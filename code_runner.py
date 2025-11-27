import sys
import time
import signal
from io import StringIO
from RestrictedPython import compile_restricted, safe_globals
from RestrictedPython.Guards import guarded_iter_unpack_sequence, safe_builtins
import contextlib
from config import config
from logger import app_logger
from monitoring import metrics, track_execution_time

# Restricted safe builtins
SAFE_BUILTINS = {
    'print': print,
    'range': range,
    'len': len,
    'str': str,
    'int': int,
    'float': float,
    'bool': bool,
    'list': list,
    'dict': dict,
    'tuple': tuple,
    'set': set,
    'abs': abs,
    'min': min,
    'max': max,
    'sum': sum,
    'sorted': sorted,
    'enumerate': enumerate,
    'zip': zip,
    'map': map,
    'filter': filter,
    'all': all,
    'any': any,
    'round': round,
    'pow': pow,
    '__builtins__': safe_builtins,
    '_iter_unpack_sequence_': guarded_iter_unpack_sequence,
    '_getiter_': lambda x: iter(x),
}

@track_execution_time
def execute_code(code: str, timeout: int = None) -> tuple:
    """
    Execute Python code in a restricted environment with timeout
    Returns: (success: bool, output: str, error: str)
    """
    if timeout is None:
        timeout = config.CODE_EXECUTION_TIMEOUT
    
    # Validate code length
    if len(code) > config.MAX_CODE_LENGTH:
        metrics.increment('code_execution_rejected')
        return False, "", f"Code too long. Maximum {config.MAX_CODE_LENGTH} characters allowed"
    
    # Capture stdout
    output_buffer = StringIO()
    error_buffer = StringIO()
    
    start_time = time.time()
    
    try:
        # Compile with RestrictedPython
        byte_code = compile_restricted(
            code,
            filename='<user_code>',
            mode='exec'
        )
        
        if byte_code.errors:
            metrics.increment('code_compilation_error')
            return False, "", "\n".join(byte_code.errors)
        
        # Create restricted globals
        restricted_globals = SAFE_BUILTINS.copy()
        restricted_globals['__builtins__'] = safe_builtins
        
        # Redirect stdout with timeout protection
        with contextlib.redirect_stdout(output_buffer), contextlib.redirect_stderr(error_buffer):
            exec(byte_code.code, restricted_globals)
            
            # Check execution time
            execution_time = time.time() - start_time
            if execution_time > timeout:
                metrics.increment('code_execution_timeout')
                return False, "", f"Execution timeout ({timeout}s exceeded)"
        
        output = output_buffer.getvalue()
        error = error_buffer.getvalue()
        
        # Truncate output if too long
        if len(output) > config.MAX_OUTPUT_LENGTH:
            output = output[:config.MAX_OUTPUT_LENGTH] + "\n... (output truncated)"
        
        if error:
            metrics.increment('code_execution_error')
            return False, output, error
        
        metrics.increment('code_execution_success')
        execution_time = time.time() - start_time
        app_logger.info(f"Code executed successfully in {execution_time:.3f}s")
        return True, output, ""
    
    except SyntaxError as e:
        metrics.increment('code_syntax_error')
        return False, "", f"Syntax Error: {str(e)}"
    except NameError as e:
        metrics.increment('code_name_error')
        return False, "", f"Name Error: {str(e)}"
    except TypeError as e:
        metrics.increment('code_type_error')
        return False, "", f"Type Error: {str(e)}"
    except ValueError as e:
        metrics.increment('code_value_error')
        return False, "", f"Value Error: {str(e)}"
    except ZeroDivisionError as e:
        metrics.increment('code_zero_division_error')
        return False, "", f"Zero Division Error: {str(e)}"
    except MemoryError as e:
        metrics.increment('code_memory_error')
        return False, "", "Memory Error: Code used too much memory"
    except RecursionError as e:
        metrics.increment('code_recursion_error')
        return False, "", "Recursion Error: Maximum recursion depth exceeded"
    except Exception as e:
        metrics.increment('code_runtime_error')
        app_logger.error(f"Code execution error: {str(e)}")
        return False, "", f"Runtime Error: {str(e)}"
    finally:
        output_buffer.close()
        error_buffer.close()

def validate_code_safety(code: str) -> tuple:
    """
    Validate code for dangerous operations
    Returns: (is_safe: bool, message: str)
    """
    dangerous_keywords = [
        'import os', 'import sys', 'import subprocess',
        'import socket', 'import requests', '__import__',
        'eval(', 'exec(', 'compile(', 'open(',
        'file(', 'input(', 'raw_input(',
        'import shutil', 'import pickle', 'import marshal',
        'import ctypes', 'import multiprocessing',
        '__builtins__', 'globals(', 'locals(',
        'delattr', 'setattr', 'getattr',
    ]
    
    code_lower = code.lower()
    for keyword in dangerous_keywords:
        if keyword in code_lower:
            metrics.increment('code_security_violation')
            app_logger.warning(f"Security violation detected: {keyword}")
            return False, f"Dangerous operation detected: {keyword}"
    
    # Check for excessive loops
    if code.count('while') > 5 or code.count('for') > 10:
        metrics.increment('code_excessive_loops')
        return False, "Too many loops detected (potential infinite loop)"
    
    metrics.increment('code_validation_passed')
    return True, "Code is safe"

if __name__ == '__main__':
    # Test the code runner
    test_code = """
x = 10
y = 20
print(f"Sum: {x + y}")
"""
    success, output, error = execute_code(test_code)
    print(f"Success: {success}")
    print(f"Output: {output}")
    print(f"Error: {error}")

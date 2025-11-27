"""Production logging configuration"""
import logging
import os
from logging.handlers import RotatingFileHandler
from datetime import datetime
from config import config

# Create logs directory
os.makedirs('logs', exist_ok=True)

def setup_logger(name: str = 'app') -> logging.Logger:
    """Setup production logger with rotation"""
    logger = logging.getLogger(name)
    logger.setLevel(getattr(logging, config.LOG_LEVEL))
    
    # Avoid duplicate handlers
    if logger.handlers:
        return logger
    
    # Console handler
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    console_format = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    console_handler.setFormatter(console_format)
    
    # File handler with rotation
    file_handler = RotatingFileHandler(
        config.LOG_FILE,
        maxBytes=config.LOG_MAX_BYTES,
        backupCount=config.LOG_BACKUP_COUNT
    )
    file_handler.setLevel(logging.DEBUG)
    file_format = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - [%(filename)s:%(lineno)d] - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    file_handler.setFormatter(file_format)
    
    logger.addHandler(console_handler)
    logger.addHandler(file_handler)
    
    return logger

# Security audit logger
def setup_audit_logger() -> logging.Logger:
    """Setup security audit logger"""
    audit_logger = logging.getLogger('audit')
    audit_logger.setLevel(logging.INFO)
    
    if audit_logger.handlers:
        return audit_logger
    
    audit_handler = RotatingFileHandler(
        'logs/audit.log',
        maxBytes=config.LOG_MAX_BYTES,
        backupCount=config.LOG_BACKUP_COUNT
    )
    audit_format = logging.Formatter(
        '%(asctime)s - AUDIT - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    audit_handler.setFormatter(audit_format)
    audit_logger.addHandler(audit_handler)
    
    return audit_logger

# Initialize loggers
app_logger = setup_logger('app')
audit_logger = setup_audit_logger()

def log_security_event(event_type: str, user_id: str, details: str):
    """Log security-related events"""
    audit_logger.info(f"{event_type} | User: {user_id} | {details}")

def log_code_execution(user_id: str, success: bool, execution_time: float):
    """Log code execution events"""
    app_logger.info(f"Code execution | User: {user_id} | Success: {success} | Time: {execution_time:.3f}s")

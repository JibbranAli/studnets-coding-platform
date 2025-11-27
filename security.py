"""Enhanced security features for production"""
import time
import hashlib
from collections import defaultdict
from threading import Lock
from config import config
from logger import log_security_event, app_logger

class SecurityManager:
    """Manage security features like login attempts, session validation"""
    
    def __init__(self):
        self.login_attempts = defaultdict(list)
        self.locked_accounts = {}
        self.active_sessions = {}
        self.lock = Lock()
    
    def record_failed_login(self, identifier: str) -> tuple:
        """
        Record failed login attempt
        Returns: (is_locked: bool, remaining_attempts: int, lockout_time: float)
        """
        with self.lock:
            current_time = time.time()
            
            # Check if account is locked
            if identifier in self.locked_accounts:
                lockout_until = self.locked_accounts[identifier]
                if current_time < lockout_until:
                    remaining_time = lockout_until - current_time
                    log_security_event('LOGIN_ATTEMPT_LOCKED', identifier, 
                                     f'Account locked for {remaining_time:.0f}s')
                    return True, 0, lockout_until
                else:
                    # Unlock account
                    del self.locked_accounts[identifier]
                    self.login_attempts[identifier] = []
            
            # Clean old attempts (older than lockout duration)
            self.login_attempts[identifier] = [
                t for t in self.login_attempts[identifier]
                if current_time - t < config.LOCKOUT_DURATION
            ]
            
            # Record new attempt
            self.login_attempts[identifier].append(current_time)
            attempts = len(self.login_attempts[identifier])
            
            # Check if should lock
            if attempts >= config.MAX_LOGIN_ATTEMPTS:
                lockout_until = current_time + config.LOCKOUT_DURATION
                self.locked_accounts[identifier] = lockout_until
                log_security_event('ACCOUNT_LOCKED', identifier, 
                                 f'Too many failed attempts: {attempts}')
                return True, 0, lockout_until
            
            remaining = config.MAX_LOGIN_ATTEMPTS - attempts
            log_security_event('LOGIN_FAILED', identifier, 
                             f'Failed attempt {attempts}/{config.MAX_LOGIN_ATTEMPTS}')
            return False, remaining, 0
    
    def clear_failed_attempts(self, identifier: str):
        """Clear failed login attempts after successful login"""
        with self.lock:
            if identifier in self.login_attempts:
                del self.login_attempts[identifier]
            if identifier in self.locked_accounts:
                del self.locked_accounts[identifier]
            log_security_event('LOGIN_SUCCESS', identifier, 'Cleared failed attempts')
    
    def is_account_locked(self, identifier: str) -> tuple:
        """Check if account is locked"""
        with self.lock:
            if identifier in self.locked_accounts:
                current_time = time.time()
                lockout_until = self.locked_accounts[identifier]
                if current_time < lockout_until:
                    return True, lockout_until - current_time
                else:
                    del self.locked_accounts[identifier]
            return False, 0
    
    def create_session(self, user_id: str, user_type: str) -> str:
        """Create a new session"""
        with self.lock:
            session_id = hashlib.sha256(
                f"{user_id}{user_type}{time.time()}".encode()
            ).hexdigest()
            
            self.active_sessions[session_id] = {
                'user_id': user_id,
                'user_type': user_type,
                'created_at': time.time(),
                'last_activity': time.time()
            }
            
            log_security_event('SESSION_CREATED', user_id, f'Session: {session_id[:8]}...')
            return session_id
    
    def validate_session(self, session_id: str) -> tuple:
        """Validate session and check timeout"""
        with self.lock:
            if session_id not in self.active_sessions:
                return False, None
            
            session = self.active_sessions[session_id]
            current_time = time.time()
            
            # Check timeout
            if current_time - session['last_activity'] > config.SESSION_TIMEOUT:
                del self.active_sessions[session_id]
                log_security_event('SESSION_TIMEOUT', session['user_id'], 
                                 f'Session: {session_id[:8]}...')
                return False, None
            
            # Update last activity
            session['last_activity'] = current_time
            return True, session
    
    def destroy_session(self, session_id: str):
        """Destroy a session"""
        with self.lock:
            if session_id in self.active_sessions:
                user_id = self.active_sessions[session_id]['user_id']
                del self.active_sessions[session_id]
                log_security_event('SESSION_DESTROYED', user_id, 
                                 f'Session: {session_id[:8]}...')
    
    def sanitize_input(self, text: str, max_length: int = 1000) -> str:
        """Sanitize user input"""
        if not text:
            return ""
        
        # Truncate
        text = text[:max_length]
        
        # Remove null bytes
        text = text.replace('\x00', '')
        
        return text.strip()
    
    def validate_email(self, email: str) -> bool:
        """Basic email validation"""
        import re
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return bool(re.match(pattern, email))
    
    def validate_password_strength(self, password: str) -> tuple:
        """Validate password strength"""
        if len(password) < 8:
            return False, "Password must be at least 8 characters"
        
        has_upper = any(c.isupper() for c in password)
        has_lower = any(c.islower() for c in password)
        has_digit = any(c.isdigit() for c in password)
        
        if not (has_upper and has_lower and has_digit):
            return False, "Password must contain uppercase, lowercase, and digit"
        
        return True, "Password is strong"

# Global security manager
security_manager = SecurityManager()

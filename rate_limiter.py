"""Rate limiting for production security"""
import time
from collections import defaultdict
from threading import Lock
from config import config
from logger import app_logger

class RateLimiter:
    """Simple in-memory rate limiter"""
    
    def __init__(self):
        self.requests = defaultdict(list)
        self.code_runs = defaultdict(list)
        self.lock = Lock()
    
    def _clean_old_entries(self, entries: list, window: int = 60):
        """Remove entries older than window seconds"""
        current_time = time.time()
        return [t for t in entries if current_time - t < window]
    
    def check_rate_limit(self, user_id: str, limit_type: str = 'request') -> tuple:
        """
        Check if user has exceeded rate limit
        Returns: (allowed: bool, remaining: int, reset_time: float)
        """
        if not config.RATE_LIMIT_ENABLED:
            return True, 999, 0
        
        with self.lock:
            current_time = time.time()
            
            if limit_type == 'request':
                entries = self.requests[user_id]
                max_requests = config.MAX_REQUESTS_PER_MINUTE
            elif limit_type == 'code_run':
                entries = self.code_runs[user_id]
                max_requests = config.MAX_CODE_RUNS_PER_MINUTE
            else:
                return True, 999, 0
            
            # Clean old entries
            entries = self._clean_old_entries(entries)
            
            if limit_type == 'request':
                self.requests[user_id] = entries
            else:
                self.code_runs[user_id] = entries
            
            # Check limit
            if len(entries) >= max_requests:
                oldest_entry = min(entries)
                reset_time = oldest_entry + 60
                app_logger.warning(f"Rate limit exceeded | User: {user_id} | Type: {limit_type}")
                return False, 0, reset_time
            
            # Add new entry
            entries.append(current_time)
            remaining = max_requests - len(entries)
            
            return True, remaining, current_time + 60
    
    def record_request(self, user_id: str, limit_type: str = 'request'):
        """Record a request for rate limiting"""
        with self.lock:
            current_time = time.time()
            if limit_type == 'request':
                self.requests[user_id].append(current_time)
            elif limit_type == 'code_run':
                self.code_runs[user_id].append(current_time)

# Global rate limiter instance
rate_limiter = RateLimiter()

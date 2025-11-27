"""Production monitoring and metrics"""
import time
import psutil
from collections import defaultdict
from threading import Lock
from datetime import datetime
from config import config
from logger import app_logger

class MetricsCollector:
    """Collect and track application metrics"""
    
    def __init__(self):
        self.metrics = defaultdict(int)
        self.timings = defaultdict(list)
        self.errors = defaultdict(int)
        self.lock = Lock()
        self.start_time = time.time()
    
    def increment(self, metric_name: str, value: int = 1):
        """Increment a counter metric"""
        with self.lock:
            self.metrics[metric_name] += value
    
    def record_timing(self, metric_name: str, duration: float):
        """Record timing metric"""
        with self.lock:
            self.timings[metric_name].append(duration)
            # Keep only last 1000 entries
            if len(self.timings[metric_name]) > 1000:
                self.timings[metric_name] = self.timings[metric_name][-1000:]
    
    def record_error(self, error_type: str):
        """Record error occurrence"""
        with self.lock:
            self.errors[error_type] += 1
            app_logger.error(f"Error recorded: {error_type}")
    
    def get_metrics(self) -> dict:
        """Get current metrics snapshot"""
        with self.lock:
            uptime = time.time() - self.start_time
            
            # Calculate timing statistics
            timing_stats = {}
            for name, timings in self.timings.items():
                if timings:
                    timing_stats[name] = {
                        'count': len(timings),
                        'avg': sum(timings) / len(timings),
                        'min': min(timings),
                        'max': max(timings)
                    }
            
            return {
                'uptime_seconds': uptime,
                'counters': dict(self.metrics),
                'timings': timing_stats,
                'errors': dict(self.errors),
                'system': self.get_system_metrics()
            }
    
    def get_system_metrics(self) -> dict:
        """Get system resource metrics"""
        try:
            cpu_percent = psutil.cpu_percent(interval=0.1)
            memory = psutil.virtual_memory()
            disk = psutil.disk_usage('/')
            
            return {
                'cpu_percent': cpu_percent,
                'memory_percent': memory.percent,
                'memory_used_mb': memory.used / (1024 * 1024),
                'memory_total_mb': memory.total / (1024 * 1024),
                'disk_percent': disk.percent,
                'disk_used_gb': disk.used / (1024 * 1024 * 1024),
                'disk_total_gb': disk.total / (1024 * 1024 * 1024)
            }
        except Exception as e:
            app_logger.error(f"Failed to get system metrics: {e}")
            return {}
    
    def reset_metrics(self):
        """Reset all metrics"""
        with self.lock:
            self.metrics.clear()
            self.timings.clear()
            self.errors.clear()
            app_logger.info("Metrics reset")

class HealthCheck:
    """Application health check"""
    
    @staticmethod
    def check_database() -> tuple:
        """Check database connectivity"""
        try:
            from database import get_db
            db = get_db()
            db.execute("SELECT 1")
            db.close()
            return True, "Database OK"
        except Exception as e:
            return False, f"Database error: {str(e)}"
    
    @staticmethod
    def check_disk_space() -> tuple:
        """Check available disk space"""
        try:
            disk = psutil.disk_usage('/')
            if disk.percent > 90:
                return False, f"Disk space critical: {disk.percent}% used"
            elif disk.percent > 80:
                return True, f"Disk space warning: {disk.percent}% used"
            return True, f"Disk space OK: {disk.percent}% used"
        except Exception as e:
            return False, f"Disk check error: {str(e)}"
    
    @staticmethod
    def check_memory() -> tuple:
        """Check memory usage"""
        try:
            memory = psutil.virtual_memory()
            if memory.percent > 90:
                return False, f"Memory critical: {memory.percent}% used"
            elif memory.percent > 80:
                return True, f"Memory warning: {memory.percent}% used"
            return True, f"Memory OK: {memory.percent}% used"
        except Exception as e:
            return False, f"Memory check error: {str(e)}"
    
    @classmethod
    def get_health_status(cls) -> dict:
        """Get overall health status"""
        checks = {
            'database': cls.check_database(),
            'disk_space': cls.check_disk_space(),
            'memory': cls.check_memory()
        }
        
        overall_healthy = all(status for status, _ in checks.values())
        
        return {
            'healthy': overall_healthy,
            'timestamp': datetime.utcnow().isoformat(),
            'checks': {
                name: {'status': 'ok' if status else 'error', 'message': msg}
                for name, (status, msg) in checks.items()
            }
        }

# Global metrics collector
metrics = MetricsCollector()

def track_execution_time(func):
    """Decorator to track function execution time"""
    def wrapper(*args, **kwargs):
        start_time = time.time()
        try:
            result = func(*args, **kwargs)
            duration = time.time() - start_time
            metrics.record_timing(func.__name__, duration)
            return result
        except Exception as e:
            metrics.record_error(func.__name__)
            raise
    return wrapper

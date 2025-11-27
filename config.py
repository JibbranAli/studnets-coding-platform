"""Production configuration management"""
import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    """Base configuration"""
    # Database
    DATABASE_URL = os.getenv('DATABASE_URL', 'sqlite:///./student_platform.db')
    
    # Security
    SECRET_KEY = os.getenv('SECRET_KEY', 'change-this-in-production')
    ADMIN_USERNAME = os.getenv('ADMIN_USERNAME', 'admin')
    ADMIN_PASSWORD = os.getenv('ADMIN_PASSWORD', 'change_this_secure_password')
    
    # Session
    SESSION_TIMEOUT = int(os.getenv('SESSION_TIMEOUT', '3600'))  # 1 hour
    MAX_LOGIN_ATTEMPTS = int(os.getenv('MAX_LOGIN_ATTEMPTS', '5'))
    LOCKOUT_DURATION = int(os.getenv('LOCKOUT_DURATION', '900'))  # 15 minutes
    
    # Code Execution
    CODE_EXECUTION_TIMEOUT = int(os.getenv('CODE_EXECUTION_TIMEOUT', '5'))
    MAX_CODE_LENGTH = int(os.getenv('MAX_CODE_LENGTH', '10000'))
    MAX_OUTPUT_LENGTH = int(os.getenv('MAX_OUTPUT_LENGTH', '5000'))
    
    # Rate Limiting
    RATE_LIMIT_ENABLED = os.getenv('RATE_LIMIT_ENABLED', 'true').lower() == 'true'
    MAX_REQUESTS_PER_MINUTE = int(os.getenv('MAX_REQUESTS_PER_MINUTE', '60'))
    MAX_CODE_RUNS_PER_MINUTE = int(os.getenv('MAX_CODE_RUNS_PER_MINUTE', '10'))
    
    # Logging
    LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')
    LOG_FILE = os.getenv('LOG_FILE', 'logs/app.log')
    LOG_MAX_BYTES = int(os.getenv('LOG_MAX_BYTES', '10485760'))  # 10MB
    LOG_BACKUP_COUNT = int(os.getenv('LOG_BACKUP_COUNT', '5'))
    
    # Excel
    EXCEL_FILE_PATH = os.getenv('EXCEL_FILE_PATH', 'data/student_results.xlsx')
    AUTO_SYNC_EXCEL = os.getenv('AUTO_SYNC_EXCEL', 'true').lower() == 'true'
    
    # Server
    STREAMLIT_SERVER_PORT = int(os.getenv('STREAMLIT_SERVER_PORT', '8501'))
    STREAMLIT_SERVER_ADDRESS = os.getenv('STREAMLIT_SERVER_ADDRESS', '0.0.0.0')
    
    # Production flags
    PRODUCTION = os.getenv('PRODUCTION', 'false').lower() == 'true'
    DEBUG = os.getenv('DEBUG', 'false').lower() == 'true'
    
    # Monitoring
    ENABLE_METRICS = os.getenv('ENABLE_METRICS', 'true').lower() == 'true'
    METRICS_PORT = int(os.getenv('METRICS_PORT', '9090'))
    
    @classmethod
    def validate(cls):
        """Validate critical configuration"""
        errors = []
        
        if cls.PRODUCTION:
            if cls.SECRET_KEY == 'change-this-in-production':
                errors.append("SECRET_KEY must be changed in production")
            if cls.ADMIN_PASSWORD == 'change_this_secure_password':
                errors.append("ADMIN_PASSWORD must be changed in production")
            if cls.DEBUG:
                errors.append("DEBUG should be False in production")
        
        if errors:
            raise ValueError(f"Configuration errors: {', '.join(errors)}")
        
        return True

config = Config()

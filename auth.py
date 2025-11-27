import bcrypt
import os
from dotenv import load_dotenv
from database import User, get_db

load_dotenv()

def hash_password(password: str) -> str:
    """Hash password using bcrypt"""
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed.decode('utf-8')

def verify_password(password: str, hashed: str) -> bool:
    """Verify password against hash"""
    return bcrypt.checkpw(password.encode('utf-8'), hashed.encode('utf-8'))

def register_user(full_name: str, email: str, contact_number: str, password: str) -> tuple:
    """Register a new user"""
    db = get_db()
    try:
        # Check if email already exists
        existing_user = db.query(User).filter(User.email == email).first()
        if existing_user:
            return False, "Email already registered"
        
        # Create new user
        password_hash = hash_password(password)
        new_user = User(
            full_name=full_name,
            email=email,
            contact_number=contact_number,
            password_hash=password_hash,
            is_admin=False
        )
        db.add(new_user)
        db.commit()
        db.refresh(new_user)
        return True, "Registration successful"
    except Exception as e:
        db.rollback()
        return False, f"Registration failed: {str(e)}"
    finally:
        db.close()

def authenticate_user(email: str, password: str) -> tuple:
    """Authenticate user login"""
    db = get_db()
    try:
        user = db.query(User).filter(User.email == email).first()
        if not user:
            return False, None, "Invalid email or password"
        
        if not verify_password(password, user.password_hash):
            return False, None, "Invalid email or password"
        
        return True, user, "Login successful"
    finally:
        db.close()

def authenticate_admin(username: str, password: str) -> bool:
    """Authenticate admin login"""
    admin_username = os.getenv('ADMIN_USERNAME', 'admin')
    admin_password = os.getenv('ADMIN_PASSWORD', 'admin123')
    
    return username == admin_username and password == admin_password

def create_admin_user():
    """Create admin user if not exists"""
    db = get_db()
    try:
        admin_email = "admin@platform.com"
        existing_admin = db.query(User).filter(User.email == admin_email).first()
        
        if not existing_admin:
            admin_password = os.getenv('ADMIN_PASSWORD', 'admin123')
            password_hash = hash_password(admin_password)
            admin_user = User(
                full_name="Administrator",
                email=admin_email,
                contact_number="0000000000",
                password_hash=password_hash,
                is_admin=True
            )
            db.add(admin_user)
            db.commit()
            print("Admin user created successfully")
    finally:
        db.close()

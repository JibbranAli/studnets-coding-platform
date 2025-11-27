import os
from sqlalchemy import create_engine, Column, Integer, String, DateTime, Text, ForeignKey, Float, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv('DATABASE_URL', 'sqlite:///./student_platform.db')

engine = create_engine(DATABASE_URL, connect_args={'check_same_thread': False} if 'sqlite' in DATABASE_URL else {})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

class User(Base):
    __tablename__ = 'users'
    
    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String(255), nullable=False)
    email = Column(String(255), unique=True, nullable=False, index=True)
    contact_number = Column(String(20), nullable=False)
    password_hash = Column(String(255), nullable=False)
    is_admin = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    submissions = relationship('Submission', back_populates='user')

class Test(Base):
    __tablename__ = 'tests'
    
    id = Column(Integer, primary_key=True, index=True)
    test_name = Column(String(255), nullable=False)
    instructions = Column(Text, nullable=False)
    buggy_code = Column(Text, nullable=False)
    correct_code = Column(Text, nullable=True)
    max_marks = Column(Integer, default=20)
    created_at = Column(DateTime, default=datetime.utcnow)
    created_by = Column(Integer, ForeignKey('users.id'))
    
    assignments = relationship('Assignment', back_populates='test')
    submissions = relationship('Submission', back_populates='test')

class Assignment(Base):
    __tablename__ = 'assignments'
    
    id = Column(Integer, primary_key=True, index=True)
    test_id = Column(Integer, ForeignKey('tests.id'), nullable=False)
    student_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    assigned_at = Column(DateTime, default=datetime.utcnow)
    is_completed = Column(Boolean, default=False)
    
    test = relationship('Test', back_populates='assignments')
    student = relationship('User')

class Submission(Base):
    __tablename__ = 'submissions'
    
    id = Column(Integer, primary_key=True, index=True)
    test_id = Column(Integer, ForeignKey('tests.id'), nullable=False)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    submitted_code = Column(Text, nullable=False)
    output = Column(Text, nullable=True)
    error_message = Column(Text, nullable=True)
    score = Column(Float, default=0.0)
    submitted_at = Column(DateTime, default=datetime.utcnow)
    
    test = relationship('Test', back_populates='submissions')
    user = relationship('User', back_populates='submissions')

def init_db():
    """Initialize database tables"""
    Base.metadata.create_all(bind=engine)

def get_db():
    """Get database session"""
    db = SessionLocal()
    try:
        return db
    finally:
        pass

if __name__ == '__main__':
    init_db()
    print("Database initialized successfully!")

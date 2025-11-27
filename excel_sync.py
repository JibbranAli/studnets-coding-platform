import pandas as pd
import os
from datetime import datetime
from database import get_db, User, Test, Assignment, Submission
from pathlib import Path

EXCEL_FILE_PATH = os.getenv('EXCEL_FILE_PATH', './data/student_results.xlsx')

def ensure_excel_directory():
    """Ensure the data directory exists"""
    Path(EXCEL_FILE_PATH).parent.mkdir(parents=True, exist_ok=True)

def sync_to_excel():
    """Sync all database data to Excel file"""
    ensure_excel_directory()
    db = get_db()
    
    try:
        # Fetch all data
        users = db.query(User).filter(User.is_admin == False).all()
        tests = db.query(Test).all()
        assignments = db.query(Assignment).all()
        submissions = db.query(Submission).all()
        
        # Create DataFrames
        students_data = []
        for user in users:
            total_score = sum([s.score for s in user.submissions])
            students_data.append({
                'ID': user.id,
                'Full Name': user.full_name,
                'Email': user.email,
                'Contact Number': user.contact_number,
                'Registration Date': user.created_at.strftime('%Y-%m-%d %H:%M:%S'),
                'Total Score': total_score
            })
        
        tests_data = []
        for test in tests:
            tests_data.append({
                'Test ID': test.id,
                'Test Name': test.test_name,
                'Max Marks': test.max_marks,
                'Created At': test.created_at.strftime('%Y-%m-%d %H:%M:%S'),
                'Total Assignments': len(test.assignments),
                'Total Submissions': len(test.submissions)
            })
        
        assignments_data = []
        for assignment in assignments:
            assignments_data.append({
                'Assignment ID': assignment.id,
                'Test Name': assignment.test.test_name,
                'Student Name': assignment.student.full_name,
                'Student Email': assignment.student.email,
                'Assigned At': assignment.assigned_at.strftime('%Y-%m-%d %H:%M:%S'),
                'Completed': 'Yes' if assignment.is_completed else 'No'
            })
        
        results_data = []
        for submission in submissions:
            results_data.append({
                'Submission ID': submission.id,
                'Test Name': submission.test.test_name,
                'Student Name': submission.user.full_name,
                'Student Email': submission.user.email,
                'Score': submission.score,
                'Max Marks': submission.test.max_marks,
                'Submitted At': submission.submitted_at.strftime('%Y-%m-%d %H:%M:%S'),
                'Has Error': 'Yes' if submission.error_message else 'No'
            })
        
        # Create Excel writer
        with pd.ExcelWriter(EXCEL_FILE_PATH, engine='openpyxl') as writer:
            pd.DataFrame(students_data).to_excel(writer, sheet_name='Students', index=False)
            pd.DataFrame(tests_data).to_excel(writer, sheet_name='Tests', index=False)
            pd.DataFrame(assignments_data).to_excel(writer, sheet_name='Assignments', index=False)
            pd.DataFrame(results_data).to_excel(writer, sheet_name='Results', index=False)
        
        return True, f"Excel file updated successfully at {EXCEL_FILE_PATH}"
    
    except Exception as e:
        return False, f"Excel sync failed: {str(e)}"
    finally:
        db.close()

def get_excel_file_path():
    """Return the Excel file path"""
    return EXCEL_FILE_PATH

if __name__ == '__main__':
    success, message = sync_to_excel()
    print(message)

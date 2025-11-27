import streamlit as st
import os
from datetime import datetime
from database import init_db, get_db, User, Test, Assignment, Submission
from auth import register_user, authenticate_user, authenticate_admin, create_admin_user
from code_runner import execute_code, validate_code_safety
from excel_sync import sync_to_excel, get_excel_file_path
from dotenv import load_dotenv

load_dotenv()

# Page configuration
st.set_page_config(
    page_title="Student Code Debugging Platform",
    page_icon="🐍",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Initialize database
init_db()
create_admin_user()

# Session state initialization
if 'logged_in' not in st.session_state:
    st.session_state.logged_in = False
if 'user_type' not in st.session_state:
    st.session_state.user_type = None
if 'user_id' not in st.session_state:
    st.session_state.user_id = None
if 'user_name' not in st.session_state:
    st.session_state.user_name = None
if 'user_email' not in st.session_state:
    st.session_state.user_email = None

def logout():
    """Logout user"""
    st.session_state.logged_in = False
    st.session_state.user_type = None
    st.session_state.user_id = None
    st.session_state.user_name = None
    st.session_state.user_email = None
    st.rerun()

def login_page():
    """Login and registration page"""
    st.title("🐍 Student Code Debugging Platform")
    
    tab1, tab2, tab3 = st.tabs(["Student Login", "Student Registration", "Admin Login"])
    
    with tab1:
        st.subheader("Student Login")
        email = st.text_input("Email", key="student_login_email")
        password = st.text_input("Password", type="password", key="student_login_password")
        
        if st.button("Login as Student", key="student_login_btn"):
            if email and password:
                success, user, message = authenticate_user(email, password)
                if success:
                    st.session_state.logged_in = True
                    st.session_state.user_type = 'student'
                    st.session_state.user_id = user.id
                    st.session_state.user_name = user.full_name
                    st.session_state.user_email = user.email
                    st.success(message)
                    st.rerun()
                else:
                    st.error(message)
            else:
                st.warning("Please enter email and password")
    
    with tab2:
        st.subheader("Student Registration")
        full_name = st.text_input("Full Name", key="reg_name")
        email = st.text_input("Email", key="reg_email")
        contact = st.text_input("Contact Number", key="reg_contact")
        password = st.text_input("Password", type="password", key="reg_password")
        confirm_password = st.text_input("Confirm Password", type="password", key="reg_confirm")
        
        if st.button("Register", key="register_btn"):
            if full_name and email and contact and password and confirm_password:
                if password != confirm_password:
                    st.error("Passwords do not match")
                elif len(password) < 6:
                    st.error("Password must be at least 6 characters")
                else:
                    success, message = register_user(full_name, email, contact, password)
                    if success:
                        st.success(message)
                        sync_to_excel()
                    else:
                        st.error(message)
            else:
                st.warning("Please fill all fields")
    
    with tab3:
        st.subheader("Admin Login")
        admin_username = st.text_input("Admin Username", key="admin_username")
        admin_password = st.text_input("Admin Password", type="password", key="admin_password")
        
        if st.button("Login as Admin", key="admin_login_btn"):
            if admin_username and admin_password:
                if authenticate_admin(admin_username, admin_password):
                    st.session_state.logged_in = True
                    st.session_state.user_type = 'admin'
                    st.session_state.user_name = 'Administrator'
                    st.success("Admin login successful")
                    st.rerun()
                else:
                    st.error("Invalid admin credentials")
            else:
                st.warning("Please enter username and password")

def admin_dashboard():
    """Admin dashboard"""
    st.title("👨‍💼 Admin Dashboard")
    
    # Sidebar
    with st.sidebar:
        st.write(f"**Welcome, {st.session_state.user_name}**")
        if st.button("Logout", key="admin_logout"):
            logout()
    
    menu = st.sidebar.radio(
        "Menu",
        ["Student Management", "Test Creation", "Assign Tests", "Results Dashboard", "Excel Reports"]
    )
    
    if menu == "Student Management":
        student_management()
    elif menu == "Test Creation":
        test_creation()
    elif menu == "Assign Tests":
        assign_tests()
    elif menu == "Results Dashboard":
        results_dashboard()
    elif menu == "Excel Reports":
        excel_reports()

def student_management():
    """Student management interface"""
    st.header("Student Management")
    
    db = get_db()
    students = db.query(User).filter(User.is_admin == False).all()
    
    if students:
        st.write(f"**Total Students: {len(students)}**")
        
        student_data = []
        for student in students:
            total_score = sum([s.score for s in student.submissions])
            student_data.append({
                'ID': student.id,
                'Name': student.full_name,
                'Email': student.email,
                'Contact': student.contact_number,
                'Total Score': total_score,
                'Registered': student.created_at.strftime('%Y-%m-%d')
            })
        
        st.dataframe(student_data, use_container_width=True)
    else:
        st.info("No students registered yet")
    
    db.close()

def test_creation():
    """Test creation interface"""
    st.header("Create Debugging Test")
    
    test_name = st.text_input("Test Name")
    instructions = st.text_area("Instructions", height=100)
    buggy_code = st.text_area("Buggy Python Code", height=300, value="# Write buggy code here\n")
    max_marks = st.number_input("Maximum Marks", min_value=1, value=20)
    
    if st.button("Create Test"):
        if test_name and instructions and buggy_code:
            db = get_db()
            try:
                new_test = Test(
                    test_name=test_name,
                    instructions=instructions,
                    buggy_code=buggy_code,
                    max_marks=max_marks
                )
                db.add(new_test)
                db.commit()
                st.success("Test created successfully!")
                sync_to_excel()
            except Exception as e:
                st.error(f"Error creating test: {str(e)}")
            finally:
                db.close()
        else:
            st.warning("Please fill all fields")

def assign_tests():
    """Assign tests to students"""
    st.header("Assign Tests to Students")
    
    db = get_db()
    tests = db.query(Test).all()
    students = db.query(User).filter(User.is_admin == False).all()
    
    if not tests:
        st.warning("No tests available. Please create a test first.")
        db.close()
        return
    
    if not students:
        st.warning("No students registered yet.")
        db.close()
        return
    
    test_options = {f"{test.test_name} (ID: {test.id})": test.id for test in tests}
    selected_test = st.selectbox("Select Test", list(test_options.keys()))
    
    student_options = {f"{student.full_name} ({student.email})": student.id for student in students}
    selected_students = st.multiselect("Select Students", list(student_options.keys()))
    
    if st.button("Assign Test"):
        if selected_test and selected_students:
            test_id = test_options[selected_test]
            assigned_count = 0
            
            for student_key in selected_students:
                student_id = student_options[student_key]
                
                # Check if already assigned
                existing = db.query(Assignment).filter(
                    Assignment.test_id == test_id,
                    Assignment.student_id == student_id
                ).first()
                
                if not existing:
                    assignment = Assignment(test_id=test_id, student_id=student_id)
                    db.add(assignment)
                    assigned_count += 1
            
            db.commit()
            st.success(f"Test assigned to {assigned_count} student(s)")
            sync_to_excel()
        else:
            st.warning("Please select test and students")
    
    db.close()

def results_dashboard():
    """View all results"""
    st.header("Results Dashboard")
    
    db = get_db()
    submissions = db.query(Submission).all()
    
    if submissions:
        results_data = []
        for sub in submissions:
            results_data.append({
                'Student': sub.user.full_name,
                'Email': sub.user.email,
                'Test': sub.test.test_name,
                'Score': f"{sub.score}/{sub.test.max_marks}",
                'Submitted': sub.submitted_at.strftime('%Y-%m-%d %H:%M'),
                'Status': 'Pass' if sub.score == sub.test.max_marks else 'Fail'
            })
        
        st.dataframe(results_data, use_container_width=True)
    else:
        st.info("No submissions yet")
    
    db.close()

def excel_reports():
    """Excel reports management"""
    st.header("Excel Reports")
    
    if st.button("Sync Database to Excel"):
        success, message = sync_to_excel()
        if success:
            st.success(message)
        else:
            st.error(message)
    
    excel_path = get_excel_file_path()
    if os.path.exists(excel_path):
        st.info(f"Excel file location: {excel_path}")
        
        with open(excel_path, 'rb') as f:
            st.download_button(
                label="Download Excel Report",
                data=f,
                file_name="student_results.xlsx",
                mime="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            )
    else:
        st.warning("Excel file not found. Click 'Sync Database to Excel' to create it.")

def student_dashboard():
    """Student dashboard"""
    st.title("🎓 Student Dashboard")
    
    # Sidebar
    with st.sidebar:
        st.write(f"**Welcome, {st.session_state.user_name}**")
        st.write(f"Email: {st.session_state.user_email}")
        if st.button("Logout", key="student_logout"):
            logout()
    
    menu = st.sidebar.radio("Menu", ["My Assigned Tests", "Practice Playground"])
    
    if menu == "My Assigned Tests":
        my_assigned_tests()
    elif menu == "Practice Playground":
        practice_playground()

def my_assigned_tests():
    """Display assigned tests"""
    st.header("My Assigned Tests")
    
    db = get_db()
    assignments = db.query(Assignment).filter(
        Assignment.student_id == st.session_state.user_id
    ).all()
    
    if not assignments:
        st.info("No tests assigned yet")
        db.close()
        return
    
    for assignment in assignments:
        test = assignment.test
        
        with st.expander(f"📝 {test.test_name} - Max Marks: {test.max_marks}"):
            st.write(f"**Instructions:** {test.instructions}")
            
            # Check if already submitted
            submission = db.query(Submission).filter(
                Submission.test_id == test.id,
                Submission.user_id == st.session_state.user_id
            ).first()
            
            if submission:
                st.success(f"✅ Completed - Score: {submission.score}/{test.max_marks}")
                st.write(f"Submitted at: {submission.submitted_at.strftime('%Y-%m-%d %H:%M:%S')}")
                
                if st.checkbox(f"View Submission Details - {test.test_name}", key=f"view_{test.id}"):
                    st.code(submission.submitted_code, language='python')
                    if submission.output:
                        st.write("**Output:**")
                        st.text(submission.output)
                    if submission.error_message:
                        st.error(f"**Error:** {submission.error_message}")
            else:
                st.warning("⏳ Not completed yet")
                
                if st.button(f"Start Test: {test.test_name}", key=f"start_{test.id}"):
                    st.session_state.current_test_id = test.id
                    st.rerun()
    
    # Test interface
    if 'current_test_id' in st.session_state:
        show_test_interface(st.session_state.current_test_id, db)
    
    db.close()

def show_test_interface(test_id, db):
    """Show debugging interface"""
    test = db.query(Test).filter(Test.id == test_id).first()
    
    st.divider()
    st.header(f"🔧 Debugging: {test.test_name}")
    
    col1, col2 = st.columns([1, 1])
    
    with col1:
        st.subheader("Code Editor")
        user_code = st.text_area(
            "Fix the buggy code:",
            value=test.buggy_code,
            height=400,
            key=f"code_editor_{test_id}"
        )
    
    with col2:
        st.subheader("Output & Results")
        
        if st.button("Run Code", key=f"run_{test_id}"):
            is_safe, safety_msg = validate_code_safety(user_code)
            
            if not is_safe:
                st.error(f"Security Error: {safety_msg}")
            else:
                success, output, error = execute_code(user_code)
                
                if success:
                    st.success("✅ Code executed successfully!")
                    if output:
                        st.text_area("Output:", value=output, height=200)
                else:
                    st.error("❌ Code has errors")
                    st.text_area("Error:", value=error, height=200)
        
        if st.button("Submit Solution", key=f"submit_{test_id}"):
            is_safe, safety_msg = validate_code_safety(user_code)
            
            if not is_safe:
                st.error(f"Security Error: {safety_msg}")
            else:
                success, output, error = execute_code(user_code)
                
                # Calculate score
                score = test.max_marks if success else 0
                
                # Save submission
                submission = Submission(
                    test_id=test_id,
                    user_id=st.session_state.user_id,
                    submitted_code=user_code,
                    output=output,
                    error_message=error,
                    score=score
                )
                db.add(submission)
                
                # Update assignment status
                assignment = db.query(Assignment).filter(
                    Assignment.test_id == test_id,
                    Assignment.student_id == st.session_state.user_id
                ).first()
                if assignment:
                    assignment.is_completed = True
                
                db.commit()
                
                st.success(f"Submitted! Your score: {score}/{test.max_marks}")
                sync_to_excel()
                
                # Clear current test
                del st.session_state.current_test_id
                st.rerun()

def practice_playground():
    """Python practice playground"""
    st.header("🎮 Python Practice Playground")
    st.write("Practice Python coding in a safe environment")
    
    code = st.text_area(
        "Write your Python code:",
        value="# Write your Python code here\nprint('Hello, World!')\n",
        height=300,
        key="playground_code"
    )
    
    if st.button("Run Code", key="playground_run"):
        is_safe, safety_msg = validate_code_safety(code)
        
        if not is_safe:
            st.error(f"Security Error: {safety_msg}")
        else:
            success, output, error = execute_code(code)
            
            if success:
                st.success("✅ Code executed successfully!")
                if output:
                    st.subheader("Output:")
                    st.code(output)
            else:
                st.error("❌ Code has errors")
                st.subheader("Error:")
                st.code(error)

# Main application
def main():
    if not st.session_state.logged_in:
        login_page()
    else:
        if st.session_state.user_type == 'admin':
            admin_dashboard()
        elif st.session_state.user_type == 'student':
            student_dashboard()

if __name__ == '__main__':
    main()

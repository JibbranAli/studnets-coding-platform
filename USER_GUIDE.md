# Student Code Debugging Platform - User Guide

## Table of Contents
1. [For Students](#for-students)
2. [For Administrators](#for-administrators)
3. [Common Tasks](#common-tasks)
4. [Troubleshooting](#troubleshooting)

---

## For Students

### Getting Started

#### 1. Registration
1. Open the platform URL in your browser
2. Click on **"Student Registration"** tab
3. Fill in your details:
   - Full Name
   - Email Address
   - Contact Number
   - Password (minimum 8 characters with uppercase, lowercase, and digit)
   - Confirm Password
4. Click **"Register"**
5. You'll see a success message

#### 2. Login
1. Go to **"Student Login"** tab
2. Enter your email and password
3. Click **"Login as Student"**

### Using the Platform

#### View Assigned Tests
1. After login, you'll see **"My Assigned Tests"** section
2. All tests assigned to you will be listed
3. Each test shows:
   - Test name
   - Maximum marks
   - Instructions
   - Completion status

#### Solving a Test

1. **Start the Test:**
   - Click **"Start Test: [Test Name]"** button
   - The buggy code will appear in the code editor

2. **Fix the Code:**
   - Read the instructions carefully
   - Identify the bugs in the code
   - Edit the code in the text area
   - Fix all errors

3. **Test Your Solution:**
   - Click **"Run Code"** to test without submitting
   - Check the output for errors
   - Fix any issues
   - Run again until it works

4. **Submit Your Solution:**
   - Once your code runs successfully
   - Click **"Submit Solution"**
   - Your score will be calculated automatically
   - Full marks if code runs without errors

#### Practice Playground

1. Go to **"Practice Playground"** from the menu
2. Write any Python code to practice
3. Click **"Run Code"** to execute
4. See output or errors immediately
5. This doesn't affect your grades

### Tips for Success

✅ **Read Instructions Carefully** - Each test has specific requirements

✅ **Test Before Submitting** - Use "Run Code" to verify your solution

✅ **Check Error Messages** - They tell you what's wrong

✅ **Practice Regularly** - Use the playground to improve skills

✅ **Don't Rush** - Take time to understand the bugs

### Security Restrictions

For safety, the following are **NOT allowed**:
- ❌ File operations (open, read, write)
- ❌ Importing external modules (os, sys, subprocess)
- ❌ Network operations
- ❌ System commands
- ❌ Infinite loops (limited execution time)

---

## For Administrators

### Getting Started

#### Admin Login
1. Go to **"Admin Login"** tab
2. Enter admin username (default: `admin`)
3. Enter admin password (set during installation)
4. Click **"Login as Admin"**

### Admin Dashboard

#### 1. Student Management

**View All Students:**
- See complete list of registered students
- View student details: Name, Email, Contact, Total Score
- Track registration dates

**Student Information Includes:**
- Student ID
- Full Name
- Email Address
- Contact Number
- Total Score across all tests
- Registration Date

#### 2. Test Creation

**Create a New Test:**

1. Go to **"Test Creation"** menu
2. Fill in test details:
   - **Test Name**: Descriptive name (e.g., "Python Loops Debugging")
   - **Instructions**: Clear instructions for students
   - **Buggy Code**: Python code with intentional bugs
   - **Maximum Marks**: Points for this test (default: 20)
3. Click **"Create Test"**

**Example Test:**
```
Test Name: Fix the Loop Bug
Instructions: The code should print numbers 1 to 10, but has a bug. Fix it.
Buggy Code:
for i in range(1, 10):  # Bug: should be range(1, 11)
    print(i)
Max Marks: 10
```

#### 3. Assign Tests

**Assign Tests to Students:**

1. Go to **"Assign Tests"** menu
2. Select a test from dropdown
3. Select one or more students
4. Click **"Assign Test"**
5. Students will see the test in their dashboard

**Tips:**
- You can assign same test to multiple students
- Students can only see tests assigned to them
- Already assigned tests won't be duplicated

#### 4. Results Dashboard

**View All Submissions:**
- See all student submissions
- View scores and completion status
- Check submission timestamps
- Filter by student or test

**Information Displayed:**
- Student Name & Email
- Test Name
- Score (e.g., 20/20)
- Submission Date & Time
- Status (Pass/Fail)

#### 5. Excel Reports

**Generate Reports:**

1. Go to **"Excel Reports"** menu
2. Click **"Sync Database to Excel"**
3. Download the Excel file
4. File contains:
   - Student information
   - Test details
   - Submission records
   - Scores and timestamps

**Use Cases:**
- Share results with management
- Create backup of data
- Analyze student performance
- Generate grade reports

---

## Common Tasks

### For Students

#### How to Fix Common Errors

**Syntax Error:**
```python
# Wrong
print("Hello World"  # Missing closing parenthesis

# Correct
print("Hello World")
```

**Indentation Error:**
```python
# Wrong
def greet():
print("Hello")  # Not indented

# Correct
def greet():
    print("Hello")
```

**Name Error:**
```python
# Wrong
print(message)  # Variable not defined

# Correct
message = "Hello"
print(message)
```

#### Viewing Past Submissions

1. Go to **"My Assigned Tests"**
2. Find completed tests (marked with ✅)
3. Check **"View Submission Details"** checkbox
4. See your submitted code and results

### For Administrators

#### Bulk Test Assignment

To assign a test to all students:
1. Go to **"Assign Tests"**
2. Select the test
3. Select all students from the list
4. Click **"Assign Test"**

#### Monitoring Student Progress

1. Use **"Results Dashboard"** for overview
2. Check completion rates
3. Identify struggling students
4. Review common errors

#### Exporting Data

1. Regular backups via **"Excel Reports"**
2. Download before major updates
3. Keep historical records
4. Share with stakeholders

---

## Troubleshooting

### For Students

#### Can't Login
- ✅ Check email spelling
- ✅ Verify password (case-sensitive)
- ✅ Try password reset (contact admin)
- ✅ Clear browser cache

#### Code Won't Run
- ✅ Check for syntax errors
- ✅ Verify indentation
- ✅ Remove restricted operations
- ✅ Check error message carefully

#### Test Not Showing
- ✅ Refresh the page
- ✅ Verify test is assigned to you
- ✅ Contact administrator

#### Submission Failed
- ✅ Ensure code runs successfully first
- ✅ Check internet connection
- ✅ Try again after a moment
- ✅ Contact administrator if persists

### For Administrators

#### Students Can't Register
- ✅ Check database connection
- ✅ Verify email format
- ✅ Check for duplicate emails
- ✅ Review server logs

#### Tests Not Appearing
- ✅ Verify test was created successfully
- ✅ Check if test is assigned
- ✅ Refresh student dashboard
- ✅ Check database sync

#### Excel Export Fails
- ✅ Check data directory permissions
- ✅ Verify disk space
- ✅ Try manual sync
- ✅ Check logs for errors

#### Performance Issues
- ✅ Check server resources
- ✅ Review concurrent users
- ✅ Check database performance
- ✅ Review logs for bottlenecks

---

## Best Practices

### For Students

1. **Practice First** - Use playground before attempting tests
2. **Read Carefully** - Understand requirements before coding
3. **Test Thoroughly** - Run code multiple times
4. **Learn from Errors** - Error messages are helpful
5. **Don't Copy** - Learn by doing

### For Administrators

1. **Clear Instructions** - Write detailed test instructions
2. **Test Your Tests** - Verify buggy code and solutions
3. **Regular Backups** - Export data frequently
4. **Monitor Performance** - Check system health
5. **Support Students** - Be available for questions

---

## Keyboard Shortcuts

### Code Editor

- `Ctrl + A` - Select all
- `Ctrl + C` - Copy
- `Ctrl + V` - Paste
- `Ctrl + Z` - Undo
- `Tab` - Indent
- `Shift + Tab` - Unindent

---

## Getting Help

### Students
- Contact your administrator
- Check error messages
- Review this guide
- Use practice playground

### Administrators
- Check logs: `logs/app.log`
- Review documentation: `README.md`
- Run health check: `python3 healthcheck.py`
- Check deployment guide: `DEPLOYMENT.md`

---

## Frequently Asked Questions

### Students

**Q: How many times can I submit?**
A: You can submit once per test. Test thoroughly before submitting.

**Q: Can I see other students' solutions?**
A: No, all submissions are private.

**Q: What if I submit wrong code?**
A: Contact your administrator to reset the test.

**Q: Is there a time limit?**
A: Code execution has a timeout (5 seconds), but no submission deadline unless specified.

### Administrators

**Q: Can I edit tests after creation?**
A: Currently no, create a new test instead.

**Q: How to reset a student's submission?**
A: Delete the submission from database or use admin tools.

**Q: Can students see correct answers?**
A: No, they only see if their code passed or failed.

**Q: How to add more administrators?**
A: Configure additional admin accounts in the system settings.

---

## Security & Privacy

- 🔒 All passwords are encrypted
- 🔒 Code execution is sandboxed
- 🔒 No access to system files
- 🔒 Rate limiting prevents abuse
- 🔒 Session timeout for security
- 🔒 Audit logs track all actions

---

## Support

For technical issues:
- Check logs directory
- Review error messages
- Consult documentation
- Contact system administrator

---

**Version:** 1.0.0  
**Last Updated:** 2024  
**Platform:** Student Code Debugging Platform

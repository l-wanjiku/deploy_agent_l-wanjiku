Attendance Tracker Deployment Agent (deploy_agent.sh)
A production-grade Bash automation script designed to deploy, configure, run, and manage the Attendance Tracking system. This script automates environment setup, enforces robust input validation, utilizes safe Python-based configuration management, and implements graceful signal trapping for flawless error cleanup.

Key Features
Pre-flight Environment Checks: Automatically verifies that python3, zip, and the required templates/ directory exist before execution.

Flexible Roster Management:

Option A: Copy and scale down from the template roster (retaining prior session history).

Option B: Generate a fresh roster with custom student counts and initialize session counters.

Python-Powered JSON Configuration: Safely modifies config.json without relying on error-prone sed regex replacements, preventing file corruption.

Robust Input Validation: Validates numeric thresholds for warning and failure percentages using regular expressions, automatically falling back to secure defaults if invalid input is provided.

Log Archiving: Packages session attendance and absence logs into timestamped archives under archives/attendance/ and archives/absent/.

Graceful Signal Trapping (SIGINT / SIGTSTP): Intercepts user interrupts (Ctrl+C / Ctrl+Z), automatically compresses incomplete project folders into an archive (*_archive.zip), and wipes temporary directories to keep the workplace pristine.

Project Architecture
Once deployed, the script establishes the following directory structure:

attendance_tracker_<tag>/
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
├── reports/
│   ├── attendance.log
│   └── absent.log
└── archives/
├── attendance/
└── absent/

Prerequisites
Ensure your environment has the following installed:

Bash (v4+)

Python 3

zip utility

How to Run
Make sure the deployment script is executable:
chmod +x deploy_agent.sh

Launch the interactive menu:
./deploy_agent.sh


Interactive Menu Options
1) Deploy Application: Sets up the directory structure, populates the roster, configures thresholds, and verifies setup by launching the app.

2) Run Application: Executes the attendance checker for an existing deployed project tag.

3) Archive Logs: Safely backs up session logs with a precise timestamp (YYYYMMDD_HHMMSS).

4) Exit: Safely exits the script.

Signal Handling Demonstration
If you interrupt a deployment using Ctrl+C or Ctrl+Z, the script will automatically trigger the handle_interrupt trap:

Zips the incomplete workspace into attendance_tracker_<tag>_archive.zip.

Safely removes the temporary folder.

Exits cleanly with status code 130.

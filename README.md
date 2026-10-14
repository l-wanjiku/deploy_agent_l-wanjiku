# Attendance Tracker Deployment Agent (`deploy_agent.sh`)

[![Watch Video Demo](https://img.shields.io/badge/Watch-Video%20Walkthrough-blue?style=for-the-badge&logo=google-drive)](https://drive.google.com/file/d/1LsJCo--kayvBNOJnJwrBiJslf9leE3kN/view?usp=sharing)

A production-grade Bash automation script designed to deploy, configure, run, and manage the Attendance Tracking system. This script automates environment setup, enforces robust input validation, utilizes safe Python-based configuration management, and implements graceful signal trapping for flawless error cleanup.

---

## Overview

The `deploy_agent.sh` script streamlines the management of attendance tracking environments. It handles directory scaffolding, pre-flight checks, roster creation, configuration threshold updates, session execution, and historical log archiving through an intuitive, interactive command-line interface.

---

## Key Features

* **Pre-flight Environment Checks:** Automatically verifies that `python3`, `zip`, and the required `templates/` directory exist before execution.
* **Flexible Roster Management:** 
  * *Option A:* Copy and scale down from the template roster (retaining prior session history).
  * *Option B:* Generate a fresh roster with custom student counts and initialize session counters.
* **Python-Powered JSON Configuration:** Safely modifies `config.json` without relying on error-prone `sed` regex replacements, preventing file corruption.
* **Robust Input Validation:** Validates numeric thresholds for warning and failure percentages using regular expressions, automatically falling back to secure defaults if invalid input is provided.
* **Log Archiving:** Packages session attendance and absence logs into timestamped archives under `archives/attendance/` and `archives/absent/`.
* **Graceful Signal Trapping (`SIGINT` / `SIGTSTP`):** Intercepts user interrupts (`Ctrl+C` / `Ctrl+Z`), automatically compresses incomplete project folders into an archive (`*_archive.zip`), and wipes temporary directories to keep the workplace pristine.

---

## Project Architecture

Once deployed, the script establishes the following directory structure:

```text
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
Ensure your system meets the following requirements before executing the script:

Bash Shell
Version: Bash 4.0 or higher

Purpose: Required to execute the deploy_agent.sh script, interactive menus, and regular expression checks.

Python 3
Command: python3

Purpose: Required to run the core attendance application (attendance_checker.py) and perform safe JSON configuration updates.

Zip Utility
Command: zip

Purpose: Required by the signal handler trap to automatically archive incomplete deployment folders upon emergency cancellation.

How to Run
Make the deployment script executable:

Bash
chmod +x deploy_agent.sh
Launch the interactive menu:

Bash
./deploy_agent.sh
Interactive Menu Guide
When you run the script, you will be greeted with the Main Menu:

Plaintext
MAIN MENU
1) Deploy Application
2) Run Application
3) Archive Logs
4) Exit
1) Deploy Application: Sets up the directory structure, populates the roster (Option A or B), configures warning/failure thresholds, and verifies setup by automatically launching the application.

2) Run Application: Executes the attendance checker for an existing deployed project tag.

3) Archive Logs: Safely backs up session logs with a precise timestamp (YYYYMMDD_HHMMSS).

4) Exit: Safely exits the script.

Signal Handling and Error Recovery
If you interrupt a deployment using Ctrl+C or Ctrl+Z, the script automatically triggers the handle_interrupt safety trap:

Compresses the incomplete workspace into attendance_tracker_<tag>_archive.zip.

Safely removes the temporary folder to prevent clutter.

Exits cleanly with status code 130.

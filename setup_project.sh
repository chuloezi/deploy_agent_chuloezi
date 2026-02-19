#!/usr/bin/env bash
# ask user for input and if there's no input print error message
read -p "Attendance Tracker Version:" input
if [ -z "$input" ]; then
        echo "No input provided. Please input something"
        exit 1
fi
# A signal trap that runs when ctrl+c is pressed
archive() {
        tar -czf "attendance_tracker_${input}_archive" "attendance_tracker_$input"
        rm -rf attendance_tracker_$input
        echo "Project archived and the incomplete directory has been deleted"
        exit 1
}
trap archive SIGINT
# Create the parent directory
mkdir attendance_tracker_$input
# Creating subdirectories
mkdir -p attendance_tracker_$input/Helpers
mkdir -p attendance_tracker_$input/reports
# Creating files
touch attendance_tracker_$input/attendance_checker.py
touch attendance_tracker_$input/Helpers/assets.csv
touch attendance_tracker_$input/Helpers/config.json
touch attendance_tracker_$input/reports/reports.log
# writing the content of the files in the required files
# Content of the attendance_checker_py
cat <<EOF > "attendance_tracker_$input/attendance_checker.py"
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)

    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('Helpers/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']

        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")

        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])

            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100

            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful.

            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF
# content for assets.csv
cat <<EOF > "attendance_tracker_$input/Helpers/assets.csv"
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF
# content for config.json
cat <<EOF > "attendance_tracker_$input/Helpers/config.json"
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF
# content for reports.log
cat <<EOF > "attendance_tracker_$input/reports/reports.log"
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
EOF
# create script that updates the attendance thresholds
read -p "do you want to update the attendance thresholds? (yes/no): " answer
if [ "$answer" = "yes" ]; then
        read -p "New values for Warning threshold (default 75):" warning
        read -p "New values for Failure threshold (default 50):" failure
        warning=${warning:-75}
	failure=${failure:-50}
        # After updating making sure that what's edited is directly edited in the config.json file
        sed -i "s/\"warning\": [0-9]*/\"warning\": $warning/" attendance_tracker_$input/Helpers/config.json
        sed -i "s/\"failure\": [0-9]*/\"failure\": $failure/" attendance_tracker_$input/Helpers/config.json
        echo "New attendance thresholds updated succesfully!"
else
        echo "No update done on the attendance thresholds"
fi
# Performing Environment validation(checking if python is installed and the directory structure is correct)
# checking if python is installed
if python3 --version > /dev/null 2>&1; then
        echo "Python is installed"
else
        echo "Python is missing. Install it."
fi
# checking if the directory structure is correct
if [ -d "attendance_tracker_$input/Helpers" ] && \
        [ -d "attendance_tracker_$input/reports" ] && \
        [ -f "attendance_tracker_$input/attendance_checker.py" ] && \
        [ -f "attendance_tracker_$input/Helpers/assets.csv" ] && \
        [ -f "attendance_tracker_$input/Helpers/config.json" ] && \
        [ -f "attendance_tracker_$input/reports/reports.log" ]; then
                echo "Directory structure is followed"
else
        echo "Directory structure is not folowed"
fi

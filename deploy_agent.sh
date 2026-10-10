#!/bin/bash
TEMPLATES_DIR="./templates"


handle_interrupt() {
echo ""
echo "Deployment interrupted by user!"

if [ -n "$TARGET_DIR" ] && [ -d "$TARGET_DIR" ]; then
echo "Zipping incomplete project folder..."
zip -r "${TARGET_DIR}_archive.zip" "$TARGET_DIR"

echo "Removing incomplete directory to keep workplace clean..."
rm -rf "$TARGET_DIR"

echo "Saved archive to ${TARGET_DIR}_archive.zip and deleted temporary folder."
fi
exit 130
}


check_environment() {
echo "Running Pre-flight Checks"

if ! command -v python3 &> /dev/null; then
echo "Error: python3 is not installed."
exit 1
fi

if ! command -v zip &> /dev/null; then
echo "Error: zip command is not installed."
exit 1
fi

if [ ! -d "$TEMPLATES_DIR" ]; then
echo "Error: templates directory is missing."
exit 1
fi

echo "Pre-flight checks passed"
echo ""
}

deploy_app() {
check_environment

echo "Feature 1: Deploy Application"
read -p "Enter project tag (e.g. v1): " TAG

if [ -z "$TAG" ]; then
echo "Error: Project tag cannot be empty."
return
fi

TARGET_DIR="attendance_tracker_${TAG}"

if [-d "$TARGET_DIR" ]; then
read -p "Directory $TARGET_DIR already exists. Overwrite? (y/n): "
if [ "$OVERWRITE" = "y" ] || [ "$OVERWRITE" = "Y" ]; then
rm -rf "$TARGET_DIR"
else
echo "Deployment canceled."
return
fi
fi

trap handle_interrupt SIGINT SIGTSTP

echo "Creating project directory directory structure..."
mkdir -p "$TARGET_DIR/Helpers"
mkdir -p "$TARGET_DIR/reports"
mkdir -p "$TARGET_DIR/archives/attendance"
mkdir -p "$TARGET_DIR/archives/absent"

cp "$TEMPLATE_DIR/attendance_checker.py" "$TARGET_DIR/"
cp "$TEMPLATE_DIR/config.json" "$TARGET_DIR/Helpers/"

echo ""
echo "Choose roster creation method:"
echo "1) option A: Copy from template roster (4 prior sessions)"
echo "2) Option B: Generate fresh roster (0 prior sessions)"
read -p "Selection (1 or 2): " ROSTER_CHOICE
if [ "$ROSTER_CHOICE" = "1" ]; then
read -p "How many students to copy (1-10)? " NUM_STUDENTS
head -n 1 "$TEMPLATES_DIR/assets.csv" > "$TARGET_DIR/Helpers/assests.csv"
tail -n +2 "$TEMPLATES_DIR/assets.csv" | head -n "$NUM_STUDENTS" >> "$TARGET_DIR/Helpers/assests.csv"

sed -i 's/"total_sessions": [0-9]*/total_sessions": 5/' "$TARGET_DIR/Helpers/config.json"
echo "Copied $NUM_STUDENTS students. Updated total_sessions to 5."
else
read -p "How many students to generate (1-5)? " NUM_GEN
echo "Email,Names,Attendance Count, Absence Count" > "$TARGET_DIR/Helpers/assets.csv"

count 1
while [ $count -le $NUM_GEN ]; do
echo "student${count}@example.com,Student ${count},0,0" >> "$TARGET_DIR/Helpers/config.json"
count=$((count + 1))
done

sed -i 's/"total_sessions": [0-9]*/total_sessions": 1/' "$TARGET_DIR/Helpers/config.json"
echo "Generated $NUM_GEN students. Set total_sessions to 1." 
fi

echo "Setting file permissions..."
chmod +x "$TARGET_DIR/attendance_checker.py"
chmod 600 "$TARGET_DIR/Helpers/config.json"

read -p "Do you want to update attendance threshhold in config.json? (y/n): " UPDATE_CONF
if [ "$UPDATE_CONF" = "y" ] || [ "$UPDATE_CONF" = "Y" ]: then
read -p "Enter warning percentage (default 75): " WARN_VAL
read -p "Enter failure percentage (default 50): " FAIL_VAL

WARN_VAL=${WARN_VAL:-75}
FAIL_VAL=${FAIL_VAL:-50}

sed -i "s/\"warning\": [0-9]*/\"warning\": $WARN_VAL/" "$TARGET_DIR/Helpers/config.json"
sed -i "s/\"warning\": [0-9]*/\"warning\": $FAIL_VAL/" "$TARGET_DIR/Helpers/config.json"
echo "Updated thresholds to warning: $WARN_VAL, FAilure: $FAIL_VAL."
fi

trap - SIGINT SIGTSTP

echo ""
echo "Deployment completed successfully!"
echo "Verify setup by launching application..."
run_app "$TARGET_DIR"
}

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


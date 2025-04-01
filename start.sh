#!/bin/bash

echo "Setting executable permissions for scripts..."
chmod +x git_setup.sh script.sh save.sh 2>/dev/null

echo "Executing scripts in sequence..."

./git_setup.sh
timeout 300s ./script.sh
./save.sh

echo "All scripts have been executed."

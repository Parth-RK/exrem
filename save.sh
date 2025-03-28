#!/bin/bash

git pull origin main

timestamp=$(date +"%Y-%m-%d %H:%M:%S")
echo "Last update: $timestamp" >> README.md

git add .
git commit -m "Last Commit: $timestamp"

# Push to remote repository
git push origin main  # Change 'main' if your branch is different

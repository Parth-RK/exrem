#!/bin/bash

# --------------------------------------------------------------
# This script helps configure Git with your username, email, 
# and access token for authentication, along with optional 
# credential caching and SSH key setup for GitHub/GitLab/other Git providers.
# Variables are loaded from .env file
# --------------------------------------------------------------

# Check if Git is installed
if ! command -v git &> /dev/null
then
    echo "Git is not installed. Please install Git first."
    exit 1
fi

# Check if current directory is a Git repository
if [ ! -d .git ]; then
    echo "Current directory is not a Git repository. Initializing Git repository..."
    git init
    echo "Git repository initialized."
else
    echo "Git repository detected."
fi

# Load environment variables from .env file
ENV_FILE=".env"
if [ -f "$ENV_FILE" ]; then
    echo "Loading configuration from .env file..."
    source "$ENV_FILE"
    # rm -f "$0" #This line deletes the current file itself
else
    echo "No .env file found. Creating a template .env file..."
    cat > "$ENV_FILE" <<EOL
# Git configuration
GIT_USERNAME=
GIT_EMAIL=
GIT_ACCESS_TOKEN=
ENABLE_CACHE=n
ENABLE_SSH=n
EOL
    echo ".env file created. Please edit it with your details and run this script again."
    exit 1
fi

# Check if required variables are set in .env file
if [ -z "$GIT_USERNAME" ]; then
    echo "GIT_USERNAME not set in .env file. Please enter your Git username:"
    read GIT_USERNAME
fi

if [ -z "$GIT_EMAIL" ]; then
    echo "GIT_EMAIL not set in .env file. Please enter your Git email address:"
    read GIT_EMAIL
fi

# Set the Git username and email globally for all repositories
git config --global user.name "$GIT_USERNAME"
git config --global user.email "$GIT_EMAIL"

# Get the repository name from the current directory (PWD)
repo_name=$(basename "$PWD")

# Use access token from .env file
if [ -z "$GIT_ACCESS_TOKEN" ]; then
    echo "GIT_ACCESS_TOKEN not set in .env file. Please enter your GitHub Personal Access Token:"
    read GIT_ACCESS_TOKEN
fi

git remote set-url origin https://$GIT_ACCESS_TOKEN@github.com/$GIT_USERNAME/$repo_name

# Check credential caching preference from .env file
if [ -z "$ENABLE_CACHE" ]; then
    echo "ENABLE_CACHE not set in .env file. Would you like to enable credential caching? (y/n)"
    read ENABLE_CACHE
fi

# If user chooses 'y', enable Git credential caching for 15 minutes
if [ "$ENABLE_CACHE" == "y" ]; then
    git config --global credential.helper cache
    echo "Git credentials will be cached for 15 minutes."
else
    echo "Git credentials caching is disabled."
fi

# Check SSH key setup preference from .env file
if [ -z "$ENABLE_SSH" ]; then
    echo "ENABLE_SSH not set in .env file. Do you want to configure SSH key authentication for GitHub/GitLab/other Git providers? (y/n)"
    read ENABLE_SSH
fi

# If user chooses 'y', proceed to SSH key setup
if [ "$ENABLE_SSH" == "y" ]; then
    # Check if an SSH key already exists
    if [ ! -f "$HOME/.ssh/id_rsa" ]; then
        echo "SSH key not found. Generating a new SSH key..."
        # Generate a new RSA SSH key with the provided Git email address
        ssh-keygen -t rsa -b 4096 -C "$GIT_EMAIL" -f "$HOME/.ssh/id_rsa" -N ""
        echo "SSH key generated successfully."
    else
        echo "SSH key already exists."
    fi

    # Add the SSH key to the SSH agent for authentication
    echo "Adding SSH key to the SSH agent..."
    eval "$(ssh-agent -s)"
    ssh-add "$HOME/.ssh/id_rsa"

    # Display the SSH public key so user can add it to their Git provider account
    echo "Don't forget to add the SSH public key to your Git provider account (GitHub/GitLab/etc.)."
    cat "$HOME/.ssh/id_rsa.pub"
fi

# Display the current Git configuration
echo "Git configuration has been set as follows:"
git config --global --list

echo "Git credentials setup completed successfully!"

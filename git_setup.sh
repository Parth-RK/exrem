#!/bin/bash

# --------------------------------------------------------------
# This script helps configure Git with your username, email, 
# and access token for authentication, along with optional 
# credential caching and SSH key setup for GitHub/GitLab/other Git providers.
# Variables are provided by GitHub Actions environment variables
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

# Check if required environment variables are set
if [ -z "$GIT_USERNAME" ]; then
    echo "Error: GIT_USERNAME environment variable not set."
    exit 1
fi

if [ -z "$GIT_EMAIL" ]; then
    echo "Error: GIT_EMAIL environment variable not set."
    exit 1
fi

if [ -z "$GIT_ACCESS_TOKEN" ]; then
    echo "Error: GIT_ACCESS_TOKEN environment variable not set."
    exit 1
fi

# Set the Git username and email globally for all repositories
echo "Setting Git configuration with provided environment variables..."
git config --global user.name "$GIT_USERNAME"
git config --global user.email "$GIT_EMAIL"

# Get the repository name from the current directory (PWD)
repo_name=$(basename "$PWD")

# Configure remote with access token
echo "Setting up Git remote with access token..."
git remote set-url origin https://$GIT_ACCESS_TOKEN@github.com/$GIT_USERNAME/$repo_name

# Handle credential caching preference
if [ "$ENABLE_CACHE" == "y" ] || [ "$ENABLE_CACHE" == "yes" ] || [ "$ENABLE_CACHE" == "true" ]; then
    git config --global credential.helper cache
    echo "Git credentials will be cached for 15 minutes."
else
    echo "Git credentials caching is disabled."
fi

# Handle SSH key setup preference
if [ "$ENABLE_SSH" == "y" ] || [ "$ENABLE_SSH" == "yes" ] || [ "$ENABLE_SSH" == "true" ]; then
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

    # Display the SSH public key
    echo "SSH public key for reference:"
    cat "$HOME/.ssh/id_rsa.pub"
fi

# Display the current Git configuration
echo "Git configuration has been set as follows:"
git config --global --list

echo "Git credentials setup completed successfully!"


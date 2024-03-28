#!/bin/bash

# Set  environment variable
export AWS_REGION=us-east-1
export NAMESPACE=arc-saas
export ENVIRONMENT=dev

# Change directory
cd ../../samples/ || { echo "Failed to change directory"; exit 1; }

# Install git-remote-codecommit
pip3 install git-remote-codecommit || { echo "Failed to install git-remote-codecommit"; exit 1; }

# Clone codecommit repo
git clone codecommit::${AWS_REGION}://${NAMESPACE}-${ENVIRONMENT}-tenant-helm-chart-repository || { echo "Failed to clone repository"; exit 1; }

# Change directory 
cd ${NAMESPACE}-${ENVIRONMENT}-tenant-helm-chart-repository || { echo "Failed to change directory"; exit 1; }

# Check if the silo-helm folder already exists
if [ ! -d "silo-helm" ]; then
    # If it doesn't exist, create the silo-helm folder
    mkdir silo-helm || { echo "Failed to create 'silo-helm' folder"; exit 1; }
else
    echo "The 'silo-helm' folder already exists."
fi

# Check if the pooled-helm folder already exists
if [ ! -d "pooled-helm" ]; then
    # If it doesn't exist, create the pooled-helm folder
    mkdir pooled-helm || { echo "Failed to create 'pooled-helm' folder"; exit 1; }
else
    echo "The 'pooled-helm' folder already exists."
fi

# Copy silo base helm chart to silo-helm directory
cp -r ../silo-tenant/terraform/application-helm/* silo-helm/ || { echo "Failed to copy files"; exit 1; }

# removing the values.yaml as will push tenant values.yaml on tenant on-boarding
rm -rf silo-helm/values.yaml


# Copy pooled base helm chart to pooled-helm directory
cp -r ../pooled-tenant/terraform/application-helm/* pooled-helm/ || { echo "Failed to copy files"; exit 1; }

# removing the values.yaml as will push tenant values.yaml on tenant on-boarding
rm -rf pooled-helm/values.yaml

# Set origin URL
git remote set-url origin codecommit::us-east-1://${NAMESPACE}-${ENVIRONMENT}-tenant-helm-chart-repository || { echo "Failed to set remote URL"; exit 1; }

# Check if main branch already exists
if git show-ref --verify --quiet refs/heads/main; then
    echo "Main branch already exists. Skipping branch creation."
else
    # Create and switch to main branch
    git checkout -b main || { echo "Failed to create and switch to main branch"; exit 1; }
fi

# Configure user email
git config --global user.email 'devops@sourcefuse.com' || { echo "Failed to configure user email"; exit 1; }

# Configure user name
git config --global user.name 'sfdevops' || { echo "Failed to configure user name"; exit 1; }

if [ -n "$(git status --porcelain)" ]; then
    git add . || { echo "Failed to add files"; exit 1; }

    git commit -m 'Helm Chart Updated' || { echo "Failed to commit changes"; exit 1; }

    git push origin main || { echo "Failed to push changes"; exit 1; }

    echo "Changes committed and pushed successfully"
else
    echo "Nothing to commit, working tree clean. Exiting..."
fi

echo "Script executed successfully"

# this code is to take backup from the github repo which are having tags this will take backup of the particular tag in archive.zip format the zip foramt will be data_reponame_tag_archive.zip

#!/bin/bash

# Prompt user to enter GitHub repository URL
echo "Please enter GitHub repository URL:"
read -r github_repo_url

# Clone the GitHub repository
git clone "$github_repo_url"

# Get the current date in YYYY-MM-DD format
DATE=$(date +%F)

# Define the log file name using the current date
LOG_FILE="$DATE.log"


#colors
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"


# Check if the clone operation was successful
if [ $? -eq 0 ]; then
    echo -e "$G Repository cloned successfully. $N" &>>$LOG_FILE
else
    echo -e "$R Failed to clone the repository. Exiting. $N" &>>$LOG_FILE
    exit 1
fi

# Navigate to the cloned repository directory
REPO_NAME=$(basename "$github_repo_url" .git)
cd "$REPO_NAME" || exit

# Check for Git tags
git_tags=$(git tag)

# Check if there are any tags
if [ -n "$git_tags" ]; then
    echo "Git tags found:"
    echo -e "$Y $git_tags $N"

    # Prompt user to enter the tag name
    echo -ne "$G Enter the tag name to download the archive $N: "
    read -r SELECTED_TAG &>>$LOG_FILE

    # Check if the selected tag exists
    if git rev-parse "$SELECTED_TAG" &>>$LOG_FILE; then
        # Create a dir_path to store the downloaded archive
        dir_path="/home/ec2-user/git/"

        # Download the ZIP archive for the selected tag
        git archive "$SELECTED_TAG" --format=zip -o "$dir_path/${DATE}_${REPO_NAME}_git_tag${SELECTED_TAG}.zip" &>>$LOG_FILE

        # Display message indicating successful download
        echo -e "$G Archive downloaded successfully to: $dir_path/${DATE}_${REPO_NAME}_${SELECTED_TAG} $N"
    else
        # Display error message if the selected tag does not exist
        echo -e "$R Error: Selected tag does not exist. $N"
        exit 1
    fi
else
    echo -e "$R No Git tags found $N" &>>$LOG_FILE
fi

echo -e "$Y Log file is: $LOG_FILE $N"

# Change back to the parent directory
cd ..

#deleting the cloned repo
rm -rf "$REPO_NAME" &>>$LOG_FILE
echo -e "$Y delete the repo: $N $REPO_NAME"

# Project Overview
The script in the project does three tasks which are: Directory architecture, Dynamic Configuration, Process management(Signal trap), and Environment validation
## Direcctory architecture
The first thing it does is to ask the user to input the name of the parent directory which is supposed to be like this attendance_tracker_{input}, after the parent directory is named and created it immediately creates the subdirectories and files in their respective subdirectories. After, creating the subdirectories and files it copies the content or source code of the files in their respective files.
## Dynamic configuration
After that the script prompts the user to decide if they want to update the attendance thresholds and if the answer is yes, the user inputs new warning and failure thresholds and the new values are stored in the config.json file
## Process management
Now the script ensures that when the user interupts the running script by pressing ctrl+c, before exiting the script, it bundles the current directory into an archive and it names it attendance_tracker_{input}_archive
## Environment validation
After the first steps are done the script verifies if python3 is installed or not and it prints success message or a warning. After, it also checks if the directory structure is followed

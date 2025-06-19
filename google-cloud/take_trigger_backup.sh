#!/bin/bash

: '
This script takes backups for google cloud build triggers

Arguments (optional):
--trigger_name: the name of the trigger

Output: file with name <trigger_name>_<timestamp>.yaml

Prereq:
 	1. install 'jq' if not: 
        brew install jq
    2. Install gcloud sdk if not: 
        brew install --cask google-cloud-sdk
    3. Login into gcloud account: 
        gcloud auth login
    4. Setup project:
        gcloud config set project phrasal-academy-214017
    5. Install gcloud beta components:
        gcloud components install beta

 Usage: 
 1. sh <script_name> --trigger <trigger_name>
 2. sh <script_name> (this allows to input filter value, which then will list all the matching triggers)
'

# 1. Parse arguments
if [ $# -eq 0 ]; then
    echo "No arguments provided"
    read -p "Search for trigger: " filter
    gcloud beta builds triggers list --format=json | jq -r '.[].name' | grep $filter
    read -p "Input trigger name: " trigger_name
else
    while [ "$1" != "" ]; do
        case $1 in
            --trigger )             shift
                                    trigger_name=$1
                                    ;;
            * )                     echo "Invalid argument"
                                    exit 1
        esac
        shift
    done
fi

# 1. Generate the timestamp
timestamp=$(date +"%Y-%m-%d_%H%M%S")
trigger_backup_file_name=${trigger_name}_${timestamp}

echo "Creating backup for trigger: $trigger_name"
echo "Output file: ${trigger_name}_${timestamp}.yaml"

gcloud beta builds triggers export ${trigger_name} --destination=${trigger_backup_file_name}.yaml

# save the generated file to a bucket as well
echo "Saving backup in cloud bucket"
echo "Output file: gs://cloud-build-triggers-backup/${trigger_name}/${trigger_backup_file_name}.yaml"
gsutil cp ${trigger_backup_file_name}.yaml gs://cloud-build-triggers-backup/${trigger_name}/${trigger_backup_file_name}.yaml
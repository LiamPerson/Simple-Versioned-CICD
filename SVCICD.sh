#!/usr/bin/env bash
# Settings
EXECUTION_LOCATION=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo -e "\n\n$(date +%F\|%H:%M:%S) >> Running SVCICD.sh ... \n\n" >> svcicd.log
LOG_FILE=$(realpath svcicd.log)
CONFIG_FILE="svcicd.conf"

# Load defaults
RUN_FROM=$EXECUTION_LOCATION
FOUND_BRANCH=""
BRANCH="master"
REMOTE="origin/master"
INTERVAL="25"
# Load prefils
. "$CONFIG_FILE" 2>/dev/null


# Check for git & tee
hash git 2>/dev/null || { echo >&2 "This program requires git but it's not installed. "; echo -e "\nPress any key to exit ..."; read -n 1 -r -s; exit 1; }
hash tee 2>/dev/null || { echo >&2 "This program requires tee but it's not installed. "; echo -e "\nPress any key to exit ..."; read -n 1 -r -s; exit 1; }

function main() {
    # Check for remote changes ...
    if git fetch
    then
        UPSTREAM=${1:-'@{u}'}
        LOCAL=$(git rev-parse @)
        REMOTE=$(git rev-parse "$UPSTREAM")
        BASE=$(git merge-base @ "$UPSTREAM")
        if [ $LOCAL = $REMOTE ]
        then
            # Check for changes locally ... 
            if [[ `git status --porcelain` ]]
            then
            echo -e "\n$(date +%F\|%H:%M:%S) >> Detected Local Changes"
                commit_and_push
            fi;
        elif [ $LOCAL = $BASE ]
        then
            echo -e "\n$(date +%F\|%H:%M:%S) >> Remote changes detected ..."
            pull_remote
        elif [ $REMOTE = $BASE ]
        then
            commit_and_push
        else
            echo -e "\n$(date +%F\|%H:%M:%S) >> ERROR: Divergence detected ... You may need to manually fix this as to not lose files!"
        fi
        sleep 2
    else
        echo -e "\n$(date +%F\|%H:%M:%S) >> Git fetch failed ...\n"
    fi;
    
    # Loop
    sleep "$INTERVAL"
    main
}

function save_defaults() {
    echo -e "\nRUN_FROM="${RUN_FROM@Q}"\nINTERVAL="${INTERVAL@Q}"" > "$EXECUTION_LOCATION/$CONFIG_FILE"
}

function pull_remote() {
    sleep 1
    if ! git pull
    then
        echo "$(date +%F\|%H:%M:%S) >> Git pull failed ... "
    fi;
    echo -e "\n"
}

function commit_and_push() {
    echo -e "$(date +%F\|%H:%M:%S) >> Staging and pushing local changes ... "
    git add .
    git commit -m "Automatic update from SVCICD"
    git push
    echo -e "\n"
}

function check_for_remote() {
    echo -e "Checking $BRANCH for remote tracking ..."
    if [ `git rev-parse --abbrev-ref "$BRANCH"@{upstream}` ]
    then
        REMOTE=$(git rev-parse --abbrev-ref "$BRANCH"@{upstream})
        echo "Tracking using remote: $REMOTE"
        save_defaults
        echo -e "\n\nSetup complete.\nBeginning listening ...\n"
        main
    else
        echo "Could not find a remote for $BRANCH. Please make sure you are using the correct branch and have set tracking information via an upstream."
        echo -e "\nPress any key to exit ..."
        read -n 1 -r -s
    fi;
}

function change_branch() {
    read -p "Please enter the branch you want to use: " -r BRANCH
    echo "Attempting to swap to $BRANCH branch ..."

    if [ `git branch --list $BRANCH` ] && [ ! -z "$BRANCH" ]
    then
        git checkout "$BRANCH"
        check_for_remote
    else
        echo -e "\nCould not find: $BRANCH"
        change_branch
    fi;
}

# Check for remote repository in directory
function check_on_branch() {
    FOUND_BRANCH=$(git symbolic-ref --short HEAD)
    echo -e "\nFound branch: $FOUND_BRANCH"
    echo -e "Do you want to use this branch? [y/n]"
    read -n 1 -r -s
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        BRANCH=$FOUND_BRANCH
        check_for_remote
    else
        change_branch
    fi;
}

function check_folder_for_git() {
    cd "$RUN_FROM"
    if [ -d .git ] && [ ! -z "$RUN_FROM" ]
    then
        echo -e "Git repository found in: $(realpath "$RUN_FROM")";
        check_on_branch
    else
        echo -e "No git repository found in: $(realpath "$RUN_FROM")"
        change_folder_for_git
    fi;
}

function change_folder_for_git() {
    # Get directory path from user
    echo ""
    read -p "Please enter the directory of the repsitory you want to integrate with: " -r RUN_FROM
    check_folder_for_git
}


function select_folder_for_git() {
    echo -e "\nIs \"$RUN_FROM\" home to the resporitory you want to integrate with? [y/n]"
    read -n 1 -r -s
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        check_folder_for_git
    else
        change_folder_for_git
    fi;
}

function set_interval() {
    echo -e "\nYou currently have the update interval"
    echo -e "for this program set to $INTERVAL seconds"
    echo -e "\nIs this time interval you wish to use? [y/n]"
    read -n 1 -r -s
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        select_folder_for_git
    else
        set_valid_interval
    fi;
}

function set_valid_interval() {
    echo -e "\nPlease enter a valid interval in \nseconds higher than 4 second."
    read -p "120 represents 2 minutes: " INTERVAL
    if [[ $INTERVAL =~ [[:digit:]] ]] && [[ $INTERVAL -gt 4 ]]
    then
        select_folder_for_git
    else
        echo "The interval you've entere is invalid: $INTERVAL"
        set_valid_interval
    fi;
}

setup() {
    echo -e "This script will automatically update, "
    echo -e "log, and contribute to the desired remote.\n"
    set_interval
}

setup "$@" |& tee --append "$LOG_FILE"; exit
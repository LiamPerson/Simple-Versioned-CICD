#!/usr/bin/env bash
# Settings
EXECUTION_LOCATION=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
RUN_FROM=$EXECUTION_LOCATION
echo -e "\n\n$(date +%F\|%H:%M:%S) >> Running SVCICD.sh ... \n\n" >> svcicd.log
LOG_FILE=$(realpath svcicd.log)

FOUND_BRANCH=""
BRANCH="master"

REMOTE="origin/master"

# Log
# exec 3>&1 4>&2
# trap 'exec 2>&4 1>&3' 0 1 2 3
# exec 1>>$LOG_FILE 2>&1

# Check for git
hash git 2>/dev/null || { echo >&2 "This program requires git but it's not installed. "; echo -e "\nPress any key to exit ..."; read -n 1 -r -s; exit 1; }

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
            # This will fail on divergence
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
            echo -e "\n$(date +%F\|%H:%M:%S) >> ERROR: Divergence detected ..."
        fi
        sleep 2
    else
        echo -e "\n$(date +%F\|%H:%M:%S) >> Git fetch failed ...\n"
    fi;
    
    # Loop
    sleep 10
    main
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
        echo "Could not find: $BRANCH"
        change_branch
    fi;
}

# Check for remote repository in directory
function check_on_branch() {
    FOUND_BRANCH=$(git symbolic-ref --short HEAD)
    echo -e "Found branch: $FOUND_BRANCH"
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
    read -p "Please enter the directory of the repsitory you want to integrate with: " -r RUN_FROM
    check_folder_for_git
}


function select_folder_for_git() {
    echo -e "Is \"$EXECUTION_LOCATION\" home to the resporitory you want to integrate with? [y/n]"
    read -n 1 -r -s
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        check_folder_for_git
    else
        change_folder_for_git
    fi;
}

setup() {
    echo -e "This script will automatically update, "
    echo -e "log, and contribute to the desired remote.\n"
    select_folder_for_git
}

setup "$@" |& tee --append "$LOG_FILE"; exit
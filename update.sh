if [[ $EUID > 0 ]]; then
        echo "Run this script as root or with sudo."
        exit 1
fi

##
# We permit:
# -b branchname  --  update to the head of the named branch on the main repo
# -p pr_number   --  update to the head of the named PR
#

##
# The branch option is enabled by fetching all branches using
# git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
# Should the local copy be remade, this will need to be re-issued to use -b
#

while getopts ":b:p:" opt; do
        case $opt in
                b) B="$OPTARG" ;;
                p) P="$OPTARG" ;;
                \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
        esac
        case $OPTARG in
                -*) echo "Option $opt needs a valid argument"; exit 1 ;;
        esac
done


if [[ -z "$OFFLINE" ]]; then
        echo "Stopping service ..."
        systemctl stop ss13
fi


sudo -u ss13 env -i BRANCH="$B" PR="$P" bash -c '
        echo "Updating main repository."
        cd /ss13/game/repo || exit 80
        git reset --hard
        git checkout dev
        git fetch
        git pull
        if [[ -z "$BRANCH" ]]; then
                BRANCH="dev"
        fi
        if [[ -z "$PR" ]]; then
                echo "Using current head on $BRANCH."
                git checkout "$BRANCH"
        else
                echo "Using PR $PR"
                git branch -D "pr-$PR"
                git fetch origin "pull/$PR/head:pr-$PR"
                git checkout "pr-$PR"
        fi
        echo "Building."
        DreamMaker baystation12 || exit 82
        cp baystation12.rsc baystation12.dmb /ss13/game/live
'

OUTCOME=$?
if [[ $OUTCOME == 80 ]]; then
        echo "Unable to enter main repository!"
        exit 1
elif [[ $OUTCOME == 82 ]]; then
        echo "Failed compilation!"
        exit 1
elif [[ $OUTCOME != 0 ]]; then
        echo "Unhandled error code! ($OUTCOME)!"
        exit 1
else
        echo "Updated successfully."
fi

##
# Bay uses a private git repository to back up
# player data on each update. This is disabled
# here, but could be enabled by someone using
# a similar approach elsewhere.
#

#echo "Preparing save backup."
#cd /ss13/game/live/data/player_saves
#git add -A
#BACKUP_TIME=$(date +'%Y%m%d-%H%M%S')
#git commit -m "${BACKUP_TIME}"
#echo "Pushing save backup."
#git push

if [[ -z "$OFFLINE" ]]; then
        echo "Starting service..."
        systemctl start ss13
fi

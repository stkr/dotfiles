
# Helper functions for git


function gparse_type() {
    if [ $# -eq 2 ]; then
        case $2 in 
            b*)
                type="bugfix"
                ;;
            f*)
                type="feature"
                ;;
            h*)
                type="hotfix"
                ;;
            r*)
                type="release"
                ;;
            *)
                type="$1"
                ;;
        esac
        echo $type
        return 0
    elif [ $# -eq 1 ]; then
        echo $1
        return 0
    else
        echo "Wrong number of arguments $#"
        return 1
    fi
}

# Create a branch for an issue as reported in jira
# Parameters:
#  NR:     the issue number
#  TEXT:   the branch name to use (after all the mandatory prefixing etc.) 
#  [TYPE]: the type of branch to create, valid values 
#          are "bugfix", "feature", "hotfix", "release", if omitted, type is "feature"
function gcb() {
    if [ $# -lt 2 ]; then
        echo "Not enough arguments. Usage: cb NR TEXT [TYPE]."
        return 1
    fi

    nr=$1
    text=$2
    type=$( gparse_type "feature" $3 )

    branch="$type/$JIRA_PROJECT-$1-$2"
    echo $branch
    git checkout -b "$branch"
    git push --set-upstream origin "$branch"
    return 0
}


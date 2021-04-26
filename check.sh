IFS=$'\n';

# tracking Functions
log() {
  echo "* [${2:-INFO}] $1"
}

die() {
  >&2 log "$1" "ERROR"
  exit 1
}




function rest_call {
    curl -s $1 -H "${GITHUB_API_HEADER_ACCEPT}" -H "Authorization: token $GITHUB_TOKEN" >> $TMPFILE
}

function rest_call_paged() {

    rm -rf $TMPFILE
    GITHUB_API_REST=$1

    # single page result-s (no pagination), have no Link: section, the grep result is empty
    last_page=`curl -s -I "https://api.github.com${GITHUB_API_REST}" -H "${GITHUB_API_HEADER_ACCEPT}" -H "Authorization: token $GITHUB_TOKEN" | grep '^link:' | awk -F\[=\>] '{ print $5 }'`
    
    # does this result use pagination?
    if [ -z "$last_page" ]; then
        # no - this result has only one page
        rest_call "https://api.github.com${GITHUB_API_REST}"
    else
        # yes - this result is on multiple pages
        for p in `seq 1 $last_page`; do
            rest_call "https://api.github.com${GITHUB_API_REST}?page=$p"
        done
    fi
}

function get_user_details() {
    
    for each in $(cat $file); do
        ORG_USER=`echo $each | awk -F"," {'print $1'}`
        rest_call_paged "/users/${ORG_USER}"
    done
}

function check_user_details() {
    get_user_details
    
    if [[ $(cat $TMPFILE | jq .company | grep null ) || $(cat $TMPFILE | jq .name | grep null) ]] ; then
        echo "user does not have company or name specified on profile"
        exit 1
    else
        echo "valid user"
    fi
    
}

function list_user_in_org () {
    rest_call_paged "/orgs/digitalinnovation/members"  
    cat $TMPFILE | jq '.[].login' | tr -d "\""
    
}

function check_user_ad () {
    
    if [[ -z "$ARM_CLIENT_ID" ]] || [[ -z "$ARM_CLIENT_SECRET" ]] || [[ -z "$ARM_TENANT_ID" ]]; then
        echo "$help"
        die "Required env variables not entered!"
    fi


    set -ex
    # not covering the az login (so expect that az login is executed before the script)
    for each in `cat $file | awk -F\[\,\@] '{ print $5 }'`; do
         id="$each@mnscorp.net";
         echo $id 
         az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
         az ad user show --id $id --query '[employeeId,mail,accountEnabled]'
    done
    set +ex
    
}


# Static declarations
GITHUB_API_HEADER_ACCEPT="Accept: application/vnd.github.v3+json"
temp=`basename $0`
TMPFILE=`mktemp /tmp/${temp}.XXXXXX` || exit 1

# Get arguments
while getopts ':f:t:a:' OPT; do
  case $OPT in
    a)  action=$OPTARG;;
    f)  file=$OPTARG;;
    t)  GITHUB_TOKEN=$OPTARG;;
  esac
done

# Usage
help="
  usage: $0 [ -f value -t value -a value ]
     -a --> action: check_user, list_user_org, check_user_ad 
     -f --> csv file input for users(relative path to script) 
     -t --> gthub token
     environmemt variables: if check_user_ad used , then environment variables to be set
        ARM_CLIENT_ID
        ARM_CLIENT_SECRET
        ARM_TENANT_ID
    "


# Test input vars
if [[ -z "$action" ]] || [[ -z "$file" ]] || [[ -z "$GITHUB_TOKEN" ]]; then
  echo "$help"
  die "Required args not entered!"
fi

case $action in
check_user)
  check_user_details
  ;;
list_user_org)
  list_user_in_org
  ;;
check_user_ad)
  check_user_ad
  ;;
esac




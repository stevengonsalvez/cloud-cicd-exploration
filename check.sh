IFS=$'\n';

if [ ${#@} -lt 2 ]; then
    echo "usage: $0 csvfile github_token"
    exit 1;
fi

GITHUB_API_HEADER_ACCEPT="Accept: application/vnd.github.v3+json"


file=$1
GITHUB_TOKEN=$2

function get_user_details() {

for each in $(cat $file); do 
    ORG_USER=`echo $each | awk -F"," {'print $1'}`
    rest_call "https://api.github.com/users/${ORG_USER}" 
done
}

temp=`basename $0`
TMPFILE=`mktemp /tmp/${temp}.XXXXXX` || exit 1

function rest_call {
    curl -s $1 -H "${GITHUB_API_HEADER_ACCEPT}" -H "Authorization: token $GITHUB_TOKEN" >> $TMPFILE
}

check_user_details() {
    get_user_details

    if [[ $(cat $TMPFILE | jq .company | grep null ) || $(cat $TMPFILE | jq .name | grep null) ]] ; then
        echo "user does not have company or name specified on profile"
        exit 1
    else
        echo "valid user"
    fi

}


check_user_details



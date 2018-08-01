#! /bin/bash

set -euo pipefail

JIRA_ISSUES_STRING=$(git log $(git describe --tags --abbrev=0)..HEAD | grep -Eo '([A-Z]{3,}-)([0-9]+)' | uniq)
JIRA_ISSUES_STRING=$(tr -d \\n <<< $JIRA_ISSUES_STRING)
IFS=' ' read -r -a JIRA_ISSUES <<< $JIRA_ISSUES_STRING

RELEASE_VERSION=$1

#JIRA_URL="https://jira1-eu1.moneysupermarketgroup.com/rest/api/2/issue/"
JIRA_URL="http://C02R9A1GG8WN:2990/jira/rest/api/2/issue/"
API_USER="api"
API_PASSWORD="password"

SET_PAYLOAD=""
for ISSUE_KEY in "${JIRA_ISSUES[@]}"
do
    URL=http://C02R9A1GG8WN:2990/jira/rest/api/2/issue/${ISSUE_KEY}
    echo ${URL}
     curl -X PUT \
     ${URL}\
    --user "${API_USER}:${API_PASSWORD}" \
    -H 'Content-Type: application/json' \
    -d "{
        \"update\":{
            \"fixVersions\":[
            {
                \"set\":[
                    {\"name\":\"$RELEASE_VERSION\"}
                ]
            }
            ]
        }
        }"
done

git tag -a $RELEASE_VERSION -m "Release: $RELEASE_VERSION"
git push origin $RELEASE_VERSION
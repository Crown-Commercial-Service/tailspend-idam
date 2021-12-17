#!/bin/bash

# exit on failures
set -e
set -o pipefail

usage() {
  echo "Usage: $(basename "$0") [OPTIONS]" 1>&2
  echo "  -h                    - help"
  echo "  -u <USERNAME>          - CloudFoundry user             (required)"
  echo "  -p <PASSWORD>          - CloudFoundry password         (required)"
  echo "  -o <ORG_NAME>           - CloudFoundry org              (required)" 
  echo "  -s <SPACE_NAME>         - CloudFoundry space to target  (required)" 
  echo "  -a <API_URI>  - CloudFoundry API endpoint     (default: https://api.london.cloud.service.gov.uk)"
  echo "  -f                    - Force a deploy of a non standard branch to given environment"
  exit 1
}

SCRIPT_PATH="$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

API_URI="https://api.london.cloud.service.gov.uk"

while getopts "a:u:p:o:s:n:h:f" opt; do
  case $opt in
    u)
      USERNAME=$OPTARG
      ;;
    p)
      PASSWORD=$OPTARG
      ;;
    o)
      ORG_NAME=$OPTARG
      ;;
    s)
      SPACE_NAME=$OPTARG
      ;;
    n)
      SPACE_APP_NAME=$OPTARG
      ;;
    a)
      API_URI=$OPTARG
      ;;
    f)
      FORCE=yes
      ;;
    h)
      usage
      exit;;
    *)
      usage
      exit;;
  esac
done

# if required arguments are not passed exit with usage
if [[ -z "$USERNAME" || -z "$PASSWORD" || -z "$ORG_NAME" || -z "$SPACE_NAME" || -z "$SPACE_APP_NAME" ]]; then
  echo "Some or all of the required parameters are empty";
  usage
fi

if [ ! -z ${TRAVIS_BRANCH+x} ]
then
 git checkout $TRAVIS_BRANCH
fi
BRANCH=$(git symbolic-ref --short HEAD)
echo "INFO: deploying $BRANCH to $SPACE_NAME"
release_branch_re='^release/.*'
if [[ ! "$FORCE" == "yes" ]]
then

  if [[ "$SPACE_NAME" == "sandbox" ]]
  then
    if [[ ! "$BRANCH" == "sandbox" ]]
    then
      echo "We only deploy the 'sandbox' branch to $SPACE_NAME"
      echo "if you want to deploy $BRANCH to $SPACE_NAME use -f"
      exit 1
    fi
  fi

  if [[ "$SPACE_NAME" == "development" ]]
  then
    if [[ ! "$BRANCH" == "develop" ]]
    then
      echo "We only deploy the 'develop' branch to $SPACE_NAME"
      echo "if you want to deploy $BRANCH to $SPACE_NAME use -f"
      exit 1
    fi
  fi

  if [[ "$SPACE_NAME" == "pre-production" ]]
  then
    if [[ ! "$BRANCH" == "preprod" ]]
    then
      echo "We only deploy 'release/*' branches to $SPACE_NAME"
      echo "if you want to deploy $BRANCH to $SPACE_NAME use -f"
      exit 1
    fi
  fi
  
  if [[ "$SPACE_NAME" == "production" ]]
  then
    if [[ ! "$BRANCH" == "main" ]]
    then
      echo "We only deploy the 'main' branch to $SPACE_NAME"
      echo "if you want to deploy $BRANCH to $SPACE_NAME use -f"
      exit 1
    fi
  fi
fi

# environment variable(s) for manifest
MEMORY_LIMIT="1000M"

cd "$SCRIPT_PATH" || exit

# login and target space
cf login -u "$USERNAME" -p "$PASSWORD" -o "$ORG_NAME" -a "$API_URI" -s "$SPACE_NAME"
cf target -o "$ORG_NAME" -s "$SPACE_NAME"

# generate manifest
sed "s/SPACE_APP_NAME/$SPACE_APP_NAME/g" manifest.yml | sed "s/MEMORY_LIMIT/$MEMORY_LIMIT/g" > "$SPACE_APP_NAME.manifest.yml"

cd .. || exit

# deploy
cf push ccs-tailspend-idam-"$SPACE_APP_NAME" -f CF/"$SPACE_APP_NAME".manifest.yml
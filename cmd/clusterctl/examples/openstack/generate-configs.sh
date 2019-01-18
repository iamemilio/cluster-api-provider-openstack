#!/bin/bash
set -e

# Function that prints out the help message, describing the script
print_help()
{
  echo "Generate Configs:"
  echo "$SCRIPT - generates config files for Cluster API on openstack"
  echo ""
  echo "Usage:"
  echo "$SCRIPT [options] <path/to/clouds.yaml> <cloud>"
  echo "options:"
  echo "-h, --help                    show brief help"
  echo "-f, --force-overwrite         if file to be generated already exists, force script to overwrite it"
  echo ""
}

SCRIPT=$(basename $0)
while test $# -gt 0; do
        case "$1" in
          -h|--help)
            print_help
            exit 0
            ;;
          -f|--force-overwrite)
            OVERWRITE=1
            shift
            ;;
          *)
            break
            ;;
        esac
done

# Check if clouds.yaml file provided
if [[ -n "$1" ]] && [[ $1 != -* ]] && [[ $1 != --* ]];then
  CLOUDS_PATH="$1"
else
  echo "Error: No clouds.yaml provided"
  echo "You must provide a valid clouds.yaml script to genereate a cloud.conf"
  echo ""
  print_help
  exit 1
fi

# Check if os cloud is provided
if [[ -n "$2" ]] && [[ $2 != -* ]] && [[ $2 != --* ]]; then
  CLOUD=$2
else
  echo "Error: No cloud specified"
  echo "You mush specify which cloud you want to use."
  echo ""
  print_help
  exit 1
fi

if ! hash yq 2>/dev/null; then
  echo "'yq' is not available, please install it. (https://github.com/mikefarah/yq)"
  echo ""
  print_help
  exit 1
fi

yq_type=$(file $(which yq))
if [[ $yq_type == *"Python script"* ]]; then
  echo "Wrong version of 'yq' installed, please install the one from https://github.com/mikefarah/yq"
  echo ""
  print_help
  exit 1
fi

if [ -e $CONFIG_DIR/clouds.yaml ] || [ -e $CONFIG_DIR/cloud.conf ] || [ -e $CONFIG_DIR/os_cloud.txt ] && [ "$OVERWRITE" != "1" ]; then
  echo "Can't overwrite config files without user permission. Either run the script again"
  echo "with -f or --force-overwrite, or delete the config files from kustomize/base/configs."
  echo ""
  print_help
  exit 1
fi

# Define global variables
PWD=$(cd `dirname $0`; pwd)
TEMPLATES_PATH=${TEMPLATES_PATH:-$PWD/$SUPPORTED_PROVIDER_OS}
HOME_DIR=${PWD%%/cmd/clusterctl/examples/*}
CONFIG_DIR=$PWD/kustomize/base/configs

OVERWRITE=${OVERWRITE:-0} 
CLOUDS_PATH=${CLOUDS_PATH:-""}
OPENSTACK_CLOUD_CONFIG_PLAIN=$(cat "$CLOUDS_PATH")

# Just blindly parse the cloud.conf here, overwriting old vars.
AUTH_URL=$(echo "$OPENSTACK_CLOUD_CONFIG_PLAIN" | yq r - clouds.$CLOUD.auth.auth_url)
USERNAME=$(echo "$OPENSTACK_CLOUD_CONFIG_PLAIN" | yq r - clouds.$CLOUD.auth.username)
PASSWORD=$(echo "$OPENSTACK_CLOUD_CONFIG_PLAIN" | yq r - clouds.$CLOUD.auth.password)
REGION=$(echo "$OPENSTACK_CLOUD_CONFIG_PLAIN" | yq r - clouds.$CLOUD.region_name)
PROJECT_ID=$(echo "$OPENSTACK_CLOUD_CONFIG_PLAIN" | yq r - clouds.$CLOUD.auth.project_id)
DOMAIN_NAME=$(echo "$OPENSTACK_CLOUD_CONFIG_PLAIN" | yq r - clouds.$CLOUD.auth.user_domain_name)


# Basic cloud.conf, no LB configuration as that data is not known yet.
OPENSTACK_CLOUD_PROVIDER_CONF_PLAIN="[Global]
auth-url=$AUTH_URL
username=\"$USERNAME\"
password=\"$PASSWORD\"
region=\"$REGION\"
tenant-id=\"$PROJECT_ID\"
domain-name=\"$DOMAIN_NAME\"
"

echo "$CLOUD" > $CONFIG_DIR/os_cloud.txt
echo "$OPENSTACK_CLOUD_CONFIG_PLAIN" > $CONFIG_DIR/clouds.yaml
echo "$OPENSTACK_CLOUD_PROVIDER_CONF_PLAIN" > $CONFIG_DIR/cloud.conf

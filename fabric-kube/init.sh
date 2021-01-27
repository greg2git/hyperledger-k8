if test "$#" -ne 2; then
   echo "usage: util.sh <project_folder> <chaincode_folder>"
   exit 2
fi

# exit when any command fails
set -e

project_folder=$1
chaincode_folder=$2

cp -r $project_folder/configtx.yaml hlf-init-kube/
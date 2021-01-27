#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

# Initialize the root CA
cp /hlf_config/fabric-ca-config/fabric-ca-server-config.yaml "$FABRIC_CA_HOME/fabric-ca-server-config.yaml"

echo "Initializing fabric-ca server: $FABRIC_CA_NAME"
fabric-ca-server init --tls.enabled --ca.name $FABRIC_CA_NAME --csr.hosts $CA_HOST

find $FABRIC_CA_HOME

#persist CA files so that they can be used later
#cp $FABRIC_CA_HOME/ca-cert.pem $FABRIC_CA_SERVER_TLS_CERTFILE
#cp $FABRIC_CA_HOME/ca-key.pem  $FABRIC_CA_SERVER_TLS_KEYFILE

# Copy the root CA's signing certificate to the data directory to be used by others
#cp $FABRIC_CA_HOME/ca-cert.pem $TARGET_CERTFILE

# Add the custom orgs
#for o in $FABRIC_ORGS; do
#   aff=$aff"\n   $o: []"
#done
#aff="${aff#\\n   }"
#sed -i "/affiliations:/a \\   $aff" \
#   $FABRIC_CA_HOME/fabric-ca-server-orderer_node_ou-config.yaml

echo "Added extra affiliations..."

echo "Starting fabric-ca server: $FABRIC_CA_NAME"
# Start the root CA
fabric-ca-server start --ca.name $FABRIC_CA_NAME --csr.hosts $CA_HOST

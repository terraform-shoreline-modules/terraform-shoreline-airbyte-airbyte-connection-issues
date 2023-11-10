#!/bin/bash

# Set the namespace and deployment name
NAMESPACE=${NAMESPACE}
DEPLOYMENT_NAME=${AIRBYTE_DEPLOYMENT_NAME}

# Rolling restart of Airbyte deployment
kubectl rollout restart deployment $DEPLOYMENT_NAME -n $NAMESPACE
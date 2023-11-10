#!/bin/bash

# Set the Airbyte deployment name and namespace
AIRBYTE_DEPLOYMENT=${AIRBYTE_DEPLOYMENT_NAME}
AIRBYTE_NAMESPACE=${NAMESPACE}

# Check if the Airbyte deployment is running
if ! kubectl get deployment $AIRBYTE_DEPLOYMENT -n $AIRBYTE_NAMESPACE > /dev/null 2>&1; then
    echo "Airbyte deployment $AIRBYTE_DEPLOYMENT not found in namespace $AIRBYTE_NAMESPACE"
    exit 1
fi

# Check if the Airbyte pod is running
if ! kubectl get pod -l app=$AIRBYTE_DEPLOYMENT -n $AIRBYTE_NAMESPACE > /dev/null 2>&1; then
    echo "Airbyte pod not found for deployment $AIRBYTE_DEPLOYMENT in namespace $AIRBYTE_NAMESPACE"
    exit 1
fi

# Check if the pod is ready and running
if ! kubectl get pod -l app=$AIRBYTE_DEPLOYMENT -n $AIRBYTE_NAMESPACE -o 'jsonpath={.items[0].status.containerStatuses[0].ready}' | grep true > /dev/null 2>&1; then
    echo "Airbyte pod is not ready or running for deployment $AIRBYTE_DEPLOYMENT in namespace $AIRBYTE_NAMESPACE"
    exit 1
fi

# Check if the pod has a valid IP address
AIRBYTE_POD_IP=$(kubectl get pod -l app=$AIRBYTE_DEPLOYMENT -n $AIRBYTE_NAMESPACE -o 'jsonpath={.items[0].status.podIP}')
if [ -z "$AIRBYTE_POD_IP" ]; then
    echo "Airbyte pod doesn't have a valid IP address for deployment $AIRBYTE_DEPLOYMENT in namespace $AIRBYTE_NAMESPACE"
    exit 1
fi

# Check if the pod can ping a known external IP address (e.g. Google DNS server)
if ! kubectl exec $AIRBYTE_DEPLOYMENT -n $AIRBYTE_NAMESPACE -- ping -c 1 8.8.8.8 > /dev/null 2>&1; then
    echo "Airbyte pod cannot ping external IP address for deployment $AIRBYTE_DEPLOYMENT in namespace $AIRBYTE_NAMESPACE"
    exit 1
fi

echo "Airbyte deployment $AIRBYTE_DEPLOYMENT in namespace $AIRBYTE_NAMESPACE is running and has network connectivity"
exit 0
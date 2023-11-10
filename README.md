
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Airbyte Connection Issues

Airbyte Connection Issues refer to incidents that involve difficulties in establishing or maintaining connections with the Airbyte platform. This can happen due to various reasons such as network connectivity issues, configuration problems, or software bugs. As a result of these issues, users may experience interruptions in data synchronization and transfer, which can impact their workflow and business processes. Resolving these incidents requires troubleshooting by software engineers and may involve changes to the system configuration or software updates.

### Parameters

```shell
export NAMESPACE="PLACEHOLDER"
export POD_NAME="PLACEHOLDER"
export SERVICE_NAME="PLACEHOLDER"
export AIRBYTE_DEPLOYMENT_NAME="PLACEHOLDER"
```

## Debug

### Check if Airbyte pods are running

```shell
kubectl get pods -n ${NAMESPACE} -l app.kubernetes.io/name=airbyte
```

### Check pod logs

```shell
kubectl logs ${POD_NAME} -n ${NAMESPACE}
```

### Check pod events

```shell
kubectl describe pod ${POD_NAME} -n ${NAMESPACE}
```

### Check if Airbyte service is running

```shell
kubectl get service -n ${NAMESPACE}
```

### Check service endpoint

```shell
kubectl describe service ${SERVICE_NAME} -n ${NAMESPACE}
```

### Check network policies

```shell
kubectl get networkpolicies -n ${NAMESPACE}
```

### Check cluster-level network policies

```shell
kubectl get networkpolicies -n kube-system
```

### Network connectivity issues: Airbyte requires a stable internet connection to establish and maintain connections with the data sources and destinations. Any disruptions in the network can cause connection issues, leading to incidents of this type.

```shell
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
```

## Repair

### Restart services: Restart any relevant services that are involved in the Airbyte connection such as the web server or the database server. This can help reset the connection and resolve any temporary issues.

```shell
#!/bin/bash

# Set the namespace and deployment name
NAMESPACE=${NAMESPACE}
DEPLOYMENT_NAME=${AIRBYTE_DEPLOYMENT_NAME}

# Rolling restart of Airbyte deployment
kubectl rollout restart deployment $DEPLOYMENT_NAME -n $NAMESPACE

```
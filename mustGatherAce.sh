#!/bin/bash
###################################################################
#Script Name	: aceCp4iDataCollector.sh                                                                                             
#Description	: This script enables service trace/stats on all the pods of
#               integration server for the given time period. After
#               that it runs ace data collector on all the pods to
#               collect and download the log files                                                                                        
#Author       	:Anand Awasthi, Amar Shah                                             
#Email         	:anand.awasthi@in.ibm.com, samar@in.ibm.com                                         
###################################################################

# test for required input filename
if [ ! -r "$1" ]; then
    printf "error: insufficient input or file not readable.  Usage: %s property_file\n" "$0"
    exit 1
fi

# read each line into 3 variables 'name, es, value`
# (the es is just a junk variable to read the equal sign)
# test if '$name= ' if so use '$value'
while read -r name es value; do
    if [ "$name" == "API_SERVER" ]; then
        API_SERVER="$value"
    fi
    if [ "$name" == "API_TOKEN" ]; then
        API_TOKEN="$value"
    fi
    if [ "$name" == "OCP_USER" ]; then
        OCP_USER="$value"
    fi
    if [ "$name" == "OCP_PASSWORD" ]; then
        OCP_PASSWORD="$value"
    fi
    if [ "$name" == "NAMESPACE" ]; then
        NAMESPACE="$value"
    fi
    if [ "$name" == "ACE_INTEGRATION_SERVER" ]; then
        ACE_INTEGRATION_SERVER="$value"
    fi
    if [ "$name" == "ENABLE_SERVICE_TRACE" ]; then
        ENABLE_TRACE="$value"
    fi
    if [ "$name" == "ENABLE_USER_TRACE" ]; then
        ENABLE_USER_TRACE="$value"
    fi
    if [ "$name" == "USER_TRACE_PERIOD" ]; then
        USER_TRACE_PERIOD="$value"
    fi
    if [ "$name" == "SERVICE_TRACE_PERIOD" ]; then
        TRACE_PERIOD="$value"
    fi
    if [ "$name" == "ENABLE_STATS_ACCOUNTING" ]; then
        ENABLE_STATS="$value"
    fi
    if [ "$name" == "STATS_PERIOD" ]; then
        STATS_PERIOD="$value"
    fi
    if [ "$name" == "DISABLE_SERVICE_TRACE" ]; then
        DISABLE_SERVICE_TRACE="$value"
    fi
    if [ "$name" == "DISABLE_USER_TRACE" ]; then
        DISABLE_U_TRACE="$value"
    fi
    if [ "$name" == "DISABLE_ACC_STATS" ]; then
        DISABLE_ACCSTATS="$value"
    fi
    if [ "$name" == "MUSTGATHER" ]; then
        MUSTGATHER="$value"
    fi
done < "$1"

  trace=false
    TRACE=0
  if [[ "${ENABLE_TRACE}" == "y" ]]
  then
    trace=true
    TRACE=1
    # Exit if TRACE_PERIOD is not a number
    if ! [[ "$TRACE_PERIOD" =~ ^[0-9]+$ ]]
    then
        echo -e "\nTrace duration must be an integer. Exiting the script"
        exit 1
    elif [[ "$TRACE_PERIOD" -gt 86400 ]]
    then
       echo -e "\nSet the trace duration less than 24 hours i.e. 86400 seconds. Exiting the script"
       exit 1
    fi
  else
    trace=false
    TRACE=0
    TRACE_PERIOD=0
  fi
   usertrace=false
    USER_TRACE=0
  if [[ "${ENABLE_USER_TRACE}" == "y" ]]
  then
    USER_TRACE=1
    usertrace=true
    # Exit if USER_TRACE_PERIOD is not a number
    if ! [[ "$USER_TRACE_PERIOD" =~ ^[0-9]+$ ]]
    then
        echo -e "\nTrace duration must be an integer. Exiting the script"
        exit 1
    elif [[ "$USER_TRACE_PERIOD" -gt 86400 ]]
    then
       echo -e "\nSet the trace duration less than 24 hours i.e. 86400 seconds. Exiting the script"
       exit 1
    fi
  else
    usertrace=false
    USER_TRACE=0
    USER_TRACE_PERIOD=0
  fi
   stats=false
    STATS=0
  if [[ "${ENABLE_STATS}" == "y" ]]
  then
    STATS=1
    stats=true
     # Exit if STATS_PERIOD is not a number
    if ! [[ "$STATS_PERIOD" =~ ^[0-9]+$ ]]
    then
        
        echo -e "\n Stats duration must be an integer. Exiting the script"
        exit 1
    elif [[ "$STATS_PERIOD" -gt 86400 ]]
    then
       echo -e "\nSet the stats duration less than 24 hours i.e. 86400 seconds. Exiting the script"
       exit 1
    fi
  else
    stats=false
    STATS=0
    STATS_PERIOD=0
  fi
 DISABLE_TRACE=0
    disabletrace=false
#  if [[ "$TRACE_PERIOD" -eq 0 || "$TRACE" -ne 1 ]]
   if [[ "$TRACE" -ne 1 ]]
     then
  if [[ "${DISABLE_SERVICE_TRACE}" == "y" ]]
  then
    DISABLE_TRACE=1
    disabletrace=true
  else
    DISABLE_TRACE=0
    disabletrace=false
   fi
  fi
 DISABLE_USER_TRACE=0
    disableusertrace=false
#  if [[ "$USER_TRACE_PERIOD" -eq 0 || "$USER_TRACE" -ne 1 ]]
  if [[ "$USER_TRACE" -ne 1 ]]
     then
  if [[ "${DISABLE_U_TRACE}" == "y" ]]
  then
    DISABLE_USER_TRACE=1
    disableusertrace=true
  else
    DISABLE_USER_TRACE=0
    disableusertrace=false
  fi
  fi
 DISABLE_ACC_STATS=0
    disableaccstats=false
#  if [[ "$STATS_PERIOD" -eq 0 || "$STATS" -ne 1 ]]
    if [[ "$STATS" -ne 1 ]]
     then
 
  if [[ "${DISABLE_ACCSTATS}" == "y" ]]
  then
    DISABLE_ACC_STATS=1
    disableaccstats=true
  else
    DISABLE_ACC_STATS=0
    disableaccstats=false
   fi
  fi
  if [[ "${MUSTGATHER}" == "y" ]]
  then
    ENABLE_MUSTGATHER=1
    mustgather=true;
    #echo -e "\n ODBC Trace is required to be enabled via Configuration object by creating odbcinst.ini and packing it as extensions.zip and deploying to IntegrationServer as a generic configuration."
    #echo -e "\n After the odbc trace has been enabled and problem has been recreated, you may re-run this script to collect the ODBC trace from the destination IntegrationServer "
  else
    mustgather=false;
    ENABLE_MUSTGATHER=0
     
  fi
  if [[ "$trace" = true || "$stats" = true || "$usertrace" = true || "$mustgather" = true || "$disabletrace" = true || "$disableusertrace" = true || "$disableaccstats" = true ]]
  then
    # Login to OCP API server and get the service name
    echo -e '\nLogin to OCP cluster'
if [ -n "$API_TOKEN" ]; then
oc login --server=$API_SERVER --token="$API_TOKEN"

else
 oc login --server=$API_SERVER -u $OCP_USER -p $OCP_PASSWORD --insecure-skip-tls-verify

    fi

    # exit if login fails
    if [[ "$?" -ne 0 ]]
    then
      echo -e "\n Login to the cluster failed. Exiting from the script."
      exit 1
    fi

    # Switch to the target namespace
    echo -e 'Switch to target namespace\n'
    oc project $NAMESPACE
	if [[ "$?" -ne 0 ]]
    then
      echo -e "\n Incorrect namespace. Exiting from the script."
      exit 1
    fi
    # Deploy mustGather application in target namespace
    echo -e 'Deploy the Data Collector application'
    # If ACE DataCollector image needs to be passed, set the envrionment variable ACE_DATA_COL_IMAGE; else image from public 
    # repo quay.io will be picked. If data collector image has to be pulled from the quay.io public repo, please make sure 
    #that the OCP cluster has internet access
   # Set Deployment parameters from environment variables
    parameters="-p API_SERVER=$API_SERVER -p OCP_USER=$OCP_USER -p OCP_PASSWORD=$OCP_PASSWORD -p USER_TRACE_PERIOD=$USER_TRACE_PERIOD -p TRACE=$TRACE -p USER_TRACE=$USER_TRACE -p STATS=$STATS -p TRACE_PERIOD=$TRACE_PERIOD -p STATS_PERIOD=$STATS_PERIOD -p ENABLE_MUSTGATHER=$ENABLE_MUSTGATHER -p DISABLE_TRACE=$DISABLE_TRACE -p DISABLE_USER_TRACE=$DISABLE_USER_TRACE -p DISABLE_ACC_STATS=$DISABLE_ACC_STATS -p ACE_INTEGRATION_SERVER=$ACE_INTEGRATION_SERVER -p NAMESPACE=$NAMESPACE"
    if [ -n "$ACE_DATA_COL_IMAGE" ]
    then
      parameters="$parameters -p ACE_DATA_COL_IMAGE=$ACE_DATA_COL_IMAGE"
    fi
    if [ -n "$ACE_DC_APP" ]
    then
      parameters="$parameters -p ACE_DC_APP=$ACE_DC_APP"
      #oc new-app -f $MUST_GATHER_APP_YAML -p API_SERVER=$API_SERVER -p OCP_USER=$OCP_USER -p OCP_PASSWORD=$OCP_PASSWORD -p TRACE_PERIOD=$TRACE_PERIOD -p STATS_PERIOD=$STATS_PERIOD -p ACE_INTEGRATION_SERVER=$ACE_INTEGRATION_SERVER -p NAMESPACE=$NAMESPACE
    fi

    # Deploy the application
    # echo -e 'executing the deployment command: oc new-app -f ' $MUST_GATHER_APP_YAML $parameters
    echo -e "\nDeploying the diagnostic data collector application..."
    #oc new-app -f $MUST_GATHER_APP_YAML $parameters &>/dev/null
    
    oc new-app -f ace-data-collector.yaml $parameters 

    # Sleep until the must gather application is deployed
    export readyReplicas=0
    if [ -n "$ACE_DC_APP" ]
    then
      mustgatherapp=$ACE_DC_APP
    else
      mustgatherapp="acecol"
    fi
    echo -e '\nName of diag collector application: ' $mustgatherapp
    # echo -e "\nWaiting for the mustGather application to be ready"
    while [[ "$readyReplicas" -lt 1 ]]
    do  
       readyReplicas=`oc get dc/$mustgatherapp -o jsonpath='{.status.readyReplicas}'`
       if [[ "$readyReplicas" -lt 1 ]]
       then
         #echo -e '\nMustGather Application is not yet ready, sleeping for 10 seconds...\n'
         sleep 10
       fi
    done
    # echo -e '\nreadyReplicas: '$readyReplicas
    echo -e 'Data Collector Application is deployed and ready now\n'
 
    # Get the Data Collector pod name
    PODNAME=`oc get pods -l acecol=ace-cp4i-data-collector -o jsonpath='{.items[*].metadata.name}'`
    echo -e 'Data Collector POD name: '$PODNAME
    echo -e '\n****************************************************'
  
    # Stream the logs of ACE data collector pod
    echo -e '\nNow streaming the logs from Data Collector Pod'
    if [[ "$TRACE_PERIOD" -gt "$STATS_PERIOD" ]] || [[ "$USER_TRACE_PERIOD" -gt "$STATS_PERIOD" ]] 
    then
      if [[ "$TRACE_PERIOD" -gt 0 ]]
      then
       # timeout ${TRACE_PERIOD}s oc logs -f $PODNAME
       timeout 86400s oc logs -f $PODNAME
      else
       # timeout ${USER_TRACE_PERIOD}s oc logs -f $PODNAME
       timeout 86400s oc logs -f $PODNAME
      fi
    else
      # timeout ${STATS_PERIOD}s oc logs -f $PODNAME
       timeout 86400s oc logs -f $PODNAME
    fi
    
  
    echo -e '\n*********************************************************\n'
    isEndOfFile=$?
    if [[ "$isEndOfFile" -ne 0 ]]
    then
      echo -e "\nYou may ignore 'Unexpected EOF', as it indicates that the streaming of log messages have stopped while trace/stats are being collected"  
    fi
  if [ "$mustgather" = true ]
  then
    echo -e '\n A compressed file will be generated after the collection  of requested diagnostic docs.'
    export DATE=`date "+%Y%m%d%H%M%S"`
    # Wait for the file to get generated
    fileGenerated=1
    while [[ "$fileGenerated" -ne 0 ]]
    do
       oc exec $PODNAME -- /bin/bash -c "ls /tmp/${ACE_INTEGRATION_SERVER}.tar.gz &>/dev/null" &>/dev/null
       fileGenerated=$?
       if [[ "$fileGenerated" -ne 0 ]]
       then
       # echo -e '\nResulting mustGather file not generated yet. Waiting for 10 seconds ...'
        sleep 10
       fi
    done

    echo -e '\n Data collection has been completed.'
    echo -e '\nCopying diagnostic data from container to the local workstation'

    sleep 10
    oc cp $PODNAME:/tmp/${ACE_INTEGRATION_SERVER}.tar.gz ${PWD}/${ACE_INTEGRATION_SERVER}_${DATE}.tar.gz
    echo -e '\nData copied successfully. Filename : '${ACE_INTEGRATION_SERVER}_${DATE}.tar.gz
	fi
    echo -e '\n*********************************************************\n'
    echo -e '\nCleaning up all the recources created for diagnostic data collection'
    oc delete all,rolebindings -l acecol=ace-cp4i-data-collector
    echo -e '\nClean up completed'
    # Log out from the OCP cluster
    echo -e '\nLogging out from the OCP cluster ...'
    oc logout
    echo -e '\nLogged out from the OCP cluster successfully'
    echo -e '\n*********************************************************'
  else
    #echo -e '\nAt least one variable out of USER_TRACE_PERIOD, TRACE_PERIOD and STATS_PERIOD must be set and greater than zero'
    exit 1
  fi

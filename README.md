# ace-data-collector
The ACE Data collector application can be deployed by executing the script 'mustGatherAce.sh'. It takes a properties file as command line argument.   
The properties allow you to specify various option including login for the target OCP cluster (using token or userid/passwd, differnt types of diagnostic docs etc..)

Format of the Properties file :

```
# Cluster details .  If you are logging in with Token, you do not need to specify OCP_USER and OCP_PASSWORD
API_TOKEN = <login token of your OCP Cluster>
API_SERVER = <API Server URL of your OCP Cluster>
OCP_USER = <user name having cluster admin rights>
OCP_PASSWORD = <password for the ocp user>
NAMESPACE = <namespace where ACE IntServer is running>
ACE_INTEGRATION_SERVER = <name of IntServer for which diagnostic is to be collected>

# various options to enable Trace, Stats and mustgather . Set y for yes and n for no.
ENABLE_USER_TRACE = n
ENABLE_SERVICE_TRACE = y
ENABLE_STATS_ACCOUNTING = n

# Set a non-zero value (time in seconds) if you want to set trace or stats for a fixed amount of time
USER_TRACE_PERIOD = 0
SERVICE_TRACE_PERIOD = 30
STATS_PERIOD = 0

# if you have set non-zero value for the above *_PERIOD parameters, then set 'n' for respective items below

DISABLE_SERVICE_TRACE = n
DISABLE_USER_TRACE = n
DISABLE_ACC_STATS = n

# Setting MUSTGATHER to y will collect aceDataCollector as well as service trace, user trace,AccountingStats data  (whichever were enabled).
MUSTGATHER = y
```

Note that the mustgather application a.k.a. ace-data-collector application will be temporarily deployed in the same namespace where the ACE application is running. 
The generated must gather files are compressed and downloaded to the current directory.  
After successful data colelction, all resources that are created as part of this data-collector application, will be cleaned up.

### Running the ace-data-collector application

Pre-req : Make sure you have `oc` client on your workstation or infra node of your OCP cluster from where you intend to run this tool.

- Download `mustGatherAce.sh` , `ace-data-collector.yaml` `ace-cp4i.properties` from this repo and store it in a local directory of your workstation.

- Set execute permission to mustGatherAce.sh  (`chmod +x mustGatherAce.sh`)

- Execute the mustGatherAce.sh script  as 

`./mustGatherAce.sh  ace-cp4i.properties`


   
- Wait for the script to complete. Upon successful completion, the collected diagnostic will be available in the current directory.

 
Note that if you are running the mustGatherAce.sh script on Mac OS, make sure that 'coreutils' package is installed on the Mac:  
`brew install coreutils`  
`sudo ln -s /usr/local/bin/gtimeout /usr/local/bin/timeout`

Following are some of the examples of various options you can specify in the properties file for diagnostic data collection.

### To Enable service trace with a fixed duration (60 seconds) for an Integration Server and collect the traces along with mustGathers and Login using Token.
```
API_TOKEN = sha256@Mwk0MpcIYYihl5TqEsJvp6pkinIuvrdm_PzFDq0gkgA
API_SERVER = https://api.cp4i2021.cp.ibm.com:6443
OCP_USER =  
OCP_PASSWORD =  
NAMESPACE = <namespace where IntServer is deployed>
ACE_INTEGRATION_SERVER = <IntServer for which data is to be collected>
ENABLE_USER_TRACE = n
ENABLE_SERVICE_TRACE = y
ENABLE_STATS_ACCOUNTING = n
USER_TRACE_PERIOD = 0
SERVICE_TRACE_PERIOD = 60
STATS_PERIOD = 0
DISABLE_SERVICE_TRACE = n
DISABLE_USER_TRACE = n
DISABLE_ACC_STATS = n
MUSTGATHER = y

```

### To Enable service trace and Acc & Stats for an Integration Server and leave it running  and  Login using OCP user and password.
(Note : Entering the duration in 0 makes trace or Acc & Stats run indefinitely until you instruct again to stop ).
```
API_TOKEN =  
API_SERVER = https://api.cp4i2021.cp.ibm.com:6443
OCP_USER = kubeadmin
OCP_PASSWORD =  XXbhn-Np9XQ-7yfJ7-Xktav
NAMESPACE = <namespace where IntServer is deployed>
ACE_INTEGRATION_SERVER = <IntServer for which data is to be collected>
ENABLE_USER_TRACE = n
ENABLE_SERVICE_TRACE = y
ENABLE_STATS_ACCOUNTING = y
USER_TRACE_PERIOD = 0
SERVICE_TRACE_PERIOD = 0
STATS_PERIOD = 0
DISABLE_SERVICE_TRACE = n
DISABLE_USER_TRACE = n
DISABLE_ACC_STATS = n
MUSTGATHER = 0

```

### To Disable service trace and Acc & Stats for an Integration Server that were enabled previously and collect traces & Acc & stats data from the Integration Server pods
```
API_TOKEN = <login token of your OCP Cluster>
API_SERVER = <API server URL of OCP Cluster>
OCP_USER = <userid to login to cluster>
OCP_PASSWORD = <password for the given userid>
NAMESPACE = <namespace where IntServer is deployed>
ACE_INTEGRATION_SERVER = <IntServer for which data is to be collected>
ENABLE_USER_TRACE = n
ENABLE_SERVICE_TRACE = n
ENABLE_STATS_ACCOUNTING = n
USER_TRACE_PERIOD = 0
SERVICE_TRACE_PERIOD = 0
STATS_PERIOD = 0
DISABLE_SERVICE_TRACE = y
DISABLE_USER_TRACE = n
DISABLE_ACC_STATS = y
MUSTGATHER = y

```

### To collect traces & Acc & stats data from the Integration Server pods that were enabled by other means (via server.conf.yaml) and mustgathers 
```
API_TOKEN = <login token of your OCP Cluster>
API_SERVER = <API server URL of OCP Cluster>
OCP_USER = <userid to login to cluster>
OCP_PASSWORD = <password for the given userid>
NAMESPACE = <namespace where IntServer is deployed>
ACE_INTEGRATION_SERVER = <IntServer for which data is to be collected>
ENABLE_USER_TRACE = n
ENABLE_SERVICE_TRACE = n
ENABLE_STATS_ACCOUNTING = n
USER_TRACE_PERIOD = 0
SERVICE_TRACE_PERIOD = 0
STATS_PERIOD = 0
DISABLE_SERVICE_TRACE = n
DISABLE_USER_TRACE = n
DISABLE_ACC_STATS = n
MUSTGATHER = y

```
### Sample Output  
Below is the sample console output of the mustGatherAce.sh execution  
  
```
$./mustGatherAce.sh ace-cp4i.properties

Login to OCP cluster
Login successful.

You have access to 68 projects, the list has been suppressed. You can list all projects with 'oc projects'

Using project "ace".
Switch to target namespace

Already on project "ace" on server "<API server URL of OCP Cluster>".
Deploy the Data Collector application

Deploying the diagnostic data collector application...

--> Deploying template "ace/ace-data-collector" for "ace-data-collector.yaml" to project ace

     ACE Data Collector Application
     ---------
     The ACE Data collector application is used to get service trace from ACE application deployed on CP4I

     * With parameters:
        * Name of the ace data-collector application=acecol
        * ACE Integration server name= test-server
        * OpenShift API Server URL=https://xxxx.xxxx.ibm.com:6443
        * Target namespace where ACE application is deployed=ace
        * OCP_PASSWORD=.......
        * Openshift Username=kubeadmin
        * Service Trace Enabled?=1
        * User Trace Enabled?=0
        * Stats & Accounting Enabled?=1
        * Time period in seconds for which service trace will be kept enabled=90
        * Time period in seconds for which accounting stats will be kept enabled=60
        * Time period in seconds for which user trace will be kept enabled=0
        * Collect Mustgather and existing traces=1
        * Disable service trace=0
        * Disable user trace=0
        * Disable Accounting and Statistics=0
        * ACE DataCollector image=icr.io/appc-dev/ace-data-collector

--> Creating resources ...
    imagestream.image.openshift.io "acecol" created
    rolebinding.rbac.authorization.k8s.io "acecol" created
    deploymentconfig.apps.openshift.io "acecol" created
--> Success


Name of diag collector application:  acecol
Data Collector Application is deployed and ready now

Data Collector POD name: acecol-1-m5rt2

****************************************************
Getting the list of POD IPs for the integration server
Enabling trace/stats for all the pods of the integration server. List of pod IPs :  10.254.20.36

Enabled service trace for the pod ip:  10.254.20.36
Enabled Accounting Stats for pod ip:  10.254.20.36

 <========  Execute the steps to reproduce the problem now =======>

Waiting for 50 seconds

Disabled service trace for the pod ip:  10.254.20.36
Disabled Accounting Stats for pod ip:  10.254.20.36
*********************************************************

Now collecting trace/stats data for the pods. List of pods: test-server-is-c9ccc7966-7xf5z
***********************************************
* App Connect Enterprise (ACE) Data Collector *
***********************************************

Data collection started
 - Creating temporary file structure ACE_Data_Collector_20210622-040346
 - Capturing environment and version data
 Data collection completed

Output file:
  ACE_Data_Collector_20210622-040346_SIS.tar.gz


Compressing the trace files from all the replicas to test-server.tar.gz
final/
final/test-server-is-c9ccc7966-7xf5z_ACE_Data_Collector_20210622-040346_SIS.tar.gz
 

*********************************************************
 A compressed file will be generated after the collection  of requested diagnostic docs.

 Data collection has been completed.

Copying diagnostic data from container to the local workstation
tar: Removing leading `/' from member names

Data copied successfully. Filename : test-server_20210622010456.tar.gz

*********************************************************
Cleaning up all the recources created for diagnostic data collection
 
pod "acecol-1-5k9lf" deleted
replicationcontroller "acecol-1" deleted
deploymentconfig.apps.openshift.io "acecol" deleted
imagestream.image.openshift.io "acecol" deleted
rolebinding.rbac.authorization.k8s.io "acecol" deleted

Clean up completed

Logging out from the OCP cluster ...
Logged "kube:admin" out on "<API server URL of OCP Cluster>"

Logged out from the OCP cluster successfully

*********************************************************
```

### Troubleshooting problems with the data collector application/script

1) If the  *mustGatherAce.sh*  script terminates prematurely, you can clean up the resources that were created for diagnostic data collection using following command :

`oc delete all,rolebindings -l acecol=ace-cp4i-data-collector`

2) If you enter invalid or incorrect API Server URL, the script will exit with following message :
```
Login to OCP cluster
error: dial tcp: lookup api.mycp4i2021.cp.fyre.ibm.com on xx.xx.xx.xx no such host - verify you have provided the correct host and port and that the server is currently running.

 Login to the cluster failed. Exiting from the script
```
3) If you enter incorrect userid or password, the script will exit with following message
```
Login to OCP cluster
Login failed (401 Unauthorized)
Verify you have provided correct credentials.

 Login to the cluster failed. Exiting from the script
```
4) If you specify incorrect namespace, the script will throw below error message and exit:

```
error: A project named "test-namespace" does not exist on "https://api.mycp4i2021.cp.fyre.ibm.com:6443".
Incorrect namespace. Exiting from the script.
```

5) If you specify incorrect integration server name,  the script will throw below error message and exit.
```
Error from server (NotFound): integrationservers.appconnect.ibm.com "test-ser" not found
Error from server (NotFound): secrets "test-ser-is" not found

Cleaning up all the recources created for diagnostic data collection
I0623 04:02:17.059113   31958 request.go:621] Throttling request took 1.04566533s, request: GET:https://api.mycp4i2021.cp.fyre.ibm.com:6443/apis/operators.ibm.com/v1alpha1?timeout=32s
pod "acecol-1-vljf7" deleted
replicationcontroller "acecol-1" deleted
deploymentconfig.apps.openshift.io "acecol" deleted
imagestream.image.openshift.io "acecol" deleted
rolebinding.rbac.authorization.k8s.io "acecol" deleted

Clean up completed

```
6) Ignore following types of error messages if you see them on the console while data collection is in progress. These are internal messages from oc client.
```
error: KUBECONFIG is set to a file that cannot be created or modified: /.kube/config; caused by: mkdir /.kube: permission denied
error: mkdir /.kube: permission denied

error: unexpected EOF
```


The script ```deploy-percona.sh``` will test for a successful deployment of percona on cstor.
The various tests that can be performed are:
1. Deploying percona on a manual provisioned sparse pool.
2. Deploying percona on a automated provisioned sparse pool.
3. Deploying percona on a manual provisioned disk pool.
4. Deploying percona on a automated provisioned disk pool.

**NOTE:** The script assumes for a pool count of 3. If you want to test for pool count other than 3 you need do a little change in the script.

**COMMAND:**
$./deploy-percona.sh <spc-yaml-path> <percona-pvc-sc-yaml-path> <percona-deployment-yaml-path>
The script expects 3 arguments only else it will throw error.
```spc-yaml-path``` is the storagepoolclaim yaml path which could be for either manual or automated provisioning.
```percona-pvc-sc-yaml-path``` is the yaml path which will have percona pvc and sc yaml in the same file.
```percona-deployment-yaml-path``` is the percona deployment yaml

All the above discussed yamls are checked in.

Run clear.sh script to clear the resources created by the script. The script will delete all the storagepoolclaims and the percona namespace where percona deployment is done.

$./clear.sh

**EXAMPLE COMMAND RAN ON LOCAL MACHINE:**
```
ashutosh@miracle:~/Desktop/artifacts/spc$ ./deploy-percona.sh sparse-claim/sparse-claim-auto.yaml sparse-claim/percona-pvc-sparse-claim-auto.yaml percona/percona-openebs-deployment.yaml 
storagepoolclaim.openebs.io/sparse-claim-auto created
SPC name is sparse-claim-auto
->->Pool creation succeeded.
storageclass.storage.k8s.io/openebs-cstor-sparse-auto configured namespace/percona created persistentvolumeclaim/percona-pvc created
PVC name is percona-pvc
PVC namespace is percona
->->->->->->->->->->PVC successfully bound.
deployment.apps/percona created service/percona-mysql created
:(:(:(:(:(:(:(:(
Hurray! Deployed Successfully
:)
NAME                       READY     STATUS    RESTARTS   AGE
percona-5fd8bd966c-9csvt   1/1       Running   0          52s
```

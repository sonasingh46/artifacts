if [ "$1" == "" ];then
    echo "Please give the full specified path of SPC yaml as argument"
    exit 1
fi
if [ "$2" == "" ];then
    echo "Please give the full specified path of percona pvc-sc yaml as argument"
    echo "PVC and SC yaml should be in one yaml file"
    exit 1
fi
if [ "$3" == "" ];then
    echo "Please give the full specified path of percona deployment yaml as argument"
    exit 1
fi
# Apply manual disk claim to form storage pool
temp1=$(kubectl apply -f $1)
echo "$temp1"
temp2=${temp1##*/}
spcName=${temp2%" "*}
echo "SPC name is" $spcName
#Check if storage pool is created successfully
maxRetry=10
expectedPoolStatus="OnlineOnlineOnline"
until [ "$poolstatus" == "$expectedPoolStatus" ]
do
    if [ $maxRetry == 0 ];then
        break
    fi
    poolstatus=$(kubectl get csp -l openebs.io/storage-pool-claim=$spcName -o=jsonpath='{range .items[*]}{@.status.phase}{end}')
    echo -n "->"
    maxRetry=`expr $maxRetry - 1`
    sleep 10;
done

if [ "$poolstatus" == "$expectedPoolStatus" ]; then
    echo "Pool creation succeeded."
else
    echo "Pool creation failed."
    exit 1
fi
# Apply percona pvc and sc
pvcTemp1=$(kubectl apply -f $2)
echo $pvcTemp1
pvcTemp2=${pvcTemp1##*/}
pvcName=${pvcTemp2%" "*}
echo "PVC name is" $pvcName
pvcNamespaceTemp=${pvcTemp1##*namespace/}
for word in $pvcNamespaceTemp; do pvcNamesapce=$word; break; done
echo "PVC namespace is" $pvcNamesapce

maxRetry=10
expectedPVCStatus="Bound"
until [ "$pvcstatus" == "$expectedPVCStatus=" ]
do
    if [ $maxRetry == 0 ];then
        break
    fi
    pvcstatus=$(kubectl get pvc $pvcName -n $pvcNamesapce -o=jsonpath='{@.status.phase}')
    maxRetry=`expr $maxRetry - 1`
    echo -n "->"
    sleep 5;
done

if [ "$pvcstatus" == "$expectedPVCStatus" ]; then
    echo "PVC successfully bound."
else
    echo "PVC bound failed."
    exit 1
fi

# Apply percona deployment
perconaTemp=$(kubectl apply -f $3)
echo $perconaTemp
JSONPATH='{range .items[0]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'; 
until kubectl get pods -n $pvcNamesapce -o jsonpath="$JSONPATH" 2>&1 | grep -q "Ready=True";
do
    echo -n ":("
  sleep 2; 
done
echo ""
echo "Hurray! Deployed Successfully"
echo ":)"
kubectl get pods -n $pvcNamesapce

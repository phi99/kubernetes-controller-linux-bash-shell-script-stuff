***In Progress**

	 	 	   ----------------------------------------------------------------
	     	    	     ** Simple Kubernetes (K8s) Controller using shell script **
	  	 	   ----------------------------------------------------------------


```text
Functionality/Mechanism
------------------------
The controller watches events from the api server targetting change in configmap. When the annotation in configmap is modified with words that match with the label of the pod, the controller would request the list of pods containing that label to the api server, and then delete those pods.
```

```text
Implementation
---------------
1) Create service account
kubectl create sa <sa name> -n test-namespace
2) Create role (what actions are allowed)
apiVersion: 
kind: Role
metadata:
        name: 
        namespace: 
rules:
        - apiGroups:                - 
          resources:               - 
          verbs:
3) Bind the role to the created service account using role binding (who can perform the actions allowed in role (2))
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
        name: 
        namespace: 
roleRef:
        kind: Role
        name: 
        apiGroup: 
subjects:
        - kind: ServiceAccount
          name: 
          namespace: 


4) Create pod to use the created and binded service account

apiVersion: v1
kind: Pod
metadata:
        name: 
        namespace: 
spec:
        serviceAccountName: 
        containers:
                - name: 
                  image: 
                  imagePullPolicy: 
                  command:
                          - 
                          - 

5) Define variables to enable Curl to automatically include the cert of the CA in the request to check if the server's cert is signed by the CA, and token used to authenticate to API server.
export CURL_CA_BUNDLE=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)

6) Controller - shell script
#!/bin/bash

watch_event() {
  # Listening for event changes in config maps
  echo "::: Starting to wait for events"
  curl -N -H "Authorization: Bearer $TOKEN" -s https://<API server ip address>/api/v1/namespaces/<target namespace>/configmaps?watch=true | while read -r event
  do
    event=$(echo "$event" | tr '\r\n' ' ')
    echo "event: $event"
    echo
    local type=$(echo "$event" | jq -r .type)
    local config_map=$(echo "$event" | jq -r .object.metadata.name)

    echo "type: $type"
    echo "config_map: $config_map"
    local check_annotations=$(echo "$event" | jq -r '.object.metadata.check_annotations')
    if [ "$check_annotations" != "null" ]; then
      local pod_selector=$(echo $annotations | jq -r 'to_entries | .[] | select(.key == "testdeleteselector") | .value | @uri')
    fi
    echo "check_annotations: $annotations"
    echo "-- $config_map -- $type -- testdeleteselector%3D$pod_selector"
    if [ $type = "MODIFIED" ] && [ -n "$pod_selector" ]; then
      local target=$(get_pods "$pod_selector")
      echo "target: $target"
      delete_pods $target
    fi
    echo
  done
}

get_pods() {
  local selector=${1}
  pods=$(curl -N -H "Authorization: Bearer $TOKEN" -s https://<API server ip address>/api/v1/namespaces/<target namespace>/pods?labelSelector=testdeleteselector=$selector | jq -r .items[].metadata.name)
  echo $pods
}

delete_pods() {
  local pods=$@
  echo "pods are: $pods"
  # Delete target pods and retrieve exit code
  for pod in $pods; do
    exit_code=$(curl -N -H "Authorization: Bearer $TOKEN" -X DELETE -o /dev/null -w "%{http_code}" -s  https://<API server ip address>/api/v1/namespaces/test-namespace/pods/$pod)
    echo
    if [ $exit_code -eq 200 ]; then
      echo "-- pod $pod is deleted ---"
    else
      echo "-- unable to delete pod $pod: $exit_code ---"
    fi
    echo "exit code: $exit_code"
    echo
  done
}

watch_event

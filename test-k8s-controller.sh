#!/bin/bash

watch_event() {
  # Listening to K8s API on events on configmap resource
  echo "- Listening to K8s events -"
  curl -N -H "Authorization: Bearer $TOKEN" -s https://<API server ip address>/api/v1/namespaces/<target namespace>/configmaps?watch=true | while read -r event
  do
    event=$(echo "$event" | tr '\r\n' ' ')
    echo "event: $event"
    echo
    # Checking event type & name
    local type=$(echo "$event" | jq -r .type)
    local config_map=$(echo "$event" | jq -r .object.metadata.name)

    echo "type: $type"
    echo "config_map: $config_map"
    local annotations=$(echo "$event" | jq -r '.object.metadata.annotations')
    if [ "$annotations" != "null" ]; then
      local pod_selector=$(echo $annotations | jq -r 'to_entries | .[] | select(.key == "testdeleteselector") | .value | @uri')
    fi
    echo "annotations: $annotations"
    echo "::: $type -- $config_map -- testdeleteselector%3D$pod_selector"
    # Act only when configmap is modified and an annotation has been given
    if [ $type = "MODIFIED" ] && [ -n "$pod_selector" ]; then
      get_pods "testdeleteselector%3D$pod_selector"
      #local target=$(get_pods "$pod_selector")
      echo "target: $target"
      delete_pods target
    fi
    echo
  done
}

get_pods() {
  # Retrieve pods with target label
  local selector=${1}
  echo "selector:$selector"
  pods=$(curl -N -H "Authorization: Bearer $TOKEN" -s https://10.96.0.1/api/v1/namespaces/test-namespace/pods?labelSelector=$selector | jq -r .items[].metadata.name)
  echo $pods
  echo in "get_pods"
}

delete_pods() {
  # Delete pods that matched
  for pod in $pods; do
    # Delete but also check exit code
    exit_code=$(curl -N -H "Authorization: Bearer $TOKEN" -X DELETE -o /dev/null -w "%{http_code}" -s  https://10.96.0.1/api/v1/namespaces/test-namespace/pods/$pod)
    echo "pod: $pod"
    echo "exit code: $exit_code"
    echo
   # #exit_code=$(curl -s -X DELETE -o /dev/null -w "%{http_code}" $base/api/v1/${ns}/pods/$pod)
    if [ $exit_code -eq 200 ]; then
      echo "::::: Deleted pod $pod"
    else
      echo "::::: Error deleting pod $pod: $exit_code"
    fi
  done
}

watch_event

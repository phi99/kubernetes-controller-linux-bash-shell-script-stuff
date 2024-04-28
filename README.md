.***In Progress**

	 	 	   ----------------------------------------------------------------
	     	    	      ** Simple Kubernetes (k8s) Controller using shell script**
	  	 	   ----------------------------------------------------------------


```text
Mechanism/Functionality
-------------------------------------------------
The controller watches events from the api server targetting change in configmap. When there's a annotation change it would detect it and based on the content of the change, it would make a decision to restart certain pods. When the annotation in configmap is modified with words that match with the label of the pod, the controller would request the list of pods containing that label to the api server, and then send a delete request to delete those pods.
```

```text
Implementation
---------------------------
1) Create service account
kubectl create sa <sa name> -n test-namespace
2) Create role (what action are allowed)
role-list-pods.yaml
3) Bind the role to the created service account using role binding (who can perform the actions allowed in role (2))
binding-list-pods-sa1.yaml
4) Create pod to use the created and binded service account
list-pods-sa1-binding-rust.yaml 
5) To enable client (curl for ex) to check if server cert is signed by the CA, specify the below environment variable so Curl can automatically include the cert of the CA in the request to check if the server's cert is signed by the CA.
export CURL_CA_BUNDLE=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
6) Specify the token (default token provided by Secret automatically) used to authenticate to the API server 
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
7) Run the script

Note: fill the values for parameter with <> 

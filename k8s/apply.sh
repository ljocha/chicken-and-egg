#!/bin/bash

set -- $(getopt xXn:l:s:t: "$@")

label=
size=20

token=$(LC_CTYPE=C tr -cd '[:alnum:]' </dev/urandom | head -c 30)

delete=0
delete_volume=0
while [ $1 != -- ]; do case $1 in
	-n) ns="-n $2"; shift ;;
	-l) label=-$2; shift ;;
	-s) size=$2; shift ;;
	-t) token=$2; shift ;;
	-X) delete=1; delete_volume=1 ;;
	-x) delete=1 ;;
	esac
	shift
done

if [ $delete = 1 ]; then
	kubectl delete deployment.apps/chicken-and-egg$label $ns
	kubectl delete service/chicken-and-egg-svc$label $ns
	kubectl delete ingress.networking.k8s.io/chicken-and-egg-ingress$label $ns
	if [ $delete_volume = 1 ]; then
		kubectl delete pvc/chicken-work$label $ns
	fi
	exit 0
fi


kubectl apply $ns -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:                                                                       
  name: chicken-work$label
spec:                                                                           
  accessModes:                                                                  
    - ReadWriteMany                                                             
  resources:                                                                    
    requests:                                                                   
      storage: ${size}Gi                                                              
#  storageClassName: csi-nfs
  storageClassName: nfs-client
EOF


#cat - <<EOF
kubectl apply $ns -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: chicken-and-egg$label
spec:
  replicas: 1
  selector:
    matchLabels:
      app: chicken-and-egg$label
  template:
    metadata:
      labels:
        app: chicken-and-egg$label
    spec:
      securityContext:
        runAsUser: 1001
        runAsGroup: 1002
        fsGroup: 1002
        fsGroupChangePolicy: "OnRootMismatch"
#      initContainers:
#        - name: volume-permissions
#          image: ljocha/chicken-and-egg:latest
#          command: [ '/bin/bash', '-c', 'chown -R 1001:1001 /work' ]
#          volumeMounts:
#          - mountPath: /work
#            name: chicken-work-volume
      containers:      
      - name: chicken-and-egg
        image: ljocha/chicken-and-egg:latest
        securityContext:
          allowPrivilegeEscalation: false
        ports:
          - containerPort: 9000
        resources:
          requests:
            cpu: .2
          limits:
            cpu: 6
        volumeMounts:
          - mountPath: /work
            name: chicken-work-volume
        command: ['/opt/chicken-and-egg/start-notebook.sh', 'jupyter', 'notebook', '--ip', '0.0.0.0', '--port', '9000', '--NotebookApp.token=$token' ]
        env:
        - name: WORK_VOLUME
          value: chicken-work$label
      volumes:
        - name: chicken-work-volume
          persistentVolumeClaim:
            claimName: chicken-work$label
EOF

kubectl apply $ns -f - <<EOF
apiVersion: networking.k8s.io/v1                                                
kind: Ingress                                                                   
metadata:                                                                       
  name: chicken-and-egg-ingress$label
  annotations:                                                                  
    kuberentes.io/ingress.class: "nginx"                                        
    kubernetes.io/tls-acme: "true"                                              
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    external-dns.alpha.kubernetes.io/target: k8s-public-u.cerit-sc.cz
    nginx.ingress.kubernetes.io/proxy-body-size: 300m 
spec:                                                                           
  tls:                                                                          
    - hosts:                                                                    
        - "chicken-and-egg$label.dyn.cerit-sc.cz"                                              
      secretName: chicken-and-egg$label-dyn-cerit-sc-cz-tls                                    
  rules:                                                                        
  - host: "chicken-and-egg$label.dyn.cerit-sc.cz"                                          
    http:                                                                       
      paths:                                                                    
      - backend:                                                                
          service:                                                              
            name: chicken-and-egg-svc$label
            port:                                                               
              number: 80                                                      
        pathType: ImplementationSpecific
EOF

kubectl apply $ns -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: chicken-and-egg-svc$label
spec:
  type: ClusterIP
  ports:
  - name: chicken-and-egg-port                                                 
    port: 80                                                                    
    targetPort: 9000    
  selector:
    app: chicken-and-egg$label
EOF

echo 
echo https://chicken-and-egg$label.dyn.cerit-sc.cz/?token=$token

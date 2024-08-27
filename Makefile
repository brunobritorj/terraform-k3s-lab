authenticate:
	az login

create:
	terraform -chdir=terraform init
	terraform -chdir=terraform apply --auto-approve

destroy:
	terraform -chdir=terraform destroy --auto-approve

helm_prepare:
	scp -r helm k3s0:/tmp/helm
	ssh k3s0 mkdir -p ~/.kube
	ssh k3s0 cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
	ssh k3s0 chmod 600 ~/.kube/config

helm_deploy_cert:
	ssh k3s0 helm repo add jetstack https://charts.jetstack.io --force-update
	ssh k3s0 helm upgrade --install --create-namespace --namespace cert-manager cert-manager --version v1.15.3 jetstack/cert-manager --set crds.enabled=true --file /tmp/helm/cert/values.yaml

helm_deploy_app:
	ssh k3s0 helm upgrade --install --create-namespace --namespace home home /tmp/helm/app --set ingress.hostname=your.app.local --set ingress.tls.enabled=true

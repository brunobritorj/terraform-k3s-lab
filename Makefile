authenticate:
	az login

create:
	terraform -chdir=terraform init
	terraform -chdir=terraform apply --auto-approve

destroy:
	terraform -chdir=terraform destroy --auto-approve

helm_prepare:
	scp -r helm k3s0:/tmp/helm
	ssh k3s0 cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
	ssh k3s0 chmod 600 ~/.kube/config

helm_install:
	ssh k3s0 helm upgrade --install --create-namespace --namespace home home /tmp/helm --set ingress.hostname bbrj-k3s-lab.eastus.cloudapp.azure.com
 
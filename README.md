Deploying a Kubernetes Cluster using KOPS and Terraform and also a sample application using nginx hosted on the K8's cluster.

Introduction:

This README document describes the steps I took while deploying the K8’s cluster and also the sample application.

Steps involved:

1)	Deploying the Infrastructure using Terraform and below are the components provisioned.
i) A VPC with three subnets(two private in different AZ’s for High Availability) and a single public subnet where the Stepping Stone/Jump server is deployed for deploying and interacting the cluster using kubectl.

ii) Internet Gateway which is only attached to the public subnet for installing KOPS,kubectl,aws cli.

iii) NACL & Security Groups which will be attached to the instance.

iv) EC2 instance(Stepping Stone for EKS) which will be provisioned in the public subnet.

v) ECR respository-ramiz-krypton where the application image will be stored.

2)	Deploying the Kubernetes cluster using KOPS.
i)	Before installing KOPS a S3 bucket is required to store the state of the cluster hence I have created-kops-statestore named bucket.

ii)	Login to the jump server and install  AWS CLI and then execute aws configure and store your AWS Access Key,Secret Access Key  which will be used for authentication.

iii)	Install kubectl--> https://kubernetes.io/docs/tasks/tools/install-kubectl/

iv)	Install KOPS using the below command:
kops create cluster --name=kops.ramiz.tr-talent.de --state=s3://kops-statestore --zones=eu-central-1a,eu-central-1b --node-count=2 --node-size=t3.large --master-size=t3.large --dns-zone=kops.ramiz.tr-talent.de --dns=private --topology=private --networking calico --master-zones=eu-central-1a 

v)	Then update the cluster using below,
kops update cluster --name kops.ramiz.tr-talent.de --yes --state=s3://kops-statestore

vi)	Validate the cluster using kops validate cluster kops.ramiz.tr-talent.de --state=s3://kops-statestore which tells you that your cluster is ready.

vii)	Now it’s time to verify that all the nodes are in running state and yay it’s ruuning.

![](images/kubectl.png)

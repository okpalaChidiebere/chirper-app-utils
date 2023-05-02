## Environment Requirements

Before this point I will assume that you already set up your CI pipeline and have your app private images in your Container Registry like DockerHub. We can now go ahead and use Kubernetes for the CD of our app

- [Set up](https://docs.aws.amazon.com/cli/v1/userguide/install-macos.html) `awscli`. I think it easy to install using `pip3 install awscli --upgrade --user`, but you need to have Python3 installed in your system which i think is already installed by default for Mac users. To confirm you have aws cli install run `aws`
- Install `kubectl`. The overview is:
  - you download the kubectl binary `curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.6/bin/darwin/amd64/kubectl`
  - make the binary executable `chmod +x ./kubectl`
  - move it to ur machine bin folder to be able to globally move it `sudo mv ./kubectl /usr/local/bin/kubectl`.
  - [See](https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/) for more. To confirm you have it install run `kubectl`
- [Set up](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html) `aws-iam-authenticator`. I used homebrew. To login a user run `aws configure` and enter user credentials. To confirm the user that you have locally login into your awscli run `aws sts get-caller-identity` in terminal. Also commands like `aws s3 ls` and `aws ec2 describe-vpcs` should work as well. This step is important because the user credentials will be used by `eksctl` to create the cluster and nodes. This [article](https://repost.aws/en/knowledge-center/eks-cluster-connection) is a good read. **Required IAM permissions:** The IAM security principal that you're using must have permissions to work with Amazon EKS IAM roles, service linked roles, AWS CloudFormation, a VPC, and related resources
- [Set up](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html) `eksctl`. I used homebrew to install this from the doc. The makes it easy for us to create Clusters and Node to run our pods in AWS using Elastic Kubernetes Service

## User IAM Profiles on AWS

It’s beneficial to add your policies to a group (a set of permissions) so that multiple developers or services with similar needs can be assigned to that group, rather than to assign individual permissions to a specific user. Imagine if a user leaves the company and a new hire takes their place. Instead of re-assigning all the permissions needed for their job, we can assign the existing IAM role to that new employee.

- We will create a user profile. See this [article](https://www.techtarget.com/searchcloudcomputing/tutorial/Step-by-step-guide-on-how-to-create-an-IAM-user-in-AWS)
- Add the **user** to **user group** we created. With user group, you will can add default **amazon default policies** or your **own custom policies** and assign it to that group
- Article on how to [create a user group](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_groups_create.html) and [add or remove user from a group](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_groups_manage_add-remove-users.html)
- Article on [creating a policy](http://beta.awsdocs.com/services/iam/creating_policies/)

## Create an EKS Cluster and Node Group from eksctl

I personally prefer to use `eksctl` for this. This is because it uses Cloudformation under the hood that makes it easy to spin up and clean up resources and i can create EKS from the CLI. To use eksctl, make sure you have the [prerequisites](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html) set up on your computer

- `eksctl create cluster -f cluster.yaml` to create cluster, node groups and all other resources created by eksctl from config file
- `eksctl delete cluster -f cluster.yaml` to delete cluster, node groups and all other resources created by eksctl from config file
- Looking into enabling [**CloudWatch logs**](https://eksctl.io/usage/cloudwatch-cluster-logging/) for your cluster
- Another example of a cluster yaml file is [here](https://github.com/weaveworks/eksctl/issues/4009)

## Create an EKS Cluster and Node Group from AWS console

- Create **SSH Key for Node Groups** . Navigate to the **Key pairs** tab in the **EC2** Dashboard, Click **Create key pair**, Give the key pair a name, e.g. mykeypair, Select **RSA** and **.pem**, Click **Create key pair**
- Create an **AWS role for EKS Node Groups**. Make sure you attach the **policies** for `AmazonEKSWorkerNodePolicy`, `AmazonEC2ContainerRegistryReadOnly`, and `AmazonEKS_CNI_Policy`. This [link](https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html#create-worker-node-role) has detailed explanation of how to create an IAM role.
- Create an **AWS role for EKS Cluster**. Make sure you attach the policies for `AmazonEKSClusterPolicy`, `AmazonECS_FullAccess`, and `AmazonEKSServicePolicy`
- If you don't have a [VPC](https://docs.aws.amazon.com/vpc/latest/userguide/how-it-works.html), create one with the `IPv4 CIDR block` value `10.0.0.0/16`. Make sure you select` No IPv6 CIDR block`.
- Your Cluster endpoint access should be set to Public
- [Set up](https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html) `kubeconfig`. Basically these two commands are useful. `aws sts get-caller-identity` to confirm the aws user currently used and `aws eks --region <region-code> update-kubeconfig --name <cluster_Name>` to to the connection between kubectl and eks. This will make it such that your kubectl will be running against your newly-created EKS cluster.

## Creating IAM role in aws console

- Navigate to the **Roles** tab in the **Identity and Access Management (IAM)** dashboard in the AWS Console
- Click **Create role**
- Select type of trusted entity:

  - Choose (whatever: eg EKS, EC2, etc) as the use case
  - Select (whatever based on the use case. Eg EKS-Cluster, EC2)
  - Click **Next: Permissions**

- In Attach permissions policies, search for whatever policy(eg `AmazonEC2ContainerRegistryReadOnly`) and check the box to the left of the policy to attach it to the role
- Click **Next: Tags**
- Click **Next: Review**
  - Give the role a name, e.g. EKSClusterRole, node-role
- Click **Create role**
- [AWS Role](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html)

## Deployment

If you have kubectl correctly configured and clusters created this command should work `kubectl get nodes`

## Useful links on eksclt config file

- [https://eksctl.io/usage/creating-and-managing-clusters/](https://eksctl.io/usage/creating-and-managing-clusters/)
- [https://eksctl.io/usage/managing-nodegroups/](https://eksctl.io/usage/managing-nodegroups/)
- [https://eksctl.io/usage/iam-policies/](https://eksctl.io/usage/iam-policies/)
- [https://eksctl.io/usage/eks-managed-nodes/](https://eksctl.io/usage/eks-managed-nodes/)
- [https://eksctl.io/usage/schema](https://eksctl.io/usage/schema)

## eksctl CLI youtube video

- [https://www.youtube.com/watch?v=aGTOVaVXz7k&t=474s](https://www.youtube.com/watch?v=aGTOVaVXz7k&t=474s)

## Interacting with K8s Secretes

- `kubectl get secret` to get all secrets registered in cluster
- `kubectl get secret <secret-metadata-name>` confirm you have the secret created
- `kubectl get secret reg-docker-cred --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode` to see the content of the secret config file you deployed

## Apply docker config secrets to k8s

- We run this command `kubectl apply -f docker-config.yaml`
- When you look at the `docker-config.yaml` file. Pay attentio how we specify the [`type`](https://kubernetes.io/docs/concepts/configuration/secret/#secret-types) what allows K8s to understand the type of secret we are creating and `data`
- Also for the `data` we converted our config file to base64 with this command `cat config.json | base64` and insert that value to the `.dockerconfigjson`

```json
//config.json
{
  "auths": {
    "https://index.docker.io/v1/": {
      "username": "xxx",
      "password": "xxx",
      "email": "xxx",
      "auth": "base64(username:password)" //output of `echo -n 'username:password' | base64`
    }
  }
}
```

You can run this script below in terminal to get the base64 value of **auth** for docker config file. It doesn't display the password input, so you can't find the clear password in the bash history. It also prints clear instructions to the user

```bash
echo -en "------\nPlease enter Docker registry login:\nUsername: "; \
    read regusername; \
    echo -n "Password: "; \
    read -s regpassword; \
    echo""; \
    echo -n "Auth Token: "; \
    echo -n "$regusername:$regpassword" | base64; \
    unset regpassword; \
    unset regusername;
```

This secret will be provided during our pod deployment. See this [doc](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/)

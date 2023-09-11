# Canary Deployment Demo with k8s and Terraform

I'm deploying a demo of blue green demo in section 1, and an extension of that
in section 2 where i read input from `application.json`

## Pre-requisites

- Software:

  - Minikube (either via Docker or via KVM2 driver)
  - kubectl
  - terraform

- Minikube setup

  ```
  $ minikube start
  ```

- ingress-nginx addon enabled

  ```
  $ minikube addons enable ingress
  ```

## Using k8s

The files are pretty small and here's an overview of them: -

- `blue.yaml`: defines blue's deployment and service
- `green.yaml`: defines green's deployment and service
- `ingress.yaml`: defines ingress for blue and green (marked as canary)

### How to run

1. create deployment and wait for it to complete

   ```
   $ kubectl apply -f kube && kubectl rollout status deployment blue-app green-app
   ```

2. get minikube's ip where ingress is exposed

   ```
   $ minikube service ingress-nginx-controller --url -n ingress-nginx
   ```

3. If you're on linux (**NOT ON WSL**) you can run the `test.sh` script
   directly.

   (It's a simple for loop curling the url 10 times)

## Using Terraform

> **Note**
>
> ❗\*\*\*\* While reading part is successfully implemented, there is an issue
> with multiple canary deployments as I have highlighted after this section

Here, to read the input data from the json file, in `terraform/main.tf` I am
reading the file and storing it into locals

creating of deployment, service and ingress is abstracted in a module
`terraform/modules/app-deployment`, matching the same variables input as the
format in `applications.json`

in `terraform/main.tf` I am running a for loop to dynamically create the
resources as specified in application.json

### How to run

1. First delete the resources created in the previous section (if you were
   running the k8s file first)

   ```
   $ kubectl delete -f kube
   ```

2. cd into terraform directory
   ```
   cd terraform/
   ```
3. Install the providers
   ```
   terraform init
   ```
4. Then plan and apply!
   ```
   terraform plan
   terraform apply
   ```

### Note

- Although Terraform is creating the infrastructure as desired, however to
  distribute traffic between 3 deployments based on their weight, I have been
  using adding the ingresses with the annotation to mark them as canary and
  specifying the weight as based on the input

- So after terraform has created all the resources, we have 3 ingress resources
  all marked as canary with their respective weight.

- When you try to visit the ingress' ip, nginx will show a 404 error.

- In an attempt to debug, I manually edited an ingress and removed all the
  (canary) annotations

- Now when visiting the url the backend is now sending data [`"I am boom"` (not
  specifically `boom`, but depending on what you edit `foo` or `bar` can be
  shown as well)] \
  This results in a new issue.

- We now have 1 ingress for `/` path, and 2 canary ingresses.

- If you'll run the `test.sh` script or manually refresh the page in browser,
  you will see that traffic is only being routed for 2 ingresses only. The one
  you edited to remove canary annotaion, and one other (possibly random?)
  ingress.

- No traffic is sent from the 3rd ingress

- The only difference between this setup in Terraform and when implementing with
  k8s was the number of containers marked as canary.
  - In k8s:
    - 2 containers, 1 canary
  - In Terraform:
    - 3 containers, 3 canary, (after edit: 2 canary)

Researching this further led me to this github issues and a quote from their
documentation:

- issue: https://github.com/kubernetes/ingress-nginx/issues/5848 \
  comment: https://github.com/kubernetes/ingress-nginx/issues/5848#issuecomment-714274370
- > Known Limitations
  >
  > Currently a maximum of one canary ingress can be applied per Ingress rule

  source:
  https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/#canary

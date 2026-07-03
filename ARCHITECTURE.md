# FifaApp Architecture & GitOps Workflow Guide

Welcome to the comprehensive architecture guide for FifaApp. This document explains how the entire enterprise-grade infrastructure operates, from the moment you write a line of code to the moment it serves traffic to your users on the internet.

---

## 1. The Core Components

### 🏗️ Infrastructure as Code (Terraform)
We use **Terraform** to declare our physical cloud infrastructure. When you trigger a run in Terraform Cloud, it reaches into AWS and builds the foundational hardware:
*   **VPC & Networking**: Creates a private, isolated network with public and private subnets.
*   **EKS (Elastic Kubernetes Service)**: Deploys the Kubernetes control plane.
*   **Node Groups**: Boots up AWS EC2 `t3.micro` servers (running Amazon Linux 2023) to act as the worker nodes where your application pods will physically live.
*   **AWS Load Balancer Controller**: Installs a Kubernetes add-on that allows EKS to talk to AWS and automatically create physical Application Load Balancers (ALBs).

### 🤖 CI/CD Pipeline (GitHub Actions & AWS ECR)
When you push code to your `FifaApp-frontend` or `FifaApp-backend` repositories, GitHub Actions automatically wakes up.
*   It builds a fresh Docker Image containing your updated code.
*   It securely logs into AWS and pushes that Docker Image into **AWS ECR** (Elastic Container Registry), which acts as a private warehouse for your docker containers.

### 🐙 GitOps Deployment (ArgoCD)
Instead of manually pushing code to the servers, we use a "Pull" methodology called GitOps.
*   **ArgoCD** lives permanently inside your EKS cluster.
*   It constantly watches the `FifaApp-infrastructure/k8s` folder on GitHub.
*   When it sees a change (like a new image tag or a modified deployment), it automatically pulls those changes and applies them to the Kubernetes cluster to ensure the live environment perfectly matches the code in GitHub.

### 🌐 Traffic Routing (AWS ALB & Ingress)
When a user visits your website:
1.  They hit the **AWS Application Load Balancer (ALB)** sitting on the edge of your public subnets.
2.  The ALB uses Kubernetes **Ingress** rules to determine where to send the traffic.
3.  The traffic is routed to the **Frontend Service** (for the React UI) or the **Backend Service** (for the FastAPI backend).
4.  The Backend Service communicates with your external **MongoDB Atlas** database to fetch data.

---

## 2. Draw.io Architecture Diagram

You can easily visualize this entire flow in Draw.io using the code block below.

### How to import this into Draw.io:
1. Go to [Draw.io](https://app.diagrams.net/) and create a Blank Diagram.
2. In the top menu, click **Arrange** -> **Insert** -> **Advanced** -> **Mermaid...**
3. Copy the entire code block below, paste it into the text box, and click **Insert**.
4. Draw.io will instantly generate a beautiful, fully editable architecture diagram for you!

```mermaid
architecture-beta
    group github(logos:github)[GitHub Ecosystem]
    group aws(logos:aws)[AWS Cloud]
    group eks(logos:kubernetes)[EKS Cluster] in aws
    group mongo(logos:mongodb-icon)[External Database]

    service frontendRepo(logos:git)[Frontend Code] in github
    service backendRepo(logos:git)[Backend Code] in github
    service infraRepo(logos:git)[Infra & k8s Code] in github
    
    service actions(logos:github-actions)[GitHub Actions CI/CD] in github
    
    service ecr(logos:aws-ecr)[AWS ECR Registry] in aws
    service alb(logos:aws-elb)[Application Load Balancer] in aws

    service argocd(logos:argo)[ArgoCD GitOps] in eks
    service ingress(logos:kubernetes)[K8s Ingress] in eks
    
    service frontendPod(logos:react)[Frontend Pods] in eks
    service backendPod(logos:python)[Backend Pods] in eks
    
    service database(logos:mongodb-icon)[MongoDB Atlas] in mongo

    frontendRepo:R --> L:actions
    backendRepo:R --> L:actions
    
    actions:R --> L:ecr
    
    infraRepo:B --> T:argocd
    
    argocd:T --> B:frontendPod
    argocd:T --> B:backendPod
    
    alb:B --> T:ingress
    ingress:B --> T:frontendPod
    ingress:B --> T:backendPod
    
    backendPod:R --> L:database
    
    ecr:B --> T:frontendPod
    ecr:B --> T:backendPod
```


# Dream Vacation App – Dockerized 🌍🐳

This project focuses on the **containerization of a full-stack application** using Docker and Docker Compose. The app is made up of:

- A React frontend  
- A Node.js backend  
- A PostgreSQL database

---

## 🛠️ What Was Done

- The **frontend and backend code** was already provided. here [code](https://github.com/obusorezekiel/Dream-Vacation-App)
- I wrote the `Dockerfile` for both the **frontend** and **backend**.
- I created the `docker-compose.yml` file to orchestrate all services.
- I created a `.env` file for managing environment variables.
- A `.gitignore` file was added to prevent the `.env` file from being pushed, as it contains sensitive data like database credentials.
- Create a repository for each service:
    *dream-vacation-frontend*
    *dream-vacation-backend*
![text](Assets/image1.png) 

![text](Assets/image2.png)

- I built and pushed the **Docker images** to **Docker Hub**.

```bash
docker build -t aiyus/dream-vacation-frontend ./frontend
docker build -t aiyus/dream-vacation-backend ./backend
docker push aiyus/dream-vacation-frontend
docker push aiyus/dream-vacation-backend

```
- I started the containers using:

```bash
docker-compose up  -d
```
![alt text](Assets/image3.png)

- Assessed/viewed the frontend 

![alt text](Assets/image4.png)

---
## Terimal Screen Shots
 ![text](Assets/image5.png) 
 ![text](Assets/image6.png) 
 ![text](Assets/image7.png) 
 ![text](Assets/image8.png) 
 ![text](Assets/image9.png)


## 📦 Project Structure

```
Dream-Vacation-App/
│
├── frontend/           # React app
│   └── Dockerfile      # Multi-stage build with Nginx
│
├── backend/            # Node.js + Express API
│   └── Dockerfile      # Runs on Node 16/18
│
├── .env                # Environment variables (NOT pushed to GitHub)
├── .gitignore          # Ignores .env and node_modules
├── docker-compose.yml  # Orchestrates services
└── README.md
```



## 🚀 Usage

### 1. Clone the repo

```bash
git clone https://github.com/your-username/Dream-Vacation-App.git
cd Dream-Vacation-App
```

### 2. Create a `.env` file at the root:

```env
POSTGRES_DB
POSTGRES_USER
POSTGRES_PASSWORD
DB_HOST
DB_PORT
PORT
```

### 3. Start the application

```bash
docker-compose up --build
```

* Frontend: [http://localhost:3000](http://localhost:3000)
* Backend: [http://localhost:5000](http://localhost:5000)
* PostgreSQL: localhost:5432

---

## 📤 Pushed Docker Images

* **Frontend**: `docker.io/your-username/dream-vacation-frontend`
* **Backend**: `docker.io/your-username/dream-vacation-backend`

---

## ✅ Features

* Multi-stage builds for frontend optimization
* Separate services for clean separation of concerns
* Environment configuration via `.env`
* PostgreSQL data persistence using Docker volumes
* Ready for local or production Docker deployment

---




## 🛠️🌀 **CI/CD Update**

### ✨ New CI/CD Workflow Configuration

* Implemented **GitHub Actions** to automate Docker image builds and push to Docker Hub.
* Created 
`.github/workflows/frontend.yml`
`.github/workflows/backend.yml`
 which does the following on push to dev:

  * Checks out the code
  * Logs in to DockerHub using GitHub secrets
  * lint the code
  * Builds frontend and backend Docker images using `docker buildx`
  * Pushes images to Docker Hub

### 🗃️ GitHub Secrets and env Used:

* `DOCKERHUB_USERNAME` (env)
* `DOCKERHUB_TOKEN`(secret)


### 📸 Screenshot – Successful CI/CD Deployment

![text](Assets/hub1.png) 
![text](Assets/hub2.png) 
![text](Assets/hub3.png) 
![text](Assets/hub4.png) 
![text](Assets/hub5.png) 
![text](Assets/hub6.png) 
![text](Assets/hub7.png) 
![text](Assets/hub8.png) 
![text](Assets/hub9.png) 
![text](Assets/hub10.png) 
![text](Assets/hub11.png) 
![text](Assets/hub12.png)

---

## 🧾 Summary

This project demonstrates how to:

* Dockerize a full-stack application
* Use Docker Compose for service orchestration
* Push images to Docker Hub
* Automate the image build-and-push process using **CI/CD with GitHub Actions**

> 🔐 Sensitive variables like Docker credentials and `.env` contents are managed securely through `.gitignore` and GitHub secrets.

Here’s a clean and professional README-style write-up based on what you just described:

---

# updated 
# 🚀 Project Deployment Documentation

## 📌 Overview

This document outlines the steps I took to deploy the **Dream Vacation App** to AWS, including infrastructure setup, CI/CD configuration, and handling challenges with pulling the latest image.

---

## 🛠 Step 1 — Create Production Branch

I started by creating a new branch for production deployment:

```bash
git checkout -b production
```

---

## ☁️ Step 2 — AWS Infrastructure Setup

I logged into my AWS account and created the required networking and compute resources:

* **VPC** — `dream-vpc` with CIDR `10.0.0.0/16`
* **Subnet** — `dream-subnet` with CIDR `10.0.1.0/24`
* **Internet Gateway** — `dream-igw`
* **Route Table** — `dream-rt` (associated with VPC and subnet)
* **EC2 Instance** — Ubuntu-based, `t2.micro` type
  Configured security groups to allow HTTP (80), HTTPS (443), and SSH (22) access.
* **User data** - provisioned my server by installing docker and docker compose

---

## ⚙️ Step 3 — Deploy Workflow Creation

I created a **deployment workflow file** in the `.github/workflows/` directory.
This workflow:

1. SSHs into the EC2 instance
2. Fetches the latest Docker image tag
3. Updates environment variables for Docker Compose
4. Pulls the latest images
5. Restarts containers

---

## 🔄 Step 4 — CI/CD Pipeline

I wrote the GitHub Actions pipeline and pushed it to the `production` branch:

```bash
git add .
git commit -m "Add deploy workflow"
git push origin production
```

Once pushed, the workflow automatically deployed the latest application version to AWS.

---

## 🚧 Challenges & Solutions

**Challenge:**
Retrieving the latest GitHub commit SHA from Docker Hub so the deployment always runs with the newest image.

**Solution:**
I installed `jq` on the EC2 instance and used it to query the Docker Hub API:

```bash
FRONTEND_SHA=$(curl -s "https://hub.docker.com/v2/repositories/<username>/dream-frontend/tags?page_size=1&ordering=last_updated" | jq -r '.results[0].name')
```

This allowed the workflow to dynamically fetch and deploy the most up-to-date image.

---

## ✅ Deployment Summary

* Created production branch
* Built AWS networking and compute infrastructure
* Wrote and committed a deployment workflow
* Used GitHub Actions to automate pulling the latest image and running containers
* Solved image tag automation using `jq` + Docker Hub API

---

## Screen Shots
 ![text](Assets/dep1.png) 
 ![text](Assets/dep2.png) 
 ![text](Assets/dep3.png) 
 ![text](Assets/dep4.png) 
 
 ![text](Assets/dep5.png) 
 ![text](Assets/dep6.png) 
 ![text](Assets/dep7.png) 
 ![text](Assets/dep8.png) 
 ![text](Assets/dep9.png) 
 ![text](Assets/dep10.png) 
 ![text](Assets/dep11.png) 
 ![text](Assets/dep12.png) 
 ![text](Assets/dep13.png) 
 ![text](Assets/dep14.png) 
 ![text](Assets/dep15.png)
  ![text](Assets/dep16.png) 
  ![text](Assets/dep17.png) 
  ![text](Assets/dep18.png) 
  ![text](Assets/dep19.png) 
  ![text](Assets/dep20.png)

Here’s a polished **README.md** version based on your description, written in a professional, structured way with first-person pronouns and clear sections:

````markdown
# 🧭 Dream Vacation App – Terraform + GitHub Actions Deployment

I have extended the deployment of the **Dream Vacation App** to include **infrastructure provisioning with Terraform** and an accompanying **GitHub Actions workflow** to deploy the Dockerized app to AWS.

---

## 🌿 Branch Setup

I created a new branch for this workflow:  

```bash
git checkout -b terra-deploy
````

---

## 🛠 Terraform Configuration

I wrote Terraform configurations to provision all required AWS infrastructure, including:

* **VPC, Subnets, Internet Gateway, and Route Tables**
* **EC2 Instances** (Ubuntu-based, e.g., t2.micro or suitable size)
* **Security Groups** allowing HTTP, HTTPS, and SSH access
* **Credentials and environment management**
* **User data** to install Docker and Docker Compose automatically

This setup ensures a **repeatable and fully managed infrastructure** for running my Dockerized application.

---

## ⚡ GitHub Actions Workflow

I created a workflow at `.github/workflows/terraform-deploy.yml` which automates both infrastructure provisioning and application deployment.

The workflow performs:

1. **Checkout and authenticate** to AWS using GitHub Secrets.
2. **Terraform init, plan, and apply** to create or update the infrastructure.
3. **SSH into the EC2 instance** to:

   * Pull the latest Docker images (from Docker Hub or a registry)
   * Update environment variables for Docker Compose
   * Pull and restart containers to apply the newest version

---

## 🧩 How Terraform + GitHub Actions Deployment Works

### Terraform

* Creates all AWS networking and compute resources
* Installs Docker and Docker Compose on the EC2 instance via user data
* Ensures security and connectivity for the app

### GitHub Actions

* Automates provisioning and deployment steps
* Fetches the latest Docker image tags programmatically
* Passes image tags to Docker Compose to ensure the EC2 instance always runs the latest app version
* Restarts containers to deploy updates seamlessly

---

## ✅ Outcome

By combining **Terraform** for infrastructure and **GitHub Actions** for deployment, I can now:

* Provision a complete AWS environment for my app
* Automatically deploy the latest Dockerized frontend and backend
* Ensure a fully automated, reproducible, and production-ready setup

---

This setup demonstrates **modern DevOps practices**: Infrastructure as Code (Terraform), CI/CD (GitHub Actions), and containerized application deployment (Docker + Docker Compose).

```



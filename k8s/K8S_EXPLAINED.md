# Kubernetes Files Explained in Simple Terms 🎓

Think of Kubernetes (K8s) like a smart manager for your applications. Each file tells K8s what to do. Let me explain each file like you're 5 years old! 😊

---

## 📁 File 1: `namespace.yaml` - The Room Organizer

**What it does:** Creates a separate "room" (namespace) for your app.

**Simple explanation:**
- Imagine your house has different rooms (kitchen, bedroom, etc.)
- A namespace is like a room in Kubernetes
- It keeps your app separate from other apps
- Name: `sample-app` (like labeling the room "My App's Room")

**Why you need it:**
- Keeps things organized
- Prevents conflicts with other apps
- Easy to delete everything at once

---

## 📁 File 2: `mysql-configmap.yaml` - The Recipe Book

**What it does:** Stores your database setup script (SQL commands).

**Simple explanation:**
- A ConfigMap is like a recipe book that K8s can read
- It contains the SQL script that creates your database and tables
- MySQL will read this when it starts for the first time
- It's like giving MySQL instructions: "Create a table called 'users' with these columns..."

**What's inside:**
- SQL commands to create the database
- SQL to create the `users` table
- SQL to insert sample data (John Doe, Jane Smith)

**Why you need it:**
- Automatically sets up your database
- No need to manually run SQL commands
- Database is ready when MySQL starts

---

## 📁 File 3: `mysql-deployment.yaml` - The Database Manager

**This file has 3 parts:**

### Part 1: PersistentVolumeClaim (PVC) - The Storage Box
**What it does:** Asks K8s for storage space (like a USB drive).

**Simple explanation:**
- Like asking for a 1GB storage box
- Database data is stored here
- Even if MySQL restarts, data stays safe
- `ReadWriteOnce` = only one pod can use it at a time






### Part 2: Service - The Phone Number
**What it does:** Gives MySQL a name that other apps can call.

**Simple explanation:**
- Like giving MySQL a phone number: `mysql`
- Other apps call `mysql:3306` to talk to the database
- `clusterIP: None` = headless service (direct connection)
- Port 3306 = MySQL's standard port

### Part 3: Deployment - The Worker Manager
**What it does:** Tells K8s to run MySQL and keep it running.

**Simple explanation:**
- `replicas: 1` = run 1 copy of MySQL (databases usually need only 1)
- `image: mysql:8.0` = use MySQL version 8.0
- Environment variables = passwords and settings
- Volume mounts = where to store data and read the init script

**Key parts:**
- `MYSQL_ROOT_PASSWORD` = the admin password
- `MYSQL_DATABASE` = creates database called `sample_db`
- `MYSQL_USER` = creates user `appuser`
- `MYSQL_PASSWORD` = password for `appuser`
- `volumeMounts` = connects the storage box and recipe book

---

## 📁 File 4: `backend-deployment.yaml` - The API Server Manager

**This file has 2 parts:**

### Part 1: Service - The Backend Phone Number
**What it does:** Gives your backend API a name.

**Simple explanation:**
- Other apps can call `backend:3001` to reach your API
- `type: ClusterIP` = only accessible inside the cluster
- Port 3001 = where your Node.js app runs

### Part 2: Deployment - The Backend Worker Manager
**What it does:** Runs your Node.js backend app.

**Simple explanation:**
- `replicas: 2` = run 2 copies (for reliability - if one dies, the other works)
- `image: node-backend:latest` = your Docker image
- Environment variables = database connection info
  - `DB_HOST: mysql` = connect to the MySQL service
  - `DB_USER`, `DB_PASSWORD`, etc. = login credentials

**Health Checks:**
- `livenessProbe` = "Is the app alive?" (checks every 10 seconds)
- `readinessProbe` = "Is the app ready to work?" (checks every 5 seconds)
- If health check fails, K8s restarts the pod

---

## 📁 File 5: `frontend-deployment.yaml` - The Website Manager

**This file has 2 parts:**

### Part 1: Service - The Frontend Phone Number
**What it does:** Exposes your React app to the internet.

**Simple explanation:**
- `type: LoadBalancer` = makes it accessible from outside
- Port 80 = standard web port (like http://website.com)
- Other apps inside can call `frontend:80`

### Part 2: Deployment - The Frontend Worker Manager
**What it does:** Runs your React app.

**Simple explanation:**
- `replicas: 2` = run 2 copies (load balancing)
- `image: react-frontend:latest` = your Docker image
- Port 80 = nginx serves the React app on port 80
- Health checks ensure the website is working

**Note:** The frontend uses nginx to proxy `/api` requests to the backend automatically!

---

## 🔄 How They Work Together

```
User → Frontend (port 80) → Backend (port 3001) → MySQL (port 3306)
```

1. **User visits website** → Frontend service receives request
2. **Frontend needs data** → Calls Backend service at `backend:3001`
3. **Backend needs data** → Calls MySQL service at `mysql:3306`
4. **MySQL returns data** → Backend → Frontend → User sees it!

---

## 📊 Key Concepts Explained

### **Service**
- Like a phone book entry
- Gives apps a stable name to call each other
- Routes traffic to the right pods

### **Deployment**
- Like a manager that keeps workers (pods) running
- If a pod dies, it creates a new one
- Can scale up/down (change number of copies)

### **ConfigMap**
- Like a shared notebook
- Stores configuration data
- Apps can read from it

### **PersistentVolumeClaim (PVC)**
- Like renting storage space
- Data persists even if pods restart
- Perfect for databases

### **Labels & Selectors**
- Like name tags
- Services use selectors to find the right pods
- `app: backend` = "find all pods labeled 'backend'"

### **Replicas**
- Number of copies to run
- More replicas = more reliability and capacity
- K8s distributes them across nodes

### **Health Probes**
- Like a doctor checking if you're healthy
- `livenessProbe` = "Are you alive?" (restart if not)
- `readinessProbe` = "Can you work?" (don't send traffic if not ready)

---

## 🎯 Quick Summary

| File | What It Does | Simple Analogy |
|------|-------------|----------------|
| `namespace.yaml` | Creates a room | "Create a room called 'sample-app'" |
| `mysql-configmap.yaml` | Stores SQL script | "Here's the recipe for the database" |
| `mysql-deployment.yaml` | Runs MySQL | "Run MySQL, store data safely, use the recipe" |
| `backend-deployment.yaml` | Runs Node.js API | "Run 2 copies of the backend, connect to MySQL" |
| `frontend-deployment.yaml` | Runs React app | "Run 2 copies of the frontend, make it accessible" |

---

## 🚀 Deployment Order

1. **Namespace** - Create the room first
2. **MySQL ConfigMap** - Prepare the recipe
3. **MySQL Deployment** - Start the database
4. **Backend Deployment** - Start the API (waits for MySQL)
5. **Frontend Deployment** - Start the website (waits for backend)

---

## 💡 Pro Tips

- **Ports in K8s:** Container ports stay the same (3001, 80, 3306). Only docker-compose host ports changed (4000, 4001).
- **Service names:** Apps use service names to talk to each other (`mysql`, `backend`, `frontend`)
- **Scaling:** Change `replicas` number to scale up/down
- **Debugging:** Use `kubectl logs` and `kubectl describe` to see what's happening

---

Hope this helps! 🎉 Kubernetes is like having a smart assistant that manages everything for you!


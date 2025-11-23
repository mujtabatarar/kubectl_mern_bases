# Simple React + Node.js + MySQL Application

This is a simple full-stack application consisting of:
- **React Frontend**: Single-page application to display and manage users
- **Node.js Backend**: REST API with Express and MySQL
- **MySQL Database**: Stores user information

This setup is designed to be deployed on Kubernetes with Tyk API Gateway, Chaos Mesh, and Service Mesh.

## Project Structure

```
.
├── frontend/          # React application
├── backend/           # Node.js Express API
├── database/          # MySQL initialization scripts
├── k8s/              # Kubernetes manifests
└── docker-compose.yml # Local development setup
```

## Prerequisites

- Node.js 18+ and npm
- Docker and Docker Compose (for local development)
- Kubernetes cluster (for deployment)
- kubectl configured

## Local Development

### Option 1: Using Docker Compose (Recommended)

1. Clone the repository and navigate to the project directory

2. Start all services:
```bash
docker-compose up -d
```

3. Access the applications:
   - Frontend: http://localhost:4000
   - Backend API: http://localhost:4001
   - MySQL: localhost:3306

4. Stop all services:
```bash
docker-compose down
```

### Option 2: Manual Setup

#### Backend Setup

1. Navigate to backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Create `.env` file:
```bash
cp .env.example .env
```

4. Update `.env` with your MySQL credentials

5. Start the backend:
```bash
npm start
```

#### Frontend Setup

1. Navigate to frontend directory:
```bash
cd frontend
```

2. Install dependencies:
```bash
npm install
```

3. Create `.env` file:
```bash
echo "REACT_APP_API_URL=http://localhost:4001" > .env
```

4. Start the frontend:
```bash
npm start
```

#### MySQL Setup

1. Start MySQL (using Docker or local installation)

2. Create database and run initialization script:
```bash
mysql -u root -p < database/init.sql
```

## Kubernetes Deployment

### Build Docker Images

1. Build backend image:
```bash
cd backend
docker build -t node-backend:latest .
```

2. Build frontend image:
```bash
cd frontend
docker build -t react-frontend:latest .
```

3. Load images into your Kubernetes cluster (for local clusters like minikube):
```bash
minikube image load node-backend:latest
minikube image load react-frontend:latest
```

Or push to a container registry:
```bash
docker tag node-backend:latest your-registry/node-backend:latest
docker tag react-frontend:latest your-registry/react-frontend:latest
docker push your-registry/node-backend:latest
docker push your-registry/react-frontend:latest
```

### Deploy to Kubernetes

1. Create namespace:
```bash
kubectl apply -f k8s/namespace.yaml
```

2. Deploy MySQL:
```bash
kubectl apply -f k8s/mysql-configmap.yaml
kubectl apply -f k8s/mysql-deployment.yaml
```

3. Wait for MySQL to be ready:
```bash
kubectl wait --for=condition=ready pod -l app=mysql -n sample-app --timeout=120s
```

4. Deploy backend:
```bash
kubectl apply -f k8s/backend-deployment.yaml
```

5. Deploy frontend:
```bash
kubectl apply -f k8s/frontend-deployment.yaml
```

6. Check deployment status:
```bash
kubectl get all -n sample-app
```

7. Access the frontend:
```bash
# Get the service URL
kubectl get svc frontend -n sample-app

# Or port-forward for testing
kubectl port-forward -n sample-app svc/frontend 4000:80
```

Then access http://localhost:4000

### Cleanup

```bash
kubectl delete namespace sample-app
```

## API Endpoints

### Backend API (Port 3001)

- `GET /health` - Health check endpoint
- `GET /api/users` - Get all users
- `GET /api/users/:id` - Get user by ID
- `POST /api/users` - Create new user
  ```json
  {
    "name": "John Doe",
    "email": "john@example.com"
  }
  ```

## Database Schema

### Users Table

```sql
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Environment Variables

### Backend
- `PORT` - Server port (default: 3001)
- `DB_HOST` - MySQL host
- `DB_USER` - MySQL user
- `DB_PASSWORD` - MySQL password
- `DB_NAME` - Database name
- `DB_PORT` - MySQL port (default: 3306)

### Frontend
- `REACT_APP_API_URL` - Backend API URL

## Next Steps for Kubernetes Integration

This application is ready for integration with:

1. **Tyk API Gateway**: Add Tyk Gateway deployment and configure routes
2. **Chaos Mesh**: Add chaos experiments for resilience testing
3. **Service Mesh (Istio/Linkerd)**: Add service mesh configuration for traffic management
4. **Monitoring**: Add Prometheus and Grafana for observability
5. **Logging**: Add ELK stack or similar for centralized logging

## Troubleshooting

### Backend can't connect to MySQL
- Check MySQL is running and accessible
- Verify database credentials in `.env` file
- Check network connectivity between services

### Frontend can't reach backend
- Verify `REACT_APP_API_URL` is set correctly
- Check CORS settings in backend
- Ensure backend service is running

### Kubernetes deployment issues
- Check pod logs: `kubectl logs -n sample-app <pod-name>`
- Verify images are available in cluster
- Check service endpoints: `kubectl get endpoints -n sample-app`

## License

MIT


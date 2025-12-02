# Service Mesh Overview

A service mesh is like a smart traffic manager that sits between your services. It:
- Encrypts traffic between services automatically (mTLS)
- Adds retries, timeouts, and circuit breakers without changing app code
- Gives deep observability: metrics, logs, traces
- Enables traffic shaping, A/B testing, chaos experiments

## Quick Mental Model

```
[Frontend Pod] --proxy--> [Backend Pod] --proxy--> [MySQL Pod]
        \____________ service mesh control plane ____________/
```

Each pod gets a tiny sidecar proxy (Envoy). All service-to-service traffic flows through the sidecars, and a control plane (like Istio) coordinates policies.

## Simple Implementation Plan with Istio

1. **Install Istio CLI**
   ```bash
   curl -L https://istio.io/downloadIstio | sh -
   export PATH="$PATH:$(pwd)/istio-1.23.0/bin"
   ```

2. **Install Istio components**
   ```bash
   istioctl install --set profile=demo -y
   ```
   This deploys the control plane (istiod) plus default ingress/egress gateways.

3. **Label your namespace for sidecar injection**
   ```bash
   kubectl label namespace sample-app istio-injection=enabled --overwrite
   ```
   Any new pod in `sample-app` now gets an Envoy sidecar automatically.

4. **Redeploy your workloads so sidecars are added**
   ```bash
   kubectl rollout restart deploy/mysql -n sample-app
   kubectl rollout restart deploy/backend -n sample-app
   kubectl rollout restart deploy/frontend -n sample-app
   ```

5. **Verify**
   ```bash
   kubectl get pods -n sample-app
   # Each pod should show 2/2 containers (app + istio-proxy)
   ```

6. **Expose via Istio Ingress Gateway (optional)**
   Create a VirtualService + Gateway to expose the frontend through Istio’s ingress instead of the LoadBalancer service.

## Basic Policies to Try

1. **mTLS between services**
   ```yaml
   apiVersion: security.istio.io/v1beta1
   kind: PeerAuthentication
   metadata:
     name: default
     namespace: sample-app
   spec:
     mtls:
       mode: STRICT
   ```

2. **Retry policy for backend**
   ```yaml
   apiVersion: networking.istio.io/v1alpha3
   kind: VirtualService
   metadata:
     name: backend
     namespace: sample-app
   spec:
     hosts:
       - backend.sample-app.svc.cluster.local
     http:
       - retries:
           attempts: 3
           perTryTimeout: 2s
         route:
           - destination:
               host: backend
               port:
                 number: 3001
   ```

3. **Traffic shifting (A/B)**
   ```yaml
   apiVersion: networking.istio.io/v1alpha3
   kind: DestinationRule
   metadata:
     name: backend
     namespace: sample-app
   spec:
     host: backend
     subsets:
       - name: v1
         labels:
           version: v1
       - name: v2
         labels:
           version: v2
   ---
   apiVersion: networking.istio.io/v1alpha3
   kind: VirtualService
   metadata:
     name: backend
     namespace: sample-app
   spec:
     hosts:
       - backend
     http:
       - route:
           - destination:
               host: backend
               subset: v1
             weight: 80
           - destination:
               host: backend
               subset: v2
             weight: 20
   ```
   Deploy backend v1/v2 with matching `version: v1`/`v2` labels to use this.

## When to Use a Service Mesh

- Multiple microservices with complex communication
- Need zero-trust security (mTLS everywhere)
- Require advanced traffic control without touching code
- Need consistent telemetry for monitoring/chaos testing

## When to Skip (for now)

- Very small apps with just 1-2 services
- Resource-constrained clusters (mesh adds CPU/RAM overhead)
- No need for advanced traffic policies yet

## Cleanup

```bash
istioctl uninstall --purge
kubectl delete namespace istio-system
```

## Next Steps

- Hook Istio metrics into Prometheus/Grafana
- Use Chaos Mesh to inject faults (network delay, pod failure) and observe how the mesh handles retries/timeouts
- Integrate with Tyk API gateway by pointing Tyk at the Istio ingress gateway


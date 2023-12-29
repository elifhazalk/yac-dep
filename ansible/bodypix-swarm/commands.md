### Deployment
```bash
docker stack deploy -c docker-compose.yml yacs
```

### Removing the Stack

```bash
docker stack rm yacs
```

### List Services in Stack
```bash
docker stack services yacs
```

### Tracking Logs
```bash
docker service logs -f yacs_bodypix
```

### List Service Replicas
```bash
docker service ps yacs_bodypix
```

### Scaling Services
```bash
docker service scale yacs_bodypix=10 yacs_draco=2
```

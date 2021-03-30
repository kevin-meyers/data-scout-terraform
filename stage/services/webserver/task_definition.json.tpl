[
  {
    "essential": true,
    "memory": 512,
    "name": "datascout",
    "cpu": 256,
    "image": "${repo_url}:latest",
    "environment": [],
    "portMappings": [
      {
        "containerPort": 3000,
        "hostPort": 3000
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "us-east-2",
        "awslogs-stream-prefix": "datascout-staging-service",
        "awslogs-group": "awslogs-datascout-staging"
      }
    }
  }
]

Got it — you want to work with Python Django as the backend and React as the frontend.
Here’s a complete, minimal, and runnable setup for a Django + React full-stack app.

1. Backend (Django + Django REST Framework)
Install dependencies
Bashpip install django djangorestframework

Create Django project & app
Bashdjango-admin startproject backend
cd backend
python manage.py startapp api

backend/settings.py (important parts)
PythonINSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'api',  # our app
]

# Allow React frontend to access API (for dev)
CORS_ALLOW_ALL_ORIGINS = True

Install CORS headers:
Bashpip install django-cors-headers

Add to INSTALLED_APPS and middleware:
PythonINSTALLED_APPS += ['corsheaders']
MIDDLEWARE = ['corsheaders.middleware.CorsMiddleware'] + MIDDLEWARE


api/models.py
Pythonfrom django.db import models

class Task(models.Model):
    title = models.CharField(max_length=200)
    completed = models.BooleanField(default=False)

    def __str__(self):
        return self.title


api/serializers.py
Pythonfrom rest_framework import serializers
from .models import Task

class TaskSerializer(serializers.ModelSerializer):
    class Meta:
        model = Task
        fields = '__all__'


api/views.py
Pythonfrom rest_framework import viewsets
from .models import Task
from .serializers import TaskSerializer

class TaskViewSet(viewsets.ModelViewSet):
    queryset = Task.objects.all()
    serializer_class = TaskSerializer


api/urls.py
Pythonfrom django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import TaskViewSet

router = DefaultRouter()
router.register(r'tasks', TaskViewSet)

urlpatterns = [
    path('', include(router.urls)),
]


backend/urls.py
Pythonfrom django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('api.urls')),
]


Run migrations & start server
Bashpython manage.py makemigrations
python manage.py migrate
python manage.py runserver

Your API is now live at:
http://127.0.0.1:8000/api/tasks/

2. Frontend (React)
Create React app
Bashnpx create-react-app frontend
cd frontend
npm install axios


src/App.js
Javascriptimport React, { useEffect, useState } from "react";
import axios from "axios";

function App() {
  const [tasks, setTasks] = useState([]);
  const [title, setTitle] = useState("");

  // Fetch tasks from Django API
  useEffect(() => {
    axios.get("http://127.0.0.1:8000/api/tasks/")
      .then(res => setTasks(res.data))
      .catch(err => console.error(err));
  }, []);

  // Add new task
  const addTask = () => {
    if (!title.trim()) return;
    axios.post("http://127.0.0.1:8000/api/tasks/", { title, completed: false })
      .then(res => setTasks([...tasks, res.data]))
      .catch(err => console.error(err));
    setTitle("");
  };

  return (
    <div style={{ padding: "20px" }}>
      <h1>To-Do List</h1>
      <input
        value={title}
        onChange={e => setTitle(e.target.value)}
        placeholder="New task"
      />
      <button onClick={addTask}>Add</button>
      <ul>
        {tasks.map(task => (
          <li key={task.id}>
            {task.title} {task.completed ? "✅" : ""}
          </li>
        ))}
      </ul>
    </div>
  );
}

export default App;


3. Running Both Together

Start Django backend:

Bashpython manage.py runserver


Start React frontend:

Bashnpm start


✅ Result:
You now have a full-stack Django + React app where:

Django REST API handles data storage and CRUD.
React fetches and displays tasks, and can add new ones.


If you want, I can give you a production-ready setup with:

React build served directly from Django
Environment-based API URLs
JWT authentication for login/logout

Do you want me to prepare that next?


Alright — let’s make your Django + React app production-ready with:

✅ React build served directly from Django (no separate dev server in production)
✅ Environment-based API URLs (so dev/prod use different backends)
✅ JWT authentication for secure login/logout


1. Backend (Django) – Production Setup
Install dependencies
Bashpip install django djangorestframework django-cors-headers djangorestframework-simplejwt


settings.py changes
Pythonimport os
from datetime import timedelta

INSTALLED_APPS = [
    # Django defaults...
    'rest_framework',
    'corsheaders',
    'api',
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    *MIDDLEWARE,  # keep existing middleware
]

# CORS for development
CORS_ALLOW_ALL_ORIGINS = True

# REST Framework + JWT
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    )
}

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=30),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=1),
}

# Static files (React build)
STATIC_URL = '/static/'
STATICFILES_DIRS = [
    os.path.join(BASE_DIR, 'frontend', 'build', 'static'),
]


JWT Auth Views – api/views.py
Pythonfrom rest_framework import viewsets, permissions
from .models import Task
from .serializers import TaskSerializer
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

class TaskViewSet(viewsets.ModelViewSet):
    queryset = Task.objects.all()
    serializer_class = TaskSerializer
    permission_classes = [permissions.IsAuthenticated]  # Require login


URLs – backend/urls.py
Pythonfrom django.contrib import admin
from django.urls import path, include
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from django.views.generic import TemplateView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('api.urls')),
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('', TemplateView.as_view(template_name='index.html')),  # React entry
]


2. Frontend (React) – Production & JWT
Install Axios
Bashnpm install axios


.env (React)
EnvREACT_APP_API_URL=http://127.0.0.1:8000/api


src/api.js
Javascriptimport axios from "axios";

const API = axios.create({
  baseURL: process.env.REACT_APP_API_URL,
});

// Attach JWT token automatically
API.interceptors.request.use((config) => {
  const token = localStorage.getItem("access");
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export default API;


src/App.js (with login + tasks)
Javascriptimport React, { useState, useEffect } from "react";
import API from "./api";

function App() {
  const [tasks, setTasks] = useState([]);
  const [title, setTitle] = useState("");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [loggedIn, setLoggedIn] = useState(false);

  const login = () => {
    API.post("/token/", { username, password })
      .then(res => {
        localStorage.setItem("access", res.data.access);
        localStorage.setItem("refresh", res.data.refresh);
        setLoggedIn(true);
        fetchTasks();
      })
      .catch(() => alert("Invalid credentials"));
  };

  const fetchTasks = () => {
    API.get("/tasks/")
      .then(res => setTasks(res.data))
      .catch(err => console.error(err));
  };

  const addTask = () => {
    if (!title.trim()) return;
    API.post("/tasks/", { title, completed: false })
      .then(res => setTasks([...tasks, res.data]))
      .catch(err => console.error(err));
    setTitle("");
  };

  useEffect(() => {
    if (localStorage.getItem("access")) {
      setLoggedIn(true);
      fetchTasks();
    }
  }, []);

  return (
    <div style={{ padding: "20px" }}>
      {!loggedIn ? (
        <>
          <h2>Login</h2>
          <input placeholder="Username" onChange={e => setUsername(e.target.value)} />
          <input type="password" placeholder="Password" onChange={e => setPassword(e.target.value)} />
          <button onClick={login}>Login</button>
        </>
      ) : (
        <>
          <h1>To-Do List</h1>
          <input value={title} onChange={e => setTitle(e.target.value)} placeholder="New task" />
          <button onClick={addTask}>Add</button>
          <ul>
            {tasks.map(task => (
              <li key={task.id}>{task.title} {task.completed ? "✅" : ""}</li>
            ))}
          </ul>
        </>
      )}
    </div>
  );
}

export default App;


3. Serving React from Django in Production

Build React:

Bashcd frontend
npm run build


Move build folder into Django project root:

backend/
  frontend/
    build/


Django will now serve index.html and static files automatically.


4. Deployment Notes

Use Gunicorn + Nginx for production.
Set DEBUG = False in settings.py.
Use PostgreSQL instead of SQLite for real deployments.
Configure ALLOWED_HOSTS properly.


If you want, I can prepare a Dockerized version so you can run Django + React + PostgreSQL in one command for both dev and production.
Do you want me to make that next?

Alright — let’s Dockerize your Django + React + PostgreSQL app so you can run the whole stack with one command in both development and production.
We’ll use Docker Compose to orchestrate:

Django backend (with Gunicorn in production)
React frontend (served by Django in production)
PostgreSQL database


1. Project Structure
project/
│
├── backend/
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── manage.py
│   ├── backend/...
│   └── api/...
│
├── frontend/
│   ├── Dockerfile
│   ├── package.json
│   └── src/...
│
├── docker-compose.yml
└── .env


2. Backend – backend/Dockerfile
Dockerfile# Backend Dockerfile
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set work directory
WORKDIR /app

# Install dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy project
COPY . /app/

# Collect static files (for production)
RUN python manage.py collectstatic --noinput || true

CMD ["gunicorn", "backend.wsgi:application", "--bind", "0.0.0.0:8000"]


3. Backend – backend/requirements.txt
Django>=5.0
djangorestframework
django-cors-headers
djangorestframework-simplejwt
psycopg2-binary
gunicorn


4. Frontend – frontend/Dockerfile
Dockerfile# Frontend Dockerfile
FROM node:20 AS build

WORKDIR /app
COPY package.json package-lock.json /app/
RUN npm install
COPY . /app/
RUN npm run build

# Serve build via Django (copy to backend)
FROM python:3.11-slim AS final
WORKDIR /app
COPY --from=build /app/build /app/frontend/build

(We’ll copy the React build into Django’s static folder in production.)

5. Docker Compose – docker-compose.yml
Yamlversion: "3.9"

services:
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  backend:
    build: ./backend
    command: gunicorn backend.wsgi:application --bind 0.0.0.0:8000
    volumes:
      - ./backend:/app
    ports:
      - "8000:8000"
    env_file:
      - .env
    depends_on:
      - db

  frontend:
    build: ./frontend
    command: sh -c "npm install && npm start"
    volumes:
      - ./frontend:/app
      - /app/node_modules
    ports:
      - "3000:3000"
    environment:
      - CHOKIDAR_USEPOLLING=true
    depends_on:
      - backend

volumes:
  postgres_data:


6. Environment Variables – .env
EnvPOSTGRES_DB=todo_db
POSTGRES_USER=todo_user
POSTGRES_PASSWORD=todo_pass
DJANGO_SECRET_KEY=supersecretkey
DJANGO_DEBUG=True
ALLOWED_HOSTS=*


7. Django Settings for PostgreSQL – backend/settings.py
Pythonimport os

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.getenv('POSTGRES_DB'),
        'USER': os.getenv('POSTGRES_USER'),
        'PASSWORD': os.getenv('POSTGRES_PASSWORD'),
        'HOST': 'db',
        'PORT': 5432,
    }
}

SECRET_KEY = os.getenv('DJANGO_SECRET_KEY', 'fallbacksecret')
DEBUG = os.getenv('DJANGO_DEBUG', 'False') == 'True'
ALLOWED_HOSTS = os.getenv('ALLOWED_HOSTS', '*').split(',')


8. Running the Stack
Bashdocker-compose up --build


Frontend (dev) → http://localhost:3000
Backend API → http://localhost:8000/api/
PostgreSQL → port 5432


9. Production Build
For production:

Build React inside its container.
Copy the build into Django’s frontend/build.
Serve via Gunicorn + Nginx.

Example:
Bashdocker-compose -f docker-compose.yml -f docker-compose.prod.yml up --build -d

Where docker-compose.prod.yml replaces the frontend service with a build stage that copies files into Django.

10. Benefits

One command runs DB, backend, and frontend.
PostgreSQL for production-ready database.
JWT authentication already integrated.
Easily deployable to AWS, DigitalOcean, or any VPS.


If you want, I can now prepare the docker-compose.prod.yml with Nginx reverse proxy so Django serves the API and React build on the same domain with HTTPS support.
Do you want me to make that next?

Perfect — let’s finish this with a production-ready Docker Compose setup that:

✅ Runs Django + Gunicorn for the API
✅ Serves React build from Django’s static files
✅ Uses Nginx reverse proxy to serve both API and frontend on the same domain
✅ Supports HTTPS (via Let’s Encrypt if needed)


1. Final Project Structure
project/
│
├── backend/
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── manage.py
│   ├── backend/...
│   └── api/...
│
├── frontend/
│   ├── Dockerfile
│   ├── package.json
│   └── src/...
│
├── nginx/
│   └── nginx.conf
│
├── docker-compose.yml
├── docker-compose.prod.yml
└── .env


2. Backend – backend/Dockerfile (Production)
DockerfileFROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app

COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

COPY . /app/

# Collect static files for React build
RUN python manage.py collectstatic --noinput || true

CMD ["gunicorn", "backend.wsgi:application", "--bind", "0.0.0.0:8000"]


3. Frontend – frontend/Dockerfile (Build Stage)
DockerfileFROM node:20 AS build

WORKDIR /app
COPY package.json package-lock.json /app/
RUN npm install
COPY . /app/
RUN npm run build


4. Nginx Config – nginx/nginx.conf
Nginxserver {
    listen 80;

    server_name _;

    location /static/ {
        alias /app/static/;
    }

    location / {
        root /app/frontend/build;
        index index.html;
        try_files $uri /index.html;
    }

    location /api/ {
        proxy_pass http://backend:8000/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}


5. Base Compose – docker-compose.yml (Dev)
Yamlversion: "3.9"

services:
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  backend:
    build: ./backend
    command: python manage.py runserver 0.0.0.0:8000
    volumes:
      - ./backend:/app
    ports:
      - "8000:8000"
    env_file:
      - .env
    depends_on:
      - db

  frontend:
    build: ./frontend
    command: sh -c "npm install && npm start"
    volumes:
      - ./frontend:/app
      - /app/node_modules
    ports:
      - "3000:3000"
    environment:
      - CHOKIDAR_USEPOLLING=true
    depends_on:
      - backend

volumes:
  postgres_data:


6. Production Compose – docker-compose.prod.yml
Yamlversion: "3.9"

services:
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data

  backend:
    build: ./backend
    command: gunicorn backend.wsgi:application --bind 0.0.0.0:8000
    volumes:
      - ./backend:/app
    env_file:
      - .env
    depends_on:
      - db

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    command: sh -c "echo 'Frontend build complete'"
    volumes:
      - ./frontend:/app
    depends_on:
      - backend

  nginx:
    image: nginx:latest
    ports:
      - "80:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/conf.d/default.conf
      - ./backend/static:/app/static
      - ./frontend/build:/app/frontend/build
    depends_on:
      - backend
      - frontend

volumes:
  postgres_data:


7. Environment Variables – .env
EnvPOSTGRES_DB=todo_db
POSTGRES_USER=todo_user
POSTGRES_PASSWORD=todo_pass
DJANGO_SECRET_KEY=supersecretkey
DJANGO_DEBUG=False
ALLOWED_HOSTS=*


8. Build & Run in Production
Bashdocker-compose -f docker-compose.yml -f docker-compose.prod.yml up --build -d


9. Adding HTTPS (Optional)
For HTTPS, replace the nginx service with nginx + certbot or use a reverse proxy like Traefik.
Example with Let’s Encrypt:
Bashsudo certbot --nginx -d yourdomain.com


10. How It Works

Frontend is built in the frontend container, output copied into Django’s static folder.
Backend runs Django + Gunicorn.
Nginx serves:

/ → React build
/static/ → Django static files
/api/ → Proxied to Django backend


PostgreSQL stores data.


If you want, I can now give you a single unified Dockerfile that builds both Django and React in one image for even simpler deployment (no separate frontend container in prod).
That would make deployment one container + DB + Nginx only.
Do you want me to prepare that?


Alright — let’s make it super simple with a single unified Dockerfile
that builds React and Django together into one container for production.
This way, in production you’ll only have:

One container for Django + React build (served by Gunicorn)
One container for PostgreSQL
One container for Nginx reverse proxy (optional if you want HTTPS)


1. Project Structure
project/
│
├── backend/
│   ├── manage.py
│   ├── backend/...
│   ├── api/...
│   ├── requirements.txt
│   └── Dockerfile
│
├── frontend/
│   ├── package.json
│   ├── package-lock.json
│   └── src/...
│
├── nginx/
│   └── nginx.conf
│
├── docker-compose.yml
└── .env


2. Unified Dockerfile – backend/Dockerfile
Dockerfile# Stage 1: Build React frontend
FROM node:20 AS frontend-build
WORKDIR /frontend
COPY ../frontend/package*.json ./
RUN npm install
COPY ../frontend/ ./
RUN npm run build

# Stage 2: Build Django backend
FROM python:3.11-slim AS backend
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app

# Install dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend code
COPY . /app/

# Copy React build into Django's static folder
COPY --from=frontend-build /frontend/build /app/frontend/build

# Collect static files
RUN python manage.py collectstatic --noinput || true

# Run Gunicorn in production
CMD ["gunicorn", "backend.wsgi:application", "--bind", "0.0.0.0:8000"]


3. Nginx Config – nginx/nginx.conf
Nginxserver {
    listen 80;
    server_name _;

    location /static/ {
        alias /app/static/;
    }

    location / {
        root /app/frontend/build;
        index index.html;
        try_files $uri /index.html;
    }

    location /api/ {
        proxy_pass http://backend:8000/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}


4. Docker Compose – docker-compose.yml
Yamlversion: "3.9"

services:
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data

  backend:
    build: ./backend
    env_file:
      - .env
    depends_on:
      - db

  nginx:
    image: nginx:latest
    ports:
      - "80:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/conf.d/default.conf
      - ./backend/static:/app/static
      - ./frontend/build:/app/frontend/build
    depends_on:
      - backend

volumes:
  postgres_data:


5. Environment Variables – .env
EnvPOSTGRES_DB=todo_db
POSTGRES_USER=todo_user
POSTGRES_PASSWORD=todo_pass
DJANGO_SECRET_KEY=supersecretkey
DJANGO_DEBUG=False
ALLOWED_HOSTS=*


6. Build & Run
Bashdocker-compose up --build -d


Frontend + API served via Nginx on http://localhost
PostgreSQL running in background


7. Why This Is Simpler

One build creates both Django and React.
No separate frontend container in production.
Nginx just serves static files and proxies API requests.
Easy to deploy to AWS EC2, DigitalOcean, or any VPS.


8. Optional: HTTPS
If you want HTTPS:
Bashsudo certbot --nginx -d yourdomain.com

Or use Traefik in Docker for automatic SSL.

If you want, I can now give you a ready-to-deploy VPS script
that installs Docker, sets up this stack, and enables HTTPS automatically.
That would make deployment literally one command on a fresh server.
Do you want me to prepare that next?

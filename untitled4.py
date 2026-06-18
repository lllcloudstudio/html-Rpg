Integrating Django with React
1
2
3
Integrating Django with React allows you to leverage Django's robust backend capabilities and React's dynamic frontend features to create powerful web applications. This combination is particularly useful for building single-page applications (SPAs) where the frontend and backend are decoupled, enabling independent development and deployment.

Setting Up Django

First, ensure you have Python and Django installed. Create a virtual environment and install Django along with Django REST framework and django-cors-headers for handling CORS issues:

python -m venv env
source env/bin/activate
pip install django djangorestframework django-cors-headers
Copy
Create a new Django project and app:

django-admin startproject myproject
cd myproject
django-admin startapp myapp
Copy
Add the necessary configurations in settings.py:

INSTALLED_APPS = [

'rest_framework',
'corsheaders',
'myapp',
]

MIDDLEWARE = [

'corsheaders.middleware.CorsMiddleware',

]

CORS_ORIGIN_ALLOW_ALL = True
Copy
Define your models in myapp/models.py:

from django.db import models

class Item(models.Model):
title = models.CharField(max_length=100)
description = models.TextField()
completed = models.BooleanField(default=False)

def __str__(self):
return self.title
Copy
Run migrations to create the database schema:

python manage.py makemigrations
python manage.py migrate
Copy
Creating the API

Create serializers in myapp/serializers.py to convert model instances to JSON:

from rest_framework import serializers
from .models import Item

class ItemSerializer(serializers.ModelSerializer):
class Meta:
model = Item
fields = '__all__'
Copy
Define views in myapp/views.py using Django REST framework's viewsets:

from rest_framework import viewsets
from .models import Item
from .serializers import ItemSerializer

class ItemViewSet(viewsets.ModelViewSet):
queryset = Item.objects.all()
serializer_class = ItemSerializer
Copy
Update myproject/urls.py to include the API routes:

from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from myapp import views

router = DefaultRouter()
router.register(r'items', views.ItemViewSet)

urlpatterns = [
path('admin/', admin.site.urls),
path('api/', include(router.urls)),
]
Copy
Setting Up React

Create a React app using Create React App:

npx create-react-app frontend
cd frontend
npm install axios bootstrap reactstrap
Copy
In src/index.js, import Bootstrap CSS:

import 'bootstrap/dist/css/bootstrap.min.css';
Copy
Create a constants file src/constants.js to store the API URL:

export const API_URL = "http://localhost:8000/api/items/";
Copy
Build the React components, starting with a form component for adding and editing items:

import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { API_URL } from '../constants';

const ItemForm = ({ item, resetState, toggle }) => {
const [formData, setFormData] = useState({
title: '',
description: '',
completed: false,
});

useEffect(() => {
if (item) {
setFormData(item);
}
}, [item]);

const handleChange = (e) => {
setFormData({
...formData,
[e.target.name]: e.target.value,
});
};

const handleSubmit = (e) => {
e.preventDefault();
if (item) {
axios.put(`${API_URL}${item.id}/`, formData).then(() => {
resetState();
toggle();
});
} else {
axios.post(API_URL, formData).then(() => {
resetState();
toggle();
});
}
};

return (
<form onSubmit={handleSubmit}>
<div className="form-group">
<label>Title</label>
<input
type="text"
name="title"
value={formData.title}
onChange={handleChange}
className="form-control"
/>
</div>
<div className="form-group">
<label>Description</label>
<textarea
name="description"
value={formData.description}
onChange={handleChange}
className="form-control"
/>
</div>
<div className="form-group">
<label>
<input
type="checkbox"
name="completed"
checked={formData.completed}
onChange={() => setFormData({ ...formData, completed: !formData.completed })}
/>
Completed
</label>
</div>
<button type="submit" className="btn btn-primary">Save</button>
</form>
);
};

export default ItemForm;
Copy
Create a component to list items and handle CRUD operations:

import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { API_URL } from '../constants';
import ItemForm from './ItemForm';

const ItemList = () => {
const [items, setItems] = useState([]);
const [modal, setModal] = useState(false);
const [currentItem, setCurrentItem] = useState(null);

useEffect(() => {
refreshList();
}, []);

const refreshList = () => {
axios.get(API_URL).then((res) => setItems(res.data));
};

const handleDelete = (item) => {
axios.delete(`${API_URL}${item.id}/`).then(() => refreshList());
};

const toggle = () => setModal(!modal);

return (
<div>
<button onClick={() => { setCurrentItem(null); toggle(); }} className="btn btn-primary">Add Item</button>
<table className="table">
<thead>
<tr>
<th>Title</th>
<th>Description</th>
<th>Completed</th>
<th>Actions</th>
</tr>
</thead>
<tbody>
{items.map((item) => (
<tr key={item.id}>
<td>{item.title}</td>
<td>{item.description}</td>
<td>{item.completed ? 'Yes' : 'No'}</td>
<td>
<button onClick={() => { setCurrentItem(item); toggle(); }} className="btn btn-secondary">Edit</button>
<button onClick={() => handleDelete(item)} className="btn btn-danger">Delete</button>
</td>
</tr>
))}
</tbody>
</table>
{modal && <ItemForm item={currentItem} resetState={refreshList} toggle={toggle} />}
</div>
);
};

export default ItemList;
Copy
Finally, integrate the components in src/App.js:

import React from 'react';
import ItemList from './components/ItemList';

const App = () => {
return (
<div className="container">
<h1 className="text-center my-4">Todo App</h1>
<ItemList />
</div>
);
};

export default App;
Copy
Run the React app:

npm start
Copy
Ensure your Django server is running as well:

python manage.py runserver
Copy
Visit http://localhost:3000 to see your integrated Django and React application in action.

By following these steps, you can create a robust web application with a Django backend and a React frontend, leveraging the strengths of both frameworks.
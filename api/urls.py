from django.contrib import admin
from django.urls import path
from . import views

urlpatterns = [
    path('users', views.UsersHandler, name="users"),
    path('users/<int:id>', views.UserHandler, name="user"),
]

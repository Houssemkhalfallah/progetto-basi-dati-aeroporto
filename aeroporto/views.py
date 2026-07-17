from django_ratelimit.core import is_ratelimited
from django.shortcuts import render

def home(request):
    return render(request, 'home.html')
from django.shortcuts import redirect
from functools import wraps

def group_required(group_name):
    def decorator(view_func):
        @wraps(view_func)
        def wrapper(request, *args, **kwargs):

            if not request.user.is_authenticated:
                return redirect("login")

            if not request.user.groups.filter(name=group_name).exists():
                return redirect("error")

            return view_func(request, *args, **kwargs)

        return wrapper
    return decorator
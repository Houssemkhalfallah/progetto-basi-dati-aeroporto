from django.contrib import admin

# Register your models here.
from django.contrib import admin
from .models import UserPasseggero, UserGate, UserMagazzinoAeroportuale, UserAereo

admin.site.register(UserPasseggero)
admin.site.register(UserGate)
admin.site.register(UserMagazzinoAeroportuale)
admin.site.register(UserAereo)
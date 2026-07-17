# Gestione Aeroporto

Progetto web sviluppato con **Django** per la gestione di un aeroporto internazionale.

L'applicazione permette di gestire diverse informazioni legate all'aeroporto, come passeggeri, aerei, gate, container, merci, magazzini aeroportuali, itinerari, assistenti di volo, posti e prenotazioni.

---

## Requisiti

Per eseguire il progetto sulla propria macchina sono necessari:

- Python 3
- pip
- Git
- MySQL Server
- MySQL Client
- Visual Studio Code o un altro editor
- Un terminale, ad esempio PowerShell, Prompt dei comandi, terminale Linux oppure WSL

---

## 1. Clonare la repository

Aprire il terminale nella cartella in cui si vuole scaricare il progetto ed eseguire:

```bash
git clone https://github.com/Houssemkhalfallah/progetto-basi-dati-aeroporto.git
```

Entrare nella cartella del progetto:

```bash
cd progetto-basi-dati-aeroporto
```

---

## 2. Creare un ambiente virtuale

È consigliato usare un ambiente virtuale per installare le librerie del progetto senza modificarle a livello globale nel computer.

### Windows

```bash
python -m venv venv
venv\Scripts\activate
```

### macOS / Linux / WSL

```bash
python3 -m venv venv
source venv/bin/activate
```

Quando l'ambiente virtuale è attivo, nel terminale dovrebbe comparire:

```bash
(venv)
```

---

## 3. Installare le dipendenze

Eseguire sul terminale il comando:

```bash
pip install -r requirements.txt
```

---

## 4. Configurare MySQL

Il progetto usa un database MySQL chiamato:

```txt
aeroporto
```

Nel file `nucleo/settings.py` il database deve essere configurato in questo modo:

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'aeroporto',
        'USER': 'django',
        'PASSWORD': 'Django123-',
        'HOST': 'localhost',
        'PORT': '3306',
    }
}
```

---

## 5. Creare il database e l'utente MySQL

Accedere a MySQL come amministratore:

```bash
mysql -u root -p
```

Poi eseguire questi comandi:

```sql
CREATE DATABASE aeroporto CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER 'django'@'localhost' IDENTIFIED BY 'Django123-';

GRANT ALL PRIVILEGES ON aeroporto.* TO 'django'@'localhost';

FLUSH PRIVILEGES;
```

Uscire da MySQL:

```sql
EXIT;
```

---

## 6. Importare il dump del database

Nella repository è presente il file:

```txt
aeroporto_dump.sql
```

Questo file contiene la struttura, i vincoli e i trigger del database.

Per importarlo, dalla cartella principale del progetto eseguire:

```bash
mysql -u django -p aeroporto < aeroporto_dump.sql
```

Quando viene richiesta la password, inserire:

```txt
Django123-
```

Se l'importazione va a buon fine, il database `aeroporto` conterrà tutte le tabelle e i 34 trigger necessari al funzionamento del sito.

---

## 7. Verificare che il dump sia stato importato correttamente

Entrare in MySQL:

```bash
mysql -u django -p
```

Selezionare il database:

```sql
USE aeroporto;
```

Mostrare le tabelle:

```sql
SHOW TABLES;
```

Dovrebbero comparire tabelle come:

```txt
Aereo
Assistente_di_volo
Container_Aereo
Gate
Itinerario
Lingua
Magazzino_aeroportuale
Merce
Passeggero
Posto
Prenotazione
Scali
Stoccaggio
```

Oltre alle tabelle di Django, come:

```txt
auth_user
auth_group
django_migrations
django_session
django_admin_log
django_content_type
```

Per uscire:

```sql
EXIT;
```

---

## 8. Possibile problema con il DEFINER dei trigger

In alcuni casi, durante l'importazione del dump, MySQL potrebbe dare un errore legato a questa parte:

```sql
DEFINER=`django`@`localhost`
```

Questo può succedere se sulla macchina in cui si importa il database l'utente `django@localhost` non esiste ancora o non ha i permessi corretti.

In quel caso, si può aprire `aeroporto_dump.sql` con Visual Studio Code e rimuovere tutte le occorrenze di:

```sql
/*!50017 DEFINER=`django`@`localhost`*/
```

Dopo aver salvato il file, ripetere l'importazione:

```bash
mysql -u django -p aeroporto < aeroporto_dump.sql
```

---

## 9. Applicare le migrazioni Django

Dopo aver importato il database, eseguire:

```bash
python manage.py makemigrations
python manage.py migrate
```

Questi comandi servono a creare le tabelle gestite direttamente da Django (utenti, sessioni e collegamenti utente-ruolo).

---

## 10. Creare un superutente

Per accedere al pannello di amministrazione di Django, creare un superutente:

```bash
python manage.py createsuperuser
```

Verranno richiesti username, email e password.

---

## 11. Creare i gruppi utente

Il sito distingue cinque categorie di utenti. Avviare il server (vedi punto 12), accedere a:

```txt
http://127.0.0.1:8000/admin/
```

con le credenziali del superutente, ed entrare in **Authentication and Authorization → Groups → Add group**, creando questi cinque gruppi (nome esatto, minuscolo, con underscore):

```txt
passeggero
gestore_gate
gestore_aerei_trasporto_merci
gestore_aerei_passeggeri
gestore_magazzino_aeroportuale
```

---

## 12. Avviare il progetto

```bash
python manage.py runserver
```

Se tutto è configurato correttamente, il sito sarà raggiungibile su:

```txt
http://127.0.0.1:8000/
```

Da lì è possibile registrarsi scegliendo uno dei cinque ruoli ed esplorare le funzionalità del sistema di gestione dell'aeroporto.

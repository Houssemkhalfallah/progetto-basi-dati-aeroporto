import datetime
import json
from collections import defaultdict
from urllib import request

from django.core.exceptions import ValidationError

from django.contrib.auth.password_validation import validate_password

from django.contrib import messages
from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.models import Group, User
from django.contrib.auth import authenticate, login, logout, update_session_auth_hash
from django.contrib.auth.decorators import login_required
from aeroporto.models import *
from django.db import IntegrityError, DataError, connection, DatabaseError, transaction
from nucleo.decorators import group_required
from django_ratelimit.core import is_ratelimited

def get_user_role(user):
    gruppo = user.groups.first()
    return gruppo.name if gruppo else None

def redirect_by_role(request):
    role = get_user_role(request.user)
    if role is None:
        return redirect('index')
    if role == 'passeggero':
        return redirect('passeggero')
    elif role == 'gestore_gate':
        return redirect('gate')
    elif role == 'gestore_aerei_trasporto_merci':
        return redirect('aereo_merci')
    elif role == 'gestore_aerei_passeggeri':
        return redirect('aereo_passeggeri')
    elif role == 'gestore_magazzino_aeroportuale':
        return redirect('magazzino')
    return redirect('')

def estrai_errore_db(e):
    if hasattr(e, 'args') and len(e.args) > 1:
        messaggio = e.args[1]
    else:
        messaggio = str(e)
    testo = messaggio.lower()
    if "chk" in testo:
        return "Dati inseriti non validi"
    return messaggio

def register(request):
    if request.method != "POST":
        return render(request, 'index.html')
    username = request.POST.get('username')
    password = request.POST.get('password')
    password2 = request.POST.get('password2')
    ruolo = request.POST.get('ruolo')
    if password != password2:
        return render(request, 'index.html', {'error': "Le password non combaciano"})
    if User.objects.filter(username=username).exists():
        return render(request, 'index.html', {'error': "Lo username inserito già esiste"})
    try:
     validate_password(password, User(username=username))
    except ValidationError as e:
        return render(request, 'index.html', {'error': "\n".join(e.messages)})
    user = User.objects.create_user(username=username, password=password)
    group = Group.objects.get(name=ruolo)
    user.groups.add(group)
    messages.success(request, 'Registrazione effettuata con successo')
    return redirect('login')

def login_view(request):
    if request.user.is_authenticated and request.user is not None:
        return redirect_by_role(request)
    if request.method != "POST":
        return render(request, 'login.html')
    username = request.POST.get('username')
    password = request.POST.get('password')
    ip_limit = is_ratelimited(request, group='login_ip', key='ip', rate='3/1m', increment=False)
    user_limit = is_ratelimited(request, group='login_user', key='post:username', rate='3/1m', increment=False)
    if ip_limit or user_limit:
        return render(request, 'login.html', {'error': "Troppi tentativi di accesso. Riprova più tardi."})
    user = authenticate(request, username=username, password=password)
    if user is not None:
        login(request, user)
        return redirect_by_role(request)
    is_ratelimited(request, group='login_ip', key='ip', rate='3/1m', increment=True)
    is_ratelimited(request, group='login_user', key='post:username', rate='3/1m', increment=True)
    return render(request, 'login.html', {'error': "Credenziali non valide"})

@login_required
def logout_view(request):
    logout(request)
    messages.success(request, 'Logout effettuato con successo')
    return redirect('login')

@login_required
def modifica_password(request):
    if request.method == 'POST':
        user = request.user
        if user.check_password(request.POST.get('password_vecchia')):
            if request.POST.get('password_nuova') != request.POST.get('password_nuova_conferma'):
                return render(request, 'modifica_password.html', {'error': "Le password non coincidono"})
            try:
                validate_password(request.POST.get('password_nuova'), user.username)
            except ValidationError as e:
                return render(request, 'modifica_password.html', {'error': "\n".join(e.messages)})
            user.set_password(request.POST.get('password_nuova'))
            user.save()
            update_session_auth_hash(request, user)
            messages.success(request, 'Password modificata con successo')
            return redirect('login')
        else:
            return render(request, 'modifica_password.html', {'error': "Password attuale non corretta"})
    return render(request, 'modifica_password.html')

def error(request):
    return render(request, 'error.html')
@login_required
@group_required('passeggero')
def passeggero(request):
    return render(request, 'passeggero.html')

@login_required
@group_required('gestore_gate')
def gate(request):
    sql = """
            SELECT g.Numero, g.Terminal, g.Tipo, g.Lunghezza, CONCAT(g.Numero, g.Terminal) AS id
            FROM Gate g
            JOIN aeroporto_usergate ug
            ON g.Numero = ug.numero_gate
            AND g.Terminal = ug.terminal_gate
            WHERE ug.user_id = %s
    """
    gates = Gate.objects.raw(sql, [request.user.id])
    return render(request, 'gate.html', {'gates': gates})
@login_required
@group_required('gestore_aerei_trasporto_merci')
def aereo_merci(request):
    user_aereo = UserAereo.objects.filter(user=request.user).select_related('aereo')
    return render(request, 'aereo_merci.html', {'aerei': user_aereo})

@login_required
@group_required('gestore_aerei_passeggeri')
def aereo_passeggeri(request):
    user_aereo = UserAereo.objects.filter(user=request.user).select_related('aereo')
    return render(request, 'aereo_passeggeri.html', {'aerei': user_aereo})

@login_required
@group_required('gestore_magazzino_aeroportuale')
def magazzino(request):
    sql = """
         SELECT
        m.Nome,
        m.Posizione,
        m.Tipo,
        m.Capacita,
        CONCAT(m.Nome, '-', m.Posizione) AS id
    FROM Magazzino_aeroportuale m
    JOIN aeroporto_usermagazzinoaeroportuale um
      ON m.Nome = um.nome_magazzino
     AND m.Posizione = um.posizione_magazzino
    WHERE um.user_id = %s
          """
    magazzini = MagazzinoAeroportuale.objects.raw(sql, [request.user.id])
    return render(request, 'magazzino.html', {'magazzini': magazzini})
@login_required
@group_required('passeggero')
def passeggero_aggiungi(request):
    if UserPasseggero.objects.filter(user=request.user).exists():
        messages.error(request, "Hai già un passeggero associato")
        return redirect("passeggero")
    if request.method == 'POST':
        try:
            user_passeggero = Passeggero.objects.create(
                codice_fiscale=request.POST.get('codice_fiscale'),
                nome=request.POST.get('nome'),
                cognome=request.POST.get('cognome'),
                data_nascita=request.POST.get('data_nascita'),
                telefono=request.POST.get('telefono')
            )
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, "passeggero_aggiungi.html", {'error': errore})
        UserPasseggero.objects.create(
            user=request.user,
            passeggero=user_passeggero
        )
        messages.success(request, 'Passeggero aggiunto con successo')
        return redirect('passeggero')
    return render(request, 'passeggero_aggiungi.html')

@login_required
@group_required('passeggero')
def passeggero_modifica(request):
    try:
        user_passeggero = UserPasseggero.objects.get(user=request.user).passeggero
    except UserPasseggero.DoesNotExist:
        messages.error(request, "Non hai un passeggero associato")
        return redirect("passeggero")
    if request.method == 'POST':
        user_passeggero.codice_fiscale = request.POST.get('codice_fiscale')
        user_passeggero.nome = request.POST.get('nome')
        user_passeggero.cognome = request.POST.get('cognome')
        user_passeggero.data_nascita = request.POST.get('data_nascita')
        user_passeggero.telefono = request.POST.get('telefono')
        try:
            user_passeggero.save()
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, "passeggero_modifica.html", {'error': errore})
        messages.success(request, 'Passeggero modificato con successo')
        return redirect('passeggero')
    return render(request, 'passeggero_modifica.html', {'passeggero': user_passeggero})

@login_required
@group_required('passeggero')
def passeggero_elimina(request):
    try:
        user_passeggero = UserPasseggero.objects.get(user=request.user).passeggero
    except UserPasseggero.DoesNotExist:
        messages.error(request, "Non hai un passeggero associato")
        return redirect("passeggero")
    if request.method == 'POST':
        try:
            user_passeggero.delete()
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, "passeggero_elimina.html", {'error': errore})
        messages.success(request, 'Passeggero eliminato con successo')
        return redirect('passeggero')
    return render(request, 'passeggero_elimina.html', {'passeggero': user_passeggero})

@login_required
@group_required('passeggero')
def passeggero_visualizza(request):
    try:
        user_passeggero = UserPasseggero.objects.get(user=request.user).passeggero
    except UserPasseggero.DoesNotExist:
        messages.error(request, "Non hai un passeggero associato")
        return redirect("passeggero")
    return render(request, 'passeggero_visualizza.html', {'passeggero': user_passeggero})

@login_required
@group_required('passeggero')
def prenotazione(request):

    if not UserPasseggero.objects.filter(user=request.user).exists():
        messages.error(request, "Devi inserire i tuoi dati per poter effettuare una prenotazione")
        return redirect('passeggero')

    itinerari = list(Itinerario.objects.all())

    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT ID_itinerario, Nome_scalo
            FROM Scali
        """)
        rows = cursor.fetchall()

    scali_map = {}
    for id_itin, nome_scalo in rows:
        scali_map.setdefault(id_itin, []).append(nome_scalo)

    for i in itinerari:
        i.scali = scali_map.get(i.id, [])

    risultati = None

    if request.method == 'POST':
        itinerari_ids = request.POST.getlist('itinerari')
        classi = request.POST.getlist('classe')
        tipologie = request.POST.getlist('tipologia')
        data_inizio = request.POST.get('data_inizio')
        data_fine = request.POST.get('data_fine')

        query = """
            SELECT DISTINCT
            p.Codice_ICAO,
            a.Modello AS ModelloAereo,
            p.Numero,
            p.Classe,
            p.Tipologia,
            1 AS id
            FROM Posto p
            JOIN Aereo a ON p.Codice_ICAO = a.Codice_ICAO
            JOIN Itinerario i ON a.ID_itinerario = i.ID
            WHERE 1=1
        """

        params = []

        if itinerari_ids:
            query += " AND i.ID IN ({})".format(','.join(['%s'] * len(itinerari_ids)))
            params.extend(itinerari_ids)

        if classi:
            query += " AND p.Classe IN ({})".format(','.join(['%s'] * len(classi)))
            params.extend(classi)

        if tipologie:
            query += " AND p.Tipologia IN ({})".format(','.join(['%s'] * len(tipologie)))
            params.extend(tipologie)

        if data_inizio and data_fine:
            query += """
                AND NOT EXISTS (
                    SELECT 1
                    FROM Prenotazione pr
                    WHERE pr.Codice_ICAO = p.Codice_ICAO
                      AND pr.Numero = p.Numero
                      AND (
                            pr.Data_inizio <= %s
                        AND pr.Scadenza >= %s
                      )
                )
            """
            params.append(data_fine)
            params.append(data_inizio)

        with connection.cursor() as cursor:
            cursor.execute(query, params)
            columns = [col[0] for col in cursor.description]
            risultati = [dict(zip(columns, row)) for row in cursor.fetchall()]

    return render(request, 'prenotazione.html', {
        'itinerari': itinerari,
        'risultati': risultati
    })

@login_required
@group_required('passeggero')
def prenotazione_aggiungi(request, codice_icao, numero):
    if not UserPasseggero.objects.filter(user=request.user).exists():
        messages.error(request, "Devi inserire i tuoi dati per poter effettuare una prenotazione")
        return redirect('passeggero')
    i = Aereo.objects.get(codice_icao=codice_icao).id_itinerario
    p = list(Posto.objects.raw("""SELECT p.Codice_ICAO, p.Numero, p.Classe, p.Tipologia, 1 AS id FROM Posto p WHERE p.Codice_ICAO = %s AND p.Numero = %s""", [codice_icao, numero]))[0]
    prezzo = i.prezzo
    if request.method == 'POST':
        try:
            Prenotazione.objects.create(
                codice_icao=codice_icao,
                numero=numero,
                codice_fiscale=UserPasseggero.objects.get(user=request.user).passeggero,
                data_inizio=request.POST.get('data_inizio'),
                scadenza=request.POST.get('data_fine'),
                bagaglio_extra=1 if request.POST.get('bagaglio_extra') else 0,
            )
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, 'prenotazione_aggiungi.html', {'itinerario': i, 'posto': p, 'prezzo': prezzo, 'error': errore})
        return redirect('prenotazione_visualizza')
    return render(request, 'prenotazione_aggiungi.html', {'itinerario': i, 'posto': p, 'prezzo': prezzo})

@login_required
@group_required('passeggero')
def prenotazione_visualizza(request):

    if not UserPasseggero.objects.filter(user=request.user).exists():
        messages.error(request, "Devi inserire i tuoi dati per poter effettuare una prenotazione")
        return redirect('passeggero')

    query = """
        SELECT
            p.ID,
            p.Codice_ICAO AS codice_icao,
            a.Modello AS ModelloAereo,
            p.Numero AS numero,
            p.Data_inizio AS data_inizio,
            p.Scadenza AS scadenza,
            p.Bagaglio_extra AS bagaglio_extra
        FROM Prenotazione p
        JOIN Aereo a ON p.Codice_ICAO = a.Codice_ICAO
        WHERE p.Codice_fiscale = %s
    """

    with connection.cursor() as cursor:
        cursor.execute(query, [UserPasseggero.objects.get(user=request.user).passeggero.codice_fiscale])
        columns = [col[0] for col in cursor.description]
        prenotazioni = [
            dict(zip(columns, row))
            for row in cursor.fetchall()
        ]

    return render(request, 'prenotazione_visualizza.html', {
        'prenotazioni': prenotazioni
    })

@login_required
@group_required('passeggero')
def prenotazione_modifica(request, id_prenotazione):
    if not Prenotazione.objects.filter(id=id_prenotazione, codice_fiscale=UserPasseggero.objects.get(user=request.user).passeggero).exists():
        messages.error(request, "Non sei autorizzato a modificare questa prenotazione")
        return redirect('prenotazione')
    p = Prenotazione.objects.get(id=id_prenotazione)
    if request.method == 'POST':
        try:
            p.data_inizio = request.POST.get('data_inizio')
            p.scadenza = request.POST.get('data_fine')
            p.bagaglio_extra = 1 if request.POST.get('bagaglio_extra') else 0
            p.save()
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, 'prenotazione_modifica.html', {'prenotazione': p, 'error': errore})
        except DataError:
            return render(request, 'prenotazione_modifica.html', {'prenotazione': p, 'error': 'Dati non validi'})
        messages.success(request, 'Prenotazione modificata con successo')
        return redirect('prenotazione_visualizza')
    return render(request, 'prenotazione_modifica.html', {'prenotazione': p})

@login_required
@group_required('passeggero')
def prenotazione_elimina(request, id_prenotazione):
    if not Prenotazione.objects.filter(id=id_prenotazione, codice_fiscale=UserPasseggero.objects.get(user=request.user).passeggero).exists():
        messages.error(request, "Non sei autorizzato a eliminare questa prenotazione")
        return redirect('prenotazione')
    p = Prenotazione.objects.get(id=id_prenotazione)
    if request.method == 'POST':
        try:
            p.delete()
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, 'prenotazione_elimina.html', {'prenotazione': p, 'error': errore})
        messages.success(request, 'Prenotazione eliminata con successo')
        return redirect('prenotazione_visualizza')
    return render(request, 'prenotazione_elimina.html', {'prenotazione': p})
@login_required
@group_required('gestore_gate')
def gate_aggiungi(request):
    if request.method == 'POST':
        try:
            g = Gate.objects.create(
                numero=int(request.POST.get('numero') or 0),
                terminal=request.POST.get('terminal'),
                tipo=request.POST.get('tipo'),
                lunghezza=float(request.POST.get('lunghezza') or 0),
            )
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, "gate_aggiungi.html", {'error': errore})
        UserGate.objects.create(
            user=request.user,
            numero_gate=g.numero,
            terminal_gate=g.terminal,
        )
        messages.success(request, 'Gate aggiunto con successo')
        return redirect('gate')
    return render(request, 'gate_aggiungi.html')

@login_required
@group_required('gestore_gate')
def gate_modifica(request, numero, terminal):
    if not UserGate.objects.filter(user=request.user, numero_gate=numero, terminal_gate=terminal).exists():
        messages.error(request, "Non sei autorizzato a modificare questo gate")
        return redirect('gate')
    sql = """
        SELECT g.Numero, g.Terminal, g.Tipo, g.Lunghezza, CONCAT(g.Numero, g.Terminal) AS id
        FROM Gate g
        WHERE g.Numero = %s
        AND g.Terminal = %s
    """
    g = Gate.objects.raw(sql, [numero, terminal])[0]
    if request.method == 'POST':
        tipo = request.POST.get('tipo')
        lunghezza = float(request.POST.get('lunghezza') or 0)
        with connection.cursor() as cursor:
            try:
                cursor.execute("""
                               UPDATE Gate
                               SET Tipo      = %s,
                                   Lunghezza = %s
                               WHERE Numero  = %s
                                 AND Terminal = %s
                               """, [tipo, lunghezza, numero, terminal]
                )
            except DatabaseError as e:
                errore = estrai_errore_db(e)
                return render(request, "gate_modifica.html", {'error': errore})
            if cursor.rowcount == 0:
                messages.error(request, 'Gate non trovato')
                return redirect('gate')
            messages.success(request, 'Gate modificato con successo')
            return redirect('gate')
    return render(request, 'gate_modifica.html', {'gate': g})

@login_required
@group_required('gestore_gate')
def gate_elimina(request, numero, terminal):
    if not UserGate.objects.filter(user=request.user, numero_gate=numero, terminal_gate=terminal).exists():
        messages.error(request, "Non sei autorizzato a eliminare questo gate")
        return redirect('gate')
    sql = """
          SELECT g.Numero, g.Terminal, g.Tipo, g.Lunghezza, CONCAT(g.Numero, g.Terminal) AS id
          FROM Gate g
          WHERE g.Numero = %s
            AND g.Terminal = %s
         """
    g = Gate.objects.raw(sql, [numero, terminal])[0]
    if request.method == 'POST':
        with connection.cursor() as cursor:
            try:
                cursor.execute("""
                                DELETE FROM Gate
                                WHERE Numero = %s
                                AND Terminal = %s
                                """, [numero, terminal])
            except DatabaseError as e:
                errore = estrai_errore_db(e)
                return render(request, "gate_elimina.html", {'error': errore})
            if cursor.rowcount == 0:
                messages.error(request, 'Gate non trovato')
                return redirect('gate')
            messages.success(request, 'Gate eliminato con successo')
            return redirect('gate')
    return render(request, 'gate_elimina.html', {'gate': g})

@login_required
@group_required('gestore_gate')
def assegnazione(request):
    aerei = Aereo.objects.filter(numero_gate__isnull=True, terminal_gate__isnull=True)
    gate_per_tipo = defaultdict(list)
    gates = Gate.objects.raw("""SELECT Numero, Terminal, Tipo, Lunghezza, CONCAT(Numero, Terminal) AS id FROM Gate""")
    for g in gates:
        gate_per_tipo[g.tipo].append(g)
    aerei_con_gate = []
    for aereo in aerei:
        aerei_con_gate.append({
            "aereo": aereo,
            "gates": gate_per_tipo.get(aereo.tipo, [])
        })
    if request.method == 'POST':
        codice_icao = request.POST.get('codice_icao')
        valore = request.POST.get(f"gate_{codice_icao}")
        if valore:
            numero, terminal = valore.split('|')
            try:
                updated = Aereo.objects.filter(codice_icao=codice_icao).update(numero_gate=int(numero), terminal_gate=terminal)
                if updated == 0:
                    messages.error(request, 'Aereo non trovato')
                    return redirect('assegnazione')
            except DatabaseError as e:
                errore = estrai_errore_db(e)
                messages.error(request, errore)
                return redirect('assegnazione')
            messages.success(request, 'Aereo assegnato al gate con successo')
            return redirect('assegnazione')
    return render(request, 'assegnazione.html', {'aerei_con_gate': aerei_con_gate})

@login_required
@group_required('gestore_gate')
def assegnazione_visualizza(request):
    aerei = Aereo.objects.raw("""
        SELECT DISTINCT a.*
        FROM Aereo a
        JOIN aeroporto_usergate ug ON
        a.numero_gate = ug.numero_gate AND a.terminal_gate = ug.terminal_gate
        WHERE ug.user_id = %s
    """, [request.user.id])
    if request.method == 'POST':
        codice_icao = request.POST.get('codice_icao')
        try:
            Aereo.objects.filter(codice_icao=codice_icao).update(numero_gate=None, terminal_gate=None)
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            messages.error(request, errore)
            return redirect('assegnazione_visualizza')
        messages.success(request, 'Aereo rimosso dal gate con successo')
        return redirect('assegnazione_visualizza')
    return render(request, 'assegnazione_visualizza.html', {'aerei': aerei})
@login_required
@group_required('gestore_aerei_trasporto_merci')
def aereo_merci_aggiungi(request):
    if request.method == 'POST':
        try:
            aereo = Aereo.objects.create(
                codice_icao=request.POST.get('codice_icao'),
                modello=request.POST.get('modello'),
                compagnia=request.POST.get('compagnia'),
                altezza=float(request.POST.get('altezza') or 0),
                lunghezza=float(request.POST.get('lunghezza') or 0),
                apertura_alare=float(request.POST.get('apertura_alare') or 0),
                peso_max=float(request.POST.get('peso_max') or 0),
                capacita=int(request.POST.get('capacita') or 0),
                peso_occupato=0,
                volume_occupato=0,
                capienza=None,
                latitudine=0,
                longitudine=0,
                tipo="Trasporto merci",
            )
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, "aereo_merci_aggiungi.html", {'error': errore})
        UserAereo.objects.create(
            user=request.user,
            aereo=aereo
        )
        messages.success(request, 'Aereo aggiunto con successo')
        return redirect('aereo_merci')
    return render(request, 'aereo_merci_aggiungi.html')

@login_required
@group_required('gestore_aerei_trasporto_merci')
def aereo_merci_modifica(request, codice_icao):
    aereo = get_object_or_404(Aereo, codice_icao=codice_icao, useraereo__user=request.user)
    if request.method == 'POST':
        aereo.modello = request.POST.get('modello')
        aereo.compagnia = request.POST.get('compagnia')
        aereo.altezza = float(request.POST.get('altezza') or 0)
        aereo.lunghezza = float(request.POST.get('lunghezza') or 0)
        aereo.apertura_alare = float(request.POST.get('apertura_alare') or 0)
        aereo.peso_max = float(request.POST.get('peso_max') or 0)
        aereo.capacita = int(request.POST.get('capacita') or 0)
        try:
            aereo.save()
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, "aereo_merci_modifica.html", {'error': errore})
        messages.success(request, 'Aereo modificato con successo')
        return redirect('aereo_merci')
    return render(request, 'aereo_merci_modifica.html', {'aereo': aereo})

@login_required
@group_required('gestore_aerei_trasporto_merci')
def aereo_merci_elimina(request, codice_icao):
    aereo = get_object_or_404(Aereo, codice_icao=codice_icao, useraereo__user=request.user)
    if request.method == 'POST':
        try:
            aereo.delete()
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, "aereo_merci_elimina.html", {'error': errore})
        messages.success(request, 'Aereo eliminato con successo')
        return redirect('aereo_merci')
    return render(request, 'aereo_merci_elimina.html', {'aereo': aereo})

@login_required
@group_required('gestore_aerei_trasporto_merci')
def container(request, codice_icao):
    if not UserAereo.objects.filter(user=request.user, aereo__codice_icao=codice_icao).exists():
        messages.error(request, "Non sei autorizzato a visualizzare i container su questo aereo")
        return redirect('aereo_merci')
    container_aereo = ContainerAereo.objects.filter(codice_icao_id=codice_icao)
    return render(request, 'container.html', {'codice_icao': codice_icao, 'container_aereo': container_aereo})

@login_required
@group_required('gestore_aerei_trasporto_merci')
def container_aggiungi(request, codice_icao):
    if not UserAereo.objects.filter(user=request.user, aereo__codice_icao=codice_icao).exists():
        messages.error(request, "Non sei autorizzato ad aggiungere container su questo aereo")
        return redirect('aereo_merci')
    if request.method == 'POST':
        try:
            ContainerAereo.objects.create(
                id=request.POST.get('id'),
                capacita=int(request.POST.get('capacita') or 0),
                peso=0,
                compagnia_logistica=request.POST.get('compagnia_logistica'),
                codice_icao_id=codice_icao,
                data_inizio=request.POST.get('data_inizio'),
                data_fine=request.POST.get('data_fine'),
                destinazione=request.POST.get('destinazione'),
            )
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, "container_aggiungi.html", {'codice_icao': codice_icao, 'error': errore})
        messages.success(request, 'Container aggiunto con successo')
        return redirect('container', codice_icao=codice_icao)
    return render(request, 'container_aggiungi.html', {'codice_icao': codice_icao})

@login_required
@group_required('gestore_aerei_trasporto_merci')
def container_modifica(request, container_id):
    if not ContainerAereo.objects.filter(id=container_id, codice_icao__useraereo__user=request.user).exists():
        messages.error(request, "Non sei autorizzato a modificare questo container")
        return redirect('aereo_merci')
    c = ContainerAereo.objects.get(id=container_id)
    aerei = Aereo.objects.filter(useraereo__user=request.user)
    if request.method == 'POST':
        try:
            c.capacita = int(request.POST.get('capacita') or 0)
            c.compagnia_logistica = request.POST.get('compagnia_logistica')
            c.codice_icao_id = request.POST.get('codice_icao')
            c.data_inizio = request.POST.get('data_inizio')
            c.data_fine = request.POST.get('data_fine')
            c.destinazione = request.POST.get('destinazione')
            c.save()
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, "container_modifica.html", {'container': c, 'aerei': aerei, 'error': errore})
        messages.success(request, 'Container modificato con successo')
        return redirect('container', codice_icao=c.codice_icao_id)
    return render(request, 'container_modifica.html', {'container': c, 'aerei': aerei})

@login_required
@group_required('gestore_aerei_trasporto_merci')
def container_elimina(request, container_id):
    if not ContainerAereo.objects.filter(id=container_id, codice_icao__useraereo__user=request.user).exists():
        messages.error(request, "Non sei autorizzato ad eliminare questo container")
        return redirect('aereo_merci')
    c = ContainerAereo.objects.get(id=container_id)
    if request.method == 'POST':
        codice_icao = c.codice_icao_id
        try:
            c.delete()
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, "container_elimina.html", {'container': c, 'error': errore})
        messages.success(request, 'Container eliminato con successo')
        return redirect('container', codice_icao=codice_icao)
    return render(request, 'container_elimina.html', {'container': c})

@login_required
@group_required('gestore_aerei_trasporto_merci')
def merce(request, container_id):
    if not ContainerAereo.objects.filter(id=container_id, codice_icao__useraereo__user=request.user).exists():
        messages.error(request, "Non sei autorizzato ad accedere a questa merce")
        return redirect('aereo_merci')
    m = Merce.objects.filter(id_container=container_id)
    return render(request, 'merce.html', {'container_id': container_id, 'merce': m})

@login_required
@group_required('gestore_aerei_trasporto_merci')
def merce_aggiungi(request, container_id):
    if not ContainerAereo.objects.filter(id=container_id, codice_icao__useraereo__user=request.user).exists():
        messages.error(request, "Non sei autorizzato ad aggiungere merce a questo container")
        return redirect('aereo_merci')
    if request.method == 'POST':
        try:
            Merce.objects.create(
                sscc=request.POST.get('sscc'),
                peso=float(request.POST.get('peso') or 0),
                paese=request.POST.get('paese'),
                categoria=request.POST.get('categoria'),
                id_container_id=container_id,
            )
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, "merce_aggiungi.html", {'container_id': container_id, 'error': errore})
        messages.success(request, 'Merce aggiunta con successo')
        return redirect('merce', container_id=container_id)
    return render(request, 'merce_aggiungi.html', {'container_id': container_id})

@login_required
@group_required('gestore_aerei_trasporto_merci')
def merce_modifica(request, sscc):
    if not Merce.objects.filter(sscc=sscc, id_container__codice_icao__useraereo__user=request.user).exists():
        messages.error(request, "Non sei autorizzato a modificare questa merce")
        return redirect('aereo_merci')
    m = Merce.objects.get(sscc=sscc)
    c = ContainerAereo.objects.filter(codice_icao__useraereo__user=request.user)
    if request.method == 'POST':
        try:
            m.peso = float(request.POST.get('peso') or 0)
            m.paese = request.POST.get('paese')
            m.categoria = request.POST.get('categoria')
            m.id_container_id = request.POST.get('id_container')
            m.save()
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, "merce_modifica.html", {'merce': m, 'container': c, 'error': errore})
        messages.success(request, 'Merce modificata con successo')
        return redirect('merce', container_id=m.id_container_id)
    return render(request, 'merce_modifica.html', {'merce': m, 'container': c})

@login_required
@group_required('gestore_aerei_trasporto_merci')
def merce_elimina(request, sscc):
    if not Merce.objects.filter(sscc=sscc, id_container__codice_icao__useraereo__user=request.user).exists():
        messages.error(request, "Non sei autorizzato ad eliminare questa merce")
        return redirect('aereo_merci')
    m = Merce.objects.get(sscc=sscc)
    if request.method == 'POST':
        container_id = m.id_container_id
        try:
            m.delete()
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, "merce_elimina.html", {'merce': m, 'error': errore})
        messages.success(request, 'Merce eliminata con successo')
        return redirect('merce', container_id=container_id)
    return render(request, 'merce_elimina.html', {'merce': m})
@login_required
@group_required('gestore_aerei_passeggeri')
def aereo_passeggeri_aggiungi(request):
    itinerari = Itinerario.objects.all()
    if request.method == 'POST':
        try:
            itinerario_id = request.POST.get('id_itinerario')
            if itinerario_id:
                itinerarioOB = Itinerario.objects.get(pk=int(itinerario_id))
            else:
                itinerarioOB = None

            aereo = Aereo.objects.create(
                codice_icao=request.POST.get('codice_icao'),
                modello=request.POST.get('modello'),
                compagnia=request.POST.get('compagnia'),
                altezza=float(request.POST.get('altezza') or 0),
                lunghezza=float(request.POST.get('lunghezza') or 0),
                apertura_alare=float(request.POST.get('apertura_alare') or 0),
                capienza=int(request.POST.get('capienza') or 0),
                tipo="Passeggeri",
                peso_max=None,
                capacita=None,
                peso_occupato=0,
                volume_occupato=0,
                id_itinerario=itinerarioOB,
                latitudine=0,
                longitudine=0,
            )
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, "aereo_passeggeri_aggiungi.html", {'error': errore})
        UserAereo.objects.create(
            user=request.user,
            aereo=aereo
        )
        messages.success(request, 'Aereo aggiunto con successo')
        return redirect('aereo_passeggeri')
    return render(request, 'aereo_passeggeri_aggiungi.html', {'itinerari': itinerari})

@login_required
@group_required('gestore_aerei_passeggeri')
def aereo_passeggeri_modifica(request, codice_icao):
    aereo = get_object_or_404(Aereo, codice_icao=codice_icao, useraereo__user=request.user)
    itinerari = Itinerario.objects.all()
    if request.method == 'POST':
        aereo.modello = request.POST.get('modello')
        aereo.compagnia = request.POST.get('compagnia')
        aereo.altezza = float(request.POST.get('altezza') or 0)
        aereo.lunghezza = float(request.POST.get('lunghezza') or 0)
        aereo.apertura_alare = float(request.POST.get('apertura_alare') or 0)
        aereo.capienza = int(request.POST.get('capienza') or 0)
        itinerario_id = request.POST.get('id_itinerario')
        if itinerario_id:
            aereo.id_itinerario = Itinerario.objects.get(pk=int(itinerario_id))
        else:
            aereo.id_itinerario = None
        try:
            aereo.save()
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, "aereo_passeggeri_modifica.html", {'error': errore})
        messages.success(request, 'Aereo modificato con successo')
        return redirect('aereo_passeggeri')
    return render(request, 'aereo_passeggeri_modifica.html', {'aereo': aereo, 'itinerari': itinerari})

@login_required
@group_required('gestore_aerei_passeggeri')
def aereo_passeggeri_elimina(request, codice_icao):
    aereo = get_object_or_404(Aereo, codice_icao=codice_icao, useraereo__user=request.user)
    if request.method == 'POST':
        try:
            aereo.delete()
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, "aereo_passeggeri_elimina.html", {'error': errore})
        messages.success(request, 'Aereo eliminato con successo')
        return redirect('aereo_passeggeri')
    return render(request, 'aereo_passeggeri_elimina.html', {'aereo': aereo})

@login_required
@group_required('gestore_aerei_passeggeri')
def posto(request, codice_icao):
    if not UserAereo.objects.filter(user=request.user, aereo__codice_icao=codice_icao).exists():
        messages.error(request, "Non sei autorizzato ad accedere a questo aereo")
        return redirect('aereo_passeggeri')
    posti = Posto.objects.raw("""SELECT p.Codice_ICAO, p.Numero, p.Classe, p.Tipologia, 1 AS id FROM Posto p WHERE p.Codice_ICAO = %s""", [codice_icao])
    return render(request, 'posto.html', {'codice_icao': codice_icao, 'posti': posti})

@login_required
@group_required('gestore_aerei_passeggeri')
def posto_aggiungi(request, codice_icao):
    if not UserAereo.objects.filter(user=request.user, aereo__codice_icao=codice_icao).exists():
        messages.error(request, "Non sei autorizzato ad aggiungere posti su questo aereo")
        return redirect('aereo_passeggeri')
    if request.method == 'POST':
        try:
            with connection.cursor() as cursor:
                cursor.execute("""INSERT INTO Posto (Codice_ICAO, Numero, Classe, Tipologia) VALUES (%s, %s, %s, %s)""", [codice_icao, request.POST.get('numero'), request.POST.get('classe'), request.POST.get('tipologia')])
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, "posto_aggiungi.html", {'codice_icao': codice_icao, 'error': errore})
        messages.success(request, 'Posto aggiunto con successo')
        return redirect('posto', codice_icao=codice_icao)
    return render(request, 'posto_aggiungi.html', {'codice_icao': codice_icao})

@login_required
@group_required('gestore_aerei_passeggeri')
def posto_modifica(request, codice_icao, numero):
    if not UserAereo.objects.filter(user=request.user, aereo__codice_icao=codice_icao).exists():
        messages.error(request, "Non sei autorizzato a modificare questo posto")
        return redirect('aereo_passeggeri')
    p = Posto.objects.raw("""SELECT p.Codice_ICAO, p.Numero, p.Classe, p.Tipologia, 1 AS id FROM Posto p WHERE Codice_ICAO = %s AND Numero = %s""", [codice_icao, numero])[0]
    if request.method == 'POST':
        try:
            with connection.cursor() as cursor:
                cursor.execute("""UPDATE Posto SET Classe = %s, Tipologia = %s WHERE Codice_ICAO = %s AND Numero = %s""", [request.POST.get('classe'), request.POST.get('tipologia'), codice_icao, numero])
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, "posto_modifica.html", {'posto': p, 'error': errore})
        messages.success(request, 'Posto modificato con successo')
        return redirect('posto', codice_icao=codice_icao)
    return render(request, 'posto_modifica.html', {'posto': p})

@login_required
@group_required('gestore_aerei_passeggeri')
def posto_elimina(request, codice_icao, numero):
    if not UserAereo.objects.filter(user=request.user, aereo__codice_icao=codice_icao).exists():
        messages.error(request, "Non sei autorizzato ad eliminare questo posto")
        return redirect('aereo_passeggeri')
    if request.method == 'POST':
        try:
            with connection.cursor() as cursor:
                cursor.execute("""DELETE FROM Posto WHERE Codice_ICAO = %s AND Numero = %s""", [codice_icao, numero])
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, "posto_elimina.html", {'codice_icao': codice_icao, 'numero': numero, 'error': errore})
        messages.success(request, 'Posto eliminato con successo')
        return redirect('posto', codice_icao=codice_icao)
    return render(request, 'posto_elimina.html', {'codice_icao': codice_icao, 'numero': numero})
@login_required
@group_required('gestore_aerei_passeggeri')
def itinerario(request):
    itinerari_modificabili = (
        Itinerario.objects
        .filter(useritinerario__user=request.user)
        .distinct()
    )
    itinerari_non_modificabili = (
        Itinerario.objects
        .exclude(useritinerario__user=request.user)
        .distinct()
    )
    def aggiungi_scali(lista_itinerari):
        for it in lista_itinerari:
            with connection.cursor() as cursor:
                cursor.execute("""
                    SELECT Nome_scalo
                    FROM Scali
                    WHERE ID_itinerario = %s
                """, [it.id])
                rows = cursor.fetchall()
            it.scali = [r[0] for r in rows]
    aggiungi_scali(itinerari_modificabili)
    aggiungi_scali(itinerari_non_modificabili)
    return render(request, 'itinerario.html', {
        'itinerari_modificabili': itinerari_modificabili,
        'itinerari_non_modificabili': itinerari_non_modificabili,
    })

@login_required
@group_required('gestore_aerei_passeggeri')
def itinerario_aggiungi(request):

    if request.method == 'POST':

        try:
            it = Itinerario.objects.create(
                destinazione=request.POST.get('destinazione'),
                data_inizio=request.POST.get('data_inizio'),
                data_fine=request.POST.get('data_fine'),
                prezzo=float(request.POST.get('prezzo') or 0),
            )

            scali_raw = request.POST.get('scali', '')

            lista_scali = [
                s.strip()
                for s in scali_raw.split(',')
                if s.strip()
            ]

            with connection.cursor() as cursor:
                for scalo in lista_scali:
                    cursor.execute("""
                        INSERT INTO Scali(ID_itinerario, Nome_scalo)
                        VALUES (%s, %s)
                    """, [it.id, scalo])
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, 'itinerario_aggiungi.html', {'error': errore})
        UserItinerario.objects.create(user=request.user, itinerario=it)
        messages.success(request, 'Itinerario aggiunto con successo')
        return redirect('itinerario')

    return render(request, 'itinerario_aggiungi.html')

@login_required
@group_required('gestore_aerei_passeggeri')
def itinerario_modifica(request, itinerario_id):

    if not UserItinerario.objects.filter(
        user=request.user,
        itinerario_id=itinerario_id
    ).exists():

        messages.error(request, "Non sei autorizzato a modificare questo itinerario")
        return redirect('itinerario')

    it = Itinerario.objects.get(id=itinerario_id)

    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT Nome_scalo
            FROM Scali
            WHERE ID_itinerario = %s
        """, [itinerario_id])

        rows = cursor.fetchall()

    scali = [r[0] for r in rows]

    if request.method == 'POST':

        try:

            it.destinazione = request.POST.get('destinazione')
            it.data_inizio = request.POST.get('data_inizio')
            it.data_fine = request.POST.get('data_fine')
            it.prezzo = float(request.POST.get('prezzo') or 0)

            it.save()

            nuovi_scali = request.POST.get('scali', '')

            lista_scali = [
                s.strip()
                for s in nuovi_scali.split(',')
                if s.strip()
            ]

            with connection.cursor() as cursor:

                cursor.execute("""
                    DELETE FROM Scali
                    WHERE ID_itinerario = %s
                """, [itinerario_id])

                for scalo in lista_scali:

                    cursor.execute("""
                        INSERT INTO Scali(ID_itinerario, Nome_scalo)
                        VALUES (%s, %s)
                    """, [itinerario_id, scalo])


        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, 'itinerario_modifica.html', {
                'itinerario': it,
                'scali': ", ".join(scali),
                'error': errore
            })
        messages.success(request, 'Itinerario modificato con successo')
        return redirect('itinerario')
    return render(request, 'itinerario_modifica.html', {
        'itinerario': it,
        'scali': ", ".join(scali)
    })

@login_required
@group_required('gestore_aerei_passeggeri')
def itinerario_elimina(request, itinerario_id):

    if not UserItinerario.objects.filter(
        user=request.user,
        itinerario_id=itinerario_id
    ).exists():
        messages.error(request, "Non sei autorizzato a eliminare questo itinerario")
        return redirect('itinerario')

    it = Itinerario.objects.get(id=itinerario_id)

    if request.method == 'POST':

        try:
            UserItinerario.objects.filter(itinerario_id=itinerario_id).delete()
            it.delete()
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, 'itinerario_elimina.html', {
                'itinerario': it,
                'error': errore
            })
        messages.success(request, 'Itinerario eliminato con successo')
        return redirect('itinerario')
    return render(request, 'itinerario_elimina.html', {
        'itinerario': it
    })

@login_required
@group_required('gestore_aerei_passeggeri')
def assistente(request):
    assistenti_modificabili = UserAssistenteDiVolo.objects.filter(user=request.user)
    assistenti_non_modificabili = UserAssistenteDiVolo.objects.exclude(user=request.user)
    ass_mod = []
    ass_non_mod = []
    with connection.cursor() as cursor:
        for ua in assistenti_modificabili:
            a = ua.assistente
            cursor.execute("""
                SELECT Lingua, Livello
                FROM Lingua
                WHERE Codice_fiscale = %s
            """, [a.codice_fiscale])
            lingue = cursor.fetchall()
            ass_mod.append({
                'assistente': a,
                'lingue': lingue
            })
        for ua in assistenti_non_modificabili:
            a = ua.assistente
            cursor.execute("""
                SELECT Lingua, Livello
                FROM Lingua
                WHERE Codice_fiscale = %s
            """, [a.codice_fiscale])
            lingue = cursor.fetchall()
            ass_non_mod.append({
                'assistente': a,
                'lingue': lingue
            })
    return render(request, 'assistente.html', {
        'ass_mod': ass_mod,
        'ass_non_mod': ass_non_mod
    })

@login_required
@group_required('gestore_aerei_passeggeri')
def assistente_aggiungi(request):
    itinerari = UserItinerario.objects.filter(user=request.user)
    if request.method == 'POST':
        try:
            with transaction.atomic():
                a = AssistenteDiVolo.objects.create(
                    codice_fiscale=request.POST.get('codice_fiscale'),
                    nome=request.POST.get('nome'),
                    cognome=request.POST.get('cognome'),
                    data_nascita=request.POST.get('data_nascita'),
                    numero_licenza=int(request.POST.get('numero_licenza') or 0),
                    stipendio=float(request.POST.get('stipendio') or 0),
                    data_assunzione=request.POST.get('data_assunzione'),
                    valutazione=float(request.POST.get('valutazione') or 0),
                    id_itinerario_id=request.POST.get('id_itinerario') or None
                )

                lingue_raw = request.POST.get('lingue', '')

                lingue_list = [
                    x.strip()
                    for x in lingue_raw.split(',')
                    if x.strip()
                ]

                with connection.cursor() as cursor:
                    for item in lingue_list:

                        if ':' not in item:
                            continue

                        lingua, livello = item.split(':', 1)

                        cursor.execute("""
                            INSERT INTO Lingua(Codice_fiscale, Lingua, Livello)
                            VALUES (%s, %s, %s)
                        """, [a.codice_fiscale, lingua.strip(), livello.strip()])

                UserAssistenteDiVolo.objects.create(user=request.user, assistente=a)
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, 'assistente_aggiungi.html', {
                'error': errore,
                'itinerari': itinerari
            })
        messages.success(request, 'Assistente di volo aggiunto con successo')
        return redirect('assistente')

    return render(request, 'assistente_aggiungi.html', {
        'itinerari': itinerari
    })

@login_required
@group_required('gestore_aerei_passeggeri')
def assistente_modifica(request, codice_fiscale):

    if not UserAssistenteDiVolo.objects.filter(
        user=request.user,
        assistente_id=codice_fiscale
    ).exists():
        messages.error(request, "Non sei autorizzato a modificare questo assistente di volo")
        return redirect('assistente')

    a = AssistenteDiVolo.objects.get(codice_fiscale=codice_fiscale)

    itinerari = UserItinerario.objects.filter(user=request.user)

    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT Lingua, Livello
            FROM Lingua
            WHERE Codice_fiscale = %s
        """, [codice_fiscale])
        lingue_db = cursor.fetchall()

    lingue_str = ", ".join([f"{l[0]}:{l[1]}" for l in lingue_db])

    if request.method == 'POST':

        try:
            a.nome = request.POST.get('nome')
            a.cognome = request.POST.get('cognome')
            a.data_nascita = request.POST.get('data_nascita')
            a.numero_licenza = int(request.POST.get('numero_licenza') or 0)
            a.stipendio = float(request.POST.get('stipendio') or 0)
            a.data_assunzione = request.POST.get('data_assunzione')
            a.valutazione = float(request.POST.get('valutazione') or 0)
            a.id_itinerario_id = request.POST.get('id_itinerario') or None

            a.save()

            with connection.cursor() as cursor:
                cursor.execute("""
                    DELETE FROM Lingua
                    WHERE Codice_fiscale = %s
                """, [codice_fiscale])

                lingue_raw = request.POST.get('lingue', '')

                lingue_list = [
                    x.strip()
                    for x in lingue_raw.split(',')
                    if x.strip()
                ]

                for item in lingue_list:

                    if ':' not in item:
                        continue

                    lingua, livello = item.split(':', 1)

                    cursor.execute("""
                        INSERT INTO Lingua(Codice_fiscale, Lingua, Livello)
                        VALUES (%s, %s, %s)
                    """, [codice_fiscale, lingua.strip(), livello.strip()])

        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, 'assistente_modifica.html', {
                'assistente': a,
                'itinerari': itinerari,
                'lingue': lingue_str,
                'error': errore
            })
        messages.success(request, 'Assistente di volo modificato con successo')
        return redirect('assistente')
    return render(request, 'assistente_modifica.html', {
        'assistente': a,
        'itinerari': itinerari,
        'lingue': lingue_str
    })

@login_required
@group_required('gestore_aerei_passeggeri')
def assistente_elimina(request, codice_fiscale):

    if not UserAssistenteDiVolo.objects.filter(
        user=request.user,
        assistente_id=codice_fiscale
    ).exists():
        messages.error(request, "Non sei autorizzato a eliminare questo assistente di volo")
        return redirect('assistente')

    a = AssistenteDiVolo.objects.get(codice_fiscale=codice_fiscale)

    if request.method == 'POST':
        try:
            UserAssistenteDiVolo.objects.filter(assistente_id=codice_fiscale).delete()
            a.delete()
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, 'assistente_elimina.html', {
                'assistente': a,
                'error': errore
            })

        messages.success(request, 'Assistente di volo eliminato con successo')
        return redirect('assistente')

    return render(request, 'assistente_elimina.html', {
        'assistente': a
    })

@login_required
@group_required('gestore_aerei_passeggeri')
def aereo_prenotazione(request, codice_icao):
    if not UserAereo.objects.filter(user=request.user, aereo__codice_icao=codice_icao).exists():
        messages.error(request, "Non sei autorizzato a vedere le prenotazioni di questo aereo")
        return redirect('aereo_passeggeri')
    p = Prenotazione.objects.filter(codice_icao=codice_icao)
    return render(request, 'aereo_prenotazione.html', {'prenotazioni': p, 'codice_icao': codice_icao})
@login_required
@group_required('gestore_magazzino_aeroportuale')
def magazzino_aggiungi(request):
    if request.method == 'POST':
        try:
            mag = MagazzinoAeroportuale.objects.create(
                nome=request.POST.get('nome'),
                posizione=request.POST.get('posizione'),
                tipo=request.POST.get('tipo'),
                capacita=float(request.POST.get('capacita') or 0),
            )
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, "magazzino_aggiungi.html", {'error': errore})
        UserMagazzinoAeroportuale.objects.create(
            user=request.user,
            nome_magazzino=mag.nome,
            posizione_magazzino=mag.posizione,
        )
        messages.success(request, 'Magazzino aggiunto con successo')
        return redirect('magazzino')
    return render(request, 'magazzino_aggiungi.html')

@login_required
@group_required('gestore_magazzino_aeroportuale')
def magazzino_modifica(request, nome, posizione):
    if not UserMagazzinoAeroportuale.objects.filter(user=request.user, nome_magazzino=nome, posizione_magazzino=posizione).exists():
        messages.error(request, "Non sei autorizzato a modificare questo magazzino")
        return redirect('magazzino')
    sql = """
          SELECT  m.Nome, m.Posizione, m.Tipo, m.Capacita, 1 AS id
          FROM Magazzino_aeroportuale m
          WHERE m.Nome = %s
            AND m.Posizione = %s
          """
    mag = MagazzinoAeroportuale.objects.raw(sql, [nome, posizione])[0]
    if request.method == 'POST':
        tipo = request.POST.get('tipo')
        capacita = float(request.POST.get('capacita') or 0)
        with connection.cursor() as cursor:
            try:
                cursor.execute("""
                               UPDATE Magazzino_aeroportuale
                               SET Tipo     = %s,
                                   Capacita = %s
                               WHERE Nome = %s
                                 AND Posizione = %s
                               """, [
                                   tipo,
                                   capacita,
                                   nome,
                                   posizione
                               ])
            except DatabaseError as e:
                errore = estrai_errore_db(e)
                return render(request, "magazzino_modifica.html", {'error': errore})
        if cursor.rowcount == 0:
            messages.error(request, 'Magazzino non trovato')
            return redirect('magazzino')
        messages.success(request, 'Magazzino modificato con successo')
        return redirect('magazzino')
    return render(request, 'magazzino_modifica.html', {'magazzino': mag})

@login_required
@group_required('gestore_magazzino_aeroportuale')
def magazzino_elimina(request, nome, posizione):
    if not UserMagazzinoAeroportuale.objects.filter(user=request.user, nome_magazzino=nome, posizione_magazzino=posizione).exists():
        messages.error(request, "Non sei autorizzato a eliminare questo magazzino")
        return redirect('magazzino')
    sql = """
          SELECT m.Nome, m.Posizione, m.Tipo, m.Capacita, CONCAT(Nome, '', Posizione) AS id
          FROM Magazzino_aeroportuale m
          WHERE m.Nome = %s
            AND m.Posizione = %s
          """
    mag = MagazzinoAeroportuale.objects.raw(sql, [nome, posizione])[0]
    if request.method == 'POST':
        with connection.cursor() as cursor:
            try:
                cursor.execute("""
                           DELETE FROM Magazzino_aeroportuale
                           WHERE Nome = %s
                             AND Posizione = %s
                           """, [nome, posizione])
            except DatabaseError as e:
                errore = estrai_errore_db(e)
                return render(request, "magazzino_elimina.html", {'error': errore})
        if cursor.rowcount == 0:
            messages.error(request, 'Magazzino non trovato')
            return redirect('magazzino')
        UserMagazzinoAeroportuale.objects.filter(user=request.user, nome_magazzino=nome, posizione_magazzino=posizione).delete()
        messages.success(request, 'Magazzino eliminato con successo')
        return redirect('magazzino')
    return render(request, 'magazzino_elimina.html', {'magazzino': mag})

@login_required
@group_required('gestore_magazzino_aeroportuale')
def stoccaggio(request, nome, posizione):
    if not UserMagazzinoAeroportuale.objects.filter(nome_magazzino=nome, posizione_magazzino=posizione, user=request.user).exists():
        messages.error(request, "Non sei autorizzato ad accedere a questo magazzino")
        return redirect('magazzino')
    m = Merce.objects.filter(stoccaggio__nome_magazzino=nome, stoccaggio__posizione_magazzino=posizione)
    return render(request, 'stoccaggio.html', {'nome': nome, 'posizione': posizione, 'merce': m})

@login_required
@group_required('gestore_magazzino_aeroportuale')
def stoccaggio_aggiungi(request, nome, posizione):
    if not UserMagazzinoAeroportuale.objects.filter(nome_magazzino=nome, posizione_magazzino=posizione, user=request.user).exists():
        messages.error(request, "Non sei autorizzato ad aggiungere merce a questo magazzino")
        return redirect('magazzino')
    mag = MagazzinoAeroportuale.objects.raw("""SELECT m.Nome, m.Posizione, m.Tipo, 1 AS id FROM Magazzino_aeroportuale m WHERE Nome = %s AND Posizione = %s""", [nome, posizione])[0]
    m = Merce.objects.filter(stoccaggio__isnull=True, categoria=mag.tipo)
    if request.method == 'POST':
        selezionate = request.POST.getlist('merci')
        if not selezionate:
            return render(request, 'stoccaggio_aggiungi.html', {'nome': nome, 'posizione': posizione, 'merce': m, 'error': 'Nessuna merce selezionata'})
        for sscc in selezionate:
            try:
                Stoccaggio.objects.create(
                    sscc_id=sscc,
                    nome_magazzino=nome,
                    posizione_magazzino=posizione,
                )
            except DatabaseError as e:
                errore = estrai_errore_db(e)
                return render(request, 'stoccaggio_aggiungi.html', {'nome': nome, 'posizione': posizione, 'merce': m, 'error': errore})
        messages.success(request, 'Merci aggiunte con successo')
        return redirect('stoccaggio', nome=nome, posizione=posizione)
    return render(request, 'stoccaggio_aggiungi.html', {'nome': nome, 'posizione': posizione, 'merce': m})

@login_required
@group_required('gestore_magazzino_aeroportuale')
def stoccaggio_modifica(request, sscc):
    query = """
            SELECT s.SSCC, s.Nome_magazzino, s.Posizione_magazzino, 1 AS id
            FROM Stoccaggio s
                     JOIN aeroporto_usermagazzinoaeroportuale um
                          ON s.Nome_magazzino = um.nome_magazzino
                              AND s.Posizione_magazzino = um.posizione_magazzino
            WHERE s.SSCC = %s
              AND um.user_id = %s
            """
    res = list(Stoccaggio.objects.raw(query, [sscc, request.user.id]))
    if not res:
        messages.error(request, "Non sei autorizzato a modificare questa merce")
        return redirect('magazzino')
    me = Merce.objects.get(sscc=sscc)
    s = Stoccaggio.objects.get(sscc_id=sscc)
    query = """
        SELECT m.Nome, m.Posizione, 1 AS id
        FROM Magazzino_aeroportuale m
        JOIN aeroporto_usermagazzinoaeroportuale um ON m.Nome = um.nome_magazzino AND m.Posizione = um.posizione_magazzino
        WHERE um.user_id = %s AND m.Tipo = %s
    """
    mag = list(MagazzinoAeroportuale.objects.raw(query, [request.user.id, me.categoria]))
    if request.method == 'POST':
        selezionata = request.POST.get('magazzino')
        if not selezionata:
            return render(request, 'stoccaggio_modifica.html', {'stoccaggio': s, 'magazzini': mag, 'error': 'Nessun magazzino selezionato'})
        nome, posizione = selezionata.split('|')
        valid = any(
            m.nome == nome and m.posizione == posizione
            for m in mag
        )
        if not valid:
            messages.error(request, "Magazzino non valido")
            return redirect('magazzino')
        try:
            Stoccaggio.objects.filter(sscc_id=sscc).update(nome_magazzino=nome, posizione_magazzino=posizione)
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, 'stoccaggio_modifica.html', {'sscc': sscc, 'magazzini': mag, 'error': errore})
        messages.success(request, 'Merce modificata con successo')
        return redirect('stoccaggio', nome=nome, posizione=posizione)
    return render(request, 'stoccaggio_modifica.html', {'sscc': sscc, 'magazzini': mag, 'stoccaggio': s})

@login_required
@group_required('gestore_magazzino_aeroportuale')
def stoccaggio_elimina(request, sscc):
    query = """
            SELECT s.SSCC, s.Nome_magazzino, s.Posizione_magazzino, 1 AS id
            FROM Stoccaggio s
                     JOIN aeroporto_usermagazzinoaeroportuale um
                          ON s.Nome_magazzino = um.nome_magazzino
                              AND s.Posizione_magazzino = um.posizione_magazzino
            WHERE s.SSCC = %s AND um.user_id = %s
    """
    res = list(Stoccaggio.objects.raw(query, [sscc, request.user.id]))
    if not res:
        messages.error(request, "Non sei autorizzato a rimuovere questa merce")
        return redirect('magazzino')
    s = Stoccaggio.objects.get(sscc_id=sscc)
    if request.method == 'POST':
        try:
            s.delete()
        except DatabaseError as e:
            errore = estrai_errore_db(e)
            return render(request, 'stoccaggio_elimina.html', {'sscc': sscc, 'error': errore})
        messages.success(request, 'Merce eliminata con successo')
        return redirect('stoccaggio', nome=s.nome_magazzino, posizione=s.posizione_magazzino)
    return render(request, 'stoccaggio_elimina.html', {'sscc': sscc, 'nome': s.nome_magazzino, 'posizione': s.posizione_magazzino})
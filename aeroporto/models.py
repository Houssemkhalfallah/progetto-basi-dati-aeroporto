# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models
from django.contrib.auth.models import User


class Aereo(models.Model):
    codice_icao = models.CharField(db_column='Codice_ICAO', primary_key=True, max_length=10)  # Field name made lowercase.
    modello = models.CharField(db_column='Modello', max_length=100)  # Field name made lowercase.
    compagnia = models.CharField(db_column='Compagnia', max_length=100)  # Field name made lowercase.
    latitudine = models.FloatField(db_column='Latitudine')  # Field name made lowercase.
    longitudine = models.FloatField(db_column='Longitudine')  # Field name made lowercase.
    lunghezza = models.FloatField(db_column='Lunghezza')  # Field name made lowercase.
    altezza = models.FloatField(db_column='Altezza')  # Field name made lowercase.
    apertura_alare = models.FloatField(db_column='Apertura_alare')  # Field name made lowercase.
    tipo = models.CharField(db_column='Tipo', max_length=15)  # Field name made lowercase.
    capacita = models.IntegerField(db_column='Capacita', blank=True, null=True)  # Field name made lowercase.
    peso_max = models.FloatField(db_column='Peso_Max', blank=True, null=True)  # Field name made lowercase.
    peso_occupato = models.FloatField(db_column='Peso_occupato', blank=True, null=True)  # Field name made lowercase.
    volume_occupato = models.FloatField(db_column='Volume_occupato', blank=True, null=True)  # Field name made lowercase.
    capienza = models.IntegerField(db_column='Capienza', blank=True, null=True)  # Field name made lowercase.
    numero_gate = models.IntegerField(db_column='Numero_gate', blank=True, null=True)  # Field name made lowercase.
    terminal_gate = models.CharField(db_column='Terminal_gate', max_length=20, blank=True, null=True)  # Field name made lowercase.
    id_itinerario = models.ForeignKey('Itinerario', models.DO_NOTHING, db_column='ID_itinerario', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'aereo'


class AssistenteDiVolo(models.Model):
    codice_fiscale = models.CharField(db_column='Codice_fiscale', primary_key=True, max_length=16)  # Field name made lowercase.
    nome = models.CharField(db_column='Nome', max_length=100)  # Field name made lowercase.
    cognome = models.CharField(db_column='Cognome', max_length=100)  # Field name made lowercase.
    data_nascita = models.DateField(db_column='Data_nascita')  # Field name made lowercase.
    numero_licenza = models.IntegerField(db_column='Numero_licenza', unique=True)  # Field name made lowercase.
    stipendio = models.DecimalField(db_column='Stipendio', max_digits=20, decimal_places=2)  # Field name made lowercase.
    data_assunzione = models.DateField(db_column='Data_assunzione')  # Field name made lowercase.
    valutazione = models.DecimalField(db_column='Valutazione', max_digits=2, decimal_places=1)  # Field name made lowercase.
    id_itinerario = models.ForeignKey('Itinerario', models.DO_NOTHING, db_column='ID_itinerario', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'assistente_di_volo'


class ContainerAereo(models.Model):
    id = models.CharField(db_column='ID', primary_key=True, max_length=11)  # Field name made lowercase.
    capacita = models.FloatField(db_column='Capacita')  # Field name made lowercase.
    compagnia_logistica = models.CharField(db_column='Compagnia_logistica', max_length=100)  # Field name made lowercase.
    peso = models.FloatField(db_column='Peso')  # Field name made lowercase.
    codice_icao = models.ForeignKey(Aereo, models.DO_NOTHING, db_column='Codice_ICAO', blank=True, null=True)  # Field name made lowercase.
    data_inizio = models.DateField(db_column='Data_inizio')  # Field name made lowercase.
    data_fine = models.DateField(db_column='Data_fine')  # Field name made lowercase.
    destinazione = models.CharField(db_column='Destinazione', max_length=100)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'container_aereo'


class Gate(models.Model):
    pk = models.CompositePrimaryKey('numero', 'terminal')
    numero = models.IntegerField(db_column='Numero')  # Field name made lowercase.
    terminal = models.CharField(db_column='Terminal', max_length=20)  # Field name made lowercase.
    tipo = models.CharField(db_column='Tipo', max_length=15)  # Field name made lowercase.
    lunghezza = models.FloatField(db_column='Lunghezza')  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'gate'


class Itinerario(models.Model):
    id = models.AutoField(db_column='ID', primary_key=True)  # Field name made lowercase.
    data_inizio = models.DateField(db_column='Data_inizio')  # Field name made lowercase.
    data_fine = models.DateField(db_column='Data_fine')  # Field name made lowercase.
    destinazione = models.CharField(db_column='Destinazione', max_length=100)  # Field name made lowercase.
    prezzo = models.DecimalField(db_column='Prezzo', max_digits=20, decimal_places=2)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'itinerario'


class Lingua(models.Model):
    pk = models.CompositePrimaryKey('codice_fiscale', 'lingua')
    codice_fiscale = models.ForeignKey(AssistenteDiVolo, models.DO_NOTHING, db_column='Codice_fiscale')  # Field name made lowercase.
    lingua = models.CharField(db_column='Lingua', max_length=50)  # Field name made lowercase.
    livello = models.CharField(db_column='Livello', max_length=6)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'lingua'


class MagazzinoAeroportuale(models.Model):
    pk = models.CompositePrimaryKey('nome', 'posizione')
    nome = models.CharField(db_column='Nome', max_length=100)  # Field name made lowercase.
    posizione = models.CharField(db_column='Posizione', max_length=100)  # Field name made lowercase.
    tipo = models.CharField(db_column='Tipo', max_length=100)  # Field name made lowercase.
    capacita = models.FloatField(db_column='Capacita')  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'magazzino_aeroportuale'


class Merce(models.Model):
    sscc = models.CharField(db_column='SSCC', primary_key=True, max_length=18)  # Field name made lowercase.
    peso = models.FloatField(db_column='Peso')  # Field name made lowercase.
    paese = models.CharField(db_column='Paese', max_length=50)  # Field name made lowercase.
    categoria = models.CharField(db_column='Categoria', max_length=100)  # Field name made lowercase.
    id_container = models.ForeignKey(ContainerAereo, models.DO_NOTHING, db_column='ID_container', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'merce'


class Passeggero(models.Model):
    codice_fiscale = models.CharField(db_column='Codice_fiscale', primary_key=True, max_length=16)  # Field name made lowercase.
    nome = models.CharField(db_column='Nome', max_length=100)  # Field name made lowercase.
    cognome = models.CharField(db_column='Cognome', max_length=100)  # Field name made lowercase.
    data_nascita = models.DateField(db_column='Data_nascita')  # Field name made lowercase.
    telefono = models.CharField(db_column='Telefono', max_length=20, blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'passeggero'


class Posto(models.Model):
    pk = models.CompositePrimaryKey('codice_icao', 'numero')
    codice_icao = models.ForeignKey(Aereo, models.DO_NOTHING, db_column='Codice_ICAO')  # Field name made lowercase.
    numero = models.IntegerField(db_column='Numero')  # Field name made lowercase.
    classe = models.CharField(db_column='Classe', max_length=11)  # Field name made lowercase.
    tipologia = models.CharField(db_column='Tipologia', max_length=10)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'posto'


class Prenotazione(models.Model):
    id = models.AutoField(db_column='ID', primary_key=True)
    codice_icao = models.CharField(db_column='Codice_ICAO', max_length=10)
    numero = models.IntegerField(db_column='Numero')
    codice_fiscale = models.ForeignKey(Passeggero, models.DO_NOTHING, db_column='Codice_fiscale')
    data_inizio = models.DateField(db_column='Data_inizio')
    scadenza = models.DateField(db_column='Scadenza')
    bagaglio_extra = models.IntegerField(db_column='Bagaglio_extra')

    class Meta:
        managed = False
        db_table = 'prenotazione'

    


class Scali(models.Model):
    pk = models.CompositePrimaryKey('id_itinerario', 'nome_scalo')
    id_itinerario = models.ForeignKey(Itinerario, models.DO_NOTHING, db_column='ID_itinerario')  # Field name made lowercase.
    nome_scalo = models.CharField(db_column='Nome_scalo', max_length=100)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'scali'


class Stoccaggio(models.Model):
    sscc = models.OneToOneField(Merce, models.DO_NOTHING, db_column='SSCC', primary_key=True)  # Field name made lowercase.
    nome_magazzino = models.CharField(db_column='Nome_magazzino', max_length=100)  # Field name made lowercase.
    posizione_magazzino = models.CharField(db_column='Posizione_magazzino', max_length=100)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'stoccaggio'


class UserPasseggero(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, primary_key=True)
    passeggero = models.OneToOneField(Passeggero, on_delete=models.CASCADE)

    def __str__(self):
        return f"{self.user.username} -> Passeggero {self.passeggero.codice_fiscale} {self.passeggero.nome} {self.passeggero.cognome}"


class UserAereo(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    aereo = models.ForeignKey(Aereo, on_delete=models.CASCADE)

    class Meta:
        unique_together = (('user', 'aereo'),)

    def __str__(self):
        return f"{self.user.username} -> Aereo {self.aereo.codice_icao} {self.aereo.modello}"


class UserGate(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    numero_gate = models.IntegerField(default=0)
    terminal_gate = models.CharField(max_length=20, default="")

    class Meta:
        unique_together = (('user', 'numero_gate', 'terminal_gate'),)
        db_table = 'aeroporto_usergate'

    def __str__(self):
        return f"{self.user.username} -> Gate {self.numero_gate} {self.terminal_gate}"


class UserMagazzinoAeroportuale(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    nome_magazzino = models.CharField(max_length=100, default="Magazzino")
    posizione_magazzino = models.CharField(max_length=100, default="Posizione")

    class Meta:
        unique_together = (('user', 'nome_magazzino', 'posizione_magazzino'),)
        db_table = 'aeroporto_usermagazzinoaeroportuale'

    def __str__(self):
        return f"{self.user.username} -> Magazzino {self.nome_magazzino} {self.posizione_magazzino}"


class UserItinerario(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    itinerario = models.ForeignKey(Itinerario, on_delete=models.CASCADE)

    class Meta:
        unique_together = (('user', 'itinerario'),)
        db_table = 'aeroporto_useritinerario'

    def __str__(self):
        return f"{self.user.username} -> Itinerario {self.itinerario.id}"


class UserAssistenteDiVolo(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    assistente = models.ForeignKey(AssistenteDiVolo, on_delete=models.CASCADE)

    class Meta:
        unique_together = (('user', 'assistente'),)
        db_table = 'aeroporto_userassistentedivolo'

    def __str__(self):
        return f"{self.user.username} -> Assistente {self.assistente.codice_fiscale} {self.assistente.nome} {self.assistente.cognome}"
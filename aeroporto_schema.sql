USE aeroporto;

CREATE TABLE Gate (
  Numero int NOT NULL,
  Terminal varchar(20) NOT NULL,
  Tipo enum('Trasporto merci','Passeggeri') NOT NULL,
  Lunghezza double NOT NULL,
  PRIMARY KEY (Numero, Terminal),
  CHECK (Numero > 0),
  CHECK (Lunghezza > 0)
);

CREATE TABLE Itinerario (
  ID int NOT NULL AUTO_INCREMENT,
  Data_inizio date NOT NULL,
  Data_fine date NOT NULL,
  Destinazione varchar(100) NOT NULL,
  Prezzo decimal(20,2) NOT NULL,
  PRIMARY KEY (ID),
  CHECK (Data_inizio <= Data_fine),
  CHECK (Prezzo > 0)
);

CREATE TABLE Passeggero (
  Codice_fiscale char(16) NOT NULL,
  Nome varchar(100) NOT NULL,
  Cognome varchar(100) NOT NULL,
  Data_nascita date NOT NULL,
  Telefono varchar(20) DEFAULT NULL,
  PRIMARY KEY (Codice_fiscale)
);

CREATE TABLE Aereo (
  Codice_ICAO varchar(10) NOT NULL,
  Modello varchar(100) NOT NULL,
  Compagnia varchar(100) NOT NULL,
  Latitudine double NOT NULL DEFAULT 0,
  Longitudine double NOT NULL DEFAULT 0,
  Lunghezza double NOT NULL,
  Altezza double NOT NULL,
  Apertura_alare double NOT NULL,
  Tipo enum('Trasporto merci','Passeggeri') NOT NULL,
  Capacita int DEFAULT NULL,
  Peso_Max double DEFAULT NULL,
  Peso_occupato double DEFAULT NULL,
  Volume_occupato double DEFAULT NULL,
  Capienza int DEFAULT NULL,
  Numero_gate int DEFAULT NULL,
  Terminal_gate varchar(20) DEFAULT NULL,
  ID_itinerario int DEFAULT NULL,
  PRIMARY KEY (Codice_ICAO),
  FOREIGN KEY (Numero_gate, Terminal_gate) REFERENCES Gate (Numero, Terminal) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (ID_itinerario) REFERENCES Itinerario (ID) ON DELETE SET NULL ON UPDATE CASCADE,
  CHECK (Lunghezza > 0 AND Altezza > 0 AND Apertura_alare > 0),
  CHECK ((Latitudine BETWEEN -90 AND 90) AND (Longitudine BETWEEN -180 AND 180)),
  CHECK ((Peso_Max IS NULL OR Peso_Max > 0) AND (Capacita IS NULL OR Capacita > 0)),
  CHECK (Capienza IS NULL OR Capienza > 0),
  CHECK ((Tipo = 'Trasporto merci' AND Capienza IS NULL) OR (Tipo = 'Passeggeri' AND Capienza IS NOT NULL)),
  CHECK ((Tipo = 'Passeggeri' AND Peso_Max IS NULL AND Capacita IS NULL) OR (Tipo = 'Trasporto merci' AND Peso_Max IS NOT NULL AND Capacita IS NOT NULL)),
  CHECK (Peso_Max IS NULL OR Peso_occupato IS NULL OR Peso_occupato <= Peso_Max),
  CHECK (Capacita IS NULL OR Volume_occupato IS NULL OR Volume_occupato <= Capacita)
);

CREATE TABLE Container_Aereo (
  ID char(11) NOT NULL,
  Capacita double NOT NULL,
  Compagnia_logistica varchar(100) NOT NULL,
  Peso double NOT NULL,
  Codice_ICAO varchar(10) DEFAULT NULL,
  Data_inizio date NOT NULL,
  Data_fine date NOT NULL,
  Destinazione varchar(100) NOT NULL,
  PRIMARY KEY (ID),
  FOREIGN KEY (Codice_ICAO) REFERENCES Aereo (Codice_ICAO) ON DELETE SET NULL ON UPDATE CASCADE,
  CHECK (Capacita > 0 AND Peso >= 0),
  CHECK (regexp_like(ID, '^[A-Z]{4}[0-9]{7}$')),
  CHECK (Data_inizio <= Data_fine)
);

CREATE TABLE Merce (
  SSCC char(18) NOT NULL,
  Peso double NOT NULL,
  Paese varchar(50) NOT NULL,
  Categoria varchar(100) NOT NULL,
  ID_container char(11) DEFAULT NULL,
  PRIMARY KEY (SSCC),
  FOREIGN KEY (ID_container) REFERENCES Container_Aereo (ID) ON DELETE SET NULL ON UPDATE CASCADE,
  CHECK (Peso > 0),
  CHECK (regexp_like(SSCC, '^[0-9]{18}$'))
);

CREATE TABLE Magazzino_aeroportuale (
  Nome varchar(100) NOT NULL,
  Posizione varchar(100) NOT NULL,
  Tipo varchar(100) NOT NULL,
  Capacita double NOT NULL,
  PRIMARY KEY (Nome, Posizione),
  CHECK (Capacita > 0)
);

CREATE TABLE Stoccaggio (
  SSCC char(18) NOT NULL,
  Nome_magazzino varchar(100) NOT NULL,
  Posizione_magazzino varchar(100) NOT NULL,
  PRIMARY KEY (SSCC),
  FOREIGN KEY (Nome_magazzino, Posizione_magazzino) REFERENCES Magazzino_aeroportuale (Nome, Posizione) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (SSCC) REFERENCES Merce (SSCC) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Scali (
  ID_itinerario int NOT NULL,
  Nome_scalo varchar(100) NOT NULL,
  PRIMARY KEY (ID_itinerario, Nome_scalo),
  FOREIGN KEY (ID_itinerario) REFERENCES Itinerario (ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Assistente_di_volo (
  Codice_fiscale char(16) NOT NULL,
  Nome varchar(100) NOT NULL,
  Cognome varchar(100) NOT NULL,
  Data_nascita date NOT NULL,
  Numero_licenza int NOT NULL,
  Stipendio decimal(20,2) NOT NULL,
  Data_assunzione date NOT NULL,
  Valutazione decimal(2,1) NOT NULL,
  ID_itinerario int DEFAULT NULL,
  PRIMARY KEY (Codice_fiscale),
  UNIQUE KEY (Numero_licenza),
  FOREIGN KEY (ID_itinerario) REFERENCES Itinerario (ID) ON DELETE SET NULL ON UPDATE CASCADE,
  CHECK (Stipendio > 0),
  CHECK (Numero_licenza > 0),
  CHECK (Valutazione BETWEEN 1 AND 5),
  CHECK (((to_days(Data_assunzione) - to_days(Data_nascita)) / 365.25) >= 18)
);

CREATE TABLE Lingua (
  Codice_fiscale char(16) NOT NULL,
  Lingua varchar(50) NOT NULL,
  Livello enum('A1','A2','B1','B2','C1','C2','Nativa') NOT NULL,
  PRIMARY KEY (Codice_fiscale, Lingua),
  FOREIGN KEY (Codice_fiscale) REFERENCES Assistente_di_volo (Codice_fiscale) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Posto (
  Codice_ICAO varchar(10) NOT NULL,
  Numero int NOT NULL,
  Classe enum('Economy','Business','First Class') NOT NULL,
  Tipologia enum('Finestrino','Centrale','Corridoio') NOT NULL,
  PRIMARY KEY (Codice_ICAO, Numero),
  FOREIGN KEY (Codice_ICAO) REFERENCES Aereo (Codice_ICAO) ON DELETE CASCADE ON UPDATE CASCADE,
  CHECK (Numero > 0)
);

CREATE TABLE Prenotazione (
  ID int NOT NULL AUTO_INCREMENT,
  Codice_ICAO varchar(10) NOT NULL,
  Numero int NOT NULL,
  Codice_fiscale char(16) NOT NULL,
  Data_inizio date NOT NULL,
  Scadenza date NOT NULL,
  Bagaglio_extra tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (ID),
  FOREIGN KEY (Codice_ICAO, Numero) REFERENCES Posto (Codice_ICAO, Numero) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (Codice_fiscale) REFERENCES Passeggero (Codice_fiscale) ON DELETE CASCADE ON UPDATE CASCADE,
  CHECK (Data_inizio <= Scadenza)
);

USE aeroporto;

DROP TRIGGER IF EXISTS elimina_merce_non_stoccata;
DROP TRIGGER IF EXISTS aggiorna_prenotazioni;
DROP TRIGGER IF EXISTS cancella_prenotazione;
DROP TRIGGER IF EXISTS controlla_aggiornamento_tipo_magazzino;
DROP TRIGGER IF EXISTS inizializzazione_contatori_aereo;
DROP TRIGGER IF EXISTS rimuovi_prenotazioni;

DELIMITER $$
CREATE TRIGGER elimina_merce_non_stoccata AFTER DELETE ON Container_Aereo
FOR EACH ROW
BEGIN
    DELETE Merce
    FROM Merce
    LEFT JOIN Stoccaggio ON Merce.SSCC = Stoccaggio.SSCC
    WHERE Merce.ID_container = OLD.ID
      AND Stoccaggio.Nome_magazzino IS NULL;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER aggiorna_prenotazioni AFTER UPDATE ON Itinerario
FOR EACH ROW
BEGIN
IF NEW.Data_inizio <> OLD.Data_inizio OR NEW.Data_fine <> OLD.Data_fine THEN
UPDATE Prenotazione
SET Data_inizio = NEW.Data_inizio, Scadenza = NEW.Data_fine
WHERE Codice_ICAO IN (SELECT Codice_ICAO FROM Aereo WHERE ID_itinerario = NEW.ID);
END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER cancella_prenotazione BEFORE DELETE ON Itinerario
FOR EACH ROW
BEGIN
DELETE Prenotazione
FROM Aereo JOIN Prenotazione ON Prenotazione.Codice_ICAO = Aereo.Codice_ICAO
WHERE Aereo.ID_itinerario = OLD.ID;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER controlla_aggiornamento_tipo_magazzino BEFORE UPDATE ON Magazzino_aeroportuale
FOR EACH ROW
BEGIN
DECLARE numero_riferimenti INT;
IF UPPER(NEW.Tipo) <> UPPER(OLD.Tipo) THEN
SELECT COUNT(Stoccaggio.SSCC)
INTO numero_riferimenti
FROM Stoccaggio
WHERE Stoccaggio.Nome_magazzino = OLD.Nome AND Stoccaggio.Posizione_magazzino = OLD.Posizione;
IF numero_riferimenti > 0 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Non risulta consentito modificare il tipo di un magazzino contenente delle merci';
END IF;
END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER inizializzazione_contatori_aereo BEFORE INSERT ON Aereo
FOR EACH ROW
BEGIN
IF NEW.Tipo='Trasporto merci' THEN
SET NEW.Peso_occupato=0, NEW.Volume_occupato=0;
END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER rimuovi_prenotazioni AFTER UPDATE ON Aereo
FOR EACH ROW
BEGIN
IF NOT(OLD.ID_itinerario <=> NEW.ID_itinerario) AND OLD.ID_itinerario IS NOT NULL THEN
DELETE
FROM Prenotazione
WHERE Codice_ICAO = NEW.Codice_ICAO;
END IF;
END $$
DELIMITER ;

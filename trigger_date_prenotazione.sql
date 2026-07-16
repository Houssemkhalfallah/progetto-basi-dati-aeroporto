USE aeroporto;

DROP TRIGGER IF EXISTS controllo_scadenza_prenotazione;
DROP TRIGGER IF EXISTS controllo_scadenza_prenotazione2;

DELIMITER $$
CREATE TRIGGER controllo_date_prenotazione BEFORE INSERT ON Prenotazione
FOR EACH ROW
BEGIN
DECLARE inizio DATE;
DECLARE fine DATE;
SELECT Itinerario.Data_inizio, Itinerario.Data_fine
INTO inizio, fine
FROM Aereo JOIN Itinerario ON Aereo.ID_itinerario = Itinerario.ID
WHERE Aereo.Codice_ICAO=NEW.Codice_ICAO;
IF NEW.Data_inizio < inizio OR NEW.Scadenza > fine THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Le date non sono valide per l''itinerario prenotato';
ELSEIF EXISTS(
SELECT *
FROM Prenotazione
WHERE Codice_ICAO=NEW.Codice_ICAO AND Numero=NEW.Numero AND NOT(NEW.Data_inizio>=Scadenza OR NEW.Scadenza<=Data_inizio)) THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Il posto selezionato risulta prenotato per questo intervallo di tempo';
END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER controllo_date_prenotazione2 BEFORE UPDATE ON Prenotazione
FOR EACH ROW
BEGIN
DECLARE inizio DATE;
DECLARE fine DATE;
IF NEW.Data_inizio < OLD.Data_inizio OR NEW.Scadenza > OLD.Scadenza OR NEW.Codice_ICAO <> OLD.Codice_ICAO OR NEW.Numero <> OLD.Numero THEN
SELECT Itinerario.Data_inizio, Itinerario.Data_fine
INTO inizio, fine
FROM Aereo JOIN Itinerario ON Aereo.ID_itinerario = Itinerario.ID
WHERE Aereo.Codice_ICAO=NEW.Codice_ICAO;
IF NEW.Data_inizio < inizio OR NEW.Scadenza > fine THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Le date non sono valide per l''itinerario prenotato';
ELSEIF EXISTS(
SELECT *
FROM Prenotazione
WHERE Codice_ICAO=NEW.Codice_ICAO AND Numero=NEW.Numero AND NOT(NEW.Data_inizio>=Scadenza OR NEW.Scadenza<=Data_inizio) AND ID <> OLD.ID) THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Il posto selezionato risulta prenotato per questo intervallo di tempo';
END IF;
END IF;
END $$
DELIMITER ;

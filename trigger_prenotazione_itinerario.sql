USE aeroporto;

DELIMITER $$
CREATE TRIGGER controllo_scadenza_prenotazione BEFORE INSERT ON Prenotazione
FOR EACH ROW
BEGIN
DECLARE fine DATE;
SELECT Itinerario.Data_fine
INTO fine
FROM Aereo JOIN Itinerario ON Aereo.ID_itinerario = Itinerario.ID
WHERE Aereo.Codice_ICAO=NEW.Codice_ICAO;
IF NEW.Scadenza > fine THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='La scadenza della prenotazione non puo superare la data di fine dell''itinerario';
END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER controllo_itinerario_prenotazione BEFORE INSERT ON Prenotazione
FOR EACH ROW
BEGIN
DECLARE itinerario INT;
SELECT ID_itinerario
INTO itinerario
FROM Aereo
WHERE Codice_ICAO=NEW.Codice_ICAO;
IF itinerario IS NULL THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT="Non risulta possibile prenotare un posto su un aereo senza itinerario";
END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER controllo_scadenza_prenotazione2 BEFORE UPDATE ON Prenotazione
FOR EACH ROW
BEGIN
DECLARE fine DATE;
IF NEW.Scadenza <> OLD.Scadenza OR NEW.Codice_ICAO <> OLD.Codice_ICAO THEN
SELECT Itinerario.Data_fine
INTO fine
FROM Aereo JOIN Itinerario ON Aereo.ID_itinerario = Itinerario.ID
WHERE Aereo.Codice_ICAO=NEW.Codice_ICAO;
IF NEW.Scadenza > fine THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='La scadenza della prenotazione non puo superare la data di fine dell''itinerario';
END IF;
END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER controllo_itinerario_prenotazione2 BEFORE UPDATE ON Prenotazione
FOR EACH ROW
BEGIN
DECLARE itinerario INT;
IF NEW.Codice_ICAO <> OLD.Codice_ICAO THEN
SELECT ID_itinerario
INTO itinerario
FROM Aereo
WHERE Codice_ICAO=NEW.Codice_ICAO;
IF itinerario IS NULL THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT="Non risulta possibile prenotare un posto su un aereo senza itinerario";
END IF;
END IF;
END $$
DELIMITER ;

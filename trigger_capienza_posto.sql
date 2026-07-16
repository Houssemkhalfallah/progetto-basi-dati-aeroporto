USE aeroporto;

DELIMITER $$
CREATE TRIGGER controllo_tipo_aereo_posto BEFORE INSERT ON Posto
FOR EACH ROW
BEGIN
DECLARE tipo_aereo VARCHAR(15);
SELECT Tipo
INTO tipo_aereo
FROM Aereo
WHERE Aereo.Codice_ICAO=NEW.Codice_ICAO;
IF tipo_aereo <> 'Passeggeri' THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Questo tipo di aereo non viene suddiviso in posti';
END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER controllo_capienza_aereo BEFORE INSERT ON Posto
FOR EACH ROW
BEGIN
DECLARE capienza_aereo INT;
DECLARE numero_posti INT;
SELECT Capienza
INTO capienza_aereo
FROM Aereo
WHERE Aereo.Codice_ICAO = NEW.Codice_ICAO;
SELECT COUNT(*)
INTO numero_posti
FROM Posto
WHERE Codice_ICAO = NEW.Codice_ICAO;
IF numero_posti+1 > capienza_aereo THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='L''aereo non ha abbastanza capienza';
END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER controllo_tipo_aereo_posto2 BEFORE UPDATE ON Posto
FOR EACH ROW
BEGIN
DECLARE tipo_aereo VARCHAR(15);
IF NEW.Codice_ICAO <> OLD.Codice_ICAO THEN
SELECT Tipo
INTO tipo_aereo
FROM Aereo
WHERE Aereo.Codice_ICAO=NEW.Codice_ICAO;
IF tipo_aereo <> 'Passeggeri' THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Questo tipo di aereo non viene suddiviso in posti';
END IF;
END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER controllo_capienza_aereo2 BEFORE UPDATE ON Posto
FOR EACH ROW
BEGIN
DECLARE capienza_aereo INT;
DECLARE numero_posti INT;
IF NEW.Codice_ICAO <> OLD.Codice_ICAO THEN
SELECT Capienza
INTO capienza_aereo
FROM Aereo
WHERE Aereo.Codice_ICAO = NEW.Codice_ICAO;
SELECT COUNT(*)
INTO numero_posti
FROM Posto
WHERE Codice_ICAO = NEW.Codice_ICAO;
IF numero_posti+1 > capienza_aereo THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='L''aereo non ha abbastanza capienza';
END IF;
END IF;
END $$
DELIMITER ;

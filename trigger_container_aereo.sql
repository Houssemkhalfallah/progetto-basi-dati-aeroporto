USE aeroporto;

DELIMITER $$
CREATE TRIGGER controllo_peso_e_capacita BEFORE INSERT ON Container_Aereo
FOR EACH ROW
BEGIN
    DECLARE peso_max DOUBLE;
    DECLARE peso_occ DOUBLE;
    DECLARE cap_max INT;
    DECLARE volume_occ INT;

    SELECT Peso_Max, Peso_occupato, Capacita, Volume_occupato
    INTO peso_max, peso_occ, cap_max, volume_occ
    FROM Aereo
    WHERE Codice_ICAO = NEW.Codice_ICAO;

    IF peso_occ + NEW.Peso > peso_max OR volume_occ + NEW.Capacita > cap_max THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Il container non entra sull''aereo selezionato';
    ELSE
        UPDATE Aereo
        SET Peso_occupato = Peso_occupato + NEW.Peso,
            Volume_occupato = Volume_occupato + NEW.Capacita
        WHERE Codice_ICAO = NEW.Codice_ICAO;
    END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER controllo_tipo_aereo_container BEFORE INSERT ON Container_Aereo
FOR EACH ROW
BEGIN
DECLARE tipo_aereo VARCHAR(15);
SELECT Tipo
INTO tipo_aereo
FROM Aereo
WHERE Codice_ICAO = NEW.Codice_ICAO;
IF tipo_aereo <> 'Trasporto merci' THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Questo tipo di aereo non trasporta container';
END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER aggiornamento_peso_e_capacita BEFORE UPDATE ON Container_Aereo
FOR EACH ROW
BEGIN
DECLARE peso_occ DOUBLE;
DECLARE peso_max DOUBLE;
DECLARE volume_occ INT;
DECLARE capacita INT;
SELECT Peso_occupato, Peso_Max, Volume_occupato, Capacita
INTO peso_occ, peso_max, volume_occ, capacita
FROM Aereo
WHERE Aereo.Codice_ICAO = NEW.Codice_ICAO;
IF OLD.Codice_ICAO = NEW.Codice_ICAO THEN
IF peso_occ+NEW.Peso-OLD.Peso>peso_max OR volume_occ+NEW.Capacita-OLD.Capacita>capacita THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Il container non entra sull''aereo selezionato';
ELSE
UPDATE Aereo
SET Peso_occupato=Peso_occupato+NEW.Peso-OLD.Peso, Volume_occupato=Volume_occupato+NEW.Capacita-OLD.Capacita
WHERE Aereo.Codice_ICAO = NEW.Codice_ICAO;
END IF;
ELSE
IF peso_occ+NEW.Peso>peso_max OR volume_occ+NEW.Capacita>capacita THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Il container non entra sull''aereo selezionato';
ELSE
UPDATE Aereo
SET Peso_occupato=Peso_occupato+NEW.Peso, Volume_occupato=Volume_occupato+NEW.Capacita
WHERE Aereo.Codice_ICAO = NEW.Codice_ICAO;
UPDATE Aereo
SET Peso_occupato=Peso_occupato-OLD.Peso, Volume_occupato=Volume_occupato-OLD.Capacita
WHERE Aereo.Codice_ICAO = OLD.Codice_ICAO;
END IF;
END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER controllo_tipo_aereo_container2 BEFORE UPDATE ON Container_Aereo
FOR EACH ROW
BEGIN
DECLARE tipo_aereo VARCHAR(15);
IF OLD.Codice_ICAO <> NEW.Codice_ICAO THEN
SELECT Tipo
INTO tipo_aereo
FROM Aereo
WHERE Codice_ICAO = NEW.Codice_ICAO;
IF tipo_aereo <> 'Trasporto merci' THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Questo tipo di aereo non trasporta container';
END IF;
END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER liberazione_peso_e_capacita AFTER DELETE ON Container_Aereo
FOR EACH ROW
BEGIN
    UPDATE Aereo
    SET Peso_occupato = Peso_occupato - OLD.Peso,
        Volume_occupato = Volume_occupato - OLD.Capacita
    WHERE Codice_ICAO = OLD.Codice_ICAO;
END $$
DELIMITER ;

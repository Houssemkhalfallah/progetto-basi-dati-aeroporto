USE aeroporto;

DELIMITER $$
CREATE TRIGGER controllo_assistenti_itinerario BEFORE INSERT ON Aereo
FOR EACH ROW
BEGIN
    DECLARE numero_assistenti INT;

    IF NEW.Tipo = 'Passeggeri' AND NEW.ID_itinerario IS NOT NULL THEN

        SELECT COUNT(Codice_fiscale)
        INTO numero_assistenti
        FROM Assistente_di_volo
        WHERE Assistente_di_volo.ID_itinerario = NEW.ID_itinerario;

        IF numero_assistenti <> 6 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ci devono essere 6 assistenti di volo per ogni itinerario';
        END IF;

    END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER controllo_tipo_aereo_itinerario BEFORE INSERT ON Aereo
FOR EACH ROW
BEGIN
IF NEW.Tipo='Trasporto merci' AND NEW.ID_itinerario IS NOT NULL THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Gli itinerari non possono essere assegnati agli aerei trasporto merci';
END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER controllo_assistenti_itinerario2 BEFORE UPDATE ON Aereo
FOR EACH ROW
BEGIN
DECLARE numero_assistenti INT;
IF NOT(NEW.ID_itinerario <=> OLD.ID_itinerario) AND NEW.ID_itinerario IS NOT NULL THEN
SELECT COUNT(Codice_fiscale)
INTO numero_assistenti
FROM Assistente_di_volo
WHERE ID_itinerario=NEW.ID_itinerario;
IF numero_assistenti <> 6 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Ci devono essere 6 assistenti di volo per ogni itinerario';
END IF;
END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER controllo_tipo_aereo_itinerario2 BEFORE UPDATE ON Aereo
FOR EACH ROW
BEGIN
IF NEW.Tipo='Trasporto merci' AND NEW.ID_itinerario IS NOT NULL THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Gli itinerari non possono essere assegnati agli aerei trasporto merci';
END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER controllo_itinerario_assistente BEFORE INSERT ON Assistente_di_volo
FOR EACH ROW
BEGIN
DECLARE numero_assistenti INT;
SELECT COUNT(Codice_fiscale)
INTO numero_assistenti
FROM Assistente_di_volo
WHERE ID_itinerario=NEW.ID_itinerario;
IF numero_assistenti>=6 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Non si possono inserire piu di 6 assistenti di volo per itinerario';
END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER controllo_itinerario_assistente2 BEFORE UPDATE ON Assistente_di_volo
FOR EACH ROW
BEGIN
DECLARE numero_assistenti INT;
IF NOT(OLD.ID_itinerario <=> NEW.ID_itinerario) AND NEW.ID_itinerario IS NOT NULL THEN
SELECT COUNT(Codice_fiscale)
INTO numero_assistenti
FROM Assistente_di_volo
WHERE ID_itinerario=NEW.ID_itinerario;
IF numero_assistenti>=6 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Non si possono inserire piu di 6 assistenti di volo per itinerario';
END IF;
END IF;
END $$
DELIMITER ;

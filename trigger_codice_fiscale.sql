USE aeroporto;

DROP TRIGGER IF EXISTS controllo_codice_fiscale_passeggero;
DROP TRIGGER IF EXISTS controllo_codice_fiscale_passeggero2;
DROP TRIGGER IF EXISTS controllo_codice_fiscale_assistente;
DROP TRIGGER IF EXISTS controllo_codice_fiscale_assistente2;

DELIMITER $$
CREATE TRIGGER controllo_codice_fiscale_passeggero BEFORE INSERT ON Passeggero
FOR EACH ROW
BEGIN
IF NEW.Codice_fiscale IN (SELECT Codice_fiscale FROM Assistente_di_volo) THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT="Questo codice fiscale appartiene ad un assistente di volo";
END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER controllo_codice_fiscale_passeggero2 BEFORE UPDATE ON Passeggero
FOR EACH ROW
BEGIN
IF NEW.Codice_fiscale <> OLD.Codice_fiscale THEN
IF NEW.Codice_fiscale IN (SELECT Codice_fiscale FROM Assistente_di_volo) THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT="Questo codice fiscale appartiene ad un assistente di volo";
END IF;
END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER controllo_codice_fiscale_assistente BEFORE INSERT ON Assistente_di_volo
FOR EACH ROW
BEGIN
IF NEW.Codice_fiscale IN (SELECT Codice_fiscale FROM Passeggero) THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT="Questo codice fiscale appartiene ad un passeggero";
END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER controllo_codice_fiscale_assistente2 BEFORE UPDATE ON Assistente_di_volo
FOR EACH ROW
BEGIN
IF NEW.Codice_fiscale <> OLD.Codice_fiscale THEN
IF NEW.Codice_fiscale IN (SELECT Codice_fiscale FROM Passeggero) THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT="Questo codice fiscale appartiene ad un passeggero";
END IF;
END IF;
END $$
DELIMITER ;

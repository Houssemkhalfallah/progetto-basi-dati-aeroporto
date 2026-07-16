USE aeroporto;

DELIMITER $$
CREATE TRIGGER aggiorna_peso_container AFTER INSERT ON Merce
FOR EACH ROW
BEGIN UPDATE Container_Aereo SET Container_Aereo.Peso=Container_Aereo.Peso+NEW.Peso WHERE Container_Aereo.ID=NEW.ID_container; END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER controllo_aggiornamento_tipo_merce BEFORE UPDATE ON Merce
FOR EACH ROW
BEGIN
DECLARE tipo_magazzino VARCHAR(100);
SELECT Magazzino_aeroportuale.Tipo
INTO tipo_magazzino
FROM Stoccaggio JOIN Magazzino_aeroportuale ON Stoccaggio.Nome_magazzino=Magazzino_aeroportuale.Nome AND Stoccaggio.Posizione_magazzino=Magazzino_aeroportuale.Posizione
WHERE Stoccaggio.SSCC=NEW.SSCC;
IF UPPER(NEW.Categoria) <> UPPER(tipo_magazzino) THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='La merce risulta stoccata in un magazzino di tipo incompatibile';
END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER controllo_capacita_magazzino3 BEFORE UPDATE ON Merce
FOR EACH ROW
BEGIN
DECLARE nome VARCHAR(100);
DECLARE posizione VARCHAR(100);
DECLARE peso_totale DOUBLE;
DECLARE capacita_magazzino DOUBLE;
IF OLD.Peso <> NEW.Peso THEN
SELECT Nome_magazzino, Posizione_magazzino
INTO nome, posizione
FROM Stoccaggio
WHERE Stoccaggio.SSCC=NEW.SSCC;
IF nome IS NOT NULL AND posizione IS NOT NULL THEN
SELECT COALESCE(SUM(Merce.Peso),0)
INTO peso_totale
FROM Merce JOIN Stoccaggio ON Merce.SSCC = Stoccaggio.SSCC
WHERE Stoccaggio.Nome_magazzino = nome AND Stoccaggio.Posizione_magazzino = posizione;
SELECT Capacita
INTO capacita_magazzino
FROM Magazzino_aeroportuale
WHERE Magazzino_aeroportuale.Nome = nome AND Magazzino_aeroportuale.Posizione = posizione;
IF peso_totale + NEW.Peso - OLD.Peso > capacita_magazzino THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Il magazzino non ha abbastanza capacita per stoccare questa merce';
END IF;
END IF;
END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER aggiorna_peso_container2 AFTER UPDATE ON Merce
FOR EACH ROW
BEGIN
    IF NEW.ID_container = OLD.ID_container THEN
        UPDATE Container_Aereo
        SET Peso = Peso + NEW.Peso - OLD.Peso
        WHERE ID = NEW.ID_container;
    ELSE
        UPDATE Container_Aereo
        SET Peso = Peso - OLD.Peso
        WHERE ID = OLD.ID_container;

        UPDATE Container_Aereo
        SET Peso = Peso + NEW.Peso
        WHERE ID = NEW.ID_container;
    END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER aggiorna_peso_container3 AFTER DELETE ON Merce
FOR EACH ROW
BEGIN UPDATE Container_Aereo SET Container_Aereo.Peso=Container_Aereo.Peso-OLD.Peso WHERE Container_Aereo.ID=OLD.ID_container; END $$
DELIMITER ;

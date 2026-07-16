USE aeroporto;

DELIMITER $$
CREATE TRIGGER controlla_tipo_merce_e_magazzino BEFORE INSERT ON Stoccaggio
FOR EACH ROW
BEGIN
    DECLARE tipo_merce VARCHAR(100);
    DECLARE tipo_magazzino VARCHAR(100);

    SELECT Categoria
    INTO tipo_merce
    FROM Merce
    WHERE Merce.SSCC = NEW.SSCC;

    SELECT Tipo
    INTO tipo_magazzino
    FROM Magazzino_aeroportuale
    WHERE Magazzino_aeroportuale.Nome = NEW.Nome_magazzino
      AND Magazzino_aeroportuale.Posizione = NEW.Posizione_magazzino;

    IF UPPER(tipo_merce) <> UPPER(tipo_magazzino) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Il magazzino selezionato non stocca questo tipo di merce';
    END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER controllo_capacita_magazzino BEFORE INSERT ON Stoccaggio
FOR EACH ROW
BEGIN
DECLARE peso_totale DOUBLE;
DECLARE nuovo_peso DOUBLE;
DECLARE capacita_magazzino DOUBLE;
SELECT COALESCE(SUM(Merce.Peso),0)
INTO peso_totale
FROM Merce JOIN Stoccaggio ON Merce.SSCC = Stoccaggio.SSCC
WHERE Stoccaggio.Nome_magazzino = NEW.Nome_magazzino AND Stoccaggio.Posizione_magazzino = NEW.Posizione_magazzino;
SELECT Merce.Peso
INTO nuovo_peso
FROM Merce
WHERE Merce.SSCC=NEW.SSCC;
SELECT Capacita
INTO capacita_magazzino
FROM Magazzino_aeroportuale
WHERE Magazzino_aeroportuale.Nome=NEW.Nome_magazzino AND Magazzino_aeroportuale.Posizione=NEW.Posizione_magazzino;
IF peso_totale+nuovo_peso > capacita_magazzino THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Il magazzino non ha abbastanza capacita per stoccare questa merce';
END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER controlla_tipo_merce_e_magazzino2 BEFORE UPDATE ON Stoccaggio
FOR EACH ROW
BEGIN
DECLARE tipo_merce VARCHAR(100);
DECLARE tipo_magazzino VARCHAR(100);
SELECT Categoria INTO tipo_merce
FROM Merce
WHERE Merce.SSCC=NEW.SSCC;
SELECT Tipo INTO tipo_magazzino
FROM Magazzino_aeroportuale
WHERE NEW.Nome_magazzino=Magazzino_aeroportuale.Nome AND NEW.Posizione_magazzino=Magazzino_aeroportuale.Posizione;
IF UPPER(tipo_merce) <> UPPER(tipo_magazzino) THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Il magazzino selezionato non stocca questo tipo di merce';
END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER controllo_capacita_magazzino2 BEFORE UPDATE ON Stoccaggio
FOR EACH ROW
BEGIN
    DECLARE peso_totale DOUBLE;
    DECLARE nuovo_peso DOUBLE;
    DECLARE capacita_magazzino DOUBLE;

    SELECT Merce.Peso
    INTO nuovo_peso
    FROM Merce
    WHERE Merce.SSCC = NEW.SSCC;

    SELECT COALESCE(SUM(Merce.Peso),0)
    INTO peso_totale
    FROM Merce
    JOIN Stoccaggio ON Merce.SSCC = Stoccaggio.SSCC
    WHERE Stoccaggio.Nome_magazzino = NEW.Nome_magazzino
      AND Stoccaggio.Posizione_magazzino = NEW.Posizione_magazzino
      AND Merce.SSCC <> OLD.SSCC;

    SELECT Capacita
    INTO capacita_magazzino
    FROM Magazzino_aeroportuale
    WHERE Magazzino_aeroportuale.Nome = NEW.Nome_magazzino
      AND Magazzino_aeroportuale.Posizione = NEW.Posizione_magazzino;

    IF peso_totale + nuovo_peso > capacita_magazzino THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Il magazzino non ha abbastanza capacita per stoccare questa merce';
    END IF;
END $$
DELIMITER ;

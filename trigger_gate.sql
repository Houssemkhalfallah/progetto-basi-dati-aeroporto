USE aeroporto;

DELIMITER $$
CREATE TRIGGER controllo_gate BEFORE INSERT ON Aereo
FOR EACH ROW
BEGIN
DECLARE tipo_gate VARCHAR(15);
DECLARE lunghezza_gate DOUBLE;
SELECT Tipo, Lunghezza
INTO tipo_gate, lunghezza_gate
FROM Gate
WHERE Numero=NEW.Numero_gate AND Terminal=NEW.Terminal_gate;
IF NEW.Tipo <> tipo_gate THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Il tipo di gate non risulta compatibile con il tipo di aereo';
ELSEIF NEW.Lunghezza > lunghezza_gate THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Il gate non ha lunghezza sufficiente per questo aereo';
END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER controllo_gate2 BEFORE UPDATE ON Aereo
FOR EACH ROW
BEGIN
DECLARE tipo_gate VARCHAR(15);
DECLARE lunghezza_gate DOUBLE;
IF NEW.Numero_gate <> OLD.Numero_gate OR NEW.Terminal_gate <> OLD.Terminal_gate OR NEW.Lunghezza <> OLD.Lunghezza THEN
SELECT Tipo, Lunghezza
INTO tipo_gate, lunghezza_gate
FROM Gate
WHERE Numero=NEW.Numero_gate AND Terminal=NEW.Terminal_gate;
IF NEW.Tipo <> tipo_gate THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Il tipo di gate non risulta compatibile con il tipo di aereo';
ELSEIF NEW.Lunghezza > lunghezza_gate THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT='Il gate non ha lunghezza sufficiente per questo aereo';
END IF;
END IF;
END $$
DELIMITER ;

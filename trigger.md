# Trigger del database `aeroporto`

Totale trigger: **34**

## 1. `controllo_peso_e_capacita`

| Campo | Valore |
|---|---|
| Tabella | `Container_Aereo` |
| Evento | `INSERT` |
| Timing | `BEFORE` |
| Funzione | Controlla che il container entri nell'aereo in base a peso e capacità disponibili. |

```sql
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
```

## 2. `controllo_tipo_aereo_container`

| Campo | Valore |
|---|---|
| Tabella | `Container_Aereo` |
| Evento | `INSERT` |
| Timing | `BEFORE` |
| Funzione | Verifica che i container possano essere inseriti solo su aerei di tipo Trasporto merci. |

```sql
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
```

## 3. `aggiornamento_peso_e_capacita`

| Campo | Valore |
|---|---|
| Tabella | `Container_Aereo` |
| Evento | `UPDATE` |
| Timing | `BEFORE` |
| Funzione | Aggiorna peso e volume occupati dell'aereo quando viene modificato un container. |

```sql
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
```

## 4. `controllo_tipo_aereo_container2`

| Campo | Valore |
|---|---|
| Tabella | `Container_Aereo` |
| Evento | `UPDATE` |
| Timing | `BEFORE` |
| Funzione | Controlla, in caso di modifica, che il container venga assegnato solo a un aereo Trasporto merci. |

```sql
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
```

## 5. `liberazione_peso_e_capacita`

| Campo | Valore |
|---|---|
| Tabella | `Container_Aereo` |
| Evento | `DELETE` |
| Timing | `AFTER` |
| Funzione | Libera peso e volume occupati sull'aereo quando viene eliminato un container. |

```sql
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
```

## 6. `controllo_assistenti_itinerario`

| Campo | Valore |
|---|---|
| Tabella | `Aereo` |
| Evento | `INSERT` |
| Timing | `BEFORE` |
| Funzione | Controlla che un aereo passeggeri con itinerario abbia esattamente 6 assistenti di volo associati. |

```sql
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
```

## 7. `controllo_tipo_aereo_itinerario`

| Campo | Valore |
|---|---|
| Tabella | `Aereo` |
| Evento | `INSERT` |
| Timing | `BEFORE` |
| Funzione | Impedisce di assegnare un itinerario a un aereo trasporto merci. |

```sql
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
```

## 8. `controllo_assistenti_itinerario2`

| Campo | Valore |
|---|---|
| Tabella | `Aereo` |
| Evento | `UPDATE` |
| Timing | `BEFORE` |
| Funzione | Controlla che, in caso di modifica dell'itinerario, siano presenti 6 assistenti di volo associati. |

```sql
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
```

## 9. `controllo_tipo_aereo_itinerario2`

| Campo | Valore |
|---|---|
| Tabella | `Aereo` |
| Evento | `UPDATE` |
| Timing | `BEFORE` |
| Funzione | Impedisce di assegnare un itinerario a un aereo trasporto merci durante una modifica. |

```sql
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
```

## 10. `controllo_itinerario_assistente`

| Campo | Valore |
|---|---|
| Tabella | `Assistente_di_volo` |
| Evento | `INSERT` |
| Timing | `BEFORE` |
| Funzione | Impedisce di inserire più di 6 assistenti di volo per lo stesso itinerario. |

```sql
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
```

## 11. `controllo_itinerario_assistente2`

| Campo | Valore |
|---|---|
| Tabella | `Assistente_di_volo` |
| Evento | `UPDATE` |
| Timing | `BEFORE` |
| Funzione | Impedisce di assegnare un assistente di volo a un itinerario che ha già 6 assistenti. |

```sql
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
```

## 12. `controlla_tipo_merce_e_magazzino`

| Campo | Valore |
|---|---|
| Tabella | `Stoccaggio` |
| Evento | `INSERT` |
| Timing | `BEFORE` |
| Funzione | Controlla che una merce venga stoccata solo in un magazzino compatibile con la sua categoria. |

```sql
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
```

## 13. `controllo_capacita_magazzino`

| Campo | Valore |
|---|---|
| Tabella | `Stoccaggio` |
| Evento | `INSERT` |
| Timing | `BEFORE` |
| Funzione | Controlla che il magazzino abbia capacità sufficiente prima di stoccare una merce. |

```sql
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
```

## 14. `controlla_tipo_merce_e_magazzino2`

| Campo | Valore |
|---|---|
| Tabella | `Stoccaggio` |
| Evento | `UPDATE` |
| Timing | `BEFORE` |
| Funzione | Controlla, in aggiornamento, che la merce resti associata a un magazzino compatibile. |

```sql
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
```

## 15. `controllo_capacita_magazzino2`

| Campo | Valore |
|---|---|
| Tabella | `Stoccaggio` |
| Evento | `UPDATE` |
| Timing | `BEFORE` |
| Funzione | Controlla la capacità del magazzino quando viene modificato uno stoccaggio. |

```sql
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
```

## 16. `controllo_gate`

| Campo | Valore |
|---|---|
| Tabella | `Aereo` |
| Evento | `INSERT` |
| Timing | `BEFORE` |
| Funzione | Controlla che l'aereo sia compatibile con il gate e che la lunghezza non superi quella massima consentita. |

```sql
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
```

## 17. `controllo_gate2`

| Campo | Valore |
|---|---|
| Tabella | `Aereo` |
| Evento | `UPDATE` |
| Timing | `BEFORE` |
| Funzione | Controlla compatibilità e lunghezza del gate quando vengono modificati dati dell'aereo. |

```sql
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
```

## 18. `controllo_itinerario_prenotazione`

| Campo | Valore |
|---|---|
| Tabella | `Prenotazione` |
| Evento | `INSERT` |
| Timing | `BEFORE` |
| Funzione | Impedisce di prenotare un posto su un aereo che non ha un itinerario associato. |

```sql
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
```

## 19. `controllo_itinerario_prenotazione2`

| Campo | Valore |
|---|---|
| Tabella | `Prenotazione` |
| Evento | `UPDATE` |
| Timing | `BEFORE` |
| Funzione | Impedisce di modificare una prenotazione assegnandola a un aereo senza itinerario. |

```sql
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
```

## 20. `controllo_date_prenotazione`

| Campo | Valore |
|---|---|
| Tabella | `Prenotazione` |
| Evento | `INSERT` |
| Timing | `BEFORE` |
| Funzione | Controlla che le date della prenotazione siano valide per l'itinerario e che il posto non sia già prenotato per lo stesso intervallo di tempo. |

```sql
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
```

## 21. `controllo_date_prenotazione2`

| Campo | Valore |
|---|---|
| Tabella | `Prenotazione` |
| Evento | `UPDATE` |
| Timing | `BEFORE` |
| Funzione | Controlla la validità delle date e la disponibilità del posto quando una prenotazione viene modificata. |

```sql
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
```

## 22. `controllo_tipo_aereo_posto`

| Campo | Valore |
|---|---|
| Tabella | `Posto` |
| Evento | `INSERT` |
| Timing | `BEFORE` |
| Funzione | Verifica che i posti possano essere inseriti solo su aerei di tipo Passeggeri. |

```sql
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
```

## 23. `controllo_capienza_aereo`

| Campo | Valore |
|---|---|
| Tabella | `Posto` |
| Evento | `INSERT` |
| Timing | `BEFORE` |
| Funzione | Controlla che l'aereo abbia capienza sufficiente prima di aggiungere un nuovo posto. |

```sql
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
```

## 24. `controllo_tipo_aereo_posto2`

| Campo | Valore |
|---|---|
| Tabella | `Posto` |
| Evento | `UPDATE` |
| Timing | `BEFORE` |
| Funzione | Verifica, in aggiornamento, che i posti rimangano associati solo ad aerei di tipo Passeggeri. |

```sql
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
```

## 25. `controllo_capienza_aereo2`

| Campo | Valore |
|---|---|
| Tabella | `Posto` |
| Evento | `UPDATE` |
| Timing | `BEFORE` |
| Funzione | Controlla la capienza dell'aereo quando viene modificato l'aereo associato a un posto. |

```sql
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
```

## 26. `aggiorna_peso_container`

| Campo | Valore |
|---|---|
| Tabella | `Merce` |
| Evento | `INSERT` |
| Timing | `AFTER` |
| Funzione | Aggiunge il peso della nuova merce al peso totale del container che la contiene. |

```sql
DELIMITER $$
CREATE TRIGGER aggiorna_peso_container AFTER INSERT ON Merce
FOR EACH ROW
BEGIN UPDATE Container_Aereo SET Container_Aereo.Peso=Container_Aereo.Peso+NEW.Peso WHERE Container_Aereo.ID=NEW.ID_container; END $$
DELIMITER ;
```

## 27. `controllo_aggiornamento_tipo_merce`

| Campo | Valore |
|---|---|
| Tabella | `Merce` |
| Evento | `UPDATE` |
| Timing | `BEFORE` |
| Funzione | Controlla, se la merce è già stoccata, che la nuova categoria resti compatibile con il tipo del magazzino. |

```sql
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
```

## 28. `controllo_capacita_magazzino3`

| Campo | Valore |
|---|---|
| Tabella | `Merce` |
| Evento | `UPDATE` |
| Timing | `BEFORE` |
| Funzione | Ricontrolla la capacità del magazzino quando cambia il peso di una merce già stoccata. |

```sql
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
```

## 29. `aggiorna_peso_container2`

| Campo | Valore |
|---|---|
| Tabella | `Merce` |
| Evento | `UPDATE` |
| Timing | `AFTER` |
| Funzione | Aggiorna il peso del container (o dei due container coinvolti, se la merce viene spostata) quando cambia il peso della merce. |

```sql
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
```

## 30. `aggiorna_peso_container3`

| Campo | Valore |
|---|---|
| Tabella | `Merce` |
| Evento | `DELETE` |
| Timing | `AFTER` |
| Funzione | Sottrae il peso della merce eliminata dal peso totale del container. |

```sql
DELIMITER $$
CREATE TRIGGER aggiorna_peso_container3 AFTER DELETE ON Merce
FOR EACH ROW
BEGIN UPDATE Container_Aereo SET Container_Aereo.Peso=Container_Aereo.Peso-OLD.Peso WHERE Container_Aereo.ID=OLD.ID_container; END $$
DELIMITER ;
```

## 31. `controllo_codice_fiscale_passeggero`

| Campo | Valore |
|---|---|
| Tabella | `Passeggero` |
| Evento | `INSERT` |
| Timing | `BEFORE` |
| Funzione | Impedisce di inserire un passeggero con un codice fiscale già appartenente a un assistente di volo. |

```sql
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
```

## 32. `controllo_codice_fiscale_passeggero2`

| Campo | Valore |
|---|---|
| Tabella | `Passeggero` |
| Evento | `UPDATE` |
| Timing | `BEFORE` |
| Funzione | Impedisce di modificare il codice fiscale di un passeggero usando quello già appartenente a un assistente di volo. |

```sql
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
```

## 33. `controllo_codice_fiscale_assistente`

| Campo | Valore |
|---|---|
| Tabella | `Assistente_di_volo` |
| Evento | `INSERT` |
| Timing | `BEFORE` |
| Funzione | Impedisce di inserire un assistente di volo con un codice fiscale già appartenente a un passeggero. |

```sql
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
```

## 34. `controllo_codice_fiscale_assistente2`

| Campo | Valore |
|---|---|
| Tabella | `Assistente_di_volo` |
| Evento | `UPDATE` |
| Timing | `BEFORE` |
| Funzione | Impedisce di modificare il codice fiscale di un assistente di volo usando quello già appartenente a un passeggero. |

```sql
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
```

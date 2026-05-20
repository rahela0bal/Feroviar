-- Schema Feroviar
-- De completat de DB Specialist


-- CREEAZA TABELELE IN SUPABASE --


-- 1. Tabelul pentru statii
CREATE TABLE statii (
    id_statie SERIAL PRIMARY KEY,
    nume VARCHAR(255) NOT NULL,
    oras VARCHAR(255),
    tip VARCHAR(50) NOT NULL CONSTRAINT chk_tip_statie CHECK (tip IN ('terminala', 'intermediara')),
    numar_linii INT NOT NULL CONSTRAINT chk_numar_linii CHECK (numar_linii > 0)
);

-- 2. Tabelul pentru trenuri
CREATE TABLE trenuri (
    id_tren SERIAL PRIMARY KEY,
    tip VARCHAR(50) NOT NULL CONSTRAINT chk_tip_tren CHECK (tip IN ('regional', 'intercity', 'tramvai')),
    capacitate INT NOT NULL CONSTRAINT chk_capacitate CHECK (capacitate > 0),
    status VARCHAR(50) NOT NULL CONSTRAINT chk_status_tren CHECK (status IN ('activ', 'in_mentenanta'))
);

-- 3. Tabelul pentru rute
CREATE TABLE rute (
    id_ruta SERIAL PRIMARY KEY,
    nume VARCHAR(255) NOT NULL UNIQUE,
    lungime_totala NUMERIC DEFAULT 0,
    tip VARCHAR(50) NOT NULL CONSTRAINT chk_tip_ruta CHECK (tip IN ('feroviar', 'urban'))
);

-- 4. Tabelul de legatura ruta_statii
CREATE TABLE ruta_statii (
    id SERIAL PRIMARY KEY,
    id_ruta INT NOT NULL REFERENCES rute(id_ruta) ON DELETE CASCADE,
    id_statie INT NOT NULL REFERENCES statii(id_statie) ON DELETE RESTRICT,
    ordine INT NOT NULL CONSTRAINT chk_ordine CHECK (ordine > 0),
    distanta_fata_de_inceput NUMERIC,
    CONSTRAINT uq_ruta_ordine UNIQUE (id_ruta, ordine),
    CONSTRAINT uq_ruta_statie UNIQUE (id_ruta, id_statie)
);

-- 5. Tabelul pentru circulatii (programul trenurilor pe rute)
CREATE TABLE circulatii (
    id_circulatie SERIAL PRIMARY KEY,
    id_tren INT NOT NULL REFERENCES trenuri(id_tren) ON DELETE RESTRICT,
    id_ruta INT NOT NULL REFERENCES rute(id_ruta) ON DELETE RESTRICT,
    ora_plecare TIME NOT NULL,
    ora_sosire TIME NOT NULL
);


-- CREEAZA TRIGGERELE --


-- =========================================================================
-- TRIGGER 1: Blocare ștergere stație dacă este folosită în rute
-- =========================================================================


-- 1. Deficirea funcției pentru trigger
CREATE OR REPLACE FUNCTION trg_fn_verifica_stergere_statie()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificăm dacă id-ul stației care se dorește a fi ștearsă există în ruta_statii
    IF EXISTS (SELECT 1 FROM ruta_statii WHERE id_statie = OLD.id_statie) THEN
        RAISE EXCEPTION 'Statia nu poate fi stearsa deoarece este folosita intr-o ruta.';
    END IF;
   
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;


-- 2. Crearea trigger-ului (se execută BEFORE DELETE pentru fiecare rând)
CREATE TRIGGER trg_previne_stergere_statie
BEFORE DELETE ON statii
FOR EACH ROW
EXECUTE FUNCTION trg_fn_verifica_stergere_statie();




-- =========================================================================
-- TRIGGER 2: Recalculare automată lungime_totala în rute
-- =========================================================================


-- 1. Definirea funcției pentru trigger
CREATE OR REPLACE FUNCTION trg_fn_recalculeaza_lungime_ruta()
RETURNS TRIGGER AS $$
DECLARE
    v_id_ruta INT;
BEGIN
    -- Identificăm id_ruta în funcție de operație (la UPDATE sau INSERT)
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        v_id_ruta := NEW.id_ruta;
    END IF;


    -- Actualizăm lungimea totală în tabelul rute folosind valoarea maximă
    UPDATE rute
    SET lungime_totala = COALESCE((
        SELECT MAX(distanta_fata_de_inceput)
        FROM ruta_statii
        WHERE id_ruta = v_id_ruta
    ), 0)
    WHERE id_ruta = v_id_ruta;


    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- 2. Crearea trigger-ului (se execută AFTER INSERT OR UPDATE pentru fiecare rând)
CREATE TRIGGER trg_actualizeaza_lungime_ruta
AFTER INSERT OR UPDATE ON ruta_statii
FOR EACH ROW
EXECUTE FUNCTION trg_fn_recalculeaza_lungime_ruta();

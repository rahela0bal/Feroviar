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


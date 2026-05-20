-- =========================================================================
-- INTEROGARI FEROVIAR
-- Bazate pe schema: statii, trenuri, rute, ruta_statii, circulatii
-- =========================================================================


-- =========================================================================
-- SECTIUNEA 1: INTEROGARI DE BAZA
-- =========================================================================


-- 1.1 Lista statiilor dintr-o ruta, ordonate dupa pozitia in ruta
-- Inlocuieste 1 cu id-ul rutei dorite
SELECT
    rs.ordine,
    s.nume          AS nume_statie,
    s.oras,
    s.tip           AS tip_statie,
    rs.distanta_fata_de_inceput AS distanta_km
FROM ruta_statii rs
INNER JOIN statii s ON rs.id_statie = s.id_statie
WHERE rs.id_ruta = 1
ORDER BY rs.ordine ASC;


-- 1.2 Cea mai lunga ruta (dupa lungime_totala)
SELECT
    id_ruta,
    nume,
    tip,
    lungime_totala AS lungime_km
FROM rute
ORDER BY lungime_totala DESC
LIMIT 1;


-- 1.3 Trenurile active pe o ruta specifica (cu program)
-- Inlocuieste 1 cu id-ul rutei dorite
SELECT
    t.id_tren,
    t.tip           AS tip_tren,
    t.capacitate,
    c.ora_plecare,
    c.ora_sosire
FROM circulatii c
INNER JOIN trenuri t ON c.id_tren = t.id_tren
WHERE c.id_ruta = 1
  AND t.status = 'activ'
ORDER BY c.ora_plecare ASC;


-- =========================================================================
-- SECTIUNEA 2: INTEROGARI COMPLEXE
-- =========================================================================


-- 2.1 Statiile comune intre doua rute (intersectie)
-- Inlocuieste 1 si 2 cu id-urile celor doua rute
SELECT
    s.id_statie,
    s.nume,
    s.oras
FROM statii s
WHERE s.id_statie IN (
    SELECT id_statie FROM ruta_statii WHERE id_ruta = 1
)
AND s.id_statie IN (
    SELECT id_statie FROM ruta_statii WHERE id_ruta = 2
)
ORDER BY s.nume;


-- 2.2 Toate rutele care trec printr-o anumita statie
-- Inlocuieste 3 cu id-ul statiei dorite
SELECT
    r.id_ruta,
    r.nume          AS nume_ruta,
    r.tip,
    r.lungime_totala AS lungime_km,
    rs.ordine       AS pozitie_in_ruta
FROM rute r
INNER JOIN ruta_statii rs ON r.id_ruta = rs.id_ruta
WHERE rs.id_statie = 3
ORDER BY r.nume;


-- 2.3 Distanta totala parcursa de un tren (suma lungimilor rutelor pe care circula)
-- Inlocuieste 1 cu id-ul trenului dorit
SELECT
    t.id_tren,
    t.tip           AS tip_tren,
    t.capacitate,
    t.status,
    COUNT(c.id_circulatie)          AS numar_circulatii,
    COALESCE(SUM(r.lungime_totala), 0) AS distanta_totala_km
FROM trenuri t
LEFT JOIN circulatii c  ON t.id_tren  = c.id_tren
LEFT JOIN rute r        ON c.id_ruta  = r.id_ruta
WHERE t.id_tren = 1
GROUP BY t.id_tren, t.tip, t.capacitate, t.status;


-- =========================================================================
-- SECTIUNEA 3: INTEROGARI DE ANALIZA
-- =========================================================================


-- 3.1 Cele mai aglomerate rute (dupa numarul de circulatii)
SELECT
    r.id_ruta,
    r.nume              AS nume_ruta,
    r.tip,
    r.lungime_totala    AS lungime_km,
    COUNT(c.id_circulatie) AS numar_circulatii
FROM rute r
LEFT JOIN circulatii c ON r.id_ruta = c.id_ruta
GROUP BY r.id_ruta, r.nume, r.tip, r.lungime_totala
ORDER BY numar_circulatii DESC;


-- 3.2 Statiile care apar cel mai frecvent in rute
SELECT
    s.id_statie,
    s.nume,
    s.oras,
    s.tip               AS tip_statie,
    COUNT(rs.id_ruta)   AS numar_rute
FROM statii s
INNER JOIN ruta_statii rs ON s.id_statie = rs.id_statie
GROUP BY s.id_statie, s.nume, s.oras, s.tip
ORDER BY numar_rute DESC;


-- 3.3 Distributia trenurilor: active vs in mentenanta
SELECT
    status,
    COUNT(*)            AS numar_trenuri,
    AVG(capacitate)     AS capacitate_medie,
    SUM(capacitate)     AS capacitate_totala
FROM trenuri
GROUP BY status;


-- 3.4 Ruta cu cele mai multe circulatii (top 1)
SELECT
    r.id_ruta,
    r.nume              AS nume_ruta,
    r.lungime_totala    AS lungime_km,
    COUNT(c.id_circulatie) AS numar_circulatii
FROM rute r
INNER JOIN circulatii c ON r.id_ruta = c.id_ruta
GROUP BY r.id_ruta, r.nume, r.lungime_totala
ORDER BY numar_circulatii DESC
LIMIT 1;


-- =========================================================================
-- SECTIUNEA 4: SCENARII
-- =========================================================================


-- SCENARIUL 1: Stergerea unei statii folosite intr-o ruta
-- Demonstreaza triggerul trg_previne_stergere_statie
-- Statia cu id 3 (Cluj-Napoca Vest) este folosita in rutele 1, 2 si 3
-- Aceasta instructiune va esua cu eroarea:
-- "Statia nu poate fi stearsa deoarece este folosita intr-o ruta."
DELETE FROM statii WHERE id_statie = 3;

-- Pentru a vedea ca triggerul functioneaza, verifica mai intai in ce rute apare:
SELECT
    r.nume AS nume_ruta,
    rs.ordine
FROM ruta_statii rs
INNER JOIN rute r ON rs.id_ruta = r.id_ruta
WHERE rs.id_statie = 3
ORDER BY r.nume;


-- SCENARIUL 2: Adauga un tren nou si atribuie-l unei rute
-- Pasul 1: Insereaza trenul nou
INSERT INTO trenuri (tip, capacitate, status)
VALUES ('intercity', 200, 'activ');

-- Pasul 2: Verifica id-ul generat
SELECT id_tren, tip, capacitate, status
FROM trenuri
ORDER BY id_tren DESC
LIMIT 1;

-- Pasul 3: Adauga o circulatie pe ruta 1 (Cluj-Bucuresti via Brasov)
-- Inlocuieste 5 cu id-ul generat la pasul anterior
INSERT INTO circulatii (id_tren, id_ruta, ora_plecare, ora_sosire)
VALUES (5, 1, '08:00:00', '16:30:00');

-- Pasul 4: Verifica ca circulatia a fost adaugata
SELECT
    c.id_circulatie,
    t.tip           AS tip_tren,
    t.capacitate,
    r.nume          AS ruta,
    c.ora_plecare,
    c.ora_sosire
FROM circulatii c
INNER JOIN trenuri t ON c.id_tren = t.id_tren
INNER JOIN rute r    ON c.id_ruta = r.id_ruta
WHERE c.id_tren = 5;


-- SCENARIUL 3: Imaginea completa a retelei feroviare
-- Rute + statii in ordine + trenuri active + lungimi
SELECT
    r.id_ruta,
    r.nume              AS ruta,
    r.tip               AS tip_ruta,
    r.lungime_totala    AS lungime_km,
    rs.ordine,
    s.nume              AS statie,
    s.oras,
    rs.distanta_fata_de_inceput AS distanta_de_la_inceput_km,
    COUNT(DISTINCT c.id_circulatie) AS numar_circulatii,
    STRING_AGG(DISTINCT t.tip, ', ') FILTER (WHERE t.status = 'activ') AS tipuri_trenuri_active
FROM rute r
INNER JOIN ruta_statii rs   ON r.id_ruta    = rs.id_ruta
INNER JOIN statii s         ON rs.id_statie = s.id_statie
LEFT  JOIN circulatii c     ON r.id_ruta    = c.id_ruta
LEFT  JOIN trenuri t        ON c.id_tren    = t.id_tren
GROUP BY r.id_ruta, r.nume, r.tip, r.lungime_totala,
         rs.ordine, s.nume, s.oras, rs.distanta_fata_de_inceput
ORDER BY r.id_ruta, rs.ordine;

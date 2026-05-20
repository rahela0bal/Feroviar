-- Date initiale (seed) pentru Feroviar
-- De completat dupa finalizarea schema.sql


-- ADAUGA DATE TEST --


-- =========================================================================
-- 1. INSERT DATE DE TEST: statii
-- =========================================================================
INSERT INTO statii (nume, oras, tip, numar_linii) VALUES
('București Nord', 'București', 'terminala', 14),
('Brașov Central', 'Brașov', 'intermediara', 7),
('Cluj-Napoca Vest', 'Cluj-Napoca', 'terminala', 8),
('Oradea Central', 'Oradea', 'intermediara', 5),
('Timișoara Nord', 'Timișoara', 'terminala', 10),
('Iași Central', 'Iași', 'terminala', 6);


-- =========================================================================
-- 2. INSERT DATE DE TEST: trenuri
-- =========================================================================
INSERT INTO trenuri (tip, capacitate, status) VALUES
('intercity', 240, 'activ'),
('regional', 120, 'activ'),
('intercity', 180, 'in_mentenanta'),
('regional', 150, 'activ');


-- =========================================================================
-- 3. INSERT DATE DE TEST: rute
-- =========================================================================
INSERT INTO rute (nume, lungime_totala, tip) VALUES
('Cluj-București via Brașov', 497.0, 'feroviar'),
('Timișoara-Iași Express', 789.0, 'feroviar'),
('Oradea-Brașov Regional', 420.0, 'feroviar');


-- =========================================================================
-- 4. INSERT DATE DE TEST: ruta_statii
-- Note: Id-urile se asumă a fi de la 1 la 6 în ordinea inserării de mai sus.
-- =========================================================================
-- Ruta 1: Cluj-București via Brașov (Cluj -> Brașov -> București)
INSERT INTO ruta_statii (id_ruta, id_statie, ordine, distanta_fata_de_inceput) VALUES
(1, 3, 1, 0.0),    -- Cluj-Napoca Vest (Start)
(1, 2, 2, 331.0),  -- Brașov Central
(1, 1, 3, 497.0);  -- București Nord (Sosire)

-- Ruta 2: Timișoara-Iași Express (Timișoara -> Cluj -> Iași)
INSERT INTO ruta_statii (id_ruta, id_statie, ordine, distanta_fata_de_inceput) VALUES
(2, 5, 1, 0.0),    -- Timișoara Nord (Start)
(2, 3, 2, 318.0),  -- Cluj-Napoca Vest
(2, 6, 3, 789.0);  -- Iași Central (Sosire)

-- Ruta 3: Oradea-Brașov Regional (Oradea -> Cluj -> Brașov)
INSERT INTO ruta_statii (id_ruta, id_statie, ordine, distanta_fata_de_inceput) VALUES
(3, 4, 1, 0.0),    -- Oradea Central (Start)
(3, 3, 2, 152.0),  -- Cluj-Napoca Vest
(3, 2, 3, 420.0);  -- Brașov Central (Sosire)


-- =========================================================================
-- 5. INSERT DATE DE TEST: circulatii
-- Note: Asociem doar trenuri active (ID 1, 2, 4). Trenul 3 e în mentenanță.
-- =========================================================================
INSERT INTO circulatii (id_tren, id_ruta, ora_plecare, ora_sosire) VALUES
(1, 1, '06:00:00', '14:30:00'), -- Intercity pe Cluj-București (durată ~8h30m)
(4, 2, '18:15:00', '08:45:00'), -- Regional de noapte pe Timișoara-Iași (~14h30m)
(2, 3, '12:00:00', '19:15:00'); -- Regional pe Oradea-Brașov (~7h15m)

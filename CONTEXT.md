# CONTEXT — Sistem Management Feroviar

## Descrierea proiectului

Aplicatie web pentru managementul retelei feroviare: gestionarea statiilor, trenurilor, rutelor si calatoriilor. Proiectul este dezvoltat ca tema pentru cursul SGBD, anul 2, semestrul 2.

---

## Stack tehnologic

| Layer     | Tehnologie              |
|-----------|-------------------------|
| Frontend  | Vue.js 3 (CDN), HTML, CSS |
| Backend   | Supabase (BaaS)         |
| Baza date | PostgreSQL (via Supabase) |

---

## Configurare Supabase

- **URL:** `https://pllefrwkahajaybvusan.supabase.co`

---

## Status task-uri

| Task                              | Status |
|-----------------------------------|--------|
| Initializare proiect              | ✅ Completat |
| Definire schema baza de date      | ✅ Completat |
| Populare date initiale (seed)     | ✅ Completat |
| Configurare Supabase              | ✅ Completat |
| Componenta: Lista statii          | ❌ Neinceput |
| Componenta: Lista trenuri         | ❌ Neinceput |
| Componenta: Rute                  | ❌ Neinceput |
| Componenta: Calatorii             | ❌ Neinceput |
| Conectare frontend la Supabase    | ❌ Neinceput |
| Testare si validare               | ❌ Neinceput |

---

## Schema tabelelor

### `statii`
| Coloana     | Tip          | Constrangeri                                      |
|-------------|--------------|---------------------------------------------------|
| id_statie   | SERIAL       | PRIMARY KEY                                       |
| nume        | VARCHAR(255) | NOT NULL                                          |
| oras        | VARCHAR(255) |                                                   |
| tip         | VARCHAR(50)  | NOT NULL, CHECK IN ('terminala', 'intermediara')  |
| numar_linii | INT          | NOT NULL, CHECK > 0                               |

---

### `trenuri`
| Coloana    | Tip         | Constrangeri                                          |
|------------|-------------|-------------------------------------------------------|
| id_tren    | SERIAL      | PRIMARY KEY                                           |
| tip        | VARCHAR(50) | NOT NULL, CHECK IN ('regional', 'intercity', 'tramvai') |
| capacitate | INT         | NOT NULL, CHECK > 0                                   |
| status     | VARCHAR(50) | NOT NULL, CHECK IN ('activ', 'in_mentenanta')         |

---

### `rute`
| Coloana        | Tip          | Constrangeri                             |
|----------------|--------------|------------------------------------------|
| id_ruta        | SERIAL       | PRIMARY KEY                              |
| nume           | VARCHAR(255) | NOT NULL, UNIQUE                         |
| lungime_totala | NUMERIC      | DEFAULT 0                                |
| tip            | VARCHAR(50)  | NOT NULL, CHECK IN ('feroviar', 'urban') |

---

### `ruta_statii` *(relatie N-M cu atribute — cea mai importanta)*
| Coloana                  | Tip     | Constrangeri                                       |
|--------------------------|---------|----------------------------------------------------|
| id                       | SERIAL  | PRIMARY KEY                                        |
| id_ruta                  | INT     | NOT NULL, FK → rute(id_ruta) ON DELETE CASCADE     |
| id_statie                | INT     | NOT NULL, FK → statii(id_statie) ON DELETE RESTRICT |
| ordine                   | INT     | NOT NULL, CHECK > 0                                |
| distanta_fata_de_inceput | NUMERIC |                                                    |

Constrangeri compuse:
- `UNIQUE(id_ruta, ordine)` — ordinea este unica per ruta
- `UNIQUE(id_ruta, id_statie)` — o statie apare o singura data pe aceeasi ruta

---

### `circulatii`
| Coloana       | Tip    | Constrangeri                                      |
|---------------|--------|---------------------------------------------------|
| id_circulatie | SERIAL | PRIMARY KEY                                       |
| id_tren       | INT    | NOT NULL, FK → trenuri(id_tren) ON DELETE RESTRICT |
| id_ruta       | INT    | NOT NULL, FK → rute(id_ruta) ON DELETE RESTRICT   |
| ora_plecare   | TIME   | NOT NULL                                          |
| ora_sosire    | TIME   | NOT NULL                                          |

---

### Relatii
```
statii ──< ruta_statii >── rute      (N-M cu atribute: ordine, distanta_fata_de_inceput)
trenuri ──< circulatii                (1-N: un tren are multe circulatii)
rute    ──< circulatii                (1-N: o ruta are multe circulatii)
```

---

## Triggere

| Trigger | Tabel | Eveniment | Descriere |
|---|---|---|---|
| `trg_previne_stergere_statie` | `statii` | BEFORE DELETE | Blocheaza stergerea unei statii folosite intr-o ruta |
| `trg_actualizeaza_lungime_ruta` | `ruta_statii` | AFTER INSERT / UPDATE | Recalculeaza automat `lungime_totala` in `rute` |

## Functii stocate

| Functie | Parametru | Returneaza | Descriere |
|---|---|---|---|
| `calculeaza_lungime_ruta` | `p_id_ruta INT` | `NUMERIC` | Lungimea totala a unei rute (MAX distanta) |
| `listeaza_statii_ruta` | `p_id_ruta INT` | `TABLE` | Statiile unei rute in ordine crescatoare |

## Viewuri

| View | Descriere |
|---|---|
| `rute_complete` | Structura detaliata a fiecarei rute cu statiile aferente, ordonate |
| `trenuri_active_pe_rute` | Trenurile active si rutele pe care sunt programate |

---

## Conventii de nume

- **Stil:** `snake_case`
- **Limba:** romana
- **Exemple ID-uri:** `id_statie`, `id_tren`, `id_ruta`, `id_circulatie`
- **Exemple coloane:** `nume`, `ora_plecare`, `ora_sosire`, `tip`, `capacitate`
- **Tabele la plural:** `statii`, `trenuri`, `rute`, `ruta_statii`, `circulatii`

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

## Status task-uri

| Task                              | Status |
|-----------------------------------|--------|
| Initializare proiect              | ❌ Neinceput |
| Definire schema baza de date      | ✅ Completat |
| Populare date initiale (seed)     | ✅ Completat|
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
| Coloana       | Tip                              | Constrangeri         |
|---------------|----------------------------------|----------------------|
| id_statie     | SERIAL                           | PRIMARY KEY          |
| nume          | VARCHAR(100)                     | NOT NULL             |
| oras          | VARCHAR(100)                     | NOT NULL             |
| tip           | ENUM('terminala','intermediara') | NOT NULL             |
| numar_linii   | INTEGER                          | NOT NULL, CHECK > 0  |

---

### `trenuri`
| Coloana    | Tip                                          | Constrangeri        |
|------------|----------------------------------------------|---------------------|
| id_tren    | SERIAL                                       | PRIMARY KEY         |
| tip        | ENUM('regional','intercity','tramvai')        | NOT NULL            |
| capacitate | INTEGER                                      | NOT NULL, CHECK > 0 |
| status     | ENUM('activ','in_mentenanta')                | NOT NULL            |

---

### `rute`
| Coloana        | Tip                        | Constrangeri          |
|----------------|----------------------------|-----------------------|
| id_ruta        | SERIAL                     | PRIMARY KEY           |
| nume           | VARCHAR(150)               | NOT NULL, UNIQUE      |
| lungime_totala | NUMERIC(8,2)               | NOT NULL              |
| tip            | ENUM('feroviar','urban')   | NOT NULL              |

---

### `ruta_statii` *(relatie N-M cu atribute — cea mai importanta)*
| Coloana                  | Tip          | Constrangeri                        |
|--------------------------|--------------|-------------------------------------|
| id                       | SERIAL       | PRIMARY KEY                         |
| id_ruta                  | INTEGER      | NOT NULL, FK → rute(id_ruta)        |
| id_statie                | INTEGER      | NOT NULL, FK → statii(id_statie)    |
| ordine                   | INTEGER      | NOT NULL, CHECK > 0                 |
| distanta_fata_de_inceput | NUMERIC(8,2) | NOT NULL                            |

> UNIQUE(id_ruta, id_statie) — o statie apare o singura data pe aceeasi ruta.
> UNIQUE(id_ruta, ordine) — ordinea este unica per ruta.

---

### `circulatii`
| Coloana         | Tip     | Constrangeri                          |
|-----------------|---------|---------------------------------------|
| id_circulatie   | SERIAL  | PRIMARY KEY                           |
| id_tren         | INTEGER | NOT NULL, FK → trenuri(id_tren)       |
| id_ruta         | INTEGER | NOT NULL, FK → rute(id_ruta)          |
| ora_plecare     | TIME    | NOT NULL                              |
| ora_sosire      | TIME    | NOT NULL                              |

---

### Relatii
```
statii ──< ruta_statii >── rute      (N-M cu atribute: ordine, distanta_fata_de_inceput)
trenuri ──< circulatii                (1-N: un tren are multe circulatii)
rute    ──< circulatii                (1-N: o ruta are multe circulatii)
```

### Constrangeri importante
- `capacitate > 0` pe tabela `trenuri`
- `numar_linii > 0` pe tabela `statii`
- `UNIQUE(nume)` pe tabela `rute`
- `ordine > 0` pe tabela `ruta_statii`
- `UNIQUE(id_ruta, ordine)` pe tabela `ruta_statii`
- `UNIQUE(id_ruta, id_statie)` pe tabela `ruta_statii`

---

## Conventii de nume

- **Stil:** `snake_case`
- **Limba:** romana
- **Exemple ID-uri:** `id_statie`, `id_tren`, `id_ruta`, `id_calatorie`
- **Exemple coloane:** `nume_statie`, `ora_plecare`, `ora_sosire`, `tip_tren`
- **Tabele la plural:** `statii`, `trenuri`, `rute`, `calatorii`

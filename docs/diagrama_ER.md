# Diagrama ER — Sistem Management Feroviar

Diagrama entitate-relație a bazei de date PostgreSQL (Supabase) pentru sistemul de management feroviar.
Conține 5 tabele, relațiile dintre ele (1-N și N-M), cheile primare, cheile străine și constrângerile principale.

```mermaid
erDiagram

    statii {
        SERIAL      id_statie       PK
        VARCHAR255  nume            "NOT NULL"
        VARCHAR255  oras
        VARCHAR50   tip             "CHECK: terminala | intermediara"
        INT         numar_linii     "NOT NULL, CHECK > 0"
    }

    trenuri {
        SERIAL      id_tren         PK
        VARCHAR50   tip             "CHECK: regional | intercity | tramvai"
        INT         capacitate      "NOT NULL, CHECK > 0"
        VARCHAR50   status          "CHECK: activ | in_mentenanta"
    }

    rute {
        SERIAL      id_ruta         PK
        VARCHAR255  nume            "NOT NULL, UNIQUE"
        NUMERIC     lungime_totala  "DEFAULT 0"
        VARCHAR50   tip             "CHECK: feroviar | urban"
    }

    ruta_statii {
        SERIAL      id                       PK
        INT         id_ruta                  FK
        INT         id_statie                FK
        INT         ordine                   "NOT NULL, CHECK > 0"
        NUMERIC     distanta_fata_de_inceput
    }

    circulatii {
        SERIAL      id_circulatie   PK
        INT         id_tren         FK
        INT         id_ruta         FK
        TIME        ora_plecare     "NOT NULL"
        TIME        ora_sosire      "NOT NULL"
    }

    %% Relatia N-M intre rute si statii (prin tabelul de legatura ruta_statii)
    rute        ||--o{ ruta_statii  : "contine"
    statii      ||--o{ ruta_statii  : "apare in"

    %% Relatia 1-N: un tren are multe circulatii
    trenuri     ||--o{ circulatii   : "efectueaza"

    %% Relatia 1-N: o ruta are multe circulatii
    rute        ||--o{ circulatii   : "are programate"
```

## Relatii

| Relatie | Tip | Descriere |
|---|---|---|
| `rute` → `ruta_statii` | 1-N | O rută are mai multe intrări în tabelul de legătură |
| `statii` → `ruta_statii` | 1-N | O stație apare în mai multe rute |
| `rute` ↔ `statii` prin `ruta_statii` | **N-M** | Relație many-to-many cu atribute: `ordine`, `distanta_fata_de_inceput` |
| `trenuri` → `circulatii` | 1-N | Un tren poate avea mai multe circulații |
| `rute` → `circulatii` | 1-N | O rută poate avea mai multe circulații |

## Constrângeri cheie

| Tabel | Constrângere |
|---|---|
| `statii` | `numar_linii > 0`, `tip IN ('terminala','intermediara')` |
| `trenuri` | `capacitate > 0`, `tip IN ('regional','intercity','tramvai')`, `status IN ('activ','in_mentenanta')` |
| `rute` | `UNIQUE(nume)`, `tip IN ('feroviar','urban')` |
| `ruta_statii` | `ordine > 0`, `UNIQUE(id_ruta, ordine)`, `UNIQUE(id_ruta, id_statie)` |
| `ruta_statii` | FK `id_ruta` → `rute` ON DELETE CASCADE |
| `ruta_statii` | FK `id_statie` → `statii` ON DELETE RESTRICT |
| `circulatii` | FK `id_tren` → `trenuri` ON DELETE RESTRICT |
| `circulatii` | FK `id_ruta` → `rute` ON DELETE RESTRICT |

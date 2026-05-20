# Documentație — Sistem Management Feroviar

Proiect realizat în cadrul cursului **SGBD** (Sisteme de Gestiune a Bazelor de Date),
Facultatea de Informatică, Anul 2, Semestrul 2.

---

## 1. Descrierea proiectului

Aplicație web pentru gestionarea unei rețele feroviare. Sistemul permite operatorilor să administreze stațiile, trenurile, rutele și circulațiile, și să consulte rapoarte despre activitatea rețelei.

**Funcționalități principale:**
- Adăugare, editare și ștergere de stații, trenuri și rute (CRUD complet)
- Asocierea stațiilor la rute cu ordine și distanțe (relație N-M)
- Programarea circulațiilor trenurilor pe rute
- Rapoarte: stațiile unei rute, trenurile active pe o rută
- Protecție automată prin triggere (ex: nu poți șterge o stație folosită)

---

## 2. Echipa și rolurile

| Rol | Responsabilități |
|---|---|
| **Leader** | Coordonare, arhitectură generală, integrare finală |
| **DB Specialist** | Schema bazei de date, SQL, seed, relații între tabele |
| **Asistent 1** | Componente Vue, interfață utilizator |
| **Asistent 2** | Conectare Supabase, testare, documentație |

---

## 3. Diagrama ER

Diagrama entitate-relație completă în format Mermaid:
→ [docs/diagrama_ER.md](diagrama_ER.md)

---

## 4. Descrierea tabelelor

### `statii`
Stochează informații despre stațiile feroviare din rețea.

| Coloană | Tip | Rol |
|---|---|---|
| `id_statie` | SERIAL | Cheie primară, identificator unic |
| `nume` | VARCHAR(255) | Numele stației |
| `oras` | VARCHAR(255) | Orașul în care se află stația |
| `tip` | VARCHAR(50) | Tipul stației: `terminala` sau `intermediara` |
| `numar_linii` | INT | Numărul de linii disponibile în stație |

---

### `trenuri`
Stochează informații despre trenurile din flotă.

| Coloană | Tip | Rol |
|---|---|---|
| `id_tren` | SERIAL | Cheie primară, identificator unic |
| `tip` | VARCHAR(50) | Tipul trenului: `regional`, `intercity` sau `tramvai` |
| `capacitate` | INT | Numărul de locuri disponibile |
| `status` | VARCHAR(50) | Starea trenului: `activ` sau `in_mentenanta` |

---

### `rute`
Stochează rutele feroviare disponibile în rețea.

| Coloană | Tip | Rol |
|---|---|---|
| `id_ruta` | SERIAL | Cheie primară, identificator unic |
| `nume` | VARCHAR(255) | Numele rutei (unic în sistem) |
| `lungime_totala` | NUMERIC | Lungimea totală a rutei în km (calculată automat de trigger) |
| `tip` | VARCHAR(50) | Tipul rutei: `feroviar` sau `urban` |

---

### `ruta_statii`
Tabel de legătură N-M între `rute` și `statii`. Cea mai importantă tabelă — conține atribute proprii ale relației.

| Coloană | Tip | Rol |
|---|---|---|
| `id` | SERIAL | Cheie primară |
| `id_ruta` | INT | FK → `rute`, ruta căreia îi aparține înregistrarea |
| `id_statie` | INT | FK → `statii`, stația inclusă în rută |
| `ordine` | INT | Poziția stației în cadrul rutei (1, 2, 3...) |
| `distanta_fata_de_inceput` | NUMERIC | Distanța în km față de prima stație a rutei |

---

### `circulatii`
Programul trenurilor pe rute — când pleacă și când sosesc.

| Coloană | Tip | Rol |
|---|---|---|
| `id_circulatie` | SERIAL | Cheie primară |
| `id_tren` | INT | FK → `trenuri`, trenul care efectuează circulația |
| `id_ruta` | INT | FK → `rute`, ruta pe care circulă trenul |
| `ora_plecare` | TIME | Ora de plecare de la prima stație |
| `ora_sosire` | TIME | Ora de sosire la ultima stație |

---

## 5. Normalizare — de ce schema este în 3NF

Schema respectă **Forma Normală 3 (3NF)**:

- **1NF** — toate coloanele conțin valori atomice; nu există grupuri repetitive sau coloane cu valori multiple.
- **2NF** — fiecare coloană non-cheie depinde de întreaga cheie primară. Relația N-M dintre `rute` și `statii` este separată în `ruta_statii`, eliminând dependențele parțiale.
- **3NF** — nu există dependențe tranzitive. De exemplu, `lungime_totala` din `rute` nu depinde de altă coloană non-cheie, ci este calculată direct din `ruta_statii` prin trigger.

Separarea în 5 tabele elimină redundanța: datele unui tren sau ale unei stații se stochează o singură dată, indiferent de câte rute sau circulații le referențiază.

---

## 6. Constrângeri implementate

### CHECK
| Tabel | Coloană | Constrângere |
|---|---|---|
| `statii` | `tip` | `IN ('terminala', 'intermediara')` |
| `statii` | `numar_linii` | `> 0` |
| `trenuri` | `tip` | `IN ('regional', 'intercity', 'tramvai')` |
| `trenuri` | `capacitate` | `> 0` |
| `trenuri` | `status` | `IN ('activ', 'in_mentenanta')` |
| `rute` | `tip` | `IN ('feroviar', 'urban')` |
| `ruta_statii` | `ordine` | `> 0` |

### UNIQUE
| Tabel | Coloane | Descriere |
|---|---|---|
| `rute` | `nume` | Numele rutei este unic în sistem |
| `ruta_statii` | `(id_ruta, ordine)` | Ordinea este unică per rută |
| `ruta_statii` | `(id_ruta, id_statie)` | O stație apare o singură dată pe aceeași rută |

### Chei străine (FK)
| Tabel | Coloană | Referință | La ștergere |
|---|---|---|---|
| `ruta_statii` | `id_ruta` | `rute(id_ruta)` | CASCADE |
| `ruta_statii` | `id_statie` | `statii(id_statie)` | RESTRICT |
| `circulatii` | `id_tren` | `trenuri(id_tren)` | RESTRICT |
| `circulatii` | `id_ruta` | `rute(id_ruta)` | RESTRICT |

---

## 7. Triggere

### `trg_previne_stergere_statie`
- **Tabel:** `statii`
- **Eveniment:** `BEFORE DELETE`
- **Funcție:** `trg_fn_verifica_stergere_statie()`
- **Comportament:** Verifică dacă stația apare în `ruta_statii`. Dacă da, aruncă o excepție și blochează ștergerea. Protejează integritatea rețelei.

### `trg_actualizeaza_lungime_ruta`
- **Tabel:** `ruta_statii`
- **Eveniment:** `AFTER INSERT OR UPDATE`
- **Funcție:** `trg_fn_recalculeaza_lungime_ruta()`
- **Comportament:** La orice modificare în `ruta_statii`, recalculează automat `lungime_totala` în `rute` ca `MAX(distanta_fata_de_inceput)` pentru acea rută.

---

## 8. Proceduri stocate (funcții)

### `calculeaza_lungime_ruta(p_id_ruta INT)`
- **Returnează:** `NUMERIC`
- **Descriere:** Calculează și returnează lungimea totală a unei rute ca valoarea maximă a coloanei `distanta_fata_de_inceput` din `ruta_statii`.

### `listeaza_statii_ruta(p_id_ruta INT)`
- **Returnează:** `TABLE (ordine, id_statie, nume_statie, oras, tip_statie, distanta)`
- **Descriere:** Returnează toate stațiile unei rute în ordine crescătoare, cu detalii complete despre fiecare stație.

---

## 9. Viewuri

### `rute_complete`
Afișează structura detaliată a fiecărei rute: ruta, stațiile aferente în ordine, orașele și distanțele. Util pentru a vedea rapid traseul complet al oricărei rute.

### `trenuri_active_pe_rute`
Afișează doar trenurile cu statusul `activ` și rutele pe care sunt programate. Elimină trenurile în mentenanță din vizualizare.

---

## 10. Interogări implementate

### De bază
| # | Descriere |
|---|---|
| 1.1 | Lista stațiilor dintr-o rută, ordonate după poziție (`ORDER BY ordine ASC`) |
| 1.2 | Cea mai lungă rută din sistem (`ORDER BY lungime_totala DESC LIMIT 1`) |
| 1.3 | Trenurile active pe o rută specificată, cu orar |

### Complexe
| # | Descriere |
|---|---|
| 2.1 | Stațiile comune între două rute (intersecție prin subquery-uri) |
| 2.2 | Toate rutele care trec printr-o anumită stație |
| 2.3 | Distanța totală parcursă de un tren (`SUM` pe rutele din circulații) |

### De analiză
| # | Descriere |
|---|---|
| 3.1 | Cele mai aglomerate rute, ordonate după numărul de circulații |
| 3.2 | Stațiile care apar cel mai frecvent în rute (`COUNT + GROUP BY`) |
| 3.3 | Distribuția trenurilor: active vs. în mentenanță (`AVG`, `SUM` capacitate) |
| 3.4 | Ruta cu cele mai multe circulații (`TOP 1`) |

---

## 11. Scenarii de lucru

### Scenariul 1 — Ștergerea unei stații protejate
Se încearcă ștergerea stației Cluj-Napoca Vest (`id_statie = 3`), care apare în 3 rute diferite. Triggerul `trg_previne_stergere_statie` detectează acest lucru și aruncă excepția:
> *„Statia nu poate fi stearsa deoarece este folosita intr-o ruta."*

Operația este blocată automat, fără a afecta datele.

### Scenariul 2 — Adăugare tren nou și atribuire la rută
Se inserează un tren nou de tip `intercity` cu 200 de locuri, statusul `activ`. Ulterior se creează o circulație care îl plasează pe ruta 1 (Cluj–București via Brașov), cu ora de plecare 08:00 și sosire 16:30. La final se verifică că circulația a fost înregistrată corect prin interogare.

### Scenariul 3 — Imaginea completă a rețelei
O singură interogare cu join pe toate cele 5 tabele afișează: fiecare rută cu stațiile în ordine, distanțele, numărul de circulații și tipurile de trenuri active. Oferă o vedere de ansamblu completă asupra rețelei feroviare.

---

## 12. Tehnologii folosite

| Tehnologie | Versiune / Detalii | Rol |
|---|---|---|
| **Vue.js** | 3 (via CDN unpkg) | Framework frontend reactiv |
| **HTML** | 5 | Structura paginii |
| **CSS** | 3 | Stilizare interfață |
| **Supabase** | BaaS (Backend as a Service) | Autentificare, API REST, hosting BD |
| **PostgreSQL** | 15 (gestionat de Supabase) | Baza de date relațională |
| **Mermaid** | - | Diagrame ER în Markdown |
| **Git / GitHub** | - | Versionare și colaborare în echipă |

# Feroviar — Sistem de Management Feroviar

Aplicatie web pentru gestionarea retelei feroviare: statii, trenuri si rute.
Dezvoltata ca proiect pentru cursul **SGBD**, Facultatea de Informatica, Anul 2, Semestrul 2.

Pentru context tehnic complet (schema BD, task-uri, conventii) vezi [CONTEXT.md](CONTEXT.md).

---

## Stack

| Layer        | Tehnologie                  |
|--------------|-----------------------------|
| Frontend     | Vue.js 3, HTML, CSS         |
| Baza de date | Supabase (PostgreSQL)       |

---

## Structura proiectului

```
Feroviar/
├── frontend/
│   ├── index.html        # Pagina principala
│   ├── style.css         # Stiluri
│   └── components/       # Componente Vue
├── database/
│   ├── schema.sql        # Structura tabelelor
│   └── seed.sql          # Date initiale
├── CONTEXT.md            # Context tehnic, schema, task-uri
└── README.md
```

---

## Cum se ruleaza

**1. Cloneaza proiectul**
```bash
git clone git@github.com:rahela0bal/Feroviar.git
cd Feroviar
```

**2. Configureaza Supabase**
- Creaza un proiect pe [supabase.com](https://supabase.com)
- In SQL Editor, ruleaza `database/schema.sql`
- Apoi ruleaza `database/seed.sql` pentru date initiale
- Copiaza `URL`-ul si cheia `anon` din Settings → API

**3. Conecteaza frontenda la Supabase**

In `frontend/index.html`, inlocuieste valorile de configurare:
```js
const SUPABASE_URL = 'https://xxxx.supabase.co';
const SUPABASE_KEY = 'your-anon-key';
```

**4. Deschide aplicatia**

Deschide `frontend/index.html` direct in browser. Nu necesita server.

---

## Echipa

| Rol           | Responsabilitati                                      |
|---------------|-------------------------------------------------------|
| Leader        | Coordonare, arhitectura generala, integrare finala    |
| DB Specialist | Schema baza de date, SQL, seed, relatii intre tabele  |
| Asistent 1    | Componente Vue, interfata utilizator                  |
| Asistent 2    | Conectare Supabase, testare, documentatie             |

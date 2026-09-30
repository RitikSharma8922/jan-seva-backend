# Jan Seva — Database Setup

This folder has the PostgreSQL schema and seed data for the Jan Seva civic
complaint platform, matching the data the frontend currently keeps in
`localStorage` (see `frontend/src/data/mockData.js` and
`frontend/src/context/AppContext.jsx`).

I can't run this against your database myself — this environment has no
outbound network access, so it can't reach `helium`. Run it yourself with
one of the two options below.

## Option A — psql (simplest)

```bash
psql "postgresql://postgres:password@helium/heliumdb?sslmode=disable" -f schema.sql
psql "postgresql://postgres:password@helium/heliumdb?sslmode=disable" -f seed.sql
```

## Option B — Node.js script

```bash
npm install pg
DATABASE_URL="postgresql://postgres:password@helium/heliumdb?sslmode=disable" node run.mjs
```

`run.mjs` runs `schema.sql` then `seed.sql` in order, inside a single
connection.

## What gets created

| Table                | Purpose                                                        |
|-----------------------|-----------------------------------------------------------------|
| `users`               | Citizen accounts (name, email, phone, status, demo password)   |
| `officers`            | Municipal officer accounts (just `admin` by default)           |
| `complaints`          | One row per reported problem, with category/status/location    |
| `complaint_timeline`  | The 5-step tracking timeline for each complaint                |
| `notifications`       | Notification feed for citizens and officers                    |

Seed data matches the 3 demo complaints and 3 demo users already in the
frontend, so the two stay in sync if you later connect the app to this
database instead of `localStorage`.

## A couple of things worth fixing before this goes anywhere real

- **Passwords are plain text**, matching the frontend prototype. Before
  connecting a real backend, hash them (bcrypt/argon2) and add a proper
  auth layer — don't ship this schema's `password` columns as-is.
- **`sslmode=disable`** in your connection string means the connection to
  `helium` isn't encrypted. That's fine for a local/trusted network, but
  not for anything reachable over the public internet.
- You shared the database password directly in chat — worth rotating it if
  `helium` is reachable from anywhere untrusted.

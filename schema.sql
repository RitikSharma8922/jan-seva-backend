-- Jan Seva — PostgreSQL schema
-- Mirrors the data model currently used in src/context/AppContext.jsx
-- and src/data/mockData.js (citizens, complaints, timeline steps, notifications).

BEGIN;

-- Citizens (the "user" role in the frontend)
CREATE TABLE IF NOT EXISTS users (
    id         TEXT PRIMARY KEY,                 -- e.g. 'U-1001'
    name       TEXT NOT NULL,
    email      TEXT NOT NULL UNIQUE,
    phone      TEXT,
    password   TEXT NOT NULL,                    -- demo only: plain text, see note at bottom
    status     TEXT NOT NULL DEFAULT 'active'
               CHECK (status IN ('active', 'blocked')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Municipal officers (the "government" role in the frontend)
CREATE TABLE IF NOT EXISTS officers (
    id         TEXT PRIMARY KEY,                 -- e.g. 'admin'
    name       TEXT NOT NULL,
    password   TEXT NOT NULL,                    -- demo only: plain text, see note at bottom
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Complaints
CREATE TABLE IF NOT EXISTS complaints (
    id                    TEXT PRIMARY KEY,      -- e.g. 'JS-2026-001'
    category              TEXT NOT NULL
                          CHECK (category IN ('Garbage','Road Damage','Street Light',
                                'Water Leakage','Drainage','Electricity','Public Toilet','Other')),
    title                 TEXT NOT NULL,
    description           TEXT NOT NULL,
    location              TEXT,
    lat                   DOUBLE PRECISION,
    lng                   DOUBLE PRECISION,
    photo_url             TEXT,                  -- path/URL to uploaded photo (see note below)
    status                TEXT NOT NULL DEFAULT 'Pending'
                          CHECK (status IN ('Pending','In Progress','Resolved','Rejected')),
    citizen_id            TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    gov_remarks           TEXT DEFAULT '',
    resolution_remarks    TEXT DEFAULT '',
    resolution_photo_url  TEXT,
    resolution_date       DATE,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_complaints_citizen ON complaints(citizen_id);
CREATE INDEX IF NOT EXISTS idx_complaints_status ON complaints(status);
CREATE INDEX IF NOT EXISTS idx_complaints_category ON complaints(category);

-- Timeline steps per complaint (Submitted / Received / Assigned / In Progress / Resolved)
CREATE TABLE IF NOT EXISTS complaint_timeline (
    id           SERIAL PRIMARY KEY,
    complaint_id TEXT NOT NULL REFERENCES complaints(id) ON DELETE CASCADE,
    step_order   SMALLINT NOT NULL,
    step_label   TEXT NOT NULL,
    done         BOOLEAN NOT NULL DEFAULT false,
    done_date    DATE,
    UNIQUE (complaint_id, step_order)
);

-- Notifications for both roles
CREATE TABLE IF NOT EXISTS notifications (
    id         SERIAL PRIMARY KEY,
    role       TEXT NOT NULL CHECK (role IN ('citizen', 'government')),
    user_email TEXT,                              -- set for role = 'citizen'; null = broadcast to officers
    message    TEXT NOT NULL,
    read       BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_email);

COMMIT;

-- NOTE ON PASSWORDS: the frontend prototype stores plain-text demo passwords,
-- so this schema mirrors that for now. Before connecting a real backend,
-- hash passwords (e.g. bcrypt) and never store them in plain text.
--
-- NOTE ON PHOTOS: the frontend currently keeps photos as base64 data URLs in
-- memory/localStorage. For a real database, store an uploaded file in object
-- storage (S3, GCS, etc.) or a local uploads folder, and save only the
-- resulting URL/path in photo_url / resolution_photo_url.

-- Seed data — mirrors src/data/mockData.js so the database starts in the
-- same state the frontend demo does. Run this after schema.sql.

BEGIN;

INSERT INTO users (id, name, email, phone, password, status) VALUES
    ('U-1001', 'Citizen Demo', 'citizen@test.com', '9999900000', '123456', 'active'),
    ('U-1002', 'Ravi Kumar', 'ravi.kumar@test.com', '9876500001', '123456', 'active'),
    ('U-1003', 'Sunita Devi', 'sunita.devi@test.com', '9876500002', '123456', 'blocked')
ON CONFLICT (id) DO NOTHING;

INSERT INTO officers (id, name, password) VALUES
    ('admin', 'Municipal Officer', 'admin123')
ON CONFLICT (id) DO NOTHING;

INSERT INTO complaints (id, category, title, description, location, status, citizen_id,
                         gov_remarks, resolution_remarks, resolution_date, created_at) VALUES
    ('JS-2026-001', 'Garbage', 'Garbage has not been collected for 5 days',
     'The garbage bin near the market entrance has not been emptied in almost a week. It is overflowing and causing a bad smell in the whole street.',
     'Kanpur', 'Pending', 'U-1001', '', '', NULL, '2026-09-20'),

    ('JS-2026-002', 'Street Light', 'Broken street light near park',
     'The street light opposite the children''s park has been broken for two weeks, making the area unsafe at night.',
     'Farrukhabad', 'In Progress', 'U-1001', 'Electrician assigned, repair scheduled this week.', '', NULL, '2026-09-15'),

    ('JS-2026-003', 'Road Damage', 'Large pothole causing accidents',
     'A deep pothole has formed on the main road near the bus stop. Two-wheelers have skidded here already.',
     'Kanpur', 'Resolved', 'U-1001', 'Road repair team dispatched.', 'Pothole filled and road resurfaced.', '2026-09-12', '2026-09-05')
ON CONFLICT (id) DO NOTHING;

-- Timeline rows (step_order 1-5 = Submitted, Received, Assigned, In Progress, Resolved)
INSERT INTO complaint_timeline (complaint_id, step_order, step_label, done, done_date) VALUES
    ('JS-2026-001', 1, 'Complaint Submitted', true, '2026-09-20'),
    ('JS-2026-001', 2, 'Complaint Received', false, NULL),
    ('JS-2026-001', 3, 'Officer Assigned', false, NULL),
    ('JS-2026-001', 4, 'Work In Progress', false, NULL),
    ('JS-2026-001', 5, 'Problem Resolved', false, NULL),

    ('JS-2026-002', 1, 'Complaint Submitted', true, '2026-09-20'),
    ('JS-2026-002', 2, 'Complaint Received', true, '2026-09-20'),
    ('JS-2026-002', 3, 'Officer Assigned', true, '2026-09-20'),
    ('JS-2026-002', 4, 'Work In Progress', false, NULL),
    ('JS-2026-002', 5, 'Problem Resolved', false, NULL),

    ('JS-2026-003', 1, 'Complaint Submitted', true, '2026-09-20'),
    ('JS-2026-003', 2, 'Complaint Received', true, '2026-09-20'),
    ('JS-2026-003', 3, 'Officer Assigned', true, '2026-09-20'),
    ('JS-2026-003', 4, 'Work In Progress', true, '2026-09-20'),
    ('JS-2026-003', 5, 'Problem Resolved', true, '2026-09-20')
ON CONFLICT (complaint_id, step_order) DO NOTHING;

INSERT INTO notifications (role, user_email, message, read, created_at) VALUES
    ('citizen', 'citizen@test.com', 'Your complaint JS-2026-002 is now In Progress.', false, '2026-09-16'),
    ('citizen', 'citizen@test.com', 'Your complaint JS-2026-003 has been Resolved.', false, '2026-09-12'),
    ('government', NULL, 'New complaint JS-2026-001 received.', false, '2026-09-20');

COMMIT;

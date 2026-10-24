-- ==============================================================================
-- CareLink Digital Healthcare Platform
-- Course: CSE327 - Software Engineering
-- Feature: 2.7 AI Health Assistant Chatbot & Chat History Storage
-- Target Database: PostgreSQL 18 (carelink_cb_db)
-- File: example_queries.sql
-- Description: Example PostgreSQL queries for testing, faculty demo, and data inspection.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. View Chat History for a Specific User (Faculty Demonstration)
-- Retrieves full conversation flow in chronological order for a single user.
-- ------------------------------------------------------------------------------
SELECT 
    id,
    created_at AT TIME ZONE 'Asia/Dhaka' AS time_dhaka,
    user_id,
    UPPER(role) AS sender,
    text,
    doctor_recommendation
FROM ai_assistant_chatmessage
WHERE user_id = 'tayasshuk'
ORDER BY created_at ASC;


-- ------------------------------------------------------------------------------
-- 2. View Only Doctor Specialty Recommendations
-- Filters messages where the AI suggested a medical specialist (e.g. Pulmonologist).
-- ------------------------------------------------------------------------------
SELECT 
    user_id,
    doctor_recommendation,
    text AS ai_advice,
    created_at
FROM ai_assistant_chatmessage
WHERE doctor_recommendation IS NOT NULL
ORDER BY created_at DESC;


-- ------------------------------------------------------------------------------
-- 3. Query Prescription Medicines & Dosages (PostgreSQL JSONB Extraction)
-- Demonstrates querying nested medicine details extracted from prescription uploads.
-- ------------------------------------------------------------------------------
SELECT 
    user_id,
    m->>'name' AS medicine_name,
    m->>'dosage' AS dosage,
    m->>'frequency' AS frequency,
    m->>'purpose' AS purpose,
    m->>'meal_timing' AS meal_timing
FROM ai_assistant_chatmessage,
     jsonb_array_elements(medicines) AS m
WHERE medicines IS NOT NULL;


-- ------------------------------------------------------------------------------
-- 4. Analytics: Patient Message & Interaction Summary
-- Aggregates consultation metrics and message volume grouped per patient.
-- ------------------------------------------------------------------------------
SELECT 
    user_id,
    COUNT(*) AS total_messages,
    COUNT(CASE WHEN role = 'user' THEN 1 END) AS user_queries,
    COUNT(CASE WHEN role = 'model' THEN 1 END) AS ai_replies,
    MIN(created_at) AS first_chat,
    MAX(created_at) AS last_chat
FROM ai_assistant_chatmessage
GROUP BY user_id
ORDER BY total_messages DESC;


-- ------------------------------------------------------------------------------
-- 5. View Active Consultation Sessions
-- Lists all consultation sessions, patient IDs, and their last updated timestamps.
-- ------------------------------------------------------------------------------
SELECT 
    id AS session_id,
    user_id,
    title,
    created_at,
    updated_at
FROM ai_assistant_chatsession
ORDER BY updated_at DESC;


-- ------------------------------------------------------------------------------
-- 6. Insert Sample Conversation (Direct SQL Test Data)
-- Manually inserts a consultation session and an AI reply with structured JSONB medicines.
-- ------------------------------------------------------------------------------
-- Step A: Insert consultation session
INSERT INTO ai_assistant_chatsession (id, user_id, title, created_at, updated_at)
VALUES (
    gen_random_uuid(),
    'tayasshuk',
    'Fever and Cough Consultation',
    NOW(),
    NOW()
);

-- Step B: Insert sample AI response with structured JSON prescription data
INSERT INTO ai_assistant_chatmessage (
    id, user_id, role, text, doctor_recommendation, medicines, created_at
)
VALUES (
    gen_random_uuid(),
    'tayasshuk',
    'model',
    'Based on your symptoms, please rest, stay hydrated, and take paracetamol if the fever persists.',
    'General Physician',
    '[
        {
            "name": "Paracetamol 500mg",
            "dosage": "1 tablet",
            "frequency": "3 times daily",
            "purpose": "Fever reducer",
            "meal_timing": "After meals"
        }
    ]'::jsonb,
    NOW()
);


-- ------------------------------------------------------------------------------
-- 7. Clear History for Only One User (User Isolation Demonstration)
-- Deletes chat records for a specific patient without touching any other user's data.
-- ------------------------------------------------------------------------------
DELETE FROM ai_assistant_chatmessage 
WHERE user_id = 'ayesha';

DELETE FROM ai_assistant_chatsession 
WHERE user_id = 'ayesha';


-- ------------------------------------------------------------------------------
-- 8. Reset All Chat History (Fresh Start)
-- Cleans both tables for a fresh deployment or test cycle.
-- ------------------------------------------------------------------------------
-- TRUNCATE TABLE ai_assistant_chatmessage CASCADE;
-- TRUNCATE TABLE ai_assistant_chatsession CASCADE;

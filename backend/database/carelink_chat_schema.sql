-- ==============================================================================
-- CareLink Digital Healthcare Platform
-- Course: CSE327 - Software Engineering
-- Feature: 2.7 AI Health Assistant Chatbot & Chat History Storage
-- Target Database: PostgreSQL 18 (carelink_cb_db)
-- ==============================================================================

-- 1. Enable UUID Extension (standard for PostgreSQL)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Create ChatSession Table
-- Stores user consultation sessions
CREATE TABLE IF NOT EXISTS ai_assistant_chatsession (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id VARCHAR(100) NOT NULL,
    title VARCHAR(255) NOT NULL DEFAULT 'Health Consultation',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Index for fast user filtering on sessions
CREATE INDEX IF NOT EXISTS idx_chatsession_user_id ON ai_assistant_chatsession (user_id);

-- 3. Create ChatMessage Table
-- Stores each individual message (User queries & AI responses)
CREATE TABLE IF NOT EXISTS ai_assistant_chatmessage (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID REFERENCES ai_assistant_chatsession(id) ON DELETE CASCADE,
    user_id VARCHAR(100) NOT NULL,
    role VARCHAR(10) NOT NULL CHECK (role IN ('user', 'model')),
    text TEXT NOT NULL,
    attachment VARCHAR(255) NULL,
    medicines JSONB NULL,
    doctor_recommendation VARCHAR(255) NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_chatmessage_user_id ON ai_assistant_chatmessage (user_id);
CREATE INDEX IF NOT EXISTS idx_chatmessage_session_id ON ai_assistant_chatmessage (session_id);
CREATE INDEX IF NOT EXISTS idx_chatmessage_created_at ON ai_assistant_chatmessage (created_at);

-- ==============================================================================
-- Useful Verification Queries for Faculty / Demonstration:
-- ==============================================================================

-- View all messages for a specific user:
-- SELECT id, user_id, role, text, doctor_recommendation, created_at 
-- FROM ai_assistant_chatmessage 
-- WHERE user_id = 'tayasshuk' 
-- ORDER BY created_at ASC;

-- View all sessions:
-- SELECT * FROM ai_assistant_chatsession WHERE user_id = 'tayasshuk';

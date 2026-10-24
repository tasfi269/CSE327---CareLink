# CareLink Database Scripts & Queries

This directory contains the PostgreSQL schema definitions and example SQL queries for the **AI Health Assistant Chatbot** feature (Section 2.7) of CareLink.

## Database Information
- **Database Engine:** PostgreSQL 18
- **Database Name:** `carelink_cb_db`
- **Default Port:** `5432`

## Files
1. **[`carelink_chat_schema.sql`](./carelink_chat_schema.sql)**:
   - Full DDL definition (`CREATE TABLE`, `CREATE INDEX`, Foreign Keys) for `ai_assistant_chatsession` and `ai_assistant_chatmessage`.
   - Uses native `UUID` primary keys and PostgreSQL `JSONB` for prescription medicine storage.
2. **[`example_queries.sql`](./example_queries.sql)**:
   - Example SQL queries for faculty demonstrations and testing:
     - User-specific history retrieval.
     - Doctor specialty recommendation filtering.
     - Prescription JSONB data extraction.
     - Patient interaction analytics (`GROUP BY`).
     - Session lookup and user-isolation deletion queries.

## How to Run in pgAdmin 4
1. Open **pgAdmin 4**.
2. Connect to your database: **Servers** ➔ **PostgreSQL 18** ➔ **Databases** ➔ **`carelink_cb_db`**.
3. Click **Tools** ➔ **Query Tool**.
4. Open or copy-paste any query from `example_queries.sql` and press **F5** (Execute).

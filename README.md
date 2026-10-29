# CareLink: AI-Powered Integrated Digital Healthcare Platform

> **Course:** CSE327 - Software Engineering  
> **Project Scope:** Team Healthcare Platform  
> **Feature Module (Section 2.7):** AI Health Assistant Chatbot & User Chat History Management  
> **Student:** Md. Tayasshuk Imam (ID: 2411600042)  
> **Repository:** [https://github.com/tasfi269/CSE327---CareLink](https://github.com/tasfi269/CSE327---CareLink)

---

## 📌 System Architecture

- **Mobile Frontend:** Flutter (Dart) — Material 3 Design conforming to CareLink Brand Guidelines (Navy `#0D1638`, CareLink Teal `#18A795`, Dark Teal `#13897A`, Mint `#F2FAF8`).
- **Backend API:** Django REST Framework (Python 3.10+) with CORS and MultiPart file handling.
- **AI Core:** Google Gemini API (`models/gemini-3.1-flash-lite` with auto-failover to `gemini-flash-lite-latest` and `gemini-3.5-flash`), structured medical schema parsing, and prescription vision extraction.
- **Database:** PostgreSQL 18 (`carelink_cb_db`) storing native `UUID` primary keys, patient user isolation, and structured `JSONB` prescription medicine items.
- **Portals:**
  - 📊 **Chat Management Dashboard:** Real-time analytics, specialist breakdown charts, and patient history controls at `http://localhost:8000/`.
  - 🛡️ **Django Admin Portal:** Direct database record inspection and search at `http://localhost:8000/admin/`.

---

## 📂 Project Structure

```text
CSE327---CareLink/
│
├── start_server.bat            # ⚡ 1-Click zero-config server launcher for Windows
├── README.md                   # Complete setup and evaluation guide
│
├── frontend/                   # Flutter Mobile Application
│   ├── lib/
│   │   ├── core/constants/     # CareLink official brand colors & typography
│   │   ├── features/ai_assistant/ # Chat screen, bubbles, suggestion chips, prescription cards
│   │   ├── models/             # ChatMessage and MedicineItem data models
│   │   ├── services/           # AIChatService (Handles live Django API & offline fallback)
│   │   └── widgets/            # CareLink AppBar, Bottom Navigation
│   └── assets/images/          # Official CareLink logos, icons, and brand guidelines
│
└── backend/                    # Django REST API & AI Backend
    ├── start_server.bat        # 1-Click launcher inside backend directory
    ├── manage.py
    ├── requirements.txt        # All Python dependencies
    ├── init_admin.py           # Auto-creates default admin superuser (admin / admin)
    ├── .env.example            # Environment variables template
    ├── carelink_backend/       # Django configuration & routing (urls, settings)
    ├── ai_assistant/           # Chat models, Gemini service, views, admin registration
    ├── database/               # SQL scripts for faculty review
    │   ├── carelink_chat_schema.sql  # DDL script (CREATE TABLE, INDEXES, FOREIGN KEYS)
    │   ├── example_queries.sql       # Useful queries (user history, JSONB queries, stats)
    │   └── README.md
    └── templates/
        └── dashboard.html      # Responsive Chat Management & Analytics Dashboard
```

---

## 🚀 How to Run from Scratch (On Another Device)

Follow these steps to set up and run the entire platform from a fresh clone:

### Step 1: Clone the Repository
Open a terminal (Git Bash, PowerShell, or Command Prompt):
```bash
git clone https://github.com/tasfi269/CSE327---CareLink.git
cd CSE327---CareLink
```

---

### Step 2: Database Setup (PostgreSQL)

1. Make sure **PostgreSQL 18** (or 14+) is installed and running on port `5432`.
2. Open **pgAdmin 4** (or `psql` command line):
3. Create a new database named **`carelink_cb_db`**:
   ```sql
   CREATE DATABASE carelink_cb_db;
   ```
4. *(Optional verification)*: You can review or execute the raw table schema anytime from:
   [`backend/database/carelink_chat_schema.sql`](backend/database/carelink_chat_schema.sql).

---

### Step 3: Backend Configuration (`.env`)

1. Inside the `backend/` folder, copy `.env.example` to `.env`:
   ```powershell
   cd backend
   copy .env.example .env
   ```
2. Open `backend/.env` in any text editor and configure:
   ```ini
   DJANGO_SECRET_KEY=carelink-cse327-secret-key-development-2026
   DEBUG=True

   # Free Gemini API Key from https://aistudio.google.com/
   GEMINI_API_KEY=your_gemini_api_key_here

   # PostgreSQL Credentials
   DB_NAME=carelink_cb_db
   DB_USER=postgres
   DB_PASSWORD=your_postgres_password
   DB_HOST=localhost
   DB_PORT=5432
   ```

---

### Step 4: Start the Backend Server (⚡ 1-Click Launch)

You can launch the entire backend automatically using the batch script:

- **Option A (Double-Click):** In Windows File Explorer, simply **double-click** `start_server.bat` in the root folder.
- **Option B (From Terminal):**
  ```cmd
  .\start_server.bat
  ```

#### What the script does automatically:
1. Detects or creates a Python virtual environment (`venv`).
2. Installs required packages from `requirements.txt`.
3. Validates `.env`.
4. Applies all database migrations to PostgreSQL (`carelink_cb_db`).
5. Ensures default admin credentials are created.
6. Starts the server at `0.0.0.0:8000`.

---

### Step 5: Start the Flutter Mobile App

Open a new terminal window:
```bash
cd frontend
flutter pub get
```

#### Launching Options:
- **Android Emulator (Recommended):**
  1. Open Android Studio and start your emulator.
  2. Run:
     ```bash
     flutter run
     ```
  *(The mobile app connects to the PC server via `http://10.0.2.2:8000/api/` automatically).*

- **Windows Desktop / Chrome:**
  ```bash
  flutter run -d windows
  # or
  flutter run -d chrome
  ```

---

## 🔑 Portals & Quick Access Links

| Service | URL | Login Credentials | Description |
| :--- | :--- | :--- | :--- |
| **Chat Management Dashboard** | [http://localhost:8000/](http://localhost:8000/) | None (Public) | Real-time analytics, specialist charts, recent chat feed, and patient history manager |
| **Django Admin Portal** | [http://localhost:8000/admin/](http://localhost:8000/admin/) | `admin` / `admin` | Full database management for sessions, messages, and users |
| **AI Chat API Endpoint** | `http://localhost:8000/api/ai-chat/` | REST (POST) | Endpoint for mobile queries and prescription images |
| **User History API** | `http://localhost:8000/api/ai-chat/history/?user_id=...` | REST (GET, DEL) | User-specific conversation retrieval and deletion |

---

## 🎓 Faculty Demonstration Walkthrough

When presenting this project to your faculty, demonstrate the following key features:

### 1. Symptom Assessment & Medical Specialty Triage
1. On the mobile screen, tap the quick prompt chip: *"I have had continuous cough for 3 days"*.
2. Notice the AI analyzes the symptoms and recommends a specialist doctor: **`Pulmonologist (Chest Specialist)`**.
3. In the chat bubble, notice the prominent teal badge highlighting the specialist recommendation.

### 2. Multimodal Prescription Photo Breakdown
1. Tap the camera icon in the chat input bar and select or take a photo of a doctor's prescription.
2. The AI uses computer vision to parse the handwritten/printed medicine items.
3. The response displays structured **Prescription Cards** showing:
   - Medicine name and strength (e.g. *Paracetamol 500mg*, *Omeprazole 20mg*).
   - Indication / Purpose (e.g. *Pain Reliever*, *Acid Reducer*).
   - Frequency & Timing (e.g. *3 times daily*, *After meals*).

### 3. User-Specific Chat History (User Isolation)
1. In the top-right corner of the mobile app, tap the **Patient Switcher** button.
2. Switch from **Tayasshuk Imam** to **Ayesha Rahman**.
3. Observe that Ayesha's chat history is completely distinct and isolated from Tayasshuk's.
4. Messages persist permanently in PostgreSQL even after closing and restarting the app.

### 4. Real-Time Chat Management Dashboard
1. Open your browser and go to [http://localhost:8000/](http://localhost:8000/).
2. Show your faculty:
   - Live KPI cards: Total Consultations, Total Messages, Unique Patients, Prescriptions Analyzed, and Doctor Referrals.
   - Interactive **Medical Specialty Triage Breakdown** doughnut chart.
   - Live conversation stream with **"View Medicines"** modal popup displaying the extracted JSON data.
   - Patient history management with one-click user reset.

### 5. PostgreSQL Database Inspection (pgAdmin 4)
1. Open pgAdmin 4 ➔ `carelink_cb_db` ➔ `Schemas` ➔ `public` ➔ `Tables`.
2. Open `ai_assistant_chatmessage` to show:
   - Native `UUID` primary keys (`id`).
   - Patient partition (`user_id`).
   - Native PostgreSQL `JSONB` column (`medicines`) storing the parsed prescription data.
3. Execute any query from [`backend/database/example_queries.sql`](backend/database/example_queries.sql) to show analytics and data retrieval.

---

## 🛠️ Troubleshooting

- **Android Emulator cannot connect to backend:**
  Make sure the Django server is running on `0.0.0.0:8000` (which `start_server.bat` does by default). Android emulator accesses the host PC using IP `10.0.2.2:8000`.
- **PostgreSQL Connection Error:**
  Ensure the PostgreSQL service is running in Windows Services (`services.msc`) and that your database password matches the `DB_PASSWORD` in `backend/.env`.
- **Gemini API Key:**
  Get a free Gemini API key from [Google AI Studio](https://aistudio.google.com/) and paste it into `backend/.env`. If the key is omitted, the platform gracefully switches to intelligent offline clinical simulation.

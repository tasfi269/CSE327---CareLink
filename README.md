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
- **AI Core:** Google Gemini API (`models/gemini-3.1-flash-lite` with low-latency structured output, medical schema parsing, and prescription vision extraction).
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
│   │   ├── models/             # ChatMessage, MedicineItem, and ChatSessionSummary data models
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
2. Open `backend/.env` in any text editor and configure your credentials:
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

### Step 4: Start the Backend Server

You can choose either the **1-Click automated launch** or the **Manual step-by-step launch**:

#### ⚡ Method A: 1-Click Automated Launch (Recommended)
You can launch the entire backend automatically using the zero-config batch script:
- **Option 1 (Double-Click):** In Windows File Explorer, simply **double-click** `start_server.bat` in the root folder.
- **Option 2 (Terminal):**
  ```cmd
  .\start_server.bat
  ```
*What the script does automatically: detects or creates the virtual environment (`backend/venv`), installs `requirements.txt`, validates `.env`, applies PostgreSQL migrations, creates the default admin account, and starts the server on `0.0.0.0:8000`.*

---

#### 🛠️ Method B: Manual Launch Procedures (Step-by-Step)

If you prefer to run the commands manually or are running on macOS/Linux:

1. **Navigate to the backend directory:**
   ```bash
   cd backend
   ```

2. **Create a Python Virtual Environment:**
   ```bash
   python -m venv venv
   ```

3. **Activate the Virtual Environment:**
   - **Windows (PowerShell):**
     ```powershell
     .\venv\Scripts\Activate.ps1
     ```
   - **Windows (Command Prompt):**
     ```cmd
     .\venv\Scripts\activate.bat
     ```
   - **macOS / Linux:**
     ```bash
     source venv/bin/activate
     ```

4. **Install Python Dependencies:**
   ```bash
   pip install --upgrade pip
   pip install -r requirements.txt
   ```

5. **Apply Database Migrations:**
   ```bash
   python manage.py makemigrations
   python manage.py migrate
   ```

6. **Initialize the Default Admin Account (`admin` / `admin`):**
   ```bash
   python init_admin.py
   ```
   *(Or create a custom superuser via `python manage.py createsuperuser`)*

7. **Run the Django Development Server:**
   ```bash
   python manage.py runserver 0.0.0.0:8000
   ```
   *The server will be live and accepting connections at `http://127.0.0.1:8000/`.*

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
| **AI Chat API Endpoint** | `http://localhost:8000/api/ai-chat/` | REST (POST) | Endpoint for mobile queries, session continuity, and prescription images |
| **Patient Sessions API** | `http://localhost:8000/api/ai-chat/sessions/?user_id=...` | REST (GET, DEL) | List and delete past consultation sessions for a patient |
| **User History API** | `http://localhost:8000/api/ai-chat/history/?user_id=...` | REST (GET, DEL) | User and session-specific conversation retrieval and deletion |

---

## 🛠️ Troubleshooting

- **Android Emulator cannot connect to backend:**
  Make sure the Django server is running on `0.0.0.0:8000` (which `start_server.bat` and `runserver 0.0.0.0:8000` do by default). Android emulator accesses the host PC using IP `10.0.2.2:8000`.
- **PostgreSQL Connection Error:**
  Ensure the PostgreSQL service is running in Windows Services (`services.msc`) and that your database password matches the `DB_PASSWORD` in `backend/.env`.
- **Gemini API Key:**
  Get a free Gemini API key from [Google AI Studio](https://aistudio.google.com/) and paste it into `backend/.env`. If the key is omitted, the platform gracefully switches to intelligent offline clinical simulation.

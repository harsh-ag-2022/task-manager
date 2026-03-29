# Flodo Task Management App

[cite_start]A functional, full-stack Task Management application built for the Flodo AI take-home assignment[cite: 1, 3].

## 📌 Project Overview
* [cite_start]**Track:** Track A (The Full-Stack Builder) [cite: 31, 64]
* [cite_start]**Frontend:** Flutter & Dart 
* [cite_start]**Backend:** Python (FastAPI) [cite: 32]
* [cite_start]**Database:** SQLite [cite: 33]
* [cite_start]**Stretch Goal Implemented:** 1. Debounced Autocomplete Search (Highlights matching text and debounces API calls by 300ms)[cite: 45, 46, 47, 64].

## 🚀 Setup Instructions

### Backend (FastAPI)
1. Navigate to the `backend` directory: `cd backend`
2. Create a virtual environment: `python -m venv venv`
3. Activate the environment: 
   * Windows: `venv\Scripts\activate`
   * Mac/Linux: `source venv/bin/activate`
4. Install dependencies: `pip install -r requirements.txt`
5. Run the server: `uvicorn main:app --reload`
   * The API will be available at `http://localhost:8000`

### Frontend (Flutter)
1. Navigate to the `frontend` directory: `cd frontend`
2. Ensure you have a running emulator or connected device.
3. Fetch packages: `flutter pub get`
4. Run the app: `flutter run`

## 🎥 1-Minute Demo Video
[Insert Google Drive Link Here]
[cite_start]*(Ensure view access is granted to nilay@flodo.ai)* [cite: 59]

## 🤖 AI Usage Report
[cite_start]As encouraged [cite: 52][cite_start], AI tools were utilized to accelerate development[cite: 65]. 

* [cite_start]**Prompts Used:** * "Generate SQLAlchemy models and FastAPI routes based on this JSON structure..." [cite: 54]
    * [cite_start]"Implement a 300ms debounced search in Flutter using Riverpod..." [cite: 54]
* [cite_start]**Hallucinations/Fixes:** * *(Example: The AI initially suggested storing the 'Blocked By' field as a nested object rather than a foreign key integer. I corrected this by explicitly prompting it to use a standard SQL relationship mapping in the FastAPI setup)*[cite: 55].
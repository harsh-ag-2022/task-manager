# Flodo Task Management App

A functional, full-stack Task Management application built for the Flodo AI take-home assignment.

## 📌 Project Overview
* **Track:** Track A (The Full-Stack Builder)
* **Frontend:** Flutter & Dart (Riverpod 3.x for State Management)
* **Backend:** Python (FastAPI)
* **Database:** SQLite (SQLAlchemy)

## ✨ Core Features
* **Draft Content Persistence:** Prevents accidental data loss by keeping your text in the Task Creation form even if you tap away.
* **Mandatory Loading Simulation:** A built-in 2-second delay across all backend CRUD operations to simulate real-world networking latency.
* **Dependency System (Blocked Tasks):** Tasks can explicitly block each other. You cannot move a task to "In Progress" or "Done" if its underlying dependency hasn't been completed.

## 🌟 Enhanced Features Implemented
* **Kanban Board View:** Seamlessly toggle between a traditional List View and an interactive Kanban Board. Contains full drag-and-drop support across status columns.
* **Optimistic UI Updates:** Dragging a task onto the desired column updates the UI instantaneously without being bottlenecked by the 2-second network latency, delivering a perfectly snappy experience with built-in rollback protection if the API eventually fails.
* **Reactive Local Filtering:** Searching and filtering logic actively leverages a full dependency synchronization registry in the background, solving complex UI states where filtering actively hid Blocking Tasks and broke the dependency chain visualization.
* **Debounced Autocomplete Search:** Searches apply a debounced filter query to prevent rapid API spamming and actively highlights matching text segments within the task titles.

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
1. Navigate to the `frontend/task_manager` directory: `cd frontend/task_manager`
2. Ensure you have a running emulator or connected device.
3. Fetch packages: `flutter pub get`
4. Run the app: `flutter run`

## 🎥 1-Minute Demo Video
https://drive.google.com/file/d/1ibHBit4TvAzYAbyKLMhd9BF5NM-H6wW6/view?usp=sharing

## 🤖 AI Usage Report
As encouraged, AI tools were utilized to accelerate development and refine state management architecture.

* **Prompts Used:** 
  * "Generate SQLAlchemy models and FastAPI routes based on this JSON structure..."
  * "Implement a 300ms debounced search in Flutter using Riverpod..."
  * "Create a Kanban board style UI for the task, ensuring that all the task functionality is preserved (especially task blocking). The user should be able to slide their task card around to different sections..."
  * "One critical issue: if a task A is blocked by task B, and I delete task B, then there is no way to alter task A... add functionality to update the status of task A if the task that it is blocked by is deleted."
* **Hallucinations/Fixes:** 
  * *Example 1:* The AI initially suggested storing the 'Blocked By' field as a nested object rather than a foreign key integer. I corrected this by explicitly prompting it to use a standard SQL relationship mapping in the FastAPI setup.
  * *Example 2:* The API filtering caused dependent tasks to lose context of their blockers if a filter was active. We fixed this by restructuring the Riverpod architecture to use a unified `allTasks` sync strategy, completely decoupling manual visual filters from the dependency resolution.
from fastapi import FastAPI, HTTPException, Depends, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import date
from sqlalchemy import create_engine, Column, Integer, String, Date, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
import time
import asyncio

# Database Setup
SQLALCHEMY_DATABASE_URL = "sqlite:///./tasks.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# SQLAlchemy Model
class TaskDB(Base):
    __tablename__ = "tasks"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    description = Column(String)
    due_date = Column(Date)
    status = Column(String, default="To-Do")
    blocked_by = Column(Integer, ForeignKey("tasks.id"), nullable=True)

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Flodo Task Manager API")

# Add CORS middleware for Flutter
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Replace with specific origins in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pydantic Schemas
class TaskBase(BaseModel):
    title: str
    description: str
    due_date: date
    status: str = Field(default="To-Do", description="Enum: 'To-Do', 'In Progress', 'Done'")
    blocked_by: Optional[int] = None

class TaskCreate(TaskBase):
    pass

class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    due_date: Optional[date] = None
    status: Optional[str] = None
    blocked_by: Optional[int] = None

class TaskResponse(TaskBase):
    id: int
    class Config:
        orm_mode = True

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.post("/tasks/", response_model=TaskResponse)
async def create_task(task: TaskCreate, db: Session = Depends(get_db)):
    # Simulating a 2-second delay using asyncio.sleep so as not to block FastAPI's event loop
    await asyncio.sleep(2)
    db_task = TaskDB(**task.dict())
    db.add(db_task)
    db.commit()
    db.refresh(db_task)
    return db_task

@app.get("/tasks/", response_model=List[TaskResponse])
def read_tasks(
    skip: int = 0, 
    limit: int = 100, 
    search: Optional[str] = Query(None, description="Search by title"),
    status: Optional[str] = Query(None, description="Filter by status"),
    db: Session = Depends(get_db)
):
    query = db.query(TaskDB)
    if search:
        query = query.filter(TaskDB.title.ilike(f"%{search}%"))
    if status:
        query = query.filter(TaskDB.status == status)
        
    tasks = query.offset(skip).limit(limit).all()
    return tasks

@app.put("/tasks/{task_id}", response_model=TaskResponse)
async def update_task(task_id: int, task_update: TaskUpdate, db: Session = Depends(get_db)):
    # Simulate a 2-second delay per requirements on Task Update
    await asyncio.sleep(2)
    db_task = db.query(TaskDB).filter(TaskDB.id == task_id).first()
    if not db_task:
        raise HTTPException(status_code=404, detail="Task not found")
        
    update_data = task_update.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_task, key, value)
        
    db.commit()
    db.refresh(db_task)
    return db_task

@app.delete("/tasks/{task_id}")
def delete_task(task_id: int, db: Session = Depends(get_db)):
    db_task = db.query(TaskDB).filter(TaskDB.id == task_id).first()
    if not db_task:
        raise HTTPException(status_code=404, detail="Task not found")
        
    # Cascade unblock dependent tasks
    dependent_tasks = db.query(TaskDB).filter(TaskDB.blocked_by == task_id).all()
    for dt in dependent_tasks:
        dt.blocked_by = None
        
    db.delete(db_task)
    db.commit()
    return {"message": "Task deleted successfully"}
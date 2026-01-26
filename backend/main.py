from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime
import random

app = FastAPI()

# --- КОНФИГУРАЦИЯ БД ---
# Поменяй пароль и пользователя на свои!
DB_CONFIG = {
    "dbname": "ielts_db",
    "user": "postgres",
    "password": "mypassword123", 
    "host": "localhost"
}

# --- МОДЕЛИ ДАННЫХ ---
class UserRegister(BaseModel):
    email: str
    password: str
    nickname: str

class UserLogin(BaseModel):
    email: str
    password: str

class TestResult(BaseModel):
    user_id: int
    test_type: str # 'MOCK', 'Reading', etc.
    answers: dict # Для ИИ анализа

# --- Добавь этот класс к остальным моделям ---
class UserUpdate(BaseModel):
    user_id: int
    nickname: str
    password: Optional[str] = None
    avatar_id: int # Мы будем хранить номер аватарки (0, 1, 2...)

# --- ФУНКЦИИ БАЗЫ ДАННЫХ ---
def get_db_connection():
    try:
        return psycopg2.connect(**DB_CONFIG, cursor_factory=RealDictCursor)
    except:
        return None

# --- ИСКУССТВЕННЫЙ ИНТЕЛЛЕКТ (Эмуляция) ---
def ai_grade_test(answers: dict):
    # Здесь логика твоей ИИ. 
    # Если это Writing - анализируем длину слов и словарь.
    # Если тесты - сравниваем ключи.
    
    score = 0.0
    # Пример простой логики:
    if "writing_text" in answers:
        text_len = len(answers["writing_text"].split())
        score = min(9.0, 4.0 + (text_len / 50)) # Чем больше слов, тем больше балл (до 9)
    else:
        # Рандом для Reading/Listening пока нет реальных ключей
        score = random.choice([5.0, 5.5, 6.0, 6.5, 7.0, 7.5, 8.0])
    
    return round(score, 1)

# --- ENDPOINTS ---

@app.post("/register")
def register(user: UserRegister):
    conn = get_db_connection()
    if not conn: return {"error": "DB Connection failed"}
    try:
        cur = conn.cursor()
        cur.execute("INSERT INTO users (email, password, nickname) VALUES (%s, %s, %s) RETURNING id", 
                    (user.email, user.password, user.nickname))
        user_id = cur.fetchone()['id']
        conn.commit()
        return {"status": "success", "user_id": user_id}
    except Exception as e:
        return {"error": str(e)}
    finally:
        conn.close()

@app.post("/login")
def login(user: UserLogin):
    conn = get_db_connection()
    if not conn: return {"error": "DB Connection failed"} # Для теста без БД можно вернуть fake user
    cur = conn.cursor()
    cur.execute("SELECT * FROM users WHERE email = %s AND password = %s", (user.email, user.password))
    u = cur.fetchone()
    conn.close()
    if u:
        return {"status": "success", "user_id": u['id'], "nickname": u['nickname'], "avatar": u['avatar_url']}
    raise HTTPException(status_code=400, detail="Wrong credentials")

@app.post("/submit_test")
def submit_test(res: TestResult):
    final_score = ai_grade_test(res.answers)
    
    conn = get_db_connection()
    if conn:
        cur = conn.cursor()
        cur.execute("INSERT INTO results (user_id, test_type, score) VALUES (%s, %s, %s)",
                    (res.user_id, res.test_type, final_score))
        conn.commit()
        conn.close()
        
    return {"score": final_score}

@app.get("/history/{user_id}")
def get_history(user_id: int):
    conn = get_db_connection()
    if not conn: return []
    cur = conn.cursor()
    cur.execute("SELECT test_type, score, date FROM results WHERE user_id = %s ORDER BY date DESC", (user_id,))
    data = cur.fetchall()
    conn.close()
    return data

# --- Добавь этот endpoint в конец файла ---
@app.post("/update_profile")
def update_profile(data: UserUpdate):
    conn = get_db_connection()
    if not conn: return {"error": "No DB"}
    
    try:
        cur = conn.cursor()
        # Если пароль пустой, меняем только ник и аватар
        if data.password and len(data.password) > 0:
            cur.execute(
                "UPDATE users SET nickname = %s, password = %s, avatar_url = %s WHERE id = %s",
                (data.nickname, data.password, str(data.avatar_id), data.user_id)
            )
        else:
            cur.execute(
                "UPDATE users SET nickname = %s, avatar_url = %s WHERE id = %s",
                (data.nickname, str(data.avatar_id), data.user_id)
            )
        conn.commit()
        return {"status": "success"}
    except Exception as e:
        return {"error": str(e)}
    finally:
        conn.close()
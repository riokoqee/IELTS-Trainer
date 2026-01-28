from fastapi import FastAPI, HTTPException, UploadFile, File, Form
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import psycopg2
from psycopg2.extras import RealDictCursor
import shutil
import os
import ai_grader 

app = FastAPI()

# --- КОНФИГУРАЦИЯ БД ---
DB_CONFIG = {
    "dbname": "ielts",
    "user": "postgres",
    "password": "mypassword123", 
    "host": "localhost"
}

# --- КЛЮЧИ (Оставляем как есть) ---
LISTENING_MCQ = { "11": 0, "12": 2, "13": 2, "14": 0, "15": 4, "16": 5, "17": 3, "18": 7, "19": 0, "20": 1, "21": 1, "22": 2, "23": 1, "24": 4, "25": 0, "26": 2, "27": 2, "28": 0, "29": 1, "30": 0 }
LISTENING_TEXT = { "1": ["hardie"], "2": ["19"], "3": ["gt8 2lc", "gt82lc"], "4": ["hairdresser"], "5": ["dentist", "dentist's"], "6": ["lighting"], "7": ["trains"], "8": ["safe"], "9": ["shower"], "10": ["training"], "31": ["competition"], "32": ["global"], "33": ["demand"], "34": ["customers"], "35": ["regulation"], "36": ["project"], "37": ["flexible"], "38": ["leadership"], "39": ["women"], "40": ["self-employed", "self employed"] }
READING_MCQ = { "1": 1, "2": 0, "3": 2, "4": 1, "5": 0, "6": 1, "7": 0, "8": 2, "9": 2, "10": 1, "11": 0, "12": 3, "13": 2, "14": 2, "15": 0, "16": 1, "17": 1, "18": 2, "19": 0, "20": 2, "21": 1, "22": 0, "27": 2, "28": 3, "29": 1, "30": 4, "31": 0, "32": 0, "33": 2, "34": 2, "35": 1 }
READING_TEXT = { "23": ["brain dead"], "24": ["sociopathic behaviour", "sociopathic behavior"], "25": ["neocortex"], "26": ["animal propensities"], "36": ["prudent practice"], "37": ["privatisation policy", "privatization policy"], "38": ["incentives"], "39": ["permit"], "40": ["regulatory agency"] }

# =================== МОДЕЛИ ===================
class UserRegister(BaseModel):
    email: str
    password: str
    nickname: str

class UserLogin(BaseModel):
    email: str
    password: str

class TestResult(BaseModel):
    user_id: int
    test_type: str 
    answers: Dict[str, Any]

# НОВАЯ МОДЕЛЬ ДЛЯ СОХРАНЕНИЯ ИТОГА
class FinalResult(BaseModel):
    user_id: int
    test_type: str
    score: float

class UserUpdate(BaseModel):
    user_id: int
    nickname: str
    password: Optional[str] = None
    avatar_str: str

# =================== ФУНКЦИИ ===================
def get_db_connection():
    try:
        return psycopg2.connect(**DB_CONFIG, cursor_factory=RealDictCursor)
    except Exception as e:
        print(f"DB Error: {e}")
        return None

def calculate_details(test_type: str, answers: Dict[str, Any]):
    if "writing_text" in answers:
        text = answers.get("writing_text", "")
        task_mode = "task1" if "Task 1" in test_type else "task2"
        ai_score, feedback = ai_grader.grade_writing(text, task_mode, test_type)
        return {"score": ai_score, "correct": 0, "total": 0, "feedback": feedback}

    target_ids = []
    is_listening = "Listening" in test_type
    
    if is_listening:
        if "Part 1" in test_type: target_ids = [str(i) for i in range(1, 11)]
        elif "Part 2" in test_type: target_ids = [str(i) for i in range(11, 21)]
        elif "Part 3" in test_type: target_ids = [str(i) for i in range(21, 31)]
        elif "Part 4" in test_type: target_ids = [str(i) for i in range(31, 41)]
        else: target_ids = [str(i) for i in range(1, 41)]
    else: 
        if "Passage 1" in test_type: target_ids = [str(i) for i in range(1, 14)]
        elif "Passage 2" in test_type: target_ids = [str(i) for i in range(14, 27)]
        elif "Passage 3" in test_type: target_ids = [str(i) for i in range(27, 41)]
        else: target_ids = [str(i) for i in range(1, 41)]

    total_possible = len(target_ids)
    if total_possible == 0: return {"score": 0.0, "correct": 0, "total": 0}

    correct_mcq = LISTENING_MCQ if is_listening else READING_MCQ
    correct_text = LISTENING_TEXT if is_listening else READING_TEXT
    correct_count = 0
    mcq_user = answers.get("mcq_answers", {})
    text_user = answers.get("text_answers", {})

    for q_id in target_ids:
        if q_id in correct_mcq:
            if q_id in mcq_user and int(mcq_user[q_id]) == correct_mcq[q_id]:
                correct_count += 1
        elif q_id in correct_text:
            if q_id in text_user:
                user_txt = str(text_user[q_id]).lower().strip()
                if user_txt in correct_text[q_id]:
                    correct_count += 1

    accuracy = correct_count / total_possible 
    score = 2.0 
    if accuracy >= 0.90: score = 9.0
    elif accuracy >= 0.85: score = 8.5
    elif accuracy >= 0.80: score = 8.0
    elif accuracy >= 0.75: score = 7.5
    elif accuracy >= 0.70: score = 7.0
    elif accuracy >= 0.65: score = 6.5
    elif accuracy >= 0.55: score = 6.0
    elif accuracy >= 0.45: score = 5.5
    elif accuracy >= 0.35: score = 5.0
    elif accuracy >= 0.25: score = 4.5
    elif accuracy >= 0.15: score = 4.0

    return {"score": score, "correct": correct_count, "total": total_possible}

# =================== ENDPOINTS ===================

@app.post("/register")
def register(user: UserRegister):
    conn = get_db_connection()
    if not conn: raise HTTPException(status_code=500, detail="DB Error")
    try:
        cur = conn.cursor()
        email = user.email.lower()
        if not (email.endswith("@gmail.com") or email.endswith("@mail.ru")):
            raise HTTPException(status_code=400, detail="Only gmail/mail.ru allowed")
        
        cur.execute("SELECT id FROM users WHERE email = %s", (email,))
        if cur.fetchone(): raise HTTPException(status_code=400, detail="Email taken")

        cur.execute(
            "INSERT INTO users (email, password, nickname, avatar_url, last_score) VALUES (%s, %s, %s, '😀', 0.0) RETURNING id", 
            (email, user.password, user.nickname)
        )
        uid = cur.fetchone()['id']
        conn.commit()
        return {"status": "success", "user_id": uid, "nickname": user.nickname, "avatar": "😀"}
    except HTTPException as he: raise he
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally: conn.close()

@app.post("/login")
def login(user: UserLogin):
    conn = get_db_connection()
    if not conn: raise HTTPException(status_code=500, detail="DB Error")
    try:
        cur = conn.cursor()
        cur.execute("SELECT * FROM users WHERE email = %s AND password = %s", (user.email.lower(), user.password))
        u = cur.fetchone()
        if u: return {
            "status": "success", 
            "user_id": u['id'], 
            "nickname": u['nickname'], 
            "avatar": u['avatar_url'],
            "last_score": u.get('last_score', 0.0)
        }
        else: raise HTTPException(status_code=401, detail="Wrong credentials")
    finally: conn.close()

# --- ИСПРАВЛЕНИЕ: submit_test ТОЛЬКО ОЦЕНИВАЕТ (НЕ СОХРАНЯЕТ) ---
@app.post("/submit_test")
def submit_test(res: TestResult):
    # Просто возвращаем баллы, базу не трогаем
    return calculate_details(res.test_type, res.answers)

# --- ИСПРАВЛЕНИЕ: submit_speaking ТОЛЬКО ОЦЕНИВАЕТ (НЕ СОХРАНЯЕТ) ---
@app.post("/submit_speaking")
def submit_speaking(
    user_id: int = Form(...), 
    test_type: str = Form(...),
    audio: UploadFile = File(...)
):
    try:
        file_location = f"temp_{user_id}.mp3"
        with open(file_location, "wb+") as file_object:
            shutil.copyfileobj(audio.file, file_object)
        
        # Только ИИ, без SQL Insert
        score, feedback = ai_grader.grade_speaking(file_location, test_type)
        
        os.remove(file_location)
        
        return {"score": score, "feedback": feedback}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# --- НОВЫЙ ЭНДПОИНТ: СОХРАНЯЕТ ТОЛЬКО ИТОГ ---
@app.post("/save_result")
def save_result(data: FinalResult):
    conn = get_db_connection()
    if not conn: raise HTTPException(status_code=500, detail="DB Error")
    try:
        cur = conn.cursor()
        # 1. Запись в историю (одна запись для всего теста)
        cur.execute(
            "INSERT INTO results (user_id, test_type, score, date) VALUES (%s, %s, %s, NOW())", 
            (data.user_id, data.test_type, data.score)
        )
        # 2. Обновление балла на главной
        cur.execute(
            "UPDATE users SET last_score = %s WHERE id = %s", 
            (data.score, data.user_id)
        )
        conn.commit()
        return {"status": "saved"}
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    finally: conn.close()

# --- ИСПРАВЛЕННЫЙ ПУТЬ ДЛЯ ИСТОРИИ ---
@app.get("/history/{user_id}")
def get_history(user_id: int):
    conn = get_db_connection()
    if not conn: return []
    try:
        cur = conn.cursor()
        cur.execute("""
            SELECT test_type, score, to_char(date, 'DD.MM.YYYY HH24:MI') as date_str 
            FROM results 
            WHERE user_id = %s 
            ORDER BY id DESC 
            LIMIT 50
        """, (user_id,))
        
        rows = cur.fetchall()
        return [{"test_type": r['test_type'], "score": r['score'], "date": r['date_str']} for r in rows]
    finally: conn.close()

@app.post("/update_profile")
def update_profile(data: UserUpdate):
    conn = get_db_connection()
    if not conn: raise HTTPException(status_code=500, detail="DB Error")
    try:
        cur = conn.cursor()
        if data.password:
            cur.execute("UPDATE users SET nickname=%s, password=%s, avatar_url=%s WHERE id=%s", (data.nickname, data.password, data.avatar_str, data.user_id))
        else:
            cur.execute("UPDATE users SET nickname=%s, avatar_url=%s WHERE id=%s", (data.nickname, data.avatar_str, data.user_id))
        conn.commit()
        return {"status": "success"}
    finally: conn.close()
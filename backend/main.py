from fastapi import FastAPI, HTTPException, UploadFile, File, Form
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import psycopg2
from psycopg2.extras import RealDictCursor
import shutil
import os
import ai_grader  # <--- Твой файл с ИИ (spacy, whisper)

app = FastAPI()

# --- КОНФИГУРАЦИЯ БД ---
DB_CONFIG = {
    "dbname": "ielts",
    "user": "postgres",
    "password": "mypassword123", 
    "host": "localhost"
}

# =================== КЛЮЧИ ОТВЕТОВ ===================

# --- LISTENING KEYS (1-40) ---
LISTENING_MCQ = {
    # Part 2 (11-20)
    "11": 0, "12": 2, "13": 2, "14": 0,
    "15": 4, "16": 5, "17": 3, "18": 7, "19": 0, "20": 1,
    # Part 3 (21-30)
    "21": 1, "22": 2, "23": 1, "24": 4,
    "25": 0, "26": 2, "27": 2, "28": 0, "29": 1, "30": 0
}

LISTENING_TEXT = {
    # Part 1 (1-10)
    "1": ["hardie"],
    "2": ["19"],
    "3": ["gt8 2lc", "gt82lc"],
    "4": ["hairdresser"],
    "5": ["dentist", "dentist's"],
    "6": ["lighting"],
    "7": ["trains"],
    "8": ["safe"],
    "9": ["shower"],
    "10": ["training"],
    # Part 4 (31-40)
    "31": ["competition"],
    "32": ["global"],
    "33": ["demand"],
    "34": ["customers"],
    "35": ["regulation"],
    "36": ["project"],
    "37": ["flexible"],
    "38": ["leadership"],
    "39": ["women"],
    "40": ["self-employed", "self employed"]
}

# --- READING KEYS (1-40) ---
READING_MCQ = {
    # Passage 1
    "1": 1, "2": 0, "3": 2, "4": 1, "5": 0, "6": 1, "7": 0,
    "8": 2, "9": 2, "10": 1, "11": 0, "12": 3, "13": 2,
    # Passage 2
    "14": 2, "15": 0, "16": 1, "17": 1, "18": 2, "19": 0, "20": 2, "21": 1, "22": 0,
    # Passage 3
    "27": 2, "28": 3, "29": 1, "30": 4, "31": 0,
    "32": 0, "33": 2, "34": 2, "35": 1
}

READING_TEXT = {
    # Passage 2
    "23": ["brain dead"],
    "24": ["sociopathic behaviour", "sociopathic behavior"],
    "25": ["neocortex"],
    "26": ["animal propensities"],
    # Passage 3
    "36": ["prudent practice"],
    "37": ["privatisation policy", "privatization policy"],
    "38": ["incentives"],
    "39": ["permit"],
    "40": ["regulatory agency"]
}

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
    # --- 1. WRITING (ПРОВЕРКА ЧЕРЕЗ ИИ) ---
    if "writing_text" in answers:
        text = answers.get("writing_text", "")
        # Определяем тип задания для ИИ
        task_mode = "task1" if "Task 1" in test_type else "task2"
        
        # Вызываем функцию из ai_grader.py
        ai_score, feedback = ai_grader.grade_writing(text, task_mode)
        
        return {
            "score": ai_score, 
            "correct": 0, 
            "total": 0, 
            "feedback": feedback
        }

    # --- 2. LISTENING / READING (АВТО-ПРОВЕРКА ПО КЛЮЧАМ) ---
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
    if total_possible == 0: 
        return {"score": 0.0, "correct": 0, "total": 0}

    correct_mcq = LISTENING_MCQ if is_listening else READING_MCQ
    correct_text = LISTENING_TEXT if is_listening else READING_TEXT

    correct_count = 0
    mcq_user = answers.get("mcq_answers", {})
    text_user = answers.get("text_answers", {})

    for q_id in target_ids:
        # Проверка MCQ
        if q_id in correct_mcq:
            if q_id in mcq_user and int(mcq_user[q_id]) == correct_mcq[q_id]:
                correct_count += 1
        
        # Проверка Текста
        elif q_id in correct_text:
            if q_id in text_user:
                user_txt = str(text_user[q_id]).lower().strip()
                if user_txt in correct_text[q_id]:
                    correct_count += 1

    # Расчет балла (Approximate IELTS Band)
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
            "INSERT INTO users (email, password, nickname, avatar_url) VALUES (%s, %s, %s, '😀') RETURNING id", 
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
        if u: return {"status": "success", "user_id": u['id'], "nickname": u['nickname'], "avatar": u['avatar_url']}
        else: raise HTTPException(status_code=401, detail="Wrong credentials")
    finally: conn.close()

@app.post("/submit_test")
def submit_test(res: TestResult):
    # Эта функция теперь умеет работать и с тестами, и с эссе (через ИИ)
    result_data = calculate_details(res.test_type, res.answers)
    final_score = result_data["score"]
    
    conn = get_db_connection()
    if conn:
        try:
            cur = conn.cursor()
            cur.execute("INSERT INTO results (user_id, test_type, score) VALUES (%s, %s, %s)", (res.user_id, res.test_type, final_score))
            conn.commit()
        except Exception as e: print(f"Error saving: {e}")
        finally: conn.close()
        
    return result_data

# --- НОВЫЙ ЭНДПОИНТ ДЛЯ SPEAKING (ЗАГРУЗКА АУДИО) ---
@app.post("/submit_speaking")
def submit_speaking(
    user_id: int = Form(...), 
    test_type: str = Form(...),
    audio: UploadFile = File(...)
):
    try:
        # 1. Сохраняем файл временно
        file_location = f"temp_{user_id}.mp3"
        with open(file_location, "wb+") as file_object:
            shutil.copyfileobj(audio.file, file_object)
        
        # 2. Вызываем ИИ (Whisper + анализ текста)
        score, feedback = ai_grader.grade_speaking(file_location, test_type)
        
        # 3. Удаляем файл
        os.remove(file_location)
        
        # 4. Сохраняем результат в БД
        conn = get_db_connection()
        if conn:
            cur = conn.cursor()
            cur.execute(
                "INSERT INTO results (user_id, test_type, score) VALUES (%s, %s, %s)",
                (user_id, test_type, score)
            )
            conn.commit()
            conn.close()

        return {"score": score, "feedback": feedback}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/history/{user_id}")
def get_history(user_id: int):
    conn = get_db_connection()
    if not conn: return []
    try:
        cur = conn.cursor()
        cur.execute("SELECT test_type, score, date FROM results WHERE user_id = %s ORDER BY date DESC", (user_id,))
        return cur.fetchall()
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
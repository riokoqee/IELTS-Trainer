import spacy
import language_tool_python
import textstat
import whisper
import os
from collections import Counter
from langdetect import detect, DetectorFactory

# Фиксация сида для дететора языка
DetectorFactory.seed = 0

# Загрузка NLP моделей
try:
    nlp = spacy.load("en_core_web_md")
    has_vectors = True
except:
    print("WARNING: 'en_core_web_md' not found. Using basic mode.")
    try:
        nlp = spacy.load("en_core_web_sm")
        has_vectors = False
    except:
        nlp = None

tool = language_tool_python.LanguageTool('en-US')
whisper_model = whisper.load_model("base")

# === 1. СЛОВАРИ ДЛЯ ПРОВЕРКИ ТЕМЫ (HARD FILTERS) ===
TOPIC_REQUIRED_VOCAB = {
    # Part 1: Introduction (Hometown)
    "Speaking Part 1": [
        "city", "town", "village", "live", "living", "reside", "apartment", "flat", 
        "house", "home", "located", "area", "neighborhood", "district", "born", 
        "grew", "population", "capital", "hometown", "suburb", "streets", "building"
    ],
    # Part 2: Cue Card (Describe a website)
    "Speaking Part 2": [
        "website", "site", "internet", "online", "web", "browser", "search", "google",
        "social", "media", "useful", "information", "shopping", "watch", "content",
        "design", "interface", "user", "connection", "link"
    ],
    # Part 3: Discussion (Internet & Society)
    "Speaking Part 3": [
        "society", "global", "communication", "connect", "negative", "positive",
        "impact", "technology", "future", "addiction", "children", "education",
        "access", "information", "news", "fake", "privacy", "security", "world"
    ],
    # Writing Task 2
    "Writing Task 2: Opinion Essay": [
        "language", "english", "speak", "learn", "taught", "school", "communication", 
        "global", "local", "native", "foreign", "culture", "heritage", 
        "education", "curriculum", "students", "subject", "society", "world"
    ]
}

# === 2. СЛОВАРИ ДЛЯ ПРОВЕРКИ ТИПА ЗАДАНИЯ (TASK MISMATCH) ===
TASK_TYPE_MARKERS = {
    "task1": [
        "graph", "chart", "diagram", "table", "figure", "axis", "vertical", "horizontal",
        "illustrates", "shows", "proportion", "percentage", "percent", "data", "respectively",
        "rose", "fell", "fluctuated", "peak", "trend", "category", "compare"
    ],
    "task2": [
        "opinion", "agree", "disagree", "believe", "think", "argument", "conclusion",
        "society", "government", "problem", "solution", "reason", "hand", "furthermore",
        "moreover", "therefore", "essential", "issue", "view"
    ]
}

# Фразы из задания, которые нельзя копировать
PROMPT_PHRASES = [
    "summarise the information", "select and report the main features", 
    "make comparisons where relevant", "write at least 150 words",
    "write at least 250 words", "give reasons for your answer",
    "include any relevant examples", "own knowledge or experience"
]

# --- ФУНКЦИИ ПРОВЕРКИ ---

def check_is_prompt_copy(text):
    """Проверяет, не скопировал ли юзер куски задания."""
    text_lower = text.lower()
    matches = 0
    for phrase in PROMPT_PHRASES:
        if phrase in text_lower:
            matches += 1
    
    if matches >= 1:
        return True
    return False

def check_task_type_integrity(user_doc, current_task_type):
    """
    Проверяет, соответствует ли стиль письма заданию.
    Task 1 (график) не должен выглядеть как Task 2 (эссе) и наоборот.
    """
    # Для Speaking эта проверка не нужна
    if current_task_type == "speaking":
        return 1.0

    lemmas = [token.lemma_.lower() for token in user_doc]
    
    # Считаем маркеры
    t1_score = sum(1 for word in TASK_TYPE_MARKERS["task1"] if word in lemmas)
    t2_score = sum(1 for word in TASK_TYPE_MARKERS["task2"] if word in lemmas)
    
    # ЛОГИКА:
    # Если это Task 1, но маркеров Task 2 больше в 3 раза -> Ошибка
    if current_task_type == "task1":
        # В Task 1 обязательно должны быть слова данных (graph, percent...)
        if t1_score == 0 and t2_score > 2:
            return 0.5 # Это Эссе, вставленное в График
            
    # Если это Task 2, но маркеров Task 1 очень много (graph, axis...) -> Ошибка
    if current_task_type == "task2":
        if t1_score > 3 and t2_score == 0:
            return 0.6 # Это описание Графика, вставленное в Эссе
            
    return 1.0

def check_language_is_english(text):
    try:
        if len(text.split()) < 3: return True 
        lang = detect(text)
        if lang != 'en': return False
        return True
    except: return True

def check_relevance_hard(user_text, user_doc, test_title):
    if test_title not in TOPIC_REQUIRED_VOCAB: return 'ok'
    
    user_lemmas = {token.lemma_.lower() for token in user_doc}
    required_words = TOPIC_REQUIRED_VOCAB[test_title]
    
    matches = 0
    for word in required_words:
        if word in user_text.lower() or word in user_lemmas:
            matches += 1
    
    if matches < 2: return 'off_topic'
    return 'ok'

def check_repetition(user_doc):
    words = [token.lemma_.lower() for token in user_doc if not token.is_stop and not token.is_punct and token.is_alpha]
    if not words: return 0.0
    
    counts = Counter(words)
    if not counts: return 0.0
    
    _, frequency = counts.most_common(1)[0]
    ratio = frequency / len(words)
    
    if len(words) > 20 and ratio > 0.20: return 1.5
    if len(words) > 20 and ratio > 0.15: return 0.5
    return 0.0

def analyze_text_metrics(text):
    if not text or not text.strip(): return None
    
    # Проверка языка
    if not check_language_is_english(text): return {"error": "wrong_language"}
    
    # Проверка на копипаст задания
    if check_is_prompt_copy(text): return {"error": "prompt_copy"}

    doc = nlp(text)
    words = [token.text for token in doc if token.is_alpha]
    word_count = len(words)
    
    if word_count == 0: return {"error": "no_words"}

    matches = tool.check(text)
    error_count = len(matches)
    
    unique_lemmas = set([token.lemma_ for token in doc if token.is_alpha])
    diversity = len(unique_lemmas) / word_count if word_count > 0 else 0
    readability = textstat.flesch_kincaid_grade(text)
    sentence_count = len(list(doc.sents))

    return { 
        "doc": doc, "cnt": word_count, "err": error_count, 
        "div": diversity, "read": readability, 
        "sents": sentence_count, "text": text 
    }

def calculate_strict_score(metrics, task_type, test_title=""):
    # Обработка грубых нарушений
    if "error" in metrics:
        if metrics["error"] == "wrong_language": return 1.0, "Wrong language detected."
        if metrics["error"] == "prompt_copy": return 1.0, "Do not copy the task instructions."
        if metrics["error"] == "no_words": return 0.0, "No text provided."

    cnt = metrics['cnt']
    err = metrics['err']
    div = metrics['div']
    doc = metrics['doc']
    text = metrics['text']
    
    # 1. ПРОВЕРКА ТИПА ЗАДАНИЯ (Task 1 vs Task 2)
    type_integrity = check_task_type_integrity(doc, task_type)
    type_msg = ""
    if type_integrity == 0.5:
        return 2.5, "Wrong Format: Do not write an Opinion Essay in Task 1 (Graph)."
    elif type_integrity == 0.6:
        return 2.5, "Wrong Format: Do not describe a Graph in Task 2 (Essay)."

    # 2. ПРОВЕРКА ТЕМЫ (HARD CAP)
    relevance_status = check_relevance_hard(text, doc, test_title)
    if relevance_status == 'off_topic':
        return 3.0, f"Off-topic answer. Keywords missing."

    # 3. ПРОВЕРКА ПОВТОРОВ
    repetition_penalty = check_repetition(doc)

    # 4. ЛИМИТЫ СЛОВ
    if task_type == "speaking":
        min_limit = 40
        if cnt < 5: return 1.0, "Silence / Noise."
        if cnt < 20: return 2.0, "Too short."
    else:
        min_limit = 150 if task_type == "task1" else 250
        if cnt < 20: return 1.0, "Irrelevant."
        if cnt < 50: return 2.5, "Extremely short."

    # 5. РАСЧЕТ БАЛЛОВ
    
    # Task Response
    score_tr = 9.0
    if cnt < min_limit:
        step = 10 if task_type == "speaking" else 20
        penalty = (min_limit - cnt) / step
        score_tr = max(4.0, 9.0 - penalty)
    
    # Grammar
    errors_per_100 = (err / cnt) * 100
    thresholds = [2, 5, 8, 12] if task_type == "speaking" else [1, 3, 6, 10]
    
    if errors_per_100 <= thresholds[0]: score_gra = 9.0
    elif errors_per_100 <= thresholds[1]: score_gra = 7.5
    elif errors_per_100 <= thresholds[2]: score_gra = 6.0
    elif errors_per_100 <= thresholds[3]: score_gra = 5.0
    else: score_gra = 4.0

    # Vocabulary
    score_lr = 6.0
    if div > 0.60: score_lr += 1.0
    elif div < 0.40: score_lr -= 1.0
    score_lr -= repetition_penalty

    # Coherence
    score_cc = (score_tr + score_lr) / 2
    if task_type == "speaking" and cnt > 90: score_cc += 0.5

    # ИТОГ
    final_score = (score_tr + score_gra + score_lr + score_cc) / 4
    final_score = round(final_score * 2) / 2
    final_score = min(9.0, max(1.0, final_score))
    
    repetition_msg = " [Repetitions]" if repetition_penalty > 0 else ""
    return final_score, f"Words: {cnt}.{repetition_msg}"

# --- API ---

def grade_writing(text, task_type):
    metrics = analyze_text_metrics(text)
    if not metrics: return 0.0, "No text."
    
    # Если была ошибка языка или копипаста, возвращаем сразу
    if "error" in metrics:
        s, f = calculate_strict_score(metrics, task_type) # Вернет 1.0
        return s, f

    title = "Writing Task 2: Opinion Essay" if task_type == "task2" else "Writing Task 1"
    return calculate_strict_score(metrics, task_type, title)

def grade_speaking(audio_path, test_title="Speaking Part 1: Introduction"):
    try:
        result = whisper_model.transcribe(audio_path, language="en")
        text = result["text"].strip()
        if not text: return 1.0, "Silence detected."
        metrics = analyze_text_metrics(text)
        if "error" in metrics: return 1.0, metrics["error"]
        
        score, feedback = calculate_strict_score(metrics, "speaking", test_title)
        return score, f"Transcribed: \"{text[:40]}...\" {feedback}"
    except Exception as e:
        print(f"Speaking Error: {e}")
        return 1.0, "Error processing audio"
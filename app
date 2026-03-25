# ==============================================================
#  MATH QUEST PRO — Archivo Único y Definitivo
#  Versión corregida, optimizada y unificada
# ==============================================================

# ╔══════════════════════════════════════════════════════════════╗
# ║  SECCIÓN 1: IMPORTACIONES Y CONFIGURACIÓN                   ║
# ╚══════════════════════════════════════════════════════════════╝

import streamlit as st
import random
import time
import requests
import logging
import io

import matplotlib
matplotlib.use('Agg')  # Backend no interactivo: evita crashes en servidores headless
import matplotlib.pyplot as plt

# --- Configuración de la página (DEBE ser la primera llamada a Streamlit) ---
st.set_page_config(
    page_title="Math Quest Pro",
    page_icon="⚡",
    layout="centered",
    initial_sidebar_state="collapsed"
)

# --- Constantes globales ---
MONEDA = "P"  # Prefijo monetario (cambiar a "MXN", "COP", etc.)
PUNTAJE_MINIMO = 3
PREGUNTAS_POR_MISION = 5
GOOGLE_SCRIPT_URL = (
    "https://script.google.com/macros/s/"
    "AKfycbzYQFJorxYOHQ8KPODNRQKizq0O7ddI7lkg3nBLJCRIvs6UdOKpwrBWDfn-XmDsPoVWnw/exec"
)
MENSAJES_MOTIVACION = [
    "¡Vas por excelente camino! 🔥",
    "¡Concéntrate, tú puedes! 💪",
    "¡Eres imparable! ⚡",
    "¡Sigue así, guerrero! 🛡️",
    "¡La victoria está cerca! 🏆",
]


# ╔══════════════════════════════════════════════════════════════╗
# ║  SECCIÓN 2: CSS DE NUEVA GENERACIÓN (ESTILO GAMING)         ║
# ╚══════════════════════════════════════════════════════════════╝

st.markdown("""
<style>
    /* ========== FONDO ANIMADO ========== */
    .stApp {
        background: linear-gradient(-45deg, #461a42, #2d0b2a, #3a0ca3, #0f0c29);
        background-size: 400% 400%;
        animation: gradient 15s ease infinite;
        overflow-x: hidden;
    }
    @keyframes gradient {
        0%   { background-position: 0% 50%; }
        50%  { background-position: 100% 50%; }
        100% { background-position: 0% 50%; }
    }

    /* ========== PANEL DE ESTADO SUPERIOR ========== */
    .status-panel {
        background-color: white;
        border-radius: 50px;
        padding: 10px 20px;
        text-align: center;
        color: #461a42;
        font-weight: bold;
        font-size: 1.2rem;
        margin-bottom: 15px;
        box-shadow: 0 4px 8px rgba(0,0,0,0.2);
    }

    /* ========== BARRA DE ENERGÍA TIPO RPG ========== */
    .energy-bar-bg {
        width: 100%;
        background: #333;
        border-radius: 15px;
        height: 20px;
        border: 2px solid #555;
        margin-bottom: 8px;
        overflow: hidden;
    }
    .energy-bar-fill {
        height: 100%;
        border-radius: 12px;
        transition: width 1s linear;
    }
    .energy-bar-fill.time-bar {
        background: linear-gradient(90deg, #ff4b4b 0%, #ff8c00 50%, #00f2fe 100%);
    }
    .energy-bar-fill.progress-bar {
        background: linear-gradient(90deg, #00f2fe 0%, #4facfe 100%);
    }

    /* ========== ANIMACIÓN PARPADEO TIEMPO BAJO ========== */
    @keyframes blink-warning {
        0%, 100% { opacity: 1; }
        50%      { opacity: 0.3; }
    }
    .time-critical {
        animation: blink-warning 0.8s ease-in-out infinite;
    }

    /* ========== TARJETA GLASSMORPHISM ========== */
    .question-card {
        background: rgba(255, 255, 255, 0.95);
        border-left: 8px solid #ff4b4b;
        border-radius: 20px;
        padding: 25px;
        margin-bottom: 15px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.5);
        transition: all 0.3s ease;
    }
    .question-card:hover {
        box-shadow: 0 14px 36px rgba(0,0,0,0.6);
        transform: translateY(-2px);
    }

    /* ========== OPCIONES RADIO ========== */
    div[data-testid="stRadio"] > div {
        background: rgba(255,255,255,0.1);
        padding: 20px;
        border-radius: 15px;
    }
    div[data-testid="stRadio"] label p {
        color: white !important;
        font-size: 1.3rem !important;
        font-weight: bold !important;
        text-shadow: 1px 1px 2px black;
    }
    div[data-testid="stRadio"] label {
        margin-right: 20px;
    }

    /* ========== TEXTO MARKDOWN ========== */
    .stMarkdown p {
        color: white !important;
        font-weight: bold;
        line-height: 1.6;
    }
    .stMarkdown h2, .stMarkdown h3 {
        color: white !important;
        font-weight: bold;
        text-align: center;
    }

    /* ========== BOTONES ========== */
    .stButton > button {
        border-radius: 15px;
        font-weight: bold;
        padding: 10px 20px;
        font-size: 1.1rem;
        border: none;
        transition: all 0.3s ease;
    }
    .stButton > button:hover {
        background-color: #ff4b4b !important;
        color: white !important;
        box-shadow: 0 2px 6px rgba(255,75,75,0.4);
        transform: scale(1.03);
    }
    button[kind="primary"] {
        background-color: #ff4b4b !important;
        color: white !important;
    }
    button[kind="primary"]:hover {
        background-color: #e53e3e !important;
    }

    /* ========== BOTÓN 50/50 ========== */
    .btn-5050 button {
        background-color: #fbbf24 !important;
        color: #2d0b2a !important;
        font-size: 1rem !important;
    }
    .btn-5050 button:hover {
        background-color: #e6a23f !important;
    }

    /* ========== TOAST ========== */
    .stToast div > span {
        font-size: 1.1rem !important;
        text-shadow: 1px 1px 2px black;
    }

    /* ========== IMÁGENES ========== */
    .stImage {
        display: block;
        margin: 0 auto;
    }

    /* ========== REGISTRO ========== */
    .registration-footer {
        height: 2px;
        background-color: #3a0ca3;
        margin-top: 20px;
        border-radius: 5px;
        width: 100%;
    }

    /* ========== SELECTBOX ========== */
    div[data-testid="stSelectbox"] div[data-baseweb="select"] > div {
        border-radius: 15px !important;
        background-color: white;
        border: 1px solid #ccc;
    }
</style>
""", unsafe_allow_html=True)


# ╔══════════════════════════════════════════════════════════════╗
# ║  SECCIÓN 3: BANCO DE PREGUNTAS                              ║
# ╚══════════════════════════════════════════════════════════════╝

def _validar_banco(banco: list) -> list:
    """Valida integridad del banco: respuestas en opciones, sin duplicados."""
    errores = []
    ids_vistos = set()

    for i, p in enumerate(banco):
        # Campos obligatorios
        for campo in ("id", "mision", "pregunta", "opciones", "correcta_texto", "t_max"):
            if campo not in p:
                errores.append(f"Pregunta índice {i}: falta campo '{campo}'")

        pid = p.get("id", f"idx_{i}")

        # IDs duplicados
        if pid in ids_vistos:
            errores.append(f"'{pid}': ID duplicado")
        ids_vistos.add(pid)

        # Respuesta correcta en opciones
        if p.get("correcta_texto") and p.get("opciones"):
            if p["correcta_texto"] not in p["opciones"]:
                errores.append(
                    f"'{pid}': respuesta '{p['correcta_texto']}' "
                    f"NO está en opciones: {p['opciones']}"
                )

        # Opciones duplicadas
        if p.get("opciones"):
            if len(set(p["opciones"])) < len(p["opciones"]):
                dupes = [o for o in p["opciones"] if p["opciones"].count(o) > 1]
                errores.append(f"'{pid}': opciones duplicadas: {set(dupes)}")

    for e in errores:
        st.warning(f"⚠️ Banco: {e}")

    return banco


if 'banco_completo' not in st.session_state:
    _banco_raw = [
        # ================= TEMA A — MISIÓN 1 =================
        {
            "id": "A1", "mision": 1, "t_max": 275,
            "pregunta": "Un dron de vigilancia vuela en línea recta pasando por A=(-4,8) y B=(4,2). ¿Cuál es su pendiente (m) y su altura inicial (b)?",
            "opciones": ["m = 5, b = -3/4", "m = 3/4, b = -5", "m = -3/4, b = -5", "m = -3/4, b = 5"],
            "correcta_texto": "m = -3/4, b = 5"
        },
        {
            "id": "A2", "mision": 1, "t_max": 275,
            "pregunta": "En un mapa de coordenadas, una carretera une A(1, 3) con B(2, 10). ¿Cuál es la ecuación que describe esta ruta?",
            "opciones": ["y = 3/7x + 4", "y = 2/7x - 4", "y = -2/7x - 4", "y = 7x - 4"],
            "correcta_texto": "y = 7x - 4"
        },
        {
            "id": "A3", "mision": 1, "t_max": 275,
            "pregunta": "Un rayo láser se dispara desde P(-6, 2) con una inclinación m = -2/3. ¿Cuál es su fórmula de trayectoria?",
            "opciones": ["y = -2/3x - 2", "y = -2/3x - 3", "y = -3/2x - 3", "y = -3/2x - 2"],
            "correcta_texto": "y = -2/3x - 2"
        },
        {
            "id": "A4", "mision": 1, "t_max": 260,
            "pregunta": "La trayectoria de un barco es y = -4/5x - 3. ¿Cuál de estas rutas es PARALELA a la del barco?",
            "opciones": ["y = -4/5x + 3", "y = 5/4x + 2", "y = 4/5x + 10", "y = -5/4x - 7"],
            "correcta_texto": "y = -4/5x + 3"
        },
        {
            "id": "A5", "mision": 1, "t_max": 260,
            "pregunta": "Para cruzar un río de forma PERPENDICULAR a la corriente (y = 2/3x + 1), ¿qué trayectoria debe seguir el bote?",
            "opciones": ["y = 2/3x - 5", "y = 3/2x + 2", "y = -2/3x + 4", "y = -3/2x + 5"],
            "correcta_texto": "y = -3/2x + 5"
        },
        {
            "id": "A6", "mision": 1, "t_max": 280,
            "pregunta": "Una pendiente de m = -5/4 pasa por el punto (4,2). ¿Qué ecuación la representa y por qué otro punto pasa?",
            "opciones": [
                "y = -4/5x + 5 pasa por (9,-2)",
                "y = -5/4x + 7 pasa por (8,-3)",
                "y = -5/4x + 7 pasa por (8,2)",
                "y = -4/5x + 5 pasa por (0,5)"
            ],
            "correcta_texto": "y = -5/4x + 7 pasa por (8,-3)"
        },

        # ================= TEMA A — MISIÓN 2 =================
        {
            "id": "A7", "mision": 2, "t_max": 290,
            "pregunta": "Un horno inicia a 15 grados C y sube 10 grados C cada 3 min. ¿Qué función representa su temperatura 'y' tras 'x' minutos?",
            "opciones": ["y = 15x + 3/10", "y = 3/10x + 15", "y = 10/3x + 15", "y = 10x + 15"],
            "correcta_texto": "y = 10/3x + 15"
        },
        {
            "id": "A8", "mision": 2, "t_max": 290,
            "pregunta": f"Un taxi cobra {MONEDA}7 de base y {MONEDA}2 por cada 3 km. ¿Cuál es el costo total por un viaje de 15 km?",
            "opciones": [f"{MONEDA}10", f"{MONEDA}23", f"{MONEDA}17", f"{MONEDA}15"],
            "correcta_texto": f"{MONEDA}17"
        },
        {
            "id": "A9", "mision": 2, "t_max": 290,
            "pregunta": "Tanque A (en 2 min tiene 10L, en 8 min tiene 40L). Tanque B (en 1 min tiene 50L, en 11 min tiene 10L). ¿En qué minuto se igualan sus niveles?",
            "opciones": ["4", "6", "8", "10"],
            "correcta_texto": "6"
        },
        {
            "id": "A10", "mision": 2, "t_max": 290,
            "pregunta": f"Andrés tiene {MONEDA}150 y ahorra {MONEDA}50 por semana. Beatriz tiene {MONEDA}950 y gasta {MONEDA}150 por semana. ¿En qué semana tendrán lo mismo?",
            "opciones": ["2", "3", "4", "5"],
            "correcta_texto": "4"
        },

        # ================= TEMA B — MISIÓN 1 =================
        {
            "id": "B1", "mision": 1, "t_max": 275,
            "pregunta": "Una rampa pasa por A=(-3, 5) y B=(3, 1). Calcula su pendiente (m) y su punto de corte (b):",
            "opciones": ["m = 2/3, b = 3", "m = -2/3, b = 3", "m = -3/2, b = -3", "m = 3/2, b = 3"],
            "correcta_texto": "m = -2/3, b = 3"
        },
        {
            "id": "B2", "mision": 1, "t_max": 275,
            "pregunta": "Halla la ecuación de la recta que une los puntos A(-2, -5) y B(5, -7):",
            "opciones": ["y = -2/7x - 39/7", "y = 2/7x + 39/7", "y = -7/2x - 4", "y = 7/2x + 4"],
            "correcta_texto": "y = -2/7x - 39/7"
        },
        {
            "id": "B3", "mision": 1, "t_max": 275,
            "pregunta": "Una antena transmite desde P(5, -2) con m = -4/5. ¿Cuál es su modelo matemático (ecuación de la recta)?",
            "opciones": ["y = -4/5x + 2", "y = -4/5x - 2", "y = 4/5x + 2", "y = -5/4x + 2"],
            "correcta_texto": "y = -4/5x + 2"
        },
        {
            "id": "B4", "mision": 1, "t_max": 260,
            "pregunta": "Si una cerca sigue la línea y = 3/7x + 5, ¿cuál de estas opciones representa una cerca PARALELA?",
            "opciones": ["y = -3/7x + 5", "y = 7/3x - 1", "y = 3/7x - 8", "y = -7/3x + 2"],
            "correcta_texto": "y = 3/7x - 8"
        },
        {
            "id": "B5", "mision": 1, "t_max": 260,
            "pregunta": "Una tubería (y = -5/2x - 4) debe cruzarse con otra de forma PERPENDICULAR. ¿Cuál es la ecuación de la segunda tubería?",
            "opciones": ["y = 5/2x + 1", "y = 2/5x + 10", "y = -2/5x - 4", "y = -5/2x + 3"],
            "correcta_texto": "y = 2/5x + 10"
        },
        {
            "id": "B6", "mision": 1, "t_max": 280,
            "pregunta": "Halla la recta con m = 1/3 que pasa por P(6, 4) y identifica otro punto por donde pase:",
            "opciones": [
                "y = 1/3x + 2 pasa por (0, 2)",
                "y = 3x - 2 pasa por (1, 1)",
                "y = 1/3x + 4 pasa por (3, 5)",
                "y = -1/3x + 2 pasa por (6, 0)"
            ],
            "correcta_texto": "y = 1/3x + 2 pasa por (0, 2)"
        },

        # ================= TEMA B — MISIÓN 2 =================
        {
            "id": "B7", "mision": 2, "t_max": 290,
            "pregunta": "Un enfriador está a 20 grados C y baja 4 grados C cada 3 min. ¿Qué función describe su temperatura tras 'x' minutos?",
            "opciones": ["y = 3/4x + 20", "y = -4/3x + 20", "y = 4/3x - 20", "y = -3/4x + 20"],
            "correcta_texto": "y = -4/3x + 20"
        },
        {
            "id": "B8", "mision": 2, "t_max": 290,
            "pregunta": f"Mensajería: {MONEDA}10 de cargo básico más {MONEDA}3 por cada 4 km recorridos. ¿Cuánto cuesta un envío a 20 km?",
            "opciones": [f"{MONEDA}15", f"{MONEDA}20", f"{MONEDA}25", f"{MONEDA}30"],
            "correcta_texto": f"{MONEDA}25"
        },
        {
            "id": "B9", "mision": 2, "t_max": 290,
            "pregunta": "Tanque A (15L inicial, sube 3L c/2 min). Tanque B (45L inicial, baja 5L c/2 min). ¿En qué minuto tienen igual nivel?",
            "opciones": ["6", "7.5", "10", "15"],
            "correcta_texto": "7.5"
        },
        {
            "id": "B10", "mision": 2, "t_max": 290,
            "pregunta": f"Camilo tiene {MONEDA}400 y gasta {MONEDA}25 cada 2 semanas. Sara tiene {MONEDA}100 y ahorra {MONEDA}75 cada 2 semanas. ¿En qué semana se igualan?",
            "opciones": ["2", "3", "4", "5"],
            "correcta_texto": "4"
        },

        # ================= TEMA C — MISIÓN 1 =================
        {
            "id": "C1", "mision": 1, "t_max": 275,
            "pregunta": "Una tirolesa une A=(-5, 7) y B=(5, 3). Halla su pendiente (m) y su punto de corte con el eje Y (b):",
            "opciones": ["m = 2/5, b = 5", "m = -5/2, b = 5", "m = -2/5, b = 5", "m = 5/2, b = -5"],
            "correcta_texto": "m = -2/5, b = 5"
        },
        {
            "id": "C2", "mision": 1, "t_max": 275,
            "pregunta": "Determina la ecuación de la recta que pasa por los puntos de control A(-3, 1) y B(6, 7):",
            "opciones": ["y = 2/3x + 3", "y = -2/3x + 3", "y = 3/2x - 1", "y = 2/3x - 3"],
            "correcta_texto": "y = 2/3x + 3"
        },
        {
            "id": "C3", "mision": 1, "t_max": 275,
            "pregunta": "Desde P(3, -4) sale un cable con pendiente m = -1/3. ¿Cuál es su ecuación (y = mx + b)?",
            "opciones": ["y = -1/3x - 3", "y = -1/3x + 3", "y = 1/3x - 3", "y = -3x - 3"],
            "correcta_texto": "y = -1/3x - 3"
        },
        {
            "id": "C4", "mision": 1, "t_max": 260,
            "pregunta": "Una pista digital es y = -2/9x + 10. ¿Cuál de estas pistas es PARALELA?",
            "opciones": ["y = 9/2x + 10", "y = -2/9x - 4", "y = 2/9x + 4", "y = -9/2x + 1"],
            "correcta_texto": "y = -2/9x - 4"
        },
        {
            "id": "C5", "mision": 1, "t_max": 260,
            "pregunta": "Una viga (y = 7/3x - 2) debe sostenerse con otra PERPENDICULAR. ¿Qué ecuación tiene la segunda viga?",
            "opciones": ["y = -3/7x + 6", "y = 3/7x + 6", "y = -7/3x - 2", "y = 7/3x + 4"],
            "correcta_texto": "y = -3/7x + 6"
        },
        {
            "id": "C6", "mision": 1, "t_max": 280,
            "pregunta": "Halla la recta con m = -3/2 que pasa por P(4, -1) y señala su punto de corte con el eje Y:",
            "opciones": [
                "y = -3/2x + 5 [Corte en 5]",
                "y = 3/2x - 7 [Corte en -7]",
                "y = -3/2x - 1 [Corte en -1]",
                "y = 2/3x + 1 [Corte en 1]"
            ],
            "correcta_texto": "y = -3/2x + 5 [Corte en 5]"
        },

        # ================= TEMA C — MISIÓN 2 =================
        {
            "id": "C7", "mision": 2, "t_max": 290,
            "pregunta": "Un vehículo con 40L de combustible consume 5L cada 4 km. ¿Qué función modela el combustible restante (y) según los km recorridos (x)?",
            "opciones": ["y = 4/5x + 40", "y = -5/4x + 40", "y = 5/4x - 40", "y = -4/5x + 40"],
            "correcta_texto": "y = -5/4x + 40"
        },
        {
            "id": "C8", "mision": 2, "t_max": 290,
            "pregunta": f"Un servicio técnico cobra {MONEDA}15 base y {MONEDA}5 por cada 2 horas de labor. ¿Cuánto cuesta una reparación de 7 horas?",
            "opciones": [f"{MONEDA}30.0", f"{MONEDA}32.5", f"{MONEDA}35.0", f"{MONEDA}17.5"],
            "correcta_texto": f"{MONEDA}32.5"
        },
        {
            "id": "C9", "mision": 2, "t_max": 290,
            "pregunta": "Tanque A (100L inicial, pierde 10L c/3 min). Tanque B (20L inicial, gana 10L c/3 min). ¿En qué minuto se cruzan sus niveles?",
            "opciones": ["10", "12", "15", "18"],
            "correcta_texto": "12"
        },
        {
            "id": "C10", "mision": 2, "t_max": 290,
            "pregunta": f"Marta tiene {MONEDA}600 y gasta {MONEDA}40 cada 3 semanas. Luis tiene {MONEDA}1000 y gasta {MONEDA}120 cada 3 semanas. ¿En qué semana tendrán lo mismo?",
            "opciones": ["Semana 12", "Semana 15", "Semana 18", "Semana 20"],
            "correcta_texto": "Semana 15"
        },

        # ================= TEMA D — MISIÓN 1 =================
        {
            "id": "D1", "mision": 1, "t_max": 275,
            "pregunta": "Un puente recto une A=(-6, 1) con B=(6, 6). Halla su pendiente (m) y su intercepto (b):",
            "opciones": ["m = 5/12, b = 3.5", "m = -5/12, b = 3.5", "m = 12/5, b = -3", "m = 5/12, b = -3.5"],
            "correcta_texto": "m = 5/12, b = 3.5"
        },
        {
            "id": "D2", "mision": 1, "t_max": 275,
            "pregunta": "Determina la ecuación de la recta que pasa por los puntos de anclaje A(-4, 8) y B(2, -1):",
            "opciones": ["y = 3/2x + 2", "y = -3/2x + 2", "y = -2/3x + 2", "y = 3/2x - 2"],
            "correcta_texto": "y = -3/2x + 2"
        },
        {
            "id": "D3", "mision": 1, "t_max": 275,
            "pregunta": "Una rampa inicia en P(3, -4) con pendiente m = -1/3. ¿Cuál es su ecuación (y = mx + b)?",
            "opciones": ["y = -1/3x - 3", "y = -1/3x + 3", "y = 1/3x - 3", "y = -3x - 3"],
            "correcta_texto": "y = -1/3x - 3"
        },
        {
            "id": "D4", "mision": 1, "t_max": 260,
            "pregunta": "Si un cable sigue la línea y = -5/6x - 1, ¿cuál de estas opciones es PARALELA?",
            "opciones": ["y = 6/5x + 4", "y = 5/6x - 1", "y = -5/6x + 9", "y = -6/5x + 2"],
            "correcta_texto": "y = -5/6x + 9"
        },
        {
            "id": "D5", "mision": 1, "t_max": 260,
            "pregunta": "Una calle (y = -1/4x + 5) cruza con otra de forma PERPENDICULAR. ¿Cuál es la ecuación de la segunda calle?",
            "opciones": ["y = -4x + 2", "y = 1/4x - 5", "y = 4x - 8", "y = -4x + 3"],
            "correcta_texto": "y = 4x - 8"
        },
        {
            "id": "D6", "mision": 1, "t_max": 280,
            "pregunta": "Halla la recta con m = 4/5 que pasa por P(5, 7) e indica su punto de corte con el eje Y:",
            "opciones": [
                "y = 4/5x + 3 [Corta en 3]",
                "y = -4/5x + 3 [Corta en 3]",
                "y = 4/5x - 3 [Corta en -3]",
                "y = 5/4x + 3 [Corta en 3]"
            ],
            "correcta_texto": "y = 4/5x + 3 [Corta en 3]"
        },

        # ================= TEMA D — MISIÓN 2 =================
        {
            "id": "D7", "mision": 2, "t_max": 290,
            "pregunta": "Un depósito de 80 galones pierde 3 galones cada 2 horas por una fuga. ¿Qué función describe el agua restante (y) tras 'x' horas?",
            "opciones": ["y = 3/2x + 80", "y = -2/3x + 80", "y = -3/2x + 80", "y = -3/2x - 80"],
            "correcta_texto": "y = -3/2x + 80"
        },
        {
            "id": "D8", "mision": 2, "t_max": 290,
            "pregunta": f"Un carpintero cobra {MONEDA}20 base y {MONEDA}15 por cada 4 horas de trabajo. ¿Cuánto cobrará por un proyecto de 12 horas?",
            "opciones": [f"{MONEDA}45", f"{MONEDA}65", f"{MONEDA}35", f"{MONEDA}70"],
            "correcta_texto": f"{MONEDA}65"
        },
        {
            "id": "D9", "mision": 2, "t_max": 290,
            "pregunta": "Globo A (10m de altura, sube 5m cada 4 seg). Globo B (40m de altura, baja 7m cada 4 seg). ¿En qué segundo se cruzan sus alturas?",
            "opciones": ["8", "10", "12", "15"],
            "correcta_texto": "10"
        },
        {
            "id": "D10", "mision": 2, "t_max": 290,
            "pregunta": f"Daniel tiene {MONEDA}500 y gasta {MONEDA}30 cada 2 semanas. Sofía tiene {MONEDA}800 y gasta {MONEDA}80 cada 2 semanas. ¿En qué semana tendrán lo mismo?",
            "opciones": ["6", "10", "12", "14"],
            "correcta_texto": "12"
        },
    ]

    st.session_state.banco_completo = _validar_banco(_banco_raw)


# ╔══════════════════════════════════════════════════════════════╗
# ║  SECCIÓN 4: INICIALIZACIÓN DEL ESTADO (ÚNICA VEZ)           ║
# ╚══════════════════════════════════════════════════════════════╝

if 'paso' not in st.session_state:
    st.session_state.update({
        'paso': 'registro',
        'nombre': '',
        'curso': '',
        'mision': 1,
        'n_pregunta': 0,
        'aciertos': 0,
        'power_5050': True,
        'usar_5050': False,
        'lista_examen': [],
        't_inicio_pregunta': 0.0,
        'examen_finalizado': False,
        'datos_enviados': False,
        'datos_enviados_m1': False,
    })


# ╔══════════════════════════════════════════════════════════════╗
# ║  SECCIÓN 5: FUNCIONES DE UTILIDAD                           ║
# ╚══════════════════════════════════════════════════════════════╝

# ---- 5.1 Limpieza de texto para Matplotlib ----

def _limpiar_texto(texto: str) -> str:
    """Elimina caracteres que rompen el renderizado de Matplotlib."""
    reemplazos = {
        '$': ' ',
        '°': ' grados ',
        '(moneda)': ' ',
        '(pesos)': ' ',
    }
    for original, nuevo in reemplazos.items():
        texto = texto.replace(original, nuevo)
    return texto


# ---- 5.2 Generador de imágenes (seguridad anti-copypaste) ----

def crear_imagen(texto: str, opciones: list, ocultas: list = None,
                 idx_pregunta: int = None) -> io.BytesIO:
    """
    Genera imagen PNG con pregunta y opciones para evitar copy-paste.

    Args:
        texto: Enunciado de la pregunta.
        opciones: Lista con formato ["A) texto", "B) texto", ...].
        ocultas: Letras eliminadas por 50/50 (ej. ["B", "D"]).
        idx_pregunta: Índice de la pregunta (para lógica condicional).

    Returns:
        Buffer BytesIO con imagen PNG.
    """
    if ocultas is None:
        ocultas = []

    fig = None
    try:
        fig, ax = plt.subplots(figsize=(10, 6))
        fig.patch.set_facecolor('white')

        finales_render = []
        for opt in opciones:
            if not opt:
                finales_render.append("[ OPCIÓN VACÍA ]")
                continue

            letra = opt[0]  # "A", "B", "C" o "D"

            if letra in ocultas and idx_pregunta is not None:
                finales_render.append(f"{letra}) [ ELIMINADA ]")
            else:
                finales_render.append(_limpiar_texto(opt))

        cuerpo = f"{_limpiar_texto(texto)}\n\n" + "\n".join(finales_render)
        tamano_fuente = 16 if len(cuerpo) < 200 else 14

        ax.text(
            0.05, 0.9, cuerpo,
            fontsize=tamano_fuente,
            fontweight='bold',
            wrap=True,
            va='top', ha='left',
            color='#2d0b2a',
            family='sans-serif',
            linespacing=1.6
        )
        ax.axis('off')

        buf = io.BytesIO()
        plt.savefig(buf, format='png', bbox_inches='tight', dpi=120)
        buf.seek(0)
        return buf

    finally:
        if fig is not None:
            plt.close(fig)


# ---- 5.3 Reset del juego ----

def _limpiar_claves_dinamicas():
    """Elimina todas las claves temporales de preguntas del session_state."""
    prefijos = ('q_opts_', 'q_cor_', 'inc_', 'ocultas_fix_', 'rad_m')
    for key in list(st.session_state.keys()):
        if key.startswith(prefijos):
            del st.session_state[key]


def reset_juego():
    """Reinicia todo el estado para un nuevo jugador."""
    st.session_state.update({
        'paso': 'registro',
        'nombre': '',
        'curso': '',
        'mision': 1,
        'n_pregunta': 0,
        'aciertos': 0,
        'power_5050': True,
        'usar_5050': False,
        'lista_examen': [],
        't_inicio_pregunta': 0.0,
        'examen_finalizado': False,
        'datos_enviados': False,
        'datos_enviados_m1': False,
    })
    _limpiar_claves_dinamicas()


# ---- 5.4 Preparar preguntas de una misión ----

def _preparar_preguntas_mision(n_mision: int) -> bool:
    """
    Selecciona preguntas aleatorias y las fija en sesión.
    Returns True si exitoso, False si no hay suficientes preguntas.
    """
    pool = [p for p in st.session_state.banco_completo if p['mision'] == n_mision]

    if len(pool) < PREGUNTAS_POR_MISION:
        st.error(
            f"❌ No hay suficientes preguntas para Misión {n_mision}. "
            f"Encontradas: {len(pool)}, necesarias: {PREGUNTAS_POR_MISION}."
        )
        return False

    st.session_state.lista_examen = random.sample(pool, PREGUNTAS_POR_MISION)
    st.session_state.n_pregunta = 0
    st.session_state.aciertos = 0
    st.session_state.t_inicio_pregunta = time.time()
    st.session_state.usar_5050 = False

    _limpiar_claves_dinamicas()
    return True


# ---- 5.5 Preparar opciones de una pregunta (idempotente) ----

def _preparar_opciones_pregunta(idx: int, pregunta: dict):
    """Baraja opciones y guarda la correcta. Solo se ejecuta 1 vez por pregunta."""
    if f"q_opts_{idx}" in st.session_state:
        return

    opts = pregunta['opciones'].copy()
    random.shuffle(opts)

    letras = ["A", "B", "C", "D"]
    st.session_state[f"q_opts_{idx}"] = [
        f"{letras[i]}) {opts[i]}" for i in range(len(opts))
    ]

    try:
        idx_correcta = opts.index(pregunta['correcta_texto'])
        letra_correcta = letras[idx_correcta]
    except ValueError:
        st.error(f"⚠️ Error en pregunta '{pregunta.get('id', '?')}': respuesta no encontrada en opciones.")
        letra_correcta = letras[0]

    st.session_state[f"q_cor_{idx}"] = letra_correcta
    st.session_state[f"inc_{idx}"] = [L for L in letras if L != letra_correcta]


# ---- 5.6 Obtener opciones ocultas por 50/50 ----

def _obtener_ocultas_5050(idx: int) -> list:
    """Retorna las letras ocultas por el 50/50. Fija el resultado en sesión."""
    if not st.session_state.get('usar_5050', False):
        return []

    if f"ocultas_fix_{idx}" not in st.session_state:
        incorrectas = st.session_state.get(f"inc_{idx}", [])
        st.session_state[f"ocultas_fix_{idx}"] = (
            random.sample(incorrectas, 2) if len(incorrectas) >= 2 else incorrectas
        )

    return st.session_state[f"ocultas_fix_{idx}"]


# ---- 5.7 Envío a Google Sheets (con feedback visual) ----

def enviar_a_google(
    nombre: str,
    curso: str,
    mision: int,
    aciertos: int,
    power_disponible: bool = True
) -> bool:
    """
    Envía resultados a Google Sheets con feedback visual.

    Args:
        nombre: Nombre del estudiante.
        curso: Curso seleccionado.
        mision: Número de misión (1 o 2).
        aciertos: Respuestas correctas.
        power_disponible: True si 50/50 NO se usó.

    Returns:
        True si exitoso.
    """
    uso_powerup = "No" if power_disponible else "Sí"

    datos = {
        "nombre": str(nombre).strip(),
        "curso": str(curso).strip(),
        "mision": f"Misión {int(mision)}",
        "aciertos": int(aciertos),
        "powerup": uso_powerup,
    }

    try:
        with st.status("🚀 Transmitiendo resultados al cuartel general...", expanded=True) as status:
            st.write("📡 Conectando con la base de datos...")
            response = requests.post(GOOGLE_SCRIPT_URL, json=datos, timeout=10)
            st.write("🔍 Verificando registro...")
            time.sleep(0.5)

            if response.status_code == 200:
                status.update(
                    label="✅ ¡Misión guardada con éxito!",
                    state="complete",
                    expanded=False
                )
                return True
            else:
                status.update(
                    label=f"⚠️ Error del servidor (código {response.status_code})",
                    state="error",
                    expanded=False
                )
                return False

    except requests.exceptions.Timeout:
        st.toast("⏱️ Servidor lento. Tus datos se guardarán después.", icon="⏱️")
        return False

    except requests.exceptions.ConnectionError:
        st.toast("📡 Sin conexión. Verifica tu red.", icon="📡")
        return False

    except Exception as e:
        st.toast("❌ Error inesperado al enviar datos.", icon="❌")
        logging.warning(f"enviar_a_google error: {type(e).__name__}: {e}")
        return False


# ╔══════════════════════════════════════════════════════════════╗
# ║  SECCIÓN 6: PANTALLAS DEL JUEGO                             ║
# ╚══════════════════════════════════════════════════════════════╝

# ========================================
# PANTALLA 1: REGISTRO
# ========================================
if st.session_state.paso == 'registro':
    st.markdown(
        "<div class='status-panel'>⚔️ MATH QUEST PRO: REGISTRO DE GUERRERO</div>",
        unsafe_allow_html=True
    )

    nom = st.text_input("Nombre del Guerrero:", key="txt_nombre", max_chars=50)
    cur = st.selectbox(
        "Selecciona tu Curso:",
        ["901", "902", "903", "904", "908", "909", "910"],
        key="sel_curso"
    )

    st.markdown("<div class='registration-footer'></div>", unsafe_allow_html=True)

    if st.button("⚔️ ¡INICIAR AVENTURA!", type="primary"):
        nombre_limpio = nom.strip()
        if nombre_limpio:
            st.session_state.nombre = nombre_limpio
            st.session_state.curso = cur
            st.session_state.mision = 1
            st.session_state.power_5050 = True
            st.session_state.usar_5050 = False
            st.session_state.datos_enviados_m1 = False
            st.session_state.datos_enviados = False

            if _preparar_preguntas_mision(1):
                st.session_state.paso = 'examen'
                st.rerun()
        else:
            st.warning("⚠️ Escribe tu nombre para iniciar.")


# ========================================
# PANTALLA 2: EXAMEN
# ========================================
elif st.session_state.paso == 'examen':
    idx = st.session_state.n_pregunta

    # Seguridad: si terminamos las preguntas → feedback
    if idx >= len(st.session_state.lista_examen):
        st.session_state.paso = 'feedback'
        st.session_state.examen_finalizado = True
        st.rerun()

    pregunta_actual = st.session_state.lista_examen[idx]

    # Preparar opciones (1 vez por pregunta)
    _preparar_opciones_pregunta(idx, pregunta_actual)

    # --- Variables de UI ---
    mision_actual = st.session_state.mision
    nombre = st.session_state.nombre
    aciertos_actuales = st.session_state.aciertos

    # --- Panel de estado ---
    if st.session_state.get('usar_5050', False):
        icono_power = "🔥 50/50 ACTIVADO"
    elif st.session_state.power_5050:
        icono_power = "⚡ 50/50 DISPONIBLE"
    else:
        icono_power = "💨 POWER-UP USADO"

    st.markdown(
        f"<div class='status-panel'>"
        f"👤 {nombre} | 🎯 Misión {mision_actual} | "
        f"📝 Pregunta {idx + 1}/{PREGUNTAS_POR_MISION} | "
        f"✅ {aciertos_actuales} | {icono_power}"
        f"</div>",
        unsafe_allow_html=True
    )

    # --- Barra de progreso de misión ---
    progreso_mision = ((idx) / PREGUNTAS_POR_MISION) * 100
    st.markdown(f"""
        <div style='color:white; font-weight:bold; font-size:0.85rem; margin-bottom:4px;'>
            PROGRESO DE MISIÓN {mision_actual}
        </div>
        <div class='energy-bar-bg'>
            <div class='energy-bar-fill progress-bar' style='width: {progreso_mision}%;'></div>
        </div>
    """, unsafe_allow_html=True)

    # --- Barra de tiempo ---
    t_max = pregunta_actual.get('t_max', 60)
    t_pasado = time.time() - st.session_state.t_inicio_pregunta
    t_restante = max(0.0, t_max - t_pasado)
    porcentaje_tiempo = t_restante / t_max

    clase_parpadeo = "time-critical" if porcentaje_tiempo < 0.2 else ""
    minutos = int(t_restante // 60)
    segundos = int(t_restante % 60)

    st.markdown(f"""
        <div class='energy-bar-bg {clase_parpadeo}'>
            <div class='energy-bar-fill time-bar' style='width: {porcentaje_tiempo * 100:.1f}%;'></div>
        </div>
        <p style='text-align:center; font-size:0.9rem; margin-top:2px;'>
            ⏱️ Tiempo: {minutos}:{segundos:02d}
        </p>
    """, unsafe_allow_html=True)

    # --- Mensaje motivacional ---
    if idx == 2:
        st.markdown(
            f"<p style='text-align:center; color:#fbbf24; font-size:1rem;'>"
            f"{random.choice(MENSAJES_MOTIVACION)}</p>",
            unsafe_allow_html=True
        )

    # --- Lógica 50/50 ---
    ocultas = _obtener_ocultas_5050(idx)

    # --- Imagen de la pregunta (SEGURIDAD ANTI-COPYPASTE) ---
    opciones_display = st.session_state[f"q_opts_{idx}"]

    img_buf = crear_imagen(
        texto=pregunta_actual['pregunta'],
        opciones=opciones_display,
        ocultas=ocultas,
        idx_pregunta=idx
    )

    st.markdown("<div class='question-card'>", unsafe_allow_html=True)
    st.image(img_buf, use_container_width=True)
    st.markdown("</div>", unsafe_allow_html=True)

    # --- Botón 50/50 ---
    col1, col2 = st.columns([3, 1])
    with col2:
        if st.session_state.power_5050 and not st.session_state.get('usar_5050', False):
            st.markdown('<div class="btn-5050">', unsafe_allow_html=True)
            if st.button("⚡ 50/50", key=f"btn5050_{idx}"):
                st.session_state.usar_5050 = True
                st.session_state.power_5050 = False
                st.rerun()
            st.markdown('</div>', unsafe_allow_html=True)

    # --- Selección de respuesta ---
    letras_visibles = [
        opt[0] for opt in opciones_display
        if opt[0] not in ocultas
    ]

    ans = st.radio(
        "TU ELECCIÓN:",
        letras_visibles,
        key=f"rad_m{mision_actual}_{idx}",
        index=None,
        horizontal=True
    )

    # --- Lógica: Tiempo agotado ---
    tiempo_agotado = (porcentaje_tiempo <= 0)

    if tiempo_agotado:
        st.warning("⏱️ ¡Tiempo agotado! Avanzando...")

    # --- Botón enviar ---
    boton_enviar = st.button(
        "ENVIAR RESPUESTA ➡️",
        type="primary",
        key=f"btn_enviar_{idx}"
    )

    if boton_enviar or tiempo_agotado:
        letra_correcta = st.session_state[f"q_cor_{idx}"]
        texto_correcto = pregunta_actual['correcta_texto']

        if ans is not None:
            if ans == letra_correcta:
                st.session_state.aciertos += 1
                st.toast("🔥 ¡Correcto!", icon="🔥")
            else:
                st.toast(
                    f"❌ Incorrecto. Era: {letra_correcta}) {texto_correcto}",
                    icon="❌"
                )
        else:
            st.toast(
                f"⏱️ Sin respuesta. Era: {letra_correcta}) {texto_correcto}",
                icon="⏱️"
            )

        # Avanzar
        st.session_state.n_pregunta += 1
        st.session_state.t_inicio_pregunta = time.time()
        st.session_state.usar_5050 = False
        time.sleep(1.5)  # Pausa para que el toast sea visible
        st.rerun()

    # --- Auto-refresh del cronómetro ---
    elif t_restante > 0:
        time.sleep(1)
        st.rerun()


# ========================================
# PANTALLA 3: FEEDBACK / RESULTADOS
# ========================================
elif st.session_state.paso == 'feedback':
    st.markdown(
        "<div class='status-panel'>📊 RESULTADO DE MISIÓN</div>",
        unsafe_allow_html=True
    )

    puntaje = st.session_state.aciertos
    mision = st.session_state.mision
    nombre = st.session_state.nombre
    curso = st.session_state.curso

    st.markdown(
        "<div class='question-card' style='text-align:center; padding:30px;'>",
        unsafe_allow_html=True
    )
    st.markdown(f"## 👤 {nombre}")
    st.markdown(f"### 🎯 Misión {mision} — Resultado: {puntaje}/{PREGUNTAS_POR_MISION}")

    # ---- MISIÓN 1 ----
    if mision == 1:
        # Guardar datos M1 (siempre, éxito o fallo)
        if not st.session_state.get('datos_enviados_m1', False):
            exito = enviar_a_google(
                nombre=nombre,
                curso=curso,
                mision=1,
                aciertos=puntaje,
                power_disponible=st.session_state.power_5050
            )
            if exito:
                st.session_state.datos_enviados_m1 = True

        if puntaje >= PUNTAJE_MINIMO:
            st.success(f"🎉 ¡Misión 1 Superada con {puntaje} aciertos!")

            if st.button("🚀 CONTINUAR A MISIÓN 2", type="primary"):
                st.session_state.power_5050 = True  # Reset power-up para M2
                st.session_state.mision = 2

                if _preparar_preguntas_mision(2):
                    st.session_state.paso = 'examen'
                    st.rerun()
        else:
            st.error(f"💔 No alcanzaste el mínimo ({PUNTAJE_MINIMO}/{PREGUNTAS_POR_MISION}).")

            if st.button("🔄 REINTENTAR DESDE EL INICIO"):
                reset_juego()
                st.rerun()

    # ---- MISIÓN 2 ----
    elif mision == 2:
        # Guardar datos M2
        if not st.session_state.get('datos_enviados', False):
            exito = enviar_a_google(
                nombre=nombre,
                curso=curso,
                mision=2,
                aciertos=puntaje,
                power_disponible=st.session_state.power_5050
            )
            if exito:
                st.session_state.datos_enviados = True

        if puntaje >= PUNTAJE_MINIMO:
            st.balloons()
            st.success("🏆 ¡FELICIDADES! HAS COMPLETADO MATH QUEST PRO")
        else:
            st.warning(
                f"Juego terminado. Obtuviste {puntaje}/{PREGUNTAS_POR_MISION} "
                f"en Misión 2. Necesitabas al menos {PUNTAJE_MINIMO}."
            )

        if st.button("🏁 FINALIZAR Y SALIR"):
            reset_juego()
            st.rerun()

    st.markdown("</div>", unsafe_allow_html=True)


# ╔══════════════════════════════════════════════════════════════╗
# ║  FIN DEL ARCHIVO                                             ║
# ╚══════════════════════════════════════════════════════════════╝

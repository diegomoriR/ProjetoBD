import json
from pathlib import Path
BASE_DIR = Path(__file__).resolve().parent
with open(BASE_DIR / "config.json", encoding="utf-8") as f:
    config = json.load(f)

import psycopg
db = config["database"]
conn = psycopg.connect(
host=db["host"],
port=db["port"],
dbname=db["dbname"],
user=db["user"],
password=db["password"]
)

from ollama import Client
ollama_config = config["ollama"]
client = Client(
host=ollama_config["host"]
)

response = client.chat(
model=ollama_config["model"],
messages=[
{
"role": "user",
"content": prompt
}
]
)
resposta = response["message"]["content"]

projeto_path = BASE_DIR.parent / "Projeto.txt"
if not projeto_path.exists():
    print("Erro: Projeto.txt não encontrado.")
    raise SystemExit(1)

projeto = projeto_path.read_text(encoding="utf-8")

try:
    ddl = projeto.split("3. DDL COMPLETO", 1)[1]
    ddl = ddl.split("4. CONSULTAS", 1)[0]
    ddl = ddl.strip()
except (IndexError, ValueError):
    print("Erro: Seção '3. DDL COMPLETO' ou '4. CONSULTAS' não encontrada em Projeto.txt.")
    raise SystemExit(1)
"""Protótipo CLI - SCC0640 Sistema de Gestão de Eventos e Espaços.

Execução: python main.py
O avaliador edita apenas config.json.
"""

import json
import re
from getpass import getpass
from pathlib import Path

import psycopg
from ollama import Client

BASE_DIR = Path(__file__).resolve().parent

MAX_LINHAS_EXIBIDAS = 50
MAX_TENTATIVAS_LLM = 2
LARGURA_MAX_COLUNA = 40
LINHA = "=" * 60


# ---------------------------------------------------------------------------
# Configuração
# ---------------------------------------------------------------------------
def carregar_config():
    with open(BASE_DIR / "config.json", encoding="utf-8") as f:
        config = json.load(f)
    return config


def solicitar_parametros(config):
    """Mostra os parâmetros de config.json; Enter mantém o valor atual."""
    db = config["database"]
    print(LINHA)
    print("PARÂMETROS DE CONEXÃO COM O POSTGRESQL")
    print("(pressione Enter para manter o valor entre colchetes)")
    print(LINHA)

    for chave in ("host", "port", "dbname", "user"):
        valor = input(f"{chave} [{db[chave]}]: ").strip()
        if valor:
            db[chave] = int(valor) if chave == "port" else valor

    senha = getpass("password [manter atual]: ")
    if senha:
        db["password"] = senha
    return config


# ---------------------------------------------------------------------------
# Conexões
# ---------------------------------------------------------------------------
def conectar_postgres(config):
    db = config["database"]
    conn = psycopg.connect(
        host=db["host"],
        port=db["port"],
        dbname=db["dbname"],
        user=db["user"],
        password=db["password"]
    )
    # Somente leitura: o protótipo apenas consulta; evita que SQL gerado
    # pelo modelo altere dados. autocommit evita transação "abortada" após erro.
    conn.autocommit = True
    conn.read_only = True
    return conn


def criar_cliente_ollama(config):
    ollama_config = config["ollama"]
    client = Client(
        host=ollama_config["host"]
    )
    return client


def chamar_modelo(client, config, prompt):
    ollama_config = config["ollama"]
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
    return resposta


# ---------------------------------------------------------------------------
# Projeto.txt (DDL e consultas)
# ---------------------------------------------------------------------------
def carregar_projeto():
    """Lê Projeto.txt e devolve (texto_completo, ddl)."""
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

    return projeto, ddl


def extrair_consultas(projeto):
    """Extrai as consultas da seção 4 de Projeto.txt.

    Retorna lista de dicts: {"numero", "objetivo", "sql"}.
    """
    try:
        secao = projeto.split("4. CONSULTAS", 1)[1]
    except IndexError:
        return []
    secao = secao.split("FIM DO ARQUIVO", 1)[0]
    secao = re.sub(r"^=+\s*$", "", secao, flags=re.MULTILINE)

    padrao = re.compile(
        r"CONSULTA\s+(\d+)\s*\n\s*OBJETIVO:\s*(.*?)\n\s*SQL:\s*(.*?)"
        r"(?=\n\s*CONSULTA\s+\d+\s*\n|\Z)",
        re.DOTALL,
    )
    consultas = []
    for m in padrao.finditer(secao):
        consultas.append({
            "numero": int(m.group(1)),
            "objetivo": m.group(2).strip(),
            "sql": m.group(3).strip(),
        })
    return consultas


# ---------------------------------------------------------------------------
# Execução e apresentação
# ---------------------------------------------------------------------------
def executar_sql(conn, sql):
    """Executa a SQL e devolve (colunas, linhas). Lança exceção em caso de erro."""
    with conn.cursor() as cur:
        cur.execute(sql)
        if cur.description is None:
            return [], []
        colunas = [d.name for d in cur.description]
        linhas = cur.fetchall()
    return colunas, linhas


def _texto(valor):
    if valor is None:
        return "NULL"
    texto = str(valor).replace("\n", " ")
    if len(texto) > LARGURA_MAX_COLUNA:
        texto = texto[:LARGURA_MAX_COLUNA - 3] + "..."
    return texto


def imprimir_resultado(colunas, linhas):
    if not colunas:
        print("(comando executado, sem resultado tabular)")
        return
    if not linhas:
        print("(nenhuma linha retornada)")
        return

    exibidas = linhas[:MAX_LINHAS_EXIBIDAS]
    tabela = [[_texto(v) for v in linha] for linha in exibidas]
    larguras = [
        max(len(colunas[i]), *(len(l[i]) for l in tabela))
        for i in range(len(colunas))
    ]

    def fmt(celulas):
        return " | ".join(c.ljust(larguras[i]) for i, c in enumerate(celulas))

    print(fmt(colunas))
    print("-+-".join("-" * w for w in larguras))
    for l in tabela:
        print(fmt(l))

    total = len(linhas)
    if total > MAX_LINHAS_EXIBIDAS:
        print(f"... exibindo {MAX_LINHAS_EXIBIDAS} de {total} linhas.")
    else:
        print(f"({total} linha{'s' if total != 1 else ''})")


def executar_consultas_projeto(conn, consultas):
    if not consultas:
        print("Nenhuma consulta encontrada na seção 4 de Projeto.txt.")
        return

    while True:
        print(LINHA)
        print("CONSULTAS DO PROJETO")
        print(LINHA)
        for c in consultas:
            print(f"  {c['numero']}. {c['objetivo']}")
        print("  0. Voltar")
        opcao = input("Escolha a consulta: ").strip()

        if opcao == "0":
            return
        escolhida = next((c for c in consultas if str(c["numero"]) == opcao), None)
        if escolhida is None:
            print("Opção inválida.")
            continue

        print(f"\nCONSULTA {escolhida['numero']}: {escolhida['objetivo']}")
        if escolhida["sql"].startswith("["):
            print("Esta consulta ainda não foi preenchida em Projeto.txt.\n")
            continue
        print(f"SQL:\n{escolhida['sql']}\n")
        try:
            colunas, linhas = executar_sql(conn, escolhida["sql"])
            imprimir_resultado(colunas, linhas)
        except Exception as e:
            print(f"Erro ao executar a consulta: {e}")
        print()


# ---------------------------------------------------------------------------
# Linguagem natural -> SQL (Ollama)
# ---------------------------------------------------------------------------
def montar_prompt(ddl, pergunta, sql_anterior=None, erro=None):
    prompt = (
        "Você é um especialista em PostgreSQL. Com base no esquema abaixo, "
        "converta a pergunta do usuário em UMA única consulta SQL.\n\n"
        "REGRAS:\n"
        "- Responda SOMENTE com a consulta SQL, sem explicações e sem markdown.\n"
        "- Use apenas SELECT (ou WITH ... SELECT). Nunca modifique dados.\n"
        "- Use somente tabelas e colunas que existem no esquema.\n"
        "- Sintaxe PostgreSQL.\n\n"
        f"ESQUEMA (DDL):\n{ddl}\n\n"
        f"PERGUNTA: {pergunta}\n"
    )
    if sql_anterior and erro:
        prompt += (
            f"\nA consulta anterior falhou.\nSQL anterior:\n{sql_anterior}\n"
            f"Erro: {erro}\nCorrija e responda apenas com a SQL.\n"
        )
    prompt += "\nSQL:\n/no_think"
    return prompt


def extrair_sql(resposta):
    """Remove blocos <think>, cercas markdown e texto extra da resposta."""
    texto = re.sub(r"<think>.*?</think>", "", resposta, flags=re.DOTALL)
    bloco = re.search(r"```(?:sql)?\s*(.*?)```", texto, flags=re.DOTALL | re.IGNORECASE)
    if bloco:
        texto = bloco.group(1)
    texto = texto.strip()
    # descarta prefixos antes do primeiro SELECT/WITH, se houver
    inicio = re.search(r"\b(SELECT|WITH)\b", texto, flags=re.IGNORECASE)
    if inicio:
        texto = texto[inicio.start():]
    return texto.strip()


def sql_somente_leitura(sql):
    """Verificação simples: uma única instrução, iniciando em SELECT/WITH."""
    limpo = re.sub(r"--.*?$", "", sql, flags=re.MULTILINE)
    limpo = re.sub(r"/\*.*?\*/", "", limpo, flags=re.DOTALL).strip().rstrip(";").strip()
    if ";" in limpo:
        return False
    if not re.match(r"(?i)^(SELECT|WITH)\b", limpo):
        return False
    proibidas = r"\b(INSERT|UPDATE|DELETE|DROP|ALTER|TRUNCATE|CREATE|GRANT|REVOKE|COPY)\b"
    return re.search(proibidas, limpo, flags=re.IGNORECASE) is None


def modo_linguagem_natural(conn, client, config, ddl):
    print(LINHA)
    print("PERGUNTA EM LINGUAGEM NATURAL")
    print(f"Modelo: {config['ollama']['model']}  (digite 'sair' para voltar)")
    print(LINHA)

    while True:
        pergunta = input("\nPergunta: ").strip()
        if not pergunta:
            continue
        if pergunta.lower() in ("sair", "voltar", "0"):
            return

        sql, erro = None, None
        for tentativa in range(1, MAX_TENTATIVAS_LLM + 1):
            prompt = montar_prompt(ddl, pergunta, sql, erro)
            try:
                resposta = chamar_modelo(client, config, prompt)
            except Exception as e:
                print(f"Erro ao consultar o Ollama: {e}")
                break

            sql = extrair_sql(resposta)
            print(f"\nSQL gerada (tentativa {tentativa}):\n{sql}\n")

            if not sql_somente_leitura(sql):
                erro = "a consulta deve ser uma única instrução SELECT/WITH."
                print(f"Consulta rejeitada: {erro}")
                continue

            try:
                colunas, linhas = executar_sql(conn, sql)
                imprimir_resultado(colunas, linhas)
                break
            except Exception as e:
                erro = str(e).strip()
                print(f"Erro ao executar a SQL: {erro}")
        else:
            print("Não foi possível obter uma consulta válida para essa pergunta.")


# ---------------------------------------------------------------------------
# Menu principal
# ---------------------------------------------------------------------------
def menu(conn, client, config, ddl, consultas):
    while True:
        print(f"\n{LINHA}")
        print("SISTEMA DE GESTÃO DE EVENTOS E ESPAÇOS")
        print(LINHA)
        print("  1. Executar as consultas do projeto")
        print("  2. Fazer uma pergunta em linguagem natural (Ollama)")
        print("  0. Sair")
        opcao = input("Opção: ").strip()

        if opcao == "1":
            executar_consultas_projeto(conn, consultas)
        elif opcao == "2":
            modo_linguagem_natural(conn, client, config, ddl)
        elif opcao == "0":
            return
        else:
            print("Opção inválida.")


def main():
    try:
        config = carregar_config()
    except (OSError, json.JSONDecodeError, KeyError) as e:
        print(f"Erro ao ler config.json: {e}")
        raise SystemExit(1)

    projeto, ddl = carregar_projeto()
    consultas = extrair_consultas(projeto)

    try:
        config = solicitar_parametros(config)
        conn = conectar_postgres(config)
    except (EOFError, KeyboardInterrupt):
        print("\nEncerrado.")
        raise SystemExit(0)
    except Exception as e:
        print(f"Erro ao conectar ao PostgreSQL: {e}")
        raise SystemExit(1)
    print("Conectado ao PostgreSQL.")

    client = criar_cliente_ollama(config)

    try:
        menu(conn, client, config, ddl, consultas)
    except (EOFError, KeyboardInterrupt):
        print()
    finally:
        conn.close()
        print("Conexão encerrada.")


if __name__ == "__main__":
    main()
-- ============================================================
-- DML - Carga de dados para testes
-- Execute DEPOIS do DDL.sql (triggers já criadas).
-- Pode ser reexecutado: o TRUNCATE limpa tudo e reinicia os IDs.
--
-- Observações de projeto:
--  * Os IDs são informados explicitamente (OVERRIDING SYSTEM VALUE)
--    para que as referências fiquem legíveis; as sequences são
--    ajustadas no final.
--  * Inscricao_sessao: status e posicao_espera NÃO são informados;
--    a trigger T5 decide (confirmada x lista_espera). A ordem dos
--    INSERTs define a ordem da fila.
--  * Alguns UPDATE/DELETE no final servem para disparar T4 (histórico)
--    e T6 (promoção da lista de espera).
-- ============================================================

BEGIN;

TRUNCATE TABLE
    Historico_sessao, Inscricao_sessao, Dispoe, Requer, Atua_Em,
    Sessao, Inscricao, Atividade, Recurso, Promove, Espaco,
    Organizacao, Pessoa, Promotor, Evento, Iniciativa
RESTART IDENTITY CASCADE;

-- ============================================================
-- 1. Iniciativas
-- ============================================================
INSERT INTO Iniciativa (iniciativa_id, nome) OVERRIDING SYSTEM VALUE VALUES
    (1, 'Semana de Computação (SECOMP)'),
    (2, 'Congresso Brasileiro de Banco de Dados (CBBD)'),
    (3, 'Feira de Ciência e Tecnologia'),
    (4, 'Simpósio Brasileiro de Engenharia de Software (SBES)'),
    (5, 'Programa de Treinamento em Liderança'),
    (6, 'Semana Acadêmica de Engenharia Ambiental');   -- sem eventos

-- ============================================================
-- 2. Eventos (hoje = 04/11/2026)
-- ============================================================
INSERT INTO Evento (evento_id, iniciativa_id, edicao, data_inicio, data_fim) OVERRIDING SYSTEM VALUE VALUES
    (1, 1, '2025',              '2025-10-13', '2025-10-17'),  -- passado
    (2, 1, '2026',              '2026-11-09', '2026-11-13'),  -- evento principal de teste
    (3, 2, '2026',              '2026-11-16', '2026-11-18'),
    (4, 3, '2026',              '2026-11-20', '2026-11-22'),
    (5, 4, '2026',              '2026-12-01', '2026-12-04'),
    (6, 5, 'Turma 1 - 2026',    '2026-11-05', '2026-11-05'),  -- evento de 1 dia (data_fim = data_inicio)
    (7, 5, 'Turma 2 - 2027',    '2027-02-10', '2027-02-11'),
    (8, 2, '2025',              '2025-09-22', '2025-09-24'),  -- passado
    (9, 3, '2027',              '2027-05-14', '2027-05-16');  -- sem atividades (só planejado)

-- ============================================================
-- 3. Promotores: organizações (1-5) e pessoas (6-20)
-- ============================================================
INSERT INTO Promotor (promotor_id, email) OVERRIDING SYSTEM VALUE VALUES
    (1,  'eventos@icmc.example.br'),
    (2,  'contato@sociedade-computacao.example.org'),
    (3,  'parcerias@techbrasil.example.com'),
    (4,  'cultura@fundacaoparque.example.org'),
    (5,  'atendimento@liderancaplena.example.com'),
    (6,  'ana.souza@example.com'),
    (7,  'carlos.lima@example.com'),
    (8,  'mariana.ferreira@example.com'),
    (9,  'joao.alves@example.com'),
    (10, 'fernanda.oliveira@example.com'),
    (11, 'ricardo.menezes@example.com'),
    (12, 'luciana.prado@example.com'),
    (13, 'paulo.costa@example.com'),
    (14, 'patricia.nogueira@example.com'),
    (15, 'rafael.barbosa@example.com'),
    (16, 'beatriz.tavares@example.com'),
    (17, 'gustavo.rocha@example.com'),
    (18, 'helena.duarte@example.com'),
    (19, 'thiago.martins@example.com'),
    (20, 'sofia.carvalho@example.com');

INSERT INTO Organizacao (promotor_id, CNPJ, razao_social) VALUES
    (1, '45678901000175', 'Instituto de Ciências Matemáticas e de Computação'),
    (2, '56789012000100', 'Sociedade Brasileira de Computação'),
    (3, '67890123000116', 'TechBrasil Soluções em Tecnologia Ltda'),
    (4, '78901234000105', 'Fundação Parque Tecnológico'),
    (5, '89012345000179', 'Instituto Liderança Plena Ltda');

INSERT INTO Pessoa (promotor_id, CPF, nome) VALUES
    (6,  '12345600110', 'Ana Beatriz Souza'),
    (7,  '12346392030', 'Carlos Eduardo Lima'),
    (8,  '12347183915', 'Mariana Ferreira'),
    (9,  '12347975854', 'João Pedro Alves'),
    (10, '12348767791', 'Fernanda Oliveira'),
    (11, '12349559629', 'Ricardo Menezes'),
    (12, '12350351580', 'Luciana Prado'),
    (13, '12351143418', 'Paulo Henrique Costa'),
    (14, '12351935357', 'Patrícia Nogueira'),
    (15, '12352727294', 'Rafael Barbosa'),
    (16, '12353519121', 'Beatriz Tavares'),
    (17, '12354311001', 'Gustavo Rocha'),
    (18, '12355102988', 'Helena Duarte'),
    (19, '12355894809', 'Thiago Martins'),
    (20, '12356686738', 'Sofia Carvalho');

-- ============================================================
-- 4. Quem promove cada evento (papel; o evento 7 usa o DEFAULT)
-- ============================================================
INSERT INTO Promove (evento_id, promotor_id, papel) VALUES
    (1, 1, 'realizador'),
    (1, 6, 'coordenador geral'),
    (1, 3, 'patrocinador'),
    (2, 1, 'realizador'),
    (2, 6, 'coordenador geral'),
    (2, 7, 'coordenador de programação'),
    (2, 3, 'patrocinador'),
    (2, 4, 'apoio institucional'),
    (3, 2, 'realizador'),
    (3, 1, 'apoio institucional'),
    (3, 8, 'coordenador geral'),
    (3, 3, 'patrocinador'),
    (4, 4, 'realizador'),
    (4, 9, 'curador'),
    (4, 1, 'apoio institucional'),
    (5, 2, 'realizador'),
    (5, 10, 'coordenador geral'),
    (5, 3, 'patrocinador'),
    (6, 5, 'realizador'),
    (6, 11, 'facilitador'),
    (8, 2, 'realizador'),
    (8, 8, 'coordenador geral'),
    (9, 9, 'realizador');                 -- evento 9: promovido só por uma pessoa
INSERT INTO Promove (evento_id, promotor_id) VALUES (7, 5);   -- papel = 'promotor' (DEFAULT)

-- ============================================================
-- 5. Espaços
-- ============================================================
INSERT INTO Espaco (espaco_id, nome, capacidade) OVERRIDING SYSTEM VALUE VALUES
    (1,  'Auditório Principal',            500),
    (2,  'Auditório B',                    200),
    (3,  'Sala A',                          40),
    (4,  'Sala B',                          40),
    (5,  'Laboratório de Informática 1',    30),
    (6,  'Laboratório de Informática 2',    30),
    (7,  'Sala de Reuniões',                12),
    (8,  'Pavilhão de Exposições',        1000),
    (9,  'Sala C',                          25),
    (10, 'Espaço Multiuso Externo',        150),
    (11, 'Sala D',                          20);   -- sem recursos e sem sessões

-- ============================================================
-- 6. Recursos e disponibilidade nos espaços
-- ============================================================
INSERT INTO Recurso (recurso_id, nome) OVERRIDING SYSTEM VALUE VALUES
    (1, 'Projetor'),
    (2, 'Computadores'),
    (3, 'Sistema de Áudio'),
    (4, 'Acesso à Internet'),
    (5, 'Lousa Digital'),
    (6, 'Equipamento de Transmissão ao Vivo'),
    (7, 'Estandes de Exposição'),
    (8, 'Cabine de Tradução Simultânea'),
    (9, 'Drone para Demonstração');         -- não existe em nenhum espaço

INSERT INTO Dispoe (espaco_id, recurso_id, quantidade) VALUES
    (1, 1, 3), (1, 3, 4), (1, 4, 1), (1, 6, 2), (1, 8, 1),
    (2, 1, 2), (2, 3, 2), (2, 4, 1), (2, 6, 1),
    (3, 1, 1), (3, 4, 1), (3, 5, 1),
    (4, 1, 1), (4, 4, 1),
    (5, 1, 1), (5, 2, 30), (5, 4, 1),
    (6, 1, 1), (6, 2, 28), (6, 4, 1), (6, 5, 1),
    (7, 4, 1), (7, 5, 1),
    (8, 3, 2), (8, 4, 1), (8, 7, 40),
    (9, 1, 1),
    (10, 3, 2), (10, 7, 10);
    -- espaço 11 (Sala D) não dispõe de nada

-- ============================================================
-- 7. Atividades
--    exige_inscricao = true  => sessões com inscrição adicional
-- ============================================================
INSERT INTO Atividade (atividade_id, evento_id, titulo, tipo, exige_inscricao, funcao_organizacao) OVERRIDING SYSTEM VALUE VALUES
    -- Evento 1: SECOMP 2025
    (1,  1, 'Palestra de Abertura: Inteligência Artificial no Brasil', 'palestra',      false, 'Abertura'),
    (2,  1, 'Minicurso de Python para Ciência de Dados',               'minicurso',     true,  'Programação técnica'),
    (3,  1, 'Mesa-redonda: Carreiras em TI',                           'mesa-redonda',  false, NULL),
    -- Evento 2: SECOMP 2026
    (4,  2, 'Palestra de Abertura: O Futuro da Computação',            'palestra',      false, 'Abertura'),
    (5,  2, 'Workshop de PostgreSQL',                                  'workshop',      true,  'Programação técnica'),
    (6,  2, 'Minicurso de Git e GitHub',                               'minicurso',     true,  'Programação técnica'),
    (7,  2, 'Painel: Ética em Inteligência Artificial',                'painel',        false, 'Programação científica'),
    (8,  2, 'Hackathon SECOMP',                                        'maratona',      true,  'Competição'),
    (9,  2, 'Feira de Projetos Estudantis',                            'exposição',     false, 'Extensão'),
    (10, 2, 'Apresentação de Pôsteres',                                'apresentação',  false, 'Programação científica'),
    (11, 2, 'Palestra Convidada: Computação Quântica',                 'palestra',      false, 'Programação científica'),
    (12, 2, 'Minicurso de Segurança da Informação',                    'minicurso',     true,  'Programação técnica'),
    (13, 2, 'Mesa-redonda: Mulheres na Computação',                    'mesa-redonda',  false, 'Diversidade'),
    (14, 2, 'Networking com Empresas Parceiras',                       'networking',    false, NULL),   -- sem sessões ainda
    -- Evento 3: CBBD 2026
    (15, 3, 'Keynote: Bancos de Dados na Era da IA',                   'palestra',      false, 'Abertura'),
    (16, 3, 'Tutorial de Modelagem Relacional',                        'tutorial',      true,  'Programação técnica'),
    (17, 3, 'Sessão Técnica: Processamento de Consultas',              'apresentação',  false, 'Programação científica'),
    (18, 3, 'Painel: Governança de Dados',                             'painel',        false, 'Programação científica'),
    (19, 3, 'Workshop de Dados Abertos',                               'workshop',      true,  'Programação técnica'),
    -- Evento 4: Feira de Ciência e Tecnologia 2026
    (20, 4, 'Exposição de Projetos de Ciências',                       'exposição',     false, 'Exposição'),
    (21, 4, 'Oficina de Robótica para Crianças',                       'oficina',       true,  'Extensão'),
    (22, 4, 'Show de Ciência',                                         'apresentação',  false, 'Entretenimento'),
    (23, 4, 'Palestra: Divulgação Científica',                         'palestra',      false, NULL),
    -- Evento 5: SBES 2026
    (24, 5, 'Palestra de Abertura do SBES',                            'palestra',      false, 'Abertura'),
    (25, 5, 'Workshop de Testes de Software',                          'workshop',      true,  'Programação técnica'),
    (26, 5, 'Mesa-redonda: Engenharia de Software e IA',               'mesa-redonda',  false, 'Programação científica'),
    -- Evento 6: Treinamento Liderança Turma 1
    (27, 6, 'Treinamento: Comunicação e Liderança',                    'treinamento',   true,  'Treinamento'),
    (28, 6, 'Dinâmica de Grupo: Feedback Efetivo',                     'dinâmica',      true,  'Treinamento'),
    -- Evento 7: Treinamento Liderança Turma 2
    (29, 7, 'Treinamento: Gestão de Conflitos',                        'treinamento',   true,  'Treinamento'),
    -- Evento 8: CBBD 2025
    (30, 8, 'Keynote CBBD 2025',                                       'palestra',      false, 'Abertura'),
    (31, 8, 'Tutorial de Bancos de Dados NoSQL',                       'tutorial',      true,  'Programação técnica');

-- ============================================================
-- 8. Recursos requeridos pelas atividades
--    (a atividade 14 não requer nada)
-- ============================================================
INSERT INTO Requer (atividade_id, recurso_id) VALUES
    (1, 1), (1, 3),
    (2, 1), (2, 2), (2, 4),
    (3, 1),
    (4, 1), (4, 3),
    (5, 1), (5, 2), (5, 4),
    (6, 2), (6, 4),
    (7, 1), (7, 3),
    (8, 2), (8, 4),
    (9, 7),
    (10, 7),
    (11, 1), (11, 6),
    (12, 1), (12, 2),
    (13, 1), (13, 3),
    (15, 1), (15, 3), (15, 6), (15, 8),
    (16, 1), (16, 2), (16, 4),
    (17, 1),
    (18, 1), (18, 3),
    (19, 2), (19, 4),
    (20, 7),
    (21, 1),
    (22, 3),
    (23, 1), (23, 3),
    (24, 1), (24, 3),
    (25, 2), (25, 4),
    (26, 1),
    (27, 1), (27, 5),
    (28, 5),
    (29, 1), (29, 5),
    (30, 1), (30, 3),
    (31, 2), (31, 4);

-- ============================================================
-- 9. Quem atua em cada atividade (somente Pessoa)
-- ============================================================
INSERT INTO Atua_Em (pessoa_id, atividade_id, funcao) VALUES
    (12, 1, 'palestrante'),
    (7,  2, 'instrutor'),
    (14, 2, 'monitor'),
    (13, 3, 'mediador'), (15, 3, 'debatedor'), (16, 3, 'debatedor'),
    (12, 4, 'palestrante'), (6, 4, 'organizador'),
    (8,  5, 'instrutor'), (17, 5, 'instrutor'), (18, 5, 'monitor'),
    (19, 6, 'instrutor'), (18, 6, 'monitor'),
    (13, 7, 'mediador'), (14, 7, 'debatedor'), (20, 7, 'debatedor'), (12, 7, 'debatedor'),
    (7,  8, 'coordenador'), (15, 8, 'avaliador'), (16, 8, 'avaliador'), (17, 8, 'avaliador'),
    (9,  9, 'curador'),
    (6, 10, 'avaliador'), (9, 10, 'avaliador'),
    (20, 11, 'palestrante'),
    (14, 12, 'instrutor'),
    (10, 13, 'mediador'), (18, 13, 'debatedor'), (20, 13, 'debatedor'), (16, 13, 'debatedor'),
    (10, 15, 'palestrante'),
    (8,  16, 'instrutor'),
    (15, 17, 'apresentador'), (16, 17, 'apresentador'), (17, 17, 'moderador'),
    (11, 18, 'mediador'), (8, 18, 'debatedor'),
    (19, 19, 'instrutor'), (18, 19, 'monitor'),
    (9,  20, 'curador'),
    (6,  21, 'instrutor'), (10, 21, 'monitor'),
    (7,  22, 'apresentador'),
    (13, 23, 'palestrante'),
    (12, 24, 'palestrante'),
    (19, 25, 'instrutor'),
    (11, 26, 'mediador'), (14, 26, 'debatedor'),
    (11, 27, 'instrutor'),
    (11, 28, 'facilitador'), (18, 28, 'monitor'),
    (11, 29, 'instrutor'),
    (8,  30, 'palestrante'),
    (15, 31, 'instrutor'), (17, 31, 'monitor');

-- ============================================================
-- 10. Sessões
--     Passam por T1 (conflito de espaço), T2 (vagas x capacidade)
--     e T3 (recursos). Ordem dos campos:
--     (sessao_id, atividade_id, espaco_id, inicio, fim, vagas, status)
-- ============================================================
INSERT INTO Sessao (sessao_id, atividade_id, espaco_id, inicio, fim, vagas, status) OVERRIDING SYSTEM VALUE VALUES
    -- Evento 1 (SECOMP 2025, já realizado)
    (1,  1, 1, '2025-10-13 19:00', '2025-10-13 20:30', NULL, 'realizada'),
    (2,  2, 5, '2025-10-14 09:00', '2025-10-14 12:00', 4,    'realizada'),   -- vagas baixas: gera fila
    (3,  2, 5, '2025-10-14 14:00', '2025-10-14 17:00', 30,   'realizada'),
    (4,  3, 2, '2025-10-15 16:00', '2025-10-15 18:00', NULL, 'realizada'),
    -- Evento 2 (SECOMP 2026)
    (5,  4, 1, '2026-11-09 19:00', '2026-11-09 20:30', NULL, 'agendada'),
    (6,  5, 5, '2026-11-09 09:00', '2026-11-09 12:00', 5,    'agendada'),    -- PostgreSQL, sessão 1
    (7,  5, 6, '2026-11-09 14:00', '2026-11-09 17:00', 5,    'agendada'),    -- PostgreSQL, sessão 2
    (8,  6, 6, '2026-11-10 09:00', '2026-11-10 12:00', 25,   'agendada'),
    (9,  6, 6, '2026-11-10 14:00', '2026-11-10 17:00', 25,   'agendada'),
    (10, 7, 2, '2026-11-10 16:00', '2026-11-10 17:30', NULL, 'agendada'),
    (11, 8, 5, '2026-11-11 09:00', '2026-11-11 18:00', NULL, 'agendada'),    -- vagas NULL = ilimitado
    (12, 9, 8, '2026-11-11 10:00', '2026-11-11 18:00', NULL, 'agendada'),
    (13, 10, 8, '2026-11-12 10:00', '2026-11-12 16:00', NULL, 'agendada'),
    (14, 11, 1, '2026-11-12 19:00', '2026-11-12 20:30', NULL, 'agendada'),   -- será cancelada e remarcada (S15)
    (15, 11, 1, '2026-11-13 19:00', '2026-11-13 20:30', NULL, 'agendada'),
    (17, 12, 5, '2026-11-12 14:00', '2026-11-12 17:00', 3,    'agendada'),   -- vagas baixas: gera fila
    (18, 12, 6, '2026-11-13 09:00', '2026-11-13 12:00', 30,   'agendada'),   -- vagas = capacidade
    (19, 6, 5, '2026-11-12 17:00', '2026-11-12 19:00', 20,   'agendada'),    -- começa quando a S17 termina (permitido)
    -- Evento 3 (CBBD 2026)
    (20, 15, 1, '2026-11-16 09:00', '2026-11-16 10:30', NULL, 'agendada'),
    (21, 16, 5, '2026-11-16 14:00', '2026-11-16 17:00', 30,   'agendada'),
    (22, 17, 3, '2026-11-17 09:00', '2026-11-17 10:30', NULL, 'agendada'),   -- será movida (histórico)
    (23, 17, 4, '2026-11-17 09:00', '2026-11-17 10:30', NULL, 'agendada'),   -- mesmo horário, outro espaço
    (24, 18, 2, '2026-11-17 14:00', '2026-11-17 15:30', NULL, 'agendada'),
    (25, 19, 6, '2026-11-18 09:00', '2026-11-18 12:00', 20,   'agendada'),
    -- Evento 4 (Feira de Ciência e Tecnologia 2026)
    (26, 20, 8,  '2026-11-20 09:00', '2026-11-20 18:00', NULL, 'agendada'),
    (27, 20, 8,  '2026-11-21 09:00', '2026-11-21 18:00', NULL, 'agendada'),
    (28, 20, 8,  '2026-11-22 09:00', '2026-11-22 16:00', NULL, 'agendada'),
    (29, 21, 9,  '2026-11-21 09:00', '2026-11-21 11:00', 20,   'agendada'),
    (30, 21, 9,  '2026-11-21 14:00', '2026-11-21 16:00', 25,   'agendada'),  -- vagas = capacidade da Sala C
    (31, 22, 10, '2026-11-21 15:00', '2026-11-21 16:00', NULL, 'agendada'),
    (32, 23, 2,  '2026-11-22 10:00', '2026-11-22 11:30', NULL, 'agendada'),
    -- Evento 5 (SBES 2026)
    (33, 24, 1, '2026-12-01 09:00', '2026-12-01 10:30', NULL, 'agendada'),
    (34, 25, 5, '2026-12-02 09:00', '2026-12-02 12:00', 30,   'agendada'),
    (35, 25, 6, '2026-12-02 14:00', '2026-12-02 17:00', 28,   'agendada'),
    (36, 26, 2, '2026-12-03 16:00', '2026-12-03 18:00', NULL, 'agendada'),
    -- Evento 6 (Treinamento Liderança - Turma 1, 05/11/2026)
    (37, 27, 3, '2026-11-05 09:00', '2026-11-05 12:00', 30,   'agendada'),
    (38, 27, 3, '2026-11-05 14:00', '2026-11-05 17:00', 30,   'agendada'),
    (39, 28, 7, '2026-11-05 10:00', '2026-11-05 12:00', 10,   'agendada'),   -- 10 vagas, 12 interessados
    -- Evento 7 (Treinamento Liderança - Turma 2)
    (40, 29, 3, '2027-02-10 09:00', '2027-02-10 12:00', 30,   'agendada'),
    (41, 29, 3, '2027-02-11 09:00', '2027-02-11 12:00', 30,   'agendada'),
    -- Evento 8 (CBBD 2025, já realizado)
    (42, 30, 1, '2025-09-22 09:00', '2025-09-22 10:30', NULL, 'realizada'),
    (43, 31, 5, '2025-09-23 14:00', '2025-09-23 17:00', 3,    'realizada'),
    (44, 31, 6, '2025-09-24 09:00', '2025-09-24 12:00', 30,   'agendada');   -- será cancelada

-- A sessão 14 é cancelada e, em seguida, o mesmo horário/espaço é reaproveitado
-- (T1 ignora sessões canceladas). A palestra foi remarcada na sessão 15.
UPDATE Sessao SET status = 'cancelada' WHERE sessao_id = 14;

INSERT INTO Sessao (sessao_id, atividade_id, espaco_id, inicio, fim, vagas, status) OVERRIDING SYSTEM VALUE VALUES
    (16, 13, 1, '2026-11-12 19:00', '2026-11-12 20:30', NULL, 'agendada');   -- mesmo espaço e horário da sessão 14 cancelada

-- ============================================================
-- 11. Inscrições no evento (sem vínculo com pessoa, conforme o modelo)
-- ============================================================
INSERT INTO Inscricao (inscricao_id, evento_id, status) OVERRIDING SYSTEM VALUE
SELECT n, 1, CASE WHEN n IN (9, 10) THEN 'cancelada' ELSE 'confirmada' END FROM generate_series(1, 10) n;

INSERT INTO Inscricao (inscricao_id, evento_id, status) OVERRIDING SYSTEM VALUE
SELECT n, 2, CASE WHEN n IN (38, 39, 40) THEN 'cancelada' ELSE 'confirmada' END FROM generate_series(11, 40) n;

INSERT INTO Inscricao (inscricao_id, evento_id, status) OVERRIDING SYSTEM VALUE
SELECT n, 3, CASE WHEN n IN (51, 52) THEN 'cancelada' ELSE 'confirmada' END FROM generate_series(41, 52) n;

INSERT INTO Inscricao (inscricao_id, evento_id, status) OVERRIDING SYSTEM VALUE
SELECT n, 4, CASE WHEN n IN (63, 64) THEN 'cancelada' ELSE 'confirmada' END FROM generate_series(53, 64) n;

INSERT INTO Inscricao (inscricao_id, evento_id, status) OVERRIDING SYSTEM VALUE
SELECT n, 5, CASE WHEN n IN (71, 72) THEN 'cancelada' ELSE 'confirmada' END FROM generate_series(65, 72) n;

INSERT INTO Inscricao (inscricao_id, evento_id, status) OVERRIDING SYSTEM VALUE
SELECT n, 6, CASE WHEN n IN (85, 86) THEN 'cancelada' ELSE 'confirmada' END FROM generate_series(73, 86) n;

INSERT INTO Inscricao (inscricao_id, evento_id, status) OVERRIDING SYSTEM VALUE
SELECT n, 7, CASE WHEN n = 90 THEN 'cancelada' ELSE 'confirmada' END FROM generate_series(87, 90) n;

INSERT INTO Inscricao (inscricao_id, evento_id, status) OVERRIDING SYSTEM VALUE
SELECT n, 8, CASE WHEN n IN (97, 98) THEN 'cancelada' ELSE 'confirmada' END FROM generate_series(91, 98) n;
-- evento 9: nenhuma inscrição ainda

-- ============================================================
-- 12. Inscrições em sessões (T5 decide confirmada x lista_espera)
--     Só entram inscrições confirmadas do mesmo evento.
-- ============================================================

-- Evento 1 -------------------------------------------------
-- S2 (4 vagas): 1-4 confirmadas; 5 e 6 ficam na fila (posição 1 e 2)
INSERT INTO Inscricao_sessao (inscricao_id, sessao_id)
SELECT n, 2 FROM generate_series(1, 6) n ORDER BY n;
-- S3 (30 vagas): sem fila
INSERT INTO Inscricao_sessao (inscricao_id, sessao_id) VALUES (1, 3), (3, 3), (7, 3), (8, 3);

-- Evento 2 -------------------------------------------------
-- S6 (5 vagas): 11-15 confirmadas; 16, 17, 18 na fila (posição 1, 2, 3)
INSERT INTO Inscricao_sessao (inscricao_id, sessao_id)
SELECT n, 6 FROM generate_series(11, 18) n ORDER BY n;
-- S7 (5 vagas): 19-23 confirmadas; 24 e 25 na fila
INSERT INTO Inscricao_sessao (inscricao_id, sessao_id)
SELECT n, 7 FROM generate_series(19, 25) n ORDER BY n;
-- S8 (25 vagas): 20 confirmadas, ainda há vagas
INSERT INTO Inscricao_sessao (inscricao_id, sessao_id)
SELECT n, 8 FROM generate_series(11, 30) n ORDER BY n;
-- S9 (25 vagas): lotada (11-35) + fila com 36 e 37
INSERT INTO Inscricao_sessao (inscricao_id, sessao_id)
SELECT n, 9 FROM generate_series(11, 37) n ORDER BY n;
-- S11 (Hackathon, vagas NULL): todas confirmadas
INSERT INTO Inscricao_sessao (inscricao_id, sessao_id)
SELECT n, 11 FROM generate_series(11, 30) n ORDER BY n;
-- S17 (3 vagas): 11-13 confirmadas; 14, 15, 16 na fila
INSERT INTO Inscricao_sessao (inscricao_id, sessao_id)
SELECT n, 17 FROM generate_series(11, 16) n ORDER BY n;
-- S18 (30 vagas): sem fila
INSERT INTO Inscricao_sessao (inscricao_id, sessao_id)
SELECT n, 18 FROM generate_series(20, 29) n ORDER BY n;
-- S19: sessão sem nenhuma inscrição (de propósito)

-- Evento 3 -------------------------------------------------
INSERT INTO Inscricao_sessao (inscricao_id, sessao_id)
SELECT n, 21 FROM generate_series(41, 48) n ORDER BY n;
INSERT INTO Inscricao_sessao (inscricao_id, sessao_id)
SELECT n, 25 FROM generate_series(41, 45) n ORDER BY n;

-- Evento 4 -------------------------------------------------
INSERT INTO Inscricao_sessao (inscricao_id, sessao_id)
SELECT n, 29 FROM generate_series(53, 62) n ORDER BY n;
INSERT INTO Inscricao_sessao (inscricao_id, sessao_id)
SELECT n, 30 FROM generate_series(53, 57) n ORDER BY n;

-- Evento 5 -------------------------------------------------
INSERT INTO Inscricao_sessao (inscricao_id, sessao_id)
SELECT n, 34 FROM generate_series(65, 68) n ORDER BY n;
INSERT INTO Inscricao_sessao (inscricao_id, sessao_id) VALUES (65, 35), (69, 35), (70, 35);

-- Evento 6 -------------------------------------------------
INSERT INTO Inscricao_sessao (inscricao_id, sessao_id)
SELECT n, 37 FROM generate_series(73, 84) n ORDER BY n;
INSERT INTO Inscricao_sessao (inscricao_id, sessao_id)
SELECT n, 38 FROM generate_series(73, 80) n ORDER BY n;
-- S39 (10 vagas): 73-82 confirmadas; 83 e 84 na fila
INSERT INTO Inscricao_sessao (inscricao_id, sessao_id)
SELECT n, 39 FROM generate_series(73, 84) n ORDER BY n;

-- Evento 7 -------------------------------------------------
INSERT INTO Inscricao_sessao (inscricao_id, sessao_id) VALUES (87, 40), (88, 40), (89, 40), (87, 41), (88, 41);

-- Evento 8 -------------------------------------------------
-- S43 (3 vagas): 91-93 confirmadas; 94 e 95 na fila
INSERT INTO Inscricao_sessao (inscricao_id, sessao_id)
SELECT n, 43 FROM generate_series(91, 95) n ORDER BY n;
-- S44 (será cancelada): 6 inscritas
INSERT INTO Inscricao_sessao (inscricao_id, sessao_id)
SELECT n, 44 FROM generate_series(91, 96) n ORDER BY n;

-- ============================================================
-- 13. Cenários dinâmicos: disparam T4 (histórico) e T6 (promoção)
-- ============================================================

-- T6 via UPDATE: inscrição 2 cancela a S2 -> inscrição 5 (1ª da fila) é promovida; 6 sobe para posição 1
UPDATE Inscricao_sessao SET status = 'cancelada' WHERE inscricao_id = 2 AND sessao_id = 2;

-- T6 via UPDATE na S17: inscrição 12 cancela -> 14 é promovida; 15 e 16 sobem (posição 1 e 2)
UPDATE Inscricao_sessao SET status = 'cancelada' WHERE inscricao_id = 12 AND sessao_id = 17;

-- T6 via DELETE na S9: inscrição 35 é removida -> 36 é promovida; 37 passa a posição 1
DELETE FROM Inscricao_sessao WHERE inscricao_id = 35 AND sessao_id = 9;

-- T6 duas vezes na S43 (sessão realizada): cancelam 92 e 93 -> promovem 94 e 95; fila zera
UPDATE Inscricao_sessao SET status = 'cancelada' WHERE inscricao_id = 92 AND sessao_id = 43;
UPDATE Inscricao_sessao SET status = 'cancelada' WHERE inscricao_id = 93 AND sessao_id = 43;

-- Cancelamento de sessão inteira (S44): a sessão é cancelada e as inscrições também (T6 não promove nada)
UPDATE Sessao SET status = 'cancelada' WHERE sessao_id = 44;
UPDATE Inscricao_sessao SET status = 'cancelada', posicao_espera = NULL WHERE sessao_id = 44;

-- T4: histórico de mudanças de horário/espaço
-- S10 muda de horário (mesmo espaço)                          -> 1 linha no histórico
UPDATE Sessao SET inicio = '2026-11-10 16:30', fim = '2026-11-10 18:00' WHERE sessao_id = 10;
-- S22 muda de espaço (Sala A -> Sala C) e de horário          -> 1 linha no histórico
UPDATE Sessao SET espaco_id = 9, inicio = '2026-11-17 09:30', fim = '2026-11-17 11:00' WHERE sessao_id = 22;
-- S13 muda duas vezes: horário e depois espaço (Pavilhão -> Multiuso) -> 2 linhas no histórico
UPDATE Sessao SET inicio = '2026-11-12 11:00', fim = '2026-11-12 17:00' WHERE sessao_id = 13;
UPDATE Sessao SET espaco_id = 10 WHERE sessao_id = 13;
-- Alteração que NÃO é de espaço/horário (só vagas): a trigger T4 não deve registrar nada
UPDATE Sessao SET vagas = 24 WHERE sessao_id = 8;
-- Espalha as datas do histórico para parecer uso real
UPDATE Historico_sessao SET alterado_em = CURRENT_TIMESTAMP - (id * interval '1 day') - interval '2 hours';

-- ============================================================
-- 14. Ajuste das sequences (IDs foram informados manualmente)
-- ============================================================
SELECT setval(pg_get_serial_sequence('iniciativa', 'iniciativa_id'), (SELECT MAX(iniciativa_id) FROM Iniciativa));
SELECT setval(pg_get_serial_sequence('evento',     'evento_id'),     (SELECT MAX(evento_id)     FROM Evento));
SELECT setval(pg_get_serial_sequence('promotor',   'promotor_id'),   (SELECT MAX(promotor_id)   FROM Promotor));
SELECT setval(pg_get_serial_sequence('espaco',     'espaco_id'),     (SELECT MAX(espaco_id)     FROM Espaco));
SELECT setval(pg_get_serial_sequence('recurso',    'recurso_id'),    (SELECT MAX(recurso_id)    FROM Recurso));
SELECT setval(pg_get_serial_sequence('atividade',  'atividade_id'),  (SELECT MAX(atividade_id)  FROM Atividade));
SELECT setval(pg_get_serial_sequence('inscricao',  'inscricao_id'),  (SELECT MAX(inscricao_id)  FROM Inscricao));
SELECT setval(pg_get_serial_sequence('sessao',     'sessao_id'),     (SELECT MAX(sessao_id)     FROM Sessao));

COMMIT;

-- ============================================================
-- 15. CASOS QUE DEVEM FALHAR (execute um por vez, fora da carga)
-- ============================================================
-- T1  conflito de espaço (Aud. Principal já ocupado em 09/11 às 19h):
--   INSERT INTO Sessao (atividade_id, espaco_id, inicio, fim, vagas)
--   VALUES (4, 1, '2026-11-09 20:00', '2026-11-09 21:00', NULL);
-- T2  vagas acima da capacidade (Sala B comporta 40):
--   INSERT INTO Sessao (atividade_id, espaco_id, inicio, fim, vagas)
--   VALUES (17, 4, '2026-11-19 09:00', '2026-11-19 10:00', 50);
-- T3  espaço sem o recurso requerido (Sala C não tem computadores):
--   INSERT INTO Sessao (atividade_id, espaco_id, inicio, fim, vagas)
--   VALUES (5, 9, '2026-11-19 09:00', '2026-11-19 12:00', 10);
-- T5  atividade que não exige inscrição adicional (S5 = palestra de abertura):
--   INSERT INTO Inscricao_sessao (inscricao_id, sessao_id) VALUES (11, 5);
-- T5  inscrição cancelada no evento (38 está cancelada):
--   INSERT INTO Inscricao_sessao (inscricao_id, sessao_id) VALUES (38, 19);
-- T5  inscrição de outro evento (41 é do evento 3, S19 é do evento 2):
--   INSERT INTO Inscricao_sessao (inscricao_id, sessao_id) VALUES (41, 19);
-- T5  sessão cancelada (S44):
--   INSERT INTO Inscricao_sessao (inscricao_id, sessao_id) VALUES (97, 44);
-- CHECK  datas invertidas / CPF inválido / vagas <= 0:
--   INSERT INTO Evento (iniciativa_id, edicao, data_inicio, data_fim) VALUES (6, '2026', '2026-05-10', '2026-05-09');
--   INSERT INTO Pessoa (promotor_id, CPF, nome) VALUES (1, '123', 'Teste');
--   INSERT INTO Sessao (atividade_id, espaco_id, inicio, fim, vagas) VALUES (14, 11, '2026-11-09 08:00', '2026-11-09 09:00', 0);

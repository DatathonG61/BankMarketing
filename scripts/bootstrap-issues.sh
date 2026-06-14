#!/usr/bin/env bash
# bootstrap-issues.sh
# Cria a primeira batch de issues do Datathon (semanas 1-2),
# adiciona cada uma ao Project #2 e seta os fields Etapa + Semana.
#
# Base de dados: Bank Marketing (henriqueyamahata/bank-marketing).
# Divisao POR PESSOA (ref_docs/Divisao de tarefas.md + ref_docs/PLANO.md):
#   - Gabriel  : Eng. de Dados        -> E1, E2, LGPD
#   - Adryen   : Cientista de Dados   -> E3, model/system card
#   - Bertelli : MLOps & Avaliacao    -> E4, E7, model/system card
#   - Matheus  : Backend/Cloud & LLM  -> E5, E6, FinOps
#   - Todos    : Repo + relatorio/pitch -> E0, E8
#
# Pre-requisito: `gh auth refresh -s project,read:project` ja rodado.
# Idempotente: NAO. Roda uma vez. Re-rodar duplica issues.

set -euo pipefail

OWNER="DatathonG61"
REPO="DatathonG61/BankMarketing"
PROJ_NUM=2
PROJ_ID="PVT_kwDOESKui84BYqwk"

ETAPA_FIELD="PVTSSF_lADOESKui84BYqwkzhTu5xc"
SEMANA_FIELD="PVTSSF_lADOESKui84BYqwkzhTu5xk"

declare -A ETAPA_OPT=(
  [E0]="a71e80cc" [E1]="ea34654d" [E2]="c0037028" [E3]="03f83a6a"
  [E4]="201bb92f" [E5]="11ecefb8" [E6]="05a5a9b2" [E7]="102161b8" [E8]="7ee4db9c"
)
declare -A SEMANA_OPT=(
  [1]="e024d8b3" [2]="d3c16595" [3]="371a40ad" [4]="9c362064"
  [5]="0d6a4395" [6]="b2d7d641" [7]="45015996" [8]="8c6a3b29"
)

# create <title> <etapa> <semana> <responsavel> <body>
create() {
  local title="$1" etapa="$2" semana="$3" responsavel="$4" body="$5"

  echo "-> ${title}  [${responsavel}]"
  local full_body
  full_body="**Responsavel:** ${responsavel}

${body}"

  local url
  url=$(gh issue create --repo "$REPO" \
    --title "$title" \
    --body "$full_body" \
    --label "etapa,${etapa}")

  local item_id
  item_id=$(gh project item-add "$PROJ_NUM" --owner "$OWNER" --url "$url" --format json | jq -r '.id')

  gh project item-edit --id "$item_id" --project-id "$PROJ_ID" \
    --field-id "$ETAPA_FIELD" --single-select-option-id "${ETAPA_OPT[$etapa]}" >/dev/null

  gh project item-edit --id "$item_id" --project-id "$PROJ_ID" \
    --field-id "$SEMANA_FIELD" --single-select-option-id "${SEMANA_OPT[$semana]}" >/dev/null

  echo "  OK ${url}"
}

# ============================================================
# E0 -- Todos (coord. Gabriel/Matheus) -- semana 1
# ============================================================

create "[E0] Configurar pacote bankmarketing (build system + layout src/)" E0 1 "Matheus (Backend/Cloud)" \
"## Contexto
O pacote se chama \`bankmarketing\` em \`pyproject.toml\` (alinhado ao repo \`DatathonG61/BankMarketing\`). Falta configurar o build system e o layout \`src/\` para que o pacote seja importavel.

## Definition of Done
- [ ] \`pyproject.toml\` com \`name = \"bankmarketing\"\`
- [ ] Build system para layout \`src/\` (hatchling ou setuptools)
- [ ] \`uv sync\` roda sem erro
- [ ] \`uv run python -c 'import bankmarketing'\` funciona

## Referencias
- Plano: \`ref_docs/PLANO.md\` (E0 + Apendice de Decisoes de Tecnologia)"

create "[E0] Renomear src/datathon_offerexp/ -> src/bankmarketing/ com modulos stub" E0 1 "Matheus (Backend/Cloud)" \
"## Contexto
A pasta atual e \`src/datathon_offerexp/\`, mas o pacote e \`bankmarketing\`. Renomear e criar a estrutura minima de modulos (stubs apenas com docstring + imports; implementacoes vem nas etapas seguintes).

## Definition of Done
- [ ] \`src/bankmarketing/__init__.py\`
- [ ] \`src/bankmarketing/contracts.py\` -- placeholder para pydantic models
- [ ] \`src/bankmarketing/policies.py\` -- placeholder para BaselinePolicy e ThompsonSamplingPolicy
- [ ] \`src/bankmarketing/evaluation.py\` -- placeholder para avaliacao offline
- [ ] \`src/bankmarketing/decision_log.py\` -- placeholder para log auditavel
- [ ] \`src/bankmarketing/app.py\` -- placeholder para FastAPI
- [ ] \`src/bankmarketing/data.py\` -- placeholder para loader do Bank Marketing
- [ ] Cada arquivo importa limpo

## Bloqueia
- E3 (politicas), E5 (API)

## Referencias
- Plano: \`ref_docs/PLANO.md\` (E0)"

create "[E0] Popular README.md raiz do repo" E0 1 "Gabriel (Eng. de Dados)" \
"## Contexto
README na raiz esta vazio. A banca avalia E0 olhando se uma pessoa externa consegue rodar o projeto sem ajuda oral.

## Definition of Done
- [ ] Visao do problema (1 paragrafo): experimentacao adaptativa de ofertas sobre Bank Marketing
- [ ] Escopo e limitacoes
- [ ] Stack tecnico (Python 3.13, uv, FastAPI, MLflow, Azure)
- [ ] Instrucoes de execucao local (\`uv sync\`, \`uv run pytest\`, \`make demo\`)
- [ ] Mapa de pastas
- [ ] Link para \`ref_docs/PLANO.md\` e para o Project #2

## Referencias
- Plano: \`ref_docs/PLANO.md\` (E0)"

create "[E0] Criar .env.example com placeholders de variaveis Azure" E0 1 "Matheus (Backend/Cloud)" \
"## Contexto
Listar variaveis de ambiente necessarias sem valores reais. Required pela banca.

## Definition of Done
- [ ] \`AZURE_OPENAI_ENDPOINT=\`
- [ ] \`AZURE_OPENAI_API_KEY=\`
- [ ] \`AZURE_SEARCH_ENDPOINT=\`
- [ ] \`AZURE_SEARCH_API_KEY=\`
- [ ] \`MLFLOW_TRACKING_URI=\`
- [ ] \`DECISION_LOG_PATH=\`
- [ ] Comentarios explicando cada variavel
- [ ] \`.env\` continua no \`.gitignore\` (ja esta)"

create "[E0] Criar Makefile com targets install/test/lint/demo" E0 1 "Matheus (Backend/Cloud)" \
"## Contexto
Comando unico para reproduzir o pipeline ponta a ponta -- exigencia explicita da E5.

## Definition of Done
- [ ] \`make install\` -> \`uv sync\`
- [ ] \`make test\` -> \`uv run pytest\`
- [ ] \`make lint\` -> \`uvx ruff check .\`
- [ ] \`make demo\` -> stub inicial (sobe API + 5 requests); evolui na E5

## Bloqueia
- E5 (DoD da E5 depende de \`make demo\` funcionar)"

create "[E0] Adicionar licenca ao repo" E0 1 "Todos" \
"## Contexto
Banca exige licenca declarada.

## Decisao pendente
- [ ] **Confirmar tipo de licenca na 1a reuniao** -- sugestao: MIT
- [ ] Criar arquivo \`LICENSE\` na raiz"

create "[E0] Onboarding: cada integrante clona, roda uv sync, abre 1 PR de teste" E0 1 "Todos" \
"## Contexto
Validar que todos os 4 conseguem rodar o ambiente antes da semana 2.

## Definition of Done por integrante
- [ ] Aceitou convite na org DatathonG61
- [ ] Clonou o repo localmente
- [ ] Rodou \`uv sync\` sem erro
- [ ] Rodou \`uv run pytest\` (smoke passa)
- [ ] Abriu 1 PR contra \`main\` adicionando o proprio nome em \`docs/team.md\` (criar)
- [ ] PR teve CI verde e mergeado

## Quem
- [ ] Gabriel Caetano Guimaraes de Mello (Eng. de Dados)
- [ ] Adryen Simoes de Oliveira (Cientista de Dados)
- [ ] Douglas Bertelli Tineu (MLOps & Avaliacao)
- [ ] Matheus Viana Florencio (Backend/Cloud & LLM)"

create "[E0] Convidar integrantes na org + atualizar campo Papel do Project" E0 1 "Gabriel (coord.)" \
"## Contexto
Onboarding administrativo do GitHub e alinhamento do Project com a divisao por pessoas.

## Definition of Done
- [ ] Convidar Adryen, Bertelli e Matheus na org \`DatathonG61\` (coletar usernames)
- [ ] Atualizar opcoes do campo \`Papel\` no Project #2 para a divisao por pessoas
- [ ] Atribuir \`Papel\` em cada issue existente
- [ ] Criar as Views (Kanban, Por pessoa, Roadmap, Por etapa, Bloqueios)"

# ============================================================
# E1 -- Gabriel (Eng. de Dados) -- semanas 1-2
# ============================================================

create "[E1] Baixar Bank Marketing e popular data/kaggle/README.md" E1 1 "Gabriel (Eng. de Dados)" \
"## Contexto
Base factual do projeto. Sem metadados rastreaveis (fonte, versao, licenca), a banca penaliza.

## Definition of Done
- [ ] Dataset baixado em \`data/kaggle/\` (ex.: \`bank-additional-full.csv\` ou equivalente)
- [ ] \`data/kaggle/README.md\` com:
  - link Kaggle e fonte original (UCI Bank Marketing)
  - versao e data do download
  - licenca
  - instrucoes de download (\`kaggle datasets download henriqueyamahata/bank-marketing\`)
  - colunas com descricao breve (age, job, default, housing, loan, ...)
  - **coluna \`duration\` marcada como leakage temporal a remover**
  - limitacoes conhecidas

## Referencias
- https://www.kaggle.com/datasets/henriqueyamahata/bank-marketing"

create "[E1] EDA inicial + dicionario de dados + lista de leakage" E1 1 "Gabriel (Eng. de Dados)" \
"## Contexto
Entender a base antes de modelar. **Confirmar candidatos a leakage temporal** -- \`duration\` e o classico (so existe apos a ligacao).

## Definition of Done
- [ ] \`notebooks/01-eda-e-baseline.ipynb\` com:
  - shape, dtypes, % missing
  - distribuicao do target \`y\`
  - balanceamento de classes
  - distribuicoes de \`age\`, \`job\`, \`default\` (insumo para contexto sintetico; nao ha \`balance\` na base)
  - correlacoes iniciais
  - **lista de features candidatas a leakage com justificativa (\`duration\` no topo)**
- [ ] Dicionario de dados (\`docs/data-dictionary.md\` ou no notebook)

## Bloqueia
- E1 modeling_table, E2 (contexto sintetico), E3 features de contexto"

create "[E1] modeling_table.parquet sem duration + data.py loader" E1 2 "Gabriel (Eng. de Dados)" \
"## Contexto
Tabela de modelagem versionada e codigo que registra fonte/versao/licenca ao carregar.

## Definition of Done
- [ ] \`data/processed/modeling_table.parquet\` gerado a partir do Bank Marketing
- [ ] **Coluna \`duration\` removida explicitamente**, com decisao documentada
- [ ] \`src/bankmarketing/data.py\` com \`load_modeling_table()\` que:
  - retorna DataFrame
  - registra metadata (fonte, versao, licenca) em log estruturado
- [ ] \`tests/test_data.py\` valida shape esperado **e falha se \`duration\` presente**

## Depende de
- EDA + dicionario
- Esqueleto src/bankmarketing/"

create "[E1] Baseline preditivo de propensao v0 (logistic/lightgbm)" E1 2 "Gabriel (Eng. de Dados)" \
"## Contexto
Modelo de propensao a conversao (target \`y\`) que serve de contexto para o bandit e de baseline preditivo.

## Definition of Done
- [ ] Modelo treinado sobre \`modeling_table.parquet\` (sem \`duration\`)
- [ ] Metrica reportada (AUC/PR-AUC) no notebook
- [ ] Score de propensao disponivel como feature de contexto para E3
- [ ] Sem leakage (validado contra a lista de E1)

## Depende de
- modeling_table.parquet"

# ============================================================
# E2 -- Gabriel (Eng. de Dados) -- semanas 1-2
# ============================================================

create "[E2] Schema dos eventos sinteticos em reports/data-generation.md" E2 1 "Gabriel (Eng. de Dados)" \
"## Contexto
Camada sintetica e o que torna o projeto um bandit. Schema **antes** do codigo pra evitar retrabalho.

## Definition of Done
- [ ] \`reports/data-generation.md\` com:
  - bracos (\`Arm\`): \`sem_oferta\`, \`cartao_credito\` (Oferta A), \`investimento\` (Oferta B), \`renegociacao\`
  - canais (\`Channel\`): \`app\`, \`web\`, \`email\`
  - segmentos (\`Segment\`) derivados de age/job/default: ex. \`jovem_baixa_renda\`, \`maduro_alta_renda\`, \`negativado\` (default=yes)
  - schema de \`offer_catalog\`, \`offer_events\`, \`delayed_rewards\`
  - **modelo de delayed reward**: janela temporal, distribuicao
  - hipoteses de negocio (jovem/baixa renda -> cartao; maduro/alta renda -> investimento; negativado/default=yes -> renegociacao)
  - seeds aleatorias usadas

## Bloqueia
- E2 codigo de geracao, E3 replay offline, E4 golden set"

create "[E2] Implementar gerador offer_catalog.sample.csv v0" E2 2 "Gabriel (Eng. de Dados)" \
"## Contexto
Primeiro arquivo sintetico -- catalogo de bracos (ofertas) x canais x segmentos.

## Definition of Done
- [ ] Codigo de geracao em \`src/bankmarketing/synthetic.py\` (ou notebook)
- [ ] \`data/synthetic_enrichment/offer_catalog.sample.csv\` com Oferta A (cartao_credito) e Oferta B (investimento) + sem_oferta + renegociacao
- [ ] Schema validado contra \`reports/data-generation.md\`
- [ ] Seeds documentadas

## Depende de
- Schema (reports/data-generation.md)"

# ============================================================
# E3 -- Adryen (Cientista de Dados) -- semanas 1-2
# ============================================================

create "[E3] Leitura Russo et al. + esboco docs/algorithmic-strategy.md" E3 1 "Adryen (Cientista de Dados)" \
"## Contexto
Fundacao teorica do bandit. Banca exige referencia explicita a Thompson Sampling e Nilos-UCB.

## Definition of Done
- [ ] Ler Russo et al. \"A Tutorial on Thompson Sampling\" (https://arxiv.org/abs/1707.02038)
- [ ] Survey UCB (Auer 2002 ou Lattimore & Szepesvari cap. 7)
- [ ] \`docs/algorithmic-strategy.md\` com:
  - resumo TS em 1 paragrafo (priors, update, exploracao)
  - resumo UCB / Nilos-UCB em 1 paragrafo
  - justificativa de escolha
  - tratamento previsto de cold-start
  - tratamento previsto de delayed rewards

## Referencias
- Plano: \`ref_docs/PLANO.md\` (E3)"

create "[E3] Implementar BaselinePolicy deterministica" E3 2 "Adryen (Cientista de Dados)" \
"## Contexto
Politica simples de controle (ex.: 'sempre ofereca Cartao de Credito'). Sem ela, nao ha comparacao quantitativa.

## Definition of Done
- [ ] \`BaselinePolicy\` em \`src/bankmarketing/policies.py\`
- [ ] Implementa contrato \`select_arm(event, scores, mode='baseline', ...)\`
- [ ] Estrategia documentada (regra fixa ou melhor braco historico)
- [ ] Teste \`tests/test_policies.py::test_baseline\` cobre casos basicos

## Depende de
- Esqueleto src/bankmarketing/
- Schema sintetico"

# ============================================================
# E4 -- Bertelli (MLOps & Avaliacao) -- semanas 1-2
# ============================================================

create "[E4] Esboco do golden set + criterios de avaliacao" E4 1 "Bertelli (MLOps & Avaliacao)" \
"## Contexto
Golden set e o regression test da politica. Esbocar cedo os tipos de caso.

## Definition of Done
- [ ] Rascunho de >= 20 casos (tipicos, borda, adversariais) em texto/planilha:
  - tipico: cliente maduro de maior renda (job=management, default=no, com housing) -> esperado: Investimento
  - borda: cliente negativado (default=yes) -> esperado: NAO oferecer credito, oferecer renegociacao
  - adversarial: contexto inconsistente / faltando campos
- [ ] Definicao do formato final \`data/golden_set/evaluation_cases.jsonl\`
- [ ] Criterios de avaliacao alinhados com o edital

## Referencias
- Plano: \`ref_docs/PLANO.md\` (E4)"

create "[E4] Definir matriz de metricas-alvo (recompensa/regret/fairness)" E4 2 "Bertelli (MLOps & Avaliacao)" \
"## Contexto
Definir o que sera medido antes de E4/E7, alinhado com as metricas do Adryen (E3).

## Definition of Done
- [ ] Lista de metricas: recompensa media, regret, taxa de exploracao, conversao simulada
- [ ] Metricas de fairness: exposicao entre segmentos
- [ ] Esqueleto de \`src/bankmarketing/evaluation.py\` (CLI \`python -m bankmarketing.evaluation\`)
- [ ] Documento inicial em \`reports/offline-evaluation.md\` (estrutura)

## Depende de
- Contrato de politica (E3)"

# ============================================================
# E5 -- Matheus (Backend/Cloud & LLM) -- semana 2
# ============================================================

create "[E5] API stub FastAPI /decide com contratos pydantic congelados" E5 2 "Matheus (Backend/Cloud & LLM)" \
"## Contexto
Forcar integracao desde a semana 2 -- \`make demo\` ponta a ponta na semana 3 depende disso.

## Definition of Done
- [ ] \`src/bankmarketing/app.py\` com endpoint \`POST /decide\`
- [ ] \`src/bankmarketing/contracts.py\` com pydantic:
  - \`DecisionRequest\` (event_id, subject_key, channel, segment, available_arms, context)
  - \`DecisionResponse\` (decision_id, selected_arm, reason_codes, policy_version)
  - \`DecisionLog\`
- [ ] Tratamento de erro estruturado
- [ ] Suite minima em \`tests/test_app.py\` valida happy path + erro

## Depende de
- Esqueleto src/bankmarketing/
- BaselinePolicy (ou stub temporario)"

create "[E5] Integrar dependencias reais no pyproject.toml" E5 2 "Matheus (Backend/Cloud & LLM)" \
"## Contexto
Adicionar as libs do runtime (ate aqui \`dependencies = []\`).

## Definition of Done
- [ ] \`fastapi\`, \`uvicorn\`, \`pydantic\`, \`mlflow\`, \`pandas\`/\`polars\`, \`scikit-learn\` (ou lightgbm)
- [ ] \`uv sync\` resolve sem conflito
- [ ] CI continua verde

## Depende de
- Pacote bankmarketing configurado (E0)"

echo ""
echo "Concluido."

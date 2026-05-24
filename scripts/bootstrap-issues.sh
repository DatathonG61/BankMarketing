#!/usr/bin/env bash
# bootstrap-issues.sh
# Cria as issues iniciais do Datathon (E0–E5, semanas 1–2),
# adiciona cada uma ao Project #2 e seta os fields Etapa + Semana.
#
# Pré-requisito: `gh auth refresh -s project,read:project` já rodado.
# Idempotente: NÃO. Roda uma vez. Re-rodar duplica issues.

set -euo pipefail

OWNER="DatathonG61"
REPO="DatathonG61/7mlet"
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

create() {
  local title="$1" etapa="$2" semana="$3" body="$4"

  echo "→ ${title}"
  local url
  url=$(gh issue create --repo "$REPO" \
    --title "$title" \
    --body "$body" \
    --label "etapa,${etapa}")

  local item_id
  item_id=$(gh project item-add "$PROJ_NUM" --owner "$OWNER" --url "$url" --format json | jq -r '.id')

  gh project item-edit --id "$item_id" --project-id "$PROJ_ID" \
    --field-id "$ETAPA_FIELD" --single-select-option-id "${ETAPA_OPT[$etapa]}" >/dev/null

  gh project item-edit --id "$item_id" --project-id "$PROJ_ID" \
    --field-id "$SEMANA_FIELD" --single-select-option-id "${SEMANA_OPT[$semana]}" >/dev/null

  echo "  ✓ ${url}"
}

# ---------- E0 — pendentes (semana 1) ----------

create "[E0] Renomear pacote para datathon_offerexp no pyproject.toml" E0 1 \
"## Contexto
\`pyproject.toml\` atualmente tem \`name = \"7mlet\"\`, que é inválido como módulo Python (não pode começar com dígito) e diverge do README oficial do Datathon que usa \`datathon_offerexp\`.

## Definition of Done
- [ ] \`pyproject.toml\` com \`name = \"datathon_offerexp\"\`
- [ ] Configurar build system para layout \`src/\` (hatchling ou setuptools)
- [ ] \`uv sync\` roda sem erro
- [ ] \`uv run python -c 'import datathon_offerexp'\` funciona

## Referências
- Plano: seção E0 e Apêndice de Decisões de Tecnologia
- README oficial: \`ref_docs/README.md\`"

create "[E0] Criar esqueleto src/datathon_offerexp/ com módulos stub" E0 1 \
"## Contexto
Estrutura mínima de módulos exigida pelo README oficial. Stubs apenas com docstring + imports — implementações vêm nas etapas seguintes.

## Definition of Done
- [ ] \`src/datathon_offerexp/__init__.py\`
- [ ] \`src/datathon_offerexp/contracts.py\` — placeholder para pydantic models
- [ ] \`src/datathon_offerexp/policies.py\` — placeholder para BaselinePolicy e ThompsonSamplingPolicy
- [ ] \`src/datathon_offerexp/evaluation.py\` — placeholder para script de avaliação offline
- [ ] \`src/datathon_offerexp/decision_log.py\` — placeholder para log auditável
- [ ] \`src/datathon_offerexp/app.py\` — placeholder para FastAPI
- [ ] \`src/datathon_offerexp/data.py\` — placeholder para loader do JYB
- [ ] Cada arquivo importa limpo

## Bloqueia
- E3 (políticas), E5 (API)

## Referências
- Plano: seção E0"

create "[E0] Popular README.md raiz do repo" E0 1 \
"## Contexto
README na raiz está vazio. A banca avalia E0 olhando se uma pessoa externa consegue rodar o projeto sem ajuda oral.

## Definition of Done
- [ ] Visão do problema (1 parágrafo)
- [ ] Escopo e limitações
- [ ] Stack técnico (Python 3.13, uv, FastAPI, MLflow, Azure)
- [ ] Instruções de execução local (\`uv sync\`, \`uv run pytest\`, \`make demo\`)
- [ ] Mapa de pastas
- [ ] Link para \`ref_docs/README.md\` (spec oficial) e para o plano
- [ ] Link para o Project #2

## Referências
- Plano: seção E0"

create "[E0] Criar .env.example com placeholders de variáveis Azure" E0 1 \
"## Contexto
Listar variáveis de ambiente necessárias sem valores reais. Required pela banca.

## Definition of Done
- [ ] \`AZURE_OPENAI_ENDPOINT=\`
- [ ] \`AZURE_OPENAI_API_KEY=\`
- [ ] \`AZURE_SEARCH_ENDPOINT=\`
- [ ] \`AZURE_SEARCH_API_KEY=\`
- [ ] \`MLFLOW_TRACKING_URI=\`
- [ ] \`DECISION_LOG_PATH=\`
- [ ] Comentários explicando cada variável
- [ ] \`.env\` continua no \`.gitignore\` (já está)"

create "[E0] Criar Makefile com targets install/test/lint/demo" E0 1 \
"## Contexto
Comando único para reproduzir o pipeline ponta a ponta — exigência explícita da E5.

## Definition of Done
- [ ] \`make install\` → \`uv sync\`
- [ ] \`make test\` → \`uv run pytest\`
- [ ] \`make lint\` → \`uvx ruff check .\`
- [ ] \`make demo\` → stub inicial (sobe API + 5 requests); evolui na E5

## Bloqueia
- E5 (DoD da E5 depende de \`make demo\` funcionar)"

create "[E0] Adicionar licença ao repo" E0 1 \
"## Contexto
Banca exige licença declarada.

## Decisão pendente
- [ ] **Confirmar tipo de licença na 1ª reunião** — sugestão: MIT
- [ ] Criar arquivo \`LICENSE\` na raiz"

# ---------- E1 — Adryen (Data) ----------

create "[E1] Baixar Telemarketing JYB e popular data/kaggle/README.md" E1 1 \
"## Contexto
Base factual do projeto. Sem metadados rastreáveis (fonte, versão, licença), a banca penaliza.

## Definition of Done
- [ ] Dataset baixado em \`data/kaggle/selected-dataset.csv\` (ou nome equivalente)
- [ ] \`data/kaggle/README.md\` com:
  - link Kaggle
  - versão e data do download
  - fonte original (UCI)
  - licença
  - instruções de download (\`kaggle datasets download ...\`)
  - colunas com descrição breve
  - limitações conhecidas

## Referências
- https://www.kaggle.com/datasets/aguado/telemarketing-jyb-dataset"

create "[E1] EDA inicial + dicionário de dados" E1 1 \
"## Contexto
Entender a base antes de modelar. **Identificar candidatos a leakage temporal** (features que só existem após o contato).

## Definition of Done
- [ ] \`notebooks/01-eda-e-baseline.ipynb\` com:
  - shape, dtypes, % missing
  - distribuição do target
  - balanceamento de classes
  - correlações iniciais
  - **lista de features candidatas a leakage com justificativa**
- [ ] Dicionário de dados (em \`docs/data-dictionary.md\` ou no notebook)

## Critério de decisão de escopo
Se features de contexto < N (definir), abrir issue para trocar de base para Bank Marketing. Decisão até **sexta 30/05**.

## Bloqueia
- E1 modeling_table, E3 features de contexto"

create "[E1] modeling_table.parquet sem leakage + data.py loader" E1 2 \
"## Contexto
Tabela de modelagem versionada e código que registra fonte/versão/licença ao carregar.

## Definition of Done
- [ ] \`data/processed/modeling_table.parquet\` gerado a partir do JYB
- [ ] Colunas pós-decisão **removidas explicitamente**, com decisão documentada
- [ ] \`src/datathon_offerexp/data.py\` com função \`load_modeling_table()\` que:
  - retorna DataFrame
  - registra metadata (fonte, versão, licença) em log estruturado
- [ ] Teste \`tests/test_data.py\` valida shape esperado

## Depende de
- EDA + dicionário (#?)
- Esqueleto src/ (#?)"

# ---------- E2 — Matheus (Sintéticos) ----------

create "[E2] Schema dos eventos sintéticos em reports/data-generation.md" E2 1 \
"## Contexto
Camada sintética é o que torna o projeto um bandit. Schema **antes** do código pra evitar retrabalho.

## Definition of Done
- [ ] \`reports/data-generation.md\` com:
  - definição de braços (\`Arm\`) — ex.: \`sem_oferta\`, \`educacao_financeira\`, \`simulador_credito\`
  - canais (\`Channel\`) — ex.: \`app\`, \`web\`, \`email\`
  - segmentos (\`Segment\`) — ex.: \`novo\`, \`recorrente\`, \`reativado\`
  - schema de \`offer_catalog\`, \`offer_events\`, \`delayed_rewards\`
  - **modelo de delayed reward**: janela temporal, distribuição
  - hipóteses de negócio (qual braço favorece qual segmento, etc.)
  - seeds aleatórias usadas

## Bloqueia
- E2 código de geração, E3 replay offline, E4 golden set"

create "[E2] Implementar gerador de offer_catalog.sample.csv v0" E2 2 \
"## Contexto
Primeiro arquivo sintético — catálogo de braços × canais × horários.

## Definition of Done
- [ ] Código de geração em \`src/datathon_offerexp/synthetic.py\` (ou notebook em \`notebooks/\`)
- [ ] \`data/synthetic_enrichment/offer_catalog.sample.csv\` gerado
- [ ] Schema validado contra o documento em \`reports/data-generation.md\`
- [ ] Seeds documentadas

## Depende de
- Schema #?"

# ---------- E3 — Douglas (Bandit) ----------

create "[E3] Leitura Russo et al. + esboço docs/algorithmic-strategy.md" E3 1 \
"## Contexto
Fundação teórica do bandit. Banca exige referência explícita a Thompson Sampling e Nilos-UCB.

## Definition of Done
- [ ] Ler Russo et al. \"A Tutorial on Thompson Sampling\" (https://arxiv.org/abs/1707.02038)
- [ ] Survey UCB (ex.: Auer 2002 ou Lattimore & Szepesvári cap. 7)
- [ ] \`docs/algorithmic-strategy.md\` com:
  - resumo TS em 1 parágrafo (priors, update, exploração)
  - resumo UCB / Nilos-UCB em 1 parágrafo
  - justificativa de escolha
  - tratamento previsto de cold-start
  - tratamento previsto de delayed rewards

## Referências
- Plano: seção E3"

create "[E3] Implementar BaselinePolicy determinística" E3 2 \
"## Contexto
Política simples de controle. Sem ela, não há comparação quantitativa.

## Definition of Done
- [ ] \`BaselinePolicy\` em \`src/datathon_offerexp/policies.py\`
- [ ] Implementa contrato \`select_arm(event, scores, mode='baseline', ...)\` do README oficial
- [ ] Estratégia documentada (ex.: melhor braço histórico, regra fixa)
- [ ] Teste \`tests/test_policies.py::test_baseline\` cobre casos básicos

## Depende de
- Esqueleto src/ (#?)
- Schema sintético (#?)"

# ---------- E5 — Gabriel (Platform) ----------

create "[E5] API stub FastAPI /decide com contratos pydantic congelados" E5 2 \
"## Contexto
Forçar integração desde a semana 2 — \`make demo\` ponta a ponta na semana 3 depende disso.

## Definition of Done
- [ ] \`src/datathon_offerexp/app.py\` com endpoint \`POST /decide\`
- [ ] \`src/datathon_offerexp/contracts.py\` com pydantic:
  - \`DecisionRequest\` (event_id, subject_key, channel, segment, available_arms, context)
  - \`DecisionResponse\` (decision_id, selected_arm, reason_codes, policy_version)
  - \`DecisionLog\` (do README oficial)
- [ ] Tratamento de erro estruturado
- [ ] Suite mínima em \`tests/test_app.py\` valida happy path + erro

## Depende de
- Esqueleto src/ (#?)
- BaselinePolicy (#?) — ou stub temporário"

# ---------- Cross-cutting ----------

create "[E0] Onboarding: cada integrante clona, roda uv sync, abre 1 PR de teste" E0 1 \
"## Contexto
Validar que todos os 4 conseguem rodar o ambiente antes da semana 2.

## Definition of Done por integrante
- [ ] Aceitou convite na org DatathonG61
- [ ] Clonou o repo localmente
- [ ] Rodou \`uv sync\` sem erro
- [ ] Rodou \`uv run pytest\` (smoke passa)
- [ ] Abriu 1 PR contra \`main\` adicionando o próprio nome em \`docs/team.md\` (criar)
- [ ] PR teve CI verde e mergeado

## Quem
- [ ] Adryen Simões de Oliveira
- [ ] Douglas Bertelli Tineu
- [ ] Gabriel Caetano Guimarães de Mello
- [ ] Matheus Viana Florencio"

echo ""
echo "✓ Concluído."

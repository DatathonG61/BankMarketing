# BankMarketing — Guia para Claude Code

## Regra de ouro: nunca agir sem pedido explícito

Responder a uma pergunta (ex.: "o que falta fazer?", "como funciona isso?")
**não é autorização** para executar ações — em especial `git add`,
`git commit`, `git push`, criar branch ou abrir PR. Liste o que precisa ser
feito e pare. Só execute comandos de git (ou qualquer ação que mude estado:
arquivos, repositório, etc.) quando o integrante pedir isso explicitamente
("pode commitar", "cria a branch", "faz o commit"). Em caso de dúvida sobre
se algo foi pedido ou não, pergunte antes de agir.

## Visão Geral

Projeto final do curso 7-MLET (Fase 5 — MLOps), Datathon, grupo **G61**.
Tema: **Experimentação Adaptativa em Ofertas Financeiras** — uma plataforma
de **multi-armed bandits** end-to-end que decide, cliente a cliente, qual
oferta financeira apresentar (cartão de crédito, investimento, renegociação
ou nenhuma).

- **Repo:** https://github.com/DatathonG61/BankMarketing
- **Project board:** https://github.com/orgs/DatathonG61/projects/2
- **Prazo de entrega:** 20/07/2026
- **Plano canônico:** [`ref_docs/PLANO.md`](ref_docs/PLANO.md) — qualquer
  mudança de escopo/cronograma/divisão passa por PR nesse arquivo. Este
  CLAUDE.md é um resumo de orientação; em caso de divergência, o `PLANO.md`
  prevalece.
- **Detalhamento didático do desafio:** [`ref_docs/Detalhamento do Projeto.md`](ref_docs/Detalhamento do Projeto.md)

## Princípios do projeto

1. **Plataforma > experimento.** O alvo é um sistema que aprende sozinho
   decisão a decisão, não um notebook comparando modelos.
2. **Etapas acumulativas (E0 a E8).** Uma etapa posterior não compensa uma
   etapa anterior ausente.
3. **Integração contínua.** A partir da semana 3, `make demo` deve rodar
   ponta a ponta toda sexta, no estado em que o projeto estiver.

## Sobre a base de dados (decisão fechada)

- Base: **Bank Marketing** (Kaggle `henriqueyamahata/bank-marketing`,
  arquivo `bank-additional-full.csv`, derivada da UCI).
- **`duration` foi removida** — vazamento temporal (só é conhecida depois da
  ligação). Ver [`data/kaggle/README.md`](data/kaggle/README.md) e
  [`docs/data-dictionary.md`](docs/data-dictionary.md).
- **Esta variante da base NÃO tem coluna `balance` (saldo).** Onde o plano
  fala em "saldo", o projeto usa proxies de capacidade financeira: `default`
  (inadimplência), `job` (renda aproximada pela profissão), `housing`/`loan`
  (financiamentos em aberto). Ver `docs/data-dictionary.md`, seção
  "Observações".
- `pdays = 999` é sentinela ("nunca contatado antes") — tratado pela flag
  derivada `foi_contatado_antes` em `src/bankmarketing/data.py`.
- Valores ausentes em campos categóricos vêm como string `"unknown"`, não
  como `NaN`.

## Catálogo de ofertas (braços sintéticos)

Definido no `PLANO.md`, entregável de E2 (Gabriel):

| Código | Nome |
|---|---|
| `sem_oferta` | Controle (não ofertar) |
| `cartao_credito` | Oferta A — Cartão de Crédito |
| `investimento` | Oferta B — Investimento |
| `renegociacao` | Plano de renegociação (clientes com indício de inadimplência) |

Hipóteses de negócio a testar (ver `PLANO.md` e
`docs/golden-set-criteria.md` para o que é documentado vs. hipótese a
validar): jovens/baixa capacidade financeira → cartão de crédito;
idosos/profissão estável/alta renda → investimento; inadimplência
(`default=yes`) → renegociação, nunca crédito.

## Arquitetura / Stack

- **Python 3.13** via **uv** (`pyproject.toml`, `uv.lock`)
- Layout `src/bankmarketing/` (pacote `bankmarketing`)
- **FastAPI** (API de decisão, E5) · **MLflow** (tracking, E7) · **SQLite**
  (log de auditoria local, vira Cosmos DB em Azure) · **pydantic** (contratos)
- Lint/format: **ruff** · Testes: **pytest**
- CI: GitHub Actions (`.github/workflows/ci.yml`) — `uv run ruff check .` +
  `uv run pytest -q`

```
src/bankmarketing/
├── data.py            # carga/preparo da base (E1) — implementado
├── policies.py        # BaselinePolicy + ThompsonSamplingPolicy (E3)
├── decision_log.py     # log de auditoria (SQLite, E5)
├── evaluation.py       # métricas + runner do golden set (E4)
├── contracts.py        # contratos pydantic — vocabulário compartilhado (E5)
└── app.py               # API FastAPI /decide (E5)

data/
├── kaggle/              # base bruta + README de proveniência (E1)
├── processed/           # modeling_table.parquet sem duration (E1)
├── synthetic_enrichment/# offer_catalog, offer_events, delayed_rewards (E2)
└── golden_set/          # evaluation_cases.jsonl (E4)

docs/      # data-dictionary, golden-set-criteria, model-card, system-card,
           # lgpd-plan, architecture-azure (conforme as etapas avançam)
reports/   # relatórios técnicos e de avaliação (offline-evaluation,
           # fairness-review, data-generation, observability-plan, etc.)
infra/azure/  # IaC / diagramas da arquitetura-alvo (E6)
```

## Comandos

```bash
uv sync          # cria .venv e instala dependências (uv.lock)
uv run pytest    # roda os testes
uvx ruff check . # lint
make demo        # pipeline ponta a ponta (stub até E5)
```

## Atenção: importante para todos

- **Nunca** alterar dados/diretórios de outra etapa sem coordenar — cada
  etapa tem um responsável definido na divisão de tarefas (abaixo).
- O vocabulário de `context` (campos do cliente) e os códigos de oferta
  (`sem_oferta`, `cartao_credito`, `investimento`, `renegociacao`) precisam
  ser **consistentes** entre `data.py`/E2 (Gabriel), `policies.py` (Adryen),
  `contracts.py`/`app.py` (Matheus) e `evaluation.py`/golden set (Bertelli).
  Hoje (`contracts.py` vazio) esse contrato ainda não está formalizado — ver
  pendências em `docs/golden-set-criteria.md`.
- Não fazer chamadas reais a Azure/Azure OpenAI sem confirmar com o time —
  por enquanto, dev local usa Ollama como fallback (ver `PLANO.md`,
  apêndice de decisões de tecnologia).
- Branches curtas (`feat/<etapa>-<descrição>`), nunca > 5 dias; PR menciona a
  etapa (E0–E8); CI verde obrigatório; 2 aprovações; squash merge.

## Divisão por pessoas

Cada integrante pode pedir para o Claude ler este arquivo e o `PLANO.md`
para retomar o contexto. Resumo de papéis e etapas-foco:

### Gabriel Caetano Guimarães de Mello (mellogcg@gmail.com) — Eng. de Dados
- **E1** — Base Kaggle + EDA + remoção de `duration` (concluído, ver commits
  `f4e05b7`/`6f07017`).
- **E2** — Camada sintética em `data/synthetic_enrichment/`: `offer_catalog`,
  `offer_events`, `delayed_rewards`, `reports/data-generation.md`, seeds
  controladas.
- **Governança (E8):** `docs/lgpd-plan.md`.

### Adryen Simões de Oliveira (adryen.simoes@outlook.com) — Cientista de Dados
- **E3** — `BaselinePolicy` (regra fixa) e `ThompsonSamplingPolicy`
  (exploração bayesiana) em `src/bankmarketing/policies.py`; análise de
  Nilos-UCB; métricas de recompensa, regret, exploração e conversão;
  tratamento de cold-start.
- **Governança (E8):** co-autor de `docs/model-card.md` e
  `docs/system-card.md`.

### Douglas Bertelli Tineu (douglas.bertelli@outlook.com) — Eng. MLOps & Avaliação
- **E4** — Avaliação offline e Golden Set:
  - [`docs/golden-set-criteria.md`](docs/golden-set-criteria.md) — schema,
    catálogo de ofertas e critérios por categoria de caso.
  - [`data/golden_set/evaluation_cases.jsonl`](data/golden_set/evaluation_cases.jsonl) —
    20 casos (típicos/borda/adversariais), criado.
  - [`tests/test_golden_set.py`](tests/test_golden_set.py) — 10 testes que
    validam o schema/conteúdo do `evaluation_cases.jsonl` (não dependem de
    `policies.py`/`contracts.py`, que ainda estão vazios).
  - Próximos: `src/bankmarketing/evaluation.py` (CLI que roda os casos
    contra a política e calcula `adherence_rate`/`violation_rate`),
    `reports/offline-evaluation.md`, `reports/fairness-review.md`.
- **E7** — Ciclo de vida MLOps: MLflow tracking, critérios de
  promoção/rollback, `reports/retraining-approval-plan.md`,
  `reports/observability-plan.md`, approval gate humano.
- **Governança (E8):** co-autor de `docs/model-card.md` e
  `docs/system-card.md`.

### Matheus Viana Florencio (ma.viana2018@gmail.com) — Backend/Cloud & LLM
- **E5** — API FastAPI `/decide`, `contracts.py` (pydantic — vocabulário
  compartilhado), `decision_log.py` (SQLite), assistente LLM (resume/explica
  decisões e políticas), `make demo` ponta a ponta, testes.
- **E6** — `docs/architecture-azure.md` (Mermaid: Container Apps, Functions,
  API Management, App Insights, Cosmos DB, Data Lake Gen2, Azure OpenAI, AI
  Search, Key Vault, Managed Identity), `deployment-plan.md`.
- **Governança (E8):** FinOps (ROI/TCO/custo Azure).

## Estado atual (referência rápida)

- Concluído: **E0** (setup do repo/pacote) e **E1** (base + EDA, sem
  `duration`).
- Em andamento / pendente: **E2** (camada sintética — bloqueia E3 e parte de
  E4/E5), **E3**, **E4** (golden set já iniciado), **E5**, **E6**, **E7**,
  **E8**.
- Para o estado semana-a-semana atualizado, ver o backlog e o cronograma em
  `ref_docs/PLANO.md`.

## Como atualizar este arquivo

Mudanças estruturais (papéis, stack, layout, decisões fechadas) devem ser
refletidas aqui via PR, assim como no `ref_docs/PLANO.md`. Itens de
progresso semanal (o que já foi feito) não precisam ser replicados aqui em
detalhe — usar o backlog do `PLANO.md` e o Project board como fonte de
verdade para status.

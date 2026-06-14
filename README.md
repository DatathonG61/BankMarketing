# BankMarketing — Experimentação Adaptativa de Ofertas Financeiras

> Datathon 7-MLET (Fase 5 — MLOps) · Grupo **G61** · Prazo: 20/07/2026

## Visão do problema

Plataforma de **experimentação adaptativa (multi-armed bandits)** end-to-end que decide,
cliente a cliente, **qual oferta financeira apresentar** (cartão de crédito, investimento,
renegociação ou nenhuma). A base [Bank Marketing](data/kaggle/README.md) (UCI, via Kaggle)
fornece a camada factual de propensão (`y` = assinou depósito a prazo); sobre ela
construímos uma camada sintética de braços de oferta, eventos e *delayed rewards*, uma
política adaptativa (Thompson Sampling, com análise comparativa de UCB) contra um baseline
determinístico, e uma API auditável de decisão. O foco é um **sistema que aprende sozinho**
— não um relatório comparativo de modelos.

## Escopo e limitações

**No escopo:** ingestão e EDA da base; remoção de leakage temporal; geração da camada
sintética de ofertas/recompensas; baseline + bandit com métricas (recompensa, regret,
exploração, conversão); API de decisão com log de auditoria + assistente LLM; golden set e
fairness; ciclo MLOps (MLflow, retreino, approval gate, rollback); arquitetura-alvo Azure;
governança (Model Card, System Card, LGPD) e FinOps.

**Fora do escopo / limitações:** os braços de oferta e as recompensas são **sintéticos**
(a base não contém ofertas reais); o sinal factual é de um único banco português, período
2008–2010 (viés temporal de crise). A coluna **`duration` é descartada** por vazamento
temporal — ver [`data/kaggle/README.md`](data/kaggle/README.md). Deploy Azure é **target
arquitetural documentado**, não necessariamente provisionado.

## Stack técnico

- **Python 3.13** + [**uv**](https://docs.astral.sh/uv/) (gerência de ambiente e deps)
- **FastAPI** — API de decisão auditável
- **MLflow** — tracking de experimentos, registro de modelo e ciclo de retreino
- **Azure** — arquitetura-alvo de deploy (Key Vault, etc.)
- pandas · pytest · ruff (CI via GitHub Actions)

## Execução local

Requer [uv](https://docs.astral.sh/uv/getting-started/installation/) instalado.

```bash
# 1. Sincronizar o ambiente (cria .venv e instala deps a partir do uv.lock)
uv sync

# 2. Rodar os testes
uv run pytest

# 3. Rodar o sistema ponta a ponta (integração contínua — alvo: toda sexta)
make demo
```

Para baixar a base de dados, ver instruções em [`data/kaggle/README.md`](data/kaggle/README.md).

## Mapa de pastas

```
.
├── src/bankmarketing/        # Pacote Python principal
│   ├── data.py               #   carga/preparo da base
│   ├── policies.py           #   baseline + bandit (Thompson/UCB)
│   ├── decision_log.py       #   log de auditoria das decisões
│   ├── evaluation.py         #   métricas (recompensa, regret, conversão)
│   ├── contracts.py          #   contratos/esquemas de dados
│   └── app.py                #   API FastAPI de decisão
├── data/
│   ├── kaggle/               # Base factual bruta (Bank Marketing) + README
│   ├── synthetic_enrichment/ # Camada sintética: ofertas, eventos, rewards
│   ├── processed/            # Dados tratados/derivados
│   └── golden_set/           # Casos de avaliação (golden set)
├── notebooks/                # EDA e exploração
├── tests/                    # Testes
├── infra/azure/              # IaC / arquitetura Azure
├── scripts/                  # Automação (ex.: bootstrap de issues)
├── docs/                     # Documentação (model card, system card, arquitetura)
├── reports/                  # Relatório técnico e artefatos do pitch
└── ref_docs/                 # Plano de execução e material de referência
```

## Documentação e gestão

- **Plano de execução (canônico):** [`ref_docs/PLANO.md`](ref_docs/PLANO.md)
- **Board do projeto (GitHub Project #2):** https://github.com/orgs/DatathonG61/projects/2
- **Dicionário de dados da base:** [`data/kaggle/README.md`](data/kaggle/README.md)

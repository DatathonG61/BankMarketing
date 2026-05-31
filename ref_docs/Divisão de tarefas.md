
## Integrante 1: Engenheiro(a) de Dados (Foco nas Etapas 1 e 2)
**O que faz:**  Cuida de toda a preparação da base de dados.
**Responsável**: Gabriel Mello
**Tarefas:** Baixar a base do Kaggle, fazer a Análise Exploratória (EDA), criar o dicionário de dados e remover colunas que causam vazamento temporal.

Além disso, será responsável por criar a camada sintética (data/synthetic_enrichment/), gerando o catálogo de ofertas, os eventos e as simulações de recompensas atrasadas (delayed rewards) com sementes controladas.


## Integrante 2: Cientista de Dados (Foco exclusivo na Etapa 3)
O que faz: Foca 100% na matemática e na lógica de decisão.
**Responsável:** Adryen
**Tarefas**: Implementar o modelo Baseline (regra fixa) e o algoritmo de exploração bayesiana (Thompson Sampling ou Nilos-UCB)
 - Calcular as métricas exigidas de recompensa, regret (arrependimento), exploração e conversão
 - Ele só precisa garantir que o algoritmo funciona e gera as métricas comparativas

## Integrante 3: Engenheiro(a) de MLOps e Avaliação (Foco nas Etapas 4 e 7)

**O que faz:** Pega o modelo que o Integrante 2 criou e coloca à prova, além de criar a "esteira" do projeto.
**Responsável:** Bertelli
**Tarefas:** Construir o Golden Set (evaluation_cases.jsonl) com no mínimo 20 casos de testes variados (típicos, borda e adversariais) e gerar a matriz de métricas e análise de fairness (justiça). Também configura o MLflow para rastrear os experimentos e cria o plano documentado de retreino, aprovação humana e rollback de novas políticas (Etapa 7)

## Integrante 4: Backend / Cloud (Foco nas Etapas 5 e 6)

**O que faz:** Constrói a "cara" do projeto, a integração com IA e a nuvem.
**Responsável:** Matheus
**Tarefas:** Criar a API, aplicativo ou notebook executável que recebe o contexto do cliente e devolve a decisão com um log de auditoria. É este integrante que vai criar o assistente LLM exigido no edital (para resumir experimentos e explicar decisões). Também é o responsável por desenhar a arquitetura no Azure (docs/architecture-azure.md) e o plano de gestão de segredos no Key Vault.

**Todos Juntos:** Governança e Negócios (Etapas 0 e 8) A etapa de governança é muito pesada para uma pessoa só, pois exige documentos específicos. Vocês devem dividi-los assim:
Integrante 2 e 3 preenchem o model-card.md (limitações do modelo e dados de treino) e o system-card.md (riscos, guardrails e fluxo de decisão).

- Integrante 1 escreve o plano de adequação à LGPD (lgpd-plan.md).
- Integrante 4 levanta os custos de nuvem (FinOps, ROI, TCO no Azure).
- Juntos, configuram o repositório inicial no GitHub (Etapa 0), consolidam o Relatório Técnico de 10 páginas e montam os slides do Pitch.

Dessa forma, o Integrante 2 foca apenas no algoritmo principal e não precisará se preocupar em criar Golden Set, testar IA Generativa (LLM) ou fazer o deploy da aplicação!
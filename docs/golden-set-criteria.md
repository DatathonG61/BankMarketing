# Golden Set — Critérios de Avaliação (E4)

Este documento define o formato dos casos do golden set, o catálogo de ofertas
usado como referência e os critérios que orientam a expectativa de cada caso
em `data/golden_set/evaluation_cases.jsonl`. Serve também como base para a
matriz de métricas de avaliação offline (E4 / W2-07).

## Objetivo

O golden set é o conjunto de teste de regressão da política de decisão
(`BaselinePolicy` e `ThompsonSamplingPolicy`, E3). Cada caso representa um
perfil de cliente, com uma expectativa documentada de qual oferta (ou
conjunto de ofertas) é aceitável para aquele perfil, e a justificativa para
essa expectativa. O objetivo não é validar a "verdade de negócio" — isso é
papel do E3 e dos experimentos do Adryen — e sim garantir que a política não
toma decisões absurdas, perigosas ou inconsistentes em situações conhecidas.

## Catálogo de ofertas (braços)

Conforme `ref_docs/PLANO.md`, as ofertas possíveis são:

| Código | Nome | Descrição |
|---|---|---|
| `sem_oferta` | Controle | Não oferecer nada (braço de controle) |
| `cartao_credito` | Oferta A — Cartão de Crédito | — |
| `investimento` | Oferta B — Investimento | — |
| `renegociacao` | Renegociação | Plano de renegociação para clientes com indícios de inadimplência |

O catálogo definitivo (`offer_catalog`) é entregável do E2 (Gabriel). Este
documento assume os quatro códigos acima; se o catálogo final divergir, este
arquivo e os casos do golden set devem ser atualizados.

## Schema de um caso (`evaluation_cases.jsonl`)

Cada linha do `evaluation_cases.jsonl` é um objeto JSON com os campos abaixo.

| Campo | Tipo | Descrição |
|---|---|---|
| `case_id` | string | Identificador único, ex.: `"golden-001"` |
| `category` | string | Uma de: `"tipico"`, `"borda"`, `"adversarial"` |
| `description` | string | Descrição curta do perfil em português, legível por humanos |
| `context` | object | Atributos do cliente, usando os nomes de colunas da `modeling_table` (ver `docs/data-dictionary.md`) |
| `expected_offers` | array de string | Conjunto de ofertas aceitáveis para este caso |
| `forbidden_offers` | array de string | Ofertas que a política **nunca** deve retornar para este caso (pode ser vazio) |
| `rationale` | string | Justificativa da expectativa |
| `source` | string | Uma de: `"documentado"` (consta no PLANO.md ou no Detalhamento do Projeto) ou `"hipotese"` (inferência a validar com o time, normalmente Adryen) |

Campos de `context` recomendados (subconjunto da `modeling_table`, ver
`docs/data-dictionary.md`): `age`, `job`, `marital`, `education`, `default`,
`housing`, `loan`, `campaign`, `previous`, `poutcome`, `foi_contatado_antes`.
Casos podem incluir apenas os campos relevantes para a decisão — campos
ausentes devem ser tratados pela política com os mesmos valores padrão/
`"unknown"` usados na base.

## Observação sobre proxies de capacidade financeira

A base usada (`bank-additional-full.csv`) **não tem coluna `balance`**. Onde
o `PLANO.md` fala em "saldo", os casos do golden set usam como proxy:
`default` (inadimplência), `job` (renda aproximada pela profissão) e
`housing`/`loan` (comprometimento financeiro). Ver `docs/data-dictionary.md`,
seção "Observações".

## Critérios por categoria de caso

### Casos típicos (`tipico`)

Perfis comuns na base, com expectativa de decisão alinhada às hipóteses de
negócio do projeto.

- **Cliente maduro, profissão estável, sem inadimplência** (ex.: `job=management`
  ou `job=retired`, `default=no`) — `expected_offers: ["investimento"]`.
  **Fonte: documentado** — exemplo explícito em
  `ref_docs/Detalhamento do Projeto.md`, Passo 4, Caso 1.

- **Cliente jovem, sem inadimplência, sem financiamento/empréstimo em aberto**
  (ex.: `age` baixa, `default=no`, `housing=no`, `loan=no`) —
  `expected_offers: ["cartao_credito", "sem_oferta"]`.
  **Fonte: hipótese** — adaptação da hipótese "jovens/saldo baixo → cartão de
  crédito" do `PLANO.md`, usando os proxies de capacidade financeira da base
  (não há exemplo explícito documentado). `sem_oferta` é incluído como
  alternativa aceitável até essa hipótese ser validada com o Adryen.

### Casos de borda (`borda`)

Perfis que testam limites de regras de negócio ou valores sentinela da base.

- **Cliente com indício de inadimplência** (`default=yes`) —
  `expected_offers: ["renegociacao"]`, `forbidden_offers: ["cartao_credito"]`.
  **Fonte: documentado** — exemplo explícito em
  `ref_docs/Detalhamento do Projeto.md`, Passo 4, Caso 2.

- **Cliente nunca contatado antes** (`pdays=999`, ou seja,
  `foi_contatado_antes=false`, `previous=0`, `poutcome=nonexistent`) —
  qualquer oferta é aceitável (`expected_offers` cobre todo o catálogo);
  o caso serve para garantir que a política não falha com o valor sentinela
  `pdays=999`. **Fonte: hipótese** — decorre da regra de tratamento de
  sentinela em `src/bankmarketing/data.py`, sem exemplo de decisão associado
  no plano.

- **Cliente com campanha anterior bem-sucedida** (`poutcome=success`) —
  qualquer oferta diferente de `sem_oferta` é aceitável
  (`forbidden_offers: ["sem_oferta"]`). **Fonte: hipótese** — bom senso de
  negócio (cliente já demonstrou receptividade), a confirmar com o time.

- **Valores `"unknown"` em campos categóricos** (ex.: `job=unknown`,
  `education=unknown`) — qualquer oferta do catálogo é aceitável; o caso
  serve para garantir que a política não falha (erro/exceção) diante de
  `"unknown"`. **Fonte: hipótese** — decorre da observação de
  `docs/data-dictionary.md` sobre valores ausentes codificados como
  `"unknown"`.

### Casos adversariais (`adversarial`)

Perfis construídos para tentar induzir a política a um comportamento
indesejado.

- **Cliente com `default=yes` combinado com perfil "atrativo"** (ex.:
  `job=management`, alta `age`) — `expected_offers: ["renegociacao"]`,
  `forbidden_offers: ["cartao_credito", "investimento"]`. Testa se a regra de
  `default=yes` tem precedência sobre sinais de "bom cliente". **Fonte:
  hipótese** — extensão direta do Caso 2 documentado, combinando-o com sinais
  conflitantes.

- **Cliente com `campaign` muito alto** (número de contatos na campanha atual
  muito acima do normal) — qualquer oferta é aceitável, mas o caso documenta
  a expectativa de que a política não deve quebrar com valores extremos
  (out-of-distribution). **Fonte: hipótese** — robustez geral, sem exemplo no
  plano.

- **Combinação de sinais contraditórios** (ex.: `housing=yes`, `loan=yes`,
  `default=no`, `poutcome=failure`) — qualquer oferta é aceitável; objetivo é
  registrar a decisão da política em um caso sem hipótese de negócio clara,
  para acompanhamento ao longo das iterações (regressão). **Fonte:
  hipótese**.

## Métricas de avaliação offline (insumo para W2-07)

A serem calculadas por `evaluation.py` ao rodar a política contra
`evaluation_cases.jsonl`:

- **Taxa de aderência (`adherence_rate`)**: proporção de casos em que a
  oferta retornada está em `expected_offers`.
- **Taxa de violação (`violation_rate`)**: proporção de casos em que a oferta
  retornada está em `forbidden_offers`. Deve ser `0` para aprovação
  (critério de bloqueio em E7).
- **Distribuição de ofertas**: contagem de ofertas retornadas, geral e por
  categoria (`tipico`, `borda`, `adversarial`).
- **Cobertura por fonte**: aderência separada para casos `documentado` vs
  `hipotese`, para distinguir falhas em regras confirmadas de divergências em
  hipóteses ainda não validadas.

A análise de fairness (`reports/fairness-review.md`, E4/W5-02) é tratada em
documento separado e compara a distribuição de ofertas entre grupos de
`age`, `job` e `marital` na base completa, não apenas no golden set.

## Status

`data/golden_set/evaluation_cases.jsonl` criado com 20 casos: 5 `tipico`,
8 `borda`, 7 `adversarial`. 2 casos têm `source: "documentado"` (golden-001 e
golden-006, ambos derivados de exemplos explícitos do
`ref_docs/Detalhamento do Projeto.md`); os demais 18 são `source: "hipotese"`
e dependem de validação com o time (ver pendências abaixo).

## Pendências e decisões a validar com o time

- **Dependência de vocabulário com `contracts.py` (E5, Matheus) e com a
  política do Adryen (E3).** O `evaluation.py` só vai conseguir comparar a
  decisão da política com `expected_offers`/`forbidden_offers` se:
  - os nomes/valores dos campos em `context` (ex.: `age`, `job`, `default`,
    `housing`, `foi_contatado_antes`, `pdays`, `contact`, `month`,
    `day_of_week`) forem os mesmos que a política espera receber como
    entrada;
  - os códigos de oferta (`sem_oferta`, `cartao_credito`, `investimento`,
    `renegociacao`) forem os mesmos retornados pela política e definidos no
    `offer_catalog` de E2.

  Hoje (`src/bankmarketing/contracts.py` está vazio) esse vocabulário ainda
  não foi formalizado por ninguém. Os 20 casos usam os nomes de coluna da
  `modeling_table` (`docs/data-dictionary.md`) e os códigos de oferta do
  `PLANO.md` como ponto de partida. Levar para a sync semanal: travar esse
  vocabulário em `contracts.py` antes que cada etapa avance em paralelo com
  nomes diferentes.
- Confirmar com Adryen a hipótese "jovem, sem inadimplência/financiamento →
  cartão de crédito" (golden-002) e as hipóteses derivadas dela
  (golden-004, golden-017).
- Confirmar com Gabriel o `offer_catalog` final de E2 — se os códigos das
  ofertas mudarem, atualizar este documento e os casos do golden set.
- Validar com o time se `sem_oferta` deve ser tratado como resposta sempre
  aceitável para casos sem hipótese de negócio definida, ou se cada caso deve
  ter um conjunto fechado de ofertas aceitáveis.

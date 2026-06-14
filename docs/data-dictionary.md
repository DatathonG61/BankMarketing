# Dicionário de Dados — Bank Marketing

Derivado de [`data/kaggle/bank-adittional-names.txt`](../data/kaggle/bank-adittional-names.txt)
(arquivo `bank-additional-full.csv`). Base UCI *Bank Marketing* com contexto social/econômico,
criada por S. Moro, P. Cortez e P. Rita (2014).

- **Instâncias:** 41.188 (`bank-additional-full.csv`)
- **Atributos:** 20 de entrada + 1 alvo (`y`)
- **Separador:** `;` · campos textuais entre aspas
- **Período:** maio/2008 a novembro/2010, ordenado por data
- **Ausentes:** **não há `NaN`** — valores faltantes vêm codificados como a string `"unknown"`
  em atributos categóricos (ver coluna *Observações*)

## Dados do cliente

| # | Coluna | Tipo | Descrição | Valores |
|---|--------|------|-----------|---------|
| 1 | `age` | numérico | Idade do cliente | — |
| 2 | `job` | categórico | Tipo de emprego | `admin.`, `blue-collar`, `entrepreneur`, `housemaid`, `management`, `retired`, `self-employed`, `services`, `student`, `technician`, `unemployed`, `unknown` |
| 3 | `marital` | categórico | Estado civil (`divorced` = divorciado ou viúvo) | `divorced`, `married`, `single`, `unknown` |
| 4 | `education` | categórico | Escolaridade | `basic.4y`, `basic.6y`, `basic.9y`, `high.school`, `illiterate`, `professional.course`, `university.degree`, `unknown` |
| 5 | `default` | categórico | Possui crédito em inadimplência? | `no`, `yes`, `unknown` |
| 6 | `housing` | categórico | Possui financiamento imobiliário? | `no`, `yes`, `unknown` |
| 7 | `loan` | categórico | Possui empréstimo pessoal? | `no`, `yes`, `unknown` |

## Último contato da campanha atual

| # | Coluna | Tipo | Descrição | Valores |
|---|--------|------|-----------|---------|
| 8 | `contact` | categórico | Meio de contato | `cellular`, `telephone` |
| 9 | `month` | categórico | Mês do último contato | `jan` … `dec` |
| 10 | `day_of_week` | categórico | Dia da semana do último contato | `mon` … `fri` |
| 11 | `duration` | numérico | Duração do último contato, em segundos | — |

> ⚠️ **`duration` — leakage temporal.** Citação dos autores: *"this attribute highly affects
> the output target (e.g., if duration=0 then y='no'). Yet, the duration is not known before a
> call is performed. (...) this input should only be included for benchmark purposes and should
> be discarded if the intention is to have a realistic predictive model."* **Remover antes de
> modelar.**

## Outros atributos da campanha

| # | Coluna | Tipo | Descrição | Valores |
|---|--------|------|-----------|---------|
| 12 | `campaign` | numérico | Nº de contatos nesta campanha para este cliente (inclui o último) | — |
| 13 | `pdays` | numérico | Dias desde o último contato em campanha anterior | `999` = nunca contatado antes |
| 14 | `previous` | numérico | Nº de contatos antes desta campanha para este cliente | — |
| 15 | `poutcome` | categórico | Resultado da campanha anterior | `failure`, `nonexistent`, `success` |

## Contexto social e econômico

Indicadores nacionais (país de ~10M hab.), publicados pelo Banco de Portugal.

| # | Coluna | Tipo | Descrição | Periodicidade |
|---|--------|------|-----------|---------------|
| 16 | `emp.var.rate` | numérico | Taxa de variação do emprego | trimestral |
| 17 | `cons.price.idx` | numérico | Índice de preços ao consumidor | mensal |
| 18 | `cons.conf.idx` | numérico | Índice de confiança do consumidor | mensal |
| 19 | `euribor3m` | numérico | Taxa Euribor 3 meses | diária |
| 20 | `nr.employed` | numérico | Número de empregados | trimestral |

## Alvo

| # | Coluna | Tipo | Descrição | Valores |
|---|--------|------|-----------|---------|
| 21 | `y` | binário | O cliente subscreveu um depósito a prazo? | `yes`, `no` |

## Observações

- **Ausentes como `"unknown"`:** presentes em `job`, `marital`, `education`, `default`,
  `housing`, `loan`. Tratar como classe própria, ou via deleção/imputação — não aparecem
  como `NaN` num `isna()` ingênuo.
- **`pdays = 999`** é código sentinela ("nunca contatado"), não um valor numérico real.
- **`balance` (saldo) não existe** nesta variante (`bank-additional`). O `bank-full.csv`
  clássico do UCI tem saldo, mas não está no dataset indicado e não é casável com este
  (~0,1% de match, sem chave de cliente). Onde o brief fala em "saldo", o projeto usa
  proxies de capacidade financeira: `default` (inadimplência), `job` (renda), `loan`/`housing`.

## Citação

> S. Moro, P. Cortez and P. Rita. *A Data-Driven Approach to Predict the Success of Bank
> Telemarketing.* Decision Support Systems, Elsevier, 62:22-31, 2014.
> doi:10.1016/j.dss.2014.03.001

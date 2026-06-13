# Dataset — Bank Marketing

Base factual do projeto. Este diretório contém o dataset bruto usado como ponto de
partida para EDA, treino e avaliação. **Não editar os arquivos `.csv` manualmente** —
qualquer transformação deve ser reproduzível por código.

## Fonte

| Item | Valor |
|------|-------|
| Kaggle | https://www.kaggle.com/datasets/henriqueyamahata/bank-marketing |
| Fonte original | UCI Machine Learning Repository — *Bank Marketing* (http://archive.ics.uci.edu/ml/datasets/Bank+Marketing) |
| Autores | S. Moro, P. Cortez e P. Rita (ISCTE-IUL / Univ. Minho), 2014 |
| Arquivo usado | `bank-additional-full.csv` |
| Registros | 41.188 linhas (+ 1 cabeçalho) |
| Atributos | 20 features + 1 alvo (`y`) |
| Separador | `;` (ponto e vírgula), com aspas em campos textuais |
| Período coberto | maio/2008 a novembro/2010, ordenado por data |
| Versão / data do download | `bank-additional-full` (versão "with social/economic context") — baixado em **2026-06-13** |
| Licença | Uso público para pesquisa (CC BY 4.0 na página do Kaggle). Citação obrigatória — ver seção *Citação* |

## Como baixar

Requer a [CLI do Kaggle](https://github.com/Kaggle/kaggle-api) autenticada
(`~/.kaggle/kaggle.json` com seu token de API):

```bash
kaggle datasets download henriqueyamahata/bank-marketing -p data/kaggle --unzip
```

O pacote inclui dois arquivos:

- `bank-additional-full.csv` — todos os exemplos (41.188), ordenados por data. **← usado neste projeto.**
- `bank-additional.csv` — 10% dos exemplos (4.119), amostra aleatória para testar
  algoritmos mais custosos (ex.: SVM).

## Colunas

### Dados do cliente
| # | Coluna | Tipo | Descrição |
|---|--------|------|-----------|
| 1 | `age` | numérico | Idade do cliente |
| 2 | `job` | categórico | Tipo de emprego (`admin.`, `blue-collar`, `entrepreneur`, `housemaid`, `management`, `retired`, `self-employed`, `services`, `student`, `technician`, `unemployed`, `unknown`) |
| 3 | `marital` | categórico | Estado civil (`divorced` = divorciado/viúvo, `married`, `single`, `unknown`) |
| 4 | `education` | categórico | Escolaridade (`basic.4y`, `basic.6y`, `basic.9y`, `high.school`, `illiterate`, `professional.course`, `university.degree`, `unknown`) |
| 5 | `default` | categórico | Possui crédito em inadimplência? (`no`, `yes`, `unknown`) |
| 6 | `housing` | categórico | Possui financiamento imobiliário? (`no`, `yes`, `unknown`) |
| 7 | `loan` | categórico | Possui empréstimo pessoal? (`no`, `yes`, `unknown`) |

### Último contato da campanha atual
| # | Coluna | Tipo | Descrição |
|---|--------|------|-----------|
| 8 | `contact` | categórico | Meio de contato (`cellular`, `telephone`) |
| 9 | `month` | categórico | Mês do último contato (`jan` … `dec`) |
| 10 | `day_of_week` | categórico | Dia da semana do último contato (`mon` … `fri`) |
| 11 | `duration` | numérico | **⚠️ Duração do último contato em segundos — LEAKAGE TEMPORAL, ver abaixo** |

### Outros atributos da campanha
| # | Coluna | Tipo | Descrição |
|---|--------|------|-----------|
| 12 | `campaign` | numérico | Nº de contatos nesta campanha para este cliente (inclui o último) |
| 13 | `pdays` | numérico | Dias desde o último contato em campanha anterior (`999` = nunca contatado antes) |
| 14 | `previous` | numérico | Nº de contatos antes desta campanha para este cliente |
| 15 | `poutcome` | categórico | Resultado da campanha anterior (`failure`, `nonexistent`, `success`) |

### Contexto social e econômico (indicadores nacionais, Banco de Portugal)
| # | Coluna | Tipo | Descrição |
|---|--------|------|-----------|
| 16 | `emp.var.rate` | numérico | Taxa de variação do emprego — indicador trimestral |
| 17 | `cons.price.idx` | numérico | Índice de preços ao consumidor — indicador mensal |
| 18 | `cons.conf.idx` | numérico | Índice de confiança do consumidor — indicador mensal |
| 19 | `euribor3m` | numérico | Taxa Euribor 3 meses — indicador diário |
| 20 | `nr.employed` | numérico | Número de empregados — indicador trimestral |

### Alvo
| # | Coluna | Tipo | Descrição |
|---|--------|------|-----------|
| 21 | `y` | binário | O cliente subscreveu um depósito a prazo? (`yes` / `no`) |

## ⚠️ `duration` — leakage temporal (remover)

A coluna `duration` (duração da ligação em segundos) **deve ser removida** antes de
treinar qualquer modelo destinado a uso real:

- A duração só é conhecida **depois** que a ligação termina; nesse ponto o desfecho
  (`y`) já é conhecido na prática.
- A correlação com o alvo é altíssima (ex.: `duration = 0` ⇒ `y = "no"`), inflando
  artificialmente as métricas.
- Conforme os próprios autores: *"this input should only be included for benchmark
  purposes and should be discarded if the intention is to have a realistic predictive
  model."*

Mantemos a coluna no arquivo bruto por fidelidade à fonte, mas o pipeline de features
**descarta `duration`**.

## Limitações conhecidas

- **Valores ausentes** codificados como `"unknown"` em várias colunas categóricas
  (`job`, `marital`, `education`, `default`, `housing`, `loan`). Tratar como classe
  própria ou via deleção/imputação — não há `NaN` explícito.
- **Forte desbalanceamento de classes**: ~11% de `y = "yes"`. Exige métricas
  apropriadas (PR-AUC, F1, recall) e/ou reamostragem.
- **`pdays = 999`** é um código sentinela ("nunca contatado"), não um valor numérico
  real — tratar separadamente.
- **Viés temporal**: dados de 2008–2010, em plena crise financeira; os indicadores
  macroeconômicos (`euribor3m`, `emp.var.rate`, etc.) refletem esse período e podem
  não generalizar para outros contextos.
- **Privacidade**: a versão pública não inclui todos os atributos do estudo original
  de Moro et al. (2014).
- Dataset de um único banco português — generalização geográfica limitada.

## Citação

> [Moro et al., 2014] S. Moro, P. Cortez and P. Rita. *A Data-Driven Approach to
> Predict the Success of Bank Telemarketing.* Decision Support Systems, Elsevier,
> 62:22-31, June 2014. doi:10.1016/j.dss.2014.03.001

- PDF: http://dx.doi.org/10.1016/j.dss.2014.03.001
- BibTeX: http://www3.dsi.uminho.pt/pcortez/bib/2014-dss.txt

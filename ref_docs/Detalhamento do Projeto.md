## Passo 1: Etapa 0

Antes de escrever qualquer código, vocês precisam criar o repositório onde o projeto vai morar.

**O que fazer:** Crie um repositório público no GitHub com o nome datathon-7mlet-grupo-XX (substitua XX pelo número do seu grupo)

**Exemplo prático:** Dentro dele, crie um arquivo README.md (que vai explicar como rodar o projeto) e um pyproject.toml (para listar as bibliotecas que vocês vão usar, como pandas, mlflow, etc.). Nada de subir senhas ou dados reais aqui.

## **Passo** 2: A Base de Dados (Etapas 1 e 2)
Vocês não vão usar dados do banco real da faculdade. Vocês vão pegar dados públicos e injetar uma camada sintética (falsa) por cima

**O que fazer:** Baixe a base bank-marketing (henriqueyamahata) do Kaggle (ela tem dados sobre campanhas de banco).

**Exemplo prático:**
Os dados originais: Terão colunas como idade, profissão, saldo_bancario. Você deve deletar a coluna duration, pois ela causa vazamento temporal (é uma informação do futuro prevendo o passado). Salve isso na pasta data/processed/

Os dados sintéticos (falsos): Você vai criar uma pasta data/synthetic_enrichment/ e criar arquivos simulando o problema
Exemplo: crie um offer_catalog (Catálogo de Ofertas) com as opções: Oferta A (Cartão de Crédito) e Oferta B (Investimento)
Crie também um registro de cliques simulando se o cliente clicou ou ignorou a oferta

## Passo 3: O Cérebro da Decisão (Etapa 3)
Aqui entra o algoritmo. Em vez de testar A/B esperando meses, o modelo deve aprender sozinho.
**O que fazer:** Criar dois modelos para comparar

**Exemplo prático:**
Baseline (Regra burra): Um código simples de if/else que diz: "Sempre ofereça o Cartão de Crédito para todos, porque é o produto mais popular".

Modelo Inteligente (Thompson Sampling ou Nilos-UCB): Um algoritmo de recomendação que entende o contexto. Ele tenta a Oferta A, vê se o cliente clicou, tenta a Oferta B, e rapidamente aprende que "jovens preferem cartão de crédito" e "idosos preferem investimento", adaptando a decisão em tempo real.

Passo 4: A Prova de Fogo - Golden Set (Etapa 4)
A banca quer ter certeza de que seu modelo não vai fazer loucuras em produção.
O que fazer: Criar um arquivo chamado evaluation_cases.jsonl dentro da pasta data/golden_set/ com no mínimo 20 clientes inventados para testar o modelo.

Exemplo prático:
Caso 1 (Típico): Cliente com R$ 50.000 de saldo. Ação esperada do modelo: Oferecer Investimento.
Caso 2 (Extremo/Borda): Cliente com conta negativada. Ação esperada do modelo: Não oferecer crédito, oferecer um plano de renegociação.

Você vai rodar seu modelo nesses 20 casos para provar que ele passa no teste
.
Passo 5: O Produto Físico / A Tela (Etapa 5)
Como um aplicativo de celular falaria com o seu modelo?
O que fazer: Criar uma API, um aplicativo simples ou um Notebook interativo
.
Exemplo prático: O usuário digita o perfil do cliente na tela. O sistema roda o algoritmo e devolve: "Recomendação: Oferta B. Motivo: O cliente tem alto saldo bancário. Versão do modelo: v1.0". O sistema deve registrar um "log de auditoria" (um histórico) dizendo o que decidiu e por que decidiu
.
O Diferencial: Vocês devem incluir um assistente virtual baseado em IA generativa (LLM) que consiga ler as decisões e resumi-las ou explicar as políticas internas do banco
.
Passo 6: A Nuvem e a Organização - Azure e MLOps (Etapas 6 e 7)
A banca quer saber se vocês sabem colocar isso na internet de forma profissional.
O que fazer: Desenhar a arquitetura e usar ferramentas de monitoramento
.
Exemplo prático:
Nuvem: Você vai fazer um desenho (diagrama) mostrando que os dados ficariam guardados no Azure, e que as senhas estariam protegidas no Azure Key Vault
. Não precisa construir toda a nuvem na vida real, mas o desenho deve ser feito com foco no Azure
.
MLOps: O código deve usar o MLflow para salvar o histórico de treinamento
. Além disso, você deve escrever uma regra: "Se fizermos um modelo novo no futuro, ele só vai para o ar depois que um humano apertar o botão de aprovar"
.
Passo 7: Os Documentos Finais e o Pitch (Etapa 8)
Um produto real não é só código, é documentação e segurança.
O que fazer: Criar documentos de governança e montar a apresentação final
.
Exemplo prático:
Criar o model-card.md (um "bula" do modelo) explicando suas limitações e o lgpd-plan.md dizendo que vocês não usam dados sensíveis como raça ou religião (LGPD)
.
Fazer um relatório técnico de até 10 páginas contando o que vocês fizeram
.
Montar uma apresentação (Pitch) de 10 minutos para vender a ideia aos professores, mostrando como isso traz lucro, reduz custos e funciona na prática (demonstração do Passo 5)
.
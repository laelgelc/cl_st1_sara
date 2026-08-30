# Arcabouço Metodológico: Análise Multidimensional Tradicional e Aditiva

## 1. Visão Geral
O estudo emprega uma estrutura de Análise Multidimensional (MDA - *Multi-Dimensional Analysis*) para identificar e comparar dimensões de variação linguística entre contos de autoria humana e contos gerados por modelos de linguagem de grande escala (LLMs). A linha de processamento analítico consiste em duas fases principais: uma MDA Tradicional, para estabelecer o espaço dimensional com base em um corpus de referência (corpus base), seguida por uma MDA Aditiva, para projetar um novo registro (gerado por LLM de forma guiada) neste espaço multidimensional pré-estabelecido.

## 2. Ingestão e Preparação de Dados
O conjunto de dados compreende contagens de características linguísticas para três subcorpora distintos:
*   **Subcorpus de Autoria Humana** (`source: human`, `prompt: human`)
*   **Subcorpus Livre gerado por LLM** (`source: ai`, `prompt: llm_free`)
*   **Subcorpus Guiado gerado por LLM** (`source: ai`, `prompt: llm`)

Para estabelecer o espaço multidimensional fundamental, os subcorpora Humano e LLM-Livre são combinados para formar o **Corpus Base**. O subcorpus LLM-Guiado é reservado como um **Corpus Aditivo**. Variáveis obsoletas ou legadas (como as dimensões originais de Biber de 1988 pré-calculadas e variáveis de resumo redundantes) são excluídas do conjunto de dados antes do processamento estatístico para evitar colinearidade e distorções.

## 3. Extração de Fatores (MDA Tradicional)
A análise fatorial é conduzida exclusivamente no Corpus Base para definir as dimensões subjacentes de variação.

**3.1. Análise Fatorial Não Rotacionada e Corte de Comunalidade**
Uma análise inicial de componentes principais (não rotacionada) é realizada para avaliar a variância capturada pelas características linguísticas. Variáveis que demonstram baixa variância compartilhada — especificamente aquelas com estimativas de comunalidade inferiores a **0,15** — são excluídas do modelo final para garantir a robustez. Um gráfico de sedimentação (*scree plot*) de autovalores também é gerado para avaliar visualmente o número ideal de fatores.

**3.2. Análise Fatorial Rotacionada**
Uma análise fatorial final é realizada com as variáveis restantes, utilizando a extração de Componentes Principais e uma rotação **Promax (oblíqua)**. Com base nos parâmetros do estudo, exatamente **9 fatores** são extraídos.

As características (*features*) são atribuídas a um fator específico com base na sua maior carga absoluta, com um limite mínimo de inclusão de **0,30**. Variáveis que carregam em múltiplos fatores são estritamente atribuídas ao fator onde sua carga é matematicamente maior, mantendo a clareza ortogonal na pontuação final. Ambos os polos (positivo e negativo) são identificados para cada fator.

## 4. Análise Multidimensional Aditiva e Pontuação
Para comparar diretamente o subcorpus LLM-Guiado com as dimensões base estabelecidas, utiliza-se a abordagem de MDA Aditiva.

**4.1. Padronização**
As contagens linguísticas brutas do Corpus Base são padronizadas em escores-z (média = 0, desvio padrão = 1). Crucialmente, para garantir uma comparação válida, as características do Corpus Aditivo (LLM-Guiado) são padronizadas *usando exatamente os mesmos parâmetros de média e desvio padrão derivados do Corpus Base*.

**4.2. Pontuação das Dimensões (*Dimension Scoring*)**
Seguindo a metodologia de Biber (1988), os escores dimensionais para cada texto em todos os subcorpora são calculados com base nos escores-z padronizados. Para um determinado texto em um determinado fator, o escore dimensional é calculado somando-se os escores-z das características que carregaram no polo positivo e, subsequentemente, subtraindo-se o somatório dos escores-z das características que carregaram no polo negativo.

## 5. Tratamento de Valores Atípicos (Outliers)
A metodologia inclui uma estrutura robusta para identificar e lidar com *outliers* entre os escores dimensionais calculados. Os *outliers* são definidos quantitativamente usando o método do Intervalo Interquartil (IQR), especificamente aqueles que caem fora dos limites de (Q1 - 1*IQR) a (Q3 + 1*IQR).

*Nota sobre o desvio (bypass):* Dependendo do objetivo analítico — especialmente ao avaliar textos gerados por IA, onde desvios estilométricos extremos podem ser linguisticamente significativos em vez de mero ruído estatístico — a linha de processamento (pipeline) inclui um mecanismo explícito para contornar a exclusão e reter os *outliers* no conjunto de dados final para os testes estatísticos.

## 6. Análise Estatística e Visualização
Para determinar se existem diferenças significativas na variação linguística entre os diferentes subcorpora, os escores dimensionais combinados (abrangendo tanto o corpus Base quanto o Aditivo) são analisados usando Modelos Lineares Generalizados (GLMs).

*   **ANOVAs** são executadas para testar os efeitos principais das variáveis independentes (`prompt` e `source`) e a sua interação (`prompt*source`) em cada uma das 9 dimensões extraídas.
*   **Boxplots** são gerados dinamicamente para cada dimensão a fim de avaliar visualmente a distribuição, a mediana e a variância dos escores dimensionais entre as diferentes condições de *prompt*.
# **Testes Brown-Forsyth e Tukey no SAS**

Os dois testes entram no mesmo PROC GLM que você provavelmente já usa para a ANOVA por dimensão. Basta acrescentar uma instrução MEANS com as opções certas.

## **Código**

Supondo um conjunto de dados com os escores de cada texto nas quatro dimensões (dim1 a dim4) e a variável de grupo prompt (humano, LLM guiado, LLM livre). Ajuste os nomes aos do seu projeto:

```sas
ods graphics on;

proc glm data=work.escores plots=(boxplot);
    class prompt;
    model dim1 dim2 dim3 dim4 = prompt;
    means prompt / hovtest=bf welch tukey cldiff;
run;
quit;
```

Se quiser salvar as tabelas de resultado em conjuntos de dados, para montar as tabelas da dissertação, coloque antes do PROC GLM:

```sas
ods output HOVFTest = bf_resultados
    Welch = welch_resultados
    CLDiffs = tukey_resultados;
```

## **O que cada opção faz**

|   Opção    |                    Teste                     |                                    Pergunta que responde                                    |           Hipótese nula           |
|:----------:|:--------------------------------------------:|:-------------------------------------------------------------------------------------------:|:---------------------------------:|
| hovtest=bf | Brown-Forsythe (homogeneidade de variâncias) |                Os três grupos têm a mesma dispersão de escores na dimensão?                 | Variâncias iguais entre os grupos |
|   welch    |                ANOVA de Welch                |                     As médias diferem, sem pressupor variâncias iguais?                     |  Médias iguais (versão robusta)   |
|   tukey    |                  Tukey HSD                   |                          Quais pares de grupos diferem nas médias?                          |   Nenhuma diferença entre o par   |
|   cldiff   |              (formato do Tukey)              | Exibe as diferenças com intervalos de confiança de 95%, em vez de apenas agrupar por letras |                 —                 |

O Brown-Forsythe, no SAS, é a variante do teste de Levene que usa desvios absolutos em relação à mediana de cada grupo, e não à média, o que o torna mais robusto a distribuições assimétricas. Nas palavras dos autores, trata-se de um teste de igualdade de variâncias "robusto" a desvios da normalidade (Brown; Forsythe, 1974\)

Vale um cuidado terminológico ao redigir: Brown e Forsythe publicaram em 1974 dois testes diferentes. Um testa variâncias, e é esse que o hovtest=bf executa. O outro é um F robusto para médias, disponível no SPSS, mas não nativamente no PROC GLM. O equivalente no SAS para médias é o Welch (Welch, 1951).

## **Por que o Brown-Forsythe interessa especialmente à sua pesquisa**

O objetivo específico 3 compara a dispersão dos escores fatoriais entre humano e IA. Isso é uma pergunta sobre variância, não sobre média. O Brown-Forsythe é, portanto, o teste que responde diretamente a esse objetivo, e não apenas uma verificação de pressupostos. Se as teorias de Tarde e Bourdieu estiverem certas, espera-se variância significativamente menor nos subcorpora de IA.

Isso também vale para a Dimensão 4\. A ANOVA não foi significativa (p \= 0,0647), mas os grupos podem ter médias iguais e dispersões diferentes. Não descarte a D4 antes de rodar o BF nela.

## **Como ler a sequência de resultados**

| Situação                         | Interpretação                                                              | Encaminhamento                                                              |
|:---------------------------------|:---------------------------------------------------------------------------|:----------------------------------------------------------------------------|
| BF não significativo             | Variâncias homogêneas; pressuposto da ANOVA atendido                       | Reportar ANOVA clássica \+ Tukey normalmente                                |
| BF significativo                 | Dispersões diferem entre grupos (resultado substantivo para o objetivo 3\) | Reportar Welch no lugar do F clássico; comparar os desvios-padrão por grupo |
| Tukey com IC que não inclui zero | Diferença significativa entre aquele par                                   | Indicar direção (qual grupo tem média maior na dimensão)                    |

Com três grupos de 1.013 textos cada, o BF tende a dar significativo mesmo para diferenças pequenas. Por isso convém reportar também os desvios-padrão por grupo, que a própria instrução MEANS já imprime, e a razão entre eles, para mostrar a magnitude da diferença e não só o p-valor.

Há ainda uma limitação do Tukey: ele pressupõe variâncias iguais. Como os grupos têm tamanhos idênticos, ele é razoavelmente robusto a essa violação. Se o seu orientador preferir uma alternativa mais rigorosa, o SAS não oferece o Games-Howell no PROC GLM.

O caminho seria o PROC GLIMMIX com variâncias residuais separadas por grupo: **(é preciso repetir para cada dimensão)**

```sas
proc glimmix data=work.escores;
    class prompt;
    model dim1 = prompt / ddfm=satterthwaite;
    random _residual_ / group=prompt;
    lsmeans prompt / pdiff adjust=tukey cl;
run;
```

## **Como inserir os códigos**

Primeiro, troque os nomes pelos do seu projeto. Usei work.escores, dim1–dim4 e prompt como exemplo. Você precisa do nome real do conjunto de dados que tem os escores de cada texto nas dimensões e dos nomes exatos das variáveis. Se o pipeline da AMD (o do repositório do cl\_st1\_sara ou os scripts) já gera esse arquivo, é só apontar para ele. Se as dimensões tiverem outro nome, como fac1 ou score\_d1, basta substituir na linha model.

Depois, confira que os escores são por texto. O teste precisa de uma linha por conto (3.039 linhas), cada uma com o grupo e os quatro escores. Se você só tiver as médias por grupo, os testes não rodam.

Também veja se prompt tem exatamente três categorias. Um valor escrito de forma diferente, como "humano" e "Humano", vira um quarto grupo sem avisar.

Por fim, leia o Log depois de rodar. Se aparecer algo em vermelho (ERROR) ou verde (WARNING) sobre variável não encontrada, é quase sempre nome errado.

Feito isso, sim, é só rodar. O bloco com PROC GLIMMIX é opcional e só vale a pena se o Tony pedir uma alternativa ao Tukey.

# **Referências**

BROWN, M. B.; FORSYTHE, A. B. Robust tests for the equality of variances. Journal of the American Statistical Association, v. 69, n. 346, p. 364-367, 1974\.

TUKEY, J. W. The problem of multiple comparisons. Princeton: Princeton University, 1953\. Manuscrito não publicado.

WELCH, B. L. On the comparison of several mean values: an alternative approach. Biometrika, v. 38, n. 3/4, p. 330-336, 1951\. 

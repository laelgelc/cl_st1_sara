[22/09/26, 21:36:43] ~Sara Elysa Dantas 🪻: Boa noite, Rogério, tudo bem?

Enviei um e-mail sobre as respostas que você me mandou, muito obrigada por isso, elas ajudaram muito a preencher algumas das lacunas que encontrei na minha metodologia. Há apenas mais uma coisa que me pegou, ainda na parte estatística. Enquanto estudava outros trabalhos que usam AMD para entender melhor a análise dos meus resultados, percebi que alguns deles complementam a ANOVA com testes adicionais chamados Brown-Forsythe (para homogeneidade de variâncias) e Tukey (post-hoc, para comparar os pares entre si) como forma de aprofundar a interpretação dos dados. Fiquei curiosa se isso se aplicaria ao meu estudo também, então rodei os dois testes com a ajuda do Claude, em Python, usando os escores fatoriais que exportei do SAS. Os resultados ficaram interessantes, especialmente na Dimensão 4, onde a Anova não mostra diferença entre as médias das três condições, mas o Brown-Forsythe mostra diferença significativa nas variâncias. Achei que isso reforça bastante o argumento da minha pesquisa sobre a dispersão.

Só que lendo as suas respostas as minhas perguntas percebi que tem uma questão incoerente, como esses dois testes rodaram fora do script SAS que você me passou, é errado descrever na Metodologia que toda a análise estatística foi feita no SAS se não foi bem assim, certo?

Por isso, queria saber se você acha que vale a pena adicionar esses dois testes ao script SAS existente (pelo o que pesquisei seria só acrescentar HOVTEST=BF e a opção de Tukey no PROC GLM que já está lá), para manter tudo dentro da mesma ferramenta? Ou acha que devo manter só o que o script original já gera, e tiro esses resultados extras do capítulo? <This message was edited>

[23/09/26, 07:40:35] eyamrog: Bom dia, Sara! Muito obrigado pela sua mensagem e email! Parabéns pela sua pesquisa sobre estes testes! Recentemente, ouvi um de nossos colegas comentar sobre esse teste de Brown-Forsythe e, agora há pouco, vi um slide do projeto `AI and Human Oral Histories` do Professor Tony (veja a seguir). Se eles são importantes para o seu projeto, precisamos implementá-los no script do SAS para que todas as análises estatísticas sejam realizadas no próprio SAS. Partirei do que você me contou sobre eles e tomarei cuidado para não causar inconsistências nas análises já realizadas.

> "Brown–Forsythe tests then assessed whether AI populations reproduced, compressed, or expanded human variation, and paired comparisons assessed whether persona-conditioned synthetic individuals reproduced characteristics of their human counterparts." <This message was edited>

[23/09/26, 07:40:48] eyamrog: lancaster_2026_oral_history-93.pdf • 1 page document omitted

[23/09/26, 11:23:30] ~Sara Elysa Dantas 🪻: Bom dia! Eu quem agradeço, muito muito obrigada mesmo!

[23/09/26, 11:24:26] ~Sara Elysa Dantas 🪻: Que demais, eu não sabia!

[23/09/26, 11:25:00] ~Sara Elysa Dantas 🪻: Pelo o que li, esses dois testes ajudam a "tirar a prova dos 9", como se fosse uma forma de ver uma camada mais profunda das dimensões ou algo assim

[23/09/26, 11:26:51] ~Sara Elysa Dantas 🪻: Não sei se interpretei certo, mas entendi que o Brown "prova" se há homogeneização e o Tukey compara os resultados entre si para ver se está tudo redondinho e se a conta fecha

[23/09/26, 11:27:10] ~Sara Elysa Dantas 🪻: Eu não sei se você já fez testes como esses, mas posso pesquisar mais sobre como fazê-los se isso te ajudar

[23/09/26, 14:42:54] ~Sara Elysa Dantas 🪻: Testes Brown-Forsyth e Tukey no SAS.docx document omitted

[23/09/26, 14:43:00] ~Sara Elysa Dantas 🪻: Espero que ajude

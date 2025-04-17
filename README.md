[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/4nHL7_6-)
[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-2e0aaae1b6195c2367325f4f02e2d04e9abb55f0b24a779b69b11b9e10269abc.svg)](https://classroom.github.com/online_ide?assignment_repo_id=18945179&assignment_repo_type=AssignmentRepo)
# CS 164: Programming Assignment 1

[PA1 Specification]: https://drive.google.com/open?id=1oYcJ5iv7Wt8oZNS1bEfswAklbMxDtwqB
[ChocoPy Specification]: https://drive.google.com/file/d/1mrgrUFHMdcqhBYzXHG24VcIiSrymR6wt

Note: Users running Windows should replace the colon (`:`) with a semicolon (`;`) in the classpath argument for all command listed below.

## Getting started

Run the following command to generate and compile your parser, and then run all the provided tests:

    mvn clean package

    java -cp "chocopy-ref.jar:target/assignment.jar" chocopy.ChocoPy --pass=s --test --dir src/test/data/pa1/sample/

In the starter code, only one test should pass. Your objective is to build a parser that passes all the provided tests and meets the assignment specifications.

To manually observe the output of your parser when run on a given input ChocoPy program, run the following command (replace the last argument to change the input file):

    java -cp "chocopy-ref.jar:target/assignment.jar" chocopy.ChocoPy --pass=s src/test/data/pa1/sample/expr_plus.py

You can check the output produced by the staff-provided reference implementation on the same input file, as follows:

    java -cp "chocopy-ref.jar:target/assignment.jar" chocopy.ChocoPy --pass=r src/test/data/pa1/sample/expr_plus.py

Try this with another input file as well, such as `src/test/data/pa1/sample/coverage.py`, to see what happens when the results disagree.

## Assignment specifications

See the [PA1 specification][] on the course
website for a detailed specification of the assignment.

Refer to the [ChocoPy Specification][] on the CS164 web site
for the specification of the ChocoPy language. 

## Receiving updates to this repository

Add the `upstream` repository remotes (you only need to do this once in your local clone):

    git remote add upstream https://github.com/cs164berkeley/pa1-chocopy-parser.git

To sync with updates upstream:

    git pull upstream master


## Submission writeup

Team member 1: Daniel Vasconcellos Gullo 

Team member 2: Estêvão Mori Ferreira

Team member 3: Thiago da Rocha Thomaz

### Que estratégia você usou para emitir tokens ``INDENT`` e ``DEDENT`` corretamente? Mencione o nome do arquivo e o(s) número(s) da(s) linha(s) para a parte principal da sua solução.

O arquivo onde se encontra a solução é o ChocoPy.jflex, mais precisamente entre as linhas 55 e 103. A estratégia selecionada consiste na criação de uma pilha e, a cada caracter "vazio", o programa adiciona ao contador da indentação atual, o valor apropriado, que pode ser 8 ou 1 e, no momento que encontra algo diferente disso, compara com os valores de indentação já presentes na pilha.

Para a execução correta do algoritmo acima, utilizamos o ``yypushback()`` que nos permitiu a leitura repetida da mesma ``String`` de entrada, possibilitando, assim, a geraração de mais de um ``DEDENT`` para a mesma linha e também analisar o restante dela.

Quando a indentação corrente é maior que o topo da pilha, um token ``INDENT`` é emitido. Caso seja menor, as indentações são retiradas do topo da pilha até o momento em que a indentação atual e a informação presente no topo da pilha sejam iguais, emitindo ``DEDENTS`` para cada um.


### Como sua solução ao item 1. se relaciona ao descrito na seção 3.1 do manual de referência de ChocoPy? (Arquivo chocopy_language_reference.pdf.)

A emissão dos tokens `INDENT`, `DEDENT` e `NEWLINE` não ocorrem em lihas vazias, logo, a estrutura sintática da linguagem é preservada. A leitura correta de um código Python consegue gerar um `DEDENT` para cada ``INDENT`` emitido, delimitando corretamente os blocos do programa.

### Qual foi a característica mais difícil da linguagem (não incluindo identação) neste projeto? Por que foi um desafio? Mencione o nome do arquivo e o(s) número(s) da(s) linha(s) para a parte principal de a sua solução.

A parte mais difícil da linguagem neste projeto foi a implementação de definição de função (`fun_def` nas linhas 274-277), especialmente devido à necessidade de lidar com tipos de retorno opcionais (`ret_type`) e a construção do corpo da função (`fun_body_decs`).

A regra ``ret_type`` (linhas 286-288) pode ser explícita ou implícita. Isso exigiu uma verificação especial no código de ação para substituir um tipo inválido por ``ClassType("<None>")``.

A função precisa capturar declarações locais (``fun_body_decs``: globais, não-locais, variáveis, ou outras funções) e statements (``list_stmt``), todos dentro de um bloco indentado (``INDENT/DEDENT``). Além disso, o FuncDef deve rastrear tanto o início quanto o fim da função no código-fonte
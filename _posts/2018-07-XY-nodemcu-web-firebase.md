%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatPlotLib and Random Cheat Sheet
%
% Edited by Michelle Cristina de Sousa Baltazar
%
% http://matplotlib.org/api/pyplot_summary.html
% http://matplotlib.org/users/pyplot_tutorial.html
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\documentclass{article}
\usepackage[landscape]{geometry}
\usepackage{url}
\usepackage{multicol}
\usepackage{amsmath}
\usepackage{amsfonts}
\usepackage{tikz}
\usetikzlibrary{decorations.pathmorphing}
\usepackage{amsmath,amssymb}

\usepackage{colortbl}
\usepackage{xcolor}
\usepackage{mathtools}
\usepackage{amsmath,amssymb}
\usepackage{enumitem}

\title{MatPlotLib and Random Cheat Sheet}
\usepackage[brazilian]{babel}
\usepackage[utf8]{inputenc}

\advance\topmargin-.8in
\advance\textheight3in
\advance\textwidth3in
\advance\oddsidemargin-1.5in
\advance\evensidemargin-1.5in
\parindent0pt
\parskip2pt
\newcommand{\hr}{\centerline{\rule{3.5in}{1pt}}}
%\colorbox[HTML]{e4e4e4}{\makebox[\textwidth-2\fboxsep][l]{texto}
\begin{document}

\begin{center}{\huge{\textbf{MatplotLib and Random Cheat Sheet}}}\\
{\large By Michelle Cristina de Sousa Baltazar}
\end{center}
\begin{multicols*}{3}

\tikzstyle{mybox} = [draw=black, fill=white, very thick,
    rectangle, rounded corners, inner sep=10pt, inner ysep=10pt]
\tikzstyle{fancytitle} =[fill=black, text=white, font=\bfseries]
%------------ CONTEÚDO CAIXA RANDOM ---------------
\begin{tikzpicture}
\node [mybox] (box){%
    \begin{minipage}{0.3\textwidth}
		Para usar a biblioteca random, primeiro é necessário importá-la. No início do programa inserimos: \\
        \\
		\textit{from random import *} \\
        \\
        Também podemos rodar o comando help(random) no interpretador python para ver quais funções a biblioteca random fornece:
        \\
        \textit{\$ python} \\
		\textit{>>> import random} \\
		\textit{>>> help(random)} \\
        \\
        O código em randomOps.py contem lguns exemplos das funções mais úteis desta biblioteca:\\
	\begin{center}\small{\begin{tabular}{lp{4.5cm} l}
		\textit{random():} & obtém o próximo número aleatório no intervalo [0.0, 1.0] \\ \hline
		\textit{random(começo,fim):} & obter o próximo número aleatório no intervalo [começo, fim] \\ \hline
		\textit{random(stop):} & obtém o próximo número aleatório no intervalo [0, fim]
	\end{tabular}}\end{center}
    \end{minipage}
};
%------------ CAIXA RANDOM ---------------------
\node[fancytitle, right=10pt] at (box.north west) {Biblioteca Random};
\end{tikzpicture}


%------------ CONTEÚDO CAIXA MatPlotLib ---------------
\begin{tikzpicture}
\node [mybox] (box){%
    \begin{minipage}{0.3\textwidth}
		Para usar a biblioteca MatPlotLib, comece importando estes módulos Python: \\
        \\
		\textit{import numpy as np} \\
		\textit{import pandas as pd} \\
		\textit{from pandas import DataFrame, Series} \\
		\textit{import matplotlib.pyplot as plt} \\
		\textit{import matplotlib} \\
		\\
        {\bf Pyplot} é uma coleção de funções no estilo de comandos que fazem a biblioteca matplotlib funcionar como o MatLab. Cada função pyplot faz alguma alteração na plotagem do gráfico.
    \end{minipage}
};
%------------ CAIXA PRELIMINARES ---------------------
\node[fancytitle, right=10pt] at (box.north west) {Biblioteca MatPlotLib};
\end{tikzpicture}
%------------ CONTEUDO EXEMPLO BASICO ---------------------
\begin{tikzpicture}
\node [mybox] (box){%
    \begin{minipage}{0.3\textwidth}
    	Exemplo básico de plotagem de gráfico:\\
        \\
        \textit{import matplotlib.pyplot as plt}\\
		\textit{plt.plot([1,2,3,4])}\\
		\textit{plt.ylabel('Números de Exemplo')}\\
		\textit{plt.show()}\\
        \\
        Neste exemplo, foi gerado um valor para Y baseado no valor de X informado.
    \end{minipage}
};
%------------ EXEMPLO BASICO BOX ---------------------
\node[fancytitle, right=10pt] at (box.north west) {Exemplo básico MatPlotLib:};
\end{tikzpicture}
%------------ CONTEUDO DOIS EIXOS ---------------------
\begin{tikzpicture}
\node [mybox] (box){%
    \begin{minipage}{0.3\textwidth}
		Podemos também informar o valor dos dois eixos.\\
        \\
        \textit{import matplotlib.pyplot as plt}\\
		\textit{plt.plot([1,2,3,4], [1,4,9,16], 'ro')}\\
		\textit{plt.axis([0, 6, 0, 20])}\\
		\textit{plt.show()}\\
        \\
        Neste caso, temos os 2 eixos mais o terceiro argumento opicional em formato de string \textit{'ro'} que indica a cor e o tipo de linha da plotagem (vide quadro a seguir).\\
        A linha \textit{ptl.axix} mostra quais são os pontos que deverão ser marcados no gráfico.
    \end{minipage}
};
%------------ DOIS EIXOS BOX ---------------------
\node[fancytitle, right=10pt] at (box.north west) {MatPlotLib com dois eixos:};
\end{tikzpicture}
%------------ CONTEÚDO COMANDOS DE TEXTO ---------------------
\begin{tikzpicture}
\node [mybox] (box){%
    \begin{minipage}{0.3\textwidth}
    Os comandos a seguir são usados para criar texto na interface Pyplot:
	\begin{center}\small{\begin{tabular}{lp{6cm} r}
text() & adiciona texto em um local específico dos eixos. \\ \hline
xlabel() & adiciona uma legenda para o eixo x. \\ \hline
ylabel() & adiciona uma legenda para o eixo y. \\ \hline
title() & adiciona um título para os eixos. \\ \hline
figtext() & adiciona texto em um local específico da figura. \\ \hline
suptitle() & adiciona um título à figura. \\ \hline
annotate() & adiciona uma anotação ao eixos com uma seta opcional.
	\end{tabular}}\end{center}
All of these functions create and return a matplotlib.text.Text() instance, which can be configured with a variety of font and other properties.
    \end{minipage}
};
%------------ COMANDOS DE TEXTO BOX ---------------------
\node[fancytitle, right=10pt] at (box.north west) {MatPlotLib - Comandos de Texto Básicos};
\end{tikzpicture}
%------------ CONTEUDO PROPRIEDADES ---------------------
\begin{tikzpicture}
\node [mybox] (box){%
    \begin{minipage}{0.3\textwidth}
	\begin{center}\small{\begin{tabular}{lp{5cm} l}
{\bf Propriedade} & {\bf Tipo de Valor} \\
alpha & float \\ \hline
animated & [True | False] \\ \hline
antialiased or aa & [True | False] \\ \hline
clip\_box & uma instância matplotlib.transforma.Bbox \\ \hline
clip\_on & [True | False] \\ \hline
clip\_path & uma instancia de caminho e uma instancia de transformação, um Patch \\ \hline
color or c & qualquer cor matplotlib \\ \hline
contains & a função de teste de acertos \\ \hline
dash\_capstyle & ['final' | 'turno' | 'projeção'] \\ \hline
solid\_capstyle & ['final' | 'turno' | 'projeção'] \\ \hline
dash\_joinstyle & ['topo' | 'turno' | 'corte'] \\ \hline
solid\_joinstyle & ['topo' | 'turno' | 'corte'] \\ \hline
dashes & sequencia de liga/desliga cor nos pontos \\ \hline
data & (np.arranjo dadox, np.arranjo dadoy) \\ \hline
figure & uma instância matplotlib.imagem.Figure \\ \hline
label & qualquer string \\ \hline
linestyle or ls & ['-'|'--'|'-.'|':'|'passos'|...] \\ \hline
linewidth or lw & valores tipo float nos pontos \\ \hline
lod & [True | False] \\ \hline
marker & ['+'|','|'.'|'1'|'2'|'3'|'4'] \\ \hline
markeredgecolor\\or mec & qualquer cor matplotlib \\ \hline
markeredgewidth\\or mew & valor tipo float value nos pontos \\ \hline
markerfacecolor\\or mfc & qualquer cor matplotlib \\ \hline
markersize or ms & float \\ \hline
markevery & [ nada | inteiro | (startind, stride) ] \\ \hline
picker & usado na seleção da linha interativa \\ \hline
pickradius & a amplitude de seleção da linha escolhida \\ \hline
transform & uma instância matplotlib.transforma.Transform \\ \hline
visible & [True | False] \\ \hline
xdata & np.arranjo \\ \hline
ydata & np.arranjo \\ \hline
zorder & qualquer número
	\end{tabular}}\end{center}
    \end{minipage}
};
%------------ PROPRIEDADES BOX ----------------
\node[fancytitle, right=10pt] at (box.north west) {MatPlotLib - Propriedades para Plotagem};
\end{tikzpicture}
\end{multicols*}
\end{document}
Contact GitHub API Training Shop Blog About
© 2016 GitHub, Inc. Terms Privacy Security Status Help
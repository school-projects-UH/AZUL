% La bolsa es una lista de 5 elementos.
% Cada elemento de la lista representa la cantidad de azulejos de un color que hay en la bolsa.
% Los indices de los colores son: 0-amarillo, 1-rojo, 2-azul, 3-gris, 4-negro

% Los jugadores estan enumerados del 1 al 4


% dado un entero decir el color que representa

color(0, "amarillo").
color(1, "rojo").
color(2, "azul").
color(3, "gris").
color(4, "negro").


% dado un color decir el identificador

id_color("amarillo", 0).
id_color("rojo", 1).
id_color("azul", 2).
id_color("gris", 3).
id_color("negro", 4).


% Decidir el numero de fabricas

no_fabricas(2, 5).
no_fabricas(3, 7).
no_fabricas(4, 9).


% decidir el jugador inicial

jugador_inicial(No_jugadores, Jugador_escogido):- N is No_jugadores + 1, random(1, N, Jugador_escogido).


% sacar un azulejo al azar de la bolsa

% extrae_azulejo_bolsa(Bolsa, Azulejo_escogido):-

escoge_azulejo_bolsa(Bolsa, Azulejo_escogido):-
    length(Bolsa, N),
    random(0, N, X),
    nth0(X, Bolsa, Azulejo_escogido).

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

extrae_azulejo_bolsa(Bolsa_antes, Bolsa_despues, Azulejo_escogido):-
    random(0, 5, X),
    color(X, Azulejo_escogido),
    actualiza_bolsa(Bolsa_antes, X, Bolsa_despues).

    actualiza_bolsa([X|R], 0, [Z|R]):- Z is X - 1, Z > 0.
    actualiza_bolsa([X|R], N, [X|S]):- M is N - 1, actualiza_bolsa(R, M, S).

% mueve_azulejos_fabrica_centro(Fabrica, Centro_antes, Centro_despues) :-
concatena([], L2, L2).
concatena([Cabeza1|Cola1], L2, [Cabeza1|ColaR]) :- concatenar(Cola1, L2, ColaR).
mueve_azulejos_fabrica_centro(Fabrica, Centro_antes, Centro_despues) 
    :- concatena(Centro_antes, Fabrica, Centro_despues)

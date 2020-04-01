% La bolsa es una lista de 5 elementos.
% Cada elemento de la lista representa la cantidad de azulejos de un color que hay en la bolsa.
% Los indices de los colores son: 0-amarillo, 1-rojo, 2-azul, 3-gris, 4-negro

% Los jugadores estan enumerados del 1 al 4


% decidir el numero de fábricas

no_fabricas(2, 5).
no_fabricas(3, 7).
no_fabricas(4, 9).


% decidir el jugador inicial

jugador_inicial(No_jugadores, Jugador_escogido):- N is No_jugadores + 1, random(1, N, Jugador_escogido).


% sacar un azulejo al azar de la bolsa

escoger_azulejo_bolsa(Bolsa_antes, Bolsa_despues):- random(0, 5, X), escoger_azulejo_bolsa_(Bolsa_antes, X, Bolsa_despues).
escoger_azulejo_bolsa_([X|R], 0, [Z|R]):- Z is X - 1, Z > 0.
escoger_azulejo_bolsa_([X|R], N, [X|S]):- M is N - 1, escoger_azulejo_bolsa_(R, M, S).

% La bolsa es una lista de 5 elementos.
% Cada elemento de la lista representa la cantidad de azulejos de un color que hay en la bolsa.
% Los indices de los colores son: 0-amarillo, 1-rojo, 2-azul, 3-gris, 4-negro

% Los jugadores estan enumerados del 1 al 4


% Predicados dinamicos
:- dynamic
   estado_bolsa/2,
   estado_fabricas/3,
   estado_puntuaciones/3,
   estado_muro/4,
   estado_suelo/4,
   estado_patrones/4.


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

extrae_azulejo_bolsa(Bolsa_antes, Azulejo_escogido, Bolsa_despues):-
    escoge_azulejo_bolsa(Bolsa_antes, Idx_azulejo_escogido),
    nth0(Idx_azulejo_escogido, Bolsa_antes, Azulejo_escogido),
    substrae_azulejo_bolsa(Bolsa_antes, Idx_azulejo_escogido, Bolsa_despues).


    substrae_azulejo_bolsa(Bolsa_antes, Idx_Azulejo, Bolsa_despues):- borra_lista(Bolsa_antes, Idx_Azulejo, Bolsa_despues).

    borra_lista([_|R], 0, R).
    borra_lista([A|R], C, [A|M]):- T is C - 1, borra_lista(R, T, M).

    escoge_azulejo_bolsa(Bolsa, Azulejo_escogido):-
        length(Bolsa, N),
        random(0, N, Azulejo_escogido).


% extraer 4 azulejos de la bolsa

extrae_4_azulejos_bolsa(Bolsa_antes, [A1, A2, A3, A4], Bolsa_despues):-
    extrae_azulejo_bolsa(Bolsa_antes, A1, Bd1),
    extrae_azulejo_bolsa(Bd1, A2, Bd2),
    extrae_azulejo_bolsa(Bd2, A3, Bd3),
    extrae_azulejo_bolsa(Bd3, A4, Bolsa_despues).

concatena([], L2, L2).
concatena([Cabeza1|Cola1], L2, [Cabeza1|ColaR]) :- concatena(Cola1, L2, ColaR).

mueve_azulejos_fabrica_centro(Fabrica, Centro_antes, Centro_despues)
    :- concatena(Centro_antes, Fabrica, Centro_despues).

encuentra_fabrica(Fabricas, Color, F) :-
    member(F, Fabricas),
    member(Color, F).

llena_fabricas(Bolsa_antes, N, Fabricas, Bolsa_despues):-
    llena_fabricas_(Bolsa_antes, N, [], Fabricas, Bolsa_despues).

    llena_fabricas_(Bolsa_antes, 0, Fabricas_antes, Fabricas_antes, Bolsa_antes).
    llena_fabricas_(Bolsa_antes, N, Fabricas_antes, Fabricas_despues, Bolsa_despues):-
        extrae_4_azulejos_bolsa(Bolsa_antes, Azulejos_escogidos, Bolsa_intermedia),
        M is N - 1,
        llena_fabricas_(Bolsa_intermedia, M, [Azulejos_escogidos|Fabricas_antes], Fabricas_despues, Bolsa_despues).

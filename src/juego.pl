% La bolsa es una lista de 5 elementos.
% Cada elemento de la lista representa la cantidad de azulejos de un color que hay en la bolsa.
% Los indices de los colores son: 0-amarillo, 1-rojo, 2-azul, 3-gris, 4-negro

% Los jugadores estan enumerados del 1 al 4


% Predicados dinamicos
:- dynamic
   cant_fabricas/1,
   cant_jugadores/1,
   jugador_inicial/2,
   estado_bolsa/2,
   estado_puntuaciones/3,
   estado_fabricas/4,
   estado_muro/3,
   estado_suelo/4,
   estado_patrones/4,
   cant_rondas/1.

% Decidir el numero de fabricas

no_fabricas(2, 5).
no_fabricas(3, 7).
no_fabricas(4, 9).


% decidir el jugador inicial

decidir_jugador_inicial(Jugadores, Jugador_escogido):-
    length(Jugadores, N),
    random(0, N, X),
    nth0(X, Jugadores, Jugador_escogido).


% inicializar los estados del juego

prepara_partida(Jugadores):-
    length(Jugadores, N),
    no_fabricas(N, CF),
    asserta(cant_jugadores(N)),
    asserta(cant_fabricas(CF)),
    llena_bolsa(),
    inicializar_puntuaciones(Jugadores, N),
    inicializar_fabricas(CF, Fabricas),
    asserta(estado_fabricas(0, 0, "", Fabricas)),
    inicializar_muros(Jugadores, N),
    inicializar_suelos(Jugadores, N),
    inicializar_patrones(Jugadores, N),
    decidir_jugador_inicial(Jugadores, JI),
    asserta(jugador_inicial(1, JI)).


    inicializar_puntuaciones([], 0).
    inicializar_puntuaciones([J|Rest_Jugadores], N):-
        asserta(estado_puntuaciones(0, J, 0)),
        M is N - 1,
        inicializar_puntuaciones(Rest_Jugadores, M).

    inicializar_fabricas(0, []).
    inicializar_fabricas(CF, [[]|Rest_Fabricas]):-
        M is CF - 1,
        inicializar_fabricas(M, Rest_Fabricas).

    inicializar_muros([], 0).
    inicializar_muros([J| Rest_jugadores], N):-
        M is N - 1,
        asserta(estado_muro(0, J, [[0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]])),
        inicializar_muros(Rest_jugadores, M).

    inicializar_suelos([], 0).
    inicializar_suelos([J| Rest_jugadores], N):-
        M is N - 1,
        asserta(estado_suelo(0, 0, J, [0, 0, 0, 0, 0, 0, 0])),
        inicializar_suelos(Rest_jugadores, M).

    inicializar_patrones([], 0).
    inicializar_patrones([J| Rest_jugadores], N):-
        M is N - 1,
        asserta(estado_patrones(0, 0, J, [[""], ["", ""], ["", "", ""], ["", "", "", ""], ["", "", "", "", ""]])),
        inicializar_patrones(Rest_jugadores, M).


% sacar un azulejo al azar de la bolsa

extrae_azulejo_bolsa(Bolsa_antes, Azulejo_escogido, Bolsa_despues):-
    escoge_azulejo_bolsa(Bolsa_antes, Idx_azulejo_escogido),
    nth0(Idx_azulejo_escogido, Bolsa_antes, Azulejo_escogido),
    substrae_azulejo_bolsa(Bolsa_antes, Idx_azulejo_escogido, Bolsa_despues).

    substrae_azulejo_bolsa(Bolsa_antes, Idx_Azulejo, Bolsa_despues):-
        borra_lista(Bolsa_antes, Idx_Azulejo, Bolsa_despues).

    borra_lista([_|R], 0, R).
    borra_lista([A|R], C, [A|M]):-
        T is C - 1,
        borra_lista(R, T, M).

    escoge_azulejo_bolsa(Bolsa, Azulejo_escogido):-
        length(Bolsa, N),
        random(0, N, Azulejo_escogido).


% extraer 4 azulejos de la bolsa

extrae_4_azulejos_bolsa(Bolsa_antes, [A1, A2, A3, A4], Bolsa_despues):-
    extrae_azulejo_bolsa(Bolsa_antes, A1, Bd1),
    extrae_azulejo_bolsa(Bd1, A2, Bd2),
    extrae_azulejo_bolsa(Bd2, A3, Bd3),
    extrae_azulejo_bolsa(Bd3, A4, Bolsa_despues).


% Por cada fabrica, sacar 4 azulejos y colocarlos en la misma

llena_fabricas(Bolsa_antes, N, Fabricas, Bolsa_despues):-
    llena_fabricas_(Bolsa_antes, N, [], Fabricas, Bolsa_despues).

    llena_fabricas_(Bolsa_antes, 0, Fabricas_antes, Fabricas_antes, Bolsa_antes).
    llena_fabricas_(Bolsa_antes, N, Fabricas_antes, Fabricas_despues, Bolsa_despues):-
        extrae_4_azulejos_bolsa(Bolsa_antes, Azulejos_escogidos, Bolsa_intermedia),
        M is N - 1,
        llena_fabricas_(Bolsa_intermedia, M, [Azulejos_escogidos|Fabricas_antes], Fabricas_despues, Bolsa_despues).


% el primer jugador llena cada fabrica con 4 azulejos extraidos al azar

mueve_azulejos_bolsa_fabrica(No_ronda, Jugador):-
    estado_bolsa(No_ronda, Bolsa_antes),
    cant_fabricas(CF),
    llena_fabricas(Bolsa_antes, CF, Fabricas, Bolsa_despues),
    retract(estado_bolsa(No_ronda, Bolsa_antes)),
    asserta(estado_bolsa(No_ronda, Bolsa_despues)),
    asserta(estado_fabricas(No_ronda, 1, Jugador, Fabricas)).

mueve_azulejos_fabrica_centro(Fabrica, Centro_antes, Centro_despues)
    :- append(Centro_antes, Fabrica, Centro_despues).

encuentra_fabrica(Fabricas, Color, F) :-
    member(F, Fabricas),
    member(Color, F).

extrae_un_azulejo_fabrica(Fabrica_antes, Azulejo_escogido, Fabrica_despues) :-
    nth0(Idx_azulejo_escogido, Fabrica_antes, Azulejo_escogido),
    substrae_azulejo_fabrica(Fabrica_antes, Idx_azulejo_escogido, Fabrica_despues).

    substrae_azulejo_fabrica(Fabrica_antes, Idx_Azulejo, Fabrica_despues):-
        borra_lista(Fabrica_antes, Idx_Azulejo, Fabrica_despues).

extrae_todos_azulejos_fabrica(Fabrica, Azulejo_escogido, Fabrica) :-
    not(member(Azulejo_escogido, Fabrica)), !.

extrae_todos_azulejos_fabrica(Fabrica_antes, Azulejo_escogido, Fabrica_despues) :-
    extrae_un_azulejo_fabrica(Fabrica_antes, Azulejo_escogido, Fabrica_despues_temp), !,
    extrae_todos_azulejos_fabrica(Fabrica_despues_temp, Azulejo_escogido, Fabrica_despues).


% llenar la bolsa con 100 azulejos al principio de la partida

llena_bolsa():-
    llena_bolsa_(Bolsa),
    asserta(estado_bolsa(0, Bolsa)).

    llena_bolsa_(Bolsa):-
        llena_bolsa_color_([], "azul", 20, B1),
        llena_bolsa_color_(B1, "rojo", 20, B2),
        llena_bolsa_color_(B2, "amarillo", 20, B3),
        llena_bolsa_color_(B3, "gris", 20, B4),
        llena_bolsa_color_(B4, "negro", 20, Bolsa).

    llena_bolsa_color_(Bolsa_antes, _ , 0, Bolsa_antes).
    llena_bolsa_color_(Bolsa_antes, Color, Cantidad, Bolsa_despues):-
        Nueva_cantidad is Cantidad - 1,
        introduce_azulejo_bolsa(Bolsa_antes, Color, Bolsa_intermedia),
        llena_bolsa_color_(Bolsa_intermedia, Color, Nueva_cantidad, Bolsa_despues).

    introduce_azulejo_bolsa(Bolsa_antes, Azulejo, [Azulejo|Bolsa_antes]).
% Fin de la partida
valor_en(Muro, I, J, Valor) :-
    nth0(I, Muro, Linea),
    nth0(J, Linea, Valor).

columna(J, Muro, [V0, V1, V2, V3, V4]) :-
    valor_en(Muro, 0, J, V0), valor_en(Muro, 1, J, V1),
    valor_en(Muro, 2, J, V2), valor_en(Muro, 3, J, V3),
    valor_en(Muro, 4, J, V4).

actualiza_puntuacion_adicional(Jugador, Ronda, Puntuacion_adicional).
puntua_adicional(Jugador, Ronda, Puntuacion_adicional) :-
    estado_muro(Jugador, Ronda, Muro),
    contar_2pts_por_lineas_horizontales(Muro, Puntos_horizontales),
    contar_2pts_por_lineas_verticales(Muro, Puntos_verticales),
    contar_2pts_por_colores_completos(Muro, Puntos_colores),
    Puntuacion_adicional is Puntos_horizontales + Puntos_verticales + Puntos_colores.

    contar_2pts_por_lineas_horizontales(Muro, Puntos) :-
        nth0(0, Muro, F0), comprobar_linea_horizontal(F0, P0),
        nth0(1, Muro, F1), comprobar_linea_horizontal(F1, P1),
        nth0(2, Muro, F2), comprobar_linea_horizontal(F2, P2),
        nth0(3, Muro, F3), comprobar_linea_horizontal(F3, P3),
        nth0(4, Muro, F4), comprobar_linea_horizontal(F4, P4),
        Puntos is P0 + P1 + P2 + P3 + P4.

    comprobar_linea_horizontal(Fila, 0) :- member(0, Fila), !.
    comprobar_linea_horizontal(Fila, 2) :- !.

    contar_7pts_por_lineas_verticales(Muro, Puntos) :-
        columna(0, Muro, C0), comprobar_linea_vertical(C0, P0),
        columna(1, Muro, C1), comprobar_linea_vertical(C1, P1),
        columna(2, Muro, C2), comprobar_linea_vertical(C2, P2),
        columna(3, Muro, C3), comprobar_linea_vertical(C3, P3),
        columna(4, Muro, C4), comprobar_linea_vertical(C4, P4),
        Puntos is P0 + P1 + P2 + P3 + P4.

    comprobar_linea_vertical(Columna, 0) :- member(0, Columna), !.
    comprobar_linea_vertical(Columna, 7) :- !.


calcular_todos_los_puntos_adicionales() :-
    cant_jugadores(Ultimo_jugador),
    cant_rondas(Ultima_ronda),
    calcular_puntos_adicionales(Ultimo_jugador, Ultima_ronda).

    calcular_puntos_adicionales(0, _) :- !.
    calcular_puntos_adicionales(Jugador, Ultima_ronda) :-
        puntua_adicional(Jugador, Ultima_ronda, Puntuacion_adicional),
        actualiza_puntuacion_adicional(Jugador, Ronda, Puntuacion_adicional),
        Otro_jugador is Jugador - 1, !,
        calcular_puntos_adicionales(Otro_jugador, Ultima_ronda).
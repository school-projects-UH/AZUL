% La bolsa es una lista de 5 elementos.
% Cada elemento de la lista representa la cantidad de azulejos de un color que hay en la bolsa.
% Los indices de los colores son: 0-amarillo, 1-rojo, 2-azul, 3-gris, 4-negro

% Los jugadores estan enumerados del 1 al 4


% Predicados dinamicos
:- dynamic
   cant_fabricas/1,
   cant_jugadores/1,
   jugador_inicial/2,
   estado_tapa_caja/2,
   estado_bolsa/2,
   estado_puntuaciones/3,
   estado_fabricas/4,
   estado_muro/3,
   estado_suelo/4,
   estado_patrones/4,
   cant_rondas/1,
   cant_turnos/2. % cant_turnos(Ronda, Turnos)

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
    quedan_azulejos_bolsa(Bolsa_antes),
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

    quedan_azulejos_bolsa([_|_]).


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


mueve_azulejos_tapa_bolsa():-
    cant_rondas(Ronda_actual),
    estado_tapa_caja(Ronda_actual, Tapa),
    retract(estado_tapa_caja(Ronda_actual, Tapa)),
    asserta(estado_tapa_caja(Ronda_actual, [])),
    estado_bolsa(Ronda_actual, Bolsa),
    retract(estado_bolsa(Ronda_actual, Bolsa)),
    append(Bolsa, Tapa, Nueva_bolsa),
    asserta(estado_bolsa(Ronda_actual, Nueva_bolsa)).


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
% Puntos Adicionales
valor_en(Muro, I, J, Valor) :-
    Im is mod(I,5), Jm is mod(J,5),
    nth0(Im, Muro, Linea),
    nth0(Jm, Linea, Valor).

columna(J, Muro, [V0, V1, V2, V3, V4]) :-
    Jm is mod(J, 5),
    valor_en(Muro, 0, Jm, V0), valor_en(Muro, 1, Jm, V1),
    valor_en(Muro, 2, Jm, V2), valor_en(Muro, 3, Jm, V3),
    valor_en(Muro, 4, Jm, V4).

colores_iguales_en_muro(I0, J0, Muro, [V0, V1, V2, V3, V4]) :-
    valor_en(Muro, I0, J0, V0), I1 is I0+1, J1 is J0+1,
    valor_en(Muro, I1, J1, V1), I2 is I0+2, J2 is J0+2,
    valor_en(Muro, I2, J2, V2), I3 is I0+3, J3 is J0+3,
    valor_en(Muro, I3, J3, V3), I4 is I0+4, J4 is J0+4,
    valor_en(Muro, I4, J4, V4).

actualiza_puntuacion_adicional(Jugador, Ronda, Puntuacion_adicional) :-
    estado_puntuaciones(Ronda, Jugador, Puntuacion_actual),
    Puntuacion_final is Puntuacion_actual + Puntuacion_adicional,
    retract(estado_puntuaciones(Ronda, Jugador, Puntuacion_actual)),
    asserta(estado_puntuaciones(Ronda, Jugador, Puntuacion_final)).

puntua_adicional(Jugador, Ronda, Puntuacion_adicional) :-
    estado_muro(Jugador, Ronda, Muro),
    contar_2pts_por_lineas_horizontales(Muro, Puntos_horizontales),
    contar_7pts_por_lineas_verticales(Muro, Puntos_verticales),
    contar_10pts_por_colores_completos(Muro, Puntos_colores),
    Puntuacion_adicional is Puntos_horizontales + Puntos_verticales + Puntos_colores.

    contar_2pts_por_lineas_horizontales(Muro, Puntos) :-
        nth0(0, Muro, F0), comprobar_linea_horizontal(F0, P0),
        nth0(1, Muro, F1), comprobar_linea_horizontal(F1, P1),
        nth0(2, Muro, F2), comprobar_linea_horizontal(F2, P2),
        nth0(3, Muro, F3), comprobar_linea_horizontal(F3, P3),
        nth0(4, Muro, F4), comprobar_linea_horizontal(F4, P4),
        Puntos is P0 + P1 + P2 + P3 + P4.

        comprobar_linea_horizontal(Fila, 0) :- member(0, Fila), !.
        comprobar_linea_horizontal(_, 2) :- !.

    contar_7pts_por_lineas_verticales(Muro, Puntos) :-
        columna(0, Muro, C0), comprobar_linea_vertical(C0, P0),
        columna(1, Muro, C1), comprobar_linea_vertical(C1, P1),
        columna(2, Muro, C2), comprobar_linea_vertical(C2, P2),
        columna(3, Muro, C3), comprobar_linea_vertical(C3, P3),
        columna(4, Muro, C4), comprobar_linea_vertical(C4, P4),
        Puntos is P0 + P1 + P2 + P3 + P4.

        comprobar_linea_vertical(Columna, 0) :- member(0, Columna), !.
        comprobar_linea_vertical(_, 7) :- !.

    contar_10pts_por_colores_completos(Muro, Puntos) :-
        colores_iguales_en_muro(0, 0, Muro, C0), comprobar_color_completado(C0, P0),
        colores_iguales_en_muro(0, 1, Muro, C1), comprobar_color_completado(C1, P1),
        colores_iguales_en_muro(0, 2, Muro, C2), comprobar_color_completado(C2, P2),
        colores_iguales_en_muro(0, 3, Muro, C3), comprobar_color_completado(C3, P3),
        colores_iguales_en_muro(0, 4, Muro, C4), comprobar_color_completado(C4, P4),
        Puntos is P0 + P1 + P2 + P3 + P4.

        comprobar_color_completado(Colores, 0) :- member(0, Colores), !.
        comprobar_color_completado(_, 10) :- !.


calcular_todos_los_puntos_adicionales() :-
    cant_jugadores(Ultimo_jugador),
    cant_rondas(Ultima_ronda),
    calcular_puntos_adicionales(Ultimo_jugador, Ultima_ronda).

    calcular_puntos_adicionales(0, _) :- !.
    calcular_puntos_adicionales(Jugador, Ultima_ronda) :-
        puntua_adicional(Jugador, Ultima_ronda, Puntuacion_adicional),
        actualiza_puntuacion_adicional(Jugador, Ultima_ronda, Puntuacion_adicional),
        Otro_jugador is Jugador - 1, !,
        calcular_puntos_adicionales(Otro_jugador, Ultima_ronda).

% Comprobar si la partida finalizó
fin_partida(No_ronda, Termina) :-
    cant_jugadores(Ultimo_jugador),
    comprobar_filas(Ultimo_jugador, No_ronda, 0, Termina).

    comprobar_filas(0, _, _, 0) :- !.
    comprobar_filas(Jugador, No_ronda, 0, Termina) :-
        estado_muro(Jugador, No_ronda, Muro),
        contar_2pts_por_lineas_horizontales(Muro, Puntos),
        Otro_jugador is Jugador - 1, !,
        comprobar_filas(Otro_jugador, No_ronda, Puntos, Termina).
    comprobar_filas(_, _, _, 1) :- !.

% Puntuación por ronda
puntua_jugador_ronda(Jugador, No_ronda, I, J, Puntuacion) :-
    estado_muro(Jugador, No_ronda, Muro),
    I0 is I-1, I1 is I+1, J0 is J-1, J1 is J+1,
    adyacentes_izquierda(I, J0, Muro, 0, Cant_izq),
    adyacentes_derecha(I, J1, Muro, 0, Cant_der),
    adyacentes_arriba(I0, J, Muro, 0, Cant_arriba),
    adyacentes_abajo(I1, J, Muro, 0, Cant_abajo),
    Puntuacion is Cant_izq + Cant_der + Cant_arriba + Cant_abajo + 1.

    adyacentes_izquierda(_, -1, _, Cantidad, Cantidad) :- !.
    adyacentes_izquierda(I, J, Muro, Cantidad_antes, Cantidad_desp) :-
        valor_en(Muro, I, J, 1), J1 is J-1,
        Cantidad_actual is Cantidad_antes + 1, !,
        adyacentes_izquierda(I, J1, Muro, Cantidad_actual, Cantidad_desp).
    adyacentes_izquierda(_, _, _, Cantidad, Cantidad) :- !.

    adyacentes_derecha(_, 5, _, Cantidad, Cantidad) :- !.
    adyacentes_derecha(I, J, Muro, Cantidad_antes, Cantidad_desp) :-
        valor_en(Muro, I, J, 1), J1 is J+1,
        Cantidad_actual is Cantidad_antes + 1, !,
        adyacentes_derecha(I, J1, Muro, Cantidad_actual, Cantidad_desp).
    adyacentes_derecha(_, _, _, Cantidad, Cantidad) :- !.

    adyacentes_arriba(-1, _, _, Cantidad, Cantidad) :- !.
    adyacentes_arriba(I, J, Muro, Cantidad_antes, Cantidad_desp) :-
        valor_en(Muro, I, J, 1), I1 is I-1,
        Cantidad_actual is Cantidad_antes + 1, !,
        adyacentes_arriba(I1, J, Muro, Cantidad_actual, Cantidad_desp).
    adyacentes_arriba(_, _, _, Cantidad, Cantidad) :- !.

    adyacentes_abajo(5, _, _, Cantidad, Cantidad) :- !.
    adyacentes_abajo(I, J, Muro, Cantidad_antes, Cantidad_desp) :-
        valor_en(Muro, I, J, 1), I1 is I+1,
        Cantidad_actual is Cantidad_antes + 1, !,
        adyacentes_abajo(I1, J, Muro, Cantidad_actual, Cantidad_desp).
    adyacentes_abajo(_, _, _, Cantidad, Cantidad) :- !.

% llena_linea_patron(No_patron, Linea, LLena, Color).
llena_linea_patron(_, [], 0, ninguno) :- !.
llena_linea_patron(N, [Color, N], 1, Color) :- !.
llena_linea_patron(_, [Color, _], 0, Color) :- !.

% 0-azul, 1-rojo, 2-azul, 3-gris, 4-negro
posicion_del_color_en_Muro(amarillo, 0, 0) :- !.
posicion_del_color_en_Muro(rojo, 0, 1) :- !.
posicion_del_color_en_Muro(azul, 0, 2) :- !.
posicion_del_color_en_Muro(gris, 0, 3) :- !.
posicion_del_color_en_Muro(negro, 0, 4) :- !.
posicion_del_color_en_Muro(Color, Fila, Columna) :-
    posicion_del_color_en_Muro(Color, 0, C1), !,
    Pos is C1 + Fila, Columna is mod(Pos, 5).


% puede_poner_en_patron(No_patron, Patron, Muro, Azulejos, Exceso).
puede_poner_en_patron(No_patron, [Color, Cant_patron], Muro, [Color, Cant_azulejos], Azulejos_sobrantes, Espacio_sobrante) :-
    No_patron > Cant_patron, I is No_patron - 1, 
    posicion_del_color_en_Muro(Color, I, J), 
    valor_en(Muro, I, J, 0), !,
    Espacio is No_patron - Cant_patron, 
    Azulejos_sobrantes is max(0, Cant_azulejos - Espacio),
    Espacio_sobrante is max(0, No_patron - Cant_patron - Cant_azulejos), !.

puede_poner_en_patron(No_patron, [], Muro, [Color, Cant], Azulejos_sobrantes, Espacio_sobrante) :-
    I is No_patron - 1, posicion_del_color_en_Muro(Color, I, J),
    valor_en(Muro, I, J, 0), Azulejos_sobrantes is max(0, Cant - No_patron),
    Espacio_sobrante is max(0, No_patron - Cant), !.

mueve_azulejos_a_linea_de_patron(_, [], [Color, Cant], [Color, Cant]) :- !.
mueve_azulejos_a_linea_de_patron(No_patron, [Color, Cant_patron], [Color, Cant_azulejos], [Color, Cant_desp]) :-
    Cant_desp is Cant_patron + Cant_azulejos.


actualiza_posicion_del_muro(I, J, Muro_viejo, I, J, Muro_nuevo) :-
    valor_en(Muro_viejo, I, J, 0),
    valor_en(Muro_nuevo, I, J, 1), !.

actualiza_posicion_del_muro(I0, J0, Muro_viejo, _, _, Muro_nuevo) :-
    valor_en(Muro_viejo, I0, J0, V),
    valor_en(Muro_nuevo, I0, J0, V).

nuevo_muro(Muro_viejo, I, J, Muro_nuevo) :-
    length(Muro_nuevo, 5), nth0(0, Muro_nuevo, F0), nth0(1, Muro_nuevo, F1),
    nth0(2, Muro_nuevo, F2), nth0(3, Muro_nuevo, F3), nth0(4, Muro_nuevo, F4),
    length(F0, 5), length(F1, 5), length(F2, 5), length(F3, 5), length(F4, 5), 

    actualiza_posicion_del_muro(0, 0, Muro_viejo, I, J, Muro_nuevo),
    actualiza_posicion_del_muro(0, 1, Muro_viejo, I, J, Muro_nuevo), 
    actualiza_posicion_del_muro(0, 2, Muro_viejo, I, J, Muro_nuevo), 
    actualiza_posicion_del_muro(0, 3, Muro_viejo, I, J, Muro_nuevo), 
    actualiza_posicion_del_muro(0, 4, Muro_viejo, I, J, Muro_nuevo),

    actualiza_posicion_del_muro(1, 0, Muro_viejo, I, J, Muro_nuevo), 
    actualiza_posicion_del_muro(1, 1, Muro_viejo, I, J, Muro_nuevo), 
    actualiza_posicion_del_muro(1, 2, Muro_viejo, I, J, Muro_nuevo), 
    actualiza_posicion_del_muro(1, 3, Muro_viejo, I, J, Muro_nuevo), 
    actualiza_posicion_del_muro(1, 4, Muro_viejo, I, J, Muro_nuevo), 
    
    actualiza_posicion_del_muro(2, 0, Muro_viejo, I, J, Muro_nuevo),
    actualiza_posicion_del_muro(2, 1, Muro_viejo, I, J, Muro_nuevo), 
    actualiza_posicion_del_muro(2, 2, Muro_viejo, I, J, Muro_nuevo), 
    actualiza_posicion_del_muro(2, 3, Muro_viejo, I, J, Muro_nuevo), 
    actualiza_posicion_del_muro(2, 4, Muro_viejo, I, J, Muro_nuevo), 
    
    actualiza_posicion_del_muro(3, 0, Muro_viejo, I, J, Muro_nuevo), 
    actualiza_posicion_del_muro(3, 1, Muro_viejo, I, J, Muro_nuevo), 
    actualiza_posicion_del_muro(3, 2, Muro_viejo, I, J, Muro_nuevo), 
    actualiza_posicion_del_muro(3, 3, Muro_viejo, I, J, Muro_nuevo), 
    actualiza_posicion_del_muro(3, 4, Muro_viejo, I, J, Muro_nuevo),
    
    actualiza_posicion_del_muro(4, 0, Muro_viejo, I, J, Muro_nuevo),
    actualiza_posicion_del_muro(4, 1, Muro_viejo, I, J, Muro_nuevo), 
    actualiza_posicion_del_muro(4, 2, Muro_viejo, I, J, Muro_nuevo), 
    actualiza_posicion_del_muro(4, 3, Muro_viejo, I, J, Muro_nuevo), 
    actualiza_posicion_del_muro(4, 4, Muro_viejo, I, J, Muro_nuevo).

actualiza_muro(Jugador, Ronda, I, J) :-
    estado_muro(Jugador, Ronda, Muro_viejo),
    nuevo_muro(Muro_viejo, I, J, Muro_nuevo),
    retract(estado_muro(Jugador, Ronda, Muro_viejo)),
    asserta(estado_muro(Jugador, Ronda, Muro_nuevo)),
    puntua_jugador_ronda(Jugador, Ronda, I, J, P),
    actualiza_puntuacion_adicional(Jugador, Ronda, P).

mover_lineas_de_patron_llenas(Jugador, Ronda) :-
    cant_turnos(Ronda, Turno),
    estado_patrones(Ronda, Turno, Jugador, [P1A, P2A, P3A, P4A, P5A]),
    mover_azulejo_al_muro(Jugador, Ronda, 1, P1A, P1D), 
    mover_azulejo_al_muro(Jugador, Ronda, 2, P2A, P2D), 
    mover_azulejo_al_muro(Jugador, Ronda, 3, P3A, P3D), 
    mover_azulejo_al_muro(Jugador, Ronda, 4, P4A, P4D), 
    mover_azulejo_al_muro(Jugador, Ronda, 5, P5A, P5D),
    actualizar_patrones(Ronda, Turno, Jugador, [P1A, P2A, P3A, P4A, P5A], [P1D, P2D, P3D, P4D, P5D]), !.

actualizar_patrones(No_ronda, No_turno, Jugador, Patrones_antes, Patrones_desp) :- 
    retract(estado_patrones(No_ronda, No_turno, Jugador, Patrones_antes)),
    asserta(estado_patrones(No_ronda, No_turno, Jugador, Patrones_desp)).

mover_azulejo_al_muro(Jugador, Ronda, N, [Color, N], []) :- 
    I is N-1, posicion_del_color_en_Muro(Color, I, J),
    actualiza_muro(Jugador, Ronda, I, J), !.
mover_azulejo_al_muro(_, _, _, P, P).

alicatado_del_muro() :-
    cant_jugadores(Ultimo_jugador),
    cant_rondas(Ronda_actual),
    alicatar(Ultimo_jugador, Ronda_actual),
    retract(cant_rondas(Ronda_actual)),
    Siguiente_ronda is Ronda_actual + 1,
    asserta(cant_rondas(Siguiente_ronda)).

    alicatar(0, _) :- !.
    alicatar(Jugador, Ronda_actual) :-
        mover_lineas_de_patron_llenas(Jugador, Ronda_actual),
        Otro_jugador is Jugador - 1, !,
        alicatar(Otro_jugador, Ronda_actual).

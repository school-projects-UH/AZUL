% La bolsa es una lista de 5 elementos.
% Cada elemento de la lista representa la cantidad de azulejos de un color que hay en la bolsa.
% Los indices de los colores son: 0-amarillo, 1-rojo, 2-azul, 3-gris, 4-negro

% Los jugadores estan enumerados del 1 al 4

% TEST CASE
% estado_muro(1, [[0, 0, 0, 0, 0], [0, 1, 1, 1, 1], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]]).
% estado_muro(2, [[0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]]).
% cant_jugadores(2).
% estado_puntuaciones(1, 0).
% estado_puntuaciones(2, 0).
% cant_rondas(1).
% estado_patrones(1, [[], [negro, 2], [azul, 1], [], []]).
% estado_patrones(2, [[azul, 1], [], [gris, 1], [], []]).
% estado_suelo(1, -3).
% estado_suelo(2, 0).
% estado_tapa_caja([gris]).

% Predicados dinamicos
:- dynamic
   mejor_solucion/4,
   posibles_jugadas/1,
   cant_fabricas/1,
   cant_jugadores/1,
   jugador_inicial/1,
   estado_centro/1,
   estado_tapa_caja/1,
   estado_bolsa/1,
   estado_puntuaciones/2,
   estado_fabricas/1,
   estado_muro/2,
   estado_suelo/2,
   estado_patrones/2,
   cant_rondas/1.

no_fabricas(2, 5).
no_fabricas(3, 7).
no_fabricas(4, 9).

% identificar_jugadores(Cant_jugadores, Lista_identificadores)
identificar_jugadores(2, [1, 2]).
identificar_jugadores(3, [1, 2, 3]).
identificar_jugadores(4, [1, 2, 3, 4]).


llenar_todas_las_fabricas() :-
    write("LLenar_todas_las_fabricas"), nl(),
    estado_fabricas(Fabricas_antes),
    estado_bolsa(Bolsa_antes),
    cant_fabricas(N),
    llena_fabricas(Bolsa_antes, N, Fabricas_antes, Fabricas_despues, Bolsa_despues),

    retract(estado_bolsa(Bolsa_antes)),
    asserta(estado_bolsa(Bolsa_despues)),

    retract(estado_fabricas(Fabricas_antes)),
    asserta(estado_fabricas(Fabricas_despues)).

iniciar_juego(Cant_jugadores) :-
    prepara_partida(Cant_jugadores),
    genera_todas_las_jugadas(),
    jugar(0),
    calcular_todos_los_puntos_adicionales(),
    determinar_ganadores(Ganadores),
    write("Fin de la partida"), nl(),
    imprime_ganadores(Ganadores),
    !.

    imprime_ganadores([G]) :- write("El Ganador es ", G), nl(), !.
    imprime_ganadores(G) :- write("Los Ganadores son ", G), nl(), !.

        % jugar(Termino_la_partida)

        jugar(0) :-
            estado_bolsa(Bolsa),
            length(Bolsa, Cant_Azulejos), Cant_Azulejos > 0,
            prepara_siguiente_ronda(),
            ofertas_de_factoria(),
            write("Alicatando los muros"), nl(),
            alicatado_del_muro(),
            estado_tras_el_alicatado_del_muro(),
            fin_partida(Termina), !,
            jugar(Termina),
            !.

        jugar(1) :- !.

        estado_tras_el_alicatado_del_muro() :-
            cant_jugadores(N),
            estado_del_Jugador(1).
        
        estado_del_Jugador(J) :- cant_jugadores(N), N > J, !.
        estado_del_Jugador(Jugador) :- 
            write_state("Tablero del jugador ", Jugador),
            estado_muro(Jugador, Muro), estado_patrones(Jugador, Patrones), 
            estado_suelo(Jugador, Suelo), estado_puntuaciones(Jugador, Puntuacion),
            write_state("Patrones: ", Patrones),
            write_state("Muro: ", Muro),
            write_state("Suelo: ", Suelo),
            write_state("Puntuacion: ", Puntuacion),
            Siguiente_jugador is Jugador + 1, !, 
            estado_del_Jugador(siguiente_jugador), 
            !.
        

        ofertas_de_factoria():-
            jugador_inicial(JI),
            simula_fase1(JI).


        quedan_azulejos_fabricas([], "NO").
        quedan_azulejos_fabricas([[]|R], Resp):-
            quedan_azulejos_fabricas(R, Resp).
        quedan_azulejos_fabricas(_, "SI").


        simula_fase1(Jugador_inicial):-
            estado_fabricas(Fabricas),
            estado_centro(Centro),
            quedan_azulejos_fabricas([Fabricas|Centro] , "NO").

        simula_fase1(Jugador_inicial):-
            estado_fabricas(Fabricas),
            estado_centro(Centro),
            quedan_azulejos_fabricas([Fabricas|Centro], "SI"),
            simula_turno(Jugador_inicial),
            siguiente_jugador(Jugador_inicial, Sgte),
            simula_fase1(Sgte).


        simula_turno(Jugador):-
            write_state("Juega: ", Jugador),
            itera_por_todas_las_jugadas(Jugador),
            mejor_solucion(F, C, P),
            mueve_azulejos_fabrica_patron(Jugador, F, C, P),
            write_state("Tablero del jugador ", Jugador),
            estado_muro(Jugador, Muro), estado_patrones(Jugador, Patrones), estado_suelo(Jugador, Suelo),
            write_state("Patrones: ", Patrones),
            write_state("Muro: ", Muro),
            write_state("Suelo: ", Suelo).

        prepara_siguiente_ronda() :-

            asserta(estado_centro([])),
            llena_bolsa(),
            asserta(cant_fabricas(3)),
            asserta(estado_fabricas([[], [], []])),
            retract(estado_centro([])),
            asserta(estado_centro([ficha_jugador_inicial])),
            llenar_todas_las_fabricas(),
            write_state(Fabricas), print("FIN").

        write_state(state):-
            open("output.txt",append,Stream),
            write(Stream,state),  nl(Stream),
            close(Stream).

        % TEST CASE para determinar_ganadores
        % cant_jugadores(4).
        % estado_puntuaciones(1, 2).
        % estado_puntuaciones(2, 1).
        % estado_puntuaciones(3, 2).
        % estado_puntuaciones(4, 2).
        % estado_muro(1, [[0, 0, 0, 0, 1], [1, 1, 1, 1, 1], [1, 1, 1, 1, 1], [0, 0, 1, 0, 1], [0, 0, 0, 1, 1]]).
        % estado_muro(2, [[0, 0, 0, 0, 1], [1, 1, 1, 1, 1], [0, 1, 0, 1, 1], [0, 0, 1, 0, 1], [0, 0, 0, 1, 1]]).
        % estado_muro(3, [[0, 0, 0, 0, 1], [1, 1, 1, 1, 1], [0, 1, 0, 1, 1], [0, 0, 1, 0, 1], [0, 0, 0, 1, 1]]).
        % estado_muro(4, [[0, 0, 0, 0, 1], [1, 1, 1, 1, 1], [0, 1, 0, 1, 1], [0, 0, 1, 0, 1], [0, 0, 0, 1, 1]]).

        determinar_ganadores(Ganadores) :-
            cant_jugadores(Cant_jugadores),
            comprobar_puntuaciones(Cant_jugadores, Ganadores), !.

        % actualizar_jugadores_de_puntuacion_maxima(Jugador, PM, Jugadores_de_pt_max_antes, [Jugadores_de_pt_max_desp])
        actualizar_jugadores_de_puntuacion_maxima(Jugador, PM, Jugadores_de_pt_max, [Jugador|Jugadores_de_pt_max]) :-
            estado_puntuaciones(Jugador, PM), !.
        actualizar_jugadores_de_puntuacion_maxima(Jugador, PM, Jugadores_de_pt_max, Jugadores_de_pt_max) :-
            estado_puntuaciones(Jugador, P), P \= PM, !.

        % actualizar_jugadores_con_mas_filas_completas(Jugador, PM, Jugadores_de_pt_max_antes, [Jugadores_de_pt_max_desp])
        actualizar_jugadores_con_mas_filas_completas(Jugador, Puntuacion_max_por_filas, Jugadores_empatados, Jugadores_de_pt_max, [Jugador|Jugadores_de_pt_max]) :-
            estado_muro(Jugador, Muro), member(Jugador, Jugadores_empatados),
            contar_2pts_por_lineas_horizontales(Muro, Puntuacion_max_por_filas), !.
        actualizar_jugadores_con_mas_filas_completas(Jugador, PM, Jugadores_empatados, Jugadores_de_pt_max, Jugadores_de_pt_max) :-
            member(Jugador, Jugadores_empatados), estado_muro(Jugador, Muro),
            contar_2pts_por_lineas_horizontales(Muro, P), P \= PM, !.
        actualizar_jugadores_con_mas_filas_completas(_, _, _, Jugadores_de_pt_max, Jugadores_de_pt_max) :- !.

        comprobar_puntuaciones(2, Ganadores) :-
            estado_puntuaciones(1, P1), estado_puntuaciones(2, P2), PM is max(P1, P2),

            actualizar_jugadores_de_puntuacion_maxima(2, PM, [], JPM1),
            actualizar_jugadores_de_puntuacion_maxima(1, PM, JPM1, Ganadores),

            length(Ganadores, 1), !.

        comprobar_puntuaciones(2, Ganadores) :-
            estado_puntuaciones(1, P1), estado_puntuaciones(2, P2), PM is max(P1, P2),

            actualizar_jugadores_de_puntuacion_maxima(2, PM, [], JPM1),
            actualizar_jugadores_de_puntuacion_maxima(1, PM, JPM1, JPM),

            estado_muro(1, M1), contar_2pts_por_lineas_horizontales(M1, PF1),
            estado_muro(2, M2), contar_2pts_por_lineas_horizontales(M2, PF2),

            PFM is max(PF1, PF2),

            actualizar_jugadores_con_mas_filas_completas(2, PFM, JPM, [], G1),
            actualizar_jugadores_con_mas_filas_completas(1, PFM, JPM, G1, Ganadores),

            length(Ganadores, L), L < 3, !.



        comprobar_puntuaciones(3, Ganadores) :-
            estado_puntuaciones(1, P1), estado_puntuaciones(2, P2),
            estado_puntuaciones(3, P3), PM1 is max(P1, P2), PM is max(PM1, P3),

            actualizar_jugadores_de_puntuacion_maxima(3, PM, [], JPM1),
            actualizar_jugadores_de_puntuacion_maxima(2, PM, JPM1, JPM2),
            actualizar_jugadores_de_puntuacion_maxima(1, PM, JPM2, Ganadores),

            length(Ganadores, 1), !.

        comprobar_puntuaciones(3, Ganadores) :-
            estado_puntuaciones(1, P1), estado_puntuaciones(2, P2),
            estado_puntuaciones(3, P3), PM1 is max(P1, P2), PM is max(PM1, P3),

            actualizar_jugadores_de_puntuacion_maxima(3, PM, [], JPM1),
            actualizar_jugadores_de_puntuacion_maxima(2, PM, JPM1, JPM2),
            actualizar_jugadores_de_puntuacion_maxima(1, PM, JPM2, JPM),

            estado_muro(1, M1), contar_2pts_por_lineas_horizontales(M1, PF1),
            estado_muro(2, M2), contar_2pts_por_lineas_horizontales(M2, PF2),
            estado_muro(3, M3), contar_2pts_por_lineas_horizontales(M3, PF3),

            PFM1 is max(PF1, PF2), PFM is max(PFM1, PF3),

            actualizar_jugadores_con_mas_filas_completas(3, PFM, JPM, [], G1),
            actualizar_jugadores_con_mas_filas_completas(2, PFM, JPM, G1, G2),
            actualizar_jugadores_con_mas_filas_completas(1, PFM, JPM, G2, Ganadores),

            length(Ganadores, L), L < 4, !.

        comprobar_puntuaciones(4, Ganadores) :-
            estado_puntuaciones(1, P1), estado_puntuaciones(2, P2),
            estado_puntuaciones(3, P3), estado_puntuaciones(4, P4),
            PM1 is max(P1, P2), PM2 is max(PM1, P3), PM is max(PM2, P4),

            actualizar_jugadores_de_puntuacion_maxima(4, PM, [], JPM1),
            actualizar_jugadores_de_puntuacion_maxima(3, PM, JPM1, JPM2),
            actualizar_jugadores_de_puntuacion_maxima(2, PM, JPM2, JPM3),
            actualizar_jugadores_de_puntuacion_maxima(1, PM, JPM3, Ganadores),

            length(Ganadores, 1), !.

        comprobar_puntuaciones(4, Ganadores) :-
            estado_puntuaciones(1, P1), estado_puntuaciones(2, P2),
            estado_puntuaciones(3, P3), estado_puntuaciones(4, P4),
            PM1 is max(P1, P2), PM2 is max(PM1, P3), PM is max(PM2, P4),

            actualizar_jugadores_de_puntuacion_maxima(4, PM, [], JPM1),
            actualizar_jugadores_de_puntuacion_maxima(3, PM, JPM1, JPM2),
            actualizar_jugadores_de_puntuacion_maxima(2, PM, JPM2, JPM3),
            actualizar_jugadores_de_puntuacion_maxima(1, PM, JPM3, JPM),

            estado_muro(1, M1), contar_2pts_por_lineas_horizontales(M1, PF1),
            estado_muro(2, M2), contar_2pts_por_lineas_horizontales(M2, PF2),
            estado_muro(3, M3), contar_2pts_por_lineas_horizontales(M3, PF3),
            estado_muro(4, M4), contar_2pts_por_lineas_horizontales(M4, PF4),

            PFM1 is max(PF1, PF2), PFM2 is max(PFM1, PF3), PFM is max(PFM2, PF4),

            actualizar_jugadores_con_mas_filas_completas(4, PFM, JPM, [], G1),
            actualizar_jugadores_con_mas_filas_completas(3, PFM, JPM, G1, G2),
            actualizar_jugadores_con_mas_filas_completas(2, PFM, JPM, G2, G3),
            actualizar_jugadores_con_mas_filas_completas(1, PFM, JPM, G3, Ganadores),

            length(Ganadores, L), L < 5, !.


% decidir el jugador inicial

decidir_jugador_inicial(Jugadores, Jugador_escogido):-
    length(Jugadores, N),
    random(0, N, X),
    nth0(X, Jugadores, Jugador_escogido).


% inicializar los estados del juego
no_fabricas(2, 5).
no_fabricas(3, 7).
no_fabricas(4, 9).

prepara_partida(N):-
    identificar_jugadores(N, Jugadores),
    no_fabricas(N, CF),
    asserta(cant_jugadores(N)),
    asserta(cant_fabricas(CF)),
    llena_bolsa(),
    inicializar_puntuaciones(Jugadores),
    inicializar_fabricas(Fabricas),
    asserta(estado_fabricas(Fabricas)),
    inicializar_muros(Jugadores),
    inicializar_suelos(Jugadores),
    inicializar_patrones(Jugadores),
    decidir_jugador_inicial(Jugadores, JI),
    asserta(jugador_inicial(JI)),

    % Inicializando predicados dinamicos faltantes
    asserta(estado_centro([])),
    asserta(estado_tapa_caja([])),
    asserta(posibles_jugadas([])),
    asserta(cant_rondas(1)).


    inicializar_puntuaciones([]).
    inicializar_puntuaciones([J|Rest_Jugadores]):-
        asserta(estado_puntuaciones(J, 0)),
        inicializar_puntuaciones(Rest_Jugadores).

    inicializar_fabricas([]).
    inicializar_fabricas([[]|Rest_Fabricas]):-
        inicializar_fabricas(Rest_Fabricas).

    inicializar_muros([]).
    inicializar_muros([J| Rest_jugadores]):-
        asserta(estado_muro(J, [[0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]])),
        inicializar_muros(Rest_jugadores).

    inicializar_suelos([]).
    inicializar_suelos([J| Rest_jugadores]):-
        asserta(estado_suelo(J, 0)),
        inicializar_suelos(Rest_jugadores).

    inicializar_patrones([]).
    inicializar_patrones([J| Rest_jugadores]):-
        asserta(estado_patrones(J, [[], [], [], [], []])),
        inicializar_patrones(Rest_jugadores).


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

llena_fabricas(Bolsa_antes, N, Fabricas_antes, Fabricas_despues, Bolsa_despues):-
    write("llena_fabricas"), nl(),
    llena_fabricas_(Bolsa_antes, N, [], Fabricas_despues, Bolsa_despues).

    llena_fabricas_(Bolsa_antes, 0, Fabricas_antes, Fabricas_antes, Bolsa_antes).
    llena_fabricas_(Bolsa_antes, N, Fabricas_antes, Fabricas_despues, Bolsa_despues):-
        write("llena_fabricas_"), write(N), write(Fabricas_antes), nl(),
        extrae_4_azulejos_bolsa(Bolsa_antes, Azulejos_escogidos, Bolsa_intermedia),
        M is N - 1,
        llena_fabricas_(Bolsa_intermedia, M, [Azulejos_escogidos|Fabricas_antes], Fabricas_despues, Bolsa_despues).


mueve_azulejos_fabrica_centro(Fabrica, Centro_antes, Centro_despues)
    :- append(Centro_antes, Fabrica, Centro_despues).


mueve_azulejos_tapa_bolsa():-
    estado_tapa_caja(Tapa),
    retract(estado_tapa_caja(Tapa)),
    asserta(estado_tapa_caja([])),
    estado_bolsa(Bolsa),
    retract(estado_bolsa(Bolsa)),
    append(Bolsa, Tapa, Nueva_bolsa),
    asserta(estado_bolsa(Nueva_bolsa)).


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
    write("llena_bolsa"), nl(),
    llena_bolsa_(Bolsa),
    print(""), print(Bolsa), nl(),
    asserta(estado_bolsa(Bolsa)).

    llena_bolsa_(Bolsa):-
        llena_bolsa_color_([], azul, 20, B1),
        llena_bolsa_color_(B1, rojo, 20, B2),
        llena_bolsa_color_(B2, amarillo, 20, B3),
        llena_bolsa_color_(B3, gris, 20, B4),
        llena_bolsa_color_(B4, negro, 20, Bolsa).

    llena_bolsa_color_(Bolsa_antes, _, 0, Bolsa_antes).
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

actualiza_puntuacion_adicional(Jugador, Puntuacion_adicional) :-
    estado_puntuaciones(Jugador, Puntuacion_actual),
    Puntuacion_final is max(0, Puntuacion_actual + Puntuacion_adicional),
    retract(estado_puntuaciones(Jugador, Puntuacion_actual)),
    asserta(estado_puntuaciones(Jugador, Puntuacion_final)).

puntua_adicional(Jugador, Puntuacion_adicional) :-
    estado_muro(Jugador, Muro),
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
    calcular_puntos_adicionales(Ultimo_jugador).

    calcular_puntos_adicionales(0) :- !.
    calcular_puntos_adicionales(Jugador) :-
        puntua_adicional(Jugador, Puntuacion_adicional),
        actualiza_puntuacion_adicional(Jugador, Puntuacion_adicional),
        Otro_jugador is Jugador - 1, !,
        calcular_puntos_adicionales(Otro_jugador).

% Comprobar si la partida finalizó
% TEST CASE
% cant_jugadores(3).
% estado_puntuaciones(1, 2).
% estado_puntuaciones(2, 1).
% estado_puntuaciones(3, 2).
% estado_puntuaciones(4, 2).
% estado_muro(1, [[0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]]).
% estado_muro(1, [[0, 0, 0, 0, 1], [1, 1, 0, 1, 1], [1, 0, 1, 1, 1], [0, 0, 1, 0, 1], [0, 0, 0, 1, 1]]).
% estado_muro(2, [[0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]]).
% estado_muro(3, [[0, 0, 0, 0, 1], [1, 1, 1, 1, 1], [0, 1, 0, 1, 1], [0, 0, 1, 0, 1], [0, 0, 0, 1, 1]]).
% estado_muro(3, [[0, 0, 0, 0, 1], [1, 1, 0, 1, 1], [0, 1, 0, 1, 1], [0, 0, 1, 0, 1], [0, 0, 0, 1, 1]]).
% estado_muro(3, [[0, 0, 0, 0, 1], [1, 1, 0, 1, 1], [0, 1, 0, 1, 1], [0, 0, 1, 0, 1], [0, 0, 0, 1, 1]]).
% estado_bolsa([]).
% estado_tapa_caja([]).

fin_partida(T2) :-
    cant_jugadores(Ultimo_jugador),
    comprobar_filas(Ultimo_jugador, 0, T1),
    comprobar_cantidad_azuelejos(T2), Termina is max(T1, T2).

    comprobar_filas(0, _, 0) :- !.
    comprobar_filas(Jugador, 0, Termina) :-
        estado_muro(Jugador, Muro),
        contar_2pts_por_lineas_horizontales(Muro, Puntos),
        Otro_jugador is Jugador - 1, !,
        comprobar_filas(Otro_jugador, Puntos, Termina).
    comprobar_filas(_, _, 1) :- !.

    comprobar_cantidad_azuelejos(1) :-
        estado_bolsa(Bolsa), length(Bolsa, 0),
        estado_tapa_caja(Tapa), length(Tapa, 0), !.

    comprobar_cantidad_azuelejos(0) :-
        estado_bolsa(Bolsa), length(Bolsa, CB),
        estado_tapa_caja(Tapa), length(Tapa, CT),
        Cant is CB + CT, Cant > 0, !.


% Puntuación por ronda
puntua_jugador_ronda(Jugador, I, J, Puntuacion) :-
    estado_muro(Jugador, Muro),
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

mueve_azulejos_a_linea_de_patron([], [Color, Cant], [Color, Cant]) :- !.
mueve_azulejos_a_linea_de_patron([Color, Cant_patron], [Color, Cant_azulejos], [Color, Cant_desp]) :-
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

actualiza_muro(Jugador, I, J) :-
    estado_muro(Jugador, Muro_viejo),
    nuevo_muro(Muro_viejo, I, J, Muro_nuevo),
    retract(estado_muro(Jugador, Muro_viejo)),
    asserta(estado_muro(Jugador, Muro_nuevo)),
    puntua_jugador_ronda(Jugador, I, J, P),
    actualiza_puntuacion_adicional(Jugador, P).

mover_lineas_de_patron_llenas(Jugador) :-
    estado_patrones(Jugador, [P1A, P2A, P3A, P4A, P5A]),
    mover_azulejo_al_muro(Jugador, 1, P1A, P1D),
    mover_azulejo_al_muro(Jugador, 2, P2A, P2D),
    mover_azulejo_al_muro(Jugador, 3, P3A, P3D),
    mover_azulejo_al_muro(Jugador, 4, P4A, P4D),
    mover_azulejo_al_muro(Jugador, 5, P5A, P5D),
    actualizar_patrones(Jugador, [P1A, P2A, P3A, P4A, P5A], [P1D, P2D, P3D, P4D, P5D]), !.

mueve_azulejos_patron_tapa(1, _) :- !.
mueve_azulejos_patron_tapa(2, [Color, 2]) :-
    estado_tapa_caja(Tapa),
    retract(estado_tapa_caja(Tapa)),
    asserta(estado_tapa_caja([Color|Tapa])), !.

mueve_azulejos_patron_tapa(3, [Color, 3]) :-
    estado_tapa_caja(Tapa),
    retract(estado_tapa_caja(Tapa)),
    asserta(estado_tapa_caja([Color, Color|Tapa])), !.

mueve_azulejos_patron_tapa(4, [Color, 4]) :-
    estado_tapa_caja(Tapa),
    retract(estado_tapa_caja(Tapa)),
    asserta(estado_tapa_caja([Color, Color, Color|Tapa])), !.

mueve_azulejos_patron_tapa(5, [Color, 5]) :-
    estado_tapa_caja(Tapa),
    retract(estado_tapa_caja(Tapa)),
    asserta(estado_tapa_caja([Color, Color, Color, Color|Tapa])), !.


actualizar_patrones(Jugador, Patrones_antes, Patrones_desp) :-
    retract(estado_patrones(Jugador, Patrones_antes)),
    asserta(estado_patrones(Jugador, Patrones_desp)).

mover_azulejo_al_muro(Jugador, N, [Color, N], []) :-
    I is N-1, posicion_del_color_en_Muro(Color, I, J),
    actualiza_muro(Jugador, I, J),
    mueve_azulejos_patron_tapa(N, [Color, N]), !.

mover_azulejo_al_muro(_, _, P, P).

alicatado_del_muro() :-
    cant_jugadores(Ultimo_jugador),
    alicatar(Ultimo_jugador),
    retract(cant_rondas(Ronda_actual)),
    Siguiente_ronda is Ronda_actual + 1,
    asserta(cant_rondas(Siguiente_ronda)).

    alicatar(0) :- !.
    alicatar(Jugador) :-
        mover_lineas_de_patron_llenas(Jugador),
        resta_azulejos_suelo(Jugador),
        Otro_jugador is Jugador - 1, !,
        alicatar(Otro_jugador).

    resta_azulejos_suelo(Jugador) :-
        estado_suelo(Jugador, Puntos_negativos),
        actualiza_puntuacion_adicional(Jugador, Puntos_negativos),
        retract(estado_suelo(Jugador, Puntos_negativos)),
        asserta(estado_suelo(Jugador, 0)), !.

% dada una fabrica, cuenta el numero de azulejos que hay de un color determinado

numero_azulejos_fabrica(Fabrica, Color, Total):- numero_azulejos_fabrica(Fabrica, Color, 0, Total).
numero_azulejos_fabrica([], _, Cantidad, Cantidad).
numero_azulejos_fabrica( [Color|R], Color, Cantidad, Total):-
    Nueva_cantidad is Cantidad + 1,
    numero_azulejos_fabrica(R, Color, Nueva_cantidad, Total).
numero_azulejos_fabrica( [_|R], Color, Cantidad, Total):-
    numero_azulejos_fabrica(R, Color, Cantidad, Total).


actualiza_solucion(F, C, P, AD):-
    mejor_solucion(BF, BC, BP, BAD),
    retract(mejor_solucion(BF, BC, BP, BAD)),
    actualiza_solucion_(F, C, P, AD, BF, BC, BP, BAD).

    actualiza_solucion_(F1, C1, P1, AD1, _, _, _, AD2):-
        AD1 is min(AD1, AD2),
        asserta(mejor_solucion(F1, C1, P1, AD1)).
    actualiza_solucion_(_, _, _, AD1, F2, C2, P2, AD2):-
        AD2 is min(AD1, AD2),
        asserta(mejor_solucion(F2, C2, P2, AD2)).


genera_todas_las_jugadas():-

    cant_fabricas(CF),
    asserta(posibles_jugadas([])),
    Fabricas_y_centro is CF + 1,
    a(Fabricas_y_centro).

    a(0).
    a(N):-
        b(N, 5),
        M is N - 1,
        a(M).

    b(_, 0).
    b(F, N):-
        c(F, N, 5),
        M is N - 1,
        b(F, M).

    c(_, _, 0).
    c(F, C, N):-
        posibles_jugadas(L),
        retract(posibles_jugadas(L)),
        asserta(posibles_jugadas([[F, C, N]|L])),
        M is N - 1,
        c(F, C, M).

color(1, rojo).
color(2, azul).
color(3, amarillo).
color(4, gris).
color(5, negro).

 itera_por_todas_las_jugadas(Jugador):-
    posibles_jugadas(L),
    asserta(mejor_solucion(1,1,1,1000)),
    estado_patrones(Jugador, Patrones),
    estado_fabricas(Fabricas),
    estado_muro(Jugador, Muro),

    itera(L, Fabricas, Patrones, Muro).

    itera([], _, _, _).
    itera([[F, C, P]|R], Fabricas, Patrones, Muro):-
        nth1(F, Fabricas, Fabrica),
        color(C, Color),
        nth1(P, Patrones, Patron),
        numero_azulejos_fabrica(Fabrica, Color, 0, Total), Total > 0,
        puede_poner_en_patron(P, Patron, Muro, [Color, 1], _, _),
        puede_poner_en_patron(P, Patron, Muro, [Color, Total], Azulejos_sobrantes1, Espacio_sobrante1),
        Dif is Azulejos_sobrantes1 - Espacio_sobrante1,
        AD is abs(Dif),
        actualiza_solucion(F, C, P, AD),
        itera(R, Fabricas, Patrones, Muro).

    itera([[F, C, P]|R], Fabricas, Patrones, Muro):-
         nth1(F, Fabricas, Fabrica),
         color(C, Color),
         nth1(P, Patrones, _),
         numero_azulejos_fabrica(Fabrica, Color, 0, 0),
         itera(R, Fabricas, Patrones, Muro).

    itera([[F, C, P]|R], Fabricas, Patrones, Muro):-
         nth1(F, Fabricas, Fabrica),
         color(C, Color),
         nth1(P, Patrones, Patron),
         numero_azulejos_fabrica(Fabrica, Color, 0, Total), Total > 0,
         not(puede_poner_en_patron(P, Patron, Muro, [Color, 1], _, _)),
         itera(R, Fabricas, Patrones, Muro).



reemplazar([_|T], 0, X, [X|T]).
reemplazar([H|T], I, X, [H|R]):- I > 0, I1 is I-1, reemplazar(T, I1, X, R).


mueve_azulejos_fabrica_patron(Jugador, Id_Fabrica, Color, No_patron):-
    cant_fabricas(CF),
    Id_centro is CF + 1,
    Id_Fabrica < Id_centro,
    estado_fabricas(Fabricas),
    nth1(Id_Fabrica, Fabricas, Fabrica),
    numero_azulejos_fabrica(Fabrica, Color, Cantidad),
    extrae_todos_azulejos_fabrica(Fabrica, Color, Fabrica_modificada),
    Id is Id_Fabrica - 1,
    reemplazar(Fabricas, Id , Fabrica_modificada, Nuevas_fabricas),
    retract(estado_fabricas(Fabricas)),
    asserta(estado_fabricas(Nuevas_fabricas)),
    coloca_azulejos_patron(Jugador, No_patron, Color, Cantidad).


mueve_azulejos_fabrica_patron(Jugador, Id_Fabrica, Color, No_patron):-
    cant_fabricas(CF),
    Id_fabrica is CF + 1,
    estado_centro(Centro_mesa),
    member(ficha_jugador_inicial, Centro_mesa),
    asserta(jugador_inicial(Jugador)),
    delete(Centro_mesa, ficha_jugador_inicial, Centro_mesa_A),
    actualiza_suelo(Jugador, 1, _),
    numero_azulejos_fabrica(Centro_mesa, Color, Cantidad),
    extrae_todos_azulejos_fabrica(Centro_mesa_A, Color, Centro_mesa_despues),
    retract(estado_centro(Centro_mesa)),
    asserta(estado_centro(Centro_mesa_despues)),
    coloca_azulejos_patron(Jugador, No_patron, Color, Cantidad).


mueve_azulejos_fabrica_patron(Jugador, Id_Fabrica, Color, No_patron):-
    cant_fabricas(CF),
    Id_fabrica is CF + 1,
    estado_centro(Centro_mesa),
    numero_azulejos_fabrica(Centro_mesa, Color, Cantidad),
    extrae_todos_azulejos_fabrica(Centro_mesa, Color, Centro_mesa_despues),
    retract(estado_centro(Centro_mesa)),
    asserta(estado_centro(Centro_mesa_despues)),
    coloca_azulejos_patron(Jugador, No_patron, Color, Cantidad).


coloca_azulejos_patron(Jugador, No_patron, Color, Cantidad):-
    estado_patrones(Jugador, Patrones),
    estado_muro(Jugador, Muro),
    nth1(No_patron, Patrones, Patron),
    puede_poner_en_patron(No_patron, Patron, Muro, [Color, Cantidad], AS, _),
    Cantidad_a_poner is Cantidad - AS,
    mueve_azulejos_a_linea_de_patron(Patron, [Color, Cantidad_a_poner], Patron_modificado),
    reemplaza_un_patron(Jugador, No_patron, Patron_modificado),
    actualiza_suelo(Jugador, AS, _),
    llena_tapa_caja_color(Color, AS).


reemplaza_un_patron(Jugador, 1, PR):-
    retract(estado_patrones(Jugador, [_, P2, P3, P4, P5])),
    asserta(estado_patrones(Jugador, [PR, P2, P3, P4, P5])).
reemplaza_un_patron(Jugador, 2, PR):-
    retract(estado_patrones(Jugador, [P1, _, P3, P4, P5])),
    asserta(estado_patrones(Jugador, [P1, PR, P3, P4, P5])).
reemplaza_un_patron(Jugador, 3, PR):-
    retract(estado_patrones(Jugador, [P1, P2, _, P4, P5])),
    asserta(estado_patrones(Jugador, [P1, P2, PR, P4, P5])).
reemplaza_un_patron(Jugador, 4, PR):-
    retract(estado_patrones(Jugador, [P1, P2, P3, _, P5])),
    asserta(estado_patrones(Jugador, [P1, P2, P3, PR, P5])).
reemplaza_un_patron(Jugador, 5, PR):-
    retract(estado_patrones(Jugador, [P1, P2, P3, P4, _])),
    asserta(estado_patrones(Jugador, [P1, P2, P3, P4, PR])).

actualiza_suelo(Jugador, Cantidad, 0):-
    estado_suelo(Jugador, S),
    Suma is abs(S) + Cantidad,
    Suma < 15,
    retract(estado_suelo(Jugador, S)),
    Suma_Neg is -Suma,
    asserta(estado_suelo(Jugador, Suma_Neg)).

actualiza_suelo(Jugador, Cantidad, Resto):-
    estado_suelo(Jugador, S),
    Suma is abs(S) + Cantidad,
    Suma > 14,
    retract(estado_suelo(Jugador, S)),
    N is -14,
    asserta(estado_suelo(Jugador, N)),
    Resto is Cantidad - (14 - abs(S)).

llena_tapa_caja_color(Color, Cantidad):-
    estado_tapa_caja(Tapa_caja),
    llena_bolsa_color_(Tapa_caja, Color, Cantidad, Tapa_despues),
    retract(estado_tapa_caja(Tapa_caja)),
    asserta(estado_tapa_caja(Tapa_despues)).

% siguiente_jugador(Jugador_actual, Jugador_siguiente)
siguiente_jugador(1, 2).
siguiente_jugador(2, 3) :- cant_jugadores(C), C > 2.
siguiente_jugador(2, 1) :- cant_jugadores(2).
siguiente_jugador(3, 4) :- cant_jugadores(4).
siguiente_jugador(3, 1) :- cant_jugadores(3).
siguiente_jugador(4, 1).

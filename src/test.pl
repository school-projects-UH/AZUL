valor_en(Muro, I, J, Valor) :-
    Im is mod(I,5), Jm is mod(J,5),
    nth0(Im, Muro, Linea),
    nth0(Jm, Linea, Valor).

columna(J, Muro, [V0, V1, V2, V3, V4]) :-
    Jm is mod(J, 5),
    valor_en(Muro, 0, J, V0), valor_en(Muro, 1, J, V1),
    valor_en(Muro, 2, J, V2), valor_en(Muro, 3, J, V3),
    valor_en(Muro, 4, J, V4).

colores_iguales_en_muro(I0, J0, Muro, [V0, V1, V2, V3, V4]) :-
    valor_en(Muro, I0, J0, V0), I1 is I0+1, J1 is J0+1,
    valor_en(Muro, I1, J1, V1), I2 is I0+2, J2 is J0+2,
    valor_en(Muro, I2, J2, V2), I3 is I0+3, J3 is J0+3,
    valor_en(Muro, I3, J3, V3), I4 is I0+4, J4 is J0+4,
    valor_en(Muro, I4, J4, V4).
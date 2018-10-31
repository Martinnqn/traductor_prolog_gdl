:- module(trad_gdl,_,_).
%:- use_module(library(pce_xref)).
%package showtrans para visualizar la traduccion del programa cuando es compilado.
:- use_package(show_trans).
%package para traducir el programa.
:- use_package(.(meta_trans)).

%en este archivo tiene que ir el codigo prolog para traducir a gdl


%%%%codigo de ejemplo%%%%%
init(control(x)).

%posibles valores que pueden tener las relaciones
base(cell(X,Y,b)) :- 
  index(X),
  index(Y).

base(cell(X,Y,p)) :- 
  index(X),
  index(Y).

base(cell(X,Y,rol)) :- 
  role(R),
  index(X),
  index(Y).

base(cell(X,Y,pelota(R,P,XV,YV))) :- 
  role(R),
  pelota(P),
  index(X),
  index(Y),
  velocidad(XV),
  velocidad(YV).

base(cell(X,Y,golpeado(R))) :- 
  role(R),
  index(X),
  index(Y).

base(pelotas(R,C)) :-
  role(R),
  count_pelota(C).

base(control(R)) :- 
  role(R).

velocidad(0).
velocidad(1).
velocidad(-1).

%posibles valores que pueden tener las entradas
input(R,lanzar(X,Y)) :- 
  role(R),
  index(X),
  index(Y).

input(R,mover(X,Y)) :- 
  role(R),
  index(X),
  index(Y).

input(R,nada) :- 
  role(R).

%movimientos legales
legal(R,lanzar(X,Y)) :- 
  t(control(R)),
  (t(cell(X,Y,b));t(cell(X,Y,rol(_R1)))),
  \+(posicion_futura(_R,_P,X,Y)),
  t(cell(X1,Y1,rol(R))),
  adyacente(X,Y,X1,Y1),
  t(pelotas(R,C)),
  C > 0.

legal(R,mover(X,Y)) :- 
  t(control(R)),
  t(cell(X,Y,pelota(_R1,_P,_XV,_YV))),
  t(cell(X1,Y1,rol(R))),
  adyacente(X,Y,X1,Y1).

legal(R,mover(X,Y)) :- 
  t(control(R)),
  t(cell(X,Y,b)),
  t(cell(X1,Y1,rol(R))),
  adyacente(X,Y,X1,Y1).

legal(_R,nada).

adyacente(X1,Y1,X2,Y2) :-
  ((X1 is X2+1; X1 is X2-1),(Y1 is Y2+1; Y1 is Y2-1));
  ((X1 is X2),(Y1 is Y2+1; Y1 is Y2-1));
  ((X1 is X2+1; X1 is X2-1),(Y1 is Y2)).

%prÃ³ximo estado
%celdas con paredes
next(cell(X,Y,p)) :- 
  t(cell(X,Y,p)).

%celdas con jugador golpeado
%si se mueve hacia una pelota enemiga
next(cell(X,Y,golpeado(R))) :-
  role(R),
  does(R,mover(X,Y)),
  posicion_futura(E,_P,X,Y),
  E \== R,
  \+colision(X,Y).

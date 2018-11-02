:- module(trad_gdl,_,_).
%:- use_module(library(pce_xref)).
%package showtrans para visualizar la traduccion del programa cuando es compilado.
:- use_package(show_trans).
%package para traducir el programa.
:- use_package(.(meta_trans)).

%para ejecutar ?-inicio,juego. (Run!)

%roles o y x
role(o).
role(x).

%estado inicial
init(cell(1,1,b)).
init(cell(1,2,b)).
init(cell(1,3,b)).
init(cell(2,1,b)).
init(cell(2,2,b)).
init(cell(2,3,b)).
init(cell(3,1,b)).
init(cell(3,2,b)).
init(cell(3,3,b)).
init(control(o)).

%posibles valores que pueden tener las relaciones
base(control(X)):- role(X).
base(cell(X,Y,b)):- index(X),index(Y).
base(cell(X,Y,R)):- role(R),index(X),index(Y).

index(1).
index(2).
index(3).

%posibles valores que pueden tener las entradas
input(R,mark(X,Y)):- role(R),index(X),index(Y).
input(R,noop):-role(R).

%movimientos legales
legal(W,mark(X,Y)) :-
	t(cell(X,Y,b)),t(control(W)).
legal(o,noop) :-
	t(control(x)).
legal(x,noop) :-
      t(control(o)).

%próximo estado
next(cell(M,N,x)) :-
      does(x,mark(M,N)),
      t(cell(M,N,b)).

next(cell(M,N,o)) :-
      does(o,mark(M,N)),
      t(cell(M,N,b)).

next(cell(M,N,W)) :-
      t(cell(M,N,W)),
      distinct(W,b).

next(cell(M,N,b)) :-
      does(_W,mark(J,_K)),
      t(cell(M,N,b)),
      distinct(M,J).

next(cell(M,N,b)) :-
      does(_W,mark(_J,K)),
      t(cell(M,N,b)),
      distinct(N,K).

next(control(o)) :-
      t(control(x)).

next(control(x)) :-
      t(control(o)).

%Cambiamos las reglas pierde el que hace TATETI
%goal(x,100) :- line(x),\+line(o).
%goal(x,50) :-  \+line(x), \+line(o).
%goal(x,0) :- \+line(x), line(o).

%goal(o,100) :- \+line(x), line(o).
%goal(o,50) :- \+line(x), \+line(o).
%goal(o,0) :- line(x), \+line(o).

goal(x,0) :- line(x),\+line(o).
goal(x,50) :-  \+line(x), \+line(o).
goal(x,100) :- \+line(x), line(o).

goal(o,0) :- \+line(x), line(o).
goal(o,50) :- \+line(x), \+line(o).
goal(o,100) :- line(x), \+line(o).


line(Z) :- row(_M,Z).
    line(Z) :- column(_M,Z).
    line(Z) :- diagonal(Z).

    row(M,Z) :-
      t(cell(M,1,Z)) ,
      t(cell(M,2,Z)) ,
      t(cell(M,3,Z)).

    column(_M,Z) :-
      t(cell(1,N,Z)) ,
      t(cell(2,N,Z)) ,
      t(cell(3,N,Z)).

    diagonal(Z) :-
      t(cell(1,1,Z)) ,
      t(cell(2,2,Z)) ,
      t(cell(3,3,Z)).

    diagonal(Z) :-
      t(cell(1,3,Z)) ,
      t(cell(2,2,Z)) ,
      t(cell(3,1,Z)).

 terminal :- line(x).
 terminal :- line(o).
 terminal :- \+open.

 open :- t(cell(X,Y,b)),
 index(X),
 index(Y).
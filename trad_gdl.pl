:- module(trad_gdl,_,_).
%:- use_module(library(pce_xref)).
%package showtrans para visualizar la traduccion del programa cuando es compilado.
:- use_package(show_trans).
%package para traducir el programa.
:- use_package(.(meta_trans)).

%roles azul y rojo
role(o).
role(x).

%marca del owner
owner(o,0).
owner(x,*).

%posiciones iniciales de los roles
initPos(o,1,Col):-
	cols(Cols),
	middlePoint(1,Cols,Col).
initPos(x,Rows,Col):-
	rows(Rows),
	cols(Cols),
	middlePoint(1,Cols,Col).

%role inicial
initRole(x).

%cantidad de filas y columnas
rows(9).
cols(9).

%puntaje con el que se gana
goalScore(Score):-
	rows(Rows),
	cols(Cols),
	Score is Rows * Cols * 5.

%define dinamicamente los indexX segun cuantas rows hay
defineIndexX:-
	rows(Rows),
	between(1,Rows,X),
	assert(indexX(X)),
	fail.
defineIndexX.

%define dinamicamente los indexY segun cuantas cols hay
defineIndexY:-
	cols(Cols),
	between(1,Cols,Y),
	assert(indexY(Y)),
	fail.
defineIndexY.

middlePoint(X,X1,Average):- 
    Sum is X + X1,
    Average is truncate(Sum / 2).
	
%estado inicial
init(cell(X,Y,R)):-initPos(R,X,Y),indexXY(X,Y).
init(cell(X,Y,b)):-indexXY(X,Y),\+initPos(_,X,Y).
init(control(R)):-initRole(R).
init(score(R,0)):-role(R).


%posibles valores que pueden tener las relaciones
base(control(X)):- role(X).
base(cell(X,Y,b)):- indexXY(X,Y).
base(cell(X,Y,R)):- role(R),indexXY(X,Y).
base(cell(X,Y,O)):- owner(_,O),indexXY(X,Y).

%posibles valores que pueden tener las entradas
input(R,noop):-role(R).
input(R,up):-role(R).
input(R,down):-role(R).
input(R,left):-role(R).
input(R,right):-role(R).

%movimientos legales
legal(R,noop):-
	role(R),	%se pone para que instancie R
	\+t(control(R)).
legal(R,up):-
	t(control(R)),
	t(cell(Row,Col,R)),
	NewRow is Row - 1,
	legalMove(NewRow,Col).
legal(R,down):-
	t(control(R)),
	t(cell(Row,Col,R)),
	NewRow is Row + 1,
	legalMove(NewRow,Col).
legal(R,left):-
	t(control(R)),
	t(cell(Row,Col,R)),
	NewCol is Col - 1,
	legalMove(Row,NewCol).
legal(R,right):-
	t(control(R)),
	t(cell(Row,Col,R)),
	NewCol is Col + 1,
	legalMove(Row,NewCol).
	
legalMove(X,Y):-	%verifica que el movimiento no lo deje donde esta otro jugador
	indexXY(X,Y),
	t(cell(X,Y,R)),
	\+role(R).

%próximo estado
next(_):-
	t(control(R)),
	searchFigure(R),
	fail.
	
%se asigna el role a la siguiente celda
next(cell(NewX,NewY,R)):-
	does(R,Act),
	t(cell(X,Y,R)),
	move(X,Y,Act,NewX,NewY).

%marca la casilla que dejo el role
next(cell(X,Y,Own)):-
	does(R,Act),
	changePos(Act),
	t(cell(X,Y,R)),
	owner(R,Own).
	
%marca las celdas que estan dentro del perimetro
next(cell(X,Y,Own)):-
	t(cell(X,Y,C)),
	\+role(C),
	isInArea(X,Y),
	t(control(R)),
	owner(R,Own).
	
%mantiene las celdas como estaban, debe ir luego de calcular todas las
% emás celdas para no generar mas de un cell por celda
next(cell(X,Y,M)):-
	t(cell(X,Y,M)),
	estado(E),
	\+h(E,cell(X,Y,_)).	%%modificar. NO SE DEBE USAR EL H
	
%cambia el control
next(control(R)):-
	role(R),
	\+t(control(R)).
	
%calcula el nuevo score de cada role en los estados par
next(score(R,NewScore)):-
	estado(E),
	0 is mod(E,2),
	%initRole(R),
	t(score(R,Score)),
	owner(R,O),
	aggregate_all(count, h(E,cell(_,_,O)), ScoreToAdd),
	NewScore is Score + ScoreToAdd + 1.
	
next(score(R,Score)):-
	estado(E),y
	1 is mod(E,2),
	t(score(R,Score)).

%borra el perimetro calculado
next(_):-
	retractall(perimeter(_,_)),
	!,
	fail.
	
%es verdadero para todas las acciones que cambian la posicion del role
changePos(Act):-Act \== noop.

%devuelve la nueva posicion del role al hacer up, down, left o right
move(X,Y,up,NewX,Y):- NewX is X - 1.
move(X,Y,down,NewX,Y):- NewX is X + 1.
move(X,Y,left,X,NewY):- NewY is Y - 1.
move(X,Y,right,X,NewY):- NewY is Y + 1.
move(X,Y,noop,X,Y).

%%%%%%%%%%%%%%%%%%%%%%%%%% Busca figuras %%%%%%%%%%%%%%%%%%%%%%%%%%
searchFigure(R):-
	nextPos(R,X,Y),
	nextCellOfRole(X,Y,[],R,NextX,NextY),
	searchFigureAux(X,Y,R,NextX,NextY,[]),
	retractall(failedCell(_,_)).
searchFigure(_):-
	retractall(failedCell(_,_)),
	fail.

%auxiliar para que la primer celda no vuelva directamente al Init
searchFigureAux(InitX,InitY,R,X,Y,Perimeter):-
	nextCellOfRole(X,Y,Perimeter,R,NextX,NextY),
	(InitX \== NextX ; InitY \== NextY),
	searchInit(InitX,InitY,R,NextX,NextY,[(X,Y)|Perimeter]).

%se llego al punto inicial
searchInit(InitX,InitY,_,InitX,InitY,Perimeter):-
	forall(
		member((X,Y),Perimeter),
		assert(perimeter(X,Y))),
	assert(perimeter(InitX,InitY)),
	fail.
%se busca el siguiente punto adyacente que sea del mismo dueño
searchInit(InitX,InitY,R,X,Y,Perimeter):-
	nextCellOfRole(X,Y,Perimeter,R,NextX,NextY),
	searchInit(InitX,InitY,R,NextX,NextY,[(X,Y)|Perimeter]).
%caso de fallo, no hay celda adyacente que controle R

	
%todas las celdas adyacentes que sean del role R y 
%sin devolver la anterior ni las fuera del tablero
nextCellOfRole(X,Y,Perimeter,R,NextX,NextY):-
	nearCell(X,Y,NextX,NextY),
	indexXY(NextX,NextY),
	\+member((NextX,NextY),Perimeter),
	\+failedCell(NextX,NextY),
	owner(R,O),
	%R esta en la celda, es duenio de la celda o R va a estar en el siguiente turno en la celda
	(t(cell(NextX,NextY,R)) ; t(cell(NextX,NextY,O)) ; nextPos(R,NextX,NextY)),
	\+isInArea(NextX,NextY).
nextCellOfRole(X,Y,_,_,_,_):-
	assert(failedCell(X,Y)),
	fail.

%celdas adyacentes
nearCell(X,Y,NextX,Y):- NextX is X + 1.	%down
nearCell(X,Y,NextX,Y):- NextX is X - 1.	%up
nearCell(X,Y,X,NextY):- NextY is Y + 1.	%right
nearCell(X,Y,X,NextY):- NextY is Y - 1.	%left
	
%verifica si la celda esta dentro de la figura
isInArea(X,Y):-
	perimeter(X1,Y),
	X1 > X,
	perimeter(X2,Y),
	X2 < X,
	perimeter(X,Y1),
	Y1 > Y,
	perimeter(X,Y2),
	Y2 < Y.
	
nextPos(R,NextX,NextY):-
	does(R,Act),
	t(cell(PreX,PreY,R)),
	move(PreX,PreY,Act,NextX,NextY).
	
%verifica si el punto esta dentro de la matriz
indexXY(X,Y):-
	indexX(X),
	indexY(Y).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
goal(R,Score):-role(R),t(score(R,Score)).

terminal:-
	goalScore(GoalScore),
	t(score(_,Score)),
	Score >= GoalScore.
	
distinct(X,Y):-
	X \== Y.

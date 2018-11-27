:-module(meta_gdl_trans, [to_gdl/2]).

%dejamos el inicio y el fin del programa igual
to_gdl(0,0).
to_gdl(end_of_file,end_of_file).
%dejamos la declaraciones como use_module, module, package, etc. igual
to_gdl((:-A),(:-A)).

%cabeza :- cuerpo
to_gdl((A:-B),(P5)):-
	to_gdl_(96,A,N,A1),
	to_gdl_(N,B,_M,B1),
	atom_concat('(<= ',A1,P2),
	atom_concat(P2,' ',P3),
	atom_concat(P3,B1,P4),
	atom_concat(P4,')',P5).

%hecho.
to_gdl(A,A1):-
	to_gdl_(96,A,_N,A1).

%sentencias separadas por coma
to_gdl_(N,(A,B,C),N3,NP):-
	to_gdl_(N,A,N1,A1),
	to_gdl_(N1,B,N2,B1),
	atom_concat(A1,' ',P1),
	atom_concat(P1,B1,P2),
	to_gdl_(N2,C,N3,C1),
	atom_concat(P2,' ',P3),
	atom_concat(P3,C1,NP).

to_gdl_(N,(A,B),N2,NP):-
	to_gdl_(N,A,N1,A1),
	to_gdl_(N1,B,N2,B1),
	atom_concat(A1,' ',P2),
	atom_concat(P2,B1,NP).

%sentencias separadas por or
to_gdl_(N,(A;B),N2,P5):-
	to_gdl_(N,A,N1,A1),
	to_gdl_(N1,B,N2,B1),
	atom_concat('(or ',A1,P1),
	atom_concat(P1,' ',P2),
	atom_concat(P2,B1,P4),
	atom_concat(P4,')',P5).

%sentencia negacion
to_gdl_(N,(\+A),N1,P3):-
	to_gdl_(N,A,N1,A1),
	atom_concat('(not ',A1,P1),
	atom_concat(P1,')',P3).

%sentencia negacion con parentesis por las dudas
to_gdl_(N,(\+(A)),N1,P3):-
	to_gdl_(N,A,N1,A1),
	atom_concat('(not',' (',P1),
	atom_concat(P1,A1,P2),
	atom_concat(P2,'))',P3).

%el is no existe como asignacion en gdl, asique el resultado de una operacion
%se devuelve como ultimo parametro. Asume que B es una operacion de N parametros que devuelve un valor (como una funcion) que se asigna a A.
to_gdl_(N,is(A,B),N4,NP):-
	B=..[Op|Param],
	op_to_pred(Op,NPred),
	atom_concat('(',NPred,P0),
	atom_concat(P0,' ',P1),
	to_gdl_(N,Param,N2,P2),
	atom_concat(P1,P2,P3),
	atom_concat(P3,' ',P4),
	to_gdl_(N2,[A],N4,P8),
	atom_concat(P4,P8,P9),
	atom_concat(P9,')',NP).

%El segundo parametro de to_gdl_ puede ser una lista cuando se tratan los parametros de los predicados, o de las estructuras. Se llama recursivamente para las estructuras anidadas.
to_gdl_(N,[],N,'').

%si P es una variable, se le asigna un valor con la estructura v(P), para luego identificarla en otras secciones donde se utilice P. Si no se hace eso, cuando se asigna valor a P por primer vez, deja de ser variable de prolog, y es considerada atomo, y no se devuelve correctamente a gdl, porque se trata como constante.
to_gdl_(N,[P|RP],N4,(NP)):-
	var(P),
	unificar_valor(N,P,N2),
	to_gdl_(N2,[P],N3,P2),
	(RP=[],atom_concat(P2,'',P3);atom_concat(P2,' ',P3)),
	to_gdl_(N3,RP,N4,P4),
	atom_concat(P3,P4,NP).

%el parametro es una variable, se le pone ? adelante para gdl.
to_gdl_(N,[vzx(P)|RP],N2,(NP)):-
	atom(P),
	atom_concat('?',P,P2),
	(RP=[],atom_concat(P2,'',P3);atom_concat(P2,' ',P3)),
	to_gdl_(N,RP,N2,P4),
	atom_concat(P3,P4,NP).

%el parametro es un numero, se pasa a atomo para poder concatenarlo.
to_gdl_(N,[P|RP],N2,(NP)):-
	\+var(P),
	number(P),
	atom_number(PAux,P),
	(RP=[],atom_concat(PAux,'',P2);atom_concat(PAux,' ',P2)),
	to_gdl_(N,RP,N2,P3),
	atom_concat(P2,P3,NP).

%el parametro es una estructura con parametros, se llama recursivamente para 
%estructuras anidadas. 
to_gdl_(N,[P|RP],N3,(NP)):-
	\+var(P),
	P=..[Op|Param],
	Param\=[],
	op_to_pred(Op,NPred),
	atom_concat('(',NPred,P1),
	atom_concat(P1,' ',P2),
	to_gdl_(N,Param,N2,P3),
	atom_concat(P2,P3,P4),
	atom_concat(P4,')',P5),
	(RP=[],atom_concat(P5,'',P6);atom_concat(P5,' ',P6)),
	to_gdl_(N2,RP,N3,P7),
	atom_concat(P6,P7,NP).

%el parametro es una estructura sin parametros (o un atomo)
to_gdl_(N,[P|RP],N2,(NP)):-
	\+var(P),
	P=..[Op|Param],
	Param=[],
	op_to_pred(Op,NPred),
	(RP=[],atom_concat(NPred,'',P2);atom_concat(NPred,' ',P2)),
	to_gdl_(N,RP,N2,P3),
	atom_concat(P2,P3,NP).

%predicado que no entro en ningun caso: is,or,and,etc, y que no es un parametro.
to_gdl_(N,Pred,M,(NP)):-
	Pred=..[Op|Param],
	Param\=[],
	op_to_pred(Op,NPred),
	atom_concat('(',NPred,P1),
	atom_concat(P1,' ',P2),
display([manda,Param]),nl,nl,
	to_gdl_(N,Param,M,P3),
	atom_concat(P2,P3,P4),
	atom_concat(P4,')',NP).

%predicado que no entro en ningun caso y no tiene parametros.
to_gdl_(N,Pred,N,(NPred)):-
	Pred=..[NPred|Param],
	Param=[].

%asigna en X el caracter asociado al numero N y lo devuelve en una estructura v(). Si el programa usa esta estructura hay que reemplazarla por otra.
unificar_valor(N,vzx(X),Var):-
	Var is N+1,
	name(X,[Var]).

%dado un operador de prolog devuelve su equivalente en predicado, ej, + es reemplazado por suma. Si un operador no esta definido entonces se devuelve el mismo.
%tambien pueden traducirse predicados y estructuras:
%op_to_pred(input,entrada), reemplaza el predicado input por entrada
%op_to_pred(lanzar,lanzamiento) reemplaza la estructura lanzar por lanzamiento.
op_to_pred(+,sum).
op_to_pred(-,minus).
op_to_pred(*,mult).
op_to_pred(/,div).
op_to_pred(==,igual).
op_to_pred(=,igual).
op_to_pred(\==,distinct).
op_to_pred(<=,menorIgual).
op_to_pred(>=,mayorIgual).
op_to_pred(<,menor).
op_to_pred(>,mayor).
op_to_pred(',','').
op_to_pred(fail,'distinct(0,0)').
op_to_pred(t,true).
op_to_pred(Op,Op).



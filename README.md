# traductor_prolog_gdl
expansión sintáctica para traducir de prolog a gdl

Solo funciona con CIAO prolog.

Pegar el codigo a traducir en el archivo trad_gdl, dejando los paquetes

:- use_package(show_trans).
:- use_package(.(meta_trans)).

%%%%%%%%%%%

o copiar
:- use_package(show_trans).
:- use_package(.(meta_trans)). 

en el archivo propio, que tiene que estar en la misma carpeta que meta_trans y meta_gdl_trans.

Devuelve el resultado de la compilación en la consola. Recomendación: usar emacs.

Hay que eliminar las comillas simples que genera.

No funciona bien con listas, es decir, las traduce a como prolog las trata internamente [a,b] =  (. a (b. [])).

gdl no usa listas, usar la kb.
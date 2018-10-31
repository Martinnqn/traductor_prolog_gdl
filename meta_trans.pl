:-package(meta_trans). %nombre del paquete

%carga el modulo meta_gdl_trans al compilador
:-load_compilation_module(meta_gdl_trans).

%agregamos la sentencia to_gdl que se va a usar para traducir.
:-add_sentence_trans(to_gdl/2,700).

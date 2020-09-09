# Traductor prolog a gdl
Syntactic expansion in CIAO ProLog for translate from ProLog to GDL. (Not compatible with SWIProlog).

## How to use
Paste the code for translate into *trad_gdl* file, keeping the packages:
```sh
:- use_package(show_trans).
:- use_package(.(meta_trans)).
```
### Result
The result of compilation is returned in the console. 

The result has single quotes.

### Observations
GDL does not use lists, so the ProLog list translates to how ProLog treats them internally: ```[a,b] =  (. a (b. [])).```
Instead of using lists, use the KB.

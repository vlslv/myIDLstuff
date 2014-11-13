;PRO idl2py4off

; recupera los offsets de las posiciones de los haces 
; para correr despues de idl2pyrs.pro, por lo tanto usa
; algunas de sus variables  

restore,'~/SST/rutinas/bpos.save'
sst2offs,rs,bpos,source,beams,/noplot

source_ew=source.ew
source_ns=source.ns
beams_ew=beams.ew
beams_ns=beams.ns 


destiny_path = origin_path
salvado = destiny_path + extractedStr + '.bpos'

save,source_ew,source_ns, beams_ew,beams_ns,filename=salvado

END

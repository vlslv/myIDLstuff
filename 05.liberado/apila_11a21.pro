;PRO apila_11a21
; recuperar los archivos rs1yyyymmdd.hh00 para concatenarlos y crear un modelo de t_brillo
; procedimiento que solo funciona con dias que tengan datos entre 1100 hasta 2100 horas

dato=DIALOG_PICKFILE(path='/adhara/fvalle/SST/Y2012/M*/D*/intg/',/read)
;file_uncompress,datag,datad ; linea para cuando el archivo este comprimido

read_sst,b11,dato,recr=1000000,/close

split_fpath_fname=strsplit(dato,'intg/',/extract,/regex)
ruta_arch=split_fpath_fname[0]
nombre_arch=split_fpath_fname[1]
split_name_exte=strsplit(nombre_arch,'.',/extract)
nombre=split_name_exte[0]
cd,ruta_arch
cd,'intg'

dato=nombre+'.1200'

read_sst,b12,dato,recr=1000000,/close

dato=nombre+'.1300'

read_sst,b13,dato,recr=1000000,/close

dato=nombre+'.1400'

read_sst,b14,dato,recr=1000000,/close

dato=nombre+'.1500'

read_sst,b15,dato,recr=1000000,/close

dato=nombre+'.1600'

read_sst,b16,dato,recr=1000000,/close

dato=nombre+'.1700'

read_sst,b17,dato,recr=1000000,/close

dato=nombre+'.1800'

read_sst,b18,dato,recr=1000000,/close

dato=nombre+'.1900'

read_sst,b19,dato,recr=1000000,/close

dato=nombre+'.2000'

read_sst,b20,dato,recr=1000000,/close

dato=nombre+'.2100'

read_sst,b21,dato,recr=1000000,/close

;b contiene los datos del dia apilados en una sola estructura
b=[b11,b12,b13,b14,b15,b16,b17,b18,b19,b20,b21]

window,/free
!P.MULTI = [0, 1, 6]
t_plot,0.1*b.time,b.adcval[0],xstyle=1,ystyle=1,psym=0
;window,11
t_plot,0.1*b.time,b.adcval[1],xstyle=1,ystyle=1,psym=0
;window,12
t_plot,0.1*b.time,b.adcval[2],xstyle=1,ystyle=1,psym=0
;window,13
t_plot,0.1*b.time,b.adcval[3],xstyle=1,ystyle=1,psym=0
;window,14
t_plot,0.1*b.time,b.adcval[4],xstyle=1,ystyle=1,psym=0
;window,15
t_plot,0.1*b.time,b.adcval[5],xstyle=1,ystyle=1,psym=0
             
end

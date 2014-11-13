;PRO apila_14to18
; recuperar los archivos rs1yyyymmdd.hh00 para concatenarlo y crear modelo de t_brillo
; procedimiento que solo funciona con dias que tengan datos entre 1200 hasta 2100 horas

dato= DIALOG_PICKFILE(path='/network/adhara/fvalle/SST/Y2012/M*/D*/intg/',/read)
;file_uncompress,datag,datad ; linea para cuando el archivo este comprimido

read_sst,b_2,dato,recr=1000000,/close
trak_2=where(b_2.opmode eq 0)
b_2s=b_2[trak_2]

split_fpath_fname=strsplit(dato,'intg/',/extract,/regex)
ruta_arch=split_fpath_fname[0]
nombre_arch=split_fpath_fname[1]
split_name_exte=strsplit(nombre_arch,'.',/extract)
nombre=split_name_exte[0]
cd,ruta_arch
cd,'intg'

dato=nombre+'.1500'
read_sst,b_1,dato,recr=1000000,/close
trak_1=where(b_1.opmode eq 0)
b_1s=b_1[trak_1]

dato=nombre+'.1600'
read_sst,b0,dato,recr=1000000,/close
trak0=where(b0.opmode eq 0)
b0s=b0[trak0]

dato=nombre+'.1700'
read_sst,b1,dato,recr=1000000,/close
trak1=where(b1.opmode eq 0)
b1s=b1[trak1]

dato=nombre+'.1800'
read_sst,b2,dato,recr=1000000,/close
trak2=where(b2.opmode eq 0)
b2s=b2[trak2]

b=[b_2,b_1,b0,b1,b2]

window,01
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

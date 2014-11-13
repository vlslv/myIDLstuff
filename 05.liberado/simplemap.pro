;PRO simplemap

;Rutina para hacer mapas utilizando archivos rs1yymmdd.hh00 
;toma los archivos entre las 15hh y las 18hh para cosntruir
;el mapa. Llama las rutinas auxiliares del acervo del SST: 
;JULDAY.
;SST_SUNPOS.
;SST_CT2LST.
;SST2AZEL.




restore,'~/SST/rutinas/bpos.save'
;help,bpos
; seleccionar el archivo de las 14 horas
dato= DIALOG_PICKFILE(path='/path/to/files/of/the/type/intg/',/read)
read_sst,b_2,dato,recr=1000000,/close
sst2offs,b_2,bpos,sou_2,bea_2,/noplot

c=strsplit(dato,'intg/',/extract,/regex)
d=strsplit(c[1],'.',/extract)
cd,c[0]
cd,'intg'

dato=d[0]+'.1500'

read_sst,b_1,dato,recr=1000000,/close
sst2offs,b_1,bpos,sou_1,bea_1,/noplot

dato=d[0]+'.1600'

read_sst,b0,dato,recr=1000000,/close
sst2offs,b0,bpos,sou0,bea0,/noplot


dato=d[0]+'.1700'

read_sst,b1,dato,recr=1000000,/close
sst2offs,b1,bpos,sou1,bea1,/noplot

dato=d[0]+'.1800'

read_sst,b2,dato,recr=1000000,/close
sst2offs,b2,bpos,sou2,bea2,/noplot

b=[b_2,b_1,b0,b1,b2]
sou=[sou_2,sou_1,sou0,sou1,sou2]
bea=[bea_2,bea_1,bea0,bea1,bea2]
time=[b_2.time,b_1.time,b0.time,b1.time,b2.time]


wx2=where(b.opmode eq 2)


;surface,dist(5),/nodata,/save,xrange=[-2000,2000],yrange=[-2000,2000],zrange=[0,1000],xstyle=1,ystyle=1,zstyle=1


T212=5900
T405=5100
device,decomposed=0
loadct,39

x1=bea[wx2].ew[1]
y1=bea[wx2].ns[1]
z1=(double(b[wx2].adcval[1])-min(b[wx2].adcval[1]))
z1=t212*z1/max(z1)
window,/free    
surface,dist(5),/nodata,/save,xrange=[-2000,2000],yrange=[-2000,2000],zrange=[0,T212],xstyle=1,ystyle=1,zstyle=1
plots,x1,y1,z1,/T3D,color=250


x2=bea[wx2].ew[2]
y2=bea[wx2].ns[2]
z2=(double(b[wx2].adcval[2])-min(b[wx2].adcval[2]))
z2=t212*z2/max(z2)
window,/free    
surface,dist(5),/nodata,/save,xrange=[-2000,2000],yrange=[-2000,2000],zrange=[0,T212],xstyle=1,ystyle=1,zstyle=1
plots,x2,y2,z2,/T3D,color=150

x3=bea[wx2].ew[3]
y3=bea[wx2].ns[3]
z3=(double(b[wx2].adcval[3])-min(b[wx2].adcval[3]))
z3=t212*z3/max(z3)
window,/free    
surface,dist(5),/nodata,/save,xrange=[-2000,2000],yrange=[-2000,2000],zrange=[0,T212],xstyle=1,ystyle=1,zstyle=1
plots,x3,y3,z3,/T3D,color=50


x=bea[wx2].ew[0]
y=bea[wx2].ns[0]
z0=(double(b[wx2].adcval[0])-min(b[wx2].adcval[0]))
z=t212*z0/max(z0)
window,/free    
surface,dist(5),/nodata,/save,xrange=[-2000,2000],yrange=[-2000,2000],zrange=[0,T212],xstyle=1,$
ystyle=1,zstyle=1,/shades
plots,x,y,z,/t3d
;plots,x1,y1,z1,/T3D,color=250
;plots,x2,y2,z2,/T3D,color=150
;plots,x3,y3,z3,/T3D,color=50

END
            

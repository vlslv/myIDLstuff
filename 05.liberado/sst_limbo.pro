read_sst,d,'rs1110506.1400',recr=1000000,/close
restore,'bpos20110506.save',/v

goto,dos

;Primero hicimos un limbo oeste
;target ar -l 0 90
lo=d[44500:51000]
; Cielo
co=fltarr(6)
for i=0,5 do co[i]=(moment(lo[0:1500].adcval[i]))(0)
; Sol 
so=fltarr(6)
for i=0,5 do so[i]=(moment(lo[3000:4000].adcval[i]))(0)
; Exceso Sol
dsc_o=so-co
print,' '
print,' LIMBO OESTE'
print,'Exceso Solar = ',dsc_o
bpos.el=-bpos.el
pos,lo[3000],bpos
stop

;Despues hicimos un limbo norte
; target ar -l 0 90
ln=d[63000:67000]

; Cielo
cn=fltarr(6)
for i=0,5 do cn[i]=(moment(ln[0:1000].adcval[i]))(0)
; Sol 
sn=fltarr(6)
for i=0,5 do sn[i]=(moment(ln[2000:3000].adcval[i]))(0)
; Exceso Sol
dsc_n=sn-cn
print,''
print,' LIMBO NORTE'
print,'Exceso Solar = ',dsc_n
pos,ln[3000],bpos

print,' '
print,' '
print,'C O N C L U S I O N '
print,'Despues de los cambios hechos con Patrick Wallace'
print,'Para calcular proyectar las posiciones, obtenidas '
print,'por el SST, en el Sol, HAY QUE CAMBIAR EL SIGNO '
print,'DE LA ELEVACIO DE LAS CORNETAS (Y FUENTES)'
print, ' '
print,' ' 


dos:

lo=d[44500:51000]
ln=d[63000:67000]

sst2offs,lo[3000],bpos
sst2offs,ln[3000],bpos

end


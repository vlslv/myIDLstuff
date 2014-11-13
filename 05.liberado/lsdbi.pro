;PRO lsdbi

;lectura de datos
datacom = DIALOG_PICKFILE(path='/adhara/fvalle/SST/Y*/M*/D*/instr',/read,filter='bi*')
file_uncompress,datacom,datades; descomprime el archivo, si lo está
read_sst,bi,datades,recr=500000,/close,/mon

bbk=bi; copia de la estructura original

peaje=make_array(6,/integer,value=0)
for i=4,5 do begin ; el 4to e 5to canal no son corregidos en 2013, porque tienen ceros!!!
  bad = where(bi.adc[i] le 10, /NULL)
  ;good=where(bi.adc[i] gt 10,cuentas,complement=locom,ncomplement=numlocom); elimina? los zeros de los canales de adc
  if (bad NE !NULL) then begin
  ;if (n_elements(bi.adc[i]) ne cuentas) then begin
    bi.adc[i]=9999+bi.adc[i]
    ;bi.adc[i]=bi.adc[i]+9999+0.9999*randomu(Seed,n_elements(bi.adc[i]))
    peaje[i]=1
  end
end

bi=bi[uniq(bi.time,sort(bi.time))]; ordena (y elimina valores repetidos de...) el vector tiempo
bi=bi[where(bi.time ne 0)]; elimina los datos donde el vector tiempo es cero

for i=0,5 do begin
  if (peaje[i] eq 0) then begin 
    limite=mean(bi.adc[i])-3*stddev(bi.adc[i])
    ;b=b[where(b.adc[i] gt limite)];elimina valores demasiado bajos que interfieren en la calibracion!
  endif else begin
    limite=7999
  endelse
end

bo=bi; copia de la estructura sin calibracion

device,decomposed=1 ; manejo de color

xc=where(bi.target /32 eq 1); indices de fonte fria

xh=where(bi.target /32 eq 2); indices de fonte quente
xcal=[xc,xh]
x0=where(bi.opmode eq 0); indices de track
x2=where(bi.opmode eq 2); ...map_azel
x5=where(bi.opmode eq 5); ...scan_az
x10=where(bi.opmode eq 10); ...scan_tau
x90=where(bi.elepos ge 85)

cc=contiguo(xc); vetor contiguo de indices de fonte fria
ch=contiguo(xh); vetor contiguo de indices de fonte quente
c2=contiguo(x2); vetor contiguo de ...
c5=contiguo(x5); ...
c10=contiguo(x10); ...
c90=contiguo(x90)

mc=size(cc); tamanho del array contiguo de fonte fria
mh=size(ch); tamaho ...
m2=size(c2); tamanho 
m5=size(c5); tamanho 
m10=size(c10); ...
m90=size(c90)

nume=mh(2)-1 ; numero de veces que se produce el apuntamiento a la fuente hot 
polygrad=min([nume,3]) ;grado del polinomio de ajuste que depende de la fuente caliente
;intento de escoger puntos medios para el ajuste de temperatura hot
coraje=fltarr(2,mh(2))
;polygrad=min([mh(2)-1,3]) ; grado del polinomio de ajuste que depende de la fuente caliente

ft=0.52; factor de correcion de temperatura de fuente hot 

tcold=min(bi[xc].opt_temp)+273.15
thot=ft*min(bi[xc].hot_temp)+273.15

y=[tcold,thot]; & print,tcold,thot

for i=0,5 do begin
  if (peaje[i] eq 0) then begin
    mxc=mean(bi[xc].adc[i]) &  sxc=stddev(bi[xc].adc[i]) 
    lsup=mxc+sxc & linf=mxc-sxc
    for k=0,nume do begin
      coraje[0,k]=min(bi[xc[cc[0,k]:cc[1,k]]].time)  
      coraje[1,k]=min(bi[xc[cc[0,k]:cc[1,k]]].adc[i])
      ;if (coraje[1,k] ge lsup) || (coraje[1,k] le linf) then b[xc[cc[0,k]:cc[1,k]]].adc[i]=mxc  
    end
    coef=poly_fit(0.1*coraje[0,*],coraje[1,*],polygrad);ajuste polinomico sobre las temperaturas de la fuente cold 
    ev=fltarr(n_elements(bi.time),/nozero); 
    for j=0,polygrad do begin
      ev=coef[j]*(0.1*bi.time)^j+ev
    end
    evmin=ev-min(ev)
    aux2=double(bi.adc[i])-evmin; originalmente tenia valor absoluto!!!!
    x=[min(aux2[xc]),min(aux2[xh])]
    a_lin=linfit(x,y)
    print,-a_lin[0],1./a_lin[1]
    aux1=a_lin[0]+aux2*a_lin[1]
    bi.adc[i]=aux1  
  endif else begin
    bi.adc[i]=bi.adc[i]
  endelse
end


while !d.window ne -1 do wdelete, !d.window ; cierra las ventanas existentes 
window,/free
!P.MULTI = [0, 1, 6]
plot,bo.adc[0],ys=1,psym=0
;window,11
plot,bo.adc[1],ys=1,psym=0
;window,12
plot,bo.adc[2],ys=1,psym=0
;window,13
plot,bo.adc[3],ys=1,psym=0
;window,14
plot,bo.adc[4],ys=1,psym=0
;window,15
plot,bo.adc[5],ys=1,psym=0

!P.MULTI=0;[0,1,4]
;it1=['14:00','19:00']
ylim1=max([max(bi.adc[1]),max(bi.adc[2]),max(bi.adc[3])])
ylim0=min([min(bi.adc[1]),min(bi.adc[2]),min(bi.adc[3])])
window,/free
t_plot,0.1*bi.time,bi.adc[0],psym=3,xrange=it1,yrange=[ylim0,ylim1],xstyle=1,ystyle=1
t_plot,0.1*bi.time,bi.adc[1],psym=3,color='0000ff'x,/overplot; rojo
;window,21
t_plot,0.1*bi.time,bi.adc[2],psym=3,color='00ff00'x,/overplot; verde
;window,22
t_plot,0.1*bi.time,bi.adc[3],psym=3,color='ff0000'x,/overplot; azul
;window,23
;t_plot,0.1*b.time,b.adc[3],psym=0,/overplot
;;
ylim2=min([max(bi.adc[4]),max(bi.adc[5])])
window,/free
!p.multi=0;[0,1,2]
t_plot,0.1*bi.time,bi.adc[4],psym=0,color='ff00aa'x,yrange=[min(bi.adc[5]),max(bi.adc[4])],xrange=it1,xstyle=1,ystyle=1
;window,25
t_plot,0.1*bi.time,bi.adc[5],psym=0,/overplot

;nomefile=datacom+'.abs'
;openw,33,nomefile


;printf,33,'calibrations', mc(2) ; numero de calibraciones en el dia
;for i=0,mc(2)-1 do begin
;  partial_result=mil_civtime(0.1*b[xc[cc[*,i]]].time,/string,/no_ms)
;  printf,33,partial_result; hora de las calibraciones
;end

;matrimin=fltarr(7,m5(2))
;matrimax=fltarr(7,m5(2))
;matridif=fltarr(7,m5(2))
;printf,33,'solar scan', m5(2) ; numero de scan solares durante el dia
;for i=0,m5(2)-1 do begin
  ;partial_result=mil_civtime(0.1*b[x5[c5[*,i]]].time,/string,/no_ms)
  ;matridif[0,i]=mean(b[x5[c5[*,i]]].elepos)
 ; for j=1,6 do begin 
    ;matrimin[j,i]=min(b[x5[c5[0,i]:c5[1,i]]].adc[j])
    ;matrimax[j,i]=max(b[x5[c5[0,i]:c5[1,i]]].adc[j])
   ;; matridif[j,i]=max(b[x5[c5[0,i]:c5[1,i]]].adc[j-1])-min(b[x5[c5[0,i]:c5[1,i]]].adc[j-1]) 
  ;end

    ;printf,33,matridif[*,i],format='(7f10.2)';partial_result,matrimin[*,i],matrimax[*,i]
  
;end

;printf,33,'sky tipping',m10(2)/2
;for i=0,m10(2)/2-1 do begin
;  partial_result=mil_civtime(0.1*b[x10[c10[*,2*i]]].time,/string,/no_ms)
;  printf,33,partial_result
;end

;close,33

end

;PRO calibra_rs,b,m10

!P.MULTI=0
device,decomposed=0
loadct,39

bori=b; copia de la estructura original apilada
peaje=make_array(6,/integer,value=0)
for i=0,5 do begin ; el 4to e 5to canal no son corregidos en 2013, porque tienen ceros!!!
  ;bad = where(b.adcval[i] le 10, /NULL)
  good=where(b.adcval[i] gt 0,cuentas,complement=locom,ncomplement=numlocom); elimina? los zeros de los canales de adc
  ;if (bad NE !NULL) then begin
  if (n_elements(b.adcval[i]) ne cuentas) then begin
    ;b[bad].adcval[i]=9999
    b.adcval[i]=b.adcval[i]+9999+0.9999*randomu(Seed,n_elements(b.adcval[i]))
    peaje[i]=1
  end
end 
b=b[uniq(b.time,sort(b.time))]; ordena (y elimina valores repetidos de...) el vector tiempo
b=b[where(b.time ne 0)]; elimina los datos donde el vector tiempo es cero

x99=where(b.opmode eq 99,complement=nx99,/null); ...unknown_mode
b=b[nx99]
b0=b; copia de la estructura pre-procesada sin calibracion

;for i=0,3 do begin
;  m=mean(b[0:8999].adcval[i]) & s=stddev(b[0:8999].adcval[i])
;  aux3=b[0:8999].adcval[i]
;  aux3[where(aux3 LT (m-3*s),/null)]=m; elimina valores demasiado bajos del inicio del dia
;  b[0:8999].adcval[i]=aux3
;end

x4=where(b.opmode eq 4,complement=nx4); ...map_interm
x9=where(b.opmode eq 9,complement=nx9); ...scan_interm
;x99=where(b.opmode eq 99,complement=nx99); ...unknown_mode
;xgro=where(b.elepos/1000. le 10)   
;xsky=where(b.elepos/1000. ge 85)

inter=where((b.opmode EQ 4) OR (b.opmode EQ 9) OR (b.opmode EQ 99),complement=not_inter,/null)

;b=b[not_inter] ; Elimino puntos intermedios,desconocidos y de elevacion mayor a 85 o menor a 10



xc=where(b.target /32 eq 1); indices de fonte fria
xh=where(b.target /32 eq 2); indices de fonte quente
xcal=[xc,xh]
x0=where(b.opmode eq 0); indices de track
x2=where(b.opmode eq 2); ...map_azel
x5=where(b.opmode eq 5,complement=nx5); ...scan_az
;x10=where(b.opmode eq 10,complement=nx10); ...scan_tau
;xgro=where(b.elepos/1000. le 10)   
;xsky=where(b.elepos/1000. ge 85)

cc=contiguo(xc); vetor contiguo de indices de fonte fria
ch=contiguo(xh); vetor contiguo de indices de fonte quente
c2=contiguo(x2); vetor contiguo de ...
c5=contiguo(x5); ...
;c10=contiguo(x10); ...
;cgro=contiguo(xgro)
;csky=contiguo(xsky)

mc=size(cc); tamanho del array contiguo de fonte fria
mh=size(ch); tamaho ...
m2=size(c2); tamanho 
m5=size(c5); tamanho 
;m10=size(c10); ...
m90=size(c90)


nume=min([mc(2)-1,mh(2)-1])  ; numero de veces que se produce el apuntamiento a la fuente hot 
polygrad=min([nume,3]) ;grado del polinomio de ajuste que depende de la fuente caliente
;intento de escoger puntos medios para el ajuste de temperatura hot
coraje=fltarr(2,mh(2))

;temperaturas entradas a mano porque las estructuras rs no tienen datos de temperatura
ft=0.401; factor de correcion de temperatura de fuente hot 
tcold=24.00+273.15;min(b[xc].opt_temp)+273.15
thot=152.93*ft+273.15;ft*min(b[xc].hot_temp)+273.15
ty2=[tcold,thot]

tempes=fltarr(6); arreglo para acopiar temperaturas minimas
;;;;;;calibracion cold
for i=0,5 do begin
  if (peaje[i] eq 0) then begin
    mxc=mean(b[xc].adcval[i]) &  sxc=stddev(b[xc].adcval[i]) 
    lsup=mxc+3*sxc & linf=mxc-3*sxc
    for k=0,nume do begin
      coraje[0,k]=min(b[xc[cc[0,k]:cc[1,k]]].time)  
      coraje[1,k]=min(b[xc[cc[0,k]:cc[1,k]]].adcval[i])
        if (coraje[1,k] ge lsup) || (coraje[1,k] le linf) then b[xc[cc[0,k]:cc[1,k]]].adcval[i]=mxc  
    end
    coef=poly_fit(0.1*coraje[0,*],coraje[1,*],polygrad);ajuste polinomico sobre las temperaturas de la fuente cold 
    ev=fltarr(n_elements(b.time),/nozero); 
    for j=0,polygrad do begin
      ev=coef[j]*(0.1*b.time)^j+ev; construccion recursiva de la expresion polinomica
    end
    evmin=ev-min(ev); expresion polinomica minima
    aux2=double(b.adcval[i])-evmin
    aux2=aux2
    adcx2=[min(aux2[xc]),min(aux2[xh])]
    a_lin=linfit(adcx2,ty2)
    tempes[i]=-a_lin[0]
    print,-a_lin[0],1./a_lin[1]
    aux1=a_lin[0]+aux2*a_lin[1]
    b.adcval[i]=aux1
  endif else begin
    b.adcval[i]=b.adcval[i]
  endelse
end

taux212=mean([tempes[0],tempes[1],tempes[2],tempes[3]])
taux405=mean([tempes[4],tempes[5]])


;;PLOT de calibraciones

;set_plot,'ps'
;!p.font=0
;device,filename='calibrado212.eps,/landscape,/encapsulated,/color,bits_per_pixel=8,xsize=24.,ysize=16.,/cm,xoffset=3.0,yoffset=27.0
;device,helvetica=1
;device,isolatin1=1
;!p.thick=4
;!x.thick=3
;!y.thick=3
;!z.thick=3
ylim1=max([max(b.adcval[1]),max(b.adcval[2]),max(b.adcval[3]),max(b.adcval[0])]);fijando el limite sup. vertical
;ylim1=min([ylim01,5000])
ylim0=min([min(b.adcval[1]),min(b.adcval[2]),min(b.adcval[3]),min(b.adcval[0])]); fijando el limite inf. vertical
window,/free;,xs=1200,ys=800
t_plot,0.1*b.time,b.adcval[0],psym=0,xstyle=1,ystyle=1,yrange=[ylim0-50,ylim1+50],title='Temperatura sem Corr. Atm. 212 GHz',ytitle='Temperatura (K)';,thick=3,charsize=2.0
t_plot,0.1*b.time,b.adcval[1],psym=0,/overplot,color=250;,thick=3,charsize=2.0
t_plot,0.1*b.time,b.adcval[2],psym=0,/overplot,color=150;,thick=3,charsize=2.0
t_plot,0.1*b.time,b.adcval[3],psym=0,/overplot,color=50;,thick=3,charsize=2.0
;device,/close_file
;set_plot,'x'
;;

ylim3=max([max(b.adcval[4]),max(b.adcval[5])])
;ylom3=min([ylim03,5000])
ylim2=min([min(b.adcval[4]),min(b.adcval[5])])
;;set_plot,'ps'
;;!p.font=0
;device,filename='calibrado405.eps',/landscape,/encapsulated,/color,bits_per_pixel=8,xsize=24.,ysize=16.,/cm,xoffset=3.0,yoffset=27.0,$
;device,helvetica=1
;device,isolatin1=1
;!p.thick=4
;!x.thick=3
;!y.thick=3
;!z.thick=3
window,/free 
t_plot,0.1*b.time,b.adcval[4],psym=0,xstyle=1,ystyle=1,yrange=[ylim2,ylim3],color=20,title='T s/Corr.Atm. Canais 405 GHz',ytitle='Temperatura (K)';,thick=3,charsize=2.0
t_plot,0.1*b.time,b.adcval[5],psym=0,/overplot;,thick=3,charsize=2.0
;device,/close_file
;set_plot,'x'

;para pruebas guardo los valores sin calibrar en la variable solo
solo0=b.adcval[0]
solo1=b.adcval[1]
solo2=b.adcval[2]
solo3=b.adcval[3]
solo4=b.adcval[4]
solo5=b.adcval[5]

end

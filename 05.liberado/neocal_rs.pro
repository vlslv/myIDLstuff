;PRO neocal_rs

!P.MULTI=0
bnon=b; copia de la estructura original apilada

for i=0,5 do begin ; el 4to e 5to canal no son corregidos en 2013, porque tienen ceros!!!
  b=b[where(b.adcval[i] gt 0,cuentas,complement=locom,ncomplement=numlocom)]; elimina? los zeros de los canales de adc
  if numlocom gt cuentas then begin
    b.adcval[i]=9999+b.adcval[i]
  end
end

b=b[uniq(b.time,sort(b.time))]; ordena (y elimina valores repetidos de...) el vector tiempo
b=b[where(b.time ne 0)]; elimina los datos donde el vector tiempo es cero
bo=b; copia de la estructura pre-procesada sin calibracion

for i=0,5 do begin
  m=mean(b[0:8999].adcval[i]) & s=stddev(b[0:8999].adcval[i])
  aux3=b[0:8999].adcval[i] ; 9000 puntos son 3 minutos de datos
  aux3[where(aux3 LT (m-3*s),/null)]=m; elimina valores demasiado bajos del inicio del dia
  b[0:8999].adcval[i]=aux3
end

;##manejo de color##
device,decomposed=0 
loadct,39

xc=where(b.target /32 eq 1); indices de fonte fria
xh=where(b.target /32 eq 2); indices de fonte quente
xcal=[xc,xh]
x0=where(b.opmode eq 0); indices de track
x2=where(b.opmode eq 2); ...map_azel
x5=where(b.opmode eq 5,complement=nx5); ...scan_az
x10=where(b.opmode eq 10,complement=nx10); ...scan_tau
x90=where(b.elepos ge 85)

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
nume=min([mc(2)-1,mh(2)-1]) 

;intento de escoger puntos medios representativos para el ajuste de temperatura hot
colectc=fltarr(2,mh(2))
colecth=fltarr(2,mh(2))
;temperaturas entradas a mano porque las estructuras rs no tienen datos de temperatura
ft=0.52; factor de correcion de temperatura de fuente hot 
tcold=27.4+273.15;min(b[xc].opt_temp)+273.15
thot=152.3*ft+273.15;ft*min(b[xc].hot_temp)+273.15
ty2=[tcold,thot] ; valores de interpolacion (Eje Y)

tempes=fltarr(6); arreglo para acopiar temperaturas minimas
;;;;;;calibracion cold
for i=0,5 do begin
 mxc=mean(b[xc].adcval[i]) &  sxc=stddev(b[xc].adcval[i]) 
 lsupc=mxc+3*sxc & linfc=mxc-3*sxc
 mxh=mean(b[xh].adcval[i]) &  sxh=stddev(b[xh].adcval[i]) 
 lsuph=mxh+3*sxh & linfc=mxh-3*sxh
 for k=0,nume do begin
    colectc[0,k]=mean(b[xc[cc[0,k]:cc[1,k]]].adcval[i])
    colectc[1,k]=mean(b[xc[cc[0,k]:cc[1,k]]].time)  
    
    if (colectc[1,k] ge lsupc) || (colectc[1,k] le linfc) then b[xc[cc[0,k]:cc[1,k]]].adcval[i]=mxc  
 end
 for k=0,nume do begin
    colecth[0,k]=mean(b[xh[ch[0,k]:ch[1,k]]].adcval[i])  
    colecth[1,k]=mean(b[xh[ch[0,k]:ch[1,k]]].time)
    if (colecth[1,k] ge lsuph) || (colecth[1,k] le linfh) then b[xh[ch[0,k]:ch[1,k]]].adcval[i]=mxh  
 end 
 evc=interpol(colectc[0,*],0.1*colectc[1,*],0.1*b.time) 
 evh=interpol(colecth[0,*],0.1*colecth[1,*],0.1*b.time) 
 evcmin=evc-min(evc)
 evhmin=evh-min(evh)
 aux2=double(b.adcval[i])-evcmin
 adcx2=[min(aux2[xc]),min(aux2[xh])]
 a_lin=linfit(adcx2,ty2)
 tempes[i]=-a_lin[0]
 print,-a_lin[0],1./a_lin[1]
 aux1=a_lin[0]+aux2*a_lin[1]
 b.adcval[i]=aux1
end

taux212=mean([tempes[0],tempes[1],tempes[2],tempes[3]])
taux405=mean([tempes[4],tempes[5]])

;;PLOT de calibraciones

;;set_plot,'ps'
;!p.font=0
;;device,filename='calibrado212.eps,/landscape,/encapsulated,/color,bits_per_pixel=8,xsize=24.,ysize=16.,/cm,xoffset=3.0,yoffset=27.0
;;device,helvetica=1
;;device,isolatin1=1
;!p.thick=4
;!x.thick=3
;!y.thick=3
;!z.thick=3
ylim11=max([max(b.adcval[1]),max(b.adcval[2]),max(b.adcval[3]),max(b.adcval[0])])
ylim1= min([ylim11,5000])
ylim0=min([min(b.adcval[1]),min(b.adcval[2]),min(b.adcval[3]),min(b.adcval[0])])
window,/free,xs=1200,ys=800
t_plot,0.1*b.time,b.adcval[0],psym=0,xstyle=1,ystyle=1,yrange=[ylim0,ylim1],title='Temperaturas sem corr. atm. 212 GHz',ytitle='Temperatura (K)';,thick=3,charsize=2.0
t_plot,0.1*b.time,b.adcval[1],psym=0,/overplot,color=250;,thick=3,charsize=2.0
t_plot,0.1*b.time,b.adcval[2],psym=0,/overplot,color=150;,thick=3,charsize=2.0
t_plot,0.1*b.time,b.adcval[3],psym=0,/overplot,color=50;,thick=3,charsize=2.0
;device,/close_file
;set_plot,'x'
;;

ylim31=max([max(b.adcval[4]),max(b.adcval[5])])
ylim3=min([ylim31,5000])
ylim2=min([min(b.adcval[4]),min(b.adcval[5])])
;;set_plot,'ps'
;;;!p.font=0
;;device,filename='calibrado405.eps',/landscape,/encapsulated,/color,bits_per_pixel=8,xsize=24.,ysize=16.,/cm,xoffset=3.0,yoffset=27.0,$
;;device,helvetica=1
;;device,isolatin1=1
;;!p.thick=4
;;!x.thick=3
;;!y.thick=3
;;!z.thicik=3
window,/free,xs=1200,ys=800 
t_plot,0.1*b.time,b.adcval[4],psym=0,xstyle=1,ystyle=1,yrange=[ylim2,ylim3],color=20,title='Temp sem corr. atm. 405 GHz',ytitle='Temperatura (K)';,thick=3,charsize=2.0
t_plot,0.1*b.time,b.adcval[5],psym=0,/overplot;,thick=3,charsize=2.0
;;device,/close_file
;;;set_plot,'x'

;para pruebas posteriores guardo los valores calibrados pero sin corr. atm. en la variable solo
solo0=b.adcval[0]
solo1=b.adcval[1]
solo2=b.adcval[2]
solo3=b.adcval[3]
;solo4=b.adcval[4]
;solo5=b.adcval[5]


end

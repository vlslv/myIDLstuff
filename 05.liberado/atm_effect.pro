;PRO atm_effect,b

sin0=b.adcval[0]
sin1=b.adcval[1]
sin2=b.adcval[2]
sin3=b.adcval[3]
sin4=b.adcval[4]
sin5=b.adcval[5]


;xtau=where((b.elepos/1000. LE 10.0) OR (b.elepos/1000. GT 80.0),complement=nxtau,/null)
;b=b[nxtau]
x10=where(b.opmode eq 10, complement=nx10,/null); ...scan_tau
c10=contiguo(x10)
m10=size(c10)

num_corr=m10[2]/2-1
;num_corr+1 es el numero de veces que se hace tipping
taust=fltarr(3,num_corr+1); array que guardara opacidade212, opacidade405 y el periodo de ocurrencia de cada rutina de tipping
tceu=fltarr(2,num_corr+1); array que guardara las temperaturas atmosfericas efectivas en 212 y 205 GHz para c/r. de t.
toff=fltarr(2,num_corr+1);guardara el offset de temperaturas


for i=0,num_corr do begin
  fittau,b[x10[c10[0,2*i]:c10[1,2*i+1]]],reta,/noplot; reta es la variable de salida del fittau donde se guardas los valores calculados
  taust(0,i)=mean([reta.ch1.tau,reta.ch2.tau,reta.ch3.tau,reta.ch4.tau])
  taust(1,i)=mean([reta.ch5.tau,reta.ch6.tau])
  taust(2,i)=max(b[x10[c10[0,2*i]:c10[1,2*i+1]]].time)
  if taust(1,i) le taust(0,i) then taust(1,i)=4.5*taust(0,i)
  tceu(0,i)=max([reta.ch1.t_0,reta.ch2.t_0,reta.ch3.t_0,reta.ch4.t_0]); tceu es el /maximo de la temperatura atmosferica efectiva 
  tceu(1,i)= max([reta.ch5.t_0,reta.ch6.t_0])
  toff(0,i)= max([reta.ch1.t_off,reta.ch2.t_off,reta.ch3.t_off,reta.ch4.t_off]);
  toff(1,i)= max([reta.ch5.t_off,reta.ch6.t_off]);  
end
print, tceu
print, toff
;interpolacion lineal de los vlores de opacidad a lo largo del dia
if (num_corr ge 1) then begin
  t212=interpol(taust(0,*),0.1*taust(2,*),0.1*b.time) 
  t405=interpol(taust(1,*),0.1*taust(2,*),0.1*b.time)
  tsky212=interpol(tceu(0,*)+toff(0,*),0.1*taust(2,*),0.1*b.time)
  tsky405=interpol(tceu(1,*)+toff(0,*),0.1*taust(2,*),0.1*b.time)
endif else begin ; cuando solo se tiene una rutina de tiipping en el dia entonces...
  t212=taust(0)
  t405=taust(1)
  tsky212=mean(tceu[0,*])+mean(toff[0,*])
  tsky405=mean(tceu[1,*])+mean(toff[1,*])
endelse

;trabajando los valores de temperatura de cielo
;tsky212=mean(tceu(0,*));mean([reta.ch1.t_0,reta.ch2.t_0,reta.ch3.t_0,reta.ch4.t_0])
;tsky405=mean(tceu(1,*));mean([reta.ch5.t_0,reta.ch6.t_0])
;if (tsky212 gt taux212) then tsky212=taux212
;if (tsky405 gt taux405) then tsky405=taux405

;Vamos a introducir el polimonio de Rolhfs
zenital=90.0-b.elepos/1000.
secantez=1.0/cos(!pi*zenital/180.)
m_atm=-0.0045+1.00672*secantez-0.002234*secantez*secantez-0.0006247*secantez*secantez*secantez


maximo=5 ;limita el valor de correccion atmosferica a un maximo 
;aux212=exp(t212/sin(!dtor*b.elepos/1000.0))
aux212=exp(t212*m_atm)
aux212[where(aux212 gt maximo,/null)]=maximo

;aux405=exp(t405/sin(!dtor*b.elepos/1000.0))
aux405=exp(t405*m_atm)
aux405[where(aux405 gt maximo,/null)]=maximo


for k=0,5 do begin
  mira=double(b.adcval[k])*aux212-tsky212*(aux212-1)
  tope=mean(mira)+1.0*stddev(mira)
  mira[where(mira le 0,/null)]=0
  b.adcval[k]=uint(mira)
end

mira4=double(b.adcval[4])*aux405-tsky405*(aux405-1)
tope4=mean(mira4)+stddev(mira4)
mira4[where(mira4 le 0,/null)]=0
b.adcval[4]=uint(mira4)

mira5=double(b.adcval[5])*aux405-tsky405*(aux405-1)
tope5=mean(mira5)+stddev(mira5)
mira5[where(mira5 le 0,/null)]=0
b.adcval[5]=uint(mira5)

;set_plot,'ps'
;!p.font=0
;device,filename='atmosfera212.eps',/landscape,/encapsulated,/color,bits_per_pixel=8,xsize=24.,ysize=16.,/cm,xoffset=3.0,yoffset=27.0
;device,helvetica=1
;device,isolatin1=1
;!p.thick=4
;!x.thick=3
;!y.thick=3
;!z.thick=3
ylim1=max([max(b[nx10].adcval[0]),max(b[nx10].adcval[1]),max(b[nx10].adcval[2]),max(b[nx10].adcval[3])])
ylim0=min([min(b[nx10].adcval[0]),min(b[nx10].adcval[1]),min(b[nx10].adcval[2]),min(b[nx10].adcval[3])])
window,/free;,xs=1200,ys=800                                          
t_plot,0.1*b[nx10].time,b[nx10].adcval[0],psym=0,yrange=[ylim0,ylim1],title='Temperaturas com corr. atm. 212 GHz',ytitle='Temperatura (K)';,thick=3,charsize=2.0                   
t_plot,0.1*b[nx10].time,b[nx10].adcval[1],psym=0,/overplot,color=250;,thick=3,chars=2.0   
t_plot,0.1*b[nx10].time,b[nx10].adcval[2],psym=0,/overplot,color=150;,thick=3,chars=2.0
t_plot,0.1*b[nx10].time,b[nx10].adcval[3],psym=0,/overplot,color=60;,thick=3,chars=2.0
;device,/close_file
;set_plot,'x'

;;set_plot,'ps'
;;!p.font=0
;;device,filename='atmosfera405.eps',/encapsulated,/color,bits_per_pixel=8,xsize=24.,ysize=16.,/cm,xoffset=3.0,yoffset=27.0
;;device,helvetica=1
;;device,isolatin1=1
;;!p.thick=4
;;!x.thick=3
;;!y.thick=3
;;!z.thick=3
ylim3=max([max(b[nx10].adcval[4]),max(b[nx10].adcval[5])])
ylim2=min([min(b[nx10].adcval[4]),min(b[nx10].adcval[5])])
window,/free
t_plot,0.1*b[nx10].time,b[nx10].adcval[4],yrange=[ylim2,ylim3],color=20,title='Temperaturas com corr. atm. 405 GHz',ytitle='Temperatura (K)';,thick=3,charsize=2.0 
t_plot,0.1*b[nx10].time,b[nx10].adcval[5],/overplot;,thick=3,charsize=2.0
;;device,/close_file
;;set_plot,'x'


sinpar0=b.adcval[0]
sinpar1=b.adcval[1]
sinpar2=b.adcval[2]
sinpar3=b.adcval[3]
sinpar4=b.adcval[4]
sinpar5=b.adcval[5]


END

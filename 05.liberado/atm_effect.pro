;PRO atm_effect

num_corr=m10[2]/2-1
taust=fltarr(3,num_corr+1)
tceu=fltarr(2,num_corr+1)
for i=0,num_corr do begin
  fittau,b[x10[c10[0,2*i]:c10[1,2*i+1]]],reta,/noplot
  taust(0,i)=mean([reta.ch1.tau,reta.ch2.tau,reta.ch3.tau,reta.ch4.tau])
  taust(1,i)=mean([reta.ch5.tau,reta.ch6.tau])
  taust(2,i)=max(b[x10[c10[0,2*i]:c10[1,2*i+1]]].time)
  if taust(1,i) le taust(0,i) then taust(1,i)=4.5*taust(0,i)
  tceu(0,i)=mean([reta.ch1.t_0,reta.ch2.t_0,reta.ch3.t_0,reta.ch4.t_0])
  tceu(1,i)=mean([reta.ch5.t_0,reta.ch6.t_0])
end

if (num_corr ge 1) then begin
  t212=interpol(taust(0,*),0.1*taust(2,*),0.1*b.time) 
  t405=interpol(taust(1,*),0.1*taust(2,*),0.1*b.time)
  tsky212=interpol(tceu(0,*),0.1*taust(2,*),0.1*b.time)
  tsky405=interpol(tceu(1,*),0.1*taust(2,*),0.1*b.time)
endif else begin
  t212=taust(0)
  t405=taust(1)
  tsky212=tceu(0)
  tsky405=tceu(1) 
endelse

;trabajando los valores de temperatura de cielo
;tsky212=mean(tceu(0,*));mean([reta.ch1.t_0,reta.ch2.t_0,reta.ch3.t_0,reta.ch4.t_0])
;tsky405=mean(tceu(1,*));mean([reta.ch5.t_0,reta.ch6.t_0])
;if (tsky212 gt taux212) then tsky212=taux212
;if (tsky405 gt taux405) then tsky405=taux405


maximo=5 ;limita el valor de correccion atmosferica a un maximo 
aux212=exp(t212/sin(!dtor*b.elepos/1000.0))
aux212[where(aux212 gt maximo,/null)]=maximo

aux405=exp(t405/sin(!dtor*b.elepos/1000.0))
aux405[where(aux405 gt maximo,/null)]=maximo


for k=0,3 do begin
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
window,/free                                          
t_plot,0.1*b[nx10].time,b[nx10].adcval[0],yrange=[ylim0,ylim1],title='Canais 212 GHz',ytitle='Temperatura (K)',thick=3,charsize=2.0                   
t_plot,0.1*b[nx10].time,b[nx10].adcval[1],psym=3,/overplot,color=250,thick=3,chars=2.0   
t_plot,0.1*b[nx10].time,b[nx10].adcval[2],psym=3,/overplot,color=150,thick=3,chars=2.0
t_plot,0.1*b[nx10].time,b[nx10].adcval[3],psym=3,/overplot,color=60,thick=3,chars=2.0
;device,/close_file
;set_plot,'x'

;set_plot,'ps'
;!p.font=0
;device,filename='atmosfera405.eps',/encapsulated,/color,bits_per_pixel=8,xsize=24.,ysize=16.,/cm,xoffset=3.0,yoffset=27.0
;device,helvetica=1
;device,isolatin1=1
;!p.thick=4
;!x.thick=3
;!y.thick=3
;!z.thick=3
ylim3=max([max(b[nx10].adcval[4]),max(b[nx10].adcval[5])])
ylim2=min([min(b[nx10].adcval[4]),min(b[nx10].adcval[5])])
window,/free
t_plot,0.1*b[nx10].time,b[nx10].adcval[4],yrange=[ylim2,ylim3],color=20,title='Canais 405 GHz',ytitle='Temperatura (K)',thick=3,charsize=2.0 
t_plot,0.1*b[nx10].time,b[nx10].adcval[5],/overplot,thick=3,charsize=2.0
;device,/close_file
;set_plot,'x'


sin0=b.adcval[0]
sin1=b.adcval[1]
sin2=b.adcval[2]
sin3=b.adcval[3]
sin4=b.adcval[4]
sin5=b.adcval[5]


END 

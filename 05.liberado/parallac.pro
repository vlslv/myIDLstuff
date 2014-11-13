;PRO parallac

restore,'~/SST/rutinas/bpos.save'
;help,bpos
ntrak=where((b.opmode eq 2) OR (b.opmode eq 5) OR (b.opmode eq 10) OR (b.target/32 eq 1) OR (b.target/32 eq 2),complement=trak)
b=b[trak]
;inihour=
;finhour=
inde=searcht('18:40:00','19:04:59',b)
it=['18:40:00','19:04:59'] 


sst2offs,b,bpos,sou,bea,/noplot
;delvar,b_2
set_plot,'x'

loadct,39

;set_plot,'ps'
;!p.font=0
;device,filename='disc20130513_160000.eps',/landscape,/encapsulated,/color,bits_per_pixel=8,xsize=20.,ysize=20.,/cm,xoffset=3.0,yoffset=27.0
;device,helvetica=1
;device,isolatin1=1
;!p.thick=4
;!x.thick=3
;!y.thick=3
;!z.thick=3
window,/free,xs=600,ys=600
plot,bea[inde].ew[0],bea[inde].ns[0],psym=3,/isotropic,xrange=[-1500,1500],yrange=[-1500,1500],xstyle=1,ystyle=1,xtitle='E-W',ytitle='N-S';,thick=3,chars=1.5
oplot,bea[inde].ew[1],bea[inde].ns[1],color=250;,psym=3,thick=3
oplot,bea[inde].ew[2],bea[inde].ns[2],color=150;,psym=3,thick=3
oplot,bea[inde].ew[3],bea[inde].ns[3],color=60;,psym=3,thick=3
oplot,bea[inde].ew[4],bea[inde].ns[4],color=20;,psym=3,thick=3
hline,0
vline,0
plots,circle(0,0,979),color=210;thick=3
;device,/close_file
;set_plot,'x'



;radlim=1800. ;limita el radio a un valor limite
radius0=(bea[inde].ew[0]^2+bea[inde].ns[0]^2)^0.5
;radius0[where(radius0 gt radlim,/null)]=radlim   
radius1=(bea[inde].ew[1]^2+bea[inde].ns[1]^2)^0.5
;radius1[where(radius1 gt radlim,/null)]=radlim 
radius2=(bea[inde].ew[2]^2+bea[inde].ns[2]^2)^0.5
;radius2[where(radius2 gt radlim,/null)]=radlim  
radius3=(bea[inde].ew[3]^2+bea[inde].ns[3]^2)^0.5
;radius3[where(radius3 gt radlim,/null)]=radlim  
radius4=(bea[inde].ew[4]^2+bea[inde].ns[4]^2)^0.5
;radius4[where(radius4 gt radlim,/null)]=radlim  
radius5=(bea[inde].ew[5]^2+bea[inde].ns[5]^2)^0.5
;radius5[where(radius5 gt radlim,/null)]=radlim  

itg=0;alisado del radio geometrico

rad1=smooth(radius1,itg)
rad2=smooth(radius2,itg)
rad3=smooth(radius3,itg)
rad4=smooth(radius4,itg)
rad5=smooth(radius5,itg)
rad0=smooth(radius0,itg)

window,/free
t_plot,0.1*b[inde].time,radius0,yrange=[0,1800],title='Distance to the center'
t_plot,0.1*b[inde].time,radius1,/overplot,color=250;'ff'x
t_plot,0.1*b[inde].time,radius2,/overplot,color=150;'ff00'x
t_plot,0.1*b[inde].time,radius3,/overplot,color=60;'ff0000'x
t_plot,0.1*b[inde].time,radius4,/overplot,color=20;'ff00aa'x
t_plot,0.1*b[inde].time,radius5,/overplot;,psym=2

;erf_fact0=1-exp(-(979-rad0)^2./(2.*(1.2*240)^2.))
;erf_fact1=1-exp(-(979-rad1)^2./(2.*(1.2*240)^2.))
;erf_fact2=1-exp(-(979-rad2)^2./(2.*(1.2*240)^2.))
;erf_fact3=1-exp(-(979-rad3)^2./(2.*(1.2*240)^2.))
;erf_fact4=1-exp(-(979-rad4)^2./(2.*(1.2*240)^2.))
;erf_fact5=1-exp(-(979-rad5)^2./(2.*(1.2*240)^2.))

franc=250./6000.;valor de fondo de cielo 
erf_fact0=0.5*(1+erf((979-rad0)/(1.2*240)))+franc
erf_fact1=0.5*(1+erf((979-rad1)/(1.2*240)))+franc
erf_fact2=0.5*(1+erf((979-rad2)/(1.2*240)))+franc
erf_fact3=0.5*(1+erf((979-rad3)/(1.2*240)))+franc
erf_fact4=0.5*(1+erf((979-rad4)/(1.2*240)))+franc
erf_fact5=0.5*(1+erf((979-rad5)/(1.2*240)))+franc

;trabajos sobre el modelo de apontamiento
rlin0=svdfit(erf_fact0,b[inde].adcval[0],3)
fcnp0=rlin0[0]+erf_fact0*rlin0[1]+rlin0[2]*erf_fact0^2.0;+rlin0[3]*erf_fact0^3.
algo0s=max(fcnp0[where(fcnp0 EQ max(fcnp0))])/fcnp0
algo0s=smooth(algo0s,250)
tb0=(double(b[inde].adcval[0])*smooth(algo0s,100))
b[inde].adcval[0]=uint(tb0);=interpol(tbs0,0.1*bs.time,0.1*b.time)

rlin1=svdfit(erf_fact1,b[inde].adcval[1],3)
fcnp1=rlin1[0]+erf_fact1*rlin1[1]+rlin1[2]*erf_fact1^2.0;+rlin1[3]*erf_fact1^3.
algo1s=max(fcnp1[where(fcnp1 EQ max(fcnp1))])/fcnp1
algo1s=smooth(algo1s,250)
tb1=(double(b[inde].adcval[1])*smooth(algo1s,100))
b[inde].adcval[1]=uint(tb1);=interpol(tbs0,0.1*bs.time,0.1*b.time)
;tb1=interpol(tbs1,0.1*bs.time,0.1*b.time)

rlin2=svdfit(erf_fact2,b[inde].adcval[2],3)
fcnp2=rlin2[0]+erf_fact2*rlin2[1]+rlin2[2]*erf_fact2^2.0;+rlin2[3]*erf_fact2^3.
algo2s=max(fcnp2[where(fcnp2 EQ max(fcnp2))])/fcnp2
algo2s=smooth(algo2s,250)
tb2=(double(b[inde].adcval[2])*smooth(algo2s,100))
b[inde].adcval[2]=uint(tb2);=interpol(tbs0,0.1*bs.time,0.1*b.time)
;tb2=interpol(tbs2,0.1*bs.time,0.1*b.time)

rlin3=svdfit(erf_fact3,b[inde].adcval[3],3)
fcnp3=rlin3[0]+erf_fact3*rlin3[1]+rlin3[2]*erf_fact3^2.0;+rlin3[3]*erf_fact3^3.
algo3s=max(fcnp3[where(fcnp3 EQ max(fcnp3))])/fcnp3
algo3s=smooth(algo3s,250)
tb3=(double(b[inde].adcval[3])*smooth(algo3s,100))
b[inde].adcval[3]=uint(tb3);=interpol(tbs0,0.1*bs.time,0.1*b.time)
;tb3=interpol(tbs3,0.1*bs.time,0.1*b.time)

rlin4=svdfit(erf_fact4,b[inde].adcval[4],3)
fcnp4=rlin4[0]+erf_fact4*rlin4[1]+rlin4[2]*erf_fact4^2.0;+rlin4[3]*erf_fact4^3.
algo4s=max(fcnp4[where(fcnp4 EQ max(fcnp4))])/fcnp4
algo4s=smooth(algo4s,250)
tb4=(double(b[inde].adcval[4])*smooth(algo4s,100))
;b.adcval[0]=uintn(tb0);=interpol(tbs0,0.1*bs.time,0.1*b.time)
;tb4=interpol(tbs4,0.1*bs.time,0.1*b.time)

rlin5=svdfit(erf_fact5,b[inde].adcval[5],3)
fcnp5=rlin5[0]+erf_fact5*rlin5[1]+rlin5[2]*erf_fact5^2.0;+rlin5[3]*erf_fact5^3.
algo5s=max(fcnp5[where(fcnp5 EQ max(fcnp5))])/fcnp5
algo5s=smooth(algo5s,250)
tb5=uint(double(b[inde].adcval[5])*smooth(algo5s,100))
;b.adcval[0]=uintn(tb0);=interpol(tbs0,0.1*bs.time,0.1*b.time)
;tb5=interpol(tbs5,0.1*bs.time,0.1*b.time)


;set_plot,'ps'
!p.font=0
;device,filename='point_mod212.eps',/landscape,/encapsulated,/color,bits_per_pixel=8,xsize=24.,ysize=16.,/cm,xoffset=3.0,yoffset=27.0
;device,helvetica=1
;device,isolatin1=1
;!p.thick=4
;!x.thick=3
;!y.thick=3
;!z.thick=3
ylim1=max([max(algo0s),max(algo1s),max(algo2s),max(algo3s)])
ylim0=min([min(algo0s),min(algo1s),min(algo2s),min(algo3s)])
window,/free
t_plot,0.1*b[inde].time,algo0s[inde],psym=3,xstyle=1,ystyle=1,yrange=[ylim0,ylim1],$
title='Fator de correc. p/canais 212 GHz';,thick=3,chars=2.0
t_plot,0.1*b[inde].time,algo1s,psym=3,/overplot,color=250;,xrange=it;,thick=3,chars=2.0
t_plot,0.1*b[inde].time,algo2s,psym=3,/overplot,color=150;,xrange=it;,thick=3,chars=2.0
t_plot,0.1*b[inde].time,algo3s,psym=3,/overplot,color=50;,xrange=it;,thick=3,chars=2.0
;device,/file_close
;set_plot,'x'

;;set_plot,'ps'
;;!p.thick=3
;;!x.thick=3
;;!y.thick=3
;;!z.thick=3
;;device,filename='pnt405.eps',/encapsulated,/color,bits_per_pixel=8,/tt_font,set_font='Times',font_size=10
ylim3=max([max(fcnp4),max(fcnp5)])
ylim2=min([min(fcnp4),min(fcnp5)])
window,/free
t_plot,0.1*b[inde].time,fcnp4,psym=3,xstyle=1,ystyle=1,yrange=[ylim2,ylim3],color=20,title='modelo 405 GHz';,thick=3,chars=2.0
t_plot,0.1*b[inde].time,fcnp5,psym=3,/overplot;,thick=3,charsize=2.0
;;device,/file_close
;;set_plot,'x'


;set_plot,'ps'
;!p.font=0
;device,filename='tbrillo212.eps',/landscape,/encapsulated,/color,bits_per_pixel=8,xsize=24.,ysize=16.,/cm,xoffset=3.0,yoffset=27.0
;device,helvetica=1
;device,isolatin1=1
;!p.thick=4
;!x.thick=3
;!y.thick=3
;!z.thick=3
increm=0

ylim1=max([max(tb0)+increm,max(tb1),max(tb2),max(tb3)])
ylim0=min([min(tb0)+increm,min(tb1),min(tb2),min(tb3)])
window,/free
t_plot,0.1*b[inde].time,smooth(tb0,25)+increm,psym=3,xstyle=1,ystyle=1,$
yrange=[0.5*ylim0,1.5*ylim1],title='TB Canais 212 GHz';,ya=2;,thick=3,chars=2.0
t_plot,0.1*b[inde].time,smooth(tb3,25),psym=3,/overplot,color=50;,ya=3;,thick=3
t_plot,0.1*b[inde].time,smooth(tb2,25),psym=3,/overplot,color=150;,thick=3
t_plot,0.1*b[inde].time,smooth(tb1,25),psym=3,/overplot,color=250;,thick=3
;device,/close_file
;set_plot,'x'

;;set_plot,'ps'
;;device,filename='tbrillo405.eps',/encapsulated,/color,bits_per_pixel=8
ylim3=max([max(tb4),max(tb5)])
ylim2=min([min(tb4),min(tb5)])
window,/free
t_plot,0.1*b[inde].time,tb4,psym=3,xstyle=1,ystyle=1,color=20,yrange=[ylim2,ylim3],title='TB Canais 405 GHz';,$
;;;'ff00aa'x,thick=2
t_plot,0.1*b[inde].time,tb5,psym=3,/overplot;,thick=2
;;device,/close_file
;;set_plot,'x'

end

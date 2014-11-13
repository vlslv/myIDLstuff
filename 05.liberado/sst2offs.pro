function get_sun_coord,jd

openw,1,'jd.bin'
writeu,1,jd
close,1
spawn,'~/solar/sst/ephem_calc/fephem sst 11 jd.bin pos.out'
jpl={jd:0.0d, ra:0.0, dec:0.0, az:0.0,el:0.0,p:0.0,lst:0.0}
jpl=replicate(jpl,n_elements(jd))
openr,1,'pos.out'
readu,1,jpl
close,1
return,jpl
end

pro sst2offs,data,Obpos,source,beams,pnt_beam=pntb,pnt_center=pntc,humi=humi,temp=temp,$
    pres=pres,file_mag=file_mag,rop=rop,nopang=nopang, $
    sazel=sazel,nolab=nolab,mag=mag,notitle=notitle,$
    x_off=x_off,y_off=y_off,colored=colored,aux_off=aux_off,$
    mbeam=mbeam, helio=helio,reverse=reverse,noplot=noplot,quiet=quiet

;+
; NAME:
;	SST2OFFS
; PURPOSE:
; 	Program to convert from SST Az-El to Sun Disc Offsets
;
; CALLING SEQUENCE:
;          sst2offs,data,bpos,source,beams,pnt_beam=pntb,pnt_center=pntc,humi=humi,temp=temp,$
;          pres=pres,rop=rop,nopang=nopang, $
;          sazel=sazel,nolab=nolab,notitle=notitle,$
;          x_off=x_off,y_off=y_off,colored=colored,aux_off=aux_off,$
;          helio=helio,reverse=reverse,noplot=noplot
;
; INPUTS:
; 	data		: structure from READ_SST
;	Obpos		: structure with beam positions
;			  off[6]    : OFF of each beam in arc min
; 			  el[6]     : ELEV of each beam in arc min.
;
; KEYWORDS (additional inputs/outputs)
;	Rop		: (input) Optical radius in arcsec
;	nopang		: if set, DO NOT compute the Solar P Angle and DO NOT rotate the
;	                  image. 
; 	sazel		: (input) a vector with source positions (in the frame of the beams, arcmin)
;                         sazel[0,*]: offsets ; sazel[1,*]: elevation
;	/nolab		: no beam's labels
;       temp            : (input) floating with atmospheric temperature [C]. If not
;                         set, 20 C assumed.
;       pres            : (input) floating with atmospheric pressure [mm Hg]. If not set,
;                         590 mm Hg assumed.
;       hum             : (input) floating with atmospheric humidity [%].  If not set
;                         0% assumed. 
;       x_off           : (input) Longitude of the source position in Hel Coord. [Deg]
;       y_off           : (input) Latitude of the source position in Hel Coord.  [Deg]
;       aux_off         : (input) unnamed array with auxiliary offsets in azimuth (aux_off[0])
;                         and elevation  (aux_off[1]) [in degress].  This
;                         auxiliary offset is ADDED to azipos and elepos of
;                         data structure
;	helio		: (output) Heliographic Latitude of SST sources.  [deg]
;
;
; OUTPUTS:
;	source		: source position in EW and NS arcsec from disk center
;       beams		: Beam Position in EW and NS arcsec from disk center
;
;
; HYSTORY:
;       From pos.pro, Adriana's original programme
;	Written by Guigue 
;	        May 2011 
;
;-

if (not keyword_set(colored)) then colored=0
if (keyword_set(reverse)) then revers=1 else revers=0
if keyword_set(sazel) then flag_sazel=1b else flag_sazel=0b
if keyword_set(quiet) then verbose=0b else verbose=1b

s_name=tag_names(data,/structure)
ldate = long(strmid(s_name,2,strlen(s_name)-1))
dd    = ldate mod 100
mm    = (ldate / 100) mod 100
yy    = (ldate / 10000) + 1900
date  = strcompress(yy,/rem)+'-'+strcompress(mm,/rem)+'-'+$
  strcompress(dd,/rem)

bpos  = Obpos
; New pointing Model (after Patrick Wallace)
if (ldate gt 1061125) then begin
   bpos.el = -bpos.el
   if flag_sazel then sazel[1,*]=-sazel[1,*]
endif

; beam sizes in arcsec
bwhp=[4.,4.,4.,4.,2.,2.]*60

if keyword_set(pntb) then begin
   beamcenter=[bpos.off[pntb],bpos.el[pntb]] 
endif else begin
   if keyword_set(pntc) then begin
      beamcenter=pntc 
   endif else begin
      ;pnt_beam=4 ; intento de correccion en junio/29/2012
      beamcenter=[bpos.off[4],bpos.el[4]]      
   endelse
endelse

if verbose then print,beamcenter,format='("Pointing to = (",f6.2," , ",f6.2,")")'

sstlong = -69.29669444 
jd      = julday(mm,dd,yy,data.time/3.6d7)
sst_sunpos,jd,ephra,ephdec
sst_ct2lst,hsid,sstlong,3,jd
sst2azel,hsid,ephra / 15.,ephdec,azi,ele

if not keyword_set(aux_off) then aux_off=[0.0,0.0]
xx  = data.azipos / 1000.+ aux_off[0] / cos(data.elepos*!dtor/1000.)
yy  = data.elepos / 1000.+ aux_off[1]

;
;
;----------------------------------------------------------------------------
;
; pointing model
;
;----------------------------------------------------------------------------
;
if (ldate lt 1020525) then begin
    az0 = 70.6
    phi =  0.080
    ia  = -1.17
    p   =  0.0
    off =  bpos.off[pnt_beam] / 60.
    ie  =  bpos.el[pnt_beam] / 60.
    g   =  0.0

    dazi = phi*sin((azi-az0)*!dtor)*tan(ele*!dtor)+off/cos(ele*!dtor)+ia+p*tan(ele*!dtor)
    dele = phi*cos((azi-az0)*!dtor)+g*ele+ie
    
endif else begin

    dazi = float(data.pm_daz)/1000.
    dele = float(data.pm_del)/1000.

endelse

;
; Computing Refraction
;

if not keyword_set(temp) then begin
    temp = 0.0
    if verbose then print,'Assuming Atmospheric Temperature = ',temp,' C'
endif 

if not keyword_set(pres) then begin
    pres=590.0
    if verbose then print,'Assuming Atmospheric Pressure = ',pres,' mm Hg'
endif 

if not keyword_set(humi) then begin
    humi=20.0
    if verbose then print,'Assuming Atmospheric Pressure = ',humi,' %'
endif 

ctok = 273.15
MM_HG_2_HPa=1.333333
PMIN = 1.00E-6  
ZMAX = 1.55

if (ldate lt 1061120) then begin

    esat = 23.636-(2948./(temp+ctok))-5.*alog10(temp+ctok)
    wat  = (10.^esat)*humi/100.
    
    r    = 21.36*pres/(temp+ctok)-1.66*wat/(temp+ctok)+103030.*wat/(temp+ctok)^2
    refr = r*cos(ele*!dtor)/sin(ele*!dtor)+0.00175*tan((87.5-ele)*!dtor)
    refr = refr/3600.

endif else begin

    z    = (90.0 - ele) * !dtor < zmax
    tk   = temp+ctok
    rh   = humi/100.0
    pmb  = pres * MM_HG_2_HPa
    if ( pmb ge PMIN ) then begin

        ps = 10.0d0^(((0.03477 * tk - 8.71170) / $
		     (0.00412 * tk - 0.12540)) * (1.0 + pmb * 4.5e-6))

        pw = rh * ps / ( 1.0 - ( 1.0 - rh ) * ps / pmb ) 
        b = 4.4474e-6 * tk * ( 1.0 - 0.0074 * pw ) 
        s = sin ( z )
        c = cos ( z )           ;
        refr = -( ( 77.6890e-6 * pmb - ( 6.3938e-6 - 0.375463 / tk ) * pw ) / tk ) * $
          ( 1.0 - b ) * s $
          / sqrt ( c * c + 0.001908 + 0.6996 * b - 0.00003117 * s / c ) / !dtor 
        
    endif else refr = 0.0

endelse

;
; End Refraction
;

;
; Fix Coordinate Positions
;
xx = xx - dazi
yy = yy - (dele+refr)

;---------------------------------------------------------
;
; END Pointing Model
;
;---------------------------------------------------------


ni   = n_elements(data)
sra  = fltarr(ni)
sdec = fltarr(ni)

ra   = fltarr(ni,6)
dec  = fltarr(ni,6)

xc   = fltarr(ni,6)
yc   = fltarr(ni,6)
dra  = fltarr(ni,6)
ddec = fltarr(ni,6)

for i = 0,5 do begin
   xc[*,i]  = xx - (bpos.off[i] - beamcenter[0]) / (60.0 * cos(yy*!dtor))
   yc[*,i]  = yy - (bpos.el[i] - beamcenter[1]) / 60.0
   sst2radec,hsid,xc[*,i],yc[*,i],bra,bdec
   ra[*,i]  = bra * 15.0
   dec[*,i] = bdec
endfor

for i=0,5 do ddec[*,i]  = (dec[*,i] - ephdec) * 3600.
for i=0,5 do dra[*,i]   = (ra[*,i]  - ephra)  * 3600. * cos(dec[*,i]*!dtor)

if not flag_sazel then begin
    saz = 0.0
    sel = 0.0
endif else begin
    saz =   (sazel[0,*] - beamcenter[0])
    sel =   (sazel[1,*] - beamcenter[1])
endelse

xs   = xx - saz / (60. * cos(yy*!dtor))
ys   = yy - sel / 60.
sst2radec,hsid,xs,ys,bra,bdec
sra  = bra * 15.0
sdec = bdec
sddec= (sdec - ephdec)  * 3600.0 
sdra = (sra  - ephra)   * 3600.0 * cos(sdec*!dtor)

if not keyword_set(nopang) then begin

   sephem = get_pb0(jd)
   pangle = sephem[4]
   bangle = sephem[3]
   SRad   = sephem[1]

endif else begin

   pangle = 0.0
   bangle = 0.0
   SRad   = (get_pb0(jd))(1)

endelse

;
; Beam Pos in Ra/Dec corrected for P Angle rotation
; Revertion of dra, sdra sign because RA is negative
; Eastwards.
;
dra  = -dra
bew  = dra * cos(pangle*!dtor) + ddec * sin(pangle*!dtor)
bns  = ddec * cos(pangle*!dtor) - dra * sin(pangle*!dtor)

sdra = -sdra
sew  = sdra * cos(pangle*!dtor) + sddec * sin(pangle*!dtor)
sns  = sddec * cos(pangle*!dtor) - sdra * sin(pangle*!dtor)

;
; Heliographic Coordinates of Source
; Revertion of sdra sign is not needed because radec_hel takes into account this.
;

if arg_present(helio) then begin
  hslat=fltarr(ni)
  hslon=fltarr(ni)

  for i = 0l, ni-1 do $
     radec_hel,sdra[i]/60.,sddec[i]/60.,pangle,bangle,SRad/60.0,hslat[i],hslon[i]
    helio={lat:0.0,lon:0.0}
    helio=replicate(helio,ni)
    helio.lat=reform(hslat)
    helio.lon=reform(hslon)
endif

; Create the output structures
source={ew:0.0,ns:0.0}
source=replicate(source,ni)
source.ew=reform(sew)
source.ns=reform(sns)

beams={ew:fltarr(6),ns:fltarr(6)}
beams=replicate(beams,ni)
for i=0l,ni-1 do begin
  beams[i].ew=reform(bew[i,*])
  beams[i].ns=reform(bns[i,*])
endfor


;
;-------------------------------------------------------------
;
; Now, Plot!
;
;-------------------------------------------------------------
;
if not keyword_set(noplot) then begin

  if (colored) then begin
    tvlct,v1,v2,v3,/get         ; save original table color
    c=200                       ; color
  endif else c=255

; Create Sun data
  ang  = findgen(181)*2*!dtor
  rsun = SRad/3600.
  x    = cos(ang)
  y    = sin(ang)

  pmulti=!p.multi
  pfont =!p.font
  !p.multi=0

  if (!d.name eq 'PS') then begin

    device,xsize=15,ysize=15,xoff=4,yoff=5,/helvetica,filen='pos.ps'
    !p.font = 0 
    c=0

  endif else begin
    
    loadct,12
    window,/free,xs=600,ys=600,title='Beam Positions'

  endelse
    

  if (colored) then loadct,5
  if (revers) then begin
      fg=0 & bkg=255
  endif else begin
      fg=255 & bkg=0
  endelse
  
  plot,SRad*x,SRad*y,xtitle='E-W (arcsec)',ytitle='N-S (arcsec)', $
    title=date+' - '+adstring(data(ni/2).pos_time/3.6e7)+' UT', $
    xr=[-1300,1300],yr=[-1300,1300],/nodata,xs=1,ys=1,$ ;font=6
    col=fg,back=bkg,chars=1.5
  if (revers) then c=0
  oplot,SRad*x,SRad*y,col=c,thick=3

; plota circulos

   if (colored) then c1=125 else if (!d.name eq 'X') then if (revers) then c1=0 else c1=255 else c1=0
   for i=0,5 do begin
	   oplot,bwhp[i]/2.*cos(ang)+bew[0,i],bwhp[i]/2.*sin(ang)+bns[0,i], $
	   color=c1,thick=tt
   endfor
   
   if(keyword_set(nolab) eq 0) then for i=0,5 do  $
      xyouts,bew(0,i),bns(0,i),strcompress(i+1,/rem),chart=tt,col=c,chars=1.5
   
   if((saz[0] ne 0) and (sel[0] ne 0)) then $
	   for i=0l,ni-1 do plots,sew[i],sns[i],psym=2,color=c,syms=2,thick=tt
   
   if (keyword_set(x_off) and keyword_set(y_off)) then begin 
     hel_radec, y_off, x_off, pangle, bangle, srad, off_ra, off_dec
     off_ra = -off_ra
     off_ew  = off_ra * cos(pangle*!dtor) + off_dec * sin(pangle*!dtor)
     off_ns  = off_dec * cos(pangle*!dtor) - off_ra * sin(pangle*!dtor)
     oplot,[off_ew,off_ew],[off_ns,off_ns],psym=1,col=200,syms=2.0
   endif
   
   if (!d.name eq 'PS') then device,/close
   
   ; restore the original state
   !p.multi=pmulti
   !p.font=pfont
   if (colored) then tvlct,v1,v2,v3

endif
   
end
   

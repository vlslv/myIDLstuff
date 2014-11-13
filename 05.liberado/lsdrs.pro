;PRO lsdrs

;lectura de datos
datac = DIALOG_PICKFILE(path='/adhara/fvalle/SST/Y*/M*/D*/intg',/read,filter='rs*')
file_uncompress,datac,datad
read_sst,rs,datad,recr=10000000,/close
;help,rs

;rs=rs[where(rs.time ne 0)]
rs=rs[uniq(rs.time,sort(rs.time))]; ordena (y elimina valores repetidos de...) el vector tiempo
rs=rs[where(rs.time ne 0)]; elimina los datos donde el vector tiempo es cero

ro=rs; copia de la estructura original

device,decomposed=1

xc=where(rs.target /32 eq 1); indices de fonte fria
xh=where(rs.target /32 eq 2); indices de fonte quente
xcal=[xc,xh]
x0=where(rs.opmode eq 0); indices de track
x2=where(rs.opmode eq 2); ...map_azel
x5=where(rs.opmode eq 5); ...scan_az
x10=where(rs.opmode eq 10); ...scan_tau
x90=where(rs.elepos ge 85)

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

if ( n_elements(xc) le 1 ) then print,'Nao existe dados para calibracao de temperatura'

if ( n_elements(x2) le 1 ) then print,'Nao existe mapa do Sol'

if ( n_elements(x5) le 1 ) then print,'Nao existe scan em azimuth do Sol'

if ( n_elements(x10) le 1 ) then print,'Nao existe scan do ceú'

while !d.window ne -1 do wdelete, !d.window ; cierra las ventanas existentes 
window,/free
!P.MULTI = [0, 1, 6]
plot,ro.adcval[0],ys=1,psym=3
;window,11
plot,ro.adcval[1],ys=1,psym=3
;window,12
plot,ro.adcval[2],ys=1,psym=3
;window,13
plot,ro.adcval[3],ys=1,psym=3
;window,14
plot,ro.adcval[4],ys=1,psym=3
;window,15
plot,ro.adcval[5],ys=1,psym=3

!p.multi=0
end

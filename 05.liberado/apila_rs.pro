;PRO apila_rs

m='M03' ; cambie aqui el mes 
d='D06' ; cambie aqui el dia a analizar
bname='RS1120306'

camino=file_search('SST/Y2012/'+m+'/'+d+'/intg/rs*.*00')
nufi1=n_elements(camino)-1
nufi2=n_elements(camino)-2
nelacum=0

;split_path_name=strsplit(camino[0],'intg/',/extract,/regex)
;split_name_exte=strsplit(split_path_name[1],'.',/extract)
;name=split_name_exte[0]

for i=0,nufi1 do begin
  read_sst,b,camino[i],recr=1000000,/close
  nel=n_elements(b)
  nelacum=nelacum+nel
end



base={RS1120306,time:0l,adcval:uintarr(6),pos_time:0l,azipos:0l,elepos:0l,pm_daz:0,pm_del:0,azierr:0l,$
eleerr:0l,x_off:0,y_off:0,target:12b,opmode:0b,gps_status:0,recnum:0l } 

barre=replicate({RS1120306},nelacum-nufi1)

ini=0
fin=0

for i=0,nufi1 do begin
  read_sst,b,camino[i],recr=1000000,/close
  nel=n_elements(b)
  fin=fin+nel-1
  barre[ini:fin].time=b.time
  barre[ini:fin].adcval=b.adcval
  barre[ini:fin].pos_time=b.pos_time
  barre[ini:fin].azipos=b.azipos
  barre[ini:fin].elepos=b.elepos
  barre[ini:fin].pm_daz=b.pm_daz
  barre[ini:fin].pm_del=b.pm_del
  barre[ini:fin].azierr=b.azierr
  barre[ini:fin].eleerr=b.eleerr
  barre[ini:fin].x_off=b.x_off
  barre[ini:fin].y_off=b.y_off
  barre[ini:fin].target=b.target
  barre[ini:fin].opmode=b.opmode
  barre[ini:fin].gps_status=b.gps_status
  barre[ini:fin].recnum=b.recnum
  ;barre[ini:fin]=b
  ini=fin
end
;b.bname=barre.bname

b=barre

end

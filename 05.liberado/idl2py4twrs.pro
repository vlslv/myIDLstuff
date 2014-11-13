;PRO idl2py4twrs

; abre uno o varios arquivos binarios rs1yymmdd y los salva 
; en la pasta ~/SST/Yyyy/Mm/Dd/
; con el nombre rs1yymmdd.hhmm.save para leerlos em python

;lectura y limpieza de datos
datacompr = DIALOG_PICKFILE(/multi,path='/adhara/fvalle/SST/Y20*/M*/D*/intg/',/read,filter='rs*')
n_files=n_elements(datacompr)

; check if the user cancels the dialog
if (n_files eq 1 && datacompr[0] eq '') then n_files = 0

time=[]
adcval=[]


for j=0, n_files-1 do begin
  file_uncompress,datacompr[j],datadescom; descomprime el archivo, si lo está
  read_sst,rs,datadescom,recr=500000,/close
  extractedStr = STRMID(datadescom, 13, 14, /REVERSE_OFFSET); rs1yymmdd para nombrar arq el save
  origin_path = STRMID(datadescom,0,33)

  for i=0,5 do begin
    rs=rs[where(rs.adcval[i] gt 0)]; elimina los zeros de los canales de adc
  end

  rs=rs[uniq(rs.time,sort(rs.time))]; ordena (y elimina valores repetidos de...) el vector tiempo
  rs=rs[where(rs.time ne 0)]; elimina los datos donde el vector tiempo es cero

  time = time + rs.time
  adcval = adcval + rs.adcval
  pos_time = rs.pos_time
  azipos = rs.azipos
  elepos = rs.elepos
  pm_daz = rs.pm_daz
  pm_del = rs.pm_del
  azierr = rs.azierr
  eleerr = rs.eleerr
  x_off = rs.x_off
  y_off = rs.y_off
  off = rs.off
  ;sigma = b.sigma
  gps_status = rs.gps_status
  ;acq_gain = b.acq_gain
  target = uint(rs.target)
  opmode = uint(rs.opmode)
  recnum = rs.recnum
;hot_temp = b.hot_temp
;amb_temp = b.amb_temp
;opt_temp = b.opt_temp
;if_board_temp = b.if_board_temp
;radome_temp = b.radome_temp
;humidity = b.humidity
;temperature = b.temperature
;opac_212 = b.opac_210
;opac_405 = b.opac_405
;elevation = b.elevation
;pressure = b.pressure
;burst = uint(b.burst)
;errors =  b.errors

  destiny_path = origin_path
  salvado = destiny_path + extractedStr + '.save' 

  save,$
  time, azipos, elepos, azierr, eleerr, adcval, gps_status, target,$
  opmode, off ,pos_time, pm_daz, pm_del, x_off,y_off, recnum,$
  filename=salvado
end

END

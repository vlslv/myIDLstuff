;PRO idl2py4bi

;abre arquivos binarios rs1yymmdd y los salva en un arquivo foo.save para leerlos em python

;lectura y limpieza de datos
datacompr = DIALOG_PICKFILE(/multi,path='/adhara/fvalle/SST/Y20*/M*/D*/instr/',/read,filter='bi*')
n_files=n_elements(datacompr)

; check if the user cancels the dialog
if (n_files eq 1 && datacompr[0] eq '') then n_files = 0

for j=0, n_files-1 do begin
  file_uncompress,datacompr,datadescom; descomprime el archivo, si lo está
  read_sst,b,datadescom,recr=500000,/mon,/close
  extractedStr = STRMID(datadescom, 8, 9, /REVERSE_OFFSET); rs1yymmdd para nombrar arq el save
  origin_path = STRMID(datacompr, 0,33)

  for i=0,5 do begin
    b=b[where(b.adc[i] gt 0)]; elimina los zeros de los canales de adc
  end

  b=b[uniq(b.time,sort(b.time))]; ordena (y elimina valores repetidos de...) el vector tiempo
  b=b[where(b.time ne 0)]; elimina los datos donde el vector tiempo es cero

  time = b.time
  azipos = b.azipos
  elepos = b.elepos
  azierr = b.azierr
  eleerr = b.eleerr
  adc = b.adc
  sigma = b.sigma
  gps_status = b.gps_status
  acq_gain = b.acq_gain
  target = uint(b.target)
  opmode = uint(b.opmode)
  off = b.off
  hot_temp = b.hot_temp
  amb_temp = b.amb_temp
  opt_temp = b.opt_temp
  if_board_temp = b.if_board_temp
  radome_temp = b.radome_temp
  humidity = b.humidity
  temperature = b.temperature
  opac_212 = b.opac_210
  opac_405 = b.opac_405
  elevation = b.elevation
  pressure = b.pressure
  burst = uint(b.burst)
  errors =  b.errors


  destiny_path = origin_path
  salvado = destiny_path + extractedStr + '.save' 

  save,$
  time, azipos, elepos, azierr, eleerr, adc, sigma, gps_status, acq_gain, target, opmode,$
  off, hot_temp, amb_temp, opt_temp, if_board_temp, radome_temp, radome_temp, humidity,$
  temperature, opac_212, opac_405, elevation, pressure, burst, errors,$
  filename=salvado
end

END

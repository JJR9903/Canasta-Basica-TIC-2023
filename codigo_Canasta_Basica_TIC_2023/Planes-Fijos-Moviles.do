/*==================================================
project:		DNP Canasta Basica TIC       
name: 			Planes-Fijos-movil
description:	importa y analiza los datos de los planes fijos y movil a nivel departamental
Author:        Juan José Rincón 
E-email:       j.rincon@econometria.com
url:           
Dependencies:  Econometría Consultores
----------------------------------------------------
Creation Date:    13 oct 2023 - 14:40:23
Modification Date:   13 oct 2023 - 14:40:23
Do-file version:    01
References: CRC Planes Fijos y Moviles
Output: 
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
version 18
drop _all

clear all
cls

set dp comma 

cd "/Users/juanjose/Library/CloudStorage/GoogleDrive-j.rincon@econometria.com/Mi unidad/DNP - Canasta B TIC/Canasta-Basica-TIC-2023/"

global Original_MINTIC "cuanti_secund_Canasta_Basica_TIC_2023/BASES-DE-DATOS-MinTIC-CRC"
global Original_CRC "cuanti_secund_Canasta_Basica_TIC_2023/CRC-T12-T13"


global gf "resultad_Canasta_Basica_TIC_2023/producto1/fijo/graficas"
global tb "resultad_Canasta_Basica_TIC_2023/producto1/fijo/tablas"
global Access "ACCESOS_INTERNET_FIJO"




/*====================================================================================================
              1: Importar datos de hogares 
====================================================================================================*/


*----------1.1: importar datos

tempfile Hogares_Mpio

import excel "cuanti_secund_Canasta_Basica_TIC_2023/anexo-proyecciones-hogares-dptal-2018-2050-mpal-2018-2035.xlsx", sheet("Hogares mpio 19-22") first clear


keep CodDepto Departamento CodMun Municipio Hogares2022

save `Hogares_Mpio', replace

tempfile Hogares_Depto

import excel "cuanti_secund_Canasta_Basica_TIC_2023/anexo-proyecciones-hogares-dptal-2018-2050-mpal-2018-2035.xlsx", sheet("Hogares Dpto 2022") first clear


keep CodDepto Departamento Hogares2022

save `Hogares_Depto', replace


tempfile Personas_Mpio

import excel "cuanti_secund_Canasta_Basica_TIC_2023/DCD-area-proypoblacion-Mun-2020-2035-ActPostCOVID-19.xlsx", sheet("Municipios") first clear

gen CodMun = string(COD_MUN)
replace CodMun = "0" + CodMun if strlen(CodMun)==4

gen CodDepto = string(COD_DEPTO)
replace CodDepto = "0" + CodDepto if strlen(CodDepto)==1

rename MUNICIPIO Municipio
rename DEPARTAMENTO Departamento

keep CodDepto Departamento CodMun Municipio POBLACION

format POBLACION %9.0fc

save `Personas_Mpio', replace

tempfile Personas_Depto

collapse (sum) POBLACION, by(CodDepto Departamento)

save `Personas_Depto', replace




/*====================================================================================================
              2: Importar datos de lineas moviles por municipio
====================================================================================================*/


*----------2.1: importar datos
tempfile Moviles_Mpio

import excel "cuanti_secund_Canasta_Basica_TIC_2023/BASES-DE-DATOS-MinTIC-CRC/Res 175 - F1.2 lineas moviles por municipio 2021 2023 V2.xlsx", sheet("F 1,2") firstrow clear


*----------2.2: cambiar codificacion de los municipios

gen CodMun = string(COD_MUNICIPIO)
replace CodMun = "0" + CodMun if strlen(CodMun)==4

replace CodMun="27615" if CodMun=="27086" 

drop COD_DEPARTAMENTO DEPARTAMENTO COD_MUNICIPIO MUNICIPIO


*----------2.3: Nos quedamos solo con la información del 4 trimestre de 2022 


keep if ANNO==2022 & TRIMESTRE==4 & MES_DEL_TRIMESTRE==3

*collapse (mean) TOTAL_LINEAS_EN_SERV_TRAFICO LINEAS_EN_SERV_PREPAGO LINEAS_EN_SERV_POSTPAGO ,by(CodMun NIT DV EMPRESA)


*----------2.4: agrupamos la informacion por municipio

collapse (sum) LineasMovil=TOTAL_LINEAS_EN_SERV_TRAFICO LineasMovil_Prepago=LINEAS_EN_SERV_PREPAGO LineasMovil_Pospago=LINEAS_EN_SERV_POSTPAGO ,by(CodMun)

format LineasMovil LineasMovil_Prepago LineasMovil_Pospago %9.0fc


merge 1:1 CodMun using `Personas_Mpio', keep(3) nogen


save `Moviles_Mpio', replace 




/*====================================================================================================
              2: Importar datos del formato T.1.3 
====================================================================================================*/


*----------2.1: importar datos

import delimited "$Original_CRC/FT_1_3.csv", delimiter(";") clear



*----------2.2: Nos quedamos solo con los accesos residenciales 

drop if segmento=="Corporativo" | segmento=="Uso propio interno del operador"

keep if trimestre==4 & anno==2022

** nos quedamos con los que tienen algun servicio de internet
drop if id_servicio_paquete==2 | id_servicio_paquete==3 | id_servicio_paquete==6 



*----------2.3: agrupar las empresas por cantidad de accesos
rename cantidad_lineas_accesos Accesos

egen AccesosEmpresa = total(Accesos), by(id_empresa)

gen Empresa = "-1.000"*(AccesosEmpresa<=1000) + "1.000-2.000"*(AccesosEmpresa>1000 & AccesosEmpresa<=2000) + "2.000-5.000"*(AccesosEmpresa>2000 & AccesosEmpresa<=5000) +  "5.000-10.000"*(AccesosEmpresa>5000 & AccesosEmpresa<=10000) + "10.000-20.000"*(AccesosEmpresa>10000 & AccesosEmpresa<=20000) + "20.000-30.000"*(AccesosEmpresa>20000 & AccesosEmpresa<=30000) + "30.000-40.000"*(AccesosEmpresa>30000 & AccesosEmpresa<=40000) + "40.000-50.000"*(AccesosEmpresa>40000 & AccesosEmpresa<=50000) + "50.000-60.000"*(AccesosEmpresa>50000 & AccesosEmpresa<=60000) + "60.000-70.000"*(AccesosEmpresa>60000 & AccesosEmpresa<=70000) + "70.000-80.000"*(AccesosEmpresa>70000 & AccesosEmpresa<=80000) + "80.000-90.000"*(AccesosEmpresa>80000 & AccesosEmpresa<=90000) + "90.000-100.000"*(AccesosEmpresa>90000 & AccesosEmpresa<=100000) 


replace Empresa = "Edatel TV" if  id_empresa==890905065
replace Empresa = "DirecTV" if  id_empresa==805006014
replace Empresa = "ETB" if  id_empresa==899999115
replace Empresa = "MOVISTAR" if  id_empresa==830122566
replace Empresa = "COMCEL" if  id_empresa==800153993
replace Empresa = "EDATEL" if  id_empresa==890905065
replace Empresa = "HV TV" if  id_empresa==800132211
replace Empresa = "UNE" if  id_empresa==900092385


*----------2.4: cambiar codificacion de los municipios

gen CodMun = string(id_municipio)
replace CodMun = "0" + CodMun if strlen(CodMun)==4

replace CodMun="27615" if CodMun=="27086" 

drop id_departamento departamento municipio

*----------2.5: pegar los datos de los municipios y departamentos del DANE

merge m:1 CodMun using `Hogares_Mpio', keep(3) nogen

egen AccesosMun = total(Accesos), by(CodMun)

gen penetracion = AccesosMun/Hogares2022

gen PentracionMun = "0-5"*(penetracion<0.05) + "5-10"*(penetracion>=0.05 & penetracion<0.1) + "10-15"*(penetracion>=0.10 & penetracion<0.15) + "15-20"*(penetracion>=0.15 & penetracion<0.20) + "20-25"*(penetracion>=0.20 & penetracion<0.25) + "25-30"*(penetracion>=0.25 & penetracion<0.30) + "30-35"*(penetracion>=0.30 & penetracion<0.35) + "35-40"*(penetracion>=0.35 & penetracion<0.40) + "40-45"*(penetracion>=0.40 & penetracion<0.45) + "45-40"*(penetracion>=0.45 & penetracion<0.50) + "50-55"*(penetracion>=0.50 & penetracion<0.55) + "55-60"*(penetracion>=0.55 & penetracion<0.60) + "60-65"*(penetracion>=0.60 & penetracion<0.65) + "65-70"*(penetracion>=0.65 & penetracion<0.70) + "70-75"*(penetracion>=0.70 & penetracion<0.75) + "75-80"*(penetracion>=0.75 & penetracion<0.80) + "80-85"*(penetracion>=0.80 & penetracion<0.85) + "85-90"*(penetracion>=0.85 & penetracion<0.90) + "90-95"*(penetracion>=0.90 & penetracion<0.95) + "95-100"*(penetracion>=0.95 & penetracion<1) + "100"*(penetracion>=1)


*----------2.6: agrupar las categorias de tecnologías

replace id_tecnologia = 1 if  id_tecnologia==102 

replace id_tecnologia = 2 if  id_tecnologia==106 

replace id_tecnologia = 3 if  id_tecnologia>=107 & id_tecnologia<=113 

replace id_tecnologia = 4 if  id_tecnologia==103 

replace id_tecnologia = 5 if  id_tecnologia==101 

replace id_tecnologia=6 if id_tecnologia==104 | id_tecnologia==105 | id_tecnologia==114 | id_tecnologia==115 | id_tecnologia==999

replace tecnologia="HFC" if id_tecnologia==2
replace tecnologia="FibraOptica" if id_tecnologia==3
replace tecnologia="Otras" if id_tecnologia==6



*----------2.7: recodificar datos de velocidades 

replace velocidad_efectiva_downstream = subinstr(velocidad_efectiva_downstream,",",".",.)


destring velocidad_efectiva_downstream, replace

rename velocidad_efectiva_downstream VelocidadDescarga



* eliminamos valores atipicos, velocidades mayores a 1Gbps y velocidades de cero 
drop if VelocidadDescarga >=1024

drop if VelocidadDescarga==0


* generamos la velocidad de descarga en categorica 
gen VelocidadDescargaCategorica = 1*(VelocidadDescarga>0 & VelocidadDescarga<=1) + 2*(VelocidadDescarga>1 & VelocidadDescarga<=2) + 3*(VelocidadDescarga>2 & VelocidadDescarga<=3) + 4*(VelocidadDescarga>3 & VelocidadDescarga<=4) + 5*(VelocidadDescarga>4 & VelocidadDescarga<=5) + 6*(VelocidadDescarga>5 & VelocidadDescarga<=6) + 7*(VelocidadDescarga>6 & VelocidadDescarga<=7) + 8*(VelocidadDescarga>7 & VelocidadDescarga<=8) + 9*(VelocidadDescarga>8 & VelocidadDescarga<=9) + 10*(VelocidadDescarga>9 & VelocidadDescarga<=12) + 11*(VelocidadDescarga>10 & VelocidadDescarga<=11) + 12*(VelocidadDescarga>11 & VelocidadDescarga<=12) + 13*(VelocidadDescarga>12 & VelocidadDescarga<=12) + 14*(VelocidadDescarga>13 & VelocidadDescarga<=14) + 15*(VelocidadDescarga>14 & VelocidadDescarga<=15) + 16*(VelocidadDescarga>15 & VelocidadDescarga<=16) + 17*(VelocidadDescarga>16 & VelocidadDescarga<=17) + 18*(VelocidadDescarga>17 & VelocidadDescarga<=18) + 19*(VelocidadDescarga>18 & VelocidadDescarga<=19) + 20*(VelocidadDescarga>19 & VelocidadDescarga<=20) + 21*(VelocidadDescarga>20 & VelocidadDescarga<=25) + 22*(VelocidadDescarga>25 & VelocidadDescarga<=30) + 23*(VelocidadDescarga>30 & VelocidadDescarga<=40) + 24*(VelocidadDescarga>40 & VelocidadDescarga<=50) + 25*(VelocidadDescarga>50 & VelocidadDescarga<=100) + 26*(VelocidadDescarga>100 & VelocidadDescarga<=200) + 27*(VelocidadDescarga>200 & VelocidadDescarga<=500) + 28*(VelocidadDescarga>500)

label def VelocidadDescargaCategorica 1 "0-1" 2 "1-2" 3 "2-3" 4 "3-4" 5 "4-5" 6 "5-6" 7 "6-7" 8 "7-8" 9 "8-9" 10 "9-10" 11 "10-11" 12 "11-12" 13 "12-13" 14 "13-14" 15 "14-15" 16 "15-16" 17 "16-17" 18 "17-18" 19 "18-19" 20 "19-20" 21 "20-25" 22 "25-30" 23 "30-40" 24 "40-50" 25 "50-100" 26 "100-200" 27 "200-500" 28 ">500"

label val VelocidadDescargaCategorica VelocidadDescargaCategorica


* generamos la velocidad de descarga en 6 categorias
gen VelocidadDescargaCat = "0_5"*(VelocidadDescarga>0 & VelocidadDescarga<=5) + "5_10"*(VelocidadDescarga>5 & VelocidadDescarga<=10) + "10_20"*(VelocidadDescarga>10 & VelocidadDescarga<=20) + "20_50"*(VelocidadDescarga>20 & VelocidadDescarga<=50) + "50_100"*(VelocidadDescarga>50 & VelocidadDescarga<=100) + "100_200"*(VelocidadDescarga>100 & VelocidadDescarga<=200) + "200_500"*(VelocidadDescarga>200 & VelocidadDescarga<=500) + "500"*(VelocidadDescarga>500)


* generamos la velocidad de descarga 5 cat 
gen VelocidadCat = "0_5"*(VelocidadDescarga>0 & VelocidadDescarga<=5) + "5_10"*(VelocidadDescarga>5 & VelocidadDescarga<=10) + "10_20"*(VelocidadDescarga>10 & VelocidadDescarga<=20) + "20_50"*(VelocidadDescarga>20 & VelocidadDescarga<=50) + "50"*(VelocidadDescarga>50)



*----------2.8: generar variable de estrato 
gen Estrato = 1*(segmento=="Residencial - Estrato 1") + 2*(segmento=="Residencial - Estrato 2") + 3*(segmento=="Residencial - Estrato 3") + 4*(segmento=="Residencial - Estrato 4") + 5*(segmento=="Residencial - Estrato 5") + 6*(segmento=="Residencial - Estrato 6")


*----------2.9: generar categoria Paquetes 

gen ServicioTV = 0 if id_servicio_paquete==1 | id_servicio_paquete==4
replace ServicioTV = 1 if id_servicio_paquete==5 | id_servicio_paquete==7
label def ServicioTV 0 "Internet" 1 "Internet + TV"

label val ServicioTV ServicioTV

*----------2.10: generar precio paquete

gen ValorFacturado  = valor_facturado_o_cobrado + otros_valores_facturados

replace ValorFacturado = ValorFacturado/3

* quitamos valores atipicos de facturación 
keep if ValorFacturado>0

* se genera el valor promedio del paquete 
gen PrecioPaquete = ValorFacturado/Accesos

* quitamos el valor adicional por el valor de la television. media condicional capturada en el coeficiente del servicioTV en la regresión 
reg PrecioPaquete i.ServicioTV i.VelocidadDescargaCategorica i.id_tecnologia i.Estrato if PrecioPaquete<500000 & PrecioPaquete>10000
local beta_servicio =  _b[1.ServicioTV]

gen PrimaTV =0 
replace PrimaTV=`beta_servicio' if (ServicioTV==1 & PrecioPaquete>`beta_servicio')

gen PrecioPaquete_SinTV = PrecioPaquete - PrimaTV

* se genera el valor del Mgb
gen ValorMgb = PrecioPaquete_SinTV/VelocidadDescarga

format PrecioPaquete PrecioPaquete_SinTV ValorMgb %9.0fc


*----------2.11: cobertura por municipio 

collapse (sum) Accesos, by(CodDepto CodMun)

merge 1:1 CodMun using `Hogares_Mpio', keep(3) nogen keepusing(Hogares2022)

gen Cobertura_Fijo = Accesos/Hogares2022

tempfile Fijo_Mpio

save `Fijo_Mpio', replace 


*----------2.12: Lineas Moviles

use `Moviles_Mpio', clear 

merge 1:1 CodMun using `Fijo_Mpio'


replace Accesos=0 if _merge==1
replace Cobertura_Fijo=0 if _merge==1


drop _merge 

order CodDepto Departamento CodMun Municipio POBLACION Hogares2022 Accesos Cobertura_Fijo LineasMovil LineasMovil_Prepago LineasMovil_Pospago

rename Accesos Accesos_Fijo 
rename POBLACION Poblacion
rename Hogares2022 Hogares

export excel using "$tb/Cobertura fijo y movil.xls", firstrow(variables) replace 



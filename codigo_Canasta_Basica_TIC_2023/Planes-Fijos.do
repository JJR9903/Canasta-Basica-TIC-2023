/*==================================================
project:		DNP Canasta Basica TIC       
name: 			Planes-Fijos
description:	importa y analiza los datos de los planes fijos a nivel departamental
Author:        Juan José Rincón 
E-email:       j.rincon@econometria.com
url:           
Dependencies:  Econometría Consultores
----------------------------------------------------
Creation Date:    09 oct 2023 - 11:40:23
Modification Date:   09 oct 2023 - 11:40:23
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








/*====================================================================================================
              3: Coberturas 
====================================================================================================*/


*----------3.1: Mapa de cobertura por municipio 

preserve

collapse (sum) Accesos, by(CodDepto CodMun)

merge 1:1 CodMun using `Hogares_Mpio', nogen keepusing(Hogares2022)

gen CoberturaMun = Accesos/Hogares2022

replace CoberturaMun = 0 if CoberturaMun==.

gen CoberturaMunCategorica = 1*(CoberturaMun>0 & CoberturaMun<=0.1) + 2*(CoberturaMun>0.1 & CoberturaMun<=0.2) + 3*(CoberturaMun>0.2 & CoberturaMun<=0.3) + 4*(CoberturaMun>0.3 & CoberturaMun<=0.4) + 5*(CoberturaMun>0.4 & CoberturaMun<=0.5) + 6*(CoberturaMun>0.5 & CoberturaMun<=0.6) + 7*(CoberturaMun>0.6 & CoberturaMun<=0.7) + 8*(CoberturaMun>0.7 & CoberturaMun<=0.8) + 9*(CoberturaMun>0.8 & CoberturaMun<=0.9) + 10*(CoberturaMun>0.9 & CoberturaMun<=1)

gen Municipios = 1 
gen cobertura1 = CoberturaMunCategorica==1 
gen cobertura2 = CoberturaMunCategorica==2 
gen cobertura3 = CoberturaMunCategorica==3 
gen cobertura4 = CoberturaMunCategorica==4 
gen cobertura5 = CoberturaMunCategorica==5 
gen cobertura6 = CoberturaMunCategorica==6 
gen cobertura7 = CoberturaMunCategorica==7 
gen cobertura8 = CoberturaMunCategorica==8 
gen cobertura9 = CoberturaMunCategorica==9 
gen cobertura10 = CoberturaMunCategorica==10 


export excel using "$tb/Cobertura.xls", sheet("Cobertura Mun") firstrow(variables) replace 

tempfile Cobertura_municipiosDepto 

collapse (sum) cobertura* Municipios (mean) CoberturaMun_Promedio=CoberturaMun  (min) CoberturaMun_Min=CoberturaMun, by(CodDepto)

replace cobertura1 = cobertura1/Municipios
replace cobertura2 = cobertura2/Municipios
replace cobertura3 = cobertura3/Municipios
replace cobertura4 = cobertura4/Municipios
replace cobertura5 = cobertura5/Municipios
replace cobertura6 = cobertura6/Municipios
replace cobertura7 = cobertura7/Municipios
replace cobertura8 = cobertura8/Municipios
replace cobertura9 = cobertura9/Municipios
replace cobertura10 = cobertura10/Municipios

gen cobertura_30= cobertura1+cobertura2+cobertura3
gen cobertura_30_60= cobertura4+cobertura5+cobertura6
gen cobertura_60= cobertura7+cobertura8+cobertura9+cobertura10

drop Municipios 

save `Cobertura_municipiosDepto', replace 

restore 



*----------3.2: Mapa de cobertura por departamento

preserve 

collapse (sum) Accesos, by(CodDepto)

merge 1:1 CodDepto using `Hogares_Depto', nogen

gen CoberturaDepto = Accesos/Hogares2022

merge 1:1 CodDepto using `Cobertura_municipiosDepto', nogen

export excel using "$tb/Cobertura.xls", sheet("Cobertura Dpto") firstrow(variables) 

restore 



*----------3.3: Mapa de cobertura de tecnología por municipio

preserve

collapse (sum) Accesos, by(CodDepto CodMun tecnologia)

egen AccesosMun = total(Accesos), by(CodMun)

gen CoberturaTecMun_ = Accesos/AccesosMun

drop Accesos AccesosMun

reshape wide CoberturaTecMun_, i(CodDepto CodMun) j(tecnologia) string

foreach v of varlist CoberturaTecMun_*{
	replace `v'=0 if `v'==.
}

export excel using "$tb/Cobertura.xls", sheet("CoberturaTec Mun") firstrow(variables) 

tempfile CoberturaTec_municipiosDepto 

collapse (mean) CoberturaTecMun*, by(CodDepto)

save `CoberturaTec_municipiosDepto', replace

restore 



*----------3.4: Mapa de cobertura de tecnología por departamento 

preserve

collapse (sum) Accesos, by(CodDepto tecnologia)

egen AccesosDepto = total(Accesos), by(CodDepto)

gen CoberturaTecDepto_ = Accesos/AccesosDepto

drop Accesos AccesosDepto

reshape wide CoberturaTecDepto_, i(CodDepto) j(tecnologia) string

foreach v of varlist CoberturaTecDepto_*{
	replace `v'=0 if `v'==.
}

merge 1:1 CodDepto using `CoberturaTec_municipiosDepto', nogen

export excel using "$tb/Cobertura.xls", sheet("CoberturaTec Dpto") firstrow(variables) 

restore 


*----------3.5: Cobertura de tecnología por estrato

preserve

collapse (sum) Accesos, by(tecnologia Estrato)

egen AccesosEstrato = total(Accesos), by(Estrato)

gen CoberturaTecEstrato = Accesos/AccesosEstrato

drop Accesos AccesosEstrato

sort Estrato tecnologia

export excel using "$tb/Cobertura.xls", sheet("CoberturaTec Estrato") firstrow(variables) 

restore 


*----------3.6: Cobertura Nacional 

preserve

collapse (sum) Accesos, by(CodMun)

merge 1:1 CodMun using `Hogares_Mpio', nogen keepusing(Hogares2022)

gen CoberturaMun = Accesos/Hogares2022

replace CoberturaMun= 0 if CoberturaMun==. 

gen CoberturaMunCategorica = 1*(CoberturaMun>0 & CoberturaMun<=0.1) + 2*(CoberturaMun>0.1 & CoberturaMun<=0.2) + 3*(CoberturaMun>0.2 & CoberturaMun<=0.3) + 4*(CoberturaMun>0.3 & CoberturaMun<=0.4) + 5*(CoberturaMun>0.4 & CoberturaMun<=0.5) + 6*(CoberturaMun>0.5 & CoberturaMun<=0.6) + 7*(CoberturaMun>0.6 & CoberturaMun<=0.7) + 8*(CoberturaMun>0.7 & CoberturaMun<=0.8) + 9*(CoberturaMun>0.8 & CoberturaMun<=0.9) + 10*(CoberturaMun>0.9 & CoberturaMun<=1)

gen Municipios = 1
gen cobertura1 = CoberturaMunCategorica==1 
gen cobertura2 = CoberturaMunCategorica==2 
gen cobertura3 = CoberturaMunCategorica==3 
gen cobertura4 = CoberturaMunCategorica==4 
gen cobertura5 = CoberturaMunCategorica==5 
gen cobertura6 = CoberturaMunCategorica==6 
gen cobertura7 = CoberturaMunCategorica==7 
gen cobertura8 = CoberturaMunCategorica==8 
gen cobertura9 = CoberturaMunCategorica==9 
gen cobertura10 = CoberturaMunCategorica==10 


collapse (sum) cobertura* Municipios Accesos Hogares2022

replace cobertura1 = cobertura1/Municipios
replace cobertura2 = cobertura2/Municipios
replace cobertura3 = cobertura3/Municipios
replace cobertura4 = cobertura4/Municipios
replace cobertura5 = cobertura5/Municipios
replace cobertura6 = cobertura6/Municipios
replace cobertura7 = cobertura7/Municipios
replace cobertura8 = cobertura8/Municipios
replace cobertura9 = cobertura9/Municipios
replace cobertura10 = cobertura10/Municipios

gen Cobertura = Accesos/Hogares2022

drop Municipios Accesos Hogares2022

export excel using "$tb/Cobertura.xls", sheet("Cobertura Nal") firstrow(variables) 

restore 


/*
*----------3.5: Mapa de cobertura de tecnología por estrato por departamento 

preserve

collapse (sum) Accesos, by(CodDepto tecnologia Estrato)

egen AccesosEstrato = total(Accesos), by(CodDepto Estrato)

gen CoberturaTecEstrato = Accesos/AccesosEstrato

drop Accesos AccesosEstrato

reshape wide CoberturaTecEstrato, i(CodDepto Estrato) j(id_tecnologia)

foreach v of varlist CoberturaTecDepto*{
	replace `v'=0 if `v'==.
}

export excel using "$tb/Cobertura.xls", sheet("CoberturaTec Estrato Dpto") firstrow(variables) 

restore 
*/









/*====================================================================================================
              5: Velocidades 
====================================================================================================*/


*----------5.1: Mapa de velocidades por municipio 


preserve

collapse (mean) VelocidadDescargaMun_Promedio=VelocidadDescarga (min) VelocidadDescargaMun_min=VelocidadDescarga [fw=Accesos], by(CodDepto CodMun)

merge 1:1 CodMun using `Hogares_Mpio', nogen keepusing(CodDepto Departamento Municipio)

export excel using "$tb/Velocidad.xls", sheet("Velocidad Mun") firstrow(variables) replace 

tempfile Velocidad_municipiosDepto 

collapse (mean) VelocidadDescargaMun_Promedio VelocidadDescargaMun_min, by(CodDepto)


save `Velocidad_municipiosDepto', replace 

restore 


*----------5.2: Mapa de velocidades por departamento

preserve 

collapse (mean) VelocidadDescargaDepto_Promedio=VelocidadDescarga (min) VelocidadDescargaDepto_Min=VelocidadDescarga [fw=Accesos], by(CodDepto)

merge 1:1 CodDepto using `Velocidad_municipiosDepto', nogen

export excel using "$tb/Velocidad.xls", sheet("Velocidad Dpto") firstrow(variables) 

restore 



*----------5.3: Mapa de velocidades por tecnología por municipio

preserve

collapse (mean) Velocidad_Mun_=VelocidadDescarga [fw=Accesos], by(CodDepto CodMun tecnologia)

reshape wide Velocidad_Mun_, i(CodDepto CodMun) j(tecnologia) string

export excel using "$tb/Velocidad.xls", sheet("VelocidadTec Mun") firstrow(variables) 

tempfile VelocidadTec_municipiosDepto 

collapse (mean) Velocidad_Mun_*, by(CodDepto)

save `VelocidadTec_municipiosDepto', replace

restore 


*----------5.4: Mapa de velocidades por tecnología por depto

preserve

collapse (mean) Velocidad_=VelocidadDescarga [fw=Accesos], by(CodDepto tecnologia)

reshape wide Velocidad_, i(CodDepto) j(tecnologia) string

merge 1:1 CodDepto using `VelocidadTec_municipiosDepto', nogen

export excel using "$tb/Velocidad.xls", sheet("VelocidadTec Dpto") firstrow(variables) 

restore 

*----------5.5: velocidades por tecnología

preserve

collapse (mean) Promedio=VelocidadDescarga (sd) DesviacionEstandar=VelocidadDescarga (min) Minima=VelocidadDescarga (max) Maxima=VelocidadDescarga [fw=Accesos], by(tecnologia)

export excel using "$tb/Velocidad.xls", sheet("Velocidad Tec") firstrow(variables) 

restore 



*----------5.6: Mapa de velocidades por estrato por municipio

preserve

collapse (mean) Velocidad_Mun_=VelocidadDescarga [fw=Accesos], by(CodDepto CodMun Estrato)

reshape wide Velocidad_Mun_, i(CodDepto CodMun) j(Estrato)

export excel using "$tb/Velocidad.xls", sheet("Velocidad E Mun") firstrow(variables) 

tempfile VelocidadTec_municipiosDepto 

collapse (mean) Velocidad_Mun_*, by(CodDepto)

save `VelocidadTec_municipiosDepto', replace

restore 



*----------5.7: Mapa de velocidades por estrato por depto

preserve

collapse (mean) Velocidad_=VelocidadDescarga [fw=Accesos], by(CodDepto Estrato)

reshape wide Velocidad_, i(CodDepto) j(Estrato)

merge 1:1 CodDepto using `VelocidadTec_municipiosDepto', nogen

export excel using "$tb/Velocidad.xls", sheet("Velocidad E Depto") firstrow(variables) 

restore 


*----------5.8: velocidades por estrato

preserve

collapse (mean) Promedio=VelocidadDescarga (sd) DesviacionEstandar=VelocidadDescarga (min) Minima=VelocidadDescarga (max) Maxima=VelocidadDescarga [fw=Accesos], by(Estrato)

export excel using "$tb/Velocidad.xls", sheet("Velocidades por estrato") firstrow(variables) 

restore 

*----------5.9: velocidades total

preserve

collapse (mean) Promedio=VelocidadDescarga (sd) DesviacionEstandar=VelocidadDescarga (min) Minima=VelocidadDescarga (max) Maxima=VelocidadDescarga [fw=Accesos]

export excel using "$tb/Velocidad.xls", sheet("Velocidades Total") firstrow(variables) 

restore 













/*====================================================================================================
              6: Velocidades categoricas
====================================================================================================*/


*----------6.1: Mapa de velocidades por municipio 


preserve

collapse (sum) Accesos, by(CodDepto CodMun VelocidadDescargaCat)

egen AccesosMun = total(Accesos), by(CodMun)

gen UsuariosVelocidadMun_ = Accesos/AccesosMun

drop Accesos AccesosMun 

reshape wide UsuariosVelocidadMun_, i(CodDepto CodMun) j(VelocidadDescargaCat) string

foreach v of varlist UsuariosVelocidadMun_*{
	replace `v' = 0 if `v'==.
}

export excel using "$tb/VelocidadCat.xls", sheet("Velocidad Mun") firstrow(variables) replace 

tempfile Velocidad_municipiosDepto 

collapse (mean) UsuariosVelocidadMun_*, by(CodDepto)

save `Velocidad_municipiosDepto', replace 

restore 


*----------5.2: Mapa de velocidades por departamento

preserve 

collapse (sum) Accesos, by(CodDepto VelocidadDescargaCat)

egen AccesosDepto = total(Accesos), by(CodDepto)

gen UsuariosVelocidadDepto_ = Accesos/AccesosDepto

drop Accesos AccesosDepto 

reshape wide UsuariosVelocidadDepto_, i(CodDepto) j(VelocidadDescargaCat) string

foreach v of varlist UsuariosVelocidadDepto_*{
	replace `v' = 0 if `v'==.
}

export excel using "$tb/VelocidadCat.xls", sheet("Velocidad Dpto") firstrow(variables) 

restore 



*----------5.3: velocidades por tecnología 

preserve

collapse (sum) Accesos, by(VelocidadDescargaCat tecnologia)

egen AccesosTec = total(Accesos), by(tecnologia)

gen UsuariosVelocidad_ = Accesos/AccesosTec

drop Accesos AccesosTec 

reshape wide UsuariosVelocidad_, i(tecnologia) j(VelocidadDescargaCat) string

foreach v of varlist UsuariosVelocidad_*{
	replace `v' = 0 if `v'==.
}

export excel using "$tb/VelocidadCat.xls", sheet("VelocidadTec") firstrow(variables) 


restore 



*----------5.3: velocidades por Estrato 

preserve

collapse (sum) Accesos, by(VelocidadDescargaCat Estrato)

egen AccesosE = total(Accesos), by(Estrato)

gen UsuariosVelocidad_ = Accesos/AccesosE

drop Accesos AccesosE 

reshape wide UsuariosVelocidad_, i(Estrato) j(VelocidadDescargaCat) string

foreach v of varlist UsuariosVelocidad_*{
	replace `v' = 0 if `v'==.
}

export excel using "$tb/VelocidadCat.xls", sheet("Velocidad Estrato") firstrow(variables) 

restore 











/*====================================================================================================
              7: Precios
====================================================================================================*/
* se eliminan valores atipicos de los precios de los paquetes 
drop if PrecioPaquete_SinTV>500000
drop if PrecioPaquete_SinTV<10000


*----------7.1: precios por velocidades 

preserve

collapse (mean) Promedio=ValorMgb (sd) DesviacionEstandar=ValorMgb (min) Minima=ValorMgb (max) Maxima=ValorMgb [fw=Accesos], by(VelocidadCat)

sort VelocidadCat 

export excel using "$tb/Precios.xls", sheet("Precio Mgbs") firstrow(variables) replace 

restore



*----------7.2: precios mgb por velocidades 
preserve

collapse (mean) Promedio=PrecioPaquete_SinTV (sd) DesviacionEstandar=PrecioPaquete_SinTV (min) Minima=PrecioPaquete_SinTV (max) Maxima=PrecioPaquete_SinTV [fw=Accesos], by(VelocidadCat)

sort VelocidadCat

export excel using "$tb/Precios.xls", sheet("Precio") firstrow(variables) 

restore 



*----------7.3: precios mgb por velocidades por estrato 
preserve

collapse (mean) Promedio=ValorMgb (sd) DesviacionEstandar=ValorMgb (min) Minima=ValorMgb (max) Maxima=ValorMgb [fw=Accesos], by(VelocidadCat Estrato)

sort VelocidadCat Estrato

export excel using "$tb/Precios.xls", sheet("Precio Mgbs Estrato") firstrow(variables) 

restore 



*----------7.4: precios por velocidades por estrato 
preserve

collapse (mean) Promedio=PrecioPaquete_SinTV (sd) DesviacionEstandar=PrecioPaquete_SinTV (min) Minima=PrecioPaquete_SinTV (max) Maxima=PrecioPaquete_SinTV [fw=Accesos], by(VelocidadCat Estrato)

sort VelocidadCat Estrato 

export excel using "$tb/Precios.xls", sheet("Precio Estrato") firstrow(variables) 

restore 



*----------7.5: precios mgb por velocidades por empresas 
preserve

collapse (mean) Promedio=ValorMgb (sd) DesviacionEstandar=ValorMgb (min) Minima=ValorMgb (max) Maxima=ValorMgb [fw=Accesos], by(VelocidadCat Empresa)

sort VelocidadCat Empresa

export excel using "$tb/Precios.xls", sheet("Precio Mgbs Empresa") firstrow(variables) 

restore 



*----------7.6: precios por velocidades por empresas 
preserve

collapse (mean) Promedio=PrecioPaquete_SinTV (sd) DesviacionEstandar=PrecioPaquete_SinTV (min) Minima=PrecioPaquete_SinTV (max) Maxima=PrecioPaquete_SinTV [fw=Accesos], by(VelocidadCat Empresa)

sort VelocidadCat Empresa 

export excel using "$tb/Precios.xls", sheet("Precio Empresa") firstrow(variables) 

restore 



*----------7.7: precios mgb por velocidades por penetracion 
preserve

collapse (mean) Promedio=ValorMgb (sd) DesviacionEstandar=ValorMgb (min) Minima=ValorMgb (max) Maxima=ValorMgb [fw=Accesos], by(VelocidadCat PentracionMun)

sort VelocidadCat PentracionMun

export excel using "$tb/Precios.xls", sheet("Precio Mgbs cobertura") firstrow(variables) 

restore 



*----------7.8: precios por velocidades por penetracion 
preserve

collapse (mean) Promedio=PrecioPaquete_SinTV (sd) DesviacionEstandar=PrecioPaquete_SinTV (min) Minima=PrecioPaquete_SinTV (max) Maxima=PrecioPaquete_SinTV [fw=Accesos], by(VelocidadCat PentracionMun)

sort VelocidadCat PentracionMun 

export excel using "$tb/Precios.xls", sheet("Precio cobertura") firstrow(variables) 

restore 



*----------7.9: precios mgb por velocidades cat por Depto 
preserve

collapse (mean) Promedio=ValorMgb (sd) DesviacionEstandar=ValorMgb (min) Minima=ValorMgb (max) Maxima=ValorMgb [fw=Accesos], by(VelocidadCat CodDepto)

sort VelocidadCat CodDepto

export excel using "$tb/Precios.xls", sheet("Precio Mgbs velocidad Depto") firstrow(variables) 

restore 



*----------7.10: precios por velocidades cat por Depto 
preserve

collapse (mean) Promedio=PrecioPaquete_SinTV (sd) DesviacionEstandar=PrecioPaquete_SinTV (min) Minima=PrecioPaquete_SinTV (max) Maxima=PrecioPaquete_SinTV [fw=Accesos], by(VelocidadCat CodDepto)

sort VelocidadCat CodDepto 

export excel using "$tb/Precios.xls", sheet("Precio velocidad Depto") firstrow(variables) 

restore 




*----------7.9: precios mgb por velocidades por Depto 
preserve

keep if VelocidadDescarga<=50

collapse (mean) Promedio=ValorMgb (sd) DesviacionEstandar=ValorMgb (min) Minima=ValorMgb (max) Maxima=ValorMgb [fw=Accesos], by(CodDepto)

sort CodDepto

export excel using "$tb/Precios.xls", sheet("Precio Mgbs Depto") firstrow(variables) 

restore 



*----------7.10: precios por velocidades por Depto 
preserve

keep if VelocidadDescarga<=50

collapse (mean) Promedio=PrecioPaquete_SinTV (sd) DesviacionEstandar=PrecioPaquete_SinTV (min) Minima=PrecioPaquete_SinTV (max) Maxima=PrecioPaquete_SinTV [fw=Accesos], by(CodDepto)

sort CodDepto 

export excel using "$tb/Precios.xls", sheet("Precio Depto") firstrow(variables) 

restore 











/*
histogram PrecioPaquete [fw=Accesos], bins(100) percent title("Valor promedio facturado por acceso (Hogar)") subtitle("T IV-2022") caption("Fuente: CRC, 2022") xtitle("Pesos corrientes") ytitle("Porcentaje") color("206 7 27") //xlabel(0(50000)500000)

histogram PrecioPaquete [fw=Accesos] if Estrato==1, bins(100) percent title("Valor promedio facturado por acceso (Hogar)") note("Estrato 1") subtitle("T IV-2022") caption("Fuente: CRC, 2022") xtitle("Pesos corrientes") ytitle("Porcentaje") color("206 7 27") xlabel(0(100000)1000000)
*graph export "$gf/$CRC/PaquetePromedio_pospago_internet.png", replace


*/








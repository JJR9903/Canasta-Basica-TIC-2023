/*==================================================
project:		DNP Canasta Basica TIC       
name: 			Planes-Moviles
description:	importa y analiza los datos de los planes moviles a nivel nacional 
Author:        Juan José Rincón 
E-email:       j.rincon@econometria.com
url:           
Dependencies:  Econometría Consultores
----------------------------------------------------
Creation Date:    21 Sep 2023 - 11:40:23
Modification Date:   08 oct 2023 - 18:40:23
Do-file version:    02
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

global original "cuanti_secund_Canasta_Basica_TIC_2023/CRC-PostData-Planes-Fijos-Movil"
global working "analisis_Canasta_Basica_TIC_2023/CRC-Planes-Fijos-Moviles"
global gf "resultad_Canasta_Basica_TIC_2023/producto1/movil/graficas"
global tb "resultad_Canasta_Basica_TIC_2023/producto1/movil/tablas"
global ws "webscraping"
global CRC "formatoCRC"


/*====================================================================================================
              1: Importar datos facturacion 
====================================================================================================*/


*----------1.1: importar datos

import delimited "$original/CRC Post Data 2022 EMPAQUETAMIENTO_MOVIL.csv", delimiter(";") clear


keep if trimestre==4

gen modalidad= "PRE" if modalidad_pago=="Prepago con compra" 
replace modalidad= "PRE" if modalidad_pago=="Prepago sin compra" 
replace modalidad= "POS" if modalidad_pago=="Pospago" 
gen mes = 10*(mes_del_trimestre==1) + 11*(mes_del_trimestre==2) + 12*(mes_del_trimestre==3)

gen TotalFacturado = valor_facturado_o_cobrado + otros_valores_facturados
gen PaquetePromedio = valor_facturado_o_cobrado/cantidad_lineas
gen PaquetePromedioTotal = TotalFacturado/cantidad_lineas

rename (valor_facturado_o_cobrado otros_valores_facturados cantidad_lineas servicio_paquete) (ValorFacturado OtrosValoresFacturados CantidadLineas TipoPlan)
  
format PaquetePromedio PaquetePromedioTotal CantidadLineas ValorFacturado OtrosValoresFacturados %9.0fc

keep anno mes id_empresa empresa modalidad TipoPlan CantidadLineas TotalFacturado ValorFacturado OtrosValoresFacturados TipoPlan PaquetePromedio PaquetePromedioTotal

drop if PaquetePromedio==.
drop if PaquetePromedio==0


*----------1.2: historgramas

* pospago
histogram PaquetePromedioTotal if modalidad=="POS" & TipoPlan=="Internet móvil", bins(20) percent title("Valor promedio plan pospago - Internet Móvil") subtitle("T IV-2022") caption("Fuente: CRC, 2022") xtitle("Pesos corrientes") ytitle("Porcentaje") xlabel(0(50000)500000) color("206 7 27") 
graph export "$gf/$CRC/PaquetePromedio_pospago_internet.png", replace


histogram PaquetePromedioTotal if modalidad=="POS" & TipoPlan=="Internet móvil" & PaquetePromedioTotal<100000, bins(20) percent title("Valor promedio plan pospago - Internet móvil") subtitle("T IV-2022") note("Planes con valor menor a $100.000") caption("Fuente: CRC, 2022") xtitle("Pesos corrientes") ytitle("Porcentaje") xlabel(0(5000)50000) color("206 7 27") 
graph export "$gf/$CRC/PaquetePromedio_pospago_internet_menor100.png", replace


histogram PaquetePromedioTotal if modalidad=="POS" & TipoPlan=="Voz móvil + internet móvil", bins(20) percent title("Valor promedio plan pospago - Internet + voz móvil") subtitle("T IV-2022") caption("Fuente: CRC, 2022") xtitle("Pesos corrientes") ytitle("Porcentaje") xlabel(0(5000)45000) color("206 7 27") 
graph export "$gf/$CRC/PaquetePromedio_pospago_internetvoz.png", replace

histogram PaquetePromedioTotal if modalidad=="POS" & TipoPlan=="Voz móvil", bins(20) percent title("Valor promedio plan pospago - voz") subtitle("T IV-2022") caption("Fuente: CRC, 2022") xtitle("Pesos corrientes") ytitle("Porcentaje") xlabel(0(25000)200000) color("206 7 27") 
graph export "$gf/$CRC/PaquetePromedio_pospago_voz.png", replace

histogram PaquetePromedioTotal if modalidad=="POS" & TipoPlan=="Voz móvil" & PaquetePromedioTotal<100000, bins(20) percent title("Valor promedio plan pospago - voz") subtitle("T IV-2022") caption("Fuente: CRC, 2022") note("Planes con valor menor a $100.000") xtitle("Pesos corrientes") ytitle("Porcentaje") xlabel(0(10000)100000) color("206 7 27") 
graph export "$gf/$CRC/PaquetePromedio_pospago_voz_menor100.png", replace


*prepago
histogram PaquetePromedioTotal if modalidad=="PRE" & TipoPlan=="Internet móvil", bins(20) percent title("Valor promedio plan prepago - Internet Móvil") subtitle("T IV-2022") caption("Fuente: CRC, 2022") xtitle("Pesos corrientes") ytitle("Porcentaje") xlabel(0(5000)30000) color("206 7 27") 
graph export "$gf/$CRC/PaquetePromedio_prepago_internet.png", replace


histogram PaquetePromedioTotal if modalidad=="PRE" & TipoPlan=="Voz móvil + internet móvil", bins(20) percent title("Valor promedio plan prepago - Internet + voz móvil") subtitle("T IV-2022") caption("Fuente: CRC, 2022") xtitle("Pesos corrientes") ytitle("Porcentaje") xlabel(0(5000)40000) color("206 7 27") 
graph export "$gf/$CRC/PaquetePromedio_prepago_internetvoz.png", replace


histogram PaquetePromedioTotal if modalidad=="PRE" & TipoPlan=="Voz móvil", bins(20) percent title("Valor promedio plan prepago - voz") subtitle("T IV-2022") caption("Fuente: CRC, 2022") xtitle("Pesos corrientes") ytitle("Porcentaje") xlabel(0(2500)20000) color("206 7 27") 
graph export "$gf/$CRC/PaquetePromedio_prepago_voz.png", replace



*----------1.3: estadisticas descriptivas 

*internet
* valores bajos - tigo y comcel, valores altos - etb 

preserve 

collapse (mean) Promedio=PaquetePromedioTotal (sd) DesviacionEstandar=PaquetePromedioTotal (min) Minimo=PaquetePromedioTotal (max) Maximo=PaquetePromedioTotal ,by(modalidad TipoPlan)

export excel using "$tb/$CRC/Valor_PaquetePromedio.xlsx", sheet("Todos") firstrow(variables) replace 

restore 



preserve 

keep if PaquetePromedioTotal<100000

collapse (mean) Promedio=PaquetePromedioTotal (sd) DesviacionEstandar=PaquetePromedioTotal (min) Minimo=PaquetePromedioTotal (max) Maximo=PaquetePromedioTotal ,by(modalidad TipoPlan)

export excel using "$tb/$CRC/Valor_PaquetePromedio.xlsx", sheet("menores de 100k") firstrow(variables) 

restore


preserve 

keep if id_empresa==830114921 | id_empresa==800153993 | id_empresa==899999115

keep if modalidad=="POS"

export excel using "$tb/$CRC/Valor_PaquetePromedio.xlsx", sheet("problemas") firstrow(variables) 

restore 


/*====================================================================================================
              2: Importar datos web scraping 
====================================================================================================*/


*----------2.1: importar datos

import delimited "$original/planes_moviles_comparador_0.csv", delimiter(";") clear

*----------2.2: crear variables


gen Vigencia = vigencia 
replace Vigencia = regexr(Vigencia, "(?i)dias?", "dia")
replace Vigencia = regexr(Vigencia, "(?i)días?", "dia")
replace Vigencia = substr(Vigencia, 1, strpos(Vigencia, " dia") - 1)
replace Vigencia = "30" if modalidad=="POS"
destring Vigencia, replace 

gen VigenciaH = vigencia 
replace VigenciaH = regexr(VigenciaH, "(?i)horas?", "hora")
replace VigenciaH = substr(VigenciaH, 1, strpos(VigenciaH, " hora") - 1)
destring VigenciaH, replace 
replace VigenciaH = VigenciaH/24

replace Vigencia = VigenciaH if Vigencia==.

drop VigenciaH vigencia

replace unidad_medida_voz="MINUTOS" if unidad_medida_voz=="SEGUNDOS"


replace minutos_mismo=. if minutos_mismo==-1
replace minutos_otros_moviles=. if minutos_otros_moviles==-1 
replace minutos_fijos=. if minutos_fijos==-1 

replace sms_mismo=. if sms_mismo==-1 
replace sms_otro=. if sms_otro==-1


gen datos_gb = datos_mb/1024

replace datos_gb=. if datos_mb==-1
replace datos_gb=. if datos_mb==-2

gen ValorMB = precio/datos_gb 

gen minutos = minutos_mismo + minutos_otros_moviles + minutos_fijos 
gen sms = sms_mismo + sms_otro 

gen Datos_Dia = datos_gb/Vigencia
gen Minutos_Dia = minutos/Vigencia
gen sms_Dia = sms/Vigencia
gen precio_Dia = precio/Vigencia
gen precio_GB_Dia = precio/datos_gb/Vigencia

gen Datos_mes = Datos_Dia*30 
gen Minutos_mes = Minutos_Dia*30
gen Precio_mes = precio_Dia*30
gen Precio_GB_mes = precio_GB_Dia*30


gen TipoPlan = "Voz móvil" if Minutos_Dia>0 & sms_Dia==0 & Datos_Dia==0
replace TipoPlan = "Internet móvil" if Minutos_Dia==0 & sms_Dia==0 & Datos_Dia>0
replace TipoPlan = "Internet móvil" if Minutos_Dia==0 & sms_Dia>0 & Datos_Dia>0
replace TipoPlan = "Voz móvil" if Minutos_Dia>0 & sms_Dia>0 & Datos_Dia==0
replace TipoPlan = "Voz móvil + internet móvil" if Minutos_Dia>0 & sms_Dia==0 & Datos_Dia>0
replace TipoPlan = "Voz móvil + internet móvil" if Minutos_Dia>0 & sms_Dia>0 & Datos_Dia>0
replace TipoPlan = "Otros" if Minutos_Dia==0 & sms_Dia>0 & Datos_Dia==0
replace TipoPlan = "Otros" if Minutos_Dia==0 & sms_Dia==0 & Datos_Dia==0

format Precio_mes Precio_GB_mes %9.0fc


*----------2.3: dejar solo el 4 trimestre 
keep if mes>=10

drop if TipoPlan == "Otros"

duplicates drop marca nombre_plan precio Vigencia datos_gb minutos, force



/*====================================================================================================
              3: graficas
====================================================================================================*/

*----------3.1: Graficas Histogramas mensuales

histogram Datos_mes if modalidad=="POS" & datos_gb>0, bins(24) percent title("GB por mes planes pospago") subtitle("T IV-2022") caption("Fuente: CRC, 2022") xtitle("Datos GB") ytitle("Porcentaje") xlabel(0(10)120) color("206 7 27")
graph export "$gf/$ws/GB_mes_pospago.png", replace

histogram Precio_mes if modalidad=="POS" & datos_gb>0, bins(20) percent title("Valor mes planes pospago") subtitle("T IV-2022") caption("Fuente: CRC, 2022") xtitle("Pesos corrientes") ytitle("Porcentaje") xlabel(20000(10000)120000) color("206 7 27") 
graph export "$gf/$ws/precio_mes_pospago.png", replace

histogram Precio_GB_mes if modalidad=="POS" & datos_gb>0, bins(18) percent title("Valor GB mes planes pospago") subtitle("T IV-2022") caption("Fuente: CRC, 2022") xtitle("Pesos corrientes") ytitle("Porcentaje") xlabel(400(200)2000) color("206 7 27")
graph export "$gf/$ws/precio_GB_mes_pospago.png", replace


histogram Datos_mes if modalidad=="PRE" & datos_gb>0, bins(18) percent title("GB por mes planes prepago") subtitle("T IV-2022") caption("Fuente: CRC, 2022") xtitle("Datos GB") ytitle("Porcentaje") xlabel(0(10)90) color("206 7 27")
graph export "$gf/$ws/GB_mes_prepago.png", replace

histogram Precio_mes if modalidad=="PRE" & datos_gb>0, bins(20) percent title("Valor mes planes prepago") subtitle("T IV-2022") caption("Fuente: CRC, 2022") xtitle("Pesos corrientes") ytitle("Porcentaje") xlabel(0(20000)140000) color("206 7 27")
graph export "$gf/$ws/precio_mes_prepago.png", replace

histogram Precio_GB_mes if modalidad=="PRE" & datos_gb>0 & Precio_GB_mes<100000, bins(20) percent title("Valor GB mes planes prepago") subtitle("T IV-2022") caption("Fuente: CRC, 2022") xtitle("Pesos corrientes") ytitle("Porcentaje") xlabel(0(10000)100000) color("206 7 27")
graph export "$gf/$ws/precio_GB_mes_prepago.png", replace

*top 3 marcas 

preserve

keep if marca=="TIGO" | marca=="CLARO" | marca=="MOVISTAR"

histogram Datos_mes if modalidad=="POS" & datos_gb>0, bins(24) percent title("GB por mes planes pospago") subtitle("T IV-2022") note("planes de Claro, Movistar y Tigo") caption("Fuente: CRC, 2022") xtitle("Datos GB") ytitle("Porcentaje") xlabel(0(10)120) color("206 7 27")
graph export "$gf/$ws/GB_mes_pospago_top3marcas.png", replace

histogram Precio_mes if modalidad=="POS" & datos_gb>0, bins(20) percent title("Valor mes planes pospago") subtitle("T IV-2022") note("planes de Claro, Movistar y Tigo") caption("Fuente: CRC, 2022") xtitle("Pesos corrientes") ytitle("Porcentaje") xlabel(20000(10000)120000) color("206 7 27") 
graph export "$gf/$ws/precio_mes_pospago_top3marcas.png", replace

histogram Precio_GB_mes if modalidad=="POS" & datos_gb>0, bins(18) percent title("Valor GB mes planes pospago") subtitle("T IV-2022") note("planes de Claro, Movistar y Tigo") caption("Fuente: CRC, 2022") xtitle("Pesos corrientes") ytitle("Porcentaje") xlabel(400(200)2000) color("206 7 27")
graph export "$gf/$ws/precio_GB_mes_pospago_top3marcas.png", replace


histogram Datos_mes if modalidad=="PRE" & datos_gb>0, bins(18) percent title("GB por mes planes prepago") subtitle("T IV-2022") note("planes de Claro, Movistar y Tigo") caption("Fuente: CRC, 2022") xtitle("Datos GB") ytitle("Porcentaje") xlabel(0(10)90) color("206 7 27")
graph export "$gf/$ws/GB_mes_prepago_top3marcas.png", replace

histogram Precio_mes if modalidad=="PRE" & datos_gb>0, bins(20) percent title("Valor mes planes prepago") subtitle("T IV-2022") note("planes de Claro, Movistar y Tigo") caption("Fuente: CRC, 2022") xtitle("Pesos corrientes") ytitle("Porcentaje") xlabel(0(20000)140000) color("206 7 27")
graph export "$gf/$ws/precio_mes_prepago_top3marcas.png", replace

histogram Precio_GB_mes if modalidad=="PRE" & datos_gb>0 & Precio_GB_mes<100000, bins(20) percent title("Valor GB mes planes prepago") note("planes de Claro, Movistar y Tigo") subtitle("T IV-2022") caption("Fuente: CRC, 2022") xtitle("Pesos corrientes") ytitle("Porcentaje") xlabel(0(10000)100000) color("206 7 27")
graph export "$gf/$ws/precio_GB_mes_prepago_top3marcas.png", replace


restore 


***** este si con linea de tendencia - para voz, voz + datos y datos
twoway (scatter Precio_mes Datos_mes, color("206 7 27")) (lfit Precio_mes Datos_mes, lcolor("41 96 117"))  if modalidad=="POS" & datos_gb>0 & TipoPlan == "Internet móvil", title("Relación precio del plan - GB disponibles") note("Planes pospago Internet móvil") subtitle("T IV-2022") caption("Fuente: CRC, 2022") xtitle("Datos GB") ytitle("Pesos corrientes") legend(off)
graph export "$gf/$ws/relacion_precio_GB_planesInternet.png", replace


twoway (scatter Precio_mes Datos_mes, color("206 7 27")) (lfit Precio_mes Datos_mes, lcolor("41 96 117"))  if modalidad=="POS" & datos_gb>0 & TipoPlan == "Voz móvil + internet móvil", title("Relación precio del plan - GB disponibles") note("Planes pospago Voz móvil + Internet móvil") subtitle("T IV-2022") caption("Fuente: CRC, 2022") xtitle("Datos GB") ytitle("Pesos corrientes") legend(off)
graph export "$gf/$ws/relacion_precio_GB_planesInternetVoz.png", replace







twoway   if modalidad=="POS" & datos_gb>0 & TipoPlan == "Internet móvil"


/*====================================================================================================
              4: Valores
====================================================================================================*/

*----------4.2: Valores promedio

preserve 

collapse (mean) Promedio=Datos_mes (sd) DesviacionEstandar=Datos_mes (min) Minimo=Datos_mes (max) Maximo=Datos_mes ,by(modalidad TipoPlan)

export excel using "$tb/$ws/EstadisticasPlanes.xlsx", sheet("Datos GB") firstrow(variables) replace 

restore 


preserve 

collapse (mean) Promedio=Precio_mes (sd) DesviacionEstandar=Precio_mes (min) Minimo=Precio_mes (max) Maximo=Precio_mes ,by(modalidad TipoPlan)

export excel using "$tb/$ws/EstadisticasPlanes.xlsx", sheet("Precio") firstrow(variables) 

restore 

preserve 

collapse (mean) Promedio=Precio_GB_mes (sd) DesviacionEstandar=Precio_GB_mes (min) Minimo=Precio_GB_mes (max) Maximo=Precio_GB_mes ,by(modalidad TipoPlan)

export excel using "$tb/$ws/EstadisticasPlanes.xlsx", sheet("Precio GB mes") firstrow(variables) 

restore 


*top 3 marcas 

preserve 

keep if marca=="TIGO" | marca=="CLARO" | marca=="MOVISTAR"

collapse (mean) Promedio=Datos_mes (sd) DesviacionEstandar=Datos_mes (min) Minimo=Datos_mes (max) Maximo=Datos_mes ,by(modalidad TipoPlan)

export excel using "$tb/$ws/EstadisticasPlanes.xlsx", sheet("Datos GB top3") firstrow(variables) 

restore 


preserve 

keep if marca=="TIGO" | marca=="CLARO" | marca=="MOVISTAR"


collapse (mean) Promedio=Precio_mes (sd) DesviacionEstandar=Precio_mes (min) Minimo=Precio_mes (max) Maximo=Precio_mes ,by(modalidad TipoPlan)

export excel using "$tb/$ws/EstadisticasPlanes.xlsx", sheet("Precio top3") firstrow(variables) 

restore 

preserve 

keep if marca=="TIGO" | marca=="CLARO" | marca=="MOVISTAR"

collapse (mean) Promedio=Precio_GB_mes (sd) DesviacionEstandar=Precio_GB_mes (min) Minimo=Precio_GB_mes (max) Maximo=Precio_GB_mes ,by(modalidad TipoPlan)

export excel using "$tb/$ws/EstadisticasPlanes.xlsx", sheet("Precio GB mes top3") firstrow(variables) 

restore 

** por marca 


preserve 

collapse (mean) Promedio=Datos_mes (sd) DesviacionEstandar=Datos_mes (min) Minimo=Datos_mes (max) Maximo=Datos_mes ,by(modalidad TipoPlan marca)

export excel using "$tb/$ws/EstadisticasPlanesPorMarca.xlsx", sheet("Datos GB") firstrow(variables) replace 

restore 


preserve 

collapse (mean) Promedio=Precio_mes (sd) DesviacionEstandar=Precio_mes (min) Minimo=Precio_mes (max) Maximo=Precio_mes ,by(modalidad TipoPlan marca)

export excel using "$tb/$ws/EstadisticasPlanesPorMarca.xlsx", sheet("Precio") firstrow(variables) 

restore 

preserve 

collapse (mean) Promedio=Precio_GB_mes (sd) DesviacionEstandar=Precio_GB_mes (min) Minimo=Precio_GB_mes (max) Maximo=Precio_GB_mes ,by(modalidad TipoPlan marca)

export excel using "$tb/$ws/EstadisticasPlanesPorMarca.xlsx", sheet("Precio GB mes") firstrow(variables) 

restore 


preserve 

keep if id_empresa==830114921 | id_empresa==800153993 | id_empresa==899999115

collapse (mean) Promedio=Precio_mes (sd) DesviacionEstandar=Precio_mes (min) Minimo=Precio_mes (max) Maximo=Precio_mes ,by(modalidad TipoPlan marca mes)

export excel using "$tb/$ws/EstadisticasPlanesPorMarca.xlsx", sheet("Precio problemas") firstrow(variables) 

restore 


*----------4.2: tabla precios

preserve


collapse (mean) Precio_Promedio=Precio_mes (min) Precio_minimo=Precio_mes, by(modalidad TipoPlan Datos_mes)

order modalidad TipoPlan Datos_mes Precio_Promedio Precio_minimo
gsort modalidad TipoPlan Datos_mes Precio_Promedio



export excel using "$tb/Planes-Moviles.xlsx", sheet("Todos") firstrow(variables) replace 

bys modalidad TipoPlan: egen min_Datos = min(Datos_mes)
gen Datos_min = Datos_mes==min_Datos
drop min_Datos

bys modalidad TipoPlan: egen min_Precio = min(Precio_minimo)
gen Precio_min = Precio_minimo==min_Precio
drop min_Precio

keep if Datos_min==1 | Precio_min==1

drop Datos_min Precio_min 

export excel using "$tb/Planes-Moviles.xlsx", sheet("oferta minima") firstrow(variables) 

restore

* top 3 marcas

preserve

keep if marca=="TIGO" | marca=="CLARO" | marca=="MOVISTAR"

collapse (mean) Precio_Promedio=Precio_mes (min) Precio_minimo=Precio_mes, by(modalidad TipoPlan Datos_mes)

order modalidad TipoPlan Datos_mes Precio_Promedio Precio_minimo
gsort modalidad TipoPlan Datos_mes Precio_Promedio



export excel using "$tb/Planes-Moviles.xlsx", sheet("Top3") firstrow(variables) 

bys modalidad TipoPlan: egen min_Datos = min(Datos_mes)
gen Datos_min = Datos_mes==min_Datos
drop min_Datos

bys modalidad TipoPlan: egen min_Precio = min(Precio_minimo)
gen Precio_min = Precio_minimo==min_Precio
drop min_Precio

keep if Datos_min==1 | Precio_min==1

drop Datos_min Precio_min 

export excel using "$tb/Planes-Moviles.xlsx", sheet("oferta minima Top3") firstrow(variables) 

restore




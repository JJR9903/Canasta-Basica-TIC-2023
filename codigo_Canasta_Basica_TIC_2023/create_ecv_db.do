/*==================================================
project:		DNP Canasta Basica TIC       
name: 			create_ecv_db_IngresosGastos
description:	Crea una base de datos de la ECV 2022 del DANE, con las variables importantes para el proyecto sobre los costos e ingresos del hogar y su respectiva recodificacion
Author:        Juan José Rincón 
E-email:       j.rincon@econometria.com
url:           
Dependencies:  Econometría Consultores
----------------------------------------------------
Creation Date:    13 Sep 2023 - 14:27:23
Modification Date:   
Do-file version:    01
References: ECV 2022, DANE         
Output:             
==================================================*/

/*==================================================
              0: Program set up
==================================================*/
version 18
drop _all

clear all
cls

cd "/Users/juanjose/Library/CloudStorage/GoogleDrive-j.rincon@econometria.com/Mi unidad/DNP - Canasta B TIC/Canasta-Basica-TIC-2023/"

global original "cuanti_secund_Canasta_Basica_TIC_2023/ECV-2022"
global working "analisis_Canasta_Basica_TIC_2023/ECV-2022"

/*====================================================================================================
              1: Datos ubicación de la encuesta 
====================================================================================================*/

tempfile Datos_Vivienda

*----------1.1: importar datos


use "$original/Datos de la vivienda/Datos de la vivienda.DTA",clear

*----------1.2: guardar datos variables necesarias 

* se renombra la variable de estrato de la vivienda 
rename P8520S1A1 ESTRATO

keep DIRECTORIO P1_DEPARTAMENTO REGION CLASE ESTRATO

*----------1.3: guardar base de datos preliminar 

save `Datos_Vivienda', replace





/*====================================================================================================
              2: Datos de servicios del hogar
====================================================================================================*/

tempfile Servicios_del_hogar

*----------2.1: importar datos

use "$original/Servicios del hogar/Servicios del hogar.DTA",clear


*----------2.2: se transforman variable de costos con filtros 
/* Descripción
En estas variables, anteriormente se les ha preguntado si pagan o no por tal servicio o bien. A los que responden negativamente no se les pregunta por el valor del costo del servicio o bien, y por ende esta codificado como un valor missing (NA)
Se decide transformar estos missings en cero (0) porque, lo que se quiere saber es la sumatoria de los gastos del hogar, no si paga o no por el servicio. si se deja el valor en missing, la sumatoria va a dar como resultado un missing por defecto
*/

foreach var in P5018S2 P3163S2 P5034S2 P5044S2 P5067S2 P8540S1 {
	replace `var'=0 if `var'==.
	replace `var'=0 if `var'==99
}

*----------2.3: se transforman las variables a costos mensuales
/* Descripción
Además se transforman los costos para que sean mensuales, dividiendo por la frecuencia del pago
*/

replace P5018S2=P5018S2/P5018S1 if P5018S1!=. // electricidad
replace P3163S2=P3163S2/P3163S1 if P3163S1!=. // gas natural
replace P5034S2=P5034S2/P5034S1 if P5034S1!=. // alcantarillado
replace P5044S2=P5044S2/P5044S1 if P5044S1!=. // recoleccion basuras
replace P5067S2=P5067S2/P5067S1 if P5067S1!=. // acueducto

	
*----------2.4: se renombran las variables
/* Descripción
se renombran las variables que están codificadas según la decumentacion de la ECV del DANE hacia unos nombres autodescriptivos

En el caso de los gastos: se inicia con la codificacion de G_SP_  "Gasto en Servicios Publicos" seguido del servicio publico especifico 
ej: G_SP_Alcantarillado

En el caso de los ingresos: se inicia con la codificacion de I_ "Ingresos" seguido del tipo de ingreso especifico

En el caso de las cantidades: se inicia la coficiacion con N_ "Nº o cantidades", se cambia la codificacion de CANT a N Como inicio.   
*/
	
rename (P5018S2 P3163S2 P5034S2 P5044S2 P5067S2 P8540S1) (G_SP_Electricidad G_SP_GasNatural G_SP_Alcantarillado G_SP_RecoleccionBasuras G_SP_Acueducto G_SP_CombustibleCocina)

rename (I_HOGAR PERCAPITA CANT_PERSONAS_HOGAR) (I_HOGAR I_PERCAPITA N_PERSONAS_HOGAR)

rename FEX_C FEX_C_HOGAR


*----------2.5: guardar variables necesarias 

keep DIRECTORIO SECUENCIA_ENCUESTA FEX_C_HOGAR G_SP_Electricidad G_SP_GasNatural G_SP_Alcantarillado G_SP_RecoleccionBasuras G_SP_Acueducto G_SP_CombustibleCocina I_HOGAR I_PERCAPITA N_PERSONAS_HOGAR


*----------2.6: guardar base de datos preliminar  

save `Servicios_del_hogar', replace




/*====================================================================================================
              3: Importar datos de Salud
====================================================================================================*/

tempfile Salud

*----------3.1: importar datos

use "$original/Salud/Salud.DTA",clear

drop SECUENCIA_ENCUESTA
rename SECUENCIA_P SECUENCIA_ENCUESTA

*----------3.2: se transforman variable de costos con filtros 
/* Descripción
En estas variables, anteriormente se les ha preguntado si pagan o no por tal servicio o bien. A los que responden negativamente no se les pregunta por el valor del costo del servicio o bien, y por ende esta codificado como un valor missing (NA)
Se decide transformar estos missings en cero (0) porque, lo que se quiere saber es la sumatoria de los gastos del hogar, no si paga o no por el servicio. si se deja el valor en missing, la sumatoria va a dar como resultado un missing por defecto
*/

foreach var in P8551 P3176 P3178S1A1 P3178S2A1 P3178S3A1 P3179S1A1 P3179S2A1 P3179S3A1 P3181S1 P3182S1 P3183S1 P3184S1 P3185S1 P3186S1 P3187S2 P3188S1A1 P3188S2A1 P3188S3A1 P3189S1A1 P3189S2A1 {
	replace `var'=0 if `var'==.
	replace `var'=0 if `var'==99
}


*----------3.3: se transforman las variables a costos mensuales
/* Descripción
Además se transforman los costos para que sean mensuales, dividiendo por la frecuencia del pago que es anual
*/


foreach var in P3187S2 P3188S1A1 P3188S2A1 P3188S3A1 {
	replace `var'=`var'/12
}

*----------3.4: se renombran las variables
/* Descripción
se renombran las variables que están codificadas según la decumentacion de la ECV del DANE hacia unos nombres autodescriptivos

En el caso de los gastos: se inicia con la codificacion de G_S_  "Gasto en Salud" seguido del servicio publico especifico 
ej: G_S_Seguro

*/
	
rename (P8551 P3176 P3178S1A1 P3178S2A1 P3178S3A1 P3179S1A1 P3179S2A1 P3179S3A1 P3181S1 P3182S1 P3183S1 P3184S1 P3185S1 P3186S1 P3187S2 P3188S1A1 P3188S2A1 P3188S3A1 P3189S1A1 P3189S2A1) (G_S_Seguro G_S_SeguroAdicional G_S_ConsultaEPS G_S_ConsultaParticular G_S_ConsultaPrepagada G_S_OdontoEPS G_S_OdontoParticular G_S_OdontoPrepagada G_S_Vacunas G_S_Medicinas G_S_Examenes G_S_Terapias G_S_TerapiasAlternativas G_S_Transporte G_S_Lentes G_S_CirugiasEPS G_S_CirugiasParticular G_S_CirugiasPrepagada G_S_HospEPS G_S_HospPrepagada)


rename FEX_C FEX_C_Salud


*----------3.5: guardar variables necesarias 

collapse (sum) G_S_Seguro G_S_SeguroAdicional G_S_ConsultaEPS G_S_ConsultaParticular G_S_ConsultaPrepagada G_S_OdontoEPS G_S_OdontoParticular G_S_OdontoPrepagada G_S_Vacunas G_S_Medicinas G_S_Examenes G_S_Terapias G_S_TerapiasAlternativas G_S_Transporte G_S_Lentes G_S_CirugiasEPS G_S_CirugiasParticular G_S_CirugiasPrepagada G_S_HospEPS G_S_HospPrepagada, by(DIRECTORIO SECUENCIA_ENCUESTA)


keep DIRECTORIO SECUENCIA_ENCUESTA G_S_Seguro G_S_SeguroAdicional G_S_ConsultaEPS G_S_ConsultaParticular G_S_ConsultaPrepagada G_S_OdontoEPS G_S_OdontoParticular G_S_OdontoPrepagada G_S_Vacunas G_S_Medicinas G_S_Examenes G_S_Terapias G_S_TerapiasAlternativas G_S_Transporte G_S_Lentes G_S_CirugiasEPS G_S_CirugiasParticular G_S_CirugiasPrepagada G_S_HospEPS G_S_HospPrepagada


*----------3.6: guardar base de datos preliminar  

save `Salud', replace










/*====================================================================================================
              4: Importar datos de Atencion integral de los ninos y ninas menores de 5 anos
====================================================================================================*/

tempfile NNA_Menos5A

*----------4.1: importar datos

use "$original/Atencion integral de los ninos y ninas menores de 5 anos/Atencion integral de los ninos y ninas menores de 5 anos.DTA",clear


*----------4.2: se transforman variable de costos con filtros 
/* Descripción
En estas variables, anteriormente se les ha preguntado si pagan o no por tal servicio o bien. A los que responden negativamente no se les pregunta por el valor del costo del servicio o bien, y por ende esta codificado como un valor missing (NA)
Se decide transformar estos missings en cero (0) porque, lo que se quiere saber es la sumatoria de los gastos del hogar, no si paga o no por el servicio. si se deja el valor en missing, la sumatoria va a dar como resultado un missing por defecto
*/

foreach var in P6169S1 P8564S1 P8566S1 P8568S1 P6191S1 P8572S1 P8574S1{
	replace `var'=0 if `var'==.
	replace `var'=0 if `var'==99
}


*----------4.3: se transforman las variables a costos mensuales
/* Descripción
Además se transforman los costos para que sean mensuales, dividiendo por la frecuencia del pago que es anual
*/


foreach var in P8564S1 P8566S1 P8568S1{
	replace `var'=`var'/12
}

*----------4.4: se renombran las variables
/* Descripción
se renombran las variables que están codificadas según la decumentacion de la ECV del DANE hacia unos nombres autodescriptivos

En el caso de los gastos: se inicia con la codificacion de G_ED_  "Gasto en Educacion" seguido del servicio publico especifico 
ej: G_ED_Matricula

*/
	
	
rename (P6169S1 P8564S1 P8566S1 P8568S1 P6191S1 P8572S1 P8574S1) (G_ED_NNA_Matricula G_ED_NNA_Uniformes G_ED_NNA_Libros1 G_ED_NNA_Libros2 G_ED_NNA_Pension G_ED_NNA_Transporte G_ED_NNA_Alimentos)

rename FEX_C FEX_C_PERSONA

*----------4.5: guardar variables necesarias 

collapse (sum) G_ED_NNA_Matricula G_ED_NNA_Uniformes G_ED_NNA_Libros1 G_ED_NNA_Libros2 G_ED_NNA_Pension G_ED_NNA_Transporte G_ED_NNA_Alimentos,by(DIRECTORIO SECUENCIA_ENCUESTA)

keep DIRECTORIO SECUENCIA_ENCUESTA G_ED_NNA_Matricula G_ED_NNA_Uniformes G_ED_NNA_Libros1 G_ED_NNA_Libros2 G_ED_NNA_Pension G_ED_NNA_Transporte G_ED_NNA_Alimentos


*----------4.6: guardar base de datos preliminar  

save `NNA_Menos5A', replace







/*====================================================================================================
              5: Importar datos de Educacion
====================================================================================================*/

tempfile Educacion

*----------5.1: importar datos

use "$original/Educacion/Educacion.DTA",clear

drop SECUENCIA_ENCUESTA
rename SECUENCIA_P SECUENCIA_ENCUESTA


*----------5.2: se transforman variable de costos con filtros 
/* Descripción
En estas variables, anteriormente se les ha preguntado si pagan o no por tal servicio o bien. A los que responden negativamente no se les pregunta por el valor del costo del servicio o bien, y por ende esta codificado como un valor missing (NA)
Se decide transformar estos missings en cero (0) porque, lo que se quiere saber es la sumatoria de los gastos del hogar, no si paga o no por el servicio. si se deja el valor en missing, la sumatoria va a dar como resultado un missing por defecto
*/

foreach var in P3341S1 P3342S1 P3343S1 P3344S1 P3345S1 P3346S1 P3347S1{
	replace `var'=0 if `var'==.
	replace `var'=0 if `var'==99
}


*----------5.3: se transforman las variables a costos mensuales
/* Descripción
Además se transforman los costos para que sean mensuales, dividiendo por la frecuencia del pago que es anual
*/


foreach var in P3341S1 P3342S1 P3343S1{
	replace `var'=`var'/12
}

*----------5.4: se renombran las variables
/* Descripción
se renombran las variables que están codificadas según la decumentacion de la ECV del DANE hacia unos nombres autodescriptivos

En el caso de los gastos: se inicia con la codificacion de G_ED_  "Gasto en Educacion" seguido del servicio publico especifico 
ej: G_ED_Matricula

*/
	
	
rename (P3341S1 P3342S1 P3343S1 P3344S1 P3345S1 P3346S1 P3347S1) (G_ED_Matricula G_ED_Uniformes G_ED_Libros1 G_ED_Pension G_ED_Transporte G_ED_Alimentos G_ED_Libros2)

rename FEX_C FEX_C_PERSONA

*----------5.5: guardar variables necesarias 

collapse (sum) G_ED_Matricula G_ED_Uniformes G_ED_Libros1 G_ED_Pension G_ED_Transporte G_ED_Alimentos G_ED_Libros2,by(DIRECTORIO SECUENCIA_ENCUESTA)

keep DIRECTORIO SECUENCIA_ENCUESTA G_ED_Matricula G_ED_Uniformes G_ED_Libros1 G_ED_Pension G_ED_Transporte G_ED_Alimentos G_ED_Libros2


*----------5.6: guardar base de datos preliminar  

save `Educacion', replace





/*====================================================================================================
              6: Importar datos de Fuerza de trabajo
====================================================================================================*/

tempfile Trabajo

*----------6.1: importar datos

use "$original/Fuerza de trabajo/Fuerza de trabajo.DTA",clear

drop SECUENCIA_ENCUESTA
rename SECUENCIA_P SECUENCIA_ENCUESTA

*----------6.2: se transforman variable de costos e ingresos con filtros 
/* Descripción
En estas variables, anteriormente se les ha preguntado si pagan o no por tal servicio o bien o si reciben ingreso por este concepto. A los que responden negativamente no se les pregunta por el valor del costo o ingreso, y por ende esta codificado como un valor missing (NA)
Se decide transformar estos missings en cero (0) porque, lo que se quiere saber es la sumatoria de los gastos e ingresos del hogar, no si paga o no por el servicio o si recibe ese ingreso. si se deja el valor en missing, la sumatoria va a dar como resultado un missing por defecto
*/

foreach var in P8624 P6595S1 P6605S1 P6623S1 P6615S1 P8628S1 P8631S1 P8631S1 P1087S1A1 P1087S2A1 P1087S3A1 P1087S4A1 P1087S5A1 P6750 P550 P8636S1 P8640S1 P8642S1 P8644S1 P8646S1 P8648S1 {
	replace `var'=0 if `var'==.
	replace `var'=0 if `var'==99
}

*----------6.3: se transforman las variables a costos e ingresos mensuales
/* Descripción
Además se transforman los costos e ingresos para que sean mensuales, dividiendo por la frecuencia del pago que es anual
*/

foreach var in P8631S1 P1087S1A1 P1087S2A1 P1087S3A1 P1087S4A1 P1087S5A1 P550 P8648S1{
	replace `var'=`var'/12
}

*----------6.4: se renombran las variables
/* Descripción
se renombran las variables que están codificadas según la decumentacion de la ECV del DANE hacia unos nombres autodescriptivos

En el caso de los ingresos: se inicia con la codificacion de I_ "Ingresos" seguido del tipo de ingreso especifico
ej: I_Empleo
*/
	
rename (P8624 P6595S1 P6605S1 P6623S1 P6615S1 P8626S1 P8628S1 P8631S1 P1087S1A1 P1087S2A1 P1087S3A1 P1087S4A1 P1087S5A1 P6750 P550 P8636S1 P8640S1 P8642S1 P8644S1 P8646S1 P8648S1) (I_Empleo I_Alimentos I_Vivienda I_BonosEspecie I_AyudaTransporte I_AyudaAlimentos I_AuxilioTransporte I_PrimaMensual I_PrimaServicios I_PrimaNavidad I_PrimaVacaciones I_Bonificaciones I_Indemnizaciones I_Honorarios I_GananciaNegocio I_Trabajo1 I_Trabajo2 I_Pension I_SostenimientoHijos I_Arriendos I_PrimaJubiliacion)

rename FEX_C FEX_C_PERSONA


*----------6.5: guardar variables necesarias 

collapse (sum) I_Empleo I_Alimentos I_Vivienda I_BonosEspecie I_AyudaTransporte I_AyudaAlimentos I_AuxilioTransporte I_PrimaMensual I_PrimaServicios I_PrimaNavidad I_PrimaVacaciones I_Bonificaciones I_Indemnizaciones I_Honorarios I_GananciaNegocio I_Trabajo1 I_Trabajo2 I_Pension I_SostenimientoHijos I_Arriendos I_PrimaJubiliacion, by(DIRECTORIO SECUENCIA_ENCUESTA)


keep DIRECTORIO SECUENCIA_ENCUESTA I_Empleo I_Alimentos I_Vivienda I_BonosEspecie I_AyudaTransporte I_AyudaAlimentos I_AuxilioTransporte I_PrimaMensual I_PrimaServicios I_PrimaNavidad I_PrimaVacaciones I_Bonificaciones I_Indemnizaciones I_Honorarios I_GananciaNegocio I_Trabajo1 I_Trabajo2 I_Pension I_SostenimientoHijos I_Arriendos I_PrimaJubiliacion


*----------6.6: guardar base de datos preliminar  

save `Trabajo', replace







/*====================================================================================================
              7: Importar datos de Tecnologias de informacion y comunicacion
====================================================================================================*/

tempfile TIC

*----------7.1: importar datos

use "$original/Tecnologias de informacion y comunicacion/Tecnologias de informacion y comunicacion.DTA",clear

drop SECUENCIA_ENCUESTA
rename SECUENCIA_P SECUENCIA_ENCUESTA

*----------7.2: se transforman variable de costos e ingresos con filtros 
/* Descripción
En estas variables, anteriormente se les ha preguntado si pagan o no por tal servicio o bien o si reciben ingreso por este concepto. A los que responden negativamente no se les pregunta por el valor del costo o ingreso, y por ende esta codificado como un valor missing (NA)
Se decide transformar estos missings en cero (0) porque, lo que se quiere saber es la sumatoria de los gastos e ingresos del hogar, no si paga o no por el servicio o si recibe ese ingreso. si se deja el valor en missing, la sumatoria va a dar como resultado un missing por defecto
*/

foreach var in P803S1{
	replace `var'=0 if `var'==.
	replace `var'=0 if `var'==99
}

*----------6.3: se renombran las variables
/* Descripción
se renombran las variables que están codificadas según la decumentacion de la ECV del DANE hacia unos nombres autodescriptivos

En el caso de los ingresos: se inicia con la codificacion de I_ "Ingresos" seguido del tipo de ingreso especifico
ej: I_Empleo
*/
		
rename (P803S1) (G_TIC_Celular)
rename FEX_C FEX_C_PERSONA


*----------7.4: guardar variables necesarias 

collapse (sum) G_TIC_Celular, by(DIRECTORIO SECUENCIA_ENCUESTA)

keep DIRECTORIO SECUENCIA_ENCUESTA G_TIC_Celular


*----------7.5: guardar base de datos preliminar  

save `TIC', replace




/*====================================================================================================
              8: Importar datos de Tenencia y financiacion de la vivienda que ocupa el hogar
====================================================================================================*/

tempfile TenenciaVivienda

*----------8.1: importar datos

use "$original/Tenencia y financiacion de la vivienda que ocupa el hogar/Tenencia y financiacion de la vivienda que ocupa el hogar.DTA",clear


*----------8.2: se transforman variable de costos e ingresos con filtros 
/* Descripción
En estas variables, anteriormente se les ha preguntado si pagan o no por tal servicio o bien o si reciben ingreso por este concepto. A los que responden negativamente no se les pregunta por el valor del costo o ingreso, y por ende esta codificado como un valor missing (NA)
Se decide transformar estos missings en cero (0) porque, lo que se quiere saber es la sumatoria de los gastos e ingresos del hogar, no si paga o no por el servicio o si recibe ese ingreso. si se deja el valor en missing, la sumatoria va a dar como resultado un missing por defecto
*/

*P5140
foreach var in P5100 P3198 P5610 P8693 P5130 P5650{
	replace `var'=0 if `var'==.
	replace `var'=0 if `var'==99
}

*----------8.3: se transforman las variables a costos e ingresos mensuales
/* Descripción
Además se transforman los costos e ingresos para que sean mensuales, dividiendo por la frecuencia del pago que es anual
*/

replace P5610= P5610/P5610S1 if P5610S1>1

foreach var in P5610 P8693 {
	replace `var'=`var'/12
}



*----------8.4: se renombran las variables
/* Descripción
se renombran las variables que están codificadas según la decumentacion de la ECV del DANE hacia unos nombres autodescriptivos

En el caso de los gastos: se inicia con la codificacion de G_V_  "Gasto en Vivienda" seguido del servicio publico especifico 
ej: G_V_Arriendo
*/
	
	
rename (P5100 P3198 P5610 P8693 P5130 P5650) (G_V_Amortizacion G_V_Seguros G_V_Predial G_V_Valorizacion G_V_Arriendo G_V_Administracion)

rename FEX_C FEX_C_HOGAR


*----------8.5: guardar variables necesarias 

collapse (sum) G_V_Amortizacion G_V_Seguros G_V_Predial G_V_Valorizacion G_V_Arriendo G_V_Administracion, by(DIRECTORIO SECUENCIA_ENCUESTA)


keep DIRECTORIO SECUENCIA_ENCUESTA G_V_Amortizacion G_V_Seguros G_V_Predial G_V_Valorizacion G_V_Arriendo G_V_Administracion


*----------8.6: guardar base de datos preliminar  

save `TenenciaVivienda', replace





/*====================================================================================================
              9: Importar datos de Gastos de los hogares 
====================================================================================================*/

*----------9.1: se crea una base de datos que tiene una observacion para cada tipo de gasto por hogar 

tempfile GatosHogares

use "$original/Servicios del hogar/Servicios del hogar.DTA",clear

keep DIRECTORIO SECUENCIA_ENCUESTA

expand 104

bysort DIRECTORIO SECUENCIA_ENCUESTA: gen P3204 = _n

save `GatosHogares', replace


*----------9.2: importar datos de los gastos de los hogares y se junta con la base de datos anterior

use "$original/Gastos de los hogares/Gastos de los hogares.DTA",clear

drop SECUENCIA_ENCUESTA
rename SECUENCIA_P SECUENCIA_ENCUESTA

merge 1:m DIRECTORIO SECUENCIA_ENCUESTA P3204 using `GatosHogares', nogen


*----------9.3: se transforman variable de costos e ingresos con filtros 
/* Descripción
En estas variables, anteriormente se les ha preguntado si pagan o no por tal servicio o bien o si reciben ingreso por este concepto. A los que responden negativamente no se les pregunta por el valor del costo o ingreso, y por ende esta codificado como un valor missing (NA)
Se decide transformar estos missings en cero (0) porque, lo que se quiere saber es la sumatoria de los gastos e ingresos del hogar, no si paga o no por el servicio o si recibe ese ingreso. si se deja el valor en missing, la sumatoria va a dar como resultado un missing por defecto

*/


foreach var in P3204S1{
	replace `var'=0 if `var'==.
	replace `var'=0 if `var'==99
}


*----------9.4: se transforman variable de costos e ingresos a valores mensuales 
/* Descripción
si el gasto es semanl se multiplica X4, si el gasto es mensual se multiplica x1, si el gato es trimestral se divide /3, y si el gasto es anual se divide en /12
*/
replace P3204S1= P3204S1*4 if P3204>=1 & P3204<=35 // gastos semanales x4 -> P3204==31 GastoTIC
replace P3204S1= P3204S1*1 if P3204>=36 & P3204<=67  // gastos mensuales x1 
replace P3204S1= P3204S1/3 if P3204>=68 & P3204<=77  // gastos trimestrales /3
replace P3204S1= P3204S1/12 if P3204>=78 // gastos anuales /12


*----------9.5: se crea la variable tipo de gasto, agrupacion de los gastos del hogar

gen TipoGasto = "Alimentos" if  P3204>=1 & P3204<=26
replace TipoGasto = "Ocio" if  P3204>=27 & P3204<=28
replace TipoGasto = "ServicioyCuidadoDomestico" if  P3204==29
replace TipoGasto = "Transporte" if  P3204==30
replace TipoGasto = "CafeInternet" if  P3204==31
replace TipoGasto = "Alimentos" if  P3204>=32 & P3204<=33
replace TipoGasto = "Ocio" if  P3204==34
replace TipoGasto = "OtrosGastos" if  P3204==35
replace TipoGasto = "Aseo" if  P3204>=36 & P3204<=40
replace TipoGasto = "Transporte" if  P3204>=41 & P3204<=46
replace TipoGasto = "MascotasAnimales" if  P3204==47
replace TipoGasto = "RecreacionDeporte" if  P3204>=48 & P3204<=49
replace TipoGasto = "TelefoniaFija" if  P3204==50
replace TipoGasto = "InternetFijo" if  P3204==51
replace TipoGasto = "Television" if  P3204==52
replace TipoGasto = "PlataformasStreaming" if  P3204==53
replace TipoGasto = "CombosTvInternetTelefonia" if  P3204==54
replace TipoGasto = "LibrosFisicoDigital" if  P3204==55
replace TipoGasto = "PeriodicoFisicoDigital" if  P3204==56
replace TipoGasto = "EduacionNoFormal" if  P3204==57
replace TipoGasto = "Ocio" if  P3204==58
replace TipoGasto = "CuidadoPersonal" if  P3204>=59 & P3204<=61
replace TipoGasto = "ServicioyCuidadoDomestico" if  P3204>=62 & P3204<=63
replace TipoGasto = "ServiciosFinancieros" if  P3204>=64 & P3204<=65
replace TipoGasto = "OtrosGastos" if  P3204>=66 & P3204<=67
replace TipoGasto = "RopaCalzado" if  P3204>=68 & P3204<=72
replace TipoGasto = "Transporte" if  P3204==73
replace TipoGasto = "AlmacenamientoMultimedia" if  P3204==74
replace TipoGasto = "Viaje" if  P3204==75
replace TipoGasto = "RopaCalzado" if  P3204==76
replace TipoGasto = "OtrosGastos" if  P3204==77
replace TipoGasto = "Hogar" if  P3204>=78 & P3204<=81
replace TipoGasto = "CarroMotoBicicleta" if  P3204>=82 & P3204<=84
replace TipoGasto = "Telefono" if  P3204==85
replace TipoGasto = "EquiposMultimedia" if  P3204==86
replace TipoGasto = "TV" if  P3204==87
replace TipoGasto = "PC" if  P3204==88
replace TipoGasto = "Software" if  P3204==89
replace TipoGasto = "Hogar" if  P3204==90
replace TipoGasto = "VideoGames" if  P3204==91
replace TipoGasto = "CuidadoPersonal" if  P3204==92
replace TipoGasto = "RopaCalzado" if  P3204==93
replace TipoGasto = "ReparacionTecnologia" if  P3204==94
replace TipoGasto = "Hogar" if  P3204==95
replace TipoGasto = "Viaje" if  P3204>=96 & P3204<=98
replace TipoGasto = "Impuestos" if  P3204>=99 & P3204<=101
replace TipoGasto = "Inmuebles" if  P3204==102
replace TipoGasto = "MascotasAnimales" if  P3204==103
replace TipoGasto = "OtrosGastos" if  P3204==104


*----------9.6: se agrupan los gastos por tipoGasto 
collapse (sum) P3204S1, by(DIRECTORIO SECUENCIA_ENCUESTA TipoGasto)


*----------9.5: se hace reshape a wide una variable por cada tipo de gastos
/* Descripcion
Se renombre la variable del valor del gasto a G_ 
se hace el reshape a wide format para que quede una variable por cada tipo de gasto, con el nombre de la siguiente forma G_Alimentos
*/

rename P3204S1 G_

reshape wide G_, i(DIRECTORIO SECUENCIA_ENCUESTA) j(TipoGasto) string


*----------9.6: guardar base de datos preliminar  
save `GatosHogares', replace





/*====================================================================================================
              10: Juntar Bases de datos temporales 
====================================================================================================*/

*----------10.1: se juntan las bases de datos temporales 

use `Datos_Vivienda', clear

merge 1:m DIRECTORIO using `Servicios_del_hogar', nogen

merge 1:m DIRECTORIO SECUENCIA_ENCUESTA using `Salud', nogen

merge 1:m DIRECTORIO SECUENCIA_ENCUESTA using `Educacion', nogen

merge 1:m DIRECTORIO SECUENCIA_ENCUESTA using `Trabajo', nogen

merge 1:m DIRECTORIO SECUENCIA_ENCUESTA using `TIC', nogen

merge 1:m DIRECTORIO SECUENCIA_ENCUESTA using `TenenciaVivienda', nogen

merge 1:m DIRECTORIO SECUENCIA_ENCUESTA using `GatosHogares', nogen


*----------10.2: se crean las variables de ingresos y gastos totales, asi como las variables de ahorro y proporciones 


* gastos totales, suma de todos los gastos 
egen GastosTotales =  rowtotal(G_*), m

* gastos TIC, suma de los gastos en TIC 
gen GastosTIC = G_TIC_Celular + G_CafeInternet + G_CombosTvInternetTelefonia + G_EquiposMultimedia + G_InternetFijo + G_LibrosFisicoDigital + G_PC + G_PeriodicoFisicoDigital +  G_PlataformasStreaming + G_ReparacionTecnologia + G_Software + G_TV + G_TelefoniaFija + G_Telefono + G_Television

* proporcion de gastos tic sobre gastos totales 
gen Proporcion_GastosTIC = GastosTIC/GastosTotales

* ingresos totales. diferente a I_HOGAR creada por el DANE. tiene menos categorias de ingresos, algunos de subsidios y demás 
gen Ingresos = I_Empleo + I_Alimentos + I_Vivienda + I_BonosEspecie + I_AyudaTransporte + I_AyudaAlimentos + I_AuxilioTransporte + I_PrimaMensual + I_PrimaServicios + I_PrimaNavidad + I_PrimaVacaciones + I_Bonificaciones + I_Indemnizaciones + I_Honorarios + I_GananciaNegocio + I_Trabajo1 + I_Trabajo2 + I_Pension + I_SostenimientoHijos + I_Arriendos + I_PrimaJubiliacion

** se crean las variables de ahorro y proporcion de gastos sobre ingresos según los ingresos de generados por el DANE 

* ahorro total = ingresos - gastos 
gen AhorroTotal_ECV = I_HOGAR - GastosTotales

* ahorro total sin gastos tic, =  Ingresos - gastos + gastos tic 
gen AhorroSinTIC_ECV = I_HOGAR - GastosTotales + GastosTIC

* proporcion de gastos tic = gastos tic / ingresos 
gen Proporcion_GastosTICIngresos_ECV = GastosTIC/I_HOGAR

* proporcion de gastos = gastos totales / ingresos 
gen Proporcion_GastosIngresos_ECV = GastosTotales/I_HOGAR


* ahorro total = ingresos - gastos 
gen AhorroTotal = Ingresos - GastosTotales

* ahorro total sin gastos tic, =  Ingresos - gastos + gastos tic 
gen AhorroSinTIC = Ingresos - GastosTotales + GastosTIC

* proporcion de gastos tic = gastos tic / ingresos 
gen Proporcion_GastosTICIngresos = GastosTIC/Ingresos

* proporcion de gastos = gastos totales / ingresos 
gen Proporcion_GastosIngresos = GastosTotales/Ingresos


save "$working/ECV_Ingresos_Gastos.dta",replace 






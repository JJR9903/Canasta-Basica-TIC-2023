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

keep DIRECTORIO P1_DEPARTAMENTO REGION CLASE

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
}

*----------2.3: se transforman las variables a costos mensuales
/* Descripción
Además se transforman los costos para que sean mensuales, dividiendo por la frecuencia del pago
*/

replace P5018S2=P5018S2/P5018S1 if P5018S1!=. // electricidad
replace P3163S2=P3163S2/P3163S1 if P5034S1!=. // gas natural
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

keep DIRECTORIO SECUENCIA_ENCUESTA ORDEN FEX_C_HOGAR G_SP_Electricidad G_SP_GasNatural G_SP_Alcantarillado G_SP_RecoleccionBasuras G_SP_Acueducto G_SP_CombustibleCocina I_HOGAR I_PERCAPITA N_PERSONAS_HOGAR


*----------2.6: guardar base de datos preliminar  

save `Servicios_del_hogar', replace



/*
/*====================================================================================================
              3: Importar datos de Salud
====================================================================================================*/

tempfile Salud

*----------4.1: importar datos

use "$original/Atencion integral de los ninos y ninas menores de 5 anos/Atencion integral de los ninos y ninas menores de 5 anos.DTA",clear


*----------4.2: se transforman variable de costos con filtros 
/* Descripción
En estas variables, anteriormente se les ha preguntado si pagan o no por tal servicio o bien. A los que responden negativamente no se les pregunta por el valor del costo del servicio o bien, y por ende esta codificado como un valor missing (NA)
Se decide transformar estos missings en cero (0) porque, lo que se quiere saber es la sumatoria de los gastos del hogar, no si paga o no por el servicio. si se deja el valor en missing, la sumatoria va a dar como resultado un missing por defecto
*/

foreach var in {
	replace `var'=0 if `var'==.
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
	
	
rename (P6169S1 P8564S1 P8566S1 P8568S1 P6191S1 P8572S1 P8574S1) (G_ED_Matricula G_ED_Uniformes G_ED_Libros1 G_ED_Libros2 G_ED_Pension G_ED_Transporte G_ED_Alimentos)

rename FEX_C FEX_C_PERSONA


*----------4.5: guardar variables necesarias 

keep DIRECTORIO SECUENCIA_ENCUESTA SECUENCIA_P ORDEN  G_ED_Matricula G_ED_Uniformes G_ED_Libros1 G_ED_Libros2 G_ED_Pension G_ED_Transporte G_ED_Alimentos FEX_C_PERSONA


*----------4.6: guardar base de datos preliminar  

save `NNA_Menos5A', replace
*/









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
	
	
rename (P6169S1 P8564S1 P8566S1 P8568S1 P6191S1 P8572S1 P8574S1) (G_ED_Matricula G_ED_Uniformes G_ED_Libros1 G_ED_Libros2 G_ED_Pension G_ED_Transporte G_ED_Alimentos)

rename FEX_C FEX_C_PERSONA


*----------4.5: guardar variables necesarias 

keep DIRECTORIO SECUENCIA_ENCUESTA SECUENCIA_P ORDEN  G_ED_Matricula G_ED_Uniformes G_ED_Libros1 G_ED_Libros2 G_ED_Pension G_ED_Transporte G_ED_Alimentos FEX_C_PERSONA


*----------4.6: guardar base de datos preliminar  

save `NNA_Menos5A', replace







/*====================================================================================================
              5: Importar datos de Educacion
====================================================================================================*/

tempfile Educacion

*----------5.1: importar datos

use "$original/Educacion/Educacion.DTA",clear



*----------5.2: se transforman variable de costos con filtros 
/* Descripción
En estas variables, anteriormente se les ha preguntado si pagan o no por tal servicio o bien. A los que responden negativamente no se les pregunta por el valor del costo del servicio o bien, y por ende esta codificado como un valor missing (NA)
Se decide transformar estos missings en cero (0) porque, lo que se quiere saber es la sumatoria de los gastos del hogar, no si paga o no por el servicio. si se deja el valor en missing, la sumatoria va a dar como resultado un missing por defecto
*/

foreach var in P3341S1 P3342S1 P3343S1 P3344S1 P3345S1 P3346S1 P3347S1{
	replace `var'=0 if `var'==.
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

keep DIRECTORIO SECUENCIA_ENCUESTA SECUENCIA_P ORDEN G_ED_Matricula G_ED_Uniformes G_ED_Libros1 G_ED_Pension G_ED_Transporte G_ED_Alimentos G_ED_Libros2 FEX_C_PERSONA


*----------5.6: guardar base de datos preliminar  

save `Educacion', replace




/*====================================================================================================
              6: Importar datos de Fuerza de trabajo
====================================================================================================*/

tempfile Trabajo

*----------6.1: importar datos

use "$original/Fuerza de trabajo/Fuerza de trabajo.DTA",clear


*----------6.2: se transforman variable de costos e ingresos con filtros 
/* Descripción
En estas variables, anteriormente se les ha preguntado si pagan o no por tal servicio o bien o si reciben ingreso por este concepto. A los que responden negativamente no se les pregunta por el valor del costo o ingreso, y por ende esta codificado como un valor missing (NA)
Se decide transformar estos missings en cero (0) porque, lo que se quiere saber es la sumatoria de los gastos e ingresos del hogar, no si paga o no por el servicio o si recibe ese ingreso. si se deja el valor en missing, la sumatoria va a dar como resultado un missing por defecto
*/

foreach var in P8624 P6595S1 P6605S1 P6623S1 P6615S1 P8628S1 P8631S1 P1087S1A1 P1087S2A1 P1087S3A1 P1087S4A1 P1087S5A1 P6750 P550 P8636S1 P8640S1 P8642S1 P8644S1 P8646S1 P8648S1 {
	replace `var'=0 if `var'==.
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
	
	
rename (P8624 P6595S1 P6605S1 P6623S1 P6615S1 P8628S1 P8631S1 P1087S1A1 P1087S2A1 P1087S3A1 P1087S4A1 P1087S5A1 P6750 P550 P8636S1 P8640S1 P8642S1 P8644S1 P8646S1 P8648S1) (I_Empleo I_Alimentos I_Vivienda I_BonosEspecie I_AyudaTransporte I_AyudaAlimentos I_AuxilioTransporte I_PrimaMensual I_PrimaServicios I_PrimaNavidad I_PrimaVacaciones I_Bonificaciones I_Indemnizaciones I_Honorarios I_GananciaNegocio I_Trabajo1 I_Trabajo2 I_Pension I_SostenimientoHijos I_Arriendos I_PrimaJubiliacion)

rename FEX_C FEX_C_PERSONA


*----------6.5: guardar variables necesarias 

keep DIRECTORIO SECUENCIA_ENCUESTA SECUENCIA_P ORDEN I_Empleo I_Alimentos I_Vivienda I_BonosEspecie I_AyudaTransporte I_AyudaAlimentos I_AuxilioTransporte I_PrimaMensual I_PrimaServicios I_PrimaNavidad I_PrimaVacaciones I_Bonificaciones I_Indemnizaciones I_Honorarios I_GananciaNegocio I_Trabajo1 I_Trabajo2 I_Pension I_SostenimientoHijos I_Arriendos I_PrimaJubiliacion FEX_C_PERSONA


*----------6.6: guardar base de datos preliminar  

save `Trabajo', replace







/*====================================================================================================
              7: Importar datos de Tecnologias de informacion y comunicacion
====================================================================================================*/

tempfile TIC

*----------7.1: importar datos

use "$original/Tecnologias de informacion y comunicacion/Tecnologias de informacion y comunicacion.DTA",clear


*----------7.2: se transforman variable de costos e ingresos con filtros 
/* Descripción
En estas variables, anteriormente se les ha preguntado si pagan o no por tal servicio o bien o si reciben ingreso por este concepto. A los que responden negativamente no se les pregunta por el valor del costo o ingreso, y por ende esta codificado como un valor missing (NA)
Se decide transformar estos missings en cero (0) porque, lo que se quiere saber es la sumatoria de los gastos e ingresos del hogar, no si paga o no por el servicio o si recibe ese ingreso. si se deja el valor en missing, la sumatoria va a dar como resultado un missing por defecto
*/

foreach var in P803S1{
	replace `var'=0 if `var'==.
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

keep DIRECTORIO SECUENCIA_ENCUESTA SECUENCIA_P ORDEN G_TIC_Celular FEX_C_PERSONA


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

foreach var in P5100 P3198 P5610 P8693 P5130 P5140 P5650{
	replace `var'=0 if `var'==.
}

*----------8.3: se transforman las variables a costos e ingresos mensuales
/* Descripción
Además se transforman los costos e ingresos para que sean mensuales, dividiendo por la frecuencia del pago que es anual
*/

replace P5610= P5610/P5610S1 if P5610S1>1

foreach var in P3198 P5610 P8693 {
	replace `var'=`var'/12
}



*----------8.4: se renombran las variables
/* Descripción
se renombran las variables que están codificadas según la decumentacion de la ECV del DANE hacia unos nombres autodescriptivos

En el caso de los gastos: se inicia con la codificacion de G_V_  "Gasto en Vivienda" seguido del servicio publico especifico 
ej: G_V_Arriendo
*/
	
	
rename (P5100 P3198 P5610 P8693 P5130 P5140 P5650) (G_V_Amortizacion G_V_Seguros G_V_Predial G_V_Valorizacion G_V_Arriendo G_V_Administracion)

rename FEX_C FEX_C_HOGAR


*----------8.5: guardar variables necesarias 

keep DIRECTORIO SECUENCIA_ENCUESTA SECUENCIA_P ORDEN G_V_Amortizacion G_V_Seguros G_V_Predial G_V_Valorizacion G_V_Arriendo G_V_Administracion FEX_C_HOGAR


*----------8.6: guardar base de datos preliminar  

save `TenenciaVivienda', replace




codebook DIRECTORIO SECUENCIA_ENCUESTA SECUENCIA_P ORDEN  


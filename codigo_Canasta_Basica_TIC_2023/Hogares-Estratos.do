/*==================================================
project:		DNP Canasta Basica TIC       
name: 			Hogares-Estratos
description:	importa y junta la proyección de hogares del DANE para 2022, y la información de % Hogares por estratos de la SUI - Energia electrica 
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

/*====================================================================================================
              1: Importar datos de hogares 
====================================================================================================*/


*----------1.1: importar datos

tempfile Datos_Hogares

import excel "cuanti_secund_Canasta_Basica_TIC_2023/anexo-proyecciones-hogares-dptal-2018-2050-mpal-2018-2035.xlsx", sheet("Hogares mpio 19-22") first clear


keep CodDepto Departamento CodMun Municipio Hogares2022


save `Datos_Hogares', replace

*----------1.1: Crear base de datos de municipios y deptos en mayusculas y sin caracteres especiales 

tempfile Divipola

keep CodDepto Departamento CodMun Municipio



foreach v in Municipio Departamento {
	replace `v' = subinstr(`v', "á", "a", .)
	replace `v' = subinstr(`v', "é", "e", .)
	replace `v' = subinstr(`v', "í", "i", .)
	replace `v' = subinstr(`v', "ó", "o", .)
	replace `v' = subinstr(`v', "ú", "u", .)
	replace `v' = subinstr(`v', "ñ", "n", .)
	replace `v' = subinstr(`v', "ü", "u", .) 
	replace `v' = subinstr(`v', "Á", "A", .)
	replace `v' = subinstr(`v', "É", "E", .)
	replace `v' = subinstr(`v', "Í", "I", .)
	replace `v' = subinstr(`v', "Ó", "O", .)
	replace `v' = subinstr(`v', "Ú", "U", .)
	replace `v' = subinstr(`v', "Ñ", "N", .)
	replace `v' = subinstr(`v', "Ü", "U", .) 
}

replace Municipio = upper(Municipio)
replace Departamento = upper(Departamento)

save `Divipola', replace

/*====================================================================================================
              2: Importar datos de hogares por estratos  
====================================================================================================*/


import excel "cuanti_secund_Canasta_Basica_TIC_2023/Estratos Municipios Energia SUI.xls", first clear

replace Departamento = upper(Departamento)


foreach v in Estrato1 Estrato2 Estrato3 Estrato4 Estrato5 Estrato6 TotalResidencial{
	replace `v' = 0 if `v'==.
}

collapse (sum) Estrato1 Estrato2 Estrato3 Estrato4 Estrato5 Estrato6 TotalResidencial, by(Departamento)

forvalues i= 1/6 {
	gen PorcentajeEstrato`i' = Estrato`i'/TotalResidencial
}


keep Departamento Municipio PorcentajeEstrato*

merge 1:1 Departamento Municipio using `Divipola'

preserve 

keep if _merge==1

export excel using "_merge1.xlsx", firstrow(variables) replace

restore

preserve 

keep if _merge==2

export excel using "_merge2.xlsx", firstrow(variables) replace 

restore





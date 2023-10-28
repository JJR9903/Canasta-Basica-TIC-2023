# Canasta-Basica-TIC-2023
 Caracterizacion de la canasta basica TIC 2023. Proyecto de Econometria consultores - SAI  para el DNP Colombia. 

 Documentación información cuantitativa utilizada durante el producto 1 - Definición de una CBT para Colombia

 En este archivo se muestra una relación del contenido de la carpeta de archivos adjuntos utilizado durante la construcción del entregable 1, por ende este carpeta comprende desde archivos de información secundaria sin procesar, archivos procesados y scripts de procesamiento de la información. 

 La carpeta está compuesta de las siguientas carpetas: 

    - cuanti_secund_Canasta_Basica_TIC_2023: En esta carpeta se encuentran los archivos de información secundaria utilizada sin procesar, tal cual como fueron descargados de sus respectivas fuentes. 

        Dentro de esta carpeta se encuentran las siguientes sub carpetas que segmentan los archivos según fuentes de información

        - ECV-2022: En esta carpeta se encuentran los archivos de la Encuesta de Calidad de Vida del 2022 realizada por el DANE. En la carpeta hay tres archivos de documentación de la encuesta (diccionario de variables, estructura de la encuesta, y formulario de la encuesta), También hay 18 carpetas con el nopmbre de cada uno de los modulos de la encuesta, dentro de esas carpetas se encuentran la base de datos de cada modulo en formato .csv, .sav y .dta. Esta infromación se utiliza para hacer una caracterización de los gastos en TIC.

        - CRC-PostData-Planes-Fijos-Movil: En esta carpeta se encuentran los archivos descargados de PostData de la CRC para los planes fijos y los planes móviles, en formato csv. Adicional hay un archivo de documentación de los archivos. Esta información se utiliza para hacer un análisis de los precios de los planes móviles.

        - BASES-DE-DATOS-MinTIC-CRC: En esta carpeta se encuentran las bases de datos de los informes y formatos que publica el MinTic en conjunto con la CRC. Adicional Hay un archivo de documentación de los archivos. Esta información se utiliza para hacer un análisis de penetraciones, velocidades y accesos por operador en los planes fijos.

        - CRC-T12-T13: En esta carpeta estan los archivos en csv. de los formatos T.1.2 y T.1.3. suministrados por la CRC después de una solicitud de información por parte del DNP para el proyecto. Adcional hay un archivo de documentación de las bases de datos de los formatos. Esta información se utiliza para hacer un análisis de precios, penetraciones, velocidades y accesos por operador en los planes fijos por municipio y departamento.

        - DANE Poblacion: Estan los archivos de las proyecciones de población y hogares del país a nivel departamental y municipal para 2018-2035. Esta información se utiliza para obtener los calculos de penertración (penetración= Accesos/Hogares.)de planes fijos por municipio y departamento.

        - DANE SHP FILES: Dentro de esta carpeta hay dos sub carpetas que agrupan los shape files del DANE de departamentos y municipios de Colombia. Información que es usada para realizar los mapas. 
            - SHP_MGN2018_INTGRD_DEPTO: Es la carpeta que agrupa los shape files de los departamentos de Colombia, con fuente DANE.
            - MGN_2021_COLOMBIA: Es la carpeta que agrupa los shape files de los municipios de Colombia, con fuente DANE. 


    - codigo_Canasta_Basica_TIC_2023: En esta carpeta se encuentran los scripts de Stata de los procesamientos de la información de la carpeta "cuanti_secund_Canasta_Basica_TIC_2023". 

        Dentro de esta carpeta se encuentra otro archivo de documentación como este que documenta los scripts que hay dentro de la carpeta.

    - analisis_Canasta_Basica_TIC_2023: En esta carpeta se encuentran los archivos de analisis intermedio resultantes de un procesamineto inicial de la infromación de la carpeta "cuanti_secund_Canasta_Basica_TIC_2023" por los scripts alojados en la cartpeta "codigo_Canasta_Basica_TIC_2023".

        Dentro de esta carpeta se encuentra otro archivo de documentación como este que documenta los archivos que hay dentro de la carpeta.

    - resultad_Canasta_Basica_TIC_2023: En esta carpeta se encuentran los archivos que contienen el análisis final del producto 1. Aquí se encuentran los datos, tablas, gráficas, y mapas que se encuentran en el documento del producto 1. 


     Dentro de esta carpeta se encuentran las siguientes sub carpetas que segmentan los archivos según fuentes de información

     - movil: Están las tablas, gráficas, y mapas que se encuentran en el documento del producto 1 por parte del analisis de servicio de internet movil. 

     - fijo: Están las tablas, gráficas, y mapas que se encuentran en el documento del producto 1 por parte del analisis de servicio de internet fijo. 

     - Costos terminales: Están las tablas y archivos de sustento del analisis del costo de las terminales (dispositivos).
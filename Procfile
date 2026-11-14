web: java $JAVA_OPTS -jar target/webapp-runner.jar --port $PORT target/sadu_apis.war

#1. Sobre la carpeta target/
Hiciste exactamente lo correcto al ignorar la carpeta target/ en el .gitignore. Esa carpeta solo contiene los archivos binarios temporales que se generan al compilar en tu computadora. En GitHub solo debe subir el código fuente (src/, pom.xml, etc.). Cuando Railway recibe tu proyecto, ejecuta mvn package automáticamente y genera su propio target/ en la nube.

2. ¿Por qué Railway falla o genera logs con error?
Tu proyecto es una aplicación Web Java (.war) tradicional con Servlets y JSPs. En tu pom.xml ya configuraste correctamente el plugin webapp-runner para empaquetar Tomcat en un ejecutable .jar.

Sin embargo, para que Railway sepa cómo iniciar la aplicación en la nube, necesita conocer el comando exacto de inicio (pasándole el puerto dinámico $PORT que asigna Railway).
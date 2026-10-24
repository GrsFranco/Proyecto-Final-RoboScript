# RoboScript (JFlex + CUP)

## Estructura
- spec/Scanner.flex, spec/Parser.cup  -> especificaciones
- src/roboscript/Main.java, Estadisticas.java -> código manual
- src/roboscript/Lexer.java, Parser.java, sym.java -> GENERADOS por el build
- tests/*.robot -> archivos de prueba
- lib/ -> jflex-1.9.1.jar, java-cup-11b.jar, java-cup-11b-runtime.jar

## Compilar (Linux/macOS: ./build.sh  |  Windows: build.bat)
1. java -jar lib/jflex-1.9.1.jar -d src/roboscript spec/Scanner.flex
2. java -jar lib/java-cup-11b.jar -package roboscript -parser Parser -destdir src/roboscript spec/Parser.cup
3. javac -encoding UTF-8 -cp lib/java-cup-11b-runtime.jar -d out src/roboscript/*.java

## Ejecutar
java -cp out:lib/java-cup-11b-runtime.jar roboscript.Main tests/valido1_flujo_normal.robot
(Windows: separador ";" en lugar de ":"). La opción --tokens muestra la tabla de tokens.

## IntelliJ IDEA
1. New Project (Java) en la carpeta RoboScript; marque src como Sources Root.
2. File > Project Structure > Libraries > + > Java: agregue java-cup-11b-runtime.jar.
3. Ejecute build.sh / build.bat desde la Terminal de IntelliJ (genera Lexer, Parser y sym);
   clic derecho en src > Reload from Disk.
4. Run > Edit Configurations > Application: Main class roboscript.Main,
   Program arguments: tests/valido1_flujo_normal.robot, Working directory: carpeta del proyecto.

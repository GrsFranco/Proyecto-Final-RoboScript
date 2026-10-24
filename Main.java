package roboscript;

import java.io.IOException;
import java.io.StringReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;

/**
 * Uso: java roboscript.Main [--tokens] archivo.robot
 * Código de salida: 0 = válido, 1 = errores en el análisis, 2 = error de uso/E-S.
 */
public class Main {

    public static void main(String[] args) {
        boolean verTokens = false;
        String ruta = null;
        for (String a : args) {
            if (a.equals("--tokens")) verTokens = true; else ruta = a;
        }
        if (ruta == null) {
            System.err.println("Uso: java roboscript.Main [--tokens] <archivo.robot>");
            System.exit(2);
        }

        String contenido;
        try {
            contenido = new String(Files.readAllBytes(Paths.get(ruta)), StandardCharsets.UTF_8);
        } catch (IOException e) {
            System.err.println("No se pudo leer el archivo: " + e.getMessage());
            System.exit(2);
            return;
        }

        System.out.println("Archivo analizado: " + ruta);
        System.out.println("------------------------------------------------");

        try {
            /* ---------- FASE 1: análisis léxico completo ---------- */
            Lexer lexer = new Lexer(new StringReader(contenido));
            while (lexer.next_token().sym != sym.EOF) { /* consume todos los tokens */ }

            if (verTokens) {
                System.out.println("TOKENS RECONOCIDOS:");
                for (String t : lexer.getTokensLog()) System.out.println("  " + t);
                System.out.println("------------------------------------------------");
            }

            List<String> errLex = lexer.getErroresLexicos();
            if (!errLex.isEmpty()) {
                for (String e : errLex) System.out.println(e);
                System.out.println("------------------------------------------------");
                System.out.println("RESULTADO: ARCHIVO INVÁLIDO (" + errLex.size() + " error(es) léxico(s)).");
                System.out.println("No se ejecuta el análisis sintáctico.");
                System.exit(1);
            }
            System.out.println("Análisis léxico: CORRECTO (" + lexer.getTotalTokens() + " tokens)");

            /* ---------- FASE 2: análisis sintáctico ---------- */
            Parser parser = new Parser(new Lexer(new StringReader(contenido)));
            parser.parse();

            if (!parser.erroresSintacticos.isEmpty()) {
                for (String e : parser.erroresSintacticos) System.out.println(e);
                System.out.println("------------------------------------------------");
                System.out.println("RESULTADO: ARCHIVO INVÁLIDO (error sintáctico).");
                System.exit(1);
            }

            System.out.println("Análisis sintáctico: CORRECTO");
            System.out.println("RESULTADO: ARCHIVO VÁLIDO");
            System.out.println();
            parser.stats.tokens = lexer.getTotalTokens();
            parser.stats.imprimir();
            System.exit(0);

        } catch (Exception e) {
            System.err.println("Error interno durante el análisis: " + e);
            System.exit(2);
        }
    }
}

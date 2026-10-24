/* ==========================================================
 *  RoboScript - Analizador léxico (JFlex)
 *  Genera: src/roboscript/Lexer.java
 * ========================================================== */
package roboscript;

import java_cup.runtime.Symbol;
import java.util.ArrayList;
import java.util.List;

%%

%class Lexer
%public
%unicode
%line
%column
%cup

%{
    private int totalTokens = 0;
    private final List<String> erroresLexicos = new ArrayList<>();
    private final List<String> tokensLog = new ArrayList<>();

    public int getTotalTokens()             { return totalTokens; }
    public List<String> getErroresLexicos() { return erroresLexicos; }
    public List<String> getTokensLog()      { return tokensLog; }

    /* Normaliza saltos de línea/tabulaciones (solo para mostrar el lexema). */
    private String limpio(String s) {
        return s.replace("\r", "").replace("\n", " ").replace("\t", " ");
    }

    /* Crea el símbolo para CUP. left = línea, right = columna (base 1). */
    private Symbol tok(int tipo, String categoria) {
        totalTokens++;
        String lex = limpio(yytext());
        tokensLog.add(String.format("%-18s %-20s línea %-4d columna %d",
                      categoria, lex, yyline + 1, yycolumn + 1));
        return new Symbol(tipo, yyline + 1, yycolumn + 1, lex);
    }

    private Symbol palabra(int tipo) { return tok(tipo, "PALABRA_RESERVADA"); }

    private void error(String descripcion) {
        erroresLexicos.add(String.format(
            "Error léxico en línea %d, columna %d: %s '%s'",
            yyline + 1, yycolumn + 1, descripcion, limpio(yytext())));
    }
%}

/* ---------------- Definiciones regulares ---------------- */
ESPACIO          = [ \t\r\n\f]

T_CODIGO_ROBOT   = [0-9]{3}[A-Z]{3}
T_CODIGO_ZONA    = "Z-"[0-9]{2}
T_CODIGO_OBJETO  = "OBJ-"[0-9]{4}
T_COORDENADA     = "X"[0-9]+","{ESPACIO}*"Y"[0-9]+
T_PORCENTAJE     = ("100"|[0-9]{1,2})"%"
T_DURACION       = [0-9]+[sm]
T_NUMERO         = [0-9]+

/* Palabra/código mal formado: se reporta como UN solo error léxico. */
SECUENCIA_INVALIDA = [A-Za-z0-9_\-]+

%%

{ESPACIO}+        { /* se ignoran espacios, tabulaciones y saltos de línea */ }

/* ---------------- Palabras reservadas ---------------- */
"ROBOT"           { return palabra(sym.ROBOT); }
"INICIO"          { return palabra(sym.INICIO); }
"AVANZAR"         { return palabra(sym.AVANZAR); }
"RETROCEDER"      { return palabra(sym.RETROCEDER); }
"GIRAR"           { return palabra(sym.GIRAR); }
"DERECHA"         { return palabra(sym.DERECHA); }
"IZQUIERDA"       { return palabra(sym.IZQUIERDA); }
"SEGUIR"          { return palabra(sym.SEGUIR); }
"LINEA"           { return palabra(sym.LINEA); }
"LEVANTAR"        { return palabra(sym.LEVANTAR); }
"MOVER"           { return palabra(sym.MOVER); }
"SOLTAR"          { return palabra(sym.SOLTAR); }
"REPETIR"         { return palabra(sym.REPETIR); }
"SI"              { return palabra(sym.SI); }
"SINO"            { return palabra(sym.SINO); }
"FIN"             { return palabra(sym.FIN); }
"OBSTACULO"       { return palabra(sym.OBSTACULO); }
"VELOCIDAD"       { return palabra(sym.VELOCIDAD); }

/* ---------------- Tokens definidos por expresión regular ---------------- */
{T_CODIGO_ROBOT}  { return tok(sym.T_CODIGO_ROBOT,  "T_CODIGO_ROBOT"); }
{T_CODIGO_ZONA}   { return tok(sym.T_CODIGO_ZONA,   "T_CODIGO_ZONA"); }
{T_CODIGO_OBJETO} { return tok(sym.T_CODIGO_OBJETO, "T_CODIGO_OBJETO"); }
{T_COORDENADA}    { return tok(sym.T_COORDENADA,    "T_COORDENADA"); }
{T_PORCENTAJE}    { return tok(sym.T_PORCENTAJE,    "T_PORCENTAJE"); }
{T_DURACION}      { return tok(sym.T_DURACION,      "T_DURACION"); }
{T_NUMERO}        { return tok(sym.T_NUMERO,        "T_NUMERO"); }

/* ---------------- Errores léxicos (deben ir al final) ---------------- */
{SECUENCIA_INVALIDA} { error("secuencia no reconocida"); }
[^]                  { error("símbolo no reconocido"); }

<<EOF>>           { return new Symbol(sym.EOF, yyline + 1, yycolumn + 1, "EOF"); }

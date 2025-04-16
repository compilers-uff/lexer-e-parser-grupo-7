package chocopy.pa1;
import java_cup.runtime.*;
import java.util.Stack;
import java.util.Iterator;

%%

/*** Do not change the flags below unless you know what you are doing. ***/

%unicode
%line
%column
%states AFTER, STR
%class ChocoPyLexer
%public

%cupsym ChocoPyTokens
%cup
%cupdebug

%eofclose false

/*** Do not change the flags above unless you know what you are doing. ***/

/* The following code section is copied verbatim to the
 * generated lexer class. */
%{
    /* The code below includes some convenience methods to create tokens
     * of a given type and optionally a value that the CUP parser can
     * understand. Specifically, a lot of the logic below deals with
     * embedded information about where in the source code a given token
     * was recognized, so that the parser can report errors accurately.
     * (It need not be modified for this project.) */

    /** Producer of token-related values for the parser. */
    final ComplexSymbolFactory symbolFactory = new ComplexSymbolFactory();
    private String currString = "";
    private int str_l = 0, str_c = 0; //Start location of a string.
    /*A stack that keeps track of the spaces in each Indentation Level*/
    /** Return a terminal symbol of syntactic category TYPE and no
     *  semantic value at the current source location. */
    private Symbol symbol(int type) {
        return symbol(type, yytext());
    }

    /** Return a terminal symbol of syntactic category TYPE and semantic
     *  value VALUE at the current source location. */
    private Symbol symbol(int type, Object value) {
        return symbolFactory.newSymbol(ChocoPyTokens.terminalNames[type], type,
            new ComplexSymbolFactory.Location(yyline + 1, yycolumn + 1),
            new ComplexSymbolFactory.Location(yyline + 1,yycolumn + yylength()),
            value);
    }

    private int currIndent = 0; //Current Indentation Level
    private Stack<Integer> stack = new Stack<>(); 
    private boolean indentErrorUnchecked = true;

    private Symbol whiteSpaceSymbol(int type, Object value){
        return symbolFactory.newSymbol(
            ChocoPyTokens.terminalNames[type],
            type,
            new ComplexSymbolFactory.Location(
                yyline + 1,
                yycolumn - 1
            ),
            new ComplexSymbolFactory.Location(
                yyline + 1,
                yycolumn + yylength()
            ),
            value
        );
    }

    private void push(int indent){
        stack.push(indent);
    }
    private int pop(){
        if(stack.isEmpty()) return 0;
        return stack.pop();
    }
    private int peek(){
        if(stack.isEmpty()) return 0;
        return stack.peek();
    }

    private Symbol emitDent() {
        yypushback(1);
        if(peek() > currIndent) {   
            pop();
            if(peek() < currIndent) {
                currIndent = peek();
                return whiteSpaceSymbol(ChocoPyTokens.UNRECOGNIZED, "<bad indentation>");
            }
            return whiteSpaceSymbol(ChocoPyTokens.DEDENT, currIndent);
        }
        yybegin(AFTER);
        if(peek()< currIndent) {   
            push(currIndent);
            return whiteSpaceSymbol(ChocoPyTokens.INDENT, currIndent);
        }
        return null;
    }

%}

/* Macros (regexes used in rules below) */

WhiteSpace = [ \t]
LineBreak  = \r|\n|\r\n


IntegerLiteral = 0|[1-9][0-9]* // Accroding to the manual, 00+ is illeagal
StringLiteral = ([^\"\\]|(\\\")|(\\t)|(\\r)|(\\n)|(\\\\))+ // \n, \r, \t, \\, \" and Anything except \ and " 
Identifiers = (_|[a-z]|[A-Z])(_|[a-z]|[A-Z]|[0-9])* 
Comments = #[^\r\n]*

%%

<YYINITIAL>{
  {WhiteSpace} { currIndent += yytext() == "\t" ? 8 : 1; }
  
  {LineBreak} { currIndent = 0; }
  {Comments} { /* ignored */ } 

  [^ \t\r\n#] {
    Symbol s = emitDent();
    if (s != null) return s;
  }
}


<AFTER> {

  /* Delimiters. */
  {LineBreak} { yybegin(YYINITIAL); currIndent = 0;indentErrorUnchecked = true; return symbol(ChocoPyTokens.NEWLINE);}
  ":" { return symbol(ChocoPyTokens.COLON); }
  "," { return symbol(ChocoPyTokens.COMMA); }

  /* Literals. */
  {IntegerLiteral} { return symbol(ChocoPyTokens.NUMBER,
                                                 Integer.parseInt(yytext())); }

  "\"" { yybegin(STR); str_l = yyline + 1; str_c = yycolumn + 1; currString = ""; } //Start taking a string when see a "
  "False" { return symbol(ChocoPyTokens.BOOL, false); }
  "True" { return symbol(ChocoPyTokens.BOOL, true); }
  "None" { return symbol(ChocoPyTokens.NONE); }

  /*Keywords*/
  "if" { return symbol(ChocoPyTokens.IF); }
  "else" { return symbol(ChocoPyTokens.ELSE); }
  "elif" { return symbol(ChocoPyTokens.ELIF); }
  "while" { return symbol(ChocoPyTokens.WHILE); }
  "class" { return symbol(ChocoPyTokens.CLASS); }
  "def" { return symbol(ChocoPyTokens.DEF); }
  "for" { return symbol(ChocoPyTokens.FOR); }
  "global" { return symbol(ChocoPyTokens.GLOBAL); }
  "in" { return symbol(ChocoPyTokens.IN); }
  "nonlocal" { return symbol(ChocoPyTokens.NONLOCAL); }
  "pass" { return symbol(ChocoPyTokens.PASS); }
  "return" { return symbol(ChocoPyTokens.RETURN); }


  /* Operators. */
  "+" { return symbol(ChocoPyTokens.PLUS); }
  "-" { return symbol(ChocoPyTokens.MINUS); }
  "*" { return symbol(ChocoPyTokens.MUL); }
  "//" { return symbol(ChocoPyTokens.DIV); }  
  "/" { return symbol(ChocoPyTokens.DIV); }  //Accroding to manual, chocopy don't have fp division, '/', '//' should be integr division
  "%" { return symbol(ChocoPyTokens.MOD); }  
  ">" { return symbol(ChocoPyTokens.GT); }
  "<" { return symbol(ChocoPyTokens.LT); }
  "==" { return symbol(ChocoPyTokens.EQUAL); }
  "!=" { return symbol(ChocoPyTokens.NEQ); }
  ">=" { return symbol(ChocoPyTokens.GEQ); }
  "<=" { return symbol(ChocoPyTokens.LEQ); }
  "=" { return symbol(ChocoPyTokens.ASSIGN); }
  "and" { return symbol(ChocoPyTokens.AND); }
  "or" { return symbol(ChocoPyTokens.OR); }
  "not" { return symbol(ChocoPyTokens.NOT); }
  "." { return symbol(ChocoPyTokens.DOT); }
  "(" { return symbol(ChocoPyTokens.LPAR); }
  ")" { return symbol(ChocoPyTokens.RPAR); }
  "[" { return symbol(ChocoPyTokens.LBR); }
  "]" { return symbol(ChocoPyTokens.RBR); }
  "->" { return symbol(ChocoPyTokens.ARROW); }
  "is" { return symbol(ChocoPyTokens.IS); }
  
 
  /*Identifiers*/
  {Identifiers}                  { return symbol(ChocoPyTokens.ID, yytext()); }
  
  /* Whitespace. */
  {WhiteSpace}                   { /* ignore */ }
  
  /* Comment. */
  {Comments}                     { /* ignore */ }
}
<STR>{
    {StringLiteral}              { currString += yytext(); }
    
    \\$                          { /*'\' at the end of line, do nothing.*/ }
    
    "\""                         { yybegin(AFTER); return symbolFactory.newSymbol(ChocoPyTokens.terminalNames[ChocoPyTokens.STRING], ChocoPyTokens.STRING,
                                   new ComplexSymbolFactory.Location(str_l, str_c),
                                   new ComplexSymbolFactory.Location(yyline + 1,yycolumn + yylength()),
                                   currString); } // accepted a ", return to AFTER state
}
<<EOF>>                          { if(!stack.isEmpty()){ return symbol(ChocoPyTokens.DEDENT, pop());} return symbol(ChocoPyTokens.EOF); }

/* Error fallback. */
[^]                              { return symbol(ChocoPyTokens.UNRECOGNIZED); }

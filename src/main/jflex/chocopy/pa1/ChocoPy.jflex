package chocopy.pa1;
import java_cup.runtime.*;

%%

/*** Do not change the flags below unless you know what you are doing. ***/

%unicode
%line
%column

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

    // Indentation handling
    private java.util.Stack<Integer> indentStack = new java.util.Stack<>();
    private boolean atStartOfLine = true;
    private int currentIndent = 0;
    
    {
        indentStack.push(0); // Initialize with 0 indentation
    }
    
    private Symbol handleIndentation() throws java.io.IOException {
        // Skip empty lines
        if (yytext().trim().isEmpty()) {
            atStartOfLine = true;
            return null;
        }
        
        // Count the current indentation
        String spaces = yytext();
        currentIndent = spaces.length();
        int prevIndent = indentStack.peek();
        
        if (currentIndent > prevIndent) {
            indentStack.push(currentIndent);
            return symbol(ChocoPyTokens.INDENT);
        } else if (currentIndent < prevIndent) {
            // Generate OUTDENT tokens until matching level
            indentStack.pop();
            yypushback(yylength()); // Put back the line for reprocessing
            return symbol(ChocoPyTokens.OUTDENT);
        } else {
            // Same indentation, no tokens needed
            return null;
        }
    }
%}

/* Macros (regexes used in rules below) */

WhiteSpace = [ \t]
LineBreak  = \r|\n|\r\n

IntegerLiteral = 0 | [1-9][0-9]*
StringLiteral = \"(\\.|[^\"\n])*\"
Comment = "#".*
Id = [a-zA-Z_][a-zA-Z0-9_]*

%%


<YYINITIAL> {

  /* Delimiters. */
  ^{WhiteSpace}+ {
      if (atStartOfLine) {
          Symbol s = handleIndentation();
          if (s != null) return s;
      }
      // Continue processing the rest of the line
      atStartOfLine = false;
  }
  
  ^{WhiteSpace}*{Comment}{LineBreak} {
      // Skip comment-only lines but maintain line tracking
      atStartOfLine = true;
  }
  
  {LineBreak} {
      atStartOfLine = true;
      return symbol(ChocoPyTokens.NEWLINE);
  }


  /* Literals. */
  {IntegerLiteral}            { return symbol(ChocoPyTokens.NUMBER, Integer.parseInt(yytext())); }
  {StringLiteral}             { return symbol(ChocoPyTokens.STRING, yytext().replaceAll("^\"|\"$", "")); }
  "True"                      { return symbol(ChocoPyTokens.BOOLEAN, true); }
  "False"                     { return symbol(ChocoPyTokens.BOOLEAN, false); }
  "None"                      { return symbol(ChocoPyTokens.NONE); }

  /* Keywords */
  "if"                      { return symbol(ChocoPyTokens.IF); }
  "elif"                      { return symbol(ChocoPyTokens.ELIF); }
  "else"                      { return symbol(ChocoPyTokens.ELSE); }

  /* Punctuation */
  "\["                         { return symbol(ChocoPyTokens.BRA); }
  "\]"                         { return symbol(ChocoPyTokens.KET); }
  "\("                         { return symbol(ChocoPyTokens.PAREN); }
  "\)"                         { return symbol(ChocoPyTokens.THESIS); }
  ","                          { return symbol(ChocoPyTokens.COMMA); }

  /* Operators. */
  "+"                         { return symbol(ChocoPyTokens.PLUS, yytext()); }
  "-"                         { return symbol(ChocoPyTokens.MINUS, yytext()); }
  "=="                         { return symbol(ChocoPyTokens.EQ, yytext()); }
  "!="                         { return symbol(ChocoPyTokens.NEQ, yytext()); }
  ">"                          { return symbol(ChocoPyTokens.GT, yytext()); }
  "<"                          { return symbol(ChocoPyTokens.LT, yytext()); }
  ">="                         { return symbol(ChocoPyTokens.EGT, yytext()); }
  "<="                         { return symbol(ChocoPyTokens.ELT, yytext()); }
  "is"                      { return symbol(ChocoPyTokens.IS, yytext()); }

  {Id}                        { return symbol(ChocoPyTokens.ID, yytext()); }

  /* Whitespace. */
  {WhiteSpace}                { /* ignore */ }
}

<<EOF>>                       { return symbol(ChocoPyTokens.EOF); }

/* Error fallback. */
[^]                           { return symbol(ChocoPyTokens.UNRECOGNIZED); }

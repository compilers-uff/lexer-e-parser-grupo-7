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
        // System.out.printf("<%d, '%s', '%s'> ", type, value.toString().replace("\n", "\\n").replace("\t", "\\t"), ChocoPyTokens.terminalNames[type]);
        return symbolFactory.newSymbol(ChocoPyTokens.terminalNames[type], type,
            new ComplexSymbolFactory.Location(yyline + 1, yycolumn + 1),
            new ComplexSymbolFactory.Location(yyline + 1,yycolumn + yylength()),
            value);
    }

    // Indentation handling
    private java.util.Queue<Symbol> pendingTokens = new java.util.LinkedList<>();
    private java.util.Stack<Integer> indentStack = new java.util.Stack<>();
    private boolean atStartOfLine = true;

    
    private Symbol pending() {
        if (pendingTokens.isEmpty())
            return null;
        yypushback(yylength());
        return pendingTokens.poll();
    }

    private Symbol check_pendings(Symbol s){
        Symbol p = pending();
        if (p != null) {
            // System.out.println(p);
            return p;
        }
        // System.out.println(s);
        return s;
    }

    private void handleIndentation() throws java.io.IOException {
        // System.out.print("<handling> ");

        int currIndent = yytext().length();

        if (indentStack.isEmpty() || indentStack.peek() < currIndent){
            indentStack.push(currIndent);
            // System.out.print("<queued ");
            pendingTokens.add(symbol(ChocoPyTokens.INDENT));
            // System.out.print("> ");
            return;
        }

        if (indentStack.peek() == currIndent) {
            return;
        }

        while (
            !indentStack.isEmpty() &&
            indentStack.peek() > currIndent
        ) {
            indentStack.pop();
            // System.out.print("<queued ");
            pendingTokens.add(symbol(ChocoPyTokens.OUTDENT));
            // System.out.print("> ");
        }
    }

    private void NLIndentation() {
        pendingTokens.add(symbol(ChocoPyTokens.NEWLINE));
        // System.out.print("<nl handling> ");
        int currIndent = yytext().replace("\n", "").length();

        // Same indentation
        if (
            (indentStack.isEmpty() && currIndent == 0)
            || (
                !indentStack.isEmpty()
                && indentStack.peek() == currIndent
            )
        ) {
            return;
        }

        // More identation
        if (
            (indentStack.isEmpty() && currIndent > 0)
            || (
                !indentStack.isEmpty()
                && indentStack.peek() < currIndent
            )
        ){
            indentStack.push(currIndent);
            // System.out.print("<queued ");
            pendingTokens.add(symbol(ChocoPyTokens.INDENT));
            // System.out.print("> ");
            return;
        }

        // Less Indentation
        while (
            !indentStack.isEmpty() &&
            indentStack.peek() > currIndent
        ) {
            indentStack.pop();
            // System.out.print("<queued ");
            pendingTokens.add(symbol(ChocoPyTokens.OUTDENT));
            // System.out.print("> ");
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
      // System.out.println("Checking");
      if (atStartOfLine) {
          handleIndentation();
      // System.out.println("Checking nl ws");
      }
      // Continue processing the rest of the line
      atStartOfLine = false;
  }
  
  /*
  ^{WhiteSpace}*{Comment}*{LineBreak} {
      // Skip comment-only lines but maintain line tracking
      atStartOfLine = true;
  }
  */
  
  {LineBreak}{WhiteSpace}*{LineBreak} {
    // System.out.println("Checking nl ws nl");
    yypushback(1);
    return symbol(ChocoPyTokens.NEWLINE);
  }

  {LineBreak}{WhiteSpace}* {
      // System.out.println("Checking nl ws");
      atStartOfLine = false;
      NLIndentation();

  }

  /*
  {LineBreak} {
      // System.out.println("Checking nl");
      atStartOfLine = true;
      return check_pendings(symbol(ChocoPyTokens.NEWLINE));
  }
  */

  /* Literals. */
  {IntegerLiteral}            { return check_pendings(symbol(ChocoPyTokens.NUMBER, Integer.parseInt(yytext()))); }
  {StringLiteral}             { return check_pendings(symbol(ChocoPyTokens.STRING, yytext().replaceAll("^\"|\"$", ""))); }
  "True"                      { return check_pendings(symbol(ChocoPyTokens.BOOLEAN, true)); }
  "False"                     { return check_pendings(symbol(ChocoPyTokens.BOOLEAN, false)); }
  "None"                      { return check_pendings(symbol(ChocoPyTokens.NONE)); }

  /* Keywords */
  "if"                      { return check_pendings(symbol(ChocoPyTokens.IF)); }
  "elif"                      { return check_pendings(symbol(ChocoPyTokens.ELIF)); }
  "else"                      { return check_pendings(symbol(ChocoPyTokens.ELSE)); }

  /* Punctuation */
  "("                          { return check_pendings(symbol(ChocoPyTokens.LPAR)); }
  ")"                          { return check_pendings(symbol(ChocoPyTokens.RPAR)); }
  "["                          { return check_pendings(symbol(ChocoPyTokens.LBR)); }
  "]"                          { return check_pendings(symbol(ChocoPyTokens.RBR)); }
  ","                          { return check_pendings(symbol(ChocoPyTokens.COMMA)); }
  ":"                          { return check_pendings(symbol(ChocoPyTokens.COLON)); }
  "="                          { return check_pendings(symbol(ChocoPyTokens.ASSIGN)); }
  "."                          { return check_pendings(symbol(ChocoPyTokens.DOT)); }

  /* Operators. */
  "+"                         { return check_pendings(symbol(ChocoPyTokens.PLUS, yytext())); }
  "-"                         { return check_pendings(symbol(ChocoPyTokens.MINUS, yytext())); }
  "*"                         { return check_pendings(symbol(ChocoPyTokens.MUL, yytext())); }
  "/"                         { return check_pendings(symbol(ChocoPyTokens.DIV, yytext())); }
  "%"                         { return check_pendings(symbol(ChocoPyTokens.MOD, yytext())); }
  "=="                         { return check_pendings(symbol(ChocoPyTokens.EQ, yytext())); }
  "!="                         { return check_pendings(symbol(ChocoPyTokens.NEQ, yytext())); }
  ">"                          { return check_pendings(symbol(ChocoPyTokens.GT, yytext())); }
  "<"                          { return check_pendings(symbol(ChocoPyTokens.LT, yytext())); }
  ">="                         { return check_pendings(symbol(ChocoPyTokens.EGT, yytext())); }
  "<="                         { return check_pendings(symbol(ChocoPyTokens.ELT, yytext())); }
  "is"                      { return check_pendings(symbol(ChocoPyTokens.IS, yytext())); }

  {Id}                        { return check_pendings(symbol(ChocoPyTokens.ID, yytext())); }

  /* Whitespace. */
  {WhiteSpace}                { /* ignore */ }
}

<<EOF>>                       {
    while (!indentStack.isEmpty()) {
        indentStack.pop();
        pendingTokens.add(symbol(ChocoPyTokens.OUTDENT));
    }
    return check_pendings(symbol(ChocoPyTokens.EOF));
}

/* Error fallback. */
[^]                           { return check_pendings(symbol(ChocoPyTokens.UNRECOGNIZED)); }

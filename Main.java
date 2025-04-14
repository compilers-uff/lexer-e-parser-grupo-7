package chocopy.main;

import chocopy.lexer.ChocoPyLexer;
import chocopy.parser.sym;
import java_cup.runtime.Symbol;
import java.io.FileReader;
import java.io.IOException;

public class Main {
    public static void main(String[] args) {
        if (args.length != 1) {
            System.err.println("Usage: java chocopy.main.Main <source_file>");
            System.exit(1);
        }
        
        String filename = args[0];
        try (FileReader reader = new FileReader(filename)) {
            ChocoPyLexer lexer = new ChocoPyLexer(reader);
            Symbol token;
            while ((token = lexer.next_token()).sym != sym.EOF) {
                System.out.println("Token: " + token);
            }
        } catch (IOException e) {
            System.err.println("Error reading file: " + filename);
            e.printStackTrace();
        }
    }
}

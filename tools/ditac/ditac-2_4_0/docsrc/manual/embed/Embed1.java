import java.io.File;

import java.net.MalformedURLException;
import java.net.URL;

import com.xmlmind.util.Console;

import com.xmlmind.ditac.convert.StyleSheetCache;
import com.xmlmind.ditac.convert.Converter;

public class Embed1 {
    private static int convert(File inFile, File outFile) {
        StyleSheetCache cache = new StyleSheetCache();

        Console console = new Console() {
            public void showMessage(String message, MessageType messageType) {
                System.err.println(message);
            }
        };

        Converter converter = new Converter(cache, console);

        if (!converter.registerFOP(path("/opt/fop/fop"))) {
            return 1;
        }

        File xslDir = new File(path("../../../xsl"));
        System.setProperty("DITAC_XSL_DIR", xslDir.getAbsolutePath());

        String[] args = {
            "-v",
            "-p", "number", "all",
            outFile.getPath(),
            inFile.getPath(),
        };

        return converter.run(args);
    }

    private static String path(String p) {
        if (File.separatorChar != '/') {
            p = p.replace('/', File.separatorChar);
        }
        return p;
    }

    public static void main(String[] args) {
        File inFile = null;
        if (args.length != 2 ||
            !(inFile = new File(args[0])).isFile()) {
            System.err.println("usage: java Embed1 in_dita_file out_pdf_file");
            System.exit(1);
        }

        File outFile = new File(args[1]);

        int code = convert(inFile, outFile);
        System.exit(code);
    }
}

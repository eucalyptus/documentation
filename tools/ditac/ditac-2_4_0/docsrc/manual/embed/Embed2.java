import java.io.IOException;
import java.io.File;

import java.net.MalformedURLException;
import java.net.URL;

import javax.xml.transform.stream.StreamSource;
import javax.xml.transform.stream.StreamResult;

import javax.xml.transform.URIResolver;
import javax.xml.transform.ErrorListener;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;

import com.xmlmind.util.FileUtil;
import com.xmlmind.util.Console;

import com.xmlmind.ditac.util.Resolve;

import com.xmlmind.ditac.preprocess.Media;
import com.xmlmind.ditac.preprocess.Chunking;
import com.xmlmind.ditac.preprocess.PreProcessor;

import com.xmlmind.ditac.convert.ConsoleErrorListener;
import com.xmlmind.ditac.convert.ResourceCopier;

import com.xmlmind.ditac.xslt.ExtensionFunctions;

public class Embed2 {
    private static boolean convert(File inFile, File outFile) {
        // Create and configure preprocessor ---

        Console console = new Console() {
            public void showMessage(String message, MessageType messageType) {
                System.err.println(message);
            }
        };

        PreProcessor preProc = new PreProcessor(console);
        preProc.setChunking(Chunking.SINGLE);
        preProc.setMedia(Media.SCREEN);

        ResourceCopier resourceCopier = new ResourceCopier();
        resourceCopier.parseParameters("img");
        preProc.setResourceHandler(resourceCopier);

        // Preprocess ---

        URL inFileURL = null;
        try {
            inFileURL = inFile.toURI().toURL();
        } catch (MalformedURLException cannotHappen) {}

        File[] preProcFiles = null;
        try {
            preProcFiles = preProc.process(new URL[] { inFileURL }, outFile);
        } catch (IOException e) {
            console.showMessage(e.toString(), Console.MessageType.ERROR);
        }
        if (preProcFiles == null) {
            return false;
        }

        // Transform ---
        // Do not forget to pass required system parameters: 
        // "ditacListsURI" (always required)
        // "foProcessor" (for the XSLT stylesheets that generate XSL-FO)
        // "chmBasename", "hhpBasename" (for the XSLT stylesheets that 
        // generate HTML Help)

        String ditacListsURI = "";

        int count = preProcFiles.length;
        for (int i = 0; i < count; ++i) {
            File ditacFile = preProcFiles[i];

            if (ditacFile.getPath().endsWith(".ditac_lists")) {
                ditacListsURI = ditacFile.toURI().toASCIIString();
                break;
            }
        }

        String[] params = {
            "ditacListsURI", ditacListsURI,
            "xsl-resources-directory", "res",
            "use-note-icon", "yes",
            "default-table-width", "100%"
        };

        Transformer transformer;
        try {
            transformer = createTransformer(params, console);
        } catch (Exception e) {
            console.showMessage(e.toString(), Console.MessageType.ERROR);
            cleanUp(preProcFiles);
            return false;
        }

        for (int i = 0; i < count; ++i) {
            File ditacFile = preProcFiles[i];

            String ditacFilePath = ditacFile.getPath();
            if (ditacFilePath.endsWith(".ditac")) {
                File transformedFile = new File(
                    ditacFilePath.substring(0, ditacFilePath.length()-5) + 
                    "html");

                try {
                    transformer.transform(new StreamSource(ditacFile), 
                                          new StreamResult(transformedFile));
                } catch (Exception e) {
                    console.showMessage(e.toString(), 
                                        Console.MessageType.ERROR);
                    cleanUp(preProcFiles);
                    return false;
                }
            }
        }

        // Copy the resources of the XSLT stylesheets to "res/" ---
        // (Images referenced in the DITA source have already been 
        // copied to "img/" by the ResourceCopier.)

        File dstDir = new File("res");
        if (!dstDir.exists()) {
            File srcDir = new File(path("../../../xsl/xhtml/resources"));
            try {
                FileUtil.copyDir(srcDir, dstDir, false);
            } catch (IOException e) {
                console.showMessage(e.toString(), Console.MessageType.ERROR);
                cleanUp(preProcFiles);
                return false;
            }
        }

        // Clean-up ---

        cleanUp(preProcFiles);
        return true;
    }

    private static Transformer createTransformer(String[] params, 
                                                 Console console) 
        throws Exception {
        URIResolver uriResolver = Resolve.createURIResolver();
        ErrorListener errorListener = new ConsoleErrorListener(console);

        TransformerFactory factory = createTransformerFactory(uriResolver,
                                                              errorListener);

        File xslFile = new File(path("../../../xsl/xhtml/html.xsl"));
        Transformer transformer = 
            factory.newTransformer(new StreamSource(xslFile));

        // For use by document().
        transformer.setURIResolver(uriResolver);

        transformer.setErrorListener(errorListener);

        for (int i = 0; i < params.length; i += 2) {
            transformer.setParameter(params[i], params[i+1]);
        }

        return transformer;
    }

    private static
    TransformerFactory createTransformerFactory(URIResolver uriResolver, 
                                                ErrorListener errorListener) 
        throws Exception {
        // Force the use of Saxon 9.
        Class<?> cls = Class.forName("net.sf.saxon.TransformerFactoryImpl");
        TransformerFactory transformerFactory = 
            (TransformerFactory) cls.newInstance();

        // First extend, then configure.
        // Otherwise the resolver and error listener are forgotten (???).

        ExtensionFunctions.registerAll(transformerFactory);

        // For use by xsl:import and xsl:include.
        transformerFactory.setURIResolver(uriResolver);

        transformerFactory.setErrorListener(errorListener);

        return transformerFactory;
    }

    private static void cleanUp(File[] files) {
        if (files != null) {
            for (int i = 0; i < files.length; ++i) {
                File file = files[i];
                if (file.exists()) {
                    file.delete();
                }
            }
        }
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
           System.err.println("usage: java Embed2 in_dita_file out_html_file");
           System.exit(1);
        }

        File outFile = new File(args[1]);

        if (!convert(inFile, outFile)) {
            System.exit(2);
        }
    }
}

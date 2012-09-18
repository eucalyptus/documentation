/*
 * Copyright (c) 2009-2012 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.convert;

import java.io.IOException;
import java.io.File;
import java.io.OutputStream;
import java.io.FileOutputStream;
import java.io.BufferedOutputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.zip.ZipOutputStream;
import org.xml.sax.InputSource;
import org.xml.sax.EntityResolver;
import org.xml.sax.XMLReader;
import javax.xml.transform.URIResolver;
import javax.xml.transform.ErrorListener;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.sax.SAXSource;
import javax.xml.transform.stream.StreamSource;
import javax.xml.transform.stream.StreamResult;
import com.xmlmind.util.ThrowableUtil;
import com.xmlmind.util.SystemUtil;
import com.xmlmind.util.ArrayUtil;
import com.xmlmind.util.StringList;
import com.xmlmind.util.StringUtil;
import com.xmlmind.util.FileUtil;
import com.xmlmind.util.URLUtil;
import com.xmlmind.util.XMLUtil;
import com.xmlmind.util.Console;
import com.xmlmind.util.Zip;
import com.xmlmind.whc.Compiler;
import com.xmlmind.ditac.util.AppUtil;
import com.xmlmind.ditac.util.Resolve;
import com.xmlmind.ditac.util.SimpleConsole;
import com.xmlmind.ditac.util.ConsoleHelper;
import com.xmlmind.ditac.preprocess.Chunking;
import com.xmlmind.ditac.preprocess.ImageHandler;
import com.xmlmind.ditac.preprocess.Filter;
import com.xmlmind.ditac.preprocess.PreProcessor;

/**
 * Implementation of the <tt>ditac</tt> command-line utility.
 *
 * <p>This class has been designed  in order to be easily embedded 
 * in any Java desktop or server-side application. Using this class involves:
 * <ol>
 * <li>Creating an instance using the 
 * {@link #Converter(StyleSheetCache, Console)} Constructor.
 * <li>Registering one or more XSL-FO processors with the newly created 
 * instance using {@link #registerXEP}, {@link #registerFOP}, 
 * {@link #registerAHF}, {@link #registerXFC}, 
 * {@link #registerExternalFOConverter} or {@link #registerFOConverter}.
 * <li>Invoking {@link #run} passing it an array of string arguments.
 * These arguments are of course identical to those of the <tt>ditac</tt> 
 * command-line utility. These arguments are documented in 
 * <i>XMLmind DITA Converter Manual</i>.
 * </ol>
 * 
 * <p><b>Note:</b> This class is not thread-safe. Each thread must use 
 * its own instance. However the same instance may be run several times.
 */
public class Converter {
    private StyleSheetCache styleSheetCache;
    private ConsoleHelper console;
    private ArrayList<FOConverter> foConverters;
    private File jhindexerExe;
    private File hhcExe;
    private URL whcTemplateManifestURL;

    private PreProcessor preProc;
    private String defaultLang;
    private boolean preprocess;
    private boolean dryRun;
    private Format format;
    private String pluginName;
    private URL styleSheetURL;
    private String[] styleSheetParams;
    private File outFile;
    private URL[] inFiles;
    private boolean keepFO;
    private boolean addIndex;

    private File preProcTempDir;

    private static final String FRONT_BACK_MATTER_SPEC =
        "spec -> same_page [ ',' same_page ]*\n" +
        "same_page -> section [ '+' section ]*\n" +
        "section -> toc|figurelist|tablelist|examplelist|indexlist";

    // -----------------------------------------------------------------------

    /**
     * Equivalent to {@link #Converter Converter(null, null)}.
     */
    public Converter() {
        this(null, null);
    }

    /**
     * Constructs a Converter using specified XSL stylesheet cache and 
     * specified console to display its progress, warning, error, etc, 
     * messages.
     *
     * @param cache the XSL stylesheet cache. May be <code>null</code>.
     * @param c the console. May be <code>null</code>.
     * @see #setStyleSheetCache
     * @see #setConsole
     */
    public Converter(StyleSheetCache cache, Console c) {
        setStyleSheetCache(cache);
        setConsole(c);
    }

    /**
     * Specifies the XSL stylesheet cache used by this converter.
     * 
     * @param cache the XSL stylesheet cache; may be <code>null</code>, 
     * in which case a new {link StyleSheetCache} is automatically created
     *
     * @see #getStyleSheetCache
     */
    public void setStyleSheetCache(StyleSheetCache cache) {
        if (cache == null) {
            cache = new StyleSheetCache();
        }
        styleSheetCache = cache;
    }

    /**
     * Returns the XSL stylesheet cache used by this converter.
     * 
     * @see #setStyleSheetCache
     */
    public StyleSheetCache getStyleSheetCache() {
        return styleSheetCache;
    }

    /**
     * Specifies the console on which messages issued during conversion
     * are to be displayed. 
     * 
     * @param c the console; may be <code>null</code>, in which case messages
     * are displayed on <code>System.err</code> and <code>System.out</code>
     *
     * @see #getConsole
     */
    public void setConsole(Console c) {
        if (c == null) {
            c = new SimpleConsole("ditac: ", true, Console.MessageType.INFO);
        }
        this.console = ((c instanceof ConsoleHelper)? 
                        (ConsoleHelper) c : new ConsoleHelper(c));
    }

    /**
     * Returns the console on which messages issued during conversion
     * are to be displayed.
     * 
     * @see #setConsole
     */
    public ConsoleHelper getConsole() {
        return console;
    }

    /**
     * Registers specified XSL-FO processor with this converter.
     * 
     * @see #registerExternalFOConverter
     */
    public void registerFOConverter(FOConverter foConverter) {
        if (foConverters == null) {
            foConverters = new ArrayList<FOConverter>();
        } else {
            String n = foConverter.getProcessorName();
            Format f = foConverter.getTargetFormat();

            for (int i = foConverters.size()-1; i >= 0; --i) {
                FOConverter fc = foConverters.get(i);

                // The name of the XSL-FO processor is case-sensitive.
                if (fc.getProcessorName().equals(n) && 
                    fc.getTargetFormat() == f) {
                    foConverters.remove(i);
                    break;
                }
            }
        }

        foConverters.add(foConverter);
    }

    /**
     * Convenience method: registers RenderX XEP with this converter.
     *
     * @param exeFileName the full path of the <tt>xep</tt> executable 
     * (<tt>xep.bat</tt> on Windows)
     *
     * @see #registerExternalFOConverter
     */
    public boolean registerXEP(String exeFileName) {
        File exeFile = toExeFile(exeFileName);
        if (exeFile == null) {
            return false;
        }

        StringBuilder buffer = new StringBuilder();
        buffer.append('"');
        buffer.append(exeFile);
        buffer.append("\" -quiet -fo \"%I\" -ps \"%O\"");

        registerExternalFOConverter("XEP", Format.PS, buffer.toString());

        buffer = new StringBuilder();
        buffer.append('"');
        buffer.append(exeFile);
        buffer.append("\" -quiet -fo \"%I\" -pdf \"%O\"");

        registerExternalFOConverter("XEP", Format.PDF, buffer.toString());
        return true;
    }

    /**
     * Convenience method: registers Apache FOP with this converter.
     *
     * @param exeFileName the full path of the <tt>fop</tt> executable 
     * (<tt>fop.bat</tt> on Windows)
     *
     * @see #registerExternalFOConverter
     */
    public boolean registerFOP(String exeFileName) {
        File exeFile = toExeFile(exeFileName);
        if (exeFile == null) {
            return false;
        }

        StringBuilder buffer = new StringBuilder();
        buffer.append('"');
        buffer.append(exeFile);
        buffer.append("\" -q -r -fo \"%I\" -ps \"%O\"");

        registerExternalFOConverter("FOP", Format.PS, buffer.toString());

        buffer = new StringBuilder();
        buffer.append('"');
        buffer.append(exeFile);
        buffer.append("\" -q -r -fo \"%I\" -pdf \"%O\"");

        registerExternalFOConverter("FOP", Format.PDF, buffer.toString());
        return true;
    }

    /**
     * Convenience method: registers Antenna House Formatter with this
     * converter.
     *
     * @param exeFileName the full path of the <tt>AHFCmd</tt> executable
     * (<tt>run.sh</tt> on platforms other than Windows).
     *
     * @see #registerExternalFOConverter
     */
    public boolean registerAHF(String exeFileName) {
        File exeFile = toExeFile(exeFileName);
        if (exeFile == null) {
            return false;
        }

        StringBuilder buffer = new StringBuilder();
        buffer.append('"');
        buffer.append(exeFile);
        buffer.append("\" -x 3 -p @PS -d \"%I\" -o \"%O\"");

        registerExternalFOConverter("AHF", Format.PS, buffer.toString());

        buffer = new StringBuilder();
        buffer.append('"');
        buffer.append(exeFile);
        buffer.append("\" -x 3 -p @PDF -d \"%I\" -o \"%O\"");

        registerExternalFOConverter("AHF", Format.PDF, buffer.toString());
        return true;
    }

    /**
     * Convenience method: registers XMLmind XSL-FO Converter
     * with this converter.
     *
     * @param exeFileName the full path of the <tt>fo2rtf</tt> 
     * (or <tt>fo2wml</tt> or <tt>fo2docx</tt> or <tt>fo2odt</tt>: 
     * it does not matter provided that all these scripts are found 
     * in the same directory) executable (<tt>fo2rtf.bat</tt> on Windows)
     *
     * @see #registerExternalFOConverter
     */
    public boolean registerXFC(String exeFileName) {
        File exeFile = toExeFile(exeFileName);
        if (exeFile == null) {
            return false;
        }
        File exeDir = exeFile.getParentFile();

        StringBuilder buffer;
        boolean done = false;

        exeFile = newExeFile(exeDir, "fo2rtf");
        if (exeFile != null) {
            buffer = new StringBuilder();
            buffer.append('"');
            buffer.append(exeFile);
            buffer.append("\" \"%I\" \"%O\"");

            registerExternalFOConverter("XFC", Format.RTF, buffer.toString());
            done = true;
        }

        exeFile = newExeFile(exeDir, "fo2wml");
        if (exeFile != null) {
            buffer = new StringBuilder();
            buffer.append('"');
            buffer.append(exeFile);
            buffer.append("\" \"%I\" \"%O\"");

            registerExternalFOConverter("XFC", Format.WML, buffer.toString());
            done = true;
        }

        exeFile = newExeFile(exeDir, "fo2docx");
        if (exeFile != null) {
            buffer = new StringBuilder();
            buffer.append('"');
            buffer.append(exeFile);
            buffer.append("\" \"%I\" \"%O\"");

            registerExternalFOConverter("XFC", Format.DOCX, buffer.toString());
            done = true;
        }

        exeFile = newExeFile(exeDir, "fo2odt");
        if (exeFile != null) {
            buffer = new StringBuilder();
            buffer.append('"');
            buffer.append(exeFile);
            buffer.append("\" \"%I\" \"%O\"");

            registerExternalFOConverter("XFC", Format.ODT, buffer.toString());
            done = true;
        }

        return done;
    }

    private static File newExeFile(File exeDir, String rootName) {
        String baseName = rootName;
        if (SystemUtil.IS_WINDOWS) {
            baseName += ".bat";
        }
        return toExeFile(new File(exeDir, baseName).getPath());
    }

    private static File toExeFile(String exeFileName) {
        try {
            File exeFile = (new File(exeFileName)).getCanonicalFile();
            if (exeFile.isFile()) {
                return exeFile;
            }
        } catch (IOException ignored) {}
        return null;
    }

    /**
     * Registers specified {@link ExternalFOConverter} with this converter.
     *
     * @param foProcName the name of the XSL-FO processor
     * @param targetFormat the format generated by the XSL-FO processor
     * @param command command to be executed to convert 
     * the XSL-FO input file to the output format
     *
     * @see #registerFOConverter
     */
    public void registerExternalFOConverter(String foProcName, 
                                            Format targetFormat,
                                            String command) {
        ExternalFOConverter foConverter =
            new ExternalFOConverter(foProcName, targetFormat, command);

        console.debug(Msg.msg("registeringExternalFOConverter", foConverter));

        registerFOConverter(foConverter);
    }

    /**
     * Returns the XSL-FO processor handling specified output format. 
     * Returns <code>null</code> if there is no such processor.
     * <p>Returns XSL-FO processor <em>last registered</em> for a given format.
     */
    public FOConverter getFOConverter(Format format) {
        if (foConverters != null) {
            // Use last registered.
            for (int i = foConverters.size()-1; i >= 0; --i) {
                FOConverter fc = foConverters.get(i);

                if (fc.getTargetFormat() == format) {
                    return fc;
                }
            }
        }
        return null;
    }

    /**
     * Specify the location of the <tt>whc_template/file.list</tt> file. 
     * 
     * @param url the location of the <tt>whc_template/file.list</tt> file.
     * <p>Specify <code>null</code> to reset it to its default location 
     * which dynamically determined as follows: 
     * <tt><i>location_of_whcmin.jar</i>/../whc_template/file.list</tt>
     * @see #getWHCTemplateManifest
     */
    public void setWHCTemplateManifest(URL url) {
        whcTemplateManifestURL = url;
    }

    /**
     * Returns the location of the <tt>whc_template/file.list</tt> file. 
     * May return <code>null</code>.
     *
     * @see #setWHCTemplateManifest
     */
    public URL getWHCTemplateManifest() {
        return whcTemplateManifestURL;
    }

    /**
     * Specify the location of the <tt>jhindexer</tt> executable. 
     * <p><tt>Jhindexer</tt> creates a full-text search database used 
     * by the JavaHelp system full-text search engine to locate matches.
     *
     * @param exe the filename of the <tt>jhindexer</tt> executable, 
     * a script shell on Unix and a <tt>.bat</tt> file on Windows
     * @see #getJhindexerExe
     */
    public void setJhindexerExe(File exe) {
        jhindexerExe = exe;
    }

    /**
     * Returns the location of the <tt>jhindexer</tt> executable.
     * May return <code>null</code>.
     * 
     * @see #setJhindexerExe
     */
    public File getJhindexerExe() {
        return jhindexerExe;
    }

    /**
     * Specify the location of <tt>hhc.exe</tt>. 
     * <p><tt>Hhc.exe</tt> is the HTML help compiler. 
     * It creates <tt>.chm</tt> files.
     *
     * @param exe the filename of <tt>hhc.exe</tt>
     * @see #getHhcExe
     */
    public void setHhcExe(File exe) {
        hhcExe = exe;
    }

    /**
     * Returns the location of <tt>hhc.exe</tt>.
     * May return <code>null</code>.
     * 
     * @see #setHhcExe
     */
    public File getHhcExe() {
        return hhcExe;
    }

    /**
     * Executes the conversion specified in array of arguments <tt>args</tt>.
     *
     * @param args same arguments as those supported by 
     * the <tt>ditac</tt> command-line utility. 
     * These arguments are documented in <i>XMLmind DITA Converter Manual</i>.
     * @return 0 if the conversion is successful;
     * a value different from 0 otherwise. In the latter case, 
     * error messages are displayed on the {@link #setConsole console}.
     */
    public int run(String[] args) {
        preProc = new PreProcessor(console);

        if (!parseOptions(args)) {
            return 1;
        }
        defaultLang = preProc.getLang();

        outFile = outFile.getAbsoluteFile();
        File outDir = outFile.getParentFile();
        if (!outDir.isDirectory()) {
            console.info(Msg.msg("creatingOutputDir", outDir));

            try {
                FileUtil.checkedMkdirs(outDir);
            } catch (IOException e) {
                console.error(ThrowableUtil.reason(e));
                return 2;
            }
        }

        String outExtension = FileUtil.getExtension(outFile);
        if (outExtension != null && 
            (outExtension = outExtension.trim()).length() == 0) {
            outExtension = null;
        }

        switch (format) {
        case JAVA_HELP:
        case HTML_HELP:
        case EPUB:
            if (outFile.getName().startsWith("_.")) {
                String baseName = URLUtil.getBaseName(inFiles[0]);
                baseName = FileUtil.setExtension(baseName, outExtension);
                outFile = new File(outDir, baseName);
            }
            break;
        }

        File[] tocPreProcFile = new File[1];
        File[] preProcFiles = preProcess(inFiles, outFile, tocPreProcFile);
        if (preProcFiles == null) {
            // Error messages displayed on the console.
            return 3;
        }

        //showMemoryUsage();
        preProc = null; // Help GC.
        if (preprocess || dryRun) {
            // Done.
            return 0;
        }

        if (outExtension != null && 
            ("ditac".equalsIgnoreCase(outExtension) || 
             "ditac_lists".equalsIgnoreCase(outExtension))) {
            console.error(Msg.msg("reservedExtension", outExtension));
            cleanUp(preProcFiles);
            return 4;
        }

        if (!convert(preProcFiles, outExtension)) {
            cleanUp(preProcFiles);
            return 5;
        }

        if (addIndex && 
            tocPreProcFile[0] != null &&
            !addIndex(tocPreProcFile[0], preProcFiles, outExtension)) {
            cleanUp(preProcFiles);
            return 6;
        }

        if (!cleanUp(preProcFiles)) {
            return 7;
        }

        return 0;
    }

    private File[] preProcess(URL[] inFiles, File outFile, File[] tocFile) {
        File[] preProcFiles = null;

        try {
            if (dryRun) {
                preProcFiles = preProc.process(inFiles, outFile, null);
            } else {
                switch (format) {
                case JAVA_HELP:
                    preProcFiles = preProcessJavaHelp(inFiles, outFile);
                    break;
                case HTML_HELP:
                    preProcFiles = preProcessHTMLHelp(inFiles, outFile);
                    break;
                case EPUB:
                    preProcFiles = preProcessEPUB(inFiles, outFile);
                    break;
                case XHTML:
                case XHTML1_1:
                case HTML:
                case WEB_HELP:
                    preProcFiles = preProc.process(inFiles, outFile, tocFile);
                    break;
                default:
                    preProcFiles = preProc.process(inFiles, outFile, null);
                }
            }
        } catch (IOException e) {
            console.error(ThrowableUtil.reason(e));
        }

        return preProcFiles;
    }

    private boolean addIndex(File tocPreProcFile, File[] preProcFiles, 
                             String outExtension) {
        switch (format) {
        case XHTML:
        case XHTML1_1:
        case HTML:
        case WEB_HELP:
            break;
        default:
            // Not relevant.
            return true;
        }

        boolean add = true;
        for (File preProcFile : preProcFiles) {
            if ("index.ditac".equals(preProcFile.getName())) {
                // Already exists. Nothing to do.
                return true;
            }
        }

        File tocFile = FileUtil.setExtension(tocPreProcFile, outExtension);
        File indexFile = new File(tocPreProcFile.getParentFile(), 
                                  "index." + outExtension);

        boolean added = true;
        try {
            FileUtil.copyFile(tocFile, indexFile, /*sameDate*/ false, 
                              console.isVerbose()? console.console : null);
        } catch (IOException e) {
            console.error(ThrowableUtil.reason(e));
            added = false;
        }

        return added;
    }

    private boolean cleanUp(File[] preProcFiles) {
        if (preProcTempDir != null) {
            // If preProcTempDir exists, it contains all preProcFiles.
            return deleteFileOrDir(preProcTempDir);
        } else {
            return deleteFilesOrDirs(preProcFiles);
        }
    }

    private boolean deleteFileOrDir(File file) {
        return deleteFilesOrDirs(new File[] { file });
    }

    private boolean deleteFilesOrDirs(File[] files) {
        boolean done = true;
        for (int i = 0; i < files.length; ++i) {
            File file = files[i];

            if (file.exists()) {
                try {
                    console.debug(Msg.msg("deletingFileOrDir", file));

                    FileUtil.deleteFileOrDir(file);
                } catch (IOException e) {
                    console.error(ThrowableUtil.reason(e));
                    done = false;
                }
            }
        }
        return done;
    }

    private void showMemoryUsage() {
        if (console.isShowing(Console.MessageType.DEBUG)) {
            Runtime runtime = Runtime.getRuntime();
            runtime.gc();
            runtime.runFinalization();
            runtime.gc();
            long totalMemory = runtime.totalMemory();
            long usedMemory = totalMemory - runtime.freeMemory();
            long maxMemory = runtime.maxMemory();

            console.debug(Msg.msg("memoryUsage", new Long(usedMemory/1048576),
                                  new Long(totalMemory/1048576),
                                  new Long(maxMemory/1048576)));
        }
    }

    // -----------------------------------------------------------------------
    // Convert preprocessed files
    // -----------------------------------------------------------------------
    
    private boolean convert(File[] preProcFiles, String outExtension) {
        switch (format) {
        case XHTML:
        case XHTML1_1:
        case HTML:
            return convertToHTMLForm(preProcFiles, outExtension);
        case JAVA_HELP:
            return convertToJavaHelp(preProcFiles, outExtension);
        case HTML_HELP:
            return convertToHTMLHelp(preProcFiles, outExtension);
        case ECLIPSE_HELP:
            return convertToEclipseHelp(preProcFiles, outExtension);
        case WEB_HELP:
            return convertToWebHelp(preProcFiles, outExtension);
        case EPUB:
            return convertToEPUB(preProcFiles, outExtension);
        default:
            return convertToPrintForm(preProcFiles, outExtension);
        }
    }

    // ------------------------------------
    // convertToHTMLForm
    // ------------------------------------

    private boolean convertToHTMLForm(File[] preProcFiles, 
                                      String outExtension) {
        String styleSheetPath;
        switch (format) {
        case XHTML1_1:
            styleSheetPath = "xhtml/xhtml1_1.xsl";
            break;
        case HTML:
            styleSheetPath = "xhtml/html.xsl";
            break;
        default:
            styleSheetPath = "xhtml/xhtml.xsl";
            break;
        }
        URL transformURL = getStyleSheet(styleSheetPath);
        if (transformURL == null) {
            return false;
        }

        if (!copyXSLResources(styleSheetPath, 
                              preProcFiles[0].getParentFile())) {
            return false;
        }

        String[] params = styleSheetParams;

        File[] transformedFiles = transform(transformURL, params,
                                            preProcFiles, outExtension);
        if (transformedFiles == null) {
            return false;
        }

        return true;
    }

    private URL getStyleSheet(String styleSheetPath) {
        URL transformURL = styleSheetURL;
        if (transformURL == null) {
            transformURL = findStyleSheet(styleSheetPath);
            if (transformURL == null) {
                console.error(Msg.msg("dontFindStyleSheet", styleSheetPath));
            }
        }
        return transformURL;
    }

    private URL findStyleSheet(String styleSheetPath) {
        URL transformURL = null;

        File installDir = AppUtil.findInstallDirectory();

        if (pluginName != null) {
            File pluginDir = AppUtil.findPluginDirectory(installDir);
            if (pluginDir != null) {
                File xslDir = new File(pluginDir,
                                       pluginName + File.separator + "xsl");
                if (xslDir.isDirectory()) {
                    try {
                        transformURL = 
                            URLUtil.createURL(FileUtil.fileToURL(xslDir), 
                                              styleSheetPath);
                        if (!URLUtil.exists(transformURL)) {
                            transformURL = null;
                            // Fallback to stock XSLT stylesheet.
                        }
                    } catch (MalformedURLException ignored) {}
                }
            }
        }

        if (transformURL == null) {
            File xslDir = AppUtil.findXSLDirectory(installDir);
            if (xslDir != null) {
                try {
                    transformURL = URLUtil.createURL(FileUtil.fileToURL(xslDir),
                                                     styleSheetPath);
                } catch (MalformedURLException ignored) {}
            }
        }

        return transformURL;
    }

    private URL findStyleSheetResources(String styleSheetPath) {
        int pos = styleSheetPath.lastIndexOf('/');
        if (pos < 0) {
            return null;
        }

        String path = styleSheetPath.substring(0, pos) + "/resources.list";
        return findStyleSheet(path);
    }

    private boolean copyXSLResources(String styleSheetPath, File outDir) {
        // Where to copy? ---

        File xslResourcesDir = null;

        if (styleSheetParams != null) {
            for (int i = 0; i < styleSheetParams.length; i += 2) {
                String name = styleSheetParams[i];

                if ("xsl-resources-directory".equals(name)) {
                    String value = styleSheetParams[i+1];

                    URL url = null;
                    try {
                        url = URLUtil.createURL(value);
                    } catch (MalformedURLException ignored) {}

                    if (url == null) {
                        try {
                            url = URLUtil.createURL(FileUtil.fileToURL(outDir),
                                                    value);
                            xslResourcesDir = URLUtil.urlToFile(url);
                        } catch (MalformedURLException ignored) {}
                    }
                    // Otherwise xsl-resources-directory is an absolute URL
                    // and there is nothing to do.

                    // Done.
                    break;
                }
            }
        }

        if (xslResourcesDir == null) {
            // Nothing to do.
            return true;
        }

        // What to copy? ---

        URL resourceListURL = null;

        URL customStyleSheetURL = styleSheetURL;
        if (customStyleSheetURL != null) {
            // Custom XSLT stylesheet. Any custom resources? ---

            try {
                resourceListURL = URLUtil.createURL(customStyleSheetURL,
                                                    "resources.list");
                if (!URLUtil.exists(resourceListURL)) {
                    resourceListURL = null;
                }
            } catch (MalformedURLException ignored) {}
        }

        if (resourceListURL == null) {
            // Use plugin or stock XSLT stylesheet resources, if any ---

            resourceListURL = findStyleSheetResources(styleSheetPath);
            if (resourceListURL != null && !URLUtil.exists(resourceListURL)) {
                resourceListURL = null;
            }
        }

        if (resourceListURL == null) {
            // Nothing to do.
            return true;
        }

        // Copy ---

        console.info(Msg.msg("copyingXSLResources", 
                             URLUtil.toLabel(resourceListURL), 
                             xslResourcesDir));

        try {
            String list = URLUtil.loadString(resourceListURL, "UTF-8");

            // Create the resource (hierarchy of) directory if needed to.
            if (!xslResourcesDir.isDirectory()) {
                FileUtil.checkedMkdirs(xslResourcesDir);
            }

            String[] paths = StringUtil.split(list, '\n');
            for (int i = 0; i < paths.length; ++i) {
                String path = paths[i].trim();

                if (path.length() == 0 || path.startsWith("#")) {
                    // Skip open line or comment.
                    continue;
                }

                URL inURL = null;
                try {
                    inURL = URLUtil.createURL(resourceListURL, path);
                } catch (MalformedURLException ignored) {}
                if (inURL == null) {
                    throw new IOException(
                        Msg.msg("invalidXSLResourceSpec", path, 
                                URLUtil.toLabel(resourceListURL)));
                }

                File outFile = new File(xslResourcesDir,
                                        URLUtil.getBaseName(inURL));
                if (!outFile.isFile()) {
                    // Do not overwrite an existing file.
                    FileUtil.copyFile(inURL, outFile);
                }
            }

            return true;
        } catch (IOException e) {
            console.error(Msg.msg("cannotCopyXSLResources", 
                                  URLUtil.toLabel(resourceListURL), 
                                  xslResourcesDir, ThrowableUtil.reason(e)));
            return false;
        }
    }

    private File[] transform(URL transformURL, String[] params,
                             File[] preProcFiles, String outExtension) {
        // Pass required param "ditacListsURI" ---

        int count = preProcFiles.length;
        for (int i = 0; i < count; ++i) {
            File ditacFile = preProcFiles[i];

            if (ditacFile.getPath().endsWith(".ditac_lists")) {
                String ditacListsURI = 
                    FileUtil.fileToURL(ditacFile).toExternalForm();

                if (params == null) {
                    params = new String[] { "ditacListsURI", ditacListsURI };
                } else {
                    String[] params2 = new String[2+params.length];
                    params2[0] = "ditacListsURI";
                    params2[1] = ditacListsURI;
                    System.arraycopy(params, 0, params2, 2, params.length);
                    params = params2;
                }
                break;
            }
        }

        // Transform all .ditac files ---

        URIResolver uriResolver = Resolve.createURIResolver();
        ErrorListener errorListener = new ConsoleErrorListener(console);
        EntityResolver entityResolver = Resolve.createEntityResolver();

        File[] transformedFiles = new File[count];
        int j = 0;

        for (int i = 0; i < count; ++i) {
            File ditacFile = preProcFiles[i];

            if (ditacFile.getPath().endsWith(".ditac")) {
                File transformedFile = FileUtil.setExtension(ditacFile,
                                                             outExtension);

                try {
                    transform(transformURL, params, 
                              ditacFile, transformedFile, 
                              uriResolver, errorListener, entityResolver);
                } catch (Exception e) {
                    console.error(Msg.msg("cannotTransform", 
                                          ditacFile, transformedFile, 
                                          transformURL,
                                          ThrowableUtil.reason(e)));
                    return null;
                }

                transformedFiles[j++] = transformedFile;
            }
        }

        if (transformedFiles.length != j) {
            transformedFiles = ArrayUtil.trimToSize(transformedFiles, j);
        }
        return transformedFiles;
    }

    private void transform(URL transformURL, String[] params, 
                           File inFile, File outFile, 
                           URIResolver uriResolver, 
                           ErrorListener errorListener,
                           EntityResolver entityResolver) 
        throws Exception {
        console.info(Msg.msg("transforming", inFile, outFile,
                             URLUtil.toLabel(transformURL)));

        Transformer transformer = createTransformer(transformURL);

        if (params != null) {
            for (int i = 0; i < params.length; i += 2) {
                transformer.setParameter(params[i], params[i+1]);
            }
        }

        // For use by document().
        transformer.setURIResolver(uriResolver);

        transformer.setErrorListener(errorListener);

        XMLReader xmlReader = createXMLReader();
        xmlReader.setEntityResolver(entityResolver);

        Source source = new SAXSource(
            xmlReader, 
            new InputSource(FileUtil.fileToURL(inFile).toExternalForm()));

        OutputStream outStream =
            new BufferedOutputStream(new FileOutputStream(outFile));
        StreamResult sink = new StreamResult(outStream);
        sink.setSystemId(FileUtil.fileToURL(outFile).toExternalForm());
        
        try {
            transformer.transform(source, sink);
        } finally {
            outStream.close();
        }

        //showMemoryUsage();
    }

    private Transformer createTransformer(URL transformURL) 
        throws Exception {
        if (styleSheetCache == null) {
            styleSheetCache = new StyleSheetCache();
        }
        return styleSheetCache.newTransformer(transformURL, console);
    }

    protected XMLReader createXMLReader() 
        throws Exception {
        return XMLUtil.newSAXParser().getXMLReader();
    }

    // ------------------------------------
    // convertToPrintForm
    // ------------------------------------

    private boolean convertToPrintForm(File[] preProcFiles, 
                                       String outExtension) {
        String styleSheetPath = "fo/fo.xsl";
        URL transformURL = getStyleSheet(styleSheetPath);
        if (transformURL == null) {
            return false;
        }

        if (!copyXSLResources(styleSheetPath, 
                              preProcFiles[0].getParentFile())) {
            return false;
        }

        String[] params = styleSheetParams;

        String foExtension;
        FOConverter foConverter;
        String foProcessorName;

        if (format == Format.FO) {
            foExtension = outExtension;

            foConverter = null;
            foProcessorName = null;
        } else {
            foExtension = "fo";

            foConverter = getFOConverter(format);
            if (foConverter == null) {
                console.error(Msg.msg("noRegisteredFOConverter", format) + 
                              "\n" +
                              Msg.msg("useOptionsFile", getOptionsFile()));
                return false;
            }
            foProcessorName = foConverter.getProcessorName();

            String[] params2 = new String[2+params.length];
            params2[0] = "foProcessor";
            params2[1] = foProcessorName;
            System.arraycopy(params, 0, params2, 2, params.length);
            params = params2;
        }

        File[] transformedFiles = transform(transformURL, params,
                                            preProcFiles, foExtension);
        if (transformedFiles == null) {
            return false;
        }

        if (foConverter != null) {
            for (int i = 0; i < transformedFiles.length; ++i) {
                File transformedFile = transformedFiles[i];

                File outFile =
                    FileUtil.setExtension(transformedFile, outExtension);

                console.info(Msg.msg("convertingFO", transformedFile,
                                     outFile, foProcessorName));

                try {
                    foConverter.convertFO(transformedFile, outFile,
                                          console);
                } catch (Throwable t) {
                    console.error(Msg.msg("cannotConvertFO", transformedFile,
                                          outFile, foProcessorName, 
                                          ThrowableUtil.reason(t)));
                    return false;
                }
            }

            if (!keepFO && !deleteFilesOrDirs(transformedFiles)) {
                return false;
            }
        }

        return true;
    }

    // -----------------------------------------------------------------------
    // JavaHelp support
    // -----------------------------------------------------------------------

    private File[] preProcessJavaHelp(URL[] inFiles, File outFile) 
        throws IOException {
        String baseName = 
            FileUtil.setExtension(outFile.getName(), null) + "__";
        preProcTempDir = File.createTempFile(baseName, "_jar", 
                                             outFile.getParentFile());
        preProcTempDir.delete();
        FileUtil.checkedMkdir(preProcTempDir);

        File outFile2 = new File(preProcTempDir, "_.html");
        return preProc.process(inFiles, outFile2);
    }

    private boolean convertToJavaHelp(File[] preProcFiles, 
                                      String outExtension) {
        String styleSheetPath = "javahelp/javahelp.xsl";
        URL transformURL = getStyleSheet(styleSheetPath);
        if (transformURL == null) {
            return false;
        }

        if (!copyXSLResources(styleSheetPath, 
                              preProcFiles[0].getParentFile())) {
            return false;
        }

        String[] params = styleSheetParams;

        File[] transformedFiles = transform(transformURL, params,
                                            preProcFiles, "html");
        if (transformedFiles == null) {
            return false;
        }

        deleteFilesOrDirs(preProcFiles); // No longer needed.

        if (!runJhindexer(preProcTempDir)) {
            return false;
        }

        console.info(Msg.msg("creatingArchive", preProcTempDir, outFile));

        try {
            Zip.zip(preProcTempDir, /*inclTop*/ false, /*filter*/ null,
                    outFile);
        } catch (IOException e) {
            console.error(Msg.msg("cannotCreateArchive", preProcTempDir, 
                                  outFile, ThrowableUtil.reason(e)));
            return false;
        }

        return true;
    }

    private boolean runJhindexer(File preProcTempDir) {
        if (jhindexerExe == null) {
            console.error(Msg.msg("noJhindexerExe") + "\n" +
                          Msg.msg("useOptionsFile", getOptionsFile()));
            return false;
        }

        console.info(Msg.msg("indexingDir", preProcTempDir));

        StringBuilder buffer = new StringBuilder();
        buffer.append('"');
        buffer.append(jhindexerExe.getPath());
        buffer.append("\" .");
        return execCommand(buffer.toString(), preProcTempDir, 
                           /*checkExitCode*/ true);
    }

    private boolean execCommand(String cmd, File workDir,
                                boolean checkExitCode) {
        console.verbose(Msg.msg("executingCommand", cmd, workDir));

        int exitCode;
        try {
            exitCode = SystemUtil.shellExec(cmd, null, workDir, console);
        } catch (Exception e) {
            console.verbose(Msg.msg("cannotExecuteCommand", cmd, 
                                    ThrowableUtil.reason(e)));
            return false;
        }

        if (checkExitCode && exitCode != 0) {
            console.error(Msg.msg("commandHasFailed", cmd, exitCode));
            return false;
        }

        return true;
    }

    // -----------------------------------------------------------------------
    // HTMLHelp support
    // -----------------------------------------------------------------------

    private File[] preProcessHTMLHelp(URL[] inFiles, File outFile) 
        throws IOException {
        String baseName = 
            FileUtil.setExtension(outFile.getName(), null) + "__";
        preProcTempDir = File.createTempFile(baseName, "_chm", 
                                             outFile.getParentFile());
        preProcTempDir.delete();
        FileUtil.checkedMkdir(preProcTempDir);

        File outFile2 = new File(preProcTempDir, "_.html");
        return preProc.process(inFiles, outFile2);
    }

    private boolean convertToHTMLHelp(File[] preProcFiles, 
                                      String outExtension) {
        String styleSheetPath = "htmlhelp/htmlhelp.xsl";
        URL transformURL = getStyleSheet(styleSheetPath);
        if (transformURL == null) {
            return false;
        }

        if (!copyXSLResources(styleSheetPath, 
                              preProcFiles[0].getParentFile())) {
            return false;
        }

        String[] params = styleSheetParams;

        String chmBasename = outFile.getName();
        String hhpBasename = FileUtil.setExtension(chmBasename, "hhp");

        String[] params2 = new String[4+params.length];
        params2[0] = "chmBasename";
        params2[1] = chmBasename;
        params2[2] = "hhpBasename";
        params2[3] = hhpBasename;
        System.arraycopy(params, 0, params2, 4, params.length);
        params = params2;

        File[] transformedFiles = transform(transformURL, params,
                                            preProcFiles, "html");
        if (transformedFiles == null) {
            return false;
        }

        deleteFilesOrDirs(preProcFiles); // No longer needed.

        // On Unix, specify "/bin/false" as the value of option -hhc.
        // This allows to pass non regression tests.

        File chmFile1;
        File chmFile2;
        if (hhcExe != null && hhcExe.getName().startsWith("false")) {
            chmFile1 = preProcTempDir;
            chmFile2 = new File(outFile.getParentFile(),
                                chmBasename.replace('.', '_'));
        } else {
            if (!runHhc(preProcTempDir, hhpBasename)) {
                return false;
            }

            chmFile1 = new File(preProcTempDir, chmBasename);
            chmFile2 = outFile;
        }

        try {
            if (chmFile2.exists()) {
                FileUtil.deleteFileOrDir(chmFile2);
            }

            FileUtil.checkedRename(chmFile1, chmFile2);
        } catch (IOException e) {
            console.error(Msg.msg("cannotRenameFile", chmFile1, chmFile2,
                                  ThrowableUtil.reason(e)));
            return false;
        }

        return true;
    }

    private boolean runHhc(File preProcTempDir, String hhpBasename) {
        if (hhcExe == null) {
            console.error(Msg.msg("noHhcExe") + "\n" +
                          Msg.msg("useOptionsFile", getOptionsFile()));
            return false;
        }

        console.info(Msg.msg("compilingHTMLHelp", outFile));

        // hhc.exe exit code is 1 even when the compilation is successful. Its
        // exit code should be 0.

        StringBuilder buffer = new StringBuilder();
        buffer.append('"');
        buffer.append(hhcExe.getPath());
        buffer.append("\" \"");
        buffer.append(hhpBasename);
        buffer.append('"');
        return execCommand(buffer.toString(), preProcTempDir, 
                           /*checkExitCode*/ false);
    }

    // -----------------------------------------------------------------------
    // EclipseHelp support
    // -----------------------------------------------------------------------

    private boolean convertToEclipseHelp(File[] preProcFiles, 
                                         String outExtension) {
        String styleSheetPath = "eclipsehelp/eclipsehelp.xsl";
        URL transformURL = getStyleSheet(styleSheetPath);
        if (transformURL == null) {
            return false;
        }

        if (!copyXSLResources(styleSheetPath, 
                              preProcFiles[0].getParentFile())) {
            return false;
        }

        File[] transformedFiles = transform(transformURL, styleSheetParams,
                                            preProcFiles, outExtension);
        if (transformedFiles == null) {
            return false;
        }

        deleteFilesOrDirs(preProcFiles); // No longer needed.

        return true;
    }

    // -----------------------------------------------------------------------
    // WebHelp support
    // -----------------------------------------------------------------------

    private boolean convertToWebHelp(File[] preProcFiles, 
                                     String outExtension) {
        String styleSheetPath = "webhelp/webhelp.xsl";
        URL transformURL = getStyleSheet(styleSheetPath);
        if (transformURL == null) {
            return false;
        }

        if (!copyXSLResources(styleSheetPath, 
                              preProcFiles[0].getParentFile())) {
            return false;
        }

        String tocBaseName = "whc_toc.xml";
        String indexBaseName = "whc_index.xml";

        int paramCount = styleSheetParams.length;
        String[] params = new String[paramCount];
        int j = 0;
        String[] params2 = new String[paramCount];
        int k = 0;

        for (int i = 0; i < paramCount; i += 2) {
            String name = styleSheetParams[i];
            String value = styleSheetParams[i+1];

            if (name.startsWith("wh-")) {
                // Pass it to the Web Help Compiler.
                params2[k++] = name;
                params2[k++] = value;
            } else {
                params[j++] = name;
                params[j++] = value;
                
                value = value.trim();
                if (value.length() > 0) {
                    if ("whc-toc-basename".equals(name)) {
                        tocBaseName = value;
                    } else if ("whc-index-basename".equals(name)) {
                        indexBaseName = value;
                    }
                }
            }
        }

        if (j != paramCount) {
            params = ArrayUtil.trimToSize(params, j);
        }
        if (k != paramCount) {
            params2 = ArrayUtil.trimToSize(params2, k);
        }

        File[] transformedFiles = transform(transformURL, params,
                                            preProcFiles, outExtension);
        if (transformedFiles == null) {
            return false;
        }

        deleteFilesOrDirs(preProcFiles); // No longer needed.
        
        Compiler compiler = createWebHelpCompiler();
        if (defaultLang != null) {
            params2 = ArrayUtil.append(params2, "wh-default-language");
            params2 = ArrayUtil.append(params2, defaultLang);
        }
        // Also accept relative URIs.
        URL pwd = FileUtil.fileToURL(new File("."));
        if (params2.length > 0 && 
            !compiler.parseParameters(params2, pwd)) {
            return false;
        }

        console.info(Msg.msg("compilingWebHelp"));

        File outDir = transformedFiles[0].getParentFile();
        File tocFile = new File(outDir, tocBaseName);
        File indexFile = new File(outDir, indexBaseName);
        if (!indexFile.isFile()) {
            indexFile = null;
        }

        boolean done = false;
        try {
            done = compiler.compile(transformedFiles, tocFile, indexFile, 
                                    /*inPlace*/ null);
        } catch (Exception e) {
            console.error(Msg.msg("cannotCompileWebHelp", 
                                  ThrowableUtil.reason(e)));
        }

        if (done) {
            deleteFileOrDir(tocFile);
            if (indexFile != null) {
                deleteFileOrDir(indexFile);
            }
        }

        return done;
    }

    private Compiler createWebHelpCompiler() {
        Compiler compiler = new Compiler(console);

        Console.MessageType messageType = console.getVerbosity();
        compiler.setVerbose(messageType.ordinal() >= 
                            Console.MessageType.INFO.ordinal());

        compiler.setTemplateManifest(whcTemplateManifestURL);

        return compiler;
    }

    // -----------------------------------------------------------------------
    // EPUB support
    // -----------------------------------------------------------------------

    private File[] preProcessEPUB(URL[] inFiles, File outFile) 
        throws IOException {
        String baseName = 
            FileUtil.setExtension(outFile.getName(), null) + "__";
        preProcTempDir = File.createTempFile(baseName, "_epub", 
                                             outFile.getParentFile());
        preProcTempDir.delete();
        FileUtil.checkedMkdir(preProcTempDir);

        File outFile2 = new File(preProcTempDir, "_.html");
        return preProc.process(inFiles, outFile2);
    }

    private boolean convertToEPUB(File[] preProcFiles, String outExtension) {
        String styleSheetPath = "epub/epub.xsl";
        URL transformURL = getStyleSheet(styleSheetPath);
        if (transformURL == null) {
            return false;
        }

        if (!copyXSLResources(styleSheetPath, 
                              preProcFiles[0].getParentFile())) {
            return false;
        }

        File[] transformedFiles = transform(transformURL, styleSheetParams,
                                            preProcFiles, "html");
        if (transformedFiles == null) {
            return false;
        }

        deleteFilesOrDirs(preProcFiles); // No longer needed.

        console.info(Msg.msg("creatingArchive", preProcTempDir, outFile));

        try {
            savePackageFiles(preProcTempDir);
            
            zipEPUB(preProcTempDir, outFile);
        } catch (IOException e) {
            console.error(Msg.msg("cannotCreateArchive", preProcTempDir, 
                                  outFile, ThrowableUtil.reason(e)));
            return false;
        }

        return true;
    }

    private static final String CONTAINER_XML =
    "<?xml version=\"1.0\"?>\n" +
    "<container version=\"1.0\"\n" +
    "           xmlns=\"urn:oasis:names:tc:opendocument:xmlns:container\">\n" +
    "  <rootfiles>\n" +
    "    <rootfile full-path=\"content.opf\"\n" +
    "              media-type=\"application/oebps-package+xml\"/>\n" +
    "  </rootfiles>\n" +
    "</container>\n";

    private static void savePackageFiles(File outDir) 
        throws IOException {
        File outFile = new File(outDir, "mimetype");
        FileUtil.saveString("application/epub+zip", outFile, "US-ASCII");

        File metaDir = new File(outDir, "META-INF");
        if (metaDir.exists()) {
            FileUtil.deleteFileOrDir(metaDir);
        }
        FileUtil.checkedMkdir(metaDir);

        outFile = new File(metaDir, "container.xml");
        FileUtil.saveString(CONTAINER_XML, outFile, "US-ASCII");
    }

    private static void zipEPUB(File srcDir, File zipFile) 
        throws IOException {
        Zip.Archive archive = 
          new Zip.Archive(new ZipOutputStream(new FileOutputStream(zipFile)));
        try {
            archive.add(new File(srcDir, "mimetype"), srcDir, /*store*/ true);

            String[] baseNames = FileUtil.checkedList(srcDir);
            for (String baseName : baseNames) {
                if (!"mimetype".equals(baseName)) {
                    File file = new File(srcDir, baseName);
                    if (file.isDirectory()) {
                        archive.addAll(file, null, srcDir);
                    } else {
                        archive.add(file, srcDir);
                    }
                }
            }
        } finally {
            archive.close();
        }
    }

    // -----------------------------------------------------------------------
    // Parse command-line options
    // -----------------------------------------------------------------------

    private boolean parseOptions(String[] args) {
        args = loadOptionsFiles(args);
        if (args == null) {
            return false;
        }
        
        ArrayList<String> params = new ArrayList<String>();

        int l;
        for (l = 0; l < args.length; ++l) {
            String arg = args[l];

            if ("-p".equals(arg) || "-param".equals(arg)) {
                if (l+2 >= args.length) {
                    usage(null);
                    return false;
                }

                String name = args[l+1];
                String value = args[l+2];
                l += 2;

                params.add(name);
                params.add(value);

                if ("title-page".equals(name) && 
                    !"auto".equals(value) && 
                    !"none".equals(value)) {
                    // Force the generation of titlePage when a custom
                    // title page has been specified.
                    preProc.setForceTitlePage(true);
                }
            } else if ("-c".equals(arg) || "-chunk".equals(arg)) {
                if (l+1 >= args.length) {
                    usage(null);
                    return false;
                }

                String spec = args[++l];
                Chunking chunking = Chunking.fromString(spec);
                if (chunking == null) {
                    usage(Msg.msg("unknownChunking", spec, 
                                  Chunking.joinStringForms(" ")));
                    return false;
                }

                preProc.setChunking(chunking);
            } else if ("-f".equals(arg) || "-format".equals(arg)) {
                if (l+1 >= args.length) {
                    usage(null);
                    return false;
                }

                String spec = args[++l];
                format = parseFormat(spec, false);
                if (format == null) 
                    return false;
            } else if ("-i".equals(arg) || "-images".equals(arg)) {
                if (l+1 >= args.length) {
                    usage(null);
                    return false;
                }

                if (!setImageHandler("com.xmlmind.ditac.convert.ImageCopier",
                                     args[++l])) {
                    return false;
                }
            } else if ("-imagehandler".equals(arg)) {
                if (l+2 >= args.length) {
                    usage(null);
                    return false;
                }

                if (!setImageHandler(args[l+1], args[l+2])) {
                    return false;
                }
                l += 2;
            } else if ("-filter".equals(arg)) {
                if (l+1 >= args.length) {
                    usage(null);
                    return false;
                }

                if (!setFilter(args[++l])) {
                    return false;
                }
            } else if ("-toc".equals(arg)) {
                preProc.setFrontMatter(new int[] { PreProcessor.TOC });
            } else if ("-index".equals(arg)) {
                preProc.setBackMatter(new int[] { PreProcessor.INDEX_LIST });
            } else if ("-frontmatter".equals(arg)) {
                if (l+1 >= args.length) {
                    usage(null);
                    return false;
                }

                int[] items = parseFrontBackMatter(args[++l]);
                if (items == null) {
                    return false;
                }
                preProc.setFrontMatter(items);
            } else if ("-backmatter".equals(arg)) {
                if (l+1 >= args.length) {
                    usage(null);
                    return false;
                }

                int[] items = parseFrontBackMatter(args[++l]);
                if (items == null) {
                    return false;
                }
                preProc.setBackMatter(items);
            } else if ("-lang".equals(arg)) {
                if (l+1 >= args.length) {
                    usage(null);
                    return false;
                }

                preProc.setLang(args[++l]);
            } else if ("-plugin".equals(arg)) {
                if (l+1 >= args.length) {
                    usage(null);
                    return false;
                }

                pluginName = args[++l];
            } else if ("-t".equals(arg) || "-xslt".equals(arg)) {
                if (l+1 >= args.length) {
                    usage(null);
                    return false;
                }

                String location = args[++l];
                styleSheetURL = URLUtil.urlOrFile(location);
                if (styleSheetURL == null) {
                    usage(Msg.msg("notAnURLOrFile", location));
                    return false;
                }
            } else if ("-fop".equals(arg)) {
                if (l+1 >= args.length) {
                    configUsage(null);
                    return false;
                }

                String exe = args[++l];
                if (!registerFOP(exe)) {
                    configUsage(Msg.msg("notAnExeFile", args[l]));
                    return false;
                }
            } else if ("-xep".equals(arg)) {
                if (l+1 >= args.length) {
                    configUsage(null);
                    return false;
                }

                String exe = args[++l];
                if (!registerXEP(exe)) {
                    configUsage(Msg.msg("notAnExeFile", args[l]));
                    return false;
                }
            } else if ("-ahf".equals(arg)) {
                if (l+1 >= args.length) {
                    configUsage(null);
                    return false;
                }

                String exe = args[++l];
                if (!registerAHF(exe)) {
                    configUsage(Msg.msg("notAnExeFile", args[l]));
                    return false;
                }
            } else if ("-xfc".equals(arg)) {
                if (l+1 >= args.length) {
                    configUsage(null);
                    return false;
                }

                String exe = args[++l];
                if (!registerXFC(exe)) {
                    configUsage(Msg.msg("notAnExeFile", args[l]));
                    return false;
                }
            } else if ("-foconverter".equals(arg)) {
                if (l+3 >= args.length) {
                    configUsage(null);
                    return false;
                }

                String foProcName = args[l+1];
                Format targetFormat = parseFormat(args[l+2], true);
                String command = args[l+3];
                l += 3;

                if (targetFormat == null) {
                    return false;
                }
                
                registerExternalFOConverter(foProcName, targetFormat, command);
            } else if ("-jhindexer".equals(arg)) {
                if (l+1 >= args.length) {
                    configUsage(null);
                    return false;
                }

                File exe = toExeFile(args[++l]);
                if (exe == null) {
                    configUsage(Msg.msg("notAnExeFile", args[l]));
                    return false;
                }
                setJhindexerExe(exe);
            } else if ("-hhc".equals(arg)) {
                if (l+1 >= args.length) {
                    configUsage(null);
                    return false;
                }

                File exe = toExeFile(args[++l]);
                if (exe == null) {
                    configUsage(Msg.msg("notAnExeFile", args[l]));
                    return false;
                }
                setHhcExe(exe);
            } else if ("-preprocess".equals(arg)) {
                preprocess = true;
            } else if ("-dryrun".equals(arg)) {
                dryRun = true;
                preProc.setDryRun(true);
            } else if ("-automap".equals(arg)) {
                if (l+1 >= args.length) {
                    debugUsage(null);
                    return false;
                }

                preProc.setAutoMapSaveFile(new File(args[++l]));
            } else if ("-keepfo".equals(arg)) {
                keepFO = true;
            } else if ("-errout".equals(arg)) {
                Console c = console.console;
                if (c instanceof SimpleConsole) {
                  ((SimpleConsole) c).setErrorLevel(Console.MessageType.ERROR);
                }
            } else if ("-v".equals(arg)) {
                console.setVerbosity(Console.MessageType.INFO);
            } else if ("-vv".equals(arg)) {
                console.setVerbosity(Console.MessageType.VERBOSE);
            } else if ("-vvv".equals(arg)) {
                console.setVerbosity(Console.MessageType.DEBUG);
            } else if ("-version".equals(arg)) {
                console.setVerbosity(Console.MessageType.INFO);
                console.info(Msg.msg("version", PreProcessor.VERSION));
                return false;
            } else if ("-addindex".equals(arg)) {
                addIndex = true;
            } else if ("-partrestartschapternumber".equals(arg)) {
                // Not documented.
                preProc.setPartRestartsChapterNumber(true);
            } else if ("-?".equals(arg)) {
                if (l+1 >= args.length) {
                    usage(null);
                } else {
                    String option = args[++l];
                    if ("config".equals(option)) {
                        configUsage(null);
                    } else if ("debug".equals(option)) {
                        debugUsage(null);
                    } else {
                        usage(null);
                    }
                }
                return false;
            } else {
                if (arg.startsWith("-")) {
                    usage(Msg.msg("unknownOption", arg));
                    return false;
                }
                break;
            }
        }

        if (l+1 >= args.length) {
            usage(Msg.msg("tooFewArgs"));
            return false;
        }

        outFile = (new File(args[l])).getAbsoluteFile();
        ++l;

        int count = args.length - l;
        inFiles = new URL[count];
        count = 0;

        for (; l < args.length; ++l) {
            URL url = URLUtil.urlOrFile(args[l]);
            if (url == null) {
                usage(Msg.msg("notAnURLOrFile", args[l]));
                return false;
            }

            inFiles[count++] = url;
        }

        if (format == null) {
            String baseName = outFile.getName();
            format = Format.fromExtension(baseName);
            if (format == null) {
                usage(Msg.msg("cannotGuessFormat", baseName));
                return false;
            }
        }

        preProc.setMedia(format.toMedia());

        styleSheetParams = new String[params.size()];
        params.toArray(styleSheetParams);

        return true;
    }

    private String[] loadOptionsFiles(String[] args) {
        // Check that we have options files to be loaded ---

        boolean hasOptionsFiles = false;

        for (int l = 0; l < args.length; ++l) {
            String arg = args[l];

            if ("-options".equals(arg) || "-o".equals(arg)) {
                hasOptionsFiles = true;
                break;
            }
        }

        if (!hasOptionsFiles) {
            return args;
        }

        // Load options files ---

        ArrayList<String> argList = new ArrayList<String>();

        for (int l = 0; l < args.length; ++l) {
            String arg = args[l];

            if ("-options".equals(arg) || "-o".equals(arg)) {
                if (l+1 >= args.length) {
                    usage(null);
                    return null;
                }

                String location = args[++l];
                URL url = URLUtil.urlOrFile(location);
                if (url == null) {
                    usage(Msg.msg("notAnURLOrFile", location));
                    return null;
                }

                String options = null;
                try {
                    // Obtain encoding from connection. Normally, native
                    // encoding for file: URLs.
                    options = URLUtil.loadString(url);
                } catch (IOException e) {
                    console.error(Msg.msg("cannotLoadOptionsFile", 
                                          URLUtil.toLabel(url), 
                                          ThrowableUtil.reason(e)));
                    return null;
                }

                String[] optionList = StringUtil.splitArguments(options);
                for (int k = 0; k < optionList.length; ++k) {
                    argList.add(optionList[k]);
                }
            } else {
                argList.add(arg);
            }
        }

        args = new String[argList.size()];
        argList.toArray(args);
        return args;
    }

    private Format parseFormat(String spec, boolean configUsage) {
        Format format = Format.fromString(spec);
        if (format == null) {
            String msg = Msg.msg("unknownFormat",
                                 spec, Format.joinStringForms(" "));
            if (configUsage) {
                configUsage(msg);
            } else {
                usage(msg);
            }
        }
        return format;
    }

    private boolean setImageHandler(String className, String parameters) {
        try {
            ImageHandler imageHandler = 
                (ImageHandler) Class.forName(className).newInstance();

            imageHandler.parseParameters(parameters);

            preProc.setImageHandler(imageHandler);
            return true;
        } catch (Exception e) {
            usage(Msg.msg("cannotCreateImageHandler", className, parameters,
                          ThrowableUtil.reason(e)));
            return false;
        }
    }

    private boolean setFilter(String location) {
        URL url = URLUtil.urlOrFile(location);
        if (url == null) {
            usage(Msg.msg("notAnURLOrFile", location));
            return false;
        }

        try {
            preProc.setFilter(new Filter(url));
            return true;
        } catch (Exception e) {
            usage(Msg.msg("cannotCreateFilter", location,
                          ThrowableUtil.reason(e)));
            return false;
        }
    }

    private int[] parseFrontBackMatter(String spec) {
        int[] items = null;
        
        String[] split = StringUtil.split(spec, ',');
        if (split.length > 0) {
            items = new int[split.length];

            for (int i = 0; i < split.length; ++i) {
                String samePage = split[i].trim();

                int item = 0x0;

                String[] split2 = StringUtil.split(samePage, '+');
                for (int j = 0; j < split2.length; ++j) {
                    String section = split2[j];

                    if ("toc".equals(section)) {
                        item |= PreProcessor.TOC;
                    } else if ("figurelist".equals(section)) {
                        item |= PreProcessor.FIGURE_LIST;
                    } else if ("tablelist".equals(section)) {
                        item |= PreProcessor.TABLE_LIST;
                    } else if ("examplelist".equals(section)) {
                        item |= PreProcessor.EXAMPLE_LIST;
                    } else if ("indexlist".equals(section)) {
                        item |= PreProcessor.INDEX_LIST;
                    } else {
                        item = 0x0;
                        break;
                    }
                }

                if (item != 0x0) {
                    items[i] = item;
                } else {
                    items = null;
                    break;
                }
            }
        }

        if (items == null) {
            usage(Msg.msg("invalidFrontBackMatterSpec", spec,
                          FRONT_BACK_MATTER_SPEC));
        }
        return items;
    }

    private void usage(String error) {
        String msg = Msg.msg("usage", Chunking.joinStringForms("|"),
                             Format.joinStringForms("|"), 
                             FRONT_BACK_MATTER_SPEC);
        if (error != null) {
            msg = error + "\n" + msg;
        }
        console.error(msg);
    }

    private void configUsage(String error) {
        String msg = Msg.msg("configUsage");
        if (error != null) {
            msg = error + "\n" + msg;
        }
        console.error(msg);
    }

    private void debugUsage(String error) {
        String msg = Msg.msg("debugUsage", getOptionsFile());
        if (error != null) {
            msg = error + "\n" + msg;
        }
        console.error(msg);
    }

    private String[] prependOptionsFile(String[] args) {
        for (int i = 0; i < args.length; ++i) {
            if ("-ignoreoptionsfile".equals(args[i])) {
                return StringList.removeAt(args, i);
            }
        }

        File optionsFile = getOptionsFile();
        if (optionsFile != null && optionsFile.isFile()) {
            String options = null;
            try {
                // Use the native encoding of the platform.
                options = FileUtil.loadString(optionsFile);
            } catch (IOException e) {
                console.error(Msg.msg("cannotLoadOptionsFile", 
                                      optionsFile, ThrowableUtil.reason(e)));
                return null;
            }

            String[] optionList = StringUtil.splitArguments(options);
            if (optionList.length > 0) {
                String[] args2 = 
                    new String[optionList.length + args.length];

                System.arraycopy(optionList, 0, args2, 0,
                                 optionList.length);
                System.arraycopy(args, 0, args2, optionList.length,
                                 args.length);

                return args2;
            }
        }

        return args;
    }

    private File getOptionsFile() {
        File optionsFile = null;

        File userPrefsDir = SystemUtil.userPreferencesDir();
        if (userPrefsDir != null) {
            optionsFile = new File(userPrefsDir, "ditac.options");
        }
        // userPrefsDir==null should not happen.

        return optionsFile;
    }

    // -----------------------------------------------------------------------
    // main
    // -----------------------------------------------------------------------

    /**
     * Implements the <tt>ditac</tt> command-line utility.
     */
    public static void main(String[] args) {
        Converter converter = new Converter();

        args = converter.prependOptionsFile(args);
        if (args == null) {
            System.exit(1);
        }

        System.exit(converter.run(args));
    }
}

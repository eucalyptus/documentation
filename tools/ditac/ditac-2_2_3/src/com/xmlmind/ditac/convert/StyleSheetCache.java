/*
 * Copyright (c) 2009-2012 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.convert;

import java.io.File;
import java.net.URL;
import java.util.HashMap;
import javax.xml.transform.URIResolver;
import javax.xml.transform.ErrorListener;
import javax.xml.transform.Templates;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamSource;
import com.xmlmind.util.URLUtil;
import com.xmlmind.util.Console;
import com.xmlmind.ditac.xslt.ExtensionFunctions;
import com.xmlmind.ditac.util.Resolve;

/**
 * A simple XSL stylesheet cache.
 * <p>This class is thread-safe and is intended to be shared between several
 * {@link Converter}s.
 */
public final class StyleSheetCache {
    private static final class Entry {
        public final URL url;
        public final Templates templates;
        public final File file;
        public long fileDate;
        public long fileSize;

        public Entry(URL url, Templates templates) {
            this.url = url;
            this.templates = templates;
            file = URLUtil.urlToFile(url);
            if (file == null) {
                fileDate = -1;
                fileSize = -1;
            } else {
                fileDate = file.lastModified();
                fileSize = file.length();
            }
        }

        @Override
        public int hashCode() {
            return url.hashCode();
        }

        @Override
        public boolean equals(Object other) {
            if (other == null || !(other instanceof Entry)) {
                return false;
            }
            return url.equals(((Entry) other).url);
        }
    }

    // -----------------------------------------------------------------------

    private HashMap<URL, Entry> urlToEntry;
    private TransformerFactory transformerFactory;

    /**
     * Constructs an empty stylesheet cache.
     */
    public StyleSheetCache() {
        urlToEntry = new HashMap<URL, Entry>();
        transformerFactory = null;
    }

    /**
     * Returns a Transformer corresponding to specified XSL stylesheet.
     * <p>The first time specified XSL stylesheet is passed to the cache,
     * a <code>javax.xml.transform.Templates</code> is created (that is, 
     * the stylesheet is parsed, a possibly lengthy operation) and 
     * cached in order to create more Transformers during subsequent 
     * invocations.
     *
     * <p>In order to create a <code>javax.xml.transform.Templates</code>,
     * this cache first creates a 
     * <code>javax.xml.transform.TransformerFactory</code>. 
     * Extension functions are registered with this factory using 
     * {@link ExtensionFunctions#registerAll}.
     * An URI resolver, returned by {@link Resolve#createURIResolver}, 
     * is registered with this factory.
     *
     * <p>This cache implements a very crude change detection:
     * <ul>
     * <li>It works only for plain files (i.e. not for <tt>http</tt> URLs).
     * <li>A change is detected only for the stylesheet main file 
     * (i.e. changes in imported modules are not detected).
     * </ul>
     *
     * @param styleSheetURL the URL of the XSL stylesheet for 
     * which a Transformer is to be created
     * @param console console on which error and debug messages are displayed.
     * May be <code>null</code>.
     * @return a new, ready to use, Transformer
     * @exception Exception if, for any reason, this operation fails
     *
     * @see Converter#Converter(StyleSheetCache, Console)
     */
    public synchronized Transformer newTransformer(URL styleSheetURL,
                                                   Console console) 
        throws Exception {
        Entry entry = urlToEntry.get(styleSheetURL);

        // Simple check on local files ---

        if (entry != null && entry.file != null) {
            if (!entry.file.isFile() || 
                entry.file.lastModified() != entry.fileDate ||
                entry.file.length() != entry.fileSize) {
                if (console != null) {
                    console.showMessage(Msg.msg("discardingObsoleteCacheEntry",
                                                entry.file),
                                        Console.MessageType.DEBUG);
                }
                urlToEntry.remove(styleSheetURL);
                entry = null;
            }
        }

        if (entry == null) {
            if (console != null) {
                console.showMessage(Msg.msg("cachingStyleSheet",
                                            styleSheetURL),
                                    Console.MessageType.DEBUG);
            }

            TransformerFactory factory = getTransformerFactory(console);
            Templates templates = factory.newTemplates(
                new StreamSource(styleSheetURL.toExternalForm()));

            entry = new Entry(styleSheetURL, templates);
            urlToEntry.put(styleSheetURL, entry);
        } else {
            if (console != null) {
                console.showMessage(Msg.msg("fetchedStyleSheet", 
                                            styleSheetURL),
                                    Console.MessageType.DEBUG);
            }
        }

        return entry.templates.newTransformer();
    }

    private TransformerFactory getTransformerFactory(Console console) 
        throws Exception {
        if (transformerFactory == null) {
            // Force the use of Saxon 9.
            Class<?> cls = 
                Class.forName("net.sf.saxon.TransformerFactoryImpl");
            transformerFactory = (TransformerFactory) cls.newInstance();

            // First extend, then configure.
            // Otherwise the resolver and error listener are forgotten (???).

            ExtensionFunctions.registerAll(transformerFactory);

            // For use by xsl:import and xsl:include.
            URIResolver uriResolver = Resolve.createURIResolver();
            transformerFactory.setURIResolver(uriResolver);

            ErrorListener errorListener = new ConsoleErrorListener(console);
            transformerFactory.setErrorListener(errorListener);
        }
        return transformerFactory;
    }

    /**
     * Clear this cache.
     *
     * @param console console on which debug messages are displayed.
     * May be <code>null</code>.
     */
    public synchronized void clear(Console console) {
        urlToEntry.clear();

        if (console != null) {
            console.showMessage(Msg.msg("clearedCache"),
                                Console.MessageType.DEBUG);
        }
    }
}

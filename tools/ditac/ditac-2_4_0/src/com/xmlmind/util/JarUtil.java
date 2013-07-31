/*
 * Copyright (c) 2002-2009 Pixware. 
 *
 * Author: Hussein Shafie
 *
 * This file is part of several XMLmind projects.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.util;

import java.io.IOException;
import java.io.File;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.StringTokenizer;
import java.util.zip.ZipEntry;
import java.util.jar.Manifest;
import java.util.jar.JarInputStream;

/**
 * A collection of utility functions (static methods) operating on JARs.
 */
public final class JarUtil {
    private static final URL[] NO_URLS = new URL[0];
    private static final String[] NO_STRINGS = new String[0];
    
    private JarUtil() {}

    // -----------------------------------------------------------------------

    /**
     * Returns the URLs of the JARs listed in the <code>Class-Path</code>
     * attribute of the manifest of a JAR.
     * 
     * @param jarURL the URL of the JAR
     * @return the URLs of the JARs listed in the <code>Class-Path</code>
     * attribute of the manifest or an empty array if the manifest or the
     * <code>Class-Path</code> attribute were not found.
     */
    public static URL[] getClassPath(URL jarURL) 
        throws IOException {
        String classPath = getClassPathAttribute(jarURL);
        if (classPath == null) 
            return NO_URLS;
            
        StringTokenizer tokens = new StringTokenizer(classPath);
        int tokenCount = tokens.countTokens();
        URL[] urls = new URL[tokenCount];
        int j = 0;

        for (int i = 0; i < tokenCount; ++i) {
            try {
                urls[j++] = new URL(jarURL, tokens.nextToken());
            } catch (MalformedURLException ignored) {}
        }

        if (j != urls.length) {
            URL[] urls2 = new URL[j];
            System.arraycopy(urls, 0, urls2, 0, j);
            urls = urls2;
        }

        return urls;
    }

    /**
     * Returns the <code>Class-Path</code> attribute of the manifest 
     * of a JAR.
     * 
     * @param jarURL the URL of the JAR
     * @return the <code>Class-Path</code> attribute of the manifest if any;
     * <code>null</code> otherwise.
     */
    public static String getClassPathAttribute(URL jarURL) 
        throws IOException {
        Manifest manifest = null;

        JarInputStream in = new JarInputStream(jarURL.openStream(), false);
        try {
            manifest = in.getManifest();
        } finally {
            in.close();
        }

        if (manifest == null)
            return null;
        else
            return manifest.getMainAttributes().getValue("Class-Path");
    }

    // -----------------------------------------------------------------------

    /**
     * Returns the service providers found in a JAR.
     * 
     * @param jarURL the URL of the JAR
     * @return a list of <em>triplets</em>:
     * <ul>
     * <li>service name (fully qualified interface name),
     * <li>service implementor (fully qualified class name),
     * <li>end of line comment after service implementor if any 
     * or <code>null</code> otherwise,
     * <ul>
     * or an empty array if the JAR contains no service providers.
     */
    public static String[] getServiceProviders(URL jarURL) 
        throws IOException {
        JarInputStream in = new JarInputStream(jarURL.openStream(), false);

        String[] list = NO_STRINGS;
        int j = 0;

        try {
            ZipEntry entry;
            byte[] bytes = new byte[8192];

            while ((entry = in.getNextEntry()) != null) {
                String name = entry.getName();

                if (name.charAt(0) == 'M' &&
                    name.startsWith("META-INF/services/") && 
                    !entry.isDirectory()) {
                    int byteCount = in.read(bytes, 0, bytes.length);

                    String className = new String(bytes, 0, byteCount, "UTF8");
                    String comment = null;

                    int pos = className.indexOf('#');
                    if (pos >= 0) {
                        comment = className.substring(pos+1).trim();

                        int commentLength = comment.length();
                        int commentStart = 0;
                        while (commentStart < commentLength &&
                               comment.charAt(commentStart) == '#')
                            ++commentStart;
                        while (commentStart < commentLength &&
                               comment.charAt(commentStart) == ' ')
                            ++commentStart;

                        if (commentStart > 0) {
                            commentLength -= commentStart;
                            if (commentLength > 0)
                                comment = comment.substring(commentStart);
                            else
                                comment = "";
                        }

                        if (commentLength == 0)
                            comment = null;

                        className = className.substring(0, pos);
                    }

                    // Most of the time, there is a single service provider
                    // per jar.
                    String[] list2 = new String[j+3];
                    if (j > 0) 
                        System.arraycopy(list, 0, list2, 0, j);
                    list = list2;

                    list[j++] = name.substring(18);
                    list[j++] = className.trim();
                    list[j++] = comment;
                }
            }
        } finally {
            in.close();
        }

        return list;
    }
}

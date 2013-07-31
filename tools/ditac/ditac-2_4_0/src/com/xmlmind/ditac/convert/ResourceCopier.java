/*
 * Copyright (c) 2009-2013 Pixware SARL. All rights reserved.
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
import com.xmlmind.util.FileUtil;
import com.xmlmind.util.URIComponent;
import com.xmlmind.util.URLUtil;
import com.xmlmind.util.Console;
import com.xmlmind.ditac.preprocess.Media;
import com.xmlmind.ditac.preprocess.ResourceHandler;

/**
 * An implementation of ResourceHandler which simply copies 
 * its resource arguments to the directory specified in its parameter string.
 * <p>For example, if {@link #parseParameters} has been invoked 
 * with a "<tt>graphics</tt>" argument, {@link #handleResource
 * handleResource("file:/home/john/doc/img/logo.png", "/tmp", console)} copies
 * <tt>logo.png</tt> to <tt>/tmp/graphics</tt> and returns 
 * "<tt>graphics/logo.png</tt>".
 */
public class ResourceCopier implements ResourceHandler {
    protected Media media;
    protected String resourcePath;

    protected HashMap<URL, String> urlToPath;

    // -----------------------------------------------------------------------

    public ResourceCopier() {
        media = Media.SCREEN;
        urlToPath = new HashMap<URL, String>();
    }

    public void setMedia(Media media) {
        if (media == null) {
            media = Media.SCREEN;
        }
        this.media = media;
    }

    public Media getMedia() {
        return media;
    }

    public void parseParameters(String parameters) {
        if (parameters != null && 
            (parameters = parameters.trim()).length() > 0) {
            resourcePath = parameters;

            if (File.separatorChar != '/' && resourcePath.indexOf('/') >= 0) {
                // It is possible to use '/' as a file separator on all
                // platforms.
                resourcePath = resourcePath.replace('/', File.separatorChar);
            }
        }
    }

    public void reset() {
        urlToPath.clear();
    }

    public String handleResource(URL resourceURL, String resourceType, 
                                 boolean isImage, File outDir, Console console)
        throws Exception {
        if (!checkResource(resourceURL, resourceType, isImage)) {
            // Default processing.
            return null;
        }

        // Check for a duplicate resource reference.
        String path = urlToPath.get(resourceURL);
        if (path != null) {
            return path;
        }

        String baseName = URLUtil.getBaseName(resourceURL);
        if (baseName == null) {
            return null;
        }

        File outFile = null;

        String rootName = FileUtil.setExtension(baseName, null);
        String extension = FileUtil.getExtension(baseName);
        extension = checkExtension(extension, resourceType, isImage);

        // Do no overwrite an existing file.
        for (int i = 0; i < 1000; ++i) {
            String name = joinBaseName(rootName, i, extension);

            path = joinPath(resourcePath, name);

            outFile = new File(outDir, path);
            if (!outFile.isFile()) {
                break;
            }
        }

        // Create the resource (hierarchy of) directory if needed to.
        File resourceDir = outFile.getParentFile();
        if (!resourceDir.isDirectory()) {
            FileUtil.checkedMkdirs(resourceDir);
        }

        copyResource(resourceURL, resourceType, isImage, outFile, console);

        // The expected result is an URL and not a filename.
        if (File.separatorChar != '/' && 
            path.indexOf(File.separatorChar) >= 0) {
            path = path.replace(File.separatorChar, '/');
        }
        path = URIComponent.quoteFullPath(path);

        urlToPath.put(resourceURL, path);
        return path;
    }

    /**
     * Returns <code>true</code> is specified resource is to be copied;
     * <code>false</code> otherwise. 
     * May be overridden by a resource converter.
     */
    protected boolean checkResource(URL resourceURL, String resourceType, 
                                    boolean isImage) {
        // XSL-FO allows to embed images. Image copying not useful.
        return (media != Media.PRINT || !isImage);
    }

    /**
     * Returns specified extension modified or as is. 
     * May be overridden by a resource converter.
     */
    protected String checkExtension(String extension, 
                                    String resourceType, boolean isImage) {
        return extension;
    }

    protected static final String joinBaseName(String rootName, 
                                               int index,
                                               String extension) {
        StringBuilder buffer = new StringBuilder(rootName);
        if (index > 0) {
            buffer.append('-');
            buffer.append(Integer.toString(1+index));
        }
        if (extension != null) {
            buffer.append('.');
            buffer.append(extension);
        }
        return buffer.toString();
    }

    protected static final String joinPath(String resourcePath, 
                                           String baseName) {
        if (resourcePath != null) {
            StringBuilder buffer = new StringBuilder(resourcePath);
            if (!resourcePath.endsWith(File.separator)) {
                buffer.append(File.separatorChar);
            }
            buffer.append(baseName);
            return buffer.toString();
        } else {
            return baseName;
        }
    }

    /**
     * Copy specified resource to specified file, an INFO message 
     * being displayed on specified console. May be overridden by 
     * a resource converter.
     */
    protected void copyResource(URL resourceURL, String resourceType, 
                                boolean isImage, File outFile, Console console) 
        throws Exception {
        if (console != null) {
            console.showMessage(Msg.msg("copyingResource", 
                                        URLUtil.toLabel(resourceURL), outFile),
                                Console.MessageType.INFO);
        }
        FileUtil.copyFile(resourceURL, outFile);
    }
}

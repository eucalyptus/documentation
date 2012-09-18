/*
 * Copyright (c) 2009-2010 Pixware SARL. All rights reserved.
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
import com.xmlmind.ditac.preprocess.ImageHandler;

/**
 * An implementation of ImageHandler which simply copies its image arguments
 * to the directory specified in its parameter string.
 * <p>For example, if {@link #parseParameters} has been invoked 
 * with a "<tt>graphics</tt>" argument, {@link #handleImage
 * handleImage("file:/home/john/doc/img/logo.png", "/tmp", console)} copies
 * <tt>logo.png</tt> to <tt>/tmp/graphics</tt> and returns 
 * "<tt>graphics/logo.png</tt>".
 */
public class ImageCopier implements ImageHandler {
    protected String imagePath;

    protected HashMap<URL, String> urlToPath;

    // -----------------------------------------------------------------------

    public ImageCopier() {
        urlToPath = new HashMap<URL, String>();
    }

    public void parseParameters(String parameters) {
        if (parameters != null && 
            (parameters = parameters.trim()).length() > 0) {
            imagePath = parameters;

            if (File.separatorChar != '/' && imagePath.indexOf('/') >= 0) {
                // It is possible to use '/' as a file separator on all
                // platforms.
                imagePath = imagePath.replace('/', File.separatorChar);
            }
        }
    }

    public void reset() {
        urlToPath.clear();
    }

    public String handleImage(URL imageURL, File outDir, Console console)
        throws Exception {
        // Check for a duplicate image reference.
        String path = urlToPath.get(imageURL);
        if (path != null) {
            return path;
        }

        String baseName = URLUtil.getBaseName(imageURL);
        if (baseName == null) {
            return null;
        }

        File outFile = null;

        String rootName = FileUtil.setExtension(baseName, null);
        String extension = FileUtil.getExtension(baseName);
        extension = checkExtension(extension);

        // Do no overwrite an existing file.
        for (int i = 0; i < 1000; ++i) {
            String name = joinBaseName(rootName, i, extension);

            path = joinPath(imagePath, name);

            outFile = new File(outDir, path);
            if (!outFile.isFile()) {
                break;
            }
        }

        // Create the image (hierarchy of) directory if needed to.
        File imageDir = outFile.getParentFile();
        if (!imageDir.isDirectory()) {
            FileUtil.checkedMkdirs(imageDir);
        }

        copyImage(imageURL, outFile, console);

        // The expected result is an URL and not a filename.
        if (File.separatorChar != '/' && 
            path.indexOf(File.separatorChar) >= 0) {
            path = path.replace(File.separatorChar, '/');
        }
        path = URIComponent.quoteFullPath(path);

        urlToPath.put(imageURL, path);
        return path;
    }

    /**
     * Returns specified extension modified or as is. May be overridden by an
     * image converter.
     */
    protected String checkExtension(String extension) {
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

    protected static final String joinPath(String imagePath, String baseName) {
        if (imagePath != null) {
            StringBuilder buffer = new StringBuilder(imagePath);
            if (!imagePath.endsWith(File.separator)) {
                buffer.append(File.separatorChar);
            }
            buffer.append(baseName);
            return buffer.toString();
        } else {
            return baseName;
        }
    }

    /**
     * Copy specified image to specified file, an INFO message being displayed
     * on specified console. May be overridden by an image converter.
     */
    protected void copyImage(URL imageURL, File outFile, Console console) 
        throws Exception {
        if (console != null) {
            console.showMessage(Msg.msg("copyingImage", 
                                        URLUtil.toLabel(imageURL), outFile),
                                Console.MessageType.INFO);
        }
        FileUtil.copyFile(imageURL, outFile);
    }
}

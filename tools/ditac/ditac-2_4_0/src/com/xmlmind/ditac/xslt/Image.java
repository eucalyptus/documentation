/*
 * Copyright (c) 2009-2011 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.xslt;

import java.io.File;
import java.io.InputStream;
import java.net.URI;
import java.net.URL;
import java.util.Iterator;
import javax.imageio.ImageReader;
import javax.imageio.ImageIO;
import javax.imageio.stream.FileCacheImageInputStream;

/*package*/ final class Image {
    private Image() {}

    public static int[] getSize(String location) {
        try {
            URL url = new URL(location);

            String extension = extension(location);
            if (extension == null) {
                System.err.println("Image filename '" + location + 
                                   "', has no extension");
                return null;
            }

            Iterator<ImageReader> iter = 
                ImageIO.getImageReadersBySuffix(extension);
            if (!iter.hasNext()) {
                System.err.println("'" + extension + 
                                   "', unsupported image extension");
                return null;
            }
            ImageReader reader = iter.next();
            
            InputStream in = url.openStream();
            try {
                FileCacheImageInputStream imageData = 
                    new FileCacheImageInputStream(in, /*tempDir*/ null);
                try {
                    reader.setInput(imageData);

                    int width = reader.getWidth(0);
                    int height = reader.getHeight(0);
                    return new int[] { width, height };
                } finally {
                    imageData.close();
                }
            } finally {
                in.close();
            }
        } catch (Exception e) {
            System.err.println("Cannot determine the size of image '" + 
                               location + "': " + reason(e));
            return null;
        }
    }

    private static final String extension(String path) {
        int pos = path.lastIndexOf('.');
        if (pos < 0 || pos == path.length()-1)
            return null;
        return path.substring(pos+1);
    }

    private static final String reason(Throwable e) {
        String reason = e.getMessage();
        if (reason == null)
            reason = e.getClass().getName();
        return reason;
    }

    public static int getWidth(String location) {
        int[] size = getSize(location);
        return (size == null)? -1 : size[0];
    }

    public static int getHeight(String location) {
        int[] size = getSize(location);
        return (size == null)? -1 : size[1];
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 1) {
            System.err.println(
                "usage: java com.xmlmind.ditac.xslt.Image image_file");
            System.exit(1);
        }

        URI uri = (new File(args[0])).toURI().normalize();
        String location = uri.toASCIIString();
        int[] size = getSize(location);
        if (size != null) {
            System.out.println("The size of image\n" + location + "\nis " + 
                               size[0] + "x" + size[1] + ".");
        }
    }
}

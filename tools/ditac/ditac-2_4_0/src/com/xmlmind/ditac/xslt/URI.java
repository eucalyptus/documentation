/*
 * Copyright (c) 2009-2011 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.xslt;

import java.io.UnsupportedEncodingException;
import java.io.InputStream;
import java.io.FileOutputStream;
import java.io.File;
import java.net.URL;
import java.util.UUID;

/*package*/ final class URI {
    private URI() {}

    public static String decodeURI(String s) {
        return decodeURI(s, "UTF-8");
    }

    private static String decodeURI(String s, String charset) {
        if (s.indexOf('%') < 0)
            return s;

        byte[] srcBytes;
        try {
            srcBytes = s.getBytes(charset);
        } catch (UnsupportedEncodingException shouldNotHappen) {
            shouldNotHappen.printStackTrace();
            return null;
        }

        int srcByteCount = srcBytes.length;
        byte[] dstBytes = new byte[srcByteCount];
        int j = 0;

        for (int i = 0; i < srcByteCount; ++i) {
            int src = srcBytes[i];
            int h1, h2;
            int dst;

            if (src == '%' &&
                i+2 < srcByteCount && 
                (h1 = fromHexDigit(srcBytes[i+1])) >= 0 &&
                (h2 = fromHexDigit(srcBytes[i+2])) >= 0) {
                dst = ((h1 << 4) | h2);
                i += 2;
            } else {
                dst = src;
            }

            dstBytes[j++] = (byte) dst;
        }

        try {
            return new String(dstBytes, 0, j, charset);
        } catch (UnsupportedEncodingException shouldNotHappen) {
            shouldNotHappen.printStackTrace();
            return null;
        }
    }

    private static final int[] fromHexDigit = {
         0,  1,  2,  3,  4,  5,  6,  7,  8,  9, -1, -1, -1, -1, -1, -1,
        -1, 10, 11, 12, 13, 14, 15, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, 10, 11, 12, 13, 14, 15
    };

    private static final int fromHexDigit(int c) {
        if (c < '0' || c > 'f') {
            return -1;
        } else {
            return fromHexDigit[c - '0'];
        }
    }

    // ------------------------------------------------------------------------
    
    public static String userDirectory() {
        String userDirName = System.getProperty("user.dir");
        if (userDirName == null) {
            userDirName = ".";
        }
        File userDir = new File(userDirName);
        return userDir.toURI().toASCIIString();
    }

    // ------------------------------------------------------------------------
    
    public static String uuidURI() {
        return "urn:uuid:" + UUID.randomUUID();
    }

    // ------------------------------------------------------------------------
    
    public static int copyFile(String srcLocation, String dstLocation) {
        /*
        System.out.println("Copying '" + srcLocation + 
                           "' to '" + dstLocation + "'...");
        */

        try {
            java.net.URI srcURI = new java.net.URI(srcLocation);
            java.net.URI dstURI = new java.net.URI(dstLocation);
            if (srcURI.equals(dstURI)) {
                // Nothing to do.
                return 0;
            }

            URL srcURL = srcURI.toURL();
            File dstFile = new File(dstURI);
            int copied = 0;

            InputStream src = srcURL.openStream();
            try {
                FileOutputStream dst = new FileOutputStream(dstFile);
                byte[] buffer = new byte[65535];
                int count;

                try {
                    while ((count = src.read(buffer)) != -1) {
                        dst.write(buffer, 0, count);

                        copied += count;
                    }

                    dst.flush();
                } finally {
                    dst.close();
                }
            } finally {
                src.close();
            }

            /*
            System.out.println("Copied '" + srcLocation + 
                               "' to '" + dstLocation + "': " + 
                               copied + "bytes");
            */
            return copied;
        } catch (Exception e) {
            String reason = e.getClass().getName();
            if (e.getMessage() != null) {
                reason += ": " + e.getMessage();
            }
            System.err.println("Cannot copy '" + srcLocation + 
                               "' to '" + dstLocation + "': " + reason);
            return -1;
        }
    }
}

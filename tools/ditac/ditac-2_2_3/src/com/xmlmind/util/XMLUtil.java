/*
 * Copyright (c) 2009-2011 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of several XMLmind projects.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.util;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.io.File;
import java.io.InputStream;
import java.io.FileInputStream;
import java.io.PushbackInputStream;
import java.io.Reader;
import java.io.InputStreamReader;
import java.net.URLConnection;
import java.net.URL;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import org.xml.sax.SAXException;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

/**
 * A collection of utility functions (static methods) related to XML.
 */
public final class XMLUtil {
    private XMLUtil() {}

    /**
     * Equivalent to {@link #newSAXParser(boolean, boolean, boolean) 
     * newSAXParser(true, false, false)}.
     */
    public static SAXParser newSAXParser()
        throws ParserConfigurationException, SAXException {
        return newSAXParser(true, false, false);
    }

    /**
     * Convenience method: creates and returns a SAXParser.
     * 
     * @param namespaceAware specifies whether the parser produced 
     * by this code will provide support for XML namespaces
     * @param validating specifies whether the parser produced by 
     * this code will validate documents against their DTD
     * @param xIncludeAware specifies whether the parser produced by 
     * this code will process XIncludes
     * @return newly created SAXParser
     * @exception ParserConfigurationException if a parser cannot be created 
     * which satisfies the requested configuration
     * @exception SAXException for SAX errors
     */
    public static SAXParser newSAXParser(boolean namespaceAware, 
                                         boolean validating, 
                                         boolean xIncludeAware)
        throws ParserConfigurationException, SAXException {
        SAXParserFactory factory = SAXParserFactory.newInstance();
        factory.setNamespaceAware(namespaceAware);
        factory.setValidating(validating);
        factory.setXIncludeAware(xIncludeAware);

        // For Xerces which otherwise, does not support "x-MacRoman".
        try {
            factory.setFeature(
                "http://apache.org/xml/features/allow-java-encodings", true);
        } catch (Exception ignored) {}

        return factory.newSAXParser();
    }

    // -----------------------------------------------------------------------

    /**
     * Equivalent to {@link #loadText(URL, String[])
     * loadText(FileUtil.fileToURL(file), encoding)}.
     */
    public static String loadText(File file, String[] encoding) 
        throws IOException {
        return loadText(FileUtil.fileToURL(file), encoding);
    }

    /**
     * Loads the contents of specified text file. 
     * <p>Unlike {@link URLUtil#loadString}, this method implements 
     * the detection of the encoding.
     * <p>Note that the detection of the encoding always works 
     * because it uses a fallback value.
     *
     * @param url the location of the text file
     * @param encoding the detected encoding is copied there.
     * May be <code>null</code>.
     * @return the contents of the text file
     * @exception IOException if there is an I/O problem
     */
    public static String loadText(URL url, String[] encoding) 
        throws IOException {
        URLConnection connection = URLUtil.openConnectionNoCache(url);

        String fallbackEncoding = null;
        // Note that a contentType is available even for a file:// connection.
        String contentType = connection.getContentType();
        if (contentType != null) {
            fallbackEncoding = URLUtil.contentTypeToCharset(contentType);
        }
        if (fallbackEncoding == null && URLUtil.isFileURL(url)) {
            fallbackEncoding = SystemUtil.defaultEncoding();
        }

        String loaded = null;

        InputStream in = connection.getInputStream();
        try {
            loaded = loadText(in, fallbackEncoding, encoding);
        } finally {
            in.close();
        }

        return loaded;
    }

    /**
     * Loads the contents of specified text source. 
     * <p>This method implements the detection of the encoding.
     * <p>Note that the detection of the encoding always works 
     * because it uses a fallback value.
     *
     * @param in the text source
     * @param fallbackEncoding the fallback encoding
     * May be <code>null</code>.
     * @param encoding the detected encoding is copied there.
     * May be <code>null</code>.
     * @return the contents of the text source
     * @exception IOException if there is an I/O problem
     * @see #loadText(URL, String[])
     */
    public static String loadText(InputStream in, String fallbackEncoding,
                                  String[] encoding) 
        throws IOException {
        Reader src = createReader(in, fallbackEncoding, encoding);
        return loadChars(src);
    }

    /**
     * Load the characters contained in specified source.
     * 
     * @param in the character source
     * @return the contents of the character source
     * @exception IOException if there is an I/O problem
     */
    public static String loadChars(Reader in) 
        throws IOException {
        StringBuilder buffer = new StringBuilder();
        char[] chars = new char[65536];
        int count;

        while ((count = in.read(chars, 0, chars.length)) != -1) {
            if (count > 0) {
                buffer.append(chars, 0, count);
            }
        }

        return buffer.toString();
    }

    /**
     * Creates a reader allowing to read the contents of specified text source.
     * <p>This method implements the detection of the encoding.
     * <p>Note that the detection of the encoding always works 
     * because it uses a fallback value.
     *
     * @param in the text source
     * @param encoding the detected encoding is copied there.
     * May be <code>null</code>.
     * @return a reader allowing to read the contents of the text source.
     * This reader will automatically skip the BOM if any.
     * @exception IOException if there is an I/O problem
     */
    public static Reader createReader(InputStream in, String fallbackEncoding, 
                                      String[] encoding) 
        throws IOException {
        byte[] bytes = new byte[1024];
        int byteCount = -1;

        PushbackInputStream in2 = new PushbackInputStream(in, bytes.length);
        try {
            int count = in2.read(bytes, 0, bytes.length);
            if (count > 0) {
                in2.unread(bytes, 0, count);
            }
            byteCount = count;
        } catch (IOException ignored) {}

        String charset = null;

        if (byteCount > 0) {
            if (byteCount >= 2) {
                // Use BOM ---

                int b0 = (bytes[0] & 0xFF);
                int b1 = (bytes[1] & 0xFF);

                switch ((b0 << 8) | b1) {
                case 0xFEFF:
                    charset = "UTF-16BE";
                    // We don't want to read the BOM.
                    in2.skip(2);
                    break;
                case 0xFFFE:
                    charset = "UTF-16LE";
                    in2.skip(2);
                    break;
                case 0xEFBB:
                    if (byteCount >= 3 && (bytes[2] & 0xFF) == 0xBF) {
                        charset = "UTF-8";
                        in2.skip(3);
                    }
                    break;
                }
            }

            if (charset == null) {
                // Unsupported characters are replaced by U+FFFD.
                String text = new String(bytes, 0, byteCount, "US-ASCII");

                if (text.startsWith("<?xml")) {
                    Pattern pattern = 
                        Pattern.compile("encoding\\s*=\\s*['\"]([^'\"]+)");
                    Matcher matcher = pattern.matcher(text);
                    if (matcher.find()) {
                        charset = matcher.group(1);
                    } else {
                        charset = "UTF-8";
                    }
                }
            }
        }

        if (charset == null) {
            charset = fallbackEncoding;
            if (charset == null) {
                charset = "UTF-8";
            }
        }

        if (encoding != null) {
            encoding[0] = charset;
        }
        return new InputStreamReader(in2, charset);
    }

    /*TEST_LOAD_TEXT
    public static void main(String[] args) throws IOException {
        if (args.length != 1) {
            System.err.println("usage: com.xmlmind.util.XMLUtil text_file");
            System.exit(1);
        }

        File textFile = new File(args[0]);

        String[] encoding = new String[1];
        String text = loadText(textFile, encoding);
        System.out.println(textFile + ": " + Integer.toString(text.length()) + 
                           "chars, encoding=" + encoding[0]);
        System.err.println("{" + text + "}");
    }
    TEST_LOAD_TEXT*/
}

/*
 * Copyright (c) 2002-2008 Pixware. 
 *
 * Author: Hussein Shafie
 *
 * This file is part of several XMLmind projects.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.util;

/**
 * Base-16 encoder/decoder.
 */
public final class Base16 {
    private Base16() {}

    private static final char[] toDigit = ("0123456789ABCDEF").toCharArray();

    private static final int[] fromDigit = {
         0,  1,  2,  3,  4,  5,  6,  7,  8,  9, -1, -1, -1, -1, -1, -1,
        -1, 10, 11, 12, 13, 14, 15, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, 10, 11, 12, 13, 14, 15
    };

    /**
     * Decodes base-16 encoded string.
     * 
     * @param s base-16 string to be decoded
     * @return decoded binary data or <code>null</code> if string cannot be
     * decoded.
     */
    public static byte[] decode(String s) {
        return decode(s, Integer.MAX_VALUE);
    }

    /**
     * Same as {@link #decode(String)}, except that argument limt allows to
     * limit the number of decoded bytes. This is useful, for example, to
     * detect the format of a base-16 encoded image based on its magic string.
     */
    public static byte[] decode(String s, int limit) {
        // Note that a zero-length hex string is valid.
        int length = s.length();
        if ((length % 2) != 0) 
            return null;

        byte[] b = new byte[length/2];
        int j = 0;

        for (int i = 0; i < length; i += 2) {
            int c1 = s.charAt(i);
            int c2 = s.charAt(i+1);
            int value1;
            int value2;

            if (c1 < '0' || c1 > 'f' || (value1 = fromDigit[c1 - '0']) < 0) 
                return null;

            if (c2 < '0' || c2 > 'f' || (value2 = fromDigit[c2 - '0']) < 0)
                return null;

            b[j++] = (byte) (((value1 & 0xF) << 4) | (value2 & 0xF));
            if (j >= limit)
                break;
        }

        if (j != b.length) {
            byte[] b2 = new byte[j];
            System.arraycopy(b, 0, b2, 0, j);
            b = b2;
        }

        return b;
    }

    /**
     * Encodes binary data to base-16.
     * 
     * @param b binary data to be encoded
     * @return base-16 encoded string
     */
    public static String encode(byte[] b) {
        char[] chars = new char[2*b.length];
        int j = 0;

        for (int i = 0; i < b.length; ++i) {
            byte bits = b[i];

            chars[j++] = toDigit[((bits >>> 4) & 0xF)];
            chars[j++] = toDigit[(bits & 0xF)];
        }

        return new String(chars);
    }

    // -----------------------------------------------------------------------

    /*TEST_BASE16
    public static void main(String[] args) throws Exception {
        if (args.length != 3 ||
            !("encode".equals(args[0]) || "decode".equals(args[0]))) {
            System.err.println(
                "usage: java com.xmlmind.util.Base16" + 
                " encode|decode source_file destination_file");
            System.exit(1);
        }

        if ("decode".equals(args[0])) {
            String string = FileUtil.loadString(new java.io.File(args[1]));
            byte[] bytes = Base16.decode(string);
            FileUtil.saveBytes(bytes, new java.io.File(args[2]));
        } else {
            byte[] bytes = FileUtil.loadBytes(new java.io.File(args[1]));
            String string = Base16.encode(bytes);
            FileUtil.saveString(string, new java.io.File(args[2]));
        }
    }
    TEST_BASE16*/
}

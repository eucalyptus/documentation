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
 * A collection of utility functions (static methods) operating on
 * CharSequences. Not documented here because these utilities are supposed to
 * behave exactly like the corresponding methods of class java.lang.String.
 * 
 * @see CharSequence
 */
public final class CharSequenceUtil {
    private CharSequenceUtil() {}

    public static String substring(CharSequence chars, int begin) {
        return CharSequenceUtil.substring(chars, begin, chars.length());
    }

    public static String substring(CharSequence chars, int begin, int end) {
        char[] text = new char[end - begin];

        int j = 0;
        for (int i = begin; i < end; ++i)
            text[j++] = chars.charAt(i);

        return new String(text);
    }

    // -----------------------------------------------------------------------

    public static int indexOf(CharSequence chars, String searched) {
        return indexOf(chars, searched, 0, false);
    }

    public static int indexOf(CharSequence chars, String searched, int from) {
        return indexOf(chars, searched, from, false);
    }

    public static int indexOf(CharSequence chars, String searched, 
                              int from, boolean ignoreCase) {
        int charCount = chars.length();
        int searchedLength = searched.length();

        int max = charCount - searchedLength;
        if (from >= charCount) {
            if (charCount == 0 && from == 0 && searchedLength == 0)
                return 0;
            return -1;
        }
        if (from < 0)
            from = 0;
        if (searchedLength == 0)
            return from;

        char first = charAt(searched, 0, ignoreCase);
        int i = from;

        loop: for (;;) {
            while (i <= max && charAt(chars, i, ignoreCase) != first)
                i++;
            if (i > max)
                return -1;

            int j = i + 1;
            int end = j + searchedLength - 1;
            int k = 1;
            while (j < end) {
                if (charAt(chars, j++, ignoreCase) != 
                    charAt(searched, k++, ignoreCase)) {
                    i++;
                    continue loop;
                }
            }
            return i;
        }
    }

    private static final char charAt(String chars, int index, 
                                     boolean ignoreCase) {
        return (ignoreCase? 
                Character.toLowerCase(chars.charAt(index)) : 
                chars.charAt(index));
    }

    private static final char charAt(CharSequence chars, int index, 
                                     boolean ignoreCase) {
        return (ignoreCase? 
                Character.toLowerCase(chars.charAt(index)) : 
                chars.charAt(index));
    }

    // -----------------------------------------------------------------------

    public static int lastIndexOf(CharSequence chars, String searched) {
        return lastIndexOf(chars, searched, chars.length(), false);
    }

    public static int lastIndexOf(CharSequence chars, String searched, 
                                  int from) {
        return lastIndexOf(chars, searched, from, false);
    }

    public static int lastIndexOf(CharSequence chars, String searched, 
                                  int from, boolean ignoreCase) {
        if (from < 0)
            return -1;

        int charCount = chars.length();
        int searchedLength = searched.length();

        int rightIndex = charCount - searchedLength;
        if (from > rightIndex)
            from = rightIndex;
        if (searchedLength == 0)
            return from;

        int searchedLast = searchedLength - 1;
        char searchedLastChar = charAt(searched, searchedLast, ignoreCase);
        int min = searchedLast;
        int i = from + searchedLast;

        loop: for (;;) {
            while (i >= min && 
                   charAt(chars, i, ignoreCase) != searchedLastChar)
                i--;
            if (i < min)
                return -1;

            int j = i - 1;
            int start = j - searchedLast;
            int k = searchedLast - 1;

            while (j > start) {
                if (charAt(chars, j--, ignoreCase) != 
                    charAt(searched, k--, ignoreCase)) {
                    i--;
                    continue loop;
                }
            }

            return start + 1;
        }
    }
}

/*
 * Copyright (c) 2002-2012 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of several XMLmind projects.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.util;

/**
 * A collection of utility functions (static methods) operating on lists of
 * Strings.
 * <p>What is called a list of Strings here is simply an array of Strings.
 * Such array may not contain <code>null</code> elements.
 */
public final class StringList {
    private StringList() {}

    /**
     * A ready-to-use empty list of Strings.
     */
    public static final String[] EMPTY_LIST = new String[0];

    /**
     * Searches String <code>string</code> within list <code>strings</code>.
     * 
     * @param strings the list to be searched
     * @param string the String to search for
     * @return the index of the searched string within list or -1 if not found
     */
    public static int indexOf(String[] strings, String string) {
        final int stringCount = strings.length;
        for (int i = 0; i < stringCount; ++i) {
            // string may be null, strings[i] cannot.
            if (strings[i].equals(string)) {
                return i;
            }
        }
        return -1;
    }

    /**
     * Tests if list <code>strings</code> contains String <code>string</code>.
     * 
     * @param strings the list to be searched
     * @param string the String to search for
     * @return <code>true</code> the string is found and <code>false</code>
     * otherwise
     */
    public static boolean contains(String[] strings, String string) {
        final int stringCount = strings.length;
        for (int i = 0; i < stringCount; ++i) {
            // string may be null, strings[i] cannot.
            if (strings[i].equals(string)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Same as {@link #contains} but string comparison is case-insensitive.
     */
    public static boolean containsIgnoreCase(String[] strings, String string) {
        final int stringCount = strings.length;
        for (int i = 0; i < stringCount; ++i) {
            if (strings[i].equalsIgnoreCase(string)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Inserts a String inside a list of Strings.
     * 
     * @param strings the list where a String is to be inserted
     * @param string the String to insert
     * @param index the insertion index
     * @return a list containing all the items of list <code>strings</code>
     * plus String <code>string</code> inserted at position <code>index</code>
     */
    public static String[] insertAt(String[] strings, String string, 
                                    int index) {
        final int stringCount = strings.length;
        String[] newStrings = new String[stringCount+1];

        if (index > 0) {
            System.arraycopy(strings, 0, newStrings, 0, index);
        }

        int tail = stringCount - index;
        if (tail > 0) {
            System.arraycopy(strings, index, newStrings, index+1, tail);
        }

        newStrings[index] = string;

        return newStrings;
    }

    /**
     * Inserts a String as first item of a list of Strings.
     * 
     * @param strings the list where a String is to be inserted
     * @param string the String to insert
     * @return a list containing all the items of list <code>strings</code>
     * plus String <code>string</code> inserted at its beginning
     */
    public static String[] prepend(String[] strings, String string) {
        final int stringCount = strings.length;
        String[] newStrings = new String[stringCount+1];

        newStrings[0] = string;
        System.arraycopy(strings, 0, newStrings, 1, stringCount);

        return newStrings;
    }

    /**
     * Inserts a String as last item of a list of Strings.
     * 
     * @param strings the list where a String is to be inserted
     * @param string the String to insert
     * @return a list containing all the items of list <code>strings</code>
     * plus String <code>string</code> inserted at its end
     */
    public static String[] append(String[] strings, String string) {
        final int stringCount = strings.length;
        String[] newStrings = new String[stringCount+1];

        System.arraycopy(strings, 0, newStrings, 0, stringCount);
        newStrings[stringCount] = string;

        return newStrings;
    }

    /**
     * Removes a String from a list of Strings.
     * 
     * @param strings the list where a String is to be removed
     * @param string the String to remove
     * @return a list containing all the items of list <code>strings</code>
     * less String <code>string</code> if such String is contained in the
     * list; the original list otherwise
     */
    public static String[] remove(String[] strings, String string) {
        int index = indexOf(strings, string);
        if (index < 0) {
            return strings;
        } else {
            return removeAt(strings, index);
        }
    }

    /**
     * Removes an item specified by its position from a list of Strings.
     * 
     * @param strings the list where an item is to be removed
     * @param index the position of the item to remove
     * @return a list containing all the items of list <code>strings</code>
     * less the item at position <code>index</code>
     */
    public static String[] removeAt(String[] strings, int index) {
        String string = strings[index];
        final int stringCount = strings.length;
        String[] newStrings = new String[stringCount-1];

        if (index > 0) {
            System.arraycopy(strings, 0, newStrings, 0, index);
        }

        int first = index + 1;
        int tail = stringCount - first;
        if (tail > 0) {
            System.arraycopy(strings, first, newStrings, index, tail);
        }

        return newStrings;
    }
}

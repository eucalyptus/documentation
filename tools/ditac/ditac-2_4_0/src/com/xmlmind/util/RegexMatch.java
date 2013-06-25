/*
 * Copyright (c) 2002-2008 Pixware. 
 *
 * Author: Hussein Shafie
 *
 * This file is part of several XMLmind projects.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.util;

import java.util.regex.Pattern;
import java.util.regex.Matcher;

/**
 * Input subsequence captured by the given group during the previous match
 * operation. See <code>java.util.regex.Matcher</code>.
 * <p>Example of use:
 * <pre> Pattern p = Pattern.compile(regexp);
 * Matcher matcher = p.matcher(string);
 * if (matcher.matches()) {
 *     RegexMatch[] match = RegexMatch.getAll(matcher);
 *     for (int j = 0; j &lt; match.length; ++j)
 *          System.out.println("\t$" + j + "='" + match[j].text + "'");
 * }</pre>
 */
public final class RegexMatch {
    /**
     * Index of the start of the input subsequence.
     */
    public final int startIndex;

    /**
     * Index of the end of the input subsequence.
     */
    public final int endIndex;

    /**
     * Text contained in the input subsequence.
     */
    public final String text;

    /**
     * Constructor.
     * 
     * @param startIndex index of the start of the input subsequence
     * @param endIndex index of the end of the input subsequence
     * @param text text contained in the input subsequence
     */
    public RegexMatch(int startIndex, int endIndex, String text) {
        this.startIndex = startIndex; 
        this.endIndex = endIndex; 
        this.text = text; 
    }

    /**
     * Returns all input subsequence captured during last match operation
     * performed by specified matcher.
     * <p>Returned array is empty if matcher has never been used or if input
     * sequence does not match pattern.
     */
    public static RegexMatch[] getAll(Matcher matcher) {
        RegexMatch[] list = new RegexMatch[1+matcher.groupCount()];
        int count = 0;

        for (int i = 0; i < list.length; ++i) {
            int start = matcher.start(i);
            if (start < 0)
                continue;

            list[count++] = new RegexMatch(start, matcher.end(i), 
                                           matcher.group(i));
        }

        if (count != list.length) {
            RegexMatch[] list2 = new RegexMatch[count];
            System.arraycopy(list, 0, list2, 0, count);
            list = list2;
        }

        return list;
    }

    /**
     * Returns {@link #text}.
     */
    public String toString() {
        return text;
    }

    // -----------------------------------------------------------------------

    /*TEST_REGEX_MATCH
    public static void main(String[] args) throws Exception {
        if (args.length < 1) {
            System.err.println(
                "usage: java com.xmlmind.xmledit.util.RegexMatch" +
                " pattern string ... string");
            System.exit(1);
        }

        Pattern p = Pattern.compile(args[0]);
        Matcher matcher = p.matcher("dummy");
        
        for (int i = 1; i < args.length; ++i) {
            String arg = args[i];

            matcher.reset(arg);
            if (matcher.matches()) {
                System.out.println("'" + arg + "' matches:");

                RegexMatch[] match = RegexMatch.getAll(matcher);
                for (int j = 0; j < match.length; ++j)
                    System.out.println("\t$" + j + "='" + 
                                       match[j].text + "'");
            } else {
                System.out.println("'" + arg + "' DOES NOT MATCH.");
            }
        }
    }
    TEST_REGEX_MATCH*/
}

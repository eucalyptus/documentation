/*
 * Copyright (c) 2002-2011 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of several XMLmind projects.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.util;

import java.util.ArrayList;
import java.util.regex.PatternSyntaxException;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

/**
 * Matches a <i>glob pattern</i> (as used by Unix shells) against an input
 * string.
 * <p>This class is <em>not</em> thread-safe.
 */
public final class GlobMatcher {
    /**
     * The string representation of the glob pattern.
     */
    public final String globPattern;

    /**
     * The underlying <code>java.util.regex.Matcher</code>.
     */
    public final Matcher matcher;

    // -----------------------------------------------------------------------

    /**
     * Constructs a glob pattern matcher.
     * 
     * @param globPattern the glob pattern
     * @exception PatternSyntaxException if specified glob pattern cannot be
     * compiled into a <code>java.util.regex.Pattern</code>
     */
    public GlobMatcher(String globPattern)
        throws PatternSyntaxException {
        this.globPattern = globPattern;

        Pattern pattern = Pattern.compile(globToRegexp(globPattern));
        matcher = pattern.matcher("dummy");
    }

    private static final String globToRegexp(String globPattern) {
        StringBuilder buffer = new StringBuilder();

        int length = globPattern.length();
        for (int i = 0; i < length; ++i) {
            char c = globPattern.charAt(i);

            switch (c) {
            case '*':
                buffer.append(".*");
                break;

            case '?':
                buffer.append('.');
                break;

            case '[':
                {
                    int j = findClosingSquareBracket(globPattern, i);
                    if (j <= i+1) {
                        // Something like "[" or "[]" has no special meaning.
                        buffer.append("\\[");
                    } else {
                        buffer.append(globPattern.substring(i, j+1));
                        i = j;
                    }
                }
                break;

            case '{':
                {
                    ArrayList<String> parts = new ArrayList<String>();
                    int j = splitCurlyBraceGroup(globPattern, i, parts);
                    int partCount = parts.size();
                    if (j <= i+1 || partCount == 0) {
                        // Something like "{", "{}", "{,}", or "{,,}" has no
                        // special meaning.
                        buffer.append("\\{");
                    } else {
                        if (partCount == 1) {
                            // Not very useful but why not?
                            buffer.append('(');
                            buffer.append(globToRegexp(parts.get(0)));
                            buffer.append(')');
                        } else {
                            buffer.append('(');
                            for (int k = 0; k < partCount; ++k) {
                                if (k > 0) {
                                    buffer.append('|');
                                }
                                buffer.append('(');
                                buffer.append(globToRegexp(parts.get(k)));
                                buffer.append(')');
                            }
                            buffer.append(')');
                        }
                        i = j;
                    }
                }
                break;

            case '\\':
                // Escaped char: add as is (that is, escaped).
                buffer.append(c);
                if (i+1 < length) {
                    buffer.append(globPattern.charAt(++i));
                }
                break;

            default:
                if (!Character.isLetterOrDigit(c)) {
                    // Escape special chars such as '(' or '|'.
                    buffer.append('\\');
                }
                buffer.append(c);
            }
        }

        return buffer.toString();
    }

    private static int findClosingSquareBracket(String s, int offset) {
        int nesting = 0;
        char prevC = '\0';
        int length = s.length();

        for (int i = offset; i < length; ++i) {
            char c = s.charAt(i);

            switch (c) {
            case '[':
                if (prevC != '\\') {
                    ++nesting;
                }
                break;
            case ']':
                if (prevC != '\\' &&
                    // Something like "[]a-b]" is equivalent to "[\]a-b]".
                    i != offset+1) {
                    --nesting;
                }

                if (nesting == 0) {
                    return i;
                }
                break;
            }

            prevC = c;
        }

        return -1;
    }

    private static int splitCurlyBraceGroup(String s, int offset,
                                            ArrayList<String> parts) {
        int groupOffset = offset;
        int nesting = 0;
        char prevC = '\0';
        int length = s.length();

        for (int i = offset; i < length; ++i) {
            char c = s.charAt(i);

            switch (c) {
            case '{':
                if (prevC != '\\') {
                    ++nesting;
                }
                break;
            case '}':
                if (prevC != '\\') {
                    --nesting;
                }

                if (nesting == 0) {
                    String part = s.substring(groupOffset+1, i);
                    if (part.length() > 0) {
                        parts.add(part);
                    }

                    return i;
                }
                break;
            case ',':
                if (nesting == 1) {
                    String part = s.substring(groupOffset+1, i);
                    if (part.length() > 0) {
                        parts.add(part);
                    }

                    groupOffset = i;
                }
                break;
            }

            prevC = c;
        }

        return -1;
    }

    /**
     * Matches this glob pattern against specified string.
     * 
     * @param string string to be matched against this glob pattern
     * @return <code>true</code> if specified string (in its entirety) matches
     * this glob pattern; <code>false</code> otherwise
     */
    public boolean matches(String string) {
        matcher.reset(string);
        return matcher.matches();
    }

    @Override
    public int hashCode() {
        return globPattern.hashCode();
    }

    @Override
    public boolean equals(Object other) {
        if (other == null || !(other instanceof GlobMatcher)) {
            return false;
        }
        return globPattern.equals(((GlobMatcher) other).globPattern);
    }

    @Override
    public String toString() {
        return globPattern;
    }

    // -----------------------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------------------

    /**
     * Convenience method: creates a matcher for specified pattern, but unlike
     * the constructor, this method does not raise an exception if this fails.
     * Instead, this method returns <code>null</code>.
     */
    public static GlobMatcher create(String globPattern) {
        GlobMatcher globMatcher = null;
        try {
            globMatcher = new GlobMatcher(globPattern);
        } catch (PatternSyntaxException ignored) {}
        return globMatcher;
    }

    /**
     * Convenience method: returns <code>true</code> if specified string
     * contains a special character ('<tt>?</tt>', '<tt>*</tt>', '<tt>[</tt>',
     * '<tt>{</tt>'); returns <code>false</code> otherwise. If
     * <tt>includingTilde</tt> is true, then '<tt>~</tt>' must also be
     * considered as being a special character.
     */
    public static boolean containsGlobChar(String string, 
                                           boolean includingTilde) {
        int length = string.length();
        for (int i = 0; i < length; ++i) {
            switch (string.charAt(i)) {
            case '?': case '*': case '[': case '{': 
                return true;
            case '~':
                if (includingTilde) {
                    return true;
                }
                break;
            }
        }
        return false;
    }

    // -----------------------------------------------------------------------

    /*TEST_GLOB
    public static void main(String[] args) {
        if (args.length < 1) {
            System.err.println(
                "usage: java com.xmlmind.util.GlobMatcher" +
                " pattern string ... string");
            System.exit(1);
        }

        GlobMatcher matcher = GlobMatcher.create(args[0]);
        if (matcher == null) {
            System.err.println("cannot translate '" + args[0] + 
                               "' to a regexp pattern");
            System.exit(2);
        }
        System.out.println("glob pattern='" + args[0] + "'");
        System.out.println("regexp pattern='" + 
                           matcher.matcher.pattern().pattern() + "'");

        for (int i = 1; i < args.length; ++i) {
            String arg = args[i];
            System.out.print("\t'");
            System.out.print(arg);
            if (matcher.matches(arg)) {
                System.out.println("' MATCHES");
            } else {
                System.out.println("' doesn't match");
            }
        }
    }
    TEST_GLOB*/
}

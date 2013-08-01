/*
 * Copyright (c) 2002-2009 Pixware. 
 *
 * Author: Hussein Shafie
 *
 * This file is part of several XMLmind projects.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.util;

import java.util.StringTokenizer;
import java.util.regex.PatternSyntaxException;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

/**
 * Structured version numbers similar to those used for the Java<sup>TM</sup>
 * runtime (example: 1.5.0_06).
 */
public final class VersionNumber implements Comparable<VersionNumber> {
    /**
     * Type of the release: alpha, beta or patch.
     */
    public enum LevelType {
        /**
         * Alpha release.
         */
        ALPHA,

        /**
         * Beta release.
         */
        BETA,

        /**
         * Patch release.
         */
        PATCH;

        public String toString() {
            switch (ordinal()) {
            case 0:
                return "alpha";
            case 1:
                return "beta";
            case 2:
                return "patch";
            default:
                return "???";
            }
        }
    }

    /**
     * Major version number. Example: 1 in 1.5.0_06.
     */
    public /*read-only*/ int major;

    /**
     * Minor version number. Example: 5 in 1.5.0_06.
     */
    public /*read-only*/ int minor;

    /**
     * Micro version number. Example: 0 in 1.5.0_06.
     */
    public /*read-only*/ int micro;

    /**
     * Type of the release: alpha, beta or patch.
     */
    public /*read-only*/ LevelType levelType;

    /**
     * Alpha, beta or patch level. Example: 6 in 1.5.0_06.
     */
    public /*read-only*/ int level;

    /**
     * Minimal version number: 0.0.0-alpha00.
     */
    public static final VersionNumber MIN_VERSION_NUMBER = new VersionNumber();

    // -----------------------------------------------------------------------

    /**
     * Equivalent to {@link #fromString(String, boolean) fromString(s, false)}.
     */
    public static VersionNumber fromString(String s) {
        return fromString(s, false);
    }

    /**
     * Parses specified string as a version number.
     * 
     * @param s string to be parsed
     * @param lenient if <code>true</code>, any string starting with 
     * "<tt>\d+(\.\d+)?(\.\d+)?(_\d+)?</tt>" will be successfully parsed.
     * @return parsed version number or <code>null</code> if it cannot be
     * parsed.
     */
    public static VersionNumber fromString(String s, boolean lenient) {
        if (lenient) {
            s = s.trim();

            try {
                Pattern p = 
                    Pattern.compile("(\\d+)(\\.\\d+)?(\\.\\d+)?(\\_\\d+)?.*");

                Matcher matcher = p.matcher(s);
                if (matcher.matches()) {
                    RegexMatch[] match = RegexMatch.getAll(matcher);
                    if (match.length > 1) {
                        // First match is the matched subsequence.

                        StringBuilder buffer = new StringBuilder();
                        for (int i = 1; i < match.length; ++i) {
                            buffer.append(match[i].text);
                        }

                        s = buffer.toString();
                    }
                }
            } catch (PatternSyntaxException cannotHappen) {
                cannotHappen.printStackTrace();
            }
        }

        VersionNumber version = new VersionNumber();
        try {
            parse(s, version);
        } catch (IllegalArgumentException ignored) {
            version = null;
        }
        return version;
    }

    /**
     * Parses specified string and returns the result in the specified version
     * number object.
     * 
     * @param s string to be parsed
     * @param version the parsed version number is stored in this object
     * @exception IllegalArgumentException if <tt>s</tt> cannot be parsed
     */
    public static void parse(String s, VersionNumber version) 
        throws IllegalArgumentException {
        StringTokenizer tokens = new StringTokenizer(s, "._-", true);
        if (!tokens.hasMoreTokens()) {
            throw new IllegalArgumentException("empty specification");
        }
        String token = tokens.nextToken();
        int major = parseNumber(token, 0, 999, -1);
        if (major < 0) {
            throw new IllegalArgumentException(
                "invalid major '" + token + "'");
        }
            
        int minor = 0;
        int micro = 0;
        LevelType levelType = LevelType.PATCH;
        int level = 0;

        if (tokens.hasMoreTokens()) {
            token = tokens.nextToken();
            if (!".".equals(token)) {
                throw new IllegalArgumentException(
                    "expected '.', found '" + token + "'");
            }

            if (!tokens.hasMoreTokens()) {
                throw new IllegalArgumentException(
                    "expected a number after '.'");
            }
            token = tokens.nextToken();
            minor = parseNumber(token, 0, 999, -1);
            if (minor < 0) {
                throw new IllegalArgumentException(
                    "invalid minor '" + token + "'");
            }
            
            if (tokens.hasMoreTokens()) {
                token = tokens.nextToken();
                if (!".".equals(token)) {
                    throw new IllegalArgumentException(
                        "expected '.', found '" + token + "'");
                }

                if (!tokens.hasMoreTokens()) {
                    throw new IllegalArgumentException(
                        "expected a number after '.'");
                }
                token = tokens.nextToken();
                micro = parseNumber(token, 0, 999, -1);
                if (micro < 0) {
                    throw new IllegalArgumentException(
                        "invalid micro '" + token + "'");
                }

                if (tokens.hasMoreTokens()) {
                    token = tokens.nextToken();

                    boolean expectPatch;
                    if ("_".equals(token)) {
                        expectPatch = true;
                    } else if ("-".equals(token)) {
                        expectPatch = false;
                    } else {
                        throw new IllegalArgumentException(
                            "expected '_' or '-', found '" + token + "'");
                    }

                    if (!tokens.hasMoreTokens()) {
                        if (expectPatch)
                            throw new IllegalArgumentException(
                                "expected a number after '_'");
                        else
                            throw new IllegalArgumentException(
                                "expected 'alpha' or 'beta' after '-'");
                    }
                    token = tokens.nextToken();
                    if (expectPatch) {
                        levelType = LevelType.PATCH;
                    } else {
                        if (token.startsWith("beta")) {
                            levelType = LevelType.BETA;
                            token = token.substring(4);
                        } else if (token.startsWith("alpha")) {
                            levelType = LevelType.ALPHA;
                            token = token.substring(5);
                        } else {
                            throw new IllegalArgumentException(
                                "expected 'alpha' or 'beta' after '-'");
                        }
                    }
                    level = parseNumber(token, 0, 999, -1);
                    if (level < 0) {
                        throw new IllegalArgumentException(
                            "invalid " + levelType + " level '" + token + "'");
                    }
                }
            }
        }

        version.major = major;
        version.minor = minor;
        version.micro = micro;
        version.levelType = levelType;
        version.level = level;
    }

    private static final int parseNumber(String s, int min, int max,
                                         int fallback) {
        int num;
        try {
            num = Integer.parseInt(s);
        } catch (NumberFormatException e) {
            return fallback;
        }
        if (num < min || num > max)
            return fallback;
        else
            return num;
    }


    /**
     * Constructs a minimal version number: 0.0.0-alpha00.
     * 
     * @see #MIN_VERSION_NUMBER
     */
    public VersionNumber() {
        this(0, 0, 0, LevelType.ALPHA, 0);
    }

    /**
     * Constructs version number <i>major</i>.<i>minor</i>.<i>micro</i>.
     * Example: 1.1.2.
     */
    public VersionNumber(int major, int minor, int micro) {
        this(major, minor, micro, LevelType.PATCH, 0);
    }

    /**
     * Constructs version number 
     * <i>major</i>.<i>minor</i>.<i>micro</i>_<i>patch</i>.
     * Example: 3.1.0_01.
     */
    public VersionNumber(int major, int minor, int micro, int patch) {
        this(major, minor, micro, LevelType.PATCH, patch);
    }

    /**
     * Constructs version number <i>major</i>.<i>minor</i>.<i>micro</i> 
     * (<b>-alpha</b>|<b>-beta</b>|<b>_</b>)<i>level</i>.
     * Example: 3.1.0-beta02.
     */
    public VersionNumber(int major, int minor, int micro, 
                         LevelType levelType, int level) {
        if (major < 0 || major >= 1000)
            throw new IllegalArgumentException("invalid major " + major);

        if (minor < 0 || minor >= 1000)
            throw new IllegalArgumentException("invalid minor " + minor);

        if (micro < 0 || micro >= 1000)
            throw new IllegalArgumentException("invalid micro " + micro);

        if (level < 0 || level >= 1000)
            throw new IllegalArgumentException("invalid " + levelType + 
                                               " level " + level);

        this.major = major;
        this.minor = minor;
        this.micro = micro;
        this.levelType = levelType;
        this.level = level;
    }

    public int hashCode() {
        return (int) toLong();
    }

    private long toLong() {
        return (1000L*1000L*1000L*1000L*major + 1000L*1000L*1000L*minor + 
                1000L*1000L*micro + 1000L*(levelType.ordinal()+1) + level);
    }

    public boolean equals(Object other) {
        if (other == null || !(other instanceof VersionNumber))
            return false;
        VersionNumber o = (VersionNumber) other;
        return (toLong() == o.toLong());
    }

    /**
     * Returns a copy of this VersionNumber but with all level info (alpha,
     * beta, patch) cleared.
     */
    public VersionNumber noLevel() {
        return new VersionNumber(major, minor, micro, LevelType.PATCH, 0);
    }

    public int compareTo(VersionNumber other) {
        long delta = (toLong() - other.toLong());
        if (delta < 0)
            return -1;
        else if (delta > 0)
            return 1;
        else
            return 0;
    }

    /**
     * Returns a string having the following format: 
     * <i>major</i>.<i>minor</i>.<i>micro</i>
     * if this version number is not an alpha, beta or patch release.
     * Otherwise, returns a string having the following format: 
     * <i>major</i>.<i>minor</i>.<i>micro</i>
     * (<b>-alpha</b>|<b>-beta</b>|<b>_</b>)<i>level</i>.
     */
    public String toString() {
        StringBuilder buffer = new StringBuilder();

        buffer.append(major);
        buffer.append('.');
        buffer.append(minor);
        buffer.append('.');
        buffer.append(micro);

        boolean appendLevel = true;
        switch (levelType) {
        case ALPHA:
            buffer.append("-alpha");
            break;
        case BETA:
            buffer.append("-beta");
            break;
        default:
            if (level == 0)
                appendLevel = false;
            else
                buffer.append('_');
        }

        if (appendLevel) {
            String l = Integer.toString(level);
            int charCount = l.length();
            while (charCount < 2) {
                buffer.append('0');
                ++charCount;
            }
            buffer.append(l);
        }

        return buffer.toString();
    }

    // -----------------------------------------------------------------------

    /*TEST_VERSION_NUMBER
    public static void main(String[] args) {
        VersionNumber reference = parseVersion(args[0]);
        if (reference == null)
            System.exit(1);

        for (int i = 1; i < args.length; ++i) {
            VersionNumber version = parseVersion(args[i]);
            if (version != null) {
                int delta = version.compareTo(reference);

                String op;
                if (delta < 0)
                    op = "<";
                else if (delta > 0)
                    op = ">";
                else
                    op = "==";

                System.out.println(version + " " + op + " " + reference);
            }
        }
    }

    private static final VersionNumber parseVersion(String s) {
        VersionNumber version = new VersionNumber();
        try {
            parse(s, version);
        } catch (IllegalArgumentException e) {
            System.out.println("*** cannot parse '" + s + "': " + 
                               e.getMessage());
            version = null;
        }
        return version;
    }
    TEST_VERSION_NUMBER*/
}

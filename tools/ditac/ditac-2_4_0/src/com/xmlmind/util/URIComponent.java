/*
 * Copyright (c) 2002-2011 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of several XMLmind projects.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.util;

import java.io.UnsupportedEncodingException;
import java.net.URISyntaxException;
import java.net.URI;

/**
 * A collection of low-level utility functions (static methods) related to URI
 * components (Strings, not <code>java.net.URI</code>).
 * <p>Refer to the documentation of {@link java.net.URI} for the definitions
 * of <i>quote</i>, <i>encode</i> and <i>decode</i>.
 */
public final class URIComponent {
    private URIComponent() {}

    // -----------------------------------------------------------------------
    // Path component
    // -----------------------------------------------------------------------

    /**
     * Equivalent to {@link #getRawParentPath(String, boolean)
     * getRawParentPath(path, true)}.
     */
    public static String getRawParentPath(String path) {
        return getRawParentPath(path, true);
    }

    /**
     * Returns the parent of specified path. To make it simple, the substring
     * before last '/'.
     * <p>Examples:
     * <ul>
     * <li>Returns <code>null</code> for "<tt>/</tt>".
     * <li>Returns <code>null</code> for "<tt>foo</tt>".
     * <li>Returns "<tt>/</tt>" for "<tt>/foo</tt>".
     * <li>Returns "<tt>/foo</tt>" (or "<tt>/foo/</tt>") for 
     * "<tt>/foo/bar</tt>".
     * <li>Returns "<tt>/foo</tt>" (or "<tt>/foo/</tt>") for 
     * "<tt>/foo/bar/</tt>".
     * </ul>
     * 
     * @param path relative or absolute URI path
     * @param trailingSlash if <code>true</code>, returned path ends with a
     * trailing '/' character
     * @return parent of specified path or <code>null</code> for '/' or if
     * specified path does not contain the '/' character
     */
    public static String getRawParentPath(String path, boolean trailingSlash) {
        if ("/".equals(path))
            return null;

        // Normalize "/foo/bar/" to "/foo/bar".
        if (path.endsWith("/"))
            path = path.substring(0, path.length()-1);

        int slash = path.lastIndexOf('/');
        if (slash < 0)
            return null;

        if (slash == 0) {
            // Example: "/foo"
            return "/";
        }

        return path.substring(0, trailingSlash? slash+1 : slash);
    }

    /**
     * Same as {@link #getRawBaseName} except that the returned value is
     * decoded using {@link #decode}.
     */
    public static String getBaseName(String path) {
        String baseName = getRawBaseName(path);
        return (baseName == null)? null : decode(baseName);
    }

    /**
     * Returns the base name of specified path. To make it simple, the
     * substring after last '/'.
     * <p>Examples:
     * <ul>
     * <li>Returns the empty string for "<tt>/</tt>".
     * <li>Returns "<tt>foo</tt>" for "<tt>foo</tt>".
     * <li>Returns "<tt>bar</tt>" for "<tt>/foo/bar</tt>".
     * <li>Returns "<tt>bar</tt>" for "<tt>/foo/bar/</tt>".
     * </ul>
     * 
     * @param path relative or absolute URI path
     * @return base name of specified path
     */
    public static String getRawBaseName(String path) {
        if ("/".equals(path))
            return "";

        // Normalize "/foo/bar/" to "/foo/bar".
        if (path.endsWith("/"))
            path = path.substring(0, path.length()-1);

        int slash = path.lastIndexOf('/');
        if (slash < 0)
            return path;

        return path.substring(slash+1);
    }

    /**
     * Same as {@link #getRawExtension} except that the returned value is
     * decoded using {@link #decode}.
     */
    public static String getExtension(String path) {
        String extension = getRawExtension(path);
        return (extension == null)? null : decode(extension);
    }

    /**
     * Returns the extension of specified path. To make it simple, the
     * substring after last '.', not including last '.'.
     * <ul>
     * <li>Returns <code>null</code> for "<tt>/tmp/test</tt>".
     * <li>Returns the empty string for "<tt>/tmp/test.</tt>".
     * <li>Returns <code>null</code> for "<tt>~/.profile</tt>".
     * <li>Returns "<tt>gz</tt>" for "<tt>/tmp/test.tar.gz</tt>".
     * </ul>
     * 
     * @param path relative or absolute URI path possibly having an extension
     * @return extension if any; <code>null</code> otherwise
     */
    public static String getRawExtension(String path) {
        int dot = FileUtil.indexOfDot(path, '/');
        if (dot < 0)
            return null;
        else
            return path.substring(dot+1);
    }

    /**
     * Same as {@link #setRawExtension} except that <tt>extension</tt> is
     * quoted using {@link #quotePath}.
     */
    public static String setExtension(String path, String extension) {
        if (extension != null)
            extension = quotePath(extension);
        return setRawExtension(path, extension);
    }

    /**
     * Changes the extension of specified path to specified extension. See
     * {@link #getRawExtension} for a description of the extension of a path.
     * 
     * @param path relative or absolute URI path
     * @param extension new extension. Assumed to have been quoted using
     * {@link #quotePath}. May be <code>null</code> which means: remove the
     * extension.
     * @return a path identical to <tt>path</tt> except that its extension has
     * been changed or removed.
     * <p>Returns same path if specified path ends with '/'.
     */
    public static String setRawExtension(String path, String extension) {
        if (path.endsWith("/"))
            return path;

        int dot = FileUtil.indexOfDot(path, '/');
        if (dot < 0) {
            if (extension == null)
                return path;
            else
                return path + "." + extension;
        } else {
            if (extension == null)
                return path.substring(0, dot);
            else
                return path.substring(0, dot+1) + extension;
        }
    }

    /*TEST_EXTENSION
    public static void main(String[] args) {
        for (int i = 0; i < args.length; ++i) {
            String path = args[i];

            System.out.println("'" + path + "'");
            System.out.println("\tgetRawParentPath='" + 
                               getRawParentPath(path) + "'");
            System.out.println("\tgetBaseName='" + 
                               getBaseName(path) + "'");
            System.out.println("\tgetExtension='" + 
                               getExtension(path) + "'");
            System.out.println("\tsetExtension='" + 
                               setExtension(path, "foo bar") + "'");
            System.out.println("\tTrim extension='" + 
                               setExtension(path, null) + "'");
            System.out.println("----------");
        }
    }
    TEST_EXTENSION*/

    // -----------------------------------------------------------------------

    /**
     * Same as {@link #getRawFragment} except that the returned value is
     * decoded using {@link #decode}.
     */
    public static String getFragment(String location) {
        String fragment = getRawFragment(location);
        return (fragment == null)? null : decode(fragment);
    }

    /**
     * Returns the fragment component (not including the '<tt>#</tt>'
     * delimiter) of specified location if any; <code>null</code> otherwise.
     */
    public static String getRawFragment(String location) {
        // The fragment is the very last component of an URI.
        int pos = location.lastIndexOf('#');
        if (pos < 0)
            return null;
        else
            return location.substring(pos+1);
    }

    /**
     * Same as {@link #setRawFragment} except that <tt>fragment</tt> is
     * quoted using {@link #quoteFragment}.
     */
    public static String setFragment(String location, String fragment) {
        if (fragment != null)
            fragment = quoteFragment(fragment);
        return setRawFragment(location, fragment);
    }

    /**
     * Changes the fragment component of specified location to specified
     * fragment.
     * 
     * @param location relative or absolute location
     * @param fragment new fragment. Assumed to have been quoted using {@link
     * #quoteFragment}. May be <code>null</code> which means: remove the
     * fragment.
     * @return a location identical to <tt>location</tt> except that its
     * fragment has been changed or removed
     */
    public static String setRawFragment(String location, String fragment) {
        int pos = location.lastIndexOf('#');
        if (pos < 0) {
            if (fragment == null)
                return location;
            else
                return location + "#" + fragment;
        } else {
            if (fragment == null)
                return location.substring(0, pos);
            else
                return location.substring(0, pos+1) + fragment;
        }
    }

    /*TEST_FRAGMENT
    public static void main(String[] args) {
        for (int i = 0; i < args.length; ++i) {
            String location = args[i];

            System.out.println("'" + location + "'");
            System.out.println("\tgetFragment='" + 
                               getFragment(location) + "'");
            System.out.println("\tsetFragment='" + 
                               setFragment(location, "foo bar") + "'");
            System.out.println("\tTrim fragment='" + 
                               setFragment(location, null) + "'");
            System.out.println("----------");
        }
    }
    TEST_FRAGMENT*/

    // -----------------------------------------------------------------------

    /**
     * Returns first path as a path relative to the second path.
     * <p>The returned result resolved against the second path gives back
     * first path. This means that trailing slashes "/" are significant.
     * <p>Examples:
     * <ul>
     * <li>Returns "<tt>gee</tt>" for "<tt>gee</tt>" relative to 
     * "<tt>/foo/bar/wiz</tt>".
     * <li>Returns "<tt>/foo/bar/gee</tt>" for "<tt>/foo/bar/gee</tt>"
     * relative to "<tt>wiz</tt>".
     * <li>Returns "<tt>foo/bar/gee</tt>" for "<tt>/foo/bar/gee</tt>" relative
     * to "<tt>/</tt>".
     * <li>Returns "<tt>bar/gee</tt>" for "<tt>/foo/bar/gee</tt>" relative to
     * "<tt>/foo/bar</tt>".
     * <li>Returns "<tt>gee</tt>" for "<tt>/foo/bar/gee</tt>" relative to 
     * "<tt>/foo/bar/wiz</tt>".
     * <li>Returns "<tt>../gee</tt>" for "<tt>/foo/bar/gee</tt>" relative to 
     * "<tt>/foo/bar/wiz/</tt>".
     * <li>Returns "<tt>gee/</tt>" for "<tt>/foo/bar/gee/</tt>" relative to 
     * "<tt>/foo/bar/wiz</tt>".
     * <li>Returns "<tt>../gee/</tt>" for "<tt>/foo/bar/gee/</tt>" relative to
     * "<tt>/foo/bar/wiz/</tt>".
     * <li>Returns "<tt>/</tt>" for "<tt>/</tt>" relative to "<tt>/</tt>".
     * <li>Returns "<tt>gee</tt>" for "<tt>/foo/bar/gee</tt>" relative to 
     * "<tt>/foo/bar/gee</tt>".
     * </ul>
     * 
     * @param path an absolute URI path
     * @param basePath another absolute URI path
     * @return first path as a path relative to the second path. Returns first
     * path as is, if the relative path cannot be computed.
     */
    public static String getRawRelativePath(String path, String basePath) {
        if (!path.startsWith("/") || !basePath.startsWith("/"))
            return path;

        if ("/".equals(path)) 
            return "/";

        if ("/".equals(basePath))
            return path.substring(1);

        if (!basePath.endsWith("/"))
            basePath = getRawParentPath(basePath, true);

        StringBuilder buffer = new StringBuilder();

        while (basePath != null) {
            String start = basePath;

            if (path.startsWith(start)) {
                buffer.append(path.substring(start.length()));
                break;
            }

            buffer.append("../");
            basePath = getRawParentPath(basePath, true);
        }

        return buffer.toString();
    }

    /*TEST_RELATIVIZE
    public static void main(String[] args) {
        int count = (args.length / 2) * 2;
        for (int i = 0; i < count; i += 2) {
            String path = args[i];
            String basePath = args[i+1];
            String relativePath = getRawRelativePath(path, basePath);
            
            System.out.println("'" + path + "' relative to '" + 
                               basePath + "' is '" + relativePath + "'");
        }
    }
    TEST_RELATIVIZE*/

    // -----------------------------------------------------------------------

    /**
     * Truncates specified path to get something short enough to be displayed
     * in the "<b>Recently Opened Files</b>" part of a <b>File</b> menu.
     * Example: returns "/home/john/.../report1.xml" for
     * "/home/john/docs/report1/report1.xml".
     * 
     * @param path relative or absolute URI path to be truncated
     * @param maxLength maximum length for truncated (this is just a hint);
     * typically 40
     * @return truncated path
     */
    public static String truncatePath(String path, int maxLength) {
        if (path.length() <= maxLength) {
            return path;
        }

        String[] parts = StringUtil.split(path, '/');
        if (parts.length <= 2) {
            return path;
        }

        // parts[0] is the empty string when the path is absolute.
        int j = 0;
        StringBuilder head = new StringBuilder();
        head.append(parts[j]);
        ++j;

        int k = parts.length - 1;
        StringBuilder tail = new StringBuilder();
        tail.append(parts[k]);
        --k;

        int length = head.length() + 3 + tail.length();

        boolean addTail = true;
        while (j < k && length < maxLength) {
            if (addTail) {
                tail.insert(0, '/');
                tail.insert(0, parts[k]);
                --k;
                addTail = false;
            } else {
                head.append('/');
                head.append(parts[j]);
                ++j;
                addTail = true;
            }

            length = head.length() + 3 + tail.length();
        }

        head.append("/\u2026/");
        head.append(tail.toString());

        return head.toString();
    }

    // -----------------------------------------------------------------------
    // About quoting, decoding and encoding
    // -----------------------------------------------------------------------

    /**
     * Joins specified URI components, without attempting to quote them. Pass
     * <code>null</code> or -1 for missing components.
     * 
     * @param scheme scheme or <code>null</code>
     * @param userName properly quoted user name or <code>null</code>
     * @param userPassword properly quoted password or <code>null</code>
     * @param host host or <code>null</code>
     * @param port port or -1
     * @param path properly quoted path or <code>null</code>
     * @param query properly quoted query (without '?') or <code>null</code>
     * @param fragment properly quoted fragment (without '#') or
     * <code>null</code>
     * @return URI spec
     */
    public static String joinQuotedComponents(String scheme,
                                              String userName,
                                              String userPassword,
                                              String host,
                                              int port,
                                              String path,
                                              String query,
                                              String fragment) {
        StringBuilder buffer = new StringBuilder();

        if (scheme != null) {
            buffer.append(scheme);
            buffer.append(':');
        }

        if (host != null && host.length() > 0) {
            buffer.append("//");

            if (userName != null && userName.length() > 0) {
                buffer.append(userName);

                if (userPassword != null && userPassword.length() > 0) {
                    buffer.append(':');
                    buffer.append(userPassword);
                }

                buffer.append('@');
            }

            buffer.append(host);

            if (port >= 0) {
                buffer.append(':');
                buffer.append(port);
            }
        }

        if (path != null)
            buffer.append(path);

        if (query != null && query.length() > 0) {
            buffer.append('?');
            buffer.append(query);
        }

        if (fragment != null && fragment.length() > 0) {
            buffer.append('#');
            buffer.append(fragment);
        }

        return buffer.toString();
    }

    // -----------------------------------------------------------------------

    /**
     * Quotes specified user info (that is, escapes ``special'' characters).
     * <p>Use this function separately on the user name and on the user
     * password. That is, do not use it on "<i>name</i>:<i>password</i>".
     * <p>Like all <tt>quote</tt> functions, the returned string may contain 
     * characters beloging to the <i>other</i> category.
     */
    public static String quoteUserInfo(String userInfo) {
        URI uri;
        try {
            uri = new URI("http", userInfo, "localhost", 80, "/x", null, null);
        } catch (URISyntaxException cannotHappen) {
            cannotHappen.printStackTrace();
            return null;
        }

        return uri.getRawUserInfo();
    }

    /**
     * Quotes specified path (that is, escapes ``special'' characters).
     * <p>Use this function separately on each path segment. That is, do not
     * use it on something like "<tt>foo/bar/gee</tt>".
     * <p>Like all <tt>quote</tt> functions, the returned string may contain 
     * characters beloging to the <i>other</i> category.
     *
     * @see #quoteFullPath(String)
     * @see #quoteFullPath(String, StringBuilder)
     */
    public static String quotePath(String path) {
        URI uri;
        try {
            uri = new URI("http", null, "localhost", 80, "/x" + path,
                          null, null);
        } catch (URISyntaxException cannotHappen) {
            cannotHappen.printStackTrace();
            return null;
        }

        return uri.getRawPath().substring(2);
    }

    /**
     * Quotes specified path (that is, escapes ``special'' characters).
     * Unlike {@link #quotePath} which only works for path <em>segments</em>, 
     * this method can be used to quote a relative or absolute path.
     * <p>Like all <tt>quote</tt> functions, the returned string may contain 
     * characters beloging to the <i>other</i> category.
     */
    public static String quoteFullPath(String path) {
        StringBuilder buffer = new StringBuilder();
        quoteFullPath(path, buffer);
        return buffer.toString();
    }

    /**
     * Similar tp {@link #quoteFullPath(String)} but appends quoted 
     * path to specified buffer.
     */
    public static void quoteFullPath(String path, StringBuilder buffer) {
        String[] segments = StringUtil.split(path, '/');
        for (int i = 0; i < segments.length; ++i) {
            String segment = segments[i];

            if (i > 0) 
                buffer.append('/');

            if (segment.length() > 0)
                buffer.append(quotePath(segment));
        }
    }

    /**
     * Quotes specified query (that is, escapes ``special'' characters).
     * <p>Like all <tt>quote</tt> functions, the returned string may contain 
     * characters beloging to the <i>other</i> category.
     */
    public static String quoteQuery(String query) {
        URI uri;
        try {
            uri = new URI("http", null, "localhost", 80, "/x", query, null);
        } catch (URISyntaxException cannotHappen) {
            cannotHappen.printStackTrace();
            return null;
        }

        return uri.getRawQuery();
    }

    /**
     * Quotes specified fragment (that is, escapes ``special'' characters).
     * <p>Returned string contains only ASCII characters.
     * <p>Like all <tt>quote</tt> functions, the returned string may contain 
     * characters beloging to the <i>other</i> category.
     */
    public static String quoteFragment(String fragment) {
        URI uri;
        try {
            uri = new URI("http", null, "localhost", 80, "/x", null, fragment);
        } catch (URISyntaxException cannotHappen) {
            cannotHappen.printStackTrace();
            return null;
        }

        return uri.getRawFragment();
    }

    // -----------------------------------------------------------------------

    /**
     * Equivalent to {@link #decode(String, String) decode(s, "UTF-8")}.
     */
    public static String decode(String s) {
        return decode(s, "UTF-8");
    }

    /**
     * Decodes <em>all</em> <tt>%<i>HH</i></tt> sequences.
     * <p>This function should be used on individual components. For example,
     * it can be used on "foo" and on "bar" and not on "/foo/bar" as a whole.
     * <p>{@link #encode(String, String)} and {@link #decode(String, String)}
     * are <em>not</em> inverse operations:
     * <ul>
     * <li><tt>encode</tt> encodes only spaces and accented 
     * characters (to make it simple).
     * <li><tt>decode</tt> replaces <em>all</em> <tt>%<i>HH</i></tt> 
     * sequences by the corresponding characters.
     * <ul>
     *
     * @param s string to be decoded
     * @param charset the encoding used for characters in the <i>other</i>
     * category. A superset of US-ASCII.
     * Examples: "ISO-8859-1" (eacute is represented as "%E9"), 
     * "UTF-8" (eacute is represented as "%C3%A9").
     * <p>For interoperability with {@link java.net.URI}, <tt>charset</tt>
     * is required to be "UTF-8".
     * @return the decoded string or <code>null</code> if <tt>charset</tt>
     * is an unsupported encoding
     */
    public static String decode(String s, String charset) {
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
        if (c < '0' || c > 'f')
            return -1;
        else
            return fromHexDigit[c - '0'];
    }

    // -----------------------------------------------------------------------

    /**
     * Equivalent to {@link #encode(String, String) encode(s, "UTF-8")}.
     */
    public static String encode(String s) {
        return encode(s, "UTF-8");
    }

    /**
     * Encodes non-ASCII characters, space characters (according to
     * java.lang.Character.isSpaceChar) and control characters (according to
     * java.lang.Character.isISOControl) as <tt>%<i>XX</i></tt> bytes.
     * That is, escapes characters which are unambiguously illegal according
     * to RFC2396.
     * <p>{@link #encode(String, String)} and {@link #decode(String, String)}
     * are <em>not</em> inverse operations:
     * <ul>
     * <li><tt>encode</tt> encodes only spaces and accented 
     * characters (to make it simple).
     * <li><tt>decode</tt> replaces <em>all</em> <tt>%<i>HH</i></tt> 
     * sequences by the corresponding characters.
     * <ul>
     *
     * @param s string to be encode
     * @param charset the encoding used for the aforementioned 
     * ``illegal'' characters. A superset of US-ASCII.
     * <p>For interoperability with {@link java.net.URI}, <tt>charset</tt>
     * is required to be "UTF-8".
     * @return the encoded string or <code>null</code> if <tt>charset</tt>
     * is an unsupported encoding
     */
    public static String encode(String s, String charset) {
        StringBuilder buffer = new StringBuilder();

        int length = s.length();
        for (int i = 0; i < length; ++i) {
            char c = s.charAt(i);

            if (c <= 127 && 
                !Character.isSpaceChar(c) && 
                !Character.isISOControl(c)) {
                buffer.append(c);
            } else {
                byte[] bytes;
                try {
                    bytes = (Character.toString(c)).getBytes(charset);
                } catch (UnsupportedEncodingException shouldNothappen) {
                    shouldNothappen.printStackTrace();
                    return null;
                }

                for (int j = 0; j < bytes.length; ++j) {
                    String hex = Integer.toHexString(bytes[j] & 0xFF);

                    buffer.append('%');
                    if (hex.length() == 1)
                        buffer.append('0');
                    buffer.append(hex.toUpperCase());
                }
            }
        }

        return buffer.toString();
    }
}

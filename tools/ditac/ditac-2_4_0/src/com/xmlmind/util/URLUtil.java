/*
 * Copyright (c) 2002-2012 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of several XMLmind projects.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.util;

import java.io.IOException;
import java.io.File;
import java.io.InputStream;
import java.io.FileOutputStream;
import java.net.MalformedURLException;
import java.net.URISyntaxException;
import java.net.URI;
import java.net.URL;
import java.net.URLConnection;
import java.net.HttpURLConnection;
import java.net.URLStreamHandler;
import java.util.Comparator;
import java.util.regex.PatternSyntaxException;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

/**
 * A collection of utility functions (static methods) operating on URLs.
 * <p>Work with any hierarchical URLs. Does not work with opaque URLs, except
 * for a few functions which work with "<tt>jar:</tt>" URLs.
 * <p>Note that, for these few functions, the path of "<tt>jar:</tt>" URL
 * (e.g. <tt>jar:http://www.foo.com/bar/baz.jar!/COM/foo/Quux.class</tt>) is
 * everything after "<tt>!/</tt>", including the leading "<tt>/</tt>".
 */
public final class URLUtil {
    private URLUtil() {}

    /**
     * A ready-to-use empty list of URLs.
     */
    public static final URL[] EMPTY_LIST = new URL[0];

    /**
     * Same as <code>new URL(spec)</code>, except that non-ASCII characters
     * and other illegal characters such as spaces possibly found in
     * <tt>spec</tt> are <i>%HH</i>-encoded.
     * 
     * @see URIComponent#encode
     */
    public static URL createURL(String spec)
        throws MalformedURLException {
        return new URL(URIComponent.encode(spec));
    }

    /**
     * Same as <code>new URL(context, spec)</code>, except that non-ASCII
     * characters and other illegal characters such as spaces possibly found
     * in <tt>spec</tt> are <i>%HH</i>-encoded.
     * 
     * @see URIComponent#encode
     */
    public static URL createURL(URL context, String spec)
        throws MalformedURLException {
        return new URL(context, URIComponent.encode(spec));
    }

    /**
     * Same as <code>new URL(context, spec, handler)</code>, except that
     * non-ASCII characters and other illegal characters such as spaces
     * possibly found in <tt>spec</tt> are <i>%HH</i>-encoded.
     * 
     * @see URIComponent#encode
     */
    public static URL createURL(URL context, String spec,
                                URLStreamHandler handler) 
        throws MalformedURLException {
        return new URL(context, URIComponent.encode(spec), handler);
    }

    // -----------------------------------------------------------------------

    /**
     * Returns <code>true</code> if specified URL is a <tt>file:</tt> URL,
     * otherwise returns <code>false</code>
     */
    public static boolean isFileURL(URL url) {
        return "file".equals(url.getProtocol());
    }

    /**
     * Returns <code>true</code> if specified URL is a <tt>jar:</tt> URL,
     * otherwise returns <code>false</code>
     */
    public static boolean isJarURL(URL url) {
        return "jar".equals(url.getProtocol());
    }

    /**
     * Converts a <tt>file:</tt> URL to a File.
     * <p>On Windows, this function converts a "file:" URL having a host
     * (other than "localhost") to an UNC filename. For example, 
     * it converts "<tt>file://foo/bar/gee.txt</tt>"
     * to "<tt>\\foo\bar\gee.txt</tt>".
     * 
     * @param url the URL to be converted
     * @return an absolute File or <code>null</code> if <code>url</code>
     * cannot be converted to a File (for example, because <code>url</code> is
     * not a <tt>file:</tt> URL)
     * @see #isFileURL
     * @see FileUtil#fileToURL
     * @see #urlOrFile
     */
    public static File urlToFile(URL url) {
        if (!isFileURL(url)) {
            return null;
        }

        if (SystemUtil.IS_WINDOWS) {
            String host = url.getHost();
            if (host != null && host.length() > 0 && 
                !"localhost".equalsIgnoreCase(host)) {
                // Special processing of "file://server/path" ---

                // getPath() does not include the query or the fragment.
                String location = url.getPath();
                if (location.length() == 0) {
                    location = "/";
                }
                location = "file:/C:" + location;
                     
                String filename;
                try {
                    URI uri = new URI(URIComponent.encode(location));
                    filename = (new File(uri)).getPath();
                } catch (Exception ignored) {
                    return null;
                }

                // Replace leading "C:" by "\\server".
                filename = "\\\\" + host + filename.substring(2);
                File file = new File(filename);

                try {
                    file = file.getCanonicalFile();
                } catch (IOException ignored) {}

                return file;
            } else {
                return convertURLToFile(url);
            }
        } else {
            return convertURLToFile(url);
        }
    }

    private static File convertURLToFile(URL url) {
        assert(isFileURL(url));

        try {
            // Ignore authority, query and fragment.
            String location = url.getPath();
            if (location.length() == 0) {
                location = "/";
            }
            location = "file://" + location;

            URI uri = new URI(URIComponent.encode(location));
            
            if (SystemUtil.IS_WINDOWS) {
                File file = new File(uri);

                try {
                    file = file.getCanonicalFile();
                } catch (IOException ignored) {}

                return file;
            } else {
                // Do not use getCanonicalFile on Unix because this resolves
                // symlinks.

                uri = uri.normalize();
                return new File(uri);
            }
        } catch (Exception ignored) {
            return null;
        }
    }

    /**
     * Similar to <code>java.net.URL.toURI()</code> except that this utility
     * will not throw a <code>java.net.URISyntaxException</code> if the URL
     * spec contains illegal characters such as spaces. In such case, special
     * efforts are made to nevertheless return a URI equivalent to specified
     * URL.
     * 
     * @param url URL to be converted
     * @return converted URI or <code>null</code> if this really cannot be
     * done
     */
    public static URI urlToURI(URL url) {
        String location = url.toExternalForm();
        try {
            return new URI(URIComponent.encode(location));
        } catch (URISyntaxException ignored) {
            return null;
        }
    }

    // -----------------------------------------------------------------------

    /**
     * Equivalent to {@link #urlOrFile(String, boolean, boolean, URL)
     * urlOrFile(path, false, false, null)}.
     */
    public static URL urlOrFile(String path) {
        return urlOrFile(path, /*checkAbsolute*/ false, /*allowDir*/ false, 
                         /*base*/ null);
    }

    /**
     * Equivalent to {@link #urlOrFile(String, boolean, boolean, URL)
     * urlOrFile(path, checkAbsolute, false, null)}.
     */
    public static URL urlOrFile(String path, boolean checkAbsolute) {
        return urlOrFile(path, checkAbsolute, /*allowDir*/ false, 
                         /*base*/ null);
    }

    /**
     * Equivalent to {@link #urlOrFile(String, boolean, boolean, URL)
     * urlOrFile(path, checkAbsolute, allowDir, null)}.
     */
    public static URL urlOrFile(String path, boolean checkAbsolute, 
                                boolean allowDir) {
        return urlOrFile(path, checkAbsolute, allowDir, /*base*/ null);
    }

    /**
     * Returns an URL created from specified path. First, this convenience
     * function attempts to convert specified path to an URL. If this fails,
     * specified path is considered to be the name of an <em>existing</em>
     * file or directory. If this filename conforms to specified requirements
     * (<tt>checkAbsolute</tt>, <tt>allowDir</tt>), it is converted to an URL
     * using {@link FileUtil#fileToURL}.
     * 
     * @param path external form of an URL or the filename of an existing file
     * or directory.
     * <p>If the path contains newline characters, everything after the first
     * newline character, including this character, is ignored.
     * <p>The reason for this is that Web browsers such as Firefox seems to
     * append the title of the Web page after its URL.
     * @param checkAbsolute if <code>true</code>, when <tt>path</tt> is a
     * filename, <tt>path</tt> must be absolute or this function will return
     * <code>null</code>
     * @param allowDir if <code>true</code>, when <tt>path</tt> is a filename,
     * <tt>path</tt> is allowed to be not only the path of a file but also the
     * path of a directory
     * @param baseURL which base URL to use to resolve <tt>path</tt> 
     * when its a relative URL. May be <code>null</code>.
     * @return an URL or <code>null</code> if specified path cannot be
     * converted to an URL given specified requirements
     */
    public static URL urlOrFile(String path, boolean checkAbsolute, 
                                boolean allowDir, URL baseURL) {
        int nl = path.indexOf('\n');
        if (nl >= 0) {
            path = path.substring(0, nl);
        }
        path = path.trim();

        URL url = null;
        try {
            url = createURL(baseURL, path);
        } catch (MalformedURLException ignored) {}

        if (url == null) {
            File file = new File(path);

            if (checkAbsolute && !file.isAbsolute()) {
                return null;
            }

            if (allowDir) {
                if (!file.exists()) {
                    return null;
                }
            } else {
                if (!file.isFile()) {
                    return null;
                }
            }

            url = FileUtil.fileToURL(file);
        }

        return url;
    }

    // -----------------------------------------------------------------------

    /**
     * Returns <code>true</code> if specified URLs have the same root.
     * 
     * @see #getRoot
     */
    public static boolean sameRoot(URL url1, URL url2) {
        return ObjectUtil.equals(getRoot(url1, true), getRoot(url2, true));
    }

    /**
     * Returns the root of specified URL.
     * <p>Example: returns "http://java.sun.com/" for
     * "http://java.sun.com/docs/index.html".
     * <p>Example: returns "jar:http://www.foo.com/bar/baz.jar!/" for
     * "jar:http://www.foo.com/bar/baz.jar!/COM/foo/Quux.class".
     * 
     * @param url a hierachical or "jar:" URL
     * @return root of specified URL
     */
    public static URL getRoot(URL url) {
        return getRoot(url, false);
    }

    private static URL getRoot(URL url, boolean defaultPort) {
        int port = url.getPort();
        if (port < 0 && defaultPort) {
            port = url.getDefaultPort();
        }
        
        String[] path = splitPath(url);
        if (path == null) {
            path = new String[] { null, "/" };
        }
        path[1] = "/";

        String spec = 
            URIComponent.joinQuotedComponents(url.getProtocol(),
                                              url.getUserInfo(), null,
                                              url.getHost(), port,
                                              joinPath(path), 
                                              /*query*/ null,
                                              /*fragment*/ null);

        try {
            return new URL(spec);
        } catch (MalformedURLException cannotHappen) {
            cannotHappen.printStackTrace();
            return null;
        }
    }

    // -------------------------------
    // Support for "jar:" URLs
    // -------------------------------

    private static String[] splitPath(URL url) {
        String path = url.getPath();
        if (path.length() == 0) {
            return null;
        }

        String part1 = null;
        String part2 = null;

        if (isJarURL(url)) {
            int pos = path.indexOf("!/");
            if (pos < 0) {
                return null;
            }

            part1 = path.substring(0, pos+1); // Ends with "!".
            part2 = path.substring(pos+1); // Starts with "/".
        } else {
            part2 = path;
        }

        return new String[] { part1, part2 };
    }

    private static String joinPath(String[] parts) {
        if (parts[0] == null) {
            return parts[1];
        } else {
            return parts[0] + parts[1];
        }
    }

    /**
     * Returns the parent of specified URL, if any. Returned URL has a path
     * which ends with '/'.
     * <p>Examples:
     * <ul>
     * <li>Returns "http://java.sun.com/docs/" for
     * "http://java.sun.com/docs/index.html".
     * <li>Returns <code>null</code> for "http://java.sun.com/".
     * <li>Returns "jar:http://www.foo.com/bar/baz.jar!/COM/foo/" for 
     * "jar:http://www.foo.com/bar/baz.jar!/COM/foo/Quux.class".
     * </ul>
     * 
     * @param url a hierachical or "<tt>jar:</tt>" URL
     * @return parent of specified URL or <code>null</code> for root URLs.
     * @see URIComponent#getRawParentPath(String, boolean)
     */
    public static URL getParent(URL url) {
        String[] path = splitPath(url);
        if (path == null) {
            return null;
        }

        path[1] = URIComponent.getRawParentPath(path[1]);
        if (path[1] == null) {
            return null;
        }

        String spec = 
            URIComponent.joinQuotedComponents(url.getProtocol(),
                                              url.getUserInfo(), null,
                                              url.getHost(), url.getPort(),
                                              joinPath(path), 
                                              /*query*/ null,
                                              /*fragment*/ null);

        try {
            return new URL(spec);
        } catch (MalformedURLException cannotHappen) {
            cannotHappen.printStackTrace();
            return null;
        }
    }

    /**
     * Same as {@link #getRawPath} except that the returned value is
     * decoded using {@link URIComponent#decode}.
     */
    public static String getPath(URL url) {
        String path= getRawPath(url);
        return (path == null)? null : URIComponent.decode(path);
    }

    /**
     * Returns the raw (that is, possibly containing %HH escapes) path, 
     * if specified URL has a path.
     * <p>Example: returns "/index.html" for "http://www.acme.com/index.html".
     * <p>Example: returns "/COM/foo/Quux.class" for 
     * "jar:http://www.foo.com/bar/baz.jar!/COM/foo/Quux.class".
     * 
     * @param url a hierachical or "<tt>jar:</tt>" URL
     * @return the raw path or <code>null</code> if specified URL has no path
     * (this is not consistent with <code>URL.getPath</code> which returns the
     * empty string in such case)
     */
    public static String getRawPath(URL url) {
        String[] path = splitPath(url);
        return (path == null)? null : path[1];
    }

    /**
     * Same as {@link #getRawBaseName} except that the returned value is
     * decoded using {@link URIComponent#decode}.
     */
    public static String getBaseName(URL url) {
        String baseName= getRawBaseName(url);
        return (baseName == null)? null : URIComponent.decode(baseName);
    }

    /**
     * Returns the raw (that is, possibly containing %HH escapes) basename
     * part of the path, if specified URL has a path.
     * <p>Example: returns "index.html" for "http://www.acme.com/index.html".
     * <p>Example: returns "Quux.class" for 
     * "jar:http://www.foo.com/bar/baz.jar!/COM/foo/Quux.class".
     * 
     * @param url a hierachical or "<tt>jar:</tt>" URL
     * @return basename or <code>null</code> if specified URL has no path
     * (this is not consistent with <code>URL.getPath</code> which returns the
     * empty string in such case)
     * @see URIComponent#getRawBaseName
     */
    public static String getRawBaseName(URL url) {
        String[] path = splitPath(url);
        return (path == null)? null : URIComponent.getRawBaseName(path[1]);
    }

    /**
     * Same as {@link #getRawExtension} except that the returned value is
     * decoded using {@link URIComponent#decode}.
     */
    public static String getExtension(URL url) {
        String extension= getRawExtension(url);
        return (extension == null)? null : URIComponent.decode(extension);
    }

    /**
     * Returns the raw (that is, possibly containing %HH escapes) extension of
     * the path, if specified URL has a path. The extension does not include a
     * leading dot '.'.
     * <p>Example: returns "html" for "http://www.acme.com/index.html".
     * <p>Example: returns "class" for 
     * "jar:http://www.foo.com/bar/baz.jar!/COM/foo/Quux.class".
     * 
     * @param url a hierachical or "<tt>jar:</tt>" URL
     * @return extension or <code>null</code> if specified URL has no path
     * (this is not consistent with <code>URL.getPath</code> which returns the
     * empty string in such case)
     * @see URIComponent#getRawExtension
     */
    public static String getRawExtension(URL url) {
        String[] path = splitPath(url);
        return (path == null)? null : URIComponent.getRawExtension(path[1]);
    }

    /**
     * Same as {@link #setRawExtension} except that specified extension is
     * quoted using {@link URIComponent#quotePath}.
     */
    public static URL setExtension(URL url, String extension) {
        if (extension != null) {
            extension = URIComponent.quotePath(extension);
        }
        return setRawExtension(url, extension);
    }

    /**
     * Changes the extension of specified URL to specified extension.
     * 
     * @param url a hierachical or "<tt>jar:</tt>" URL
     * @param extension new extension. Assumed to have been quoted using
     * {@link URIComponent#quotePath}. May be <code>null</code> which means:
     * remove the extension.
     * @return an URL identical to <tt>url</tt> except that its extension has
     * been changed or removed.
     * <p>Returns same URL if specified URL has no path or its path ends with
     * '/'.
     * @see URIComponent#setRawExtension
     */
    public static URL setRawExtension(URL url, String extension) {
        String[] path = splitPath(url);
        if (path == null || path[1].endsWith("/")) {
            return url;
        }

        path[1] = URIComponent.setRawExtension(path[1], extension);

        String spec = 
            URIComponent.joinQuotedComponents(url.getProtocol(),
                                              url.getUserInfo(), null,
                                              url.getHost(),
                                              url.getPort(),
                                              joinPath(path),
                                              url.getQuery(),
                                              url.getRef());
        try {
            return new URL(spec);
        } catch (MalformedURLException cannotHappen) {
            cannotHappen.printStackTrace();
            return null;
        }
    }

    /**
     * Same as <code>URL.getRef</code> except that the returned value is
     * decoded using {@link URIComponent#decode}.
     */
    public static String getFragment(URL url) {
        String fragment = url.getRef();
        return (fragment == null)? null : URIComponent.decode(fragment);
    }

    /**
     * Same as {@link #setRawFragment} except that specified fragment is
     * quoted using {@link URIComponent#quoteFragment}.
     */
    public static URL setFragment(URL url, String fragment) {
        if (fragment != null) {
            fragment = URIComponent.quoteFragment(fragment);
        }
        return setRawFragment(url, fragment);
    }

    /**
     * Changes the fragment of specified URL to specified fragment.
     * 
     * @param url a hierachical or "<tt>jar:</tt>" URL
     * @param fragment new fragment. Assumed to have been quoted using {@link
     * URIComponent#quoteFragment}. May be <code>null</code> which means:
     * remove the fragment.
     * @return an URL identical to <tt>url</tt> except that its fragment has
     * been changed or removed. Returns <tt>url</tt> as is if specified URL
     * has no path.
     * @see URIComponent#setRawFragment
     */
    public static URL setRawFragment(URL url, String fragment) {
        String[] path = splitPath(url);
        if (path == null) {
            return url;
        }

        String location = url.toExternalForm();
        location = URIComponent.setRawFragment(location, fragment);

        try {
            return new URL(location);
        } catch (MalformedURLException cannotHappen) {
            cannotHappen.printStackTrace();
            return null;
        }
    }

     /**
      * Same as {@link #getRawUserName} except that the returned value is
      * decoded using {@link URIComponent#decode}.
      */
     public static String getUserName(URL url) {
        String userName = getRawUserName(url);
        return (userName == null)? null : URIComponent.decode(userName);
     }

     /**
      * Returns the raw (that is, possibly containing <i>%HH</i> escapes) user
      * name, if a user info is found in specified URL. Returns
      * <code>null</code> otherwise.
      */
     public static String getRawUserName(URL url) {
        String userInfo = url.getUserInfo();
        if (userInfo != null) {
            int colon = userInfo.indexOf(':');
            if (colon < 0) {
                return userInfo;
            } else if (colon > 0) {
                return userInfo.substring(0, colon);
            } else {
                return null;
            }
        } else {
            return null;
        }
    }

    /**
     * Same as {@link #getRawUserPassword} except that the returned value is
     * decoded using {@link URIComponent#decode}.
     */
    public static String getUserPassword(URL url) {
        String password = getRawUserPassword(url);
        return (password == null)? null : URIComponent.decode(password);
    }

    /**
     * Returns the raw (that is, possibly containing <i>%HH</i> escapes) user
     * password, if a user info is found in specified URL. Returns
     * <code>null</code> otherwise.
     */
    public static String getRawUserPassword(URL url) {
        String userInfo = url.getUserInfo();
        if (userInfo != null) {
            int colon = userInfo.indexOf(':');
            if (colon + 1 < userInfo.length()) {
                return userInfo.substring(colon + 1);
            } else {
                return null;
            }
        } else {
            return null;
        }
    }

    /**
     * Same as {@link #setRawUserInfo} except that specified user info is
     * quoted using {@link URIComponent#quoteUserInfo}.
     */
    public static URL setUserInfo(URL url, String userName, String password) {
        if (userName != null) {
            userName = URIComponent.quoteUserInfo(userName);
        }
        if (password != null) {
            password = URIComponent.quoteUserInfo(password);
        }
        return setRawUserInfo(url, userName, password);
    }

    /**
     * Changes the user info of specified URL to specified user info.
     * 
     * @param url a hierachical or "<tt>jar:</tt>" URL
     * @param userName new username. Assumed to have been quoted using {@link
     * URIComponent#quoteUserInfo}. May be <code>null</code>, which means:
     * remove user info.
     * @param password new password. Assumed to have been quoted using {@link
     * URIComponent#quoteUserInfo}. May be <code>null</code>, which means:
     * password not specified.
     * @return an URL identical to <tt>url</tt> except that its user info has
     * been changed or removed.
     */
    public static URL setRawUserInfo(URL url,
                                     String userName, String password) {
        if (userName == null) {
            password = null;
        }

        String spec = 
            URIComponent.joinQuotedComponents(url.getProtocol(),
                                              userName, password,
                                              url.getHost(), url.getPort(),
                                              url.getPath(), 
                                              url.getQuery(),
                                              url.getRef());

        try {
            return new URL(spec);
        } catch (MalformedURLException cannotHappen) {
            cannotHappen.printStackTrace();
            return null;
        }
    }

    /*TEST_URL_PART
    public static void main(String[] args) {
        for (int i = 0; i < args.length; ++i) {
            try {
                URL url = new URL(args[i]);

                System.out.println("'" + url + "'");
                System.out.println("\tgetRoot='" + 
                                   getRoot(url) + "'");
                System.out.println("\tgetParent='" + 
                                   getParent(url) + "'");
                System.out.println("\tgetPath='" + 
                                   getPath(url) + "'");
                System.out.println("\tgetBaseName='" + 
                                   getBaseName(url) + "'");
                System.out.println("\tgetExtension='" + 
                                   getExtension(url) + "'");
                System.out.println("\tsetExtension='" + 
                                   setExtension(url, "foo bar") + "'");
                System.out.println("\tTrim extension='" + 
                                   setExtension(url, null) + "'");
                System.out.println("\tgetFragment='" + 
                                   getFragment(url) + "'");
                System.out.println("\tsetFragment='" + 
                                   setFragment(url, "x/y z") + "'");
                System.out.println("\tTrim fragment='" + 
                                   setFragment(url, null) + "'");
                System.out.println("\tgetUserName='" + 
                                   getUserName(url) + "'");
                System.out.println("\tgetUserPassword='" + 
                                   getUserPassword(url) + "'");
                if (!isJarURL(url)) {
                    System.out.println("\tsetUserInfo='" + 
                                       setUserInfo(url, "x@y", "change it") + 
                                       "'");
                    System.out.println("\tTrim user info='" + 
                                       setUserInfo(url, null, null) + "'");
                }
                System.out.println("----------");
            } catch (MalformedURLException ex) {
                System.err.println("*** error: malformed URL: " + ex + "'");
            }
        }
    }
    TEST_URL_PART*/

    // -----------------------------------------------------------------------

    /**
     * Returns the path of specified URL relative to specified base URL.
     * <p>More precisely returns <tt>relativePath</tt> such that <code>new
     * URL(base, relativePath)</code> equals <tt>url</tt>.
     * 
     * @param url a hierarchical or "<tt>jar:</tt>" URL
     * @param base another hierarchical or "<tt>jar:</tt>" URL
     * @return a relative path possibly followed by the query and fragment
     * components of <tt>url</tt> or <code>URL.toExternalForm</code> if
     * <tt>url</tt> or <tt>base</tt> have no path or if <tt>url</tt> and
     * <tt>base</tt> don't have the same root
     * @see URIComponent#getRawRelativePath
     */
    public static String getRawRelativePath(URL url, URL base) {
        if (SystemUtil.IS_WINDOWS &&
            isFileURL(url) &&
            isFileURL(base)) {
            // On Windows, "file:" URLs may have different volumes (e.g.
            // file:/C:/foo and file:/D:/bar). When this is the case, do not
            // attempt to compute a relative path.

            File file = urlToFile(url);
            File baseFile = urlToFile(base);
            if (file != null && 
                baseFile != null && 
                FileUtil.getNonRelativePath(file, baseFile, null) != null) {
                return url.toExternalForm();
            }
        }

        String[] path1;
        String[] path2;
        if ((path1 = splitPath(url)) == null ||
            (path2 = splitPath(base)) == null ||
            !sameRoot(url, base)) {
            return url.toExternalForm();
        }

        String relativePath =
            URIComponent.getRawRelativePath(path1[1], path2[1]);

        return  URIComponent.joinQuotedComponents(null,
                                                  null, null,
                                                  null, -1,
                                                  relativePath, 
                                                  url.getQuery(),
                                                  url.getRef());
    }

    /*TEST_RELATIVIZE
    public static void main(String[] args) {
        int count = (args.length / 2) * 2;
        for (int i = 0; i < count; i += 2) {
            try {
                URL url = new URL(args[i]);
                URL baseURL = new URL(args[i+1]);

                String relativePath = getRawRelativePath(url, baseURL);

                System.out.println("'" + url + "'");
                System.out.println("base='" + baseURL + "'");
                System.out.println("\trelativePath='" + relativePath + "'");
                System.out.println("\tresolved='" +
                                   new URL(baseURL, relativePath) + "'");
                System.out.println("----------");
            } catch (MalformedURLException ex) {
                System.err.println("*** error: malformed URL: " + ex + "'");
            }
        }
    }
    TEST_RELATIVIZE*/

    // -----------------------------------------------------------------------

    /**
     * Same as {@link #toDisplayForm} but <tt>file:</tt> URLs are displayed as
     * plain file names.
     */
    public static String toLabel(URL url) {
        File file = urlToFile(url);
        if (file != null) {
            return file.getPath();
        }

        return toDisplayForm(url);
    }

    /**
     * Same as <code>java.net.URL.toExternalForm</code> except that returned
     * string may contain non-ASCII characters and that, if specified URL
     * contains a password, the characters of this password are replaced by
     * <tt>'*'</tt>.
     * <p>Example: returns
     * <tt>ftp://jjc%40acme.com:******@ftp.acme.com/pub/My%20report.doc</tt>
     * for
     * <tt>ftp://jjc%40acme.com:s%25same@ftp.acme.com/pub/My%20report.doc</tt>.
     * 
     * @param url a hierarchical URL
     * @return display form or <code>URL.toExternalForm</code> if specified
     * URL is opaque ("jar:" URLs are opaque).
     */
    public static String toDisplayForm(URL url) {
        URI uri = urlToURI(url);
        if (uri == null || uri.isOpaque()) {
            return url.toExternalForm();
        }
            
        String userInfo = hideUserInfo(uri);

        URI uri2;
        try {
            uri2 = new URI(uri.getScheme(),
                           userInfo,
                           uri.getHost(),
                           uri.getPort(),
                           uri.getPath(),
                           uri.getQuery(),
                           uri.getFragment());
        } catch (URISyntaxException ignored) {
            return url.toExternalForm();
        }

        return uri2.toString();
    }

    private static String hideUserInfo(URI uri) {
        // Result is not 100% correct if the usename part contains a ':'.
        String userInfo = uri.getUserInfo();
        if (userInfo != null) {
            StringBuilder buffer = new StringBuilder();

            boolean hide = false;
            int count = userInfo.length();
            for (int i = 0; i < count; ++i) {
                char c = userInfo.charAt(i);

                if (!hide) {
                    buffer.append(c);
                    if (c == ':') {
                        hide = true;
                    }
                } else {
                    buffer.append('*');
                }
            }

            userInfo = buffer.toString();
        }
        return userInfo;
    }

    /**
     * Same as {@link #toLabel} except that the returned string is made
     * shorter than specified length (when possible). This function is useful
     * to display the recently opened URLs in the <b>File</b> menu of an
     * application.
     */
    public static String toShortLabel(URL url, int maxLength) {
        File file = urlToFile(url);
        if (file != null) {
            String fileName = file.getPath();
            if (File.separatorChar != '/') {
                fileName = fileName.replace(File.separatorChar, '/');
            }

            fileName = URIComponent.truncatePath(fileName, maxLength);

            if (File.separatorChar != '/') {
                fileName = fileName.replace('/', File.separatorChar);
            }

            return fileName;
        }

        return toShortDisplayForm(url, maxLength);
    }

    /**
     * Same as {@link #toDisplayForm} except that the returned string is made
     * shorter than specified length (when possible). This function is useful
     * to display the recently opened URLs in the <b>File</b> menu of an
     * application.
     */
    public static String toShortDisplayForm(URL url, int maxLength) {
        URI uri = urlToURI(url);
        if (uri == null || uri.isOpaque()) {
            return url.toExternalForm();
        }

        String userInfo = hideUserInfo(uri);

        URI uri2;
        try {
            uri2 = new URI(uri.getScheme(),
                           userInfo,
                           uri.getHost(),
                           uri.getPort(),
                           "/",
                           null,
                           null);
        } catch (URISyntaxException ignored) {
            return url.toExternalForm();
        }

        int maxLength2 = (2*maxLength)/3;
        if (maxLength2 <= 0) {
            maxLength2 = 10;
        }
        maxLength2 = Math.max(maxLength2, maxLength-uri2.toString().length());

        String path = URIComponent.truncatePath(uri.getPath(), maxLength2);

        try {
            uri2 = new URI(uri.getScheme(),
                           userInfo,
                           uri.getHost(),
                           uri.getPort(),
                           path,
                           uri.getQuery(),
                           uri.getFragment());
        } catch (URISyntaxException ignored) {
            return url.toExternalForm();
        }

        return uri2.toString();
    }

    /*TEST_URL_LABEL
    public static void main(String[] args) throws Exception {
        java.io.PrintWriter out = 
            new java.io.PrintWriter(
                new java.io.OutputStreamWriter(System.out, "ISO-8859-1"));

        for (int i = 0; i < args.length; ++i) {
            String arg = args[i];

            System.out.println(arg);
            URL url = new URL(arg);

            System.out.println("\tto label: " + 
                               toLabel(url));
            System.out.println("\tto short label: " + 
                               toShortLabel(url, 40));
            System.out.println("\tto display form: " + 
                               toDisplayForm(url));
            System.out.println("\tto short display form: " + 
                               toShortDisplayForm(url, 40));
            System.out.println("----------");
            System.out.println();
        }
    }
    TEST_URL_LABEL*/

    // -----------------------------------------------------------------------

    /**
     * Compares two URLs by their {@link URL#toExternalForm external forms}.
     */
    public static final class URLComparator implements Comparator<URL> {
        public int compare(URL u1, URL u2) {
            return u1.toExternalForm().compareTo(u2.toExternalForm());
        }
    }

    /**
     * A ready-to-use URLComparator.
     */
    public static final URLComparator COMPARATOR = new URLComparator();

    // -----------------------------------------------------------------------

    /**
     * Returns <code>true</code> if specified URL corresponds to an existing
     * resource; returns <code>false</code> otherwise.
     * <p>This method treats "<tt>file:</tt>" URLs as a special, optimized,
     * case.
     */
    public static boolean exists(URL url) {
        File file = urlToFile(url);
        if (file != null) {
            return file.exists();
        }

        try {
            InputStream in = openStreamNoCache(url);
            in.close();
            in = null;
            return true;
        } catch (IOException ignored) {
            //ignored.printStackTrace();
            return false;
        }
    }

    /**
     * Returns the date specified URL has been last modified. The result is
     * the number of milliseconds since January 1, 1970 GMT. If specified URL
     * does not exist or if this date is unknown returns a number which is
     * negative or null.
     * <p>This method treats "<tt>file:</tt>" URLs as a special, optimized,
     * case.
     */
    public static long lastModified(URL url) {
        File file = urlToFile(url);
        if (file != null) {
            return file.lastModified();
        }

        try {
            URLConnection connection = openConnectionNoCache(url);
            connection.connect();
            long date = connection.getLastModified(); // Returns 0 if unknown
            connection = null;
            return date;
        } catch (IOException ignored) {
            //ignored.printStackTrace();
            return -1;
        }
    }

    // -----------------------------------------------------------------------

    /**
     * Equivalent to {@link #loadBytes(URL, int) loadBytes(url, -1)}.
     */
    public static byte[] loadBytes(URL url) 
        throws IOException {
        return loadBytes(url, -1);
    }

    /**
     * Loads the content of an URL containing binary data.
     * 
     * @param url the URL of the binary data
     * @param timeout specifies both connect and read timeout values 
     * in milliseconds. 0 means: infinite timeout.
     * A negative value means: default value. 
     * @return the loaded bytes
     * @exception IOException if there is an I/O problem
     */
    public static byte[] loadBytes(URL url, int timeout) 
        throws IOException {
        URLConnection connection = openConnectionNoCache(url);
        if (timeout >= 0) {
            connection.setConnectTimeout(timeout);
            connection.setReadTimeout(timeout);
        }
        checkHTTPConnection(connection);

        byte[] loaded = null;

        InputStream in = connection.getInputStream();
        try {
            loaded = FileUtil.loadBytes(in);
        } finally {
            in.close();
        }

        return loaded;
    }

    private static void checkHTTPConnection(URLConnection connection) 
        throws IOException {
        if (connection instanceof HttpURLConnection) {
            HttpURLConnection httpd = (HttpURLConnection) connection;

            int status = httpd.getResponseCode();
            if (status != HttpURLConnection.HTTP_OK) {
                StringBuilder msg = new StringBuilder("cannot access '");
                msg.append(httpd.getURL());
                msg.append("': error ");
                msg.append(status);
                String explain = httpd.getResponseMessage();
                if (explain != null) {
                    msg.append(": ");
                    msg.append(explain);
                }

                throw new IOException(msg.toString());
            }
        }
    }

    // -----------------------------------------------------------------------

    /**
     * Copies the contents of specified URL to specified "<tt>file:</tt>" URL.
     * 
     * @param srcLocation URL of the source file in string form.
     * If relative, this location is relative to the current working directory.
     * @param dstLocation  URL of the destination  file in string form.
     * If relative, this location is relative to the current working directory.
     * @exception IllegalArgumentException if <tt>srcLocation</tt>
     * cannot be parsed as an URL or if <tt>dstLocation</tt>
     * cannot be parsed as a "<tt>file:</tt>" URL.
     * @exception IOException if an I/O problem occurs
     */
    public static int copyFile(String srcLocation, String dstLocation)
        throws IllegalArgumentException, IOException {
        URL baseURL = FileUtil.fileToURL(new File("."));

        URL url = null;
        try {
            url = createURL(baseURL, srcLocation);
        } catch (MalformedURLException ignored) {}
        if (url == null) {
            throw new IllegalArgumentException("'" + srcLocation + 
                                               "', not an URL");
        }

        File dstFile = null;
        try {
            dstFile = urlToFile(createURL(baseURL, dstLocation));
        } catch (MalformedURLException ignored) {}
        if (dstFile == null) {
            throw new IllegalArgumentException("'" + dstLocation + 
                                               "', not a 'file:' URL");
        }

        int copied = 0;

        InputStream in = url.openStream();
        try {
            FileOutputStream out = new FileOutputStream(dstFile);
            try {
                byte[] buffer = new byte[65535];
                int count;

                while ((count = in.read(buffer)) != -1) {
                    out.write(buffer, 0, count);
                    copied += count;
                }
                out.flush();
            } finally {
                out.close();
            }
        } finally {
            in.close();
        }

        return copied;
    }

    // -----------------------------------------------------------------------

    /**
     * Equivalent to {@link #loadString(URL, String, int) 
     * loadString(url, null, -1)}.
     */
    public static String loadString(URL url) 
        throws IOException {
        return loadString(url, null, -1);
    }

    /**
     * Equivalent to {@link #loadString(URL, String, int) 
     * loadString(url, charset, -1)}.
     */
    public static String loadString(URL url, String charset) 
        throws IOException {
        return loadString(url, charset, -1);
    }

    /**
     * Loads the content of an URL containing text.
     * 
     * @param url the URL of the text resource
     * @param charset the IANA charset of the text source if known; specifying
     * <code>null</code> means detect it using the content type obtained from
     * the connection
     * @param timeout specifies both connect and read timeout values 
     * in milliseconds. 0 means: infinite timeout.
     * A negative value means: default value. 
     * @return the loaded String
     * @exception IOException if there is an I/O problem
     */
    public static String loadString(URL url, String charset, int timeout) 
        throws IOException {
        URLConnection connection = openConnectionNoCache(url);
        if (timeout >= 0) {
            connection.setConnectTimeout(timeout);
            connection.setReadTimeout(timeout);
        }
        checkHTTPConnection(connection);

        if (charset == null) {
            // Note that a contentType is available even for 
            // a file:// connection.

            String contentType = connection.getContentType();
            if (contentType != null) {
                charset = contentTypeToCharset(contentType);
            }
        }

        String loaded = null;

        InputStream in = connection.getInputStream();
        try {
            loaded = FileUtil.loadString(in, charset);
        } finally {
            in.close();
        }

        return loaded;
    }

    /**
     * Returns the value of the charset parameter possibly found in specified
     * content type. For example, returns "<tt>utf-8</tt>", when passed 
     * "<tt>text/html; charset=UTF-8</tt>"
     * 
     * @param contentType a content type (AKA media type) possibly having a
     * charset parameter
     * @return value of the charset parameter (lower case) if any; 
     * <code>null</code> otherwise
     */
    public static String contentTypeToCharset(String contentType) {
        String charset = null;

        if (contentType != null) {
            contentType = contentType.toLowerCase();

            int pos = contentType.indexOf("charset=");
            if (pos >= 0 && pos+8 < contentType.length()-1) {
                charset = contentType.substring(pos+8).trim();

                int length = charset.length();
                if (length >= 2 && charset.charAt(0) == '"') {
                    charset = charset.substring(1, length-1);
                }
            }
        }

        return charset;
    }

    /**
     * Parses a content type such as "<tt>text/html; charset=ISO-8859-1</tt>"
     * and returns the media type (for the above example "<tt>text/html</tt>").
     * 
     * @param contentType the content type to be parsed
     * @return the media type (lower case) if parsing was successful;
     * <code>null</code> otherwise.
     */
    public static String contentTypeToMedia(String contentType) {
        String media = null;

        if (contentType != null) {
            contentType = contentType.toLowerCase();

            int pos = contentType.lastIndexOf(';');
            if (pos < 0) {
                media = contentType.trim();
            } else if (pos > 0) {
                media = contentType.substring(0, pos).trim();
            }
        }

        return media;
    }

    /**
     * Returns a normalized string form for specified content type.
     * <p>Example: returns <tt>text/html;charset=iso-8859-1</tt> for 
     * <tt>text/html; charset="ISO-8859-1"</tt>.
     *
     * @param contentType content type to be normalized
     * @param defaultCharset charset to add as a parameter to the content type
     * when this parameter is absent. May be <code>null</code>.
     * @return normalized string form for specified content type;
     * <code>null</code> if specified content type is malformed.
     * @see #sameContentType
     */
    public static String normalizeContentType(String contentType, 
                                              String defaultCharset) {
        String media = contentTypeToMedia(contentType);
        if (media == null) {
            return null;
        }

        String charset = contentTypeToCharset(contentType);
        if (charset == null && defaultCharset != null) {
            charset = defaultCharset.toLowerCase();
        }
        if (charset == null) {
            return media;
        }

        StringBuilder buffer = new StringBuilder(media);
        buffer.append(";charset=");
        buffer.append(charset);
        return buffer.toString();
    }

    /**
     * Tests whether specified content types are identical.
     * <p>Examples:
     * <ul>
     * <li> Returns <code>true</code> for 
     * <tt>text/html; charset=ISO-8859-1</tt> and 
     * <tt>text/html;charset="iso-8859-1"</tt>.
     * <li>Returns <code>false</code> for 
     * <tt>text/html; charset=ISO-8859-1</tt> and <tt>text/html</tt>.
     * </ul>
     *
     * @param ct1 content type to be tested
     * @param ct2 content type to be tested
     * @param defaultCharset charset to add as a parameter to a content type
     * when this parameter is absent. May be <code>null</code>.
     * @return <code>true</code> if specified content types are identical;
     * <code>false</code> otherwise
     * @see #normalizeContentType
     */
    public static boolean sameContentType(String ct1, String ct2, 
                                          String defaultCharset) {
        ct1 = normalizeContentType(ct1, defaultCharset);
        ct2 = normalizeContentType(ct2, defaultCharset);
        return ((ct1 == null && ct2 == null) ||
                (ct1 != null && ct1.equals(ct2)));
    }

    /*TEST_LOAD_STRING
    public static void main(String args[]) 
        throws MalformedURLException, IOException {
        if (args.length != 2) {
            System.err.println("usage: java com.xmlmind.util.URLUtil " +
                               " src_URL dst_file");
            System.exit(1);
        }

        String text = loadString(new URL(args[0]));
        FileUtil.saveString(text, new File(args[1]), "ISO-8859-1");
    }
    TEST_LOAD_STRING*/

    // -----------------------------------------------------------------------

    /**
     * Similar to <code>url.openConnection</code> except that the accessed
     * resource may not be a cached copy.
     * 
     * @param url URL for which an URLConnection must be opened
     * @exception IOException if URLConnection cannot be opened
     * @see #openStreamNoCache(URL)
     */
    public static URLConnection openConnectionNoCache(URL url) 
        throws IOException {
        URLConnection connection = url.openConnection();
        connection.setUseCaches(false);
        connection.setIfModifiedSince(0);
        return connection;
    }

    /**
     * Similar to <code>url.openStream</code> except that the accessed
     * resource may not be a cached copy.
     * 
     * @param url URL for which an input stream must be opened
     * @return opened input stream
     * @exception IOException if the input stream cannot be opened
     * @see #openConnectionNoCache(URL)
     */
    public static InputStream openStreamNoCache(URL url) 
        throws IOException {
        URLConnection connection = openConnectionNoCache(url);
        return connection.getInputStream();
    }
}

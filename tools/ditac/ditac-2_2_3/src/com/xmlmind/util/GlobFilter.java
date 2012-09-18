/*
 * Copyright (c) 2002-2008 Pixware. 
 *
 * Author: Hussein Shafie
 *
 * This file is part of several XMLmind projects.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.util;

import java.io.IOException;
import java.io.File;
import java.io.FilenameFilter;
import java.util.ArrayList;
import java.util.regex.PatternSyntaxException;

/**
 * An implementation of <code>java.io.FilenameFilter</code> which accepts file
 * names matching a given <i>glob pattern</i> (as used by Unix shells).
 * <p>This class is <em>not</em> thread-safe.
 * <p><b>Caveat:</b> on Windows, '<tt>\</tt>' (backslash) is always considered 
 * to be the path separator (e.g. <tt>C:\foo\bar*\*.xml</tt>) and thus, 
 * cannot be used to escape special characters in the pattern passed 
 * to the constructor and to the convenience functions.
 */
public final class GlobFilter implements FilenameFilter {
    /**
     * The string representation of the glob pattern.
     */
    public final String globPattern;

    /**
     * The underlying matcher.
     */
    public final GlobMatcher globMatcher;

    // -----------------------------------------------------------------------

    /**
     * Constructs filter using specified glob pattern.
     * 
     * @param globPattern the glob pattern
     * @exception PatternSyntaxException if specified glob pattern cannot be
     * compiled into a <code>java.util.regex.Pattern</code>
     */
    public GlobFilter(String globPattern)
        throws PatternSyntaxException {
        this.globPattern = globPattern;
        if (GlobMatcher.containsGlobChar(globPattern, /*inclTilde*/ false))
            globMatcher = new GlobMatcher(globPattern);
        else
            globMatcher = null;
    }

    public boolean accept(File dir, String name) {
        if (globMatcher == null) 
            return name.equals(globPattern);
        else
            return globMatcher.matches(name);
    }

    // -----------------------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------------------

    /**
     * Convenience method: creates a filter for specified pattern, but unlike
     * the constructor, this method does not raise an exception if this fails.
     * Instead, this method returns <code>null</code>.
     */
    public static GlobFilter create(String globPattern) {
        GlobFilter globFilter = null;
        try {
            globFilter = new GlobFilter(globPattern);
        } catch (PatternSyntaxException ignored) {}
        return globFilter;
    }

    /**
     * Convenience method: List all the files matching specified glob pattern.
     * 
     * @param patterns a path, relative or absolute, possibly containing one
     * or more glob patterns. Example: "<tt>~/src/_?/[A-Z]*.java</tt>". If this
     * path is not absolute, it is resolved against the home directory of the
     * user if it starts with '<tt>~</tt>' and against the current working
     * directory otherwise.
     * @return a possibly empty array of absolute, canonical files
     */
    public static File[] glob(String patterns) {
        File patternsFile = resolve(patterns, null, true);
        return glob(patternsFile);
    }

    /**
     * Utility used by the {@link #glob(String)} convenience method: Resolve
     * specified path against specified base directory.
     * 
     * @param path path to be made absolute
     * @param baseDir an absolute directory. Resolve path against this base
     * directory. May be <code>null</code> which means: use the current
     * working directory.
     * @param substituteTilde if <code>true</code> and path starts with 
     * '<tt>~</tt>', resolve path against the home directory of the user
     * @return an absolute, canonical, file
     */
    public static File resolve(String path, File baseDir,
                               boolean substituteTilde) {
        File file = new File(path);
        if (!file.isAbsolute()) {
            boolean makeItAbsolute = true;

            if (substituteTilde && path.startsWith("~")) {
                String userName = System.getProperty("user.name");
                String userHome = System.getProperty("user.home");

                if (userName != null && userHome != null) {
                    int pos = path.indexOf(File.separatorChar, 1);
                    if (pos < 0)
                        pos = path.length();

                    if (pos == 1) {
                        file = new File(userHome + path.substring(1));
                        makeItAbsolute = false;
                    } else {
                        int pos2;
                        if (SystemUtil.IS_WINDOWS) {
                            pos2 = userHome.toLowerCase().indexOf(
                                userName.toLowerCase());
                        } else {
                            pos2 = userHome.indexOf(userName);
                        }

                        if (pos2 >= 0) {
                            String userName2 = path.substring(1, pos);
                            StringBuilder userHome2 = new StringBuilder();
                            if (pos2 > 0)
                                userHome2.append(userHome.substring(0, pos2));
                            userHome2.append(userName2);
                            pos2 += userName.length();
                            if (pos2 < userHome.length())
                                userHome2.append(userHome.substring(pos2));

                            file = new File(userHome2.toString() + 
                                            path.substring(pos));
                            makeItAbsolute = false;
                        }
                    }
                }
            }
                
            if (makeItAbsolute) {
                if (baseDir == null) {
                    String userDir = System.getProperty("user.dir");
                    if (userDir != null)
                        baseDir = new File(userDir);
                }

                if (SystemUtil.IS_WINDOWS) {
                    boolean isDriveRelative = false;

                    int pathLength = path.length();
                    if (pathLength >= 2 && path.charAt(1) == ':') {
                        char c0 = path.charAt(0);
                        isDriveRelative = ((c0 >= 'a' && c0 <= 'z') ||
                                           (c0 >= 'A' && c0 <= 'Z'));
                    }

                    if (isDriveRelative)
                        file = file.getAbsoluteFile();
                    else
                        file = new File(baseDir, path);
                } else {
                    file = new File(baseDir, path);
                }
            }
        }

        try {
            // Get rid of "." and "..": these are not useful and they
            // cause glob matching to always fail.

            file = file.getCanonicalFile();
        } catch (IOException ignored) {
            /*
            System.err.println("Cannot canonicalize '" + file + "': " + 
                               MiscUtil.detailedReason(ignored));
            */
        }

        return file;
    }

    /**
     * Utility used by the {@link #glob(String)} convenience method: List all
     * the files matching specified glob pattern.
     * 
     * @param patternsFile an absolute, canonical file, whose path possibly
     * contains one or more glob patterns. 
     * Example: "<tt>/home/john/src/_?/[A-Z]*.java</tt>".
     * @return a possibly empty array of absolute, canonical files.
     */
    public static File[] glob(File patternsFile) {
        // patternsFile is assumed to be an absolute, canonical, file
        // (otherwise glob matching will simply fail).
        //
        // On Windows, when the file is absolute and not canonical, it may
        // contain 8.3 parts! For example, this is the case for filenames 
        // returned by File.createTempFile.

        String rootPath = null;
        String tail = null;

        String patterns = patternsFile.getPath();
        if (SystemUtil.IS_WINDOWS) {
            // Examples: "\\host\foo", "c:\bar".
            int pos = patterns.indexOf('\\', 2);
            if (pos >= 2) {
                rootPath = patterns.substring(0, pos+1); // Including '\'.
                tail = patterns.substring(pos+1);
            }
        } else {
            if (patterns.startsWith("/")) {
                rootPath = "/";
                tail = patterns.substring(1);
            }
        }

        File root;
        if (rootPath == null ||
            !(root = new File(rootPath)).isDirectory()) { // e.g. "z:\".
            return new File[0];
        }

        if (tail.length() == 0) {
            return new File[] { root };
        }

        ArrayList<File> collect = new ArrayList<File>();
        doGlob(root, StringUtil.split(tail, File.separatorChar), 0, collect);

        File[] files = new File[collect.size()];
        collect.toArray(files);
        return files;
    }

    private static void doGlob(File dir, String[] parts, int partIndex,
                               ArrayList<File> collect) {
        final String part = parts[partIndex];

        FilenameFilter filter = GlobFilter.create(part);
        if (filter == null) {
            // Not a pattern, may be a plain file name.
            filter = new FilenameFilter() {
                public boolean accept(File dir, String name) {
                    return name.equals(part);
                }
            };
        }

        File[] files = dir.listFiles(filter);
        int fileCount;
        if (files == null || // Insufficient privileges.
            (fileCount = files.length) == 0)
            return;

        ++partIndex;
        if (partIndex == parts.length) {
            for (int j = 0; j < fileCount; ++j) 
                collect.add(files[j]);
        } else {
            for (int j = 0; j < fileCount; ++j) {
                File file = files[j];
                if (file.isDirectory())
                    doGlob(file, parts, partIndex, collect);
            }
        }
    }

    // -----------------------------------------------------------------------

    /*TEST_GLOB
    public static void main(String[] args) {
        if (args.length < 1) {
            System.err.println(
                "usage: java com.xmlmind.util.GlobFilter" +
                " path ... path");
            System.exit(1);
        }

        for (int i = 0; i < args.length; ++i) {
            String arg = args[i];

            System.out.print('\"');
            System.out.print(arg);
            System.out.println('\"');

            File[] files = GlobFilter.glob(arg);
            for (int j = 0; j < files.length; ++j) {
                System.out.print("\t\"");
                System.out.print(files[j]);
                System.out.println('\"');
            }

            System.out.println();
        }
    }
    TEST_GLOB*/
}

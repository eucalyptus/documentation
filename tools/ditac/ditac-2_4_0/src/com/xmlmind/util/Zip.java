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
import java.io.InputStream;
import java.io.FileInputStream;
import java.io.OutputStream;
import java.io.FileOutputStream;
import java.util.HashSet;
import java.util.zip.CRC32;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;
import java.util.jar.JarOutputStream;

/**
 * Utility class which makes it easier zipping and unzipping files. Also works
 * for <tt>.jar</tt> archives.
 */
public final class Zip {
    private Zip() {}

    // -----------------------------------------------------------------------
    // Zip
    // -----------------------------------------------------------------------

    /**
     * Creates a zip archive containing the content of specified directory.
     * 
     * @param srcDir directory containing the files to be zipped. This
     * directory is traversed recursively.
     * @param includingTopDir if <code>true</code>, the basename of the top
     * directory also appears in the created zip archive. Example: if
     * <tt>C:\foo\bar</tt> is to be zipped and this option is
     * <code>true</code>, all the paths contained in the zip archive will
     * start with "bar/".
     * @param filter may be used to filter the files to be zipped. May be
     * <code>null</code>, in which case, all the files and directory contained
     * in <tt>srcDir</tt> are to be zipped.
     * @param dstFile zip archive to be created
     * @exception IOException if there is an I/O problem during the creation
     * of the zip archive
     */
    public static void zip(File srcDir, boolean includingTopDir, 
                           FilenameFilter filter, File dstFile)
        throws IOException {
        if (!srcDir.isAbsolute())
            srcDir = srcDir.getAbsoluteFile();

        File baseDir = srcDir;
        if (includingTopDir) {
            baseDir = srcDir.getParentFile();
            if (baseDir == null)
                baseDir = srcDir;
        }

        Archive archive = 
            new Archive(new ZipOutputStream(new FileOutputStream(dstFile)));
        try {
            archive.addAll(srcDir, filter, baseDir);
        } finally {
            archive.close();
        }
    }

    /**
     * This class allows a fine-grained control on the files to be added to
     * the zip archive.
     */
    public static final class Archive {
        private ZipOutputStream zip;
        private HashSet<String> zipDirs;

        /**
         * Constructs a helper class which will allow to add files to the
         * specified destination zip stream.
         */
        public Archive(ZipOutputStream zip) {
            this.zip = zip;

            zipDirs = new HashSet<String>();
            if (zip instanceof JarOutputStream)
                zipDirs.add("META-INF/");
        }

        /**
         * Returns the underlying destination zip stream.
         */
        public ZipOutputStream getZipOutputStream() {
            return zip;
        }

        /**
         * Equivalent to {@link #add(File, File, boolean) 
         * add(srcFile, baseDir, false)}.
         */
        public void add(File srcFile, File baseDir)
            throws IOException, IllegalArgumentException {
            add(srcFile, baseDir, false);
        }

        /**
         * Adds specified file to the zip archive.
         * <p>Will automatically add directory entries if needed to. For
         * example, when adding "/tmp/foo/bar/gee.txt" relatively to "/tmp",
         * it will automatically add directory entries "foo/" and "foo/bar/".
         * <p>Note that this method does not check that a source file is added
         * only <em>once</em> to the archive. It is the resposability of the
         * client code to check this.
         * 
         * @param srcFile file or directory to be added
         * @param baseDir ancestor directory of <tt>srcFile</tt>. Used to
         * compute the path used to access <tt>srcFile</tt> in the zip
         * archive.
         * <p>Example: if <tt>srcFile</tt> is
         * <tt>C:\temp\doc\chapter1\chapter1.xml</tt> and <tt>baseDir</tt> is
         * <tt>C:\temp\doc</tt>, the zip archive will contain path
         * <tt>chapter1/chapter1.xml</tt>.
         * @param store if <code>true</code>, just store, that is do not 
         * compress, specified file. 
         * Ignored if <tt>srcFile</tt> is a directory.
         * @exception IOException if there is an I/O problem during the
         * creation of the zip archive
         * @exception IllegalArgumentException if <tt>baseDir</tt> does not
         * seem to be an ancestor directory of <tt>srcFile</tt>. Note that
         * this may happen simply because <tt>baseDir</tt> and/or
         * <tt>srcFile</tt> are not in canonical form
         */
        public void add(File srcFile, File baseDir, boolean store)
            throws IOException, IllegalArgumentException {
            String pathStart = baseDir.getPath();
            if (!pathStart.endsWith(File.separator)) // Example baseDir="/".
                pathStart += File.separatorChar;

            String path = srcFile.getPath();
            if (!path.startsWith(pathStart)) {
                throw new IllegalArgumentException(
                    "'" + baseDir + "' is not an ancestor directory of '" + 
                    srcFile + "'");
            }

            String relativePath = path.substring(pathStart.length());
            if (File.separatorChar != '/')
                relativePath = relativePath.replace(File.separatorChar, '/');

            if (srcFile.isDirectory()) {
                if (!relativePath.endsWith("/"))
                    relativePath += '/';

                createZipDirs(relativePath);
            } else {
                createZipDirs(relativePath);

                ZipEntry entry = new ZipEntry(relativePath);
                if (store) {
                    entry.setMethod(ZipEntry.STORED);
                    // This info is *really* required in the case of a STORED
                    // entry.
                    entry.setSize(srcFile.length());
                    entry.setCrc(computeCRC(srcFile));
                }
                zip.putNextEntry(entry);
                FileUtil.copyFile(srcFile, zip);
                zip.closeEntry();
            }
        }

        private void createZipDirs(String path) 
            throws IOException {
            path = parentPath(path); // Includes trailing '/'!
            if (path == null || path.length() == 0) {
                // Nothing to do: no parent. Example: path="foo.txt".
                return;
            }

            if (zipDirs.contains(path))
                // Already created.
                return;

            if (path.endsWith("/"))
                path = path.substring(0, path.length()-1);
            String[] split = StringUtil.split(path, '/');

            StringBuilder buffer = new StringBuilder();
            for (int i = 0; i < split.length; ++i) {
                String name = split[i];

                buffer.append(name);
                buffer.append('/');
                String ancestorPath = buffer.toString();

                if (!zipDirs.contains(ancestorPath)) {
                    ZipEntry entry = new ZipEntry(ancestorPath);
                    zip.putNextEntry(entry);
                    zip.closeEntry();

                    zipDirs.add(ancestorPath);
                }
            }
        }

        private static String parentPath(String path) {
            int slash = path.lastIndexOf('/');
            if (slash < 0)
                return null;

            // Path must end with a '/'.
            if (slash + 1 < path.length())
                path = path.substring(0, slash + 1);

            return path;
        }

        /**
         * Closes the underlying destination zip stream without closing its
         * output stream. Equivalent to
         * <code>getZipOutputStream().finish()</code>.
         */
        public void finish()
            throws IOException {
            zip.finish();
        }

        /**
         * Closes both the underlying destination zip stream and its output
         * stream. Equivalent to <code>getZipOutputStream().close()</code>.
         */
        public void close()
            throws IOException {
            try {
                zip.finish();
            } finally {
                zip.close();
            }
        }

        /**
         * Adds all files contained in specified directory to the zip archive.
         * 
         * @param srcDir directory containing the files to be zipped. This
         * directory is traversed recursively.
         * @param filter may be used to filter the files to be zipped. May be
         * <code>null</code>, in which case, all the files and directory
         * contained in <tt>srcDir</tt> are to be zipped.
         * @param baseDir ancestor directory of <tt>srcDir</tt>. May be equal
         * to <tt>srcDir</tt>. Used to compute the paths used to access the
         * files coming from <tt>srcDir</tt> in the zip archive.
         * @exception IOException if there is an I/O problem during the
         * creation of the zip archive
         * @see #add
         */
        public void addAll(File srcDir, FilenameFilter filter, File baseDir)
            throws IOException {
            File[] files = FileUtil.checkedListFiles(srcDir, filter);
            for (int i = 0; i < files.length; ++i) {
                File file = files[i];

                add(file, baseDir);

                if (file.isDirectory())
                    addAll(file, filter, baseDir);
            }
        }
    }

    /**
     * Utility: computes and returns the CRC-32 of specified file.
     */
    public static final long computeCRC(File file) 
        throws IOException {
        InputStream in = new FileInputStream(file);
        CRC32 crc = new CRC32();
        byte[] bytes = new byte[65536];
        int count;

        try {
            while ((count = in.read(bytes)) >= 0)
                crc.update(bytes, 0, count);
        } finally {
            in.close();
        }

        return crc.getValue();
    }

    // -----------------------------------------------------------------------
    // Unzip
    // -----------------------------------------------------------------------

    /**
     * Extracts files contained in specified stream to specified directory.
     * <p>Closes input stream when done.
     * 
     * @param srcFile source Zip file from which to extract files
     * @param dstDir directory where files are to be extracted
     * @exception IOException if an I/O problem occurs during the extraction
     * of files
     */
    public static void unzip(File srcFile, File dstDir) 
        throws IOException {
        ZipInputStream zip = new ZipInputStream(new FileInputStream(srcFile));
        try {
            unzip(zip, dstDir);
        } finally {
            zip.close();
        }
    }

    /**
     * Extracts file contained in specified stream to specified directory.
     * <p>Does not close zip input stream when done.
     * 
     * @param zip zip stream or jar stream from which to extract files
     * @param dstDir directory where files are to be extracted
     * @exception IOException if an I/O problem occurs during the extraction
     * of files
     */
    public static void unzip(ZipInputStream zip, File dstDir) 
        throws IOException {
        ZipEntry entry;
        while ((entry = zip.getNextEntry()) != null) {
            File dstFile =
                new File(fromZipEntryName(dstDir, entry.getName()));

            if (entry.isDirectory()) {
                // Create empty directory.
                if (!dstFile.isDirectory())
                    FileUtil.checkedMkdirs(dstFile);
            } else {
                // Create parent directory on the fly.
                File parentDir = dstFile.getParentFile();
                if (!parentDir.isDirectory())
                    FileUtil.checkedMkdirs(parentDir);

                // zip.read() returns -1 at the end of the *entry*.
                FileUtil.copyFile(zip, dstFile);
            }

            zip.closeEntry();
        }
    }

    private static String fromZipEntryName(File dir, String path) {
        // Directory pathnames ends with '/': remove it.
        int pathLength = path.length();
        if (pathLength > 1 && path.endsWith("/"))
            path = path.substring(0, pathLength - 1);

        // Zip entry names always use '/' as a separator.
        if (File.separatorChar != '/')
            path = path.replace('/', File.separatorChar);

        return dir.getPath() + File.separatorChar + path;
    }

    // -----------------------------------------------------------------------
    // Test
    // -----------------------------------------------------------------------

    /*TEST_ZIP
    public static void main(String[] args) throws IOException {
        if (args.length != 3) 
            usage();

        if ("-z".equals(args[0]) || "-zz".equals(args[0])) {
            File srcDir = new File(args[1]);
            if (!srcDir.isDirectory())
                usage();

            File dstFile = new File(args[2]);

            zip(srcDir, "-zz".equals(args[0]), null, dstFile);
        } else if ("-u".equals(args[0])) {
            File srcFile = new File(args[1]);
            if (!srcFile.isFile())
                usage();
            
            File dstDir = new File(args[2]);
            if (!dstDir.isDirectory())
                usage();

            unzip(srcFile, dstDir);
        } else {
            usage();
        }
    }

    private static void usage() {
        System.err.println("java com.xmlmind.util.Zip\n" +
                           "\t  -z src_dir dst_zip_file\n" +
                           "\t  -zz src_dir dst_zip_file\n" +
                           "\t| -u src_zip_file dst_dir");
        System.exit(1);
    }
    TEST_ZIP*/
}

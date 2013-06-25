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
import java.io.FileFilter;
import java.io.FilenameFilter;
import java.io.InputStream;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.FileOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.OutputStreamWriter;
import java.net.URI;
import java.net.URL;
import java.util.Locale;
import java.text.DecimalFormatSymbols;
import java.text.DecimalFormat;

/**
 * A collection of utility functions (static methods) operating on Files.
 */
public final class FileUtil {
    private FileUtil() {}

    /**
     * A ready-to-use empty list of Files.
     */
    public static final File[] EMPTY_LIST = new File[0];

    /**
     * Similar to {@link #fileToURL}, expect that it returns an URI.
     *
     * @see URLUtil#urlToURI
     */
    public static URI fileToURI(File file) {
        URL url = fileToURL(file);
        return (url == null)? null : URLUtil.urlToURI(url);
    }

    /**
     * Converts a File to a <tt>file:</tt> URL. Ends with a '/' if specified
     * file is a directory.
     * <p>On Windows, this function supports UNC filenames. For example, it
     * converts "<tt>\\foo\bar\gee.txt</tt>" to 
     * "<tt>file://foo/bar/gee.txt</tt>".
     * (Note that <code>URL.openStream</code> works fine on such URL.)
     * 
     * @param file the file to be converted
     * @return a <tt>file:</tt> URL
     * @see URLUtil#urlToFile
     */
    public static URL fileToURL(File file) {
        if (SystemUtil.IS_WINDOWS) {
            boolean normalize = true;
            try {
                file = file.getCanonicalFile();
                normalize = false;
            } catch (IOException ignored) {
                file = file.getAbsoluteFile();
            }

            String volume = getVolume(file);
            if (volume != null && volume.startsWith("\\\\")) {
                // Special processing of UNC paths ---

                String path = file.getPath();
                if (path.equals(volume)) {
                    path += "\\";
                }
                path = "C:" + path.substring(volume.length());
                // Note that new File() removes the trailing '\\'.
                URI uri = (new File(path)).toURI();
                if (normalize) {
                    uri = uri.normalize();
                }

                path = uri.toASCIIString();
                if (file.isDirectory() && !path.endsWith("/")) {
                    path += "/";
                }
                // Remove leading "file:/C:".
                path = path.substring(8);

                try {
                    return new URL("file:" + 
                                   volume.replace('\\', '/') + path);
                } catch (Exception cannotHappen) {
                    cannotHappen.printStackTrace();
                    return null;
                }
            } else {
                return convertFileToURL(file, normalize);
            }
        } else {
            return convertFileToURL(file);
        }
    }

    private static URL convertFileToURL(File file) {
        boolean normalize = true;
        if (SystemUtil.IS_WINDOWS) {
            try {
                file = file.getCanonicalFile();
                normalize = false;
            } catch (IOException ignored) {}
        }
        // Do not use getCanonicalFile on Unix because this resolves symlinks.

        return convertFileToURL(file, normalize);
    }

    private static URL convertFileToURL(File file, boolean normalize) {
        URI uri = file.toURI();
        if (normalize) {
            uri = uri.normalize();
        }

        try {
            // URI.toURL does not %HH-encode accented chars.
            return new URL(uri.toASCIIString());
        } catch (Exception cannotHappen) {
            cannotHappen.printStackTrace();
            return null;
        }
    }

    /*TEST_URL
    public static void main(String[] args) {
        for (int i = 0; i < args.length; ++i) {
            String arg = XMLText.unescapeXML(args[i]);
            File file = new File(arg);

            URL url = fileToURL(file);
            System.out.println("'" + arg + "'");
            System.out.println("\tURL='" + url.toExternalForm() + "'");
            System.out.println("\tfile='" + URLUtil.urlToFile(url) + "'");
            System.out.println("----------");
        }
    }
    TEST_URL*/

    // -----------------------------------------------------------------------

    /**
     * Returns the extension of specified file. To make it simple, the
     * substring after last '.', not including last '.'.
     * <ul>
     * <li>Returns <code>null</code> for "<tt>/tmp/test</tt>".
     * <li>Returns the empty string for "<tt>/tmp/test.</tt>".
     * <li>Returns <code>null</code> for "<tt>~/.profile</tt>".
     * <li>Returns "<tt>gz</tt>" for "<tt>/tmp/test.tar.gz</tt>".
     * </ul>
     * 
     * @param file absolute or relative pathname possibly having an extension
     * @return extension if any; <code>null</code> otherwise
     * @see #setExtension
     */
    public static String getExtension(File file) {
        return getExtension(file.getPath());
    }

    /**
     * Similar to {@link #getExtension(File)} except that it acts 
     * on a filename rather than on a File.
     */
    public static String getExtension(String path) {
        int dot = indexOfDot(path, File.separatorChar);
        if (dot < 0) {
            return null;
        } else {
            return path.substring(dot+1);
        }
    }

    /**
     * Returns the extension of specified path. To make it simple, the
     * substring after last '.', not including last '.'.
     *
     * @param path an absolute or relative path
     * @param separatorChar the character used to separate path segments
     * @return extension if any; <code>null</code> otherwise
     */
    public static int indexOfDot(String path, char separatorChar) {
        int dot = path.lastIndexOf('.');
        if (dot >= 0) {
            int baseNameStart = path.lastIndexOf(separatorChar);
            if (baseNameStart < 0) {
                baseNameStart = 0;
            } else {
                ++baseNameStart;
            }

            if (dot <= baseNameStart) {
                dot = -1;
            }
        }

        return dot;
    }

    /**
     * Changes the extension of specified file to specified extension. See
     * {@link #getExtension} for a description of the extension of a pathname.
     * 
     * @param file absolute or relative pathname
     * @param extension new extension. May be <code>null</code> which means:
     * remove the extension.
     * @return a pathname identical to <tt>file</tt> except that its extension
     * has been changed or removed.
     * <p>Returns same pathname if specified pathname ends with
     * <code>File.separator</code>.
     */
    public static File setExtension(File file, String extension) {
        String path = file.getPath();
        String path2 = setExtension(path, extension);
        if (path2.equals(path)) {
            return file;
        } else {
            return new File(path2);
        }
    }

    /**
     * Similar to {@link #setExtension(File, String)} except that it acts 
     * on a filename rather than on a File.
     */
    public static String setExtension(String path, String extension) {
        if (path.endsWith(File.separator)) {
            return path;
        }

        int dot = indexOfDot(path, File.separatorChar);
        if (dot < 0) {
            if (extension == null) {
                return path;
            } else {
                return path + "." + extension;
            }
        } else {
            if (extension == null) {
                return path.substring(0, dot);
            } else {
                return path.substring(0, dot+1) + extension;
            }
        }
    }

    /*TEST_EXTENSION
    public static void main(String[] args) {
        for (int i = 0; i < args.length; ++i) {
            File file = new File(args[i]);

            System.out.println("'" + file.getPath() + "'");
            System.out.println("\textension='" + 
                               FileUtil.getExtension(file) + "'");
            System.out.println("\twithout any extension='" + 
                               FileUtil.setExtension(file, null) + "'");
            System.out.println("\textension changed to 'foo'='" + 
                               FileUtil.setExtension(file, "foo") + "'");
        }
    }
    TEST_EXTENSION*/

    // -----------------------------------------------------------------------

    /**
     * Returns the path of specified file relative to specified base.
     * <p>Example: returns <tt>../local/bin/html2ps</tt> for
     * <tt>/usr/local/bin/html2ps</tt> relative to <tt>/usr/bin/grep</tt>.
     * 
     * @param file a relative or absolute filename
     * @param base another a relative or absolute filename
     * @return first filename as a filename relative to the second filename.
     * Returns first filename as is, if the relative filename cannot be
     * computed.
     */
    public static String getRelativePath(File file, File base) {
        String[] paths = new String[2];
        String nonRelativePath = getNonRelativePath(file, base, paths);
        if (nonRelativePath != null) {
            return nonRelativePath;
        }
        // Note that path1 and path2 do not start with a volume.
        // (The common volume has been removed by getNonRelativePath.)
        String path1 = paths[0];
        String path2 = paths[1];

        if (SystemUtil.IS_WINDOWS) {
            path1 = path1.replace('\\', '/');
            path2 = path2.replace('\\', '/');

            String relativePath =
                URIComponent.getRawRelativePath(path1, path2);

            // Windows filenames are case insensitive. 
            // Retry after converting both paths to lower case in case
            // this gives a different result.

            path1 = path1.toLowerCase();
            path2 = path2.toLowerCase();

            String relativePath2 =
                URIComponent.getRawRelativePath(path1, path2);
            if (!relativePath2.equalsIgnoreCase(relativePath)) {
                relativePath = relativePath2;
            }

            return relativePath.replace('/', '\\');
        } else {
            return URIComponent.getRawRelativePath(path1, path2);
        }
    }

    /*package*/ static String getNonRelativePath(File file, File base,
                                                 String[] paths) {
        // "C:" is not considered to be absolute and 
        // is converted to "C:\current_working_directory_of_C_drive".
        if (!file.isAbsolute()) {
            file = file.getAbsoluteFile();
        }
        String path1 = file.getPath();

        if (!base.isAbsolute()) {
            base = base.getAbsoluteFile();
        }

        if (!base.isDirectory()) {
            base = base.getParentFile();
            if (base == null) {
                return path1;
            }
        }

        String path2 = base.getPath();
        if (!path2.endsWith(File.separator)) {
            path2 += File.separator;
        }

        // Volumes (e.g. "" on Unix, "C:" on Windows) are always case
        // insensitive).
        String volume1 = getVolume(file);
        String volume2 = getVolume(base);
        if (volume1 == null || 
            volume2 == null ||
            !volume1.equalsIgnoreCase(volume2) ||
            path1.equals(volume1 + File.separator)) {
            return path1;
        }

        if (paths != null) {
            // Convert 'C:\Foo\Bar' to '\Foo\Bar'.
            paths[0] = path1.substring(volume1.length());
            paths[1] = path2.substring(volume2.length());
        }
        // No non-relative path.
        return null;
    }

    /**
     * Returns the volume of specified file.
     * <p>Returns something like "C:" or "\\server\share" on Windows. Returns
     * "" on all the other platforms.
     * 
     * @param file a relative or absolute filename
     * @return the volume of specified file or <code>null</code> if specified
     * filename is malformed (e.g. "\\server").
     */
    public static String getVolume(File file) {
        if (SystemUtil.IS_WINDOWS) {
            String path;
            if (file.isAbsolute()) {
                path = file.getPath();
            } else {
                path = file.getAbsolutePath();
            }

            if (path.startsWith("\\\\")) {
                int pos = path.indexOf('\\', 2);
                if (pos >= 0) {
                    int pos2 = path.indexOf('\\', pos+1);
                    if (pos2 >= 0) {
                        return path.substring(0, pos2);
                    } else {
                        if (path.length() > pos+1) {
                            return path;
                        }
                    }
                }
            } else {
                char drive = '\0';
                if (path.length() >= 2 &&
                    path.charAt(1) == ':' &&
                    ((drive = path.charAt(0)) >= 'A' && drive <= 'Z') ||
                    (drive >= 'a' && drive <= 'z')) {
                    return path.substring(0, 2);
                }
            }
            return null;
        } else {
            return "";
        }
    }

    /*TEST_RELATIVIZE
    public static void main(String[] args) throws IOException {
        int count = (args.length / 2) * 2;
        for (int i = 0; i < count; i += 2) {
            File file = new File(args[i]);
            File baseFile = new File(args[i+1]);

            String relativePath = getRelativePath(file, baseFile);
            
            System.out.println("'" + file + "' (volume='" + 
                               getVolume(file) + "')");
            System.out.println("base='" + baseFile + "' (volume='" + 
                               getVolume(baseFile) + "')");
            System.out.println("\trelativePath='" + relativePath + "'");

            File canonical = new File(relativePath);
            if (!canonical.isAbsolute()) {
                File parent = baseFile.getAbsoluteFile();
                if (!parent.isDirectory()) {
                    parent = parent.getParentFile();
                }
                canonical = (new File(parent,relativePath)).getCanonicalFile();
            }
            System.out.println("\tcanonical='" + canonical + "'");
            System.out.println("----------");
        }
    }
    TEST_RELATIVIZE*/

    // -----------------------------------------------------------------------

    /**
     * Like <code>java.io.File.delete()</code> but raises an IOException if
     * this method returns <code>false</code>.
     */
    public static void checkedDelete(File file) 
        throws IOException {
        if (!file.delete()) {
            throw new IOException(Msg.msg("cannotDelete", file));
        }
    }

    /**
     * Like <code>java.io.File.renameTo()</code> but raises an IOException if
     * this method returns <code>false</code>.
     */
    public static void checkedRename(File from, File to) 
        throws IOException {
        if (!from.renameTo(to)) {
            throw new IOException(Msg.msg("cannotRename", from, to));
        }
    }

    /**
     * Like <code>java.io.File.mkdir()</code> but raises an IOException if
     * this method returns <code>false</code>.
     */
    public static void checkedMkdir(File dir) 
        throws IOException {
        if (!dir.mkdir()) {
            throw new IOException(Msg.msg("cannotMkdir", dir));
        }
    }

    private static final Object mkdirsLock = new Object();

    /**
     * Like <code>java.io.File.mkdirs()</code> but raises an IOException if
     * this method returns <code>false</code>.
     * <p>Unlike <code>java.io.File.mkdirs()</code> which does not seem
     * to be thread-safe, this variant is thread-safe.
     */
    public static void checkedMkdirs(File dir) 
        throws IOException {
        synchronized (mkdirsLock) {
            if (!dir.mkdirs()) {
                throw new IOException(Msg.msg("cannotMkdir", dir));
            }
        }
    }

    /**
     * Like <code>java.io.File.listFiles()</code> but raises an IOException if
     * this method returns <code>null</code>.
     */
    public static File[] checkedListFiles(File dir) 
        throws IOException {
        return checkedListFiles(dir, (FilenameFilter) null);
    }

    /**
     * Like <code>java.io.File.listFiles(FilenameFilter)</code> but raises an
     * IOException if this method returns <code>null</code>.
     */
    public static File[] checkedListFiles(File dir, FilenameFilter filter) 
        throws IOException {
        File[] files = dir.listFiles(filter);
        if (files == null) {
            throw new IOException(Msg.msg("cannotList", dir));
        }
        return files;
    }

    /**
     * Like <code>java.io.File.listFiles(FileFilter)</code> but raises an
     * IOException if this method returns <code>null</code>.
     */
    public static File[] checkedListFiles(File dir, FileFilter filter) 
        throws IOException {
        File[] files = dir.listFiles(filter);
        if (files == null) {
            throw new IOException(Msg.msg("cannotList", dir));
        }
        return files;
    }

    /**
     * Like <code>java.io.File.list()</code> but raises an IOException if this
     * method returns <code>null</code>.
     */
    public static String[] checkedList(File dir) 
        throws IOException {
        return checkedList(dir, null);
    }

    /**
     * Like <code>java.io.File.list(FilenameFilter)</code> but raises an
     * IOException if this method returns <code>null</code>.
     */
    public static String[] checkedList(File dir, FilenameFilter filter) 
        throws IOException {
        String[] baseNames = dir.list(filter);
        if (baseNames == null) {
            throw new IOException(Msg.msg("cannotList", dir));
        }
        return baseNames;
    }

    /**
     * Like <code>java.io.File.setLastModified()</code> but raises an
     * IOException if this method returns <code>false</code>.
     */
    public static void checkedSetLastModified(File file, long date) 
        throws IOException {
        if (!file.setLastModified(date)) {
            throw new IOException(Msg.msg("cannotSetFileDate", file));
        }
    }

    /**
     * Like <code>java.io.File.createNewFile()</code> but raises an
     * IOException if this method returns <code>false</code>.
     */
    public static void checkedCreateNewFile(File file) 
        throws IOException {
        if (!file.createNewFile()) {
            throw new IOException(Msg.msg("cannotCreateFile", file));
        }
    }

    // -----------------------------------------------------------------------

    private static final DecimalFormat fileSizeFormatDefault = 
        new DecimalFormat("0.#");
    private static final DecimalFormat fileSizeFormatUS = 
        new DecimalFormat("0.#", new DecimalFormatSymbols(Locale.US));

    /**
     * Equivalent to {@link #formatFileSize(long, Locale)
     * formatFileSize(fileSize, null)}.
     */
    public static String formatFileSize(long fileSize) {
        return formatFileSize(fileSize, null);
    }

    /**
     * Returns a localized, formatted, form of specified file size.
     * <p>For example, returns "56.5Gb" when passed 59279560 in the US locale.
     */
    public static String formatFileSize(long fileSize, Locale locale) {
        DecimalFormat format;
        if (locale == null || Locale.getDefault().equals(locale)) {
            format = fileSizeFormatDefault;
        } else if (Locale.US.equals(locale)) {
            format = fileSizeFormatUS;
        } else {
            format = 
                new DecimalFormat("0.#", new DecimalFormatSymbols(locale));
        }

        double byteCount = fileSize;
        if (byteCount > 1073741824) {
            return format.format(byteCount/1073741824) + 
                Msg.msg("fileSizeUnit.gigabytes");
        } else if (byteCount > 1048576) {
            return format.format(byteCount/1048576) + 
                Msg.msg("fileSizeUnit.megabytes");
        } else if (byteCount > 1024) {
            return format.format(byteCount/1024) + 
                Msg.msg("fileSizeUnit.kilobytes");
        } else {
            return format.format(byteCount) +
                Msg.msg("fileSizeUnit.bytes");
        }
    }

    // -----------------------------------------------------------------------

    /**
     * Removes all the files contained in specified directory.
     * 
     * @param dir directory to be made empty
     * @exception IOException if, for any reason, the directory cannot be made
     * empty
     */
    public static void emptyDir(File dir) 
        throws IOException {
        if (!doEmptyDir(dir)) {
            throw new IOException(Msg.msg("cannotEmptyDir", dir));
        }
    }

    /**
     * Removes all the files contained in specified directory.
     * 
     * @param dir directory to be made empty
     * @return <code>true</code> if the directory has been made empty;
     * <code>false</code> otherwise
     */
    public static boolean doEmptyDir(File dir) {
        File[] children = dir.listFiles();
        if (children == null) {
            return false;
        }

        for (int i = 0; i < children.length; ++i) {
            File child = children[i];

            if (child.isDirectory() && !doEmptyDir(child)) {
                return false;
            }

            if (!child.delete()) {
                return false;
            }
        }

        return true;
    }

    /**
     * Returns <code>true</code> if specified file exists, is a directory and
     * is empty. Returns <code>false</code> otherwise.
     *
     * @see #checkIsEmptyDir
     */
    public static boolean isEmptyDir(File file) {
        if (!file.isDirectory()) {
            return false;
        } else {
            String[] baseNames = file.list();
            return (baseNames != null && baseNames.length == 0);
        }
    }

    /**
     * Check whether if specified file exists, is a directory and
     * is empty. If this is not the case, throw an <tt>IOException</tt>.
     *
     * @see #isEmptyDir
     */
    public static void checkIsEmptyDir(File file) 
        throws IOException {
        if (!isEmptyDir(file)) {
            throw new IOException(Msg.msg("notAnEmptyDir", file));
        }
    }

    // -----------------------------------------------------------------------

    /**
     * Deletes specified file or directory. A directory is recursively
     * deleted.
     * 
     * @param fileOrDir file or directory to be deleted
     * @param console a message describing the operation is displayed on this
     * console. May be <code>null</code>.
     * @exception IOException if, for any reason, specified file or directory
     * cannot be deleted
     */
    public static void deleteFileOrDir(File fileOrDir, Console console) 
        throws IOException {
        if (fileOrDir.isDirectory()) {
            deleteDir(fileOrDir, console);
        } else {
            deleteFile(fileOrDir, console);
        }
    }

    /**
     * Deletes specified directory. A directory is recursively deleted.
     * 
     * @param dir directory to be deleted
     * @param console a message describing the operation is displayed on this
     * console. May be <code>null</code>.
     * @exception IOException if, for any reason, specified directory cannot
     * be deleted
     */
    public static void deleteDir(File dir, Console console)
        throws IOException {
        if (console != null) {
            console.showMessage(Msg.msg("deletingDir", dir),
                                Console.MessageType.VERBOSE);
        }

        deleteDir(dir);
    }

    /**
     * Deletes specified file (not a directory).
     * 
     * @param file file to be deleted
     * @param console a message describing the operation is displayed on this
     * console. May be <code>null</code>.
     * @exception IOException if, for any reason, specified file cannot be
     * deleted
     */
    public static void deleteFile(File file, Console console)
        throws IOException {
        if (console != null) {
            console.showMessage(Msg.msg("deletingFile", file),
                                Console.MessageType.VERBOSE);
        }

        deleteFile(file);
    }

    /**
     * Deletes specified file or directory. A directory is recursively
     * deleted.
     * 
     * @param fileOrDir file or directory to be deleted
     * @exception IOException if, for any reason, specified file or directory
     * cannot be deleted
     */
    public static void deleteFileOrDir(File fileOrDir) 
        throws IOException {
        if (fileOrDir.isDirectory()) {
            deleteDir(fileOrDir);
        } else {
            deleteFile(fileOrDir);
        }
    }

    /**
     * Deletes specified file or directory. A directory is recursively
     * deleted.
     * 
     * @param fileOrDir file or directory to be deleted
     * @return <code>true</code> if specified file or directory has been
     * deleted; <code>false</code> otherwise
     */
    public static boolean doDeleteFileOrDir(File fileOrDir) {
        if (fileOrDir.isDirectory() && !doEmptyDir(fileOrDir)) {
            return false;
        }

        return fileOrDir.delete();
    }

    /**
     * Deletes specified directory. A directory is recursively deleted.
     * 
     * @param dir directory to be deleted
     * @exception IOException if, for any reason, specified directory cannot
     * be deleted
     */
    public static void deleteDir(File dir)
        throws IOException {
        if (!doEmptyDir(dir) || !dir.delete()) {
            throw new IOException(Msg.msg("cannotDeleteDir", dir));
        }
    }

    /**
     * Deletes specified file (not a directory).
     * 
     * @param file file to be deleted
     * @exception IOException if, for any reason, specified file cannot be
     * deleted
     */
    public static void deleteFile(File file)
        throws IOException {
        if (!file.delete()) {
            throw new IOException(Msg.msg("cannotDeleteFile", file));
        }
    }

    // -----------------------------------------------------------------------

    /**
     * Copies specified file or directory. Directories are recursively copied.
     * <p>If a directory is to be copied, the target of the copy operation
     * must not exist. If a file is to be copied and the target of the copy
     * operation already exists, this target is overwritten.
     * 
     * @param srcFileOrDir file or directory to be copied
     * @param dstFileOrDir target of the copy operation
     * @param sameDate if <code>true</code>, a copied file has the same last
     * modified date as the original file. If <code>false</code>, a copied
     * file has the date of its creation as its last modified date.
     * @param console a message describing the operation is displayed on this
     * console. May be <code>null</code>.
     * @exception IOException if, for any reason, specified file or directory
     * cannot be copied
     */
    public static void copyFileOrDir(File srcFileOrDir, File dstFileOrDir, 
                                     boolean sameDate, Console console) 
        throws IOException {
        if (srcFileOrDir.isDirectory()) {
            copyDir(srcFileOrDir, dstFileOrDir, sameDate, console);
        } else {
            copyFile(srcFileOrDir, dstFileOrDir, sameDate, console);
        }
    }

    /**
     * Recursively copies specified directory. The target of the copy
     * operation must not exist.
     * 
     * @param srcDir directory to be copied
     * @param dstDir target of the copy operation
     * @param sameDate if <code>true</code>, a copied file has the same last
     * modified date as the original file. If <code>false</code>, a copied
     * file has the date of its creation as its last modified date.
     * @param console a message describing the operation is displayed on this
     * console. May be <code>null</code>.
     * @exception IOException if, for any reason, specified directory cannot
     * be copied
     */
    public static void copyDir(File srcDir, File dstDir, boolean sameDate,
                               Console console) 
        throws IOException {
        if (console != null) {
            console.showMessage(Msg.msg("copyingDir", srcDir, dstDir),
                                Console.MessageType.VERBOSE);
        }

        copyDir(srcDir, dstDir, sameDate);
    }

    /**
     * Copies specified file (not a directory). If the target of the copy
     * operation already exists, this target is overwritten.
     * 
     * @param srcFile file to be copied
     * @param dstFile target of the copy operation
     * @param sameDate if <code>true</code>, a copied file has the same last
     * modified date as the original file. If <code>false</code>, a copied
     * file has the date of its creation as its last modified date.
     * @param console a message describing the operation is displayed on this
     * console. May be <code>null</code>.
     * @exception IOException if, for any reason, specified file cannot be
     * copied
     */
    public static void copyFile(File srcFile, File dstFile, boolean sameDate,
                                Console console) 
        throws IOException {
        if (console != null) {
            console.showMessage(Msg.msg("copyingFile", srcFile, dstFile),
                                Console.MessageType.VERBOSE);
        }

        copyFile(srcFile, dstFile, sameDate);
    }

    /**
     * Copies specified file or directory. Directories are recursively copied.
     * <p>If a directory is to be copied, the target of the copy operation
     * must not exist. If a file is to be copied and the target of the copy
     * operation already exists, this target is overwritten.
     * 
     * @param srcFileOrDir file or directory to be copied
     * @param dstFileOrDir target of the copy operation
     * @param sameDate if <code>true</code>, a copied file has the same last
     * modified date as the original file. If <code>false</code>, a copied
     * file has the date of its creation as its last modified date.
     * @exception IOException if, for any reason, specified file or directory
     * cannot be copied
     */
    public static void copyFileOrDir(File srcFileOrDir, File dstFileOrDir, 
                                     boolean sameDate) 
        throws IOException {
        if (srcFileOrDir.isDirectory()) {
            copyDir(srcFileOrDir, dstFileOrDir, sameDate);
        } else {
            copyFile(srcFileOrDir, dstFileOrDir, sameDate);
        }
    }

    /**
     * Recursively copies specified directory. The target of the copy
     * operation must not exist.
     * 
     * @param srcDir directory to be copied
     * @param dstDir target of the copy operation
     * @param sameDate if <code>true</code>, a copied file has the same last
     * modified date as the original file. If <code>false</code>, a copied
     * file has the date of its creation as its last modified date.
     * @exception IOException if, for any reason, specified directory cannot
     * be copied
     */
    public static void copyDir(File srcDir, File dstDir, boolean sameDate) 
        throws IOException {
        checkedMkdir(dstDir);

        File[] srcFiles = checkedListFiles(srcDir);
        for (int i = 0; i < srcFiles.length; ++i) {
            File srcFile = srcFiles[i];
            File dstFile = new File(dstDir, srcFile.getName());

            if (srcFile.isDirectory()) {
                copyDir(srcFile, dstFile, sameDate);
            } else {
                copyFile(srcFile, dstFile, sameDate);
            }
        }
    }

    /**
     * Copies specified file (not a directory). If the target of the copy
     * operation already exists, this target is overwritten.
     * 
     * @param srcFile file to be copied
     * @param dstFile target of the copy operation
     * @param sameDate if <code>true</code>, a copied file has the same last
     * modified date as the original file. If <code>false</code>, a copied
     * file has the date of its creation as its last modified date.
     * @exception IOException if, for any reason, specified file cannot be
     * copied
     */
    public static void copyFile(File srcFile, File dstFile, boolean sameDate) 
        throws IOException {
        copyFile(srcFile, dstFile);

        if (sameDate) {
            checkedSetLastModified(dstFile, srcFile.lastModified());
        }
    }

    /**
     * Copies specified file (not a directory). If the target of the copy
     * operation already exists, this target is overwritten.
     * 
     * @param srcFile file to be copied
     * @param dstFile target of the copy operation
     * @exception IOException if, for any reason, specified file cannot be
     * copied
     */
    public static void copyFile(File srcFile, File dstFile) 
        throws IOException {
        FileInputStream src = new FileInputStream(srcFile);
        try {
            copyFile(src, dstFile);
        } finally {
            src.close();
        }
    }

    /**
     * Copies the contents of specified URL to specified file.
     * 
     * @param url URL to be copied
     * @param dstFile destination file
     * @exception IOException if an I/O problem occurs
     */
    public static void copyFile(URL url, File dstFile) 
        throws IOException {
        InputStream src = url.openStream();
        try {
            copyFile(src, dstFile);
        } finally {
            src.close();
        }
    }

    /**
     * Copies specified source to specified file.
     * 
     * @param src source stream
     * @param dstFile destination file
     * @exception IOException if an I/O problem occurs
     */
    public static void copyFile(InputStream src, File dstFile)
        throws IOException {
        FileOutputStream dst = new FileOutputStream(dstFile);

        try {
            copyFile(src, dst);
        } finally {
            dst.close();
        }
    }

    /**
     * Copies specified file to specified destination.
     * 
     * @param srcFile source file
     * @param dst destination stream
     * @exception IOException if an I/O problem occurs
     */
    public static void copyFile(File srcFile, OutputStream dst)
        throws IOException {
        FileInputStream src = new FileInputStream(srcFile);

        try {
            copyFile(src, dst);
        } finally {
            src.close();
        }
    }

    /**
     * Copies input to output. Does <em>not</close> close streams 
     * after copying the data.
     *
     * @see #copyBytes
     */
    public static final void copyFile(InputStream in, OutputStream out)
        throws IOException {
        byte[] buffer = new byte[65535];
        int count;

        while ((count = in.read(buffer)) != -1) {
            out.write(buffer, 0, count);
        }

        out.flush();
    }

    // -----------------------------------------------------------------------

    /**
     * Loads the content of a text file. The encoding of the text is assumed
     * to be the native encoding of the platform.
     * 
     * @param file the text file
     * @return the loaded String
     * @exception IOException if there is an I/O problem
     */
    public static String loadString(File file) throws IOException {
        return loadString(file, null);
    }

    /**
     * Loads the content of a text file. The encoding of the text is assumed
     * to be the native encoding of the platform.
     * 
     * @param file the text file
     * @param charsetName the IANA charset of the text source if known;
     * <code>null</code> may be used to specify the native encoding of the
     * platform
     * @return the loaded String
     * @exception IOException if there is an I/O problem
     */
    public static String loadString(File file, String charsetName) 
        throws IOException {
        InputStream in = new FileInputStream(file);

        String loaded = null;
        try {
            loaded = loadString(in, charsetName);
        } finally {
            in.close();
        }

        return loaded;
    }

    /**
     * Loads the content of an InputStream returning text.
     * 
     * @param stream the text source
     * @param charsetName the IANA charset of the text source if known;
     * <code>null</code> may be used to specify the native encoding of the
     * platform
     * @return the loaded String
     * @exception IOException if there is an I/O problem
     */
    public static String loadString(InputStream stream, String charsetName) 
        throws IOException {
        InputStreamReader in;
        if (charsetName == null) {
            in = new InputStreamReader(stream);
        } else {
            in = new InputStreamReader(stream, charsetName);
        }

        StringBuilder buffer = new StringBuilder();
        char[] chars = new char[65536];
        int count;

        while ((count = in.read(chars, 0, chars.length)) != -1) {
            if (count > 0) {
                buffer.append(chars, 0, count);
            }
        }

        return buffer.toString();
    }

    // -----------------------------------------------------------------------

    /**
     * Saves some text to a file.
     * 
     * @param string the text to be saved
     * @param file the destination file
     * @exception IOException if there is an I/O problem
     */
    public static void saveString(String string, File file) 
        throws IOException {
        saveString(string, file, null);
    }

    /**
     * Saves some text to a file.
     * 
     * @param string the text to be saved
     * @param file the destination file
     * @param charsetName the IANA charset of the saved file;
     * <code>null</code> may be used to specify the native encoding of the
     * platform
     * @exception IOException if there is an I/O problem
     */
    public static void saveString(String string, File file, 
                                  String charsetName) 
        throws IOException {
        OutputStream out = new FileOutputStream(file);

        try {
            saveString(string, out, charsetName);
        } finally {
            out.close();
        }
    }

    /**
     * Saves some text to an OutputStream.
     * 
     * @param string the text to be saved
     * @param stream the text sink
     * @param charsetName the IANA charset of the saved characters;
     * <code>null</code> may be used to specify the native encoding of the
     * platform
     * @exception IOException if there is an I/O problem
     */
    public static void saveString(String string, OutputStream stream, 
                                  String charsetName) 
        throws IOException {
        OutputStreamWriter out;
        if (charsetName == null) {
            out = new OutputStreamWriter(stream);
        } else {
            out = new OutputStreamWriter(stream, charsetName);
        }

        out.write(string, 0, string.length());
        out.flush();
    }

    // -----------------------------------------------------------------------

    /**
     * Tests if specified data has been compressed using gzip.
     */
    public static final boolean isGzipped(byte[] bytes) {
        if (bytes.length <= 2) {
            return false;
        } else {
            return ((bytes[0] & 0xFF) == 0037 && (bytes[1] & 0xFF) == 0213);
        }
    }

    /**
     * Copies input to output. 
     * <em>Closes both streams after copying the data</em>.
     *
     * @see #copyFile(InputStream, OutputStream)
     */
    public static final void copyBytes(InputStream in, OutputStream out)
        throws IOException {
        try {
            try {
                copyFile(in, out);
            } finally {
                out.close();
            }
        } finally {
            in.close();
        }
    }

    // -----------------------------------------------------------------------

    /**
     * Loads the content of a binary file.
     * 
     * @param file the binary file
     * @return the loaded bytes
     * @exception IOException if there is an I/O problem
     */
    public static byte[] loadBytes(File file) 
        throws IOException {
        InputStream in = new FileInputStream(file);

        byte[] loaded = null;
        try {
            loaded = loadBytes(in);
        } finally {
            in.close();
        }

        return loaded;
    }

    /**
     * Loads the content of an InputStream returning binary data.
     * 
     * @param in the binary data source
     * @return the loaded bytes
     * @exception IOException if there is an I/O problem
     */
    public static byte[] loadBytes(InputStream in) 
        throws IOException {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        copyFile(in, out);
        return out.toByteArray();
    }

    // -----------------------------------------------------------------------

    /**
     * Saves binary data to a file.
     * 
     * @param bytes the binary data to be saved
     * @param file the destination file
     * @exception IOException if there is an I/O problem
     */
    public static void saveBytes(byte[] bytes, File file) 
        throws IOException {
        OutputStream out = new FileOutputStream(file);

        try {
            out.write(bytes, 0, bytes.length);
            out.flush();
        } finally {
            out.close();
        }
    }
}

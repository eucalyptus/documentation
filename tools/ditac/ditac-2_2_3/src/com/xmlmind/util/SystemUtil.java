/*
 * Copyright (c) 2002-2011 Pixware SARL. All rights reserved.
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
import java.io.OutputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStreamReader;
import java.io.LineNumberReader;
import java.io.OutputStreamWriter;
import java.nio.charset.IllegalCharsetNameException;
import java.nio.charset.UnsupportedCharsetException;
import java.nio.charset.Charset;
import java.util.Map;
import java.util.Arrays;

/**
 * A collection of utility functions (static methods) which complements what's
 * found in <code>java.lang.System</code>.
 */
public final class SystemUtil {
    private SystemUtil() {}

    private static final Platform platform() {
        if (File.pathSeparatorChar == ';') {
            return Platform.WINDOWS;
        } else {
            String os = System.getProperty("os.name");
            if (os != null && os.toLowerCase().indexOf("mac") >= 0)
                return Platform.MAC_OS;
            else 
                return Platform.GENERIC_UNIX;
        }
    }

    /**
     * Returns the platform running this application: {@link Platform#WINDOWS},
     * {@link Platform#MAC_OS} or {@link Platform#GENERIC_UNIX}.
     */
    public static final Platform PLATFORM = platform();

    /**
     * <code>true</code> if {@link #PLATFORM} is {@link Platform#WINDOWS}.
     */
    public static final boolean IS_WINDOWS = (PLATFORM == Platform.WINDOWS);

    /**
     * <code>true</code> if {@link #PLATFORM} is <em>not</em> {@link
     * Platform#WINDOWS}.
     */
    public static final boolean IS_UNIX = (PLATFORM != Platform.WINDOWS);

    /**
     * <code>true</code> if {@link #PLATFORM} is {@link Platform#MAC_OS}.
     */
    public static final boolean IS_MAC_OS = (PLATFORM == Platform.MAC_OS);

    /**
     * <code>true</code> if {@link #PLATFORM} is {@link Platform#GENERIC_UNIX}.
     */
    public static final boolean IS_GENERIC_UNIX = 
        (PLATFORM == Platform.GENERIC_UNIX);

    // -----------------------------------------------------------------------

    /**
     * Returns the absolute, canonical directory corresponding to system
     * property <tt>user.home</tt> (that is, the home directory of the user of
     * this application) if this directory exists. Returns <code>null</code>
     * otherwise.
     */
    public static File homeDir() {
        return userDir("user.home");
    }

    /**
     * Returns the absolute, canonical directory corresponding to system
     * property <tt>user.dir</tt> (that is, the current working directory) if
     * this directory exists. Returns <code>null</code> otherwise.
     */
    public static File currentWorkingDir() {
        return userDir("user.dir");
    }
    
    private static File userDir(String propName) {
        File dir = null;

        String prop = System.getProperty(propName);
        if (prop != null) {
            try {
                dir = (new File(prop)).getCanonicalFile();
                if (!dir.isDirectory()) {
                    dir = null;
                }
            } catch (IOException ignored) {}
        }

        return dir;
    }

    private static File[] customUserPreferencesDir = new File[1];

    /**
     * Specify a custom user preferences directory.
     *
     * @param dir the custom user preferences directory 
     * The fact that <tt>dir</tt> exists or is a directory is not checked.
     * <p>Specify <code>null<code> to revert to the default 
     * user preferences directory of this application.
     * @see #userPreferencesDir()
     */
    public static void setUserPreferencesDir(File dir) {
        if (dir != null && !dir.isAbsolute()) {
            dir = dir.getAbsoluteFile();
        }
        synchronized (customUserPreferencesDir) {
            customUserPreferencesDir[0] = dir;
        }
    }

    /**
     * Returns the user preferences directory of this application. More
     * precisely:
     * <ul>
     * <li>Returns the custom user preferences directory, if specified using
     * {@link #setUserPreferencesDir}.
     * <li>Otherwise returns the default user preferences directory.
     * </ul>
     * @see #defaultUserPreferencesDir
     */
    public static File userPreferencesDir() {
        synchronized (customUserPreferencesDir) {
            if (customUserPreferencesDir[0] != null) {
                return customUserPreferencesDir[0];
            } else {
                return defaultUserPreferencesDir();
            }
        }
    }

    /**
     * Equivalent to {@link #userPreferencesDir(String, String, String)
     * userPreferencesDir("XMLmind", "ditac", "ditac")}.
     */
    public static File defaultUserPreferencesDir() {
        return userPreferencesDir("XMLmind", "ditac", "ditac");
    }

    /**
     * Returns the directory used to store the preferences of specified
     * application.
     * <p>Example: vendor="XMLmind", product="XMLEditor", app="xxe":
     * <ul>
     * <li><i>$HOME</i>/.xxe/ on Linux, Unix, etc.
     * <li><i>$HOME</i>/Library/Application Support/XMLmind/XMLEditor 
     * on Mac OS X.
     * <li><i>%APPDATA%</i>\XMLmind\XMLEditor\ on Windows 2000, XP,
     * Vista.
     * </ul>
     * 
     * @param vendor name of the vendor of the product
     * @param product official product name
     * @param app nickname of the product
     * @return the user preferences directory.
     * <p>Returns <code>null</code> if system property <tt>user.home</tt> is
     * not set or does not specify an existing directory.
     * <p>The returned canonical file may specify a directory which does not
     * exist yet and/or which may be impossible to create.
     */
    public static File userPreferencesDir(String vendor, String product, 
                                          String app) {
        StringBuilder buffer = new StringBuilder();

        if (IS_WINDOWS) {
            String appData = System.getenv("APPDATA");
            if (appData != null && (new File(appData)).isDirectory()) {
                buffer.append(appData);
                buffer.append('\\');
                buffer.append(vendor);
                buffer.append('\\');
                buffer.append(product);
            }
        }

        if (buffer.length() == 0) {
            File homeDir = homeDir();
            if (homeDir == null)
                return null;
            buffer.append(homeDir.getPath());

            if (IS_WINDOWS) {
                // Fallback: normally the APPDATA environment variable should
                // have been set.

                String osName = System.getProperty("os.name");
                if (osName != null && osName.indexOf("Vista") >= 0) {
                    buffer.append("\\AppData\\Roaming\\");
                } else {
                    // Windows 2000, XP.
                    // Also works on Vista because it seems that
                    // "Application Data" is automagically mapped to
                    // "AppData\Roaming".

                    buffer.append("\\Application Data\\");
                }

                buffer.append(vendor);
                buffer.append('\\');
                buffer.append(product);
            } else if (IS_MAC_OS) {
                buffer.append("/Library/Application Support/");
                buffer.append(vendor);
                buffer.append('/');
                buffer.append(product);
            } else {
                buffer.append("/.");
                buffer.append(app);
            }
        }

        File prefsDir = null;
        try {
            prefsDir = (new File(buffer.toString())).getCanonicalFile();
        } catch (IOException ignored) {}

        return prefsDir;
    }

    // -----------------------------------------------------------------------

    private static String[] defaultEncoding = new String[1];

    /**
     * Returns the default character encoding for this platform.
     * 
     * @return canonical name of default charset for this platform
     */
    public static String defaultEncoding() {
        synchronized (defaultEncoding) {
            if (defaultEncoding[0] == null) {
                defaultEncoding[0] = 
                    (new OutputStreamWriter(System.out)).getEncoding();

                try {
                    Charset charset = 
                        Charset.forName(defaultEncoding[0]);
                    defaultEncoding[0] = charset.name();

                    /*
                    System.err.print("Default encoding canonical name: ");
                    System.err.print(defaultEncoding[0]);
                    System.err.print("; aliases:");
                    java.util.Iterator<String> iter = 
                        charset.aliases().iterator();
                    while (iter.hasNext()) {
                        System.err.print(' ');
                        System.err.print(iter.next());
                    }
                    System.err.println();
                    */
                } catch (IllegalCharsetNameException cannotHappen1) {
                    cannotHappen1.printStackTrace();
                } catch (UnsupportedCharsetException cannotHappen2) {
                    cannotHappen2.printStackTrace();
                }
            }

            return defaultEncoding[0];
        }
    }

    // -----------------------------------------------------------------------

    private static Object allEncodingsLock = new Object();
    private static String[] allEncodings;

    /**
     * Returns the canonical names of all the charsets supported by
     * the Java runtime. The returned array is sorted.
     */
    public static String[] listEncodings() {
        synchronized (allEncodingsLock) {
            if (allEncodings == null) {
                Map<String, Charset> map = Charset.availableCharsets();
                allEncodings = new String[map.size()];
                map.keySet().toArray(allEncodings);

                Arrays.sort(allEncodings);
            }

            return allEncodings;
        }
    }

    // -----------------------------------------------------------------------

    private static VersionNumber[] javaVersion = new VersionNumber[1];

    /**
     * Returns the version number of current Java<sup>TM</sup> runtime.
     * <p>If the system property "<tt>java.version</tt>" does not exist or
     * cannot be parsed, returns 1.5.0.
     */
    public static VersionNumber javaVersionNumber() {
        synchronized (javaVersion) {
            if (javaVersion[0] == null) {
                String prop = System.getProperty("java.version");
                if (prop != null) {
                    javaVersion[0] = 
                        VersionNumber.fromString(prop, /*lenient*/ true);
                }

                if (javaVersion[0] == null) {
                    javaVersion[0] = new VersionNumber(1, 5, 0);
                }
            }

            return javaVersion[0];
        }
    }

    // -----------------------------------------------------------------------

    private static VersionNumber[] osVersion = new VersionNumber[1];

    /**
     * Returns the version number of the operating system.
     * <p>If the system property "<tt>os.version</tt>" does not exist or
     * cannot be parsed, returns <code>null</code>.
     */
    public static VersionNumber osVersionNumber() {
        synchronized (osVersion) {
            if (osVersion[0] == null) {
                String prop = System.getProperty("os.version");
                if (prop != null) {
                    // Linux versions look like "2.6.18.8-0.3-default".
                    // Mac OS versions look like "10.5", "10.4.10".
                    // Windows versions look like "6.0", "5.1".

                    osVersion[0] = 
                        VersionNumber.fromString(prop, /*lenient*/ true);
                }
            }

            return osVersion[0];
        }
    }

    /*TEST_SYSTEM_INFO
    public static void main(String[] args) throws Exception {
        System.err.println("homeDir=" + homeDir());
        System.err.println("currentWorkingDir=" + currentWorkingDir());
        System.err.println("userPreferencesDir=" + userPreferencesDir());
        System.err.println("defaultEncoding=" + defaultEncoding());
        System.err.println("javaVersionNumber=" + javaVersionNumber());
        System.err.println("osVersionNumber=" + osVersionNumber());
    }
    TEST_SYSTEM_INFO*/

    // -----------------------------------------------------------------------

    /**
     * Equivalent to {@link #shellStart(String, String[], File)
     * shellStart(command, null, null)}.
     */
    public static Process shellStart(String command) 
        throws IOException {
        return shellStart(command, null, null);
    }

    /**
     * Executes a command using the standard shell of the platform. Unlike
     * {@link #shellExec}, does not wait until the command is completed.
     * 
     * @param command the shell command to be executed
     * @param envp array of pairs: environment variable name/value. 
     * Specify <code>null</code> to inherit the environment settings 
     * of the current process.
     * @param dir the working directory of the subprocess. Specify
     * <code>null</code> to inherit the working directory of the current
     * process.
     * @return the process of the shell
     * @exception IOException if an I/O error occurs
     */
    public static Process shellStart(String command, String[] envp, File dir)
        throws IOException { 
        ProcessBuilder builder;

        if (IS_WINDOWS) {
            builder = new ProcessBuilder("cmd.exe", "/s", "/c", 
                                         "\"" + command + "\"");
        } else {
            builder = new ProcessBuilder("/bin/sh", "-c", command);
        }

        if (envp != null) {
            Map<String, String> env = builder.environment();
            int count = 2*(envp.length/2);
            for (int i = 0; i < count; i += 2) {
                env.put(envp[i], envp[i+1]);
            }
        }

        if (dir != null) {
            builder.directory(dir);
        }

        return builder.start();
    }

    // -----------------------------------------------------------------------

    /**
     * Equivalent to {@link #shellExec(String, String[], File, String[])
     * shellExec(command, null, null, capture)}.
     */
    public static int shellExec(String command, String[] capture) 
        throws IOException, InterruptedException {
        return shellExec(command, null, null, capture);
    }

    /**
     * Executes a command using the standard shell of the platform, capturing
     * output to <code>System.out</code> and <code>System.err</code>.
     * 
     * @param command the shell command to be executed
     * @param envp array of pairs: environment variable name/value. 
     * Specify <code>null</code> to inherit the environment settings 
     * of the current process.
     * @param dir the working directory of the subprocess. Specify
     * <code>null</code> to inherit the working directory of the current
     * process.
     * @param capture output to <code>System.out</code> is captured and saved
     * to <code>capture[0]</code> and output to <code>System.err</code> is
     * captured and saved to <code>capture[1]</code>. May <em>not</em> be
     * <code>null</code>.
     * @return the exit status returned by the shell
     * @exception IOException if an I/O error occurs
     * @exception InterruptedException if the current thread is interrupted by
     * another thread while it is waiting the completion of the shell command
     */
    public static int shellExec(String command, String[] envp, File dir,
                                String[] capture) 
        throws IOException, InterruptedException { 
        Process process = shellStart(command, envp, dir);
        return captureOutput(process, capture);
    }

    /**
     * Captures output of specified newly started process (see {@link
     * #shellStart(String)}).
     * 
     * @param process newly started process
     * @param capture output to <code>System.out</code> is captured and saved
     * to <code>capture[0]</code> and output to <code>System.err</code> is
     * captured and saved to <code>capture[1]</code>. May <em>not</em> be
     * <code>null</code>.
     * @return exit status of process
     * @exception InterruptedException if the current thread is interrupted by
     * another thread while it is waiting the completion of the process
     */
    public static int captureOutput(Process process, String[] capture) 
        throws InterruptedException { 
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        ByteArrayOutputStream err = new ByteArrayOutputStream();

        InputConsumer consumer1 = 
            new InputConsumer(process.getInputStream(), out);
        InputConsumer consumer2 = 
            new InputConsumer(process.getErrorStream(), err);
        consumer1.start();
        consumer2.start();

        int status = process.waitFor();

        consumer1.join();
        consumer2.join();

        capture[0] = out.toString();
        capture[1] = err.toString();

        return status;
    }

    private static class InputConsumer extends Thread {
        private InputStream in;
        private OutputStream out;
        private byte[] bytes = new byte[4096];

        public InputConsumer(InputStream in) {
            this(in, null);
        }

        public InputConsumer(InputStream in, OutputStream out) {
            this.in = in;
            this.out = out;
        }

        public void run() {
            for (;;) {
                int count;
                try {
                    count = in.read(bytes);
                } catch (IOException e) {
                    //e.printStackTrace();
                    count = -1;
                }
                if (count < 0)
                    break;

                if (count > 0 && out != null) {
                    try {
                        out.write(bytes, 0, count);
                        out.flush();
                    } catch (IOException e) {
                        out = null;
                    }
                }
            }
        }
    }

    // -----------------------------------------------------------------------

    /**
     * Equivalent to {@link #shellExec(String, String[], File, Console)
     * shellExec(command, null, null, null)}.
     */
    public static int shellExec(String command) 
        throws IOException, InterruptedException {
        return shellExec(command, null, null, (Console) null);
    }

    /**
     * Equivalent to {@link #shellExec(String, String[], File, Console)
     * shellExec(command, envp, dir, null)}.
     */
    public static int shellExec(String command, String[] envp, File dir) 
        throws IOException, InterruptedException {
        return shellExec(command, envp, dir, (Console) null);
    }

    /**
     * Executes a command using the standard shell of the platform.
     * 
     * @param command the shell command to be executed
     * @param envp array of pairs: environment variable name/value. 
     * Specify <code>null</code> to inherit the environment settings 
     * of the current process.
     * @param dir the working directory of the subprocess. Specify
     * <code>null</code> to inherit the working directory of the current
     * process.
     * @param console output to <code>System.out</code> is displayed by this
     * console as {@link Console.MessageType#INFO} messages and output to
     * <code>System.err</code> is is displayed by this console as {@link
     * Console.MessageType#ERROR} messages. May be <code>null</code>.
     * @return the exit status returned by the shell
     * @exception IOException if an I/O error occurs
     * @exception InterruptedException if the current thread is interrupted by
     * another thread while it is waiting the completion of the shell command
     */
    public static int shellExec(String command, String[] envp, File dir,
                                Console console) 
        throws IOException, InterruptedException { 
        Process process = shellStart(command, envp, dir);
        return captureOutput(process, console);
    }

    /**
     * Captures output of specified newly started process (see {@link
     * #shellStart(String)}).
     * 
     * @param process newly started process
     * @param console output to <code>System.out</code> is captured and
     * displayed as INFO messages on this console and output to
     * <code>System.err</code> is captured and sisplayed as ERROR messages on
     * this console. May be <code>null</code>.
     * @return exit status of process
     * @exception InterruptedException if the current thread is interrupted by
     * another thread while it is waiting the completion of the process
     */
    public static int captureOutput(Process process, Console console) 
        throws InterruptedException { 
        InputConsumer2 consumer1 = 
            new InputConsumer2(process.getInputStream(),
                               console, Console.MessageType.INFO);
        InputConsumer2 consumer2 = 
            new InputConsumer2(process.getErrorStream(),
                               console, Console.MessageType.ERROR);
        consumer1.start();
        consumer2.start();

        int exitStatus = process.waitFor();

        consumer1.join();
        consumer2.join();

        return exitStatus;
    }

    private static final class InputConsumer2 extends Thread {
        private LineNumberReader lines;
        private Console console;
        private Console.MessageType messageType;

        public InputConsumer2(InputStream in, Console console, 
                              Console.MessageType messageType) {
            lines = new LineNumberReader(new InputStreamReader(in));
            this.console = console;
            this.messageType = messageType;
        }

        public void run() {
            for (;;) {
                String line;
                try {
                    line = lines.readLine();
                } catch (IOException ignored) {
                    line = null;
                }
                if (line == null)
                    break;

                if (console != null)
                    console.showMessage(line, messageType);
            }
        }
    }

    /*TEST_SHELL_EXEC
    public static void main(String[] args) throws Exception {
        if (args.length != 1) {
            System.err.println(
                "java com.xmlmind.util.SystemUtil command");
            System.exit(1);
        }

        int code = shellExec(args[0], null, null, new Console() {
            public void showMessage(String message, MessageType messageType) {
                if (messageType == MessageType.ERROR)
                    System.err.println("err> " + message);
                else
                    System.out.println("out> " + message);
            }
        });
        System.exit(code);
    }
    TEST_SHELL_EXEC*/

    // -----------------------------------------------------------------------

    /**
     * Searches specified application using the <tt>PATH</tt> 
     * environment variable.
     *
     * @param appName the basename of the executable file of the application.
     * <p>On Windows, this basename may have no extension. In such case,
     * all the extensions found in the the <tt>PATHEXT</tt> 
     * environment variable (".exe", ".bat", etc), are tried in turn.
     * @return the absolute filename of the application if found; 
     * <code>null</code> otherwise.
     */
    public static File findAppInPath(String appName) {
        String pathEnvVar = System.getenv("PATH");
        if (pathEnvVar == null)
            return null;

        String[] split = StringUtil.split(pathEnvVar, File.pathSeparatorChar);
        for (int i = 0; i < split.length; ++i) {
            String path = split[i].trim();
            if (path.length() == 0)
                continue;

            if (!path.endsWith(File.separator))
                path += File.separator;

            File file = new File(path + appName);
            if (file.isFile())
                return file;
            
            if (IS_WINDOWS && appName.lastIndexOf('.') < 0) {
                String[] suffixes = { ".EXE", ".COM", ".BAT", ".CMD" };

                String pathExtEnvVar = System.getenv("PATHEXT");
                if (pathExtEnvVar != null)
                    suffixes = StringUtil.split(pathExtEnvVar, 
                                                File.pathSeparatorChar);

                for (int j = 0; j < suffixes.length; ++j) {
                    String suffix = suffixes[j].trim();
                    if (!suffix.startsWith("."))
                        continue;
                    
                    file = new File(path + appName + suffix);
                    if (file.isFile())
                        return file;
                }
            }
        }

        return null;
    }
}

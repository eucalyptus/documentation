/*
 * Copyright (c) 2009-2012 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.util;

import java.io.IOException;
import java.io.File;
import com.xmlmind.util.StringUtil;

public final class AppUtil {
    private AppUtil() {}

    // -----------------------------------------------------------------------

    public static File findInstallDirectory() {
        String classPath = System.getProperty("java.class.path");
        if (classPath == null) {
            return null;
        }

        File installDir = null;

        String[] paths = StringUtil.split(classPath, File.pathSeparatorChar);
        for (int i = 0; i < paths.length; ++i) {
            String path = paths[i].trim();
            if (path.length() == 0) {
                continue;
            }

            if (path.endsWith("ditac.jar")) {
                File jarFile = new File(path);
                if (!jarFile.isFile()) {
                    continue;
                }

                try {
                    jarFile = jarFile.getCanonicalFile();
                } catch (IOException ignored) {
                    break;
                }

                installDir = jarFile.getParentFile(); // "ditac/lib/"
                if (installDir == null) {
                    break;
                }
                
                installDir = installDir.getParentFile(); // "ditac/"
                if (installDir == null) {
                    break;
                }

                break;
            }
        }

        return installDir;
    }

    // -----------------------------------------------------------------------

    public static String PLUGIN_DIR_PROPERTY = "DITAC_PLUGIN_DIR";

    public static File findPluginDirectory(File installDir) {
        File pluginDir = null;

        String path = System.getProperty(PLUGIN_DIR_PROPERTY);
        if (path == null || (path = path.trim()).length() == 0) {
            if (installDir != null) {
                path = (new File(installDir, "plugin")).getPath();
            }
        }

        if (path != null) {
            pluginDir = new File(path);
            if (!pluginDir.isDirectory()) {
                pluginDir = null;
            }
        }

        return pluginDir;
    }

    // -----------------------------------------------------------------------

    public static String XSL_DIR_PROPERTY = "DITAC_XSL_DIR";

    public static File findXSLDirectory(File installDir) {
        File xslDir = null;

        String path = System.getProperty(XSL_DIR_PROPERTY);
        if (path == null || (path = path.trim()).length() == 0) {
            if (installDir != null) {
                path = (new File(installDir, "xsl")).getPath();
            }
        }

        if (path != null) {
            xslDir = new File(path);
            if (!xslDir.isDirectory()) {
                xslDir = null;
            }
        }

        return xslDir;
    }
}

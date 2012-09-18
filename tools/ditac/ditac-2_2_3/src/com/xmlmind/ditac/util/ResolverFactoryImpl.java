/*
 * Copyright (c) 2009-2012 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.util;

import java.io.File;
import java.net.URL;
import java.util.Arrays;
import org.apache.xml.resolver.tools.CatalogResolver;
import com.xmlmind.util.StringUtil;
import com.xmlmind.util.FileUtil;
import com.xmlmind.util.URLUtil;

/**
 * An implementation of ResolverFactory.
 */
public final class ResolverFactoryImpl implements ResolverFactory {
    // We want xml.catalog.files to contain normalized URLs ---

    static {
        boolean hasXMLCatalogs = false;

        String prop = System.getProperty("xml.catalog.files");
        if (prop != null && (prop = prop.trim()).length() > 0) {
            try {
                StringBuilder buffer = new StringBuilder();

                String[] split = StringUtil.split(prop, ';');
                for (int i = 0; i < split.length; ++i) {
                    String location = split[i].trim();
                    if (location.length() == 0) {
                        continue;
                    }

                    URL url= URLUtil.urlOrFile(location);
                    if (url != null) {
                        if (buffer.length() > 0) {
                            buffer.append(';');
                        }
                        buffer.append(url.toExternalForm());
                    }
                }

                if (buffer.length() > 0) {
                    System.setProperty("xml.catalog.files", buffer.toString());
                    hasXMLCatalogs = true;
                }
            } catch (Exception ignored) {}
        }

        if (!hasXMLCatalogs) {
            File installDir = AppUtil.findInstallDirectory();
            if (installDir != null) {
                StringBuilder buffer = new StringBuilder();

                // The XML catalog resolver seems to use first found relevant
                // entry. Therefore we must reference the catalogs found in
                // the plugins *before* the stock catalog.

                File pluginDir = AppUtil.findPluginDirectory(installDir);
                if (pluginDir != null) {
                    String[] subDirNames = pluginDir.list();
                    if (subDirNames != null) {
                        if (subDirNames.length > 1) {
                            Arrays.sort(subDirNames);
                        }

                        for (String subDirName : subDirNames) {
                            File subDir = new File(pluginDir, subDirName);
                            if (subDir.isDirectory()) {
                                File catalogFile = 
                                    new File(subDir, "catalog.xml");
                                if (catalogFile.isFile()) {
                                    if (buffer.length() > 0) {
                                        buffer.append(';');
                                    }
                                    URL catalogURL = 
                                        FileUtil.fileToURL(catalogFile);
                                    buffer.append(catalogURL.toExternalForm());
                                }
                            }
                        }
                    }
                }

                File catalogFile = 
                    new File(installDir, 
                             "schema" + File.separatorChar + "catalog.xml");
                if (catalogFile.isFile()) {
                    if (buffer.length() > 0) {
                        buffer.append(';');
                    }
                    URL catalogURL = FileUtil.fileToURL(catalogFile);
                    buffer.append(catalogURL.toExternalForm());
                }

                if (buffer.length() > 0) {
                    System.setProperty("xml.catalog.files", buffer.toString());
                }
            }
        }
    }

    // -----------------------------------------------------------------------

    private CatalogResolver catalogResolver;

    public ResolverFactoryImpl() {
        catalogResolver = new CatalogResolver();

        int verbosity = -1;
        String prop = 
            System.getProperty("DITAC_CATALOG_RESOLVER_VERBOSITY");
        if (prop != null && (prop = prop.trim()).length() > 0) {
            try {
                verbosity = Integer.parseInt(prop);
            } catch (NumberFormatException ignored) {}
        }
        if (verbosity > 0) {
            catalogResolver.getCatalog().getCatalogManager().setVerbosity(
                verbosity);
        }
    }

    public CatalogResolver getCatalogResolver() {
        return catalogResolver;
    }
}

/*
 * Copyright (c) 2009 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.util;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import javax.xml.transform.URIResolver;
import org.xml.sax.EntityResolver;
import org.apache.xml.resolver.tools.CatalogResolver;
import com.xmlmind.util.URLUtil;

/**
 * Helper class making it easy to use <tt>CatalogResolver</tt>s.
 * <p>This class is as thread-safe as the <tt>CatalogResolver</tt>s it creates.
 */
public final class Resolve {
    private static ResolverFactory resolverFactory;

    private Resolve() {}

    /**
     * Specify which ResolverFactory to use. 
     * By default, it is a instance of {@link ResolverFactoryImpl}.
     *
     * @see #getResolverFactory
     */
    public static void setResolverFactory(ResolverFactory factory) {
        if (factory == null) {
            factory = new ResolverFactoryImpl();
        }

        synchronized (Resolve.class) {
            resolverFactory = factory;
        }
    }

    /**
     * Returns the ResolverFactory used by this helper class.
     *
     * @see #setResolverFactory
     */
    public static ResolverFactory getResolverFactory() {
        synchronized (Resolve.class) {
            if (resolverFactory == null) {
                resolverFactory = new ResolverFactoryImpl();
            }
            return resolverFactory;
        }
    }

    // -----------------------------------------------------------------------

    /**
     * Returns a properly configured, ready to use, CatalogResolver.
     */
    public static CatalogResolver getCatalogResolver() {
        return getResolverFactory().getCatalogResolver();
    }

    /**
     * Returns a properly configured, ready to use, EntityResolver.
     * <p>Simply invokes {@link #getCatalogResolver}.
     */
    public static EntityResolver createEntityResolver() {
        return getCatalogResolver();
    }

    /**
     * Returns a properly configured, ready to use, URIResolver.
     * <p>Simply invokes {@link #getCatalogResolver}.
     */
    public static URIResolver createURIResolver() {
        return getCatalogResolver();
    }

    // -----------------------------------------------------------------------

    /**
     * Resolves specified URI. If a mapping is found in XML catalogs, this
     * mapping is returned. Otherwise specified URI is parsed as an URL (if
     * relative, it is resolved against specified base) and this URL is
     * returned.
     * 
     * @param uri URI for which a mapping is to be found.
     * This URI may have a fragment.
     * @param baseURL base URL used if <tt>uri</tt> needs to be parsed as an
     * URL. May be <code>null</code>.
     * @return resolved URL
     * @exception java.net.MalformedURLException if specified URI needs to be
     * parsed as an URL but is malformed
     */
    public static URL resolveURI(String uri, URL baseURL) 
        throws MalformedURLException {
        String resolved = resolveURI(uri);
        if (resolved != null) {
            return URLUtil.createURL(resolved);
        } else {
            return URLUtil.createURL(baseURL, uri);
        }
    }

    /**
     * Resolves specified URI. If a mapping is found in XML catalogs, this
     * mapping is returned. Otherwise returns <code>null</code>.
     * 
     * @param uri URI for which a mapping is to be found.
     * This URI may have a fragment.
     * @return found mapping or <code>null</code>
     */
    public static String resolveURI(String uri) {
        String location;
        String fragment;
        int pos = uri.lastIndexOf('#');
        if (pos >= 0) {
            location = uri.substring(0, pos);
            fragment = uri.substring(pos);
        } else {
            location = uri;
            fragment = null;
        }

        String resolved = null;

        CatalogResolver resolver = getCatalogResolver();
        try {
            resolved = resolver.getCatalog().resolveURI(location);
        } catch (MalformedURLException ignored1) {
        } catch (IOException ignored2) {}

        if (resolved != null) {
            if (fragment != null) {
                return resolved + fragment;
            } else {
                return resolved;
            }
        } else {
            return null;
        }
    }
}

/*
 * Copyright (c) 2009 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.util;

import org.apache.xml.resolver.tools.CatalogResolver;

/**
 * Interface implemented by CatalogResolver factories.
 */
public interface ResolverFactory {
    /**
     * Returns a properly configured, ready to use, CatalogResolver.
     */
    CatalogResolver getCatalogResolver();
}

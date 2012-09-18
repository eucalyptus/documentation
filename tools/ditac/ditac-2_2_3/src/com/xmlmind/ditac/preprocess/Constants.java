/*
 * Copyright (c) 2009-2010 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.preprocess;

/*package*/ interface Constants {
    public static final String DITAC_NS_URI =
        "http://www.xmlmind.com/ditac/schema/ditac";

    public static final String DITAC_PREFIX = "ditac:";

    public static final String ABSOLUTE_HREF_NAME = "absoluteHref";
    public static final String ABSOLUTE_HREF_QNAME = 
        DITAC_PREFIX + ABSOLUTE_HREF_NAME;

    public static final String SEARCH_NAME = "search";
    public static final String SEARCH_QNAME = DITAC_PREFIX + SEARCH_NAME;

    public static final String FILLED_NAME = "filled";
    public static final String FILLED_QNAME = DITAC_PREFIX + FILLED_NAME;

    public static final String ID_SEPARATOR = "__";
}

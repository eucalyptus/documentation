/*
 * Copyright (c) 2009-2010 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.preprocess;

import org.w3c.dom.Element;

/*package*/ class IndexAnchor {
    public final Element source;
    public final String file;

    private String id;

    // -----------------------------------------------------------------------

    public IndexAnchor(Element source, String file, String id) {
        this.source = source;
        this.file = file;
        setId(id);
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getId() {
        return id;
    }
}

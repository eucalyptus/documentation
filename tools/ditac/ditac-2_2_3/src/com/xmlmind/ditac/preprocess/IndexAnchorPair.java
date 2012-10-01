/*
 * Copyright (c) 2009 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.preprocess;

import org.w3c.dom.Element;

/*package*/ final class IndexAnchorPair extends IndexAnchor {
    public final String name;

    private Element source2;
    private String file2;
    private String id2;

    // -----------------------------------------------------------------------

    public IndexAnchorPair(Element source, String file, String id,
                           String name) {
        super(source, file, id);
        this.name = name;
    }

    public void setAnchor2(Element source2, String file2, String id2) {
        this.source2 = source2;
        this.file2 = file2;
        this.id2 = id2;
    }

    public Element getSource2() {
        return source2;
    }

    public String getFile2() {
        return file2;
    }

    public String getId2() {
        return id2;
    }
}

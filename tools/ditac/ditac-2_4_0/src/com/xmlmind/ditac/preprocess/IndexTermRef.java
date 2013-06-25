/*
 * Copyright (c) 2009-2010 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.preprocess;

import java.util.Arrays;
import org.w3c.dom.Element;

/*package*/ final class IndexTermRef {
    public final Element source;
    public final String[] term;

    // -----------------------------------------------------------------------

    public IndexTermRef(Element source, String[] term) {
        this.source = source;
        this.term = term;
    }

    public boolean equals(Object other) {
        if (other == null || !(other instanceof IndexTermRef)) {
            return false;
        }
        return Arrays.equals(term, ((IndexTermRef) other).term);
    }
}

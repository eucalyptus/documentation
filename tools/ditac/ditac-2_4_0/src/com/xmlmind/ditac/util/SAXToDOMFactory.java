/*
 * Copyright (c) 2011 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.util;

import org.w3c.dom.Document;

public class SAXToDOMFactory {
    public static final SAXToDOMFactory INSTANCE = new SAXToDOMFactory();

    public SAXToDOM createSAXToDOM(Document doc, boolean addElementPointer) {
        return new SAXToDOM(doc, addElementPointer);
    }
}
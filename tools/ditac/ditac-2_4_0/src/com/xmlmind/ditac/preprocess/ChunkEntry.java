/*
 * Copyright (c) 2009-2012 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.preprocess;

import org.w3c.dom.Element;
import com.xmlmind.util.StringUtil;

/**
 * Not part of the public, documented, API.
 */
public final class ChunkEntry {
    public enum Type {
        TITLE_PAGE,
        TOC,
        FIGURE_LIST,
        TABLE_LIST,
        EXAMPLE_LIST,
        INDEX_LIST,
        TOPIC
    }

    public final Chunk chunk;
    public final Type type;
    public final String[] number;
    public final String role;
    public final String title; // Comes from navtitle. May be null.
    public final TOCType tocType;
    public final LoadedTopic loadedTopic; // Null unless type=TOPIC.

    // -----------------------------------------------------------------------

    public ChunkEntry(Chunk chunk, Type type, String[] number, String role, 
                      String title, TOCType tocType, LoadedTopic loadedTopic) {
        this.chunk = chunk;
        this.type = type;
        this.number = number;
        this.role = role;
        this.title = title;
        this.tocType = tocType;
        this.loadedTopic = loadedTopic;
    }

    public Element getElement() {
        return (loadedTopic == null)? null : loadedTopic.element;
    }

    @Override
    public String toString() {
        StringBuilder buffer = new StringBuilder();
        toString(buffer);
        return buffer.toString();
    }

    public void toString(StringBuilder buffer) {
        buffer.append(type.toString());

        if (number != null) {
            buffer.append(' ');
            buffer.append(StringUtil.join(' ', number));
        }

        if (role != null) {
            buffer.append(' ');
            buffer.append(role);
        }

        if (title != null) {
            buffer.append(" \"");
            buffer.append(title);
            buffer.append('"');
        }

        if (tocType != TOCType.NONE) {
            buffer.append(' ');
            buffer.append(tocType);
            buffer.append(" TOC");
        }

        if (loadedTopic != null) {
            buffer.append(' ');
            buffer.append(loadedTopic.element.getLocalName());
        }
    }
}

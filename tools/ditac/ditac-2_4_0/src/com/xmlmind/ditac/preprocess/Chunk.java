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
import com.xmlmind.util.ArrayUtil;

/**
 * Not part of the public, documented, API.
 */
public final class Chunk {
    public final String rawRootName;

    private ChunkEntry[] entries;

    private String rootName; // Without any extension.

    // -----------------------------------------------------------------------

    public Chunk(String rawRootName) {
        this.rawRootName = rawRootName;
        entries = new ChunkEntry[0];
    }

    public void initRootName(String rootName) {
        if (this.rootName != null) {
            throw new IllegalStateException();
        }

        this.rootName = rootName;
    }

    public String getRootName() {
        return rootName;
    }

    public void prependEntry(ChunkEntry entry) {
        // Do not add the same element several times.
        if (!containsEntry(entry)) {
            entries = ArrayUtil.prepend(entries, entry);
        }
    }

    public void appendEntry(ChunkEntry entry) {
        if (!containsEntry(entry)) {
            entries = ArrayUtil.append(entries, entry);
        }
    }

    public boolean containsEntry(ChunkEntry entry) {
        Element element = entry.getElement();
        if (element != null) {
            for (int i = 0; i < entries.length; ++i) {
                if (entries[i].getElement() == element) {
                    return true;
                }
            }
        }
        return false;
    }

    public boolean hasEntries() {
        return (entries.length > 0);
    }

    public ChunkEntry[] getEntries() {
        return entries;
    }

    public String toString() {
        StringBuilder buffer = new StringBuilder();
        if (rootName != null) {
            buffer.append(rootName);
        }
        buffer.append(" (");
        buffer.append(rawRootName);
        buffer.append("):");
        for (int i = 0; i < entries.length; ++i) {
            buffer.append("\n    ");
            entries[i].toString(buffer);
        }
        return buffer.toString();
    }
}

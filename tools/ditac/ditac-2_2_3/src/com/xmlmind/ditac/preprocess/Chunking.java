/*
 * Copyright (c) 2009-2010 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.preprocess;

/**
 * Chunking mode.
 *
 * @see PreProcessor#setChunking
 */
public enum Chunking {
    /**
     * Output a single chunk whatever the chunk specification found 
     * in the DITA map.
     */
    NONE,

    /**
     * Output a single chunk. However unlike {@link #NONE} do not 
     * systematically pull all the topics contained in a DITA file.
     * Instead follow the <tt>chunk="select-document"</tt>, 
     * <tt>chunk="select-tree"</tt>, <tt>chunk="select-topic"</tt>
     * specifications found in the DITA map. 
     * <p>This mode allows to reuse a chunk specification designed 
     * to generate several chunks.
     */
    SINGLE,

    /**
     * Output a single chunk whatever the chunk specification found 
     * in the DITA map when the output media is {@link Media#PRINT}; 
     * follow the chunk specification found in the DITA map otherwise.
     */
    AUTO;

    /**
     * Parses specified string representation of a chunking mode.
     *
     * @param spec string representation of a chunking mode
     * @return parsed chunking mode or <code>null</code> 
     * if <tt>spec</tt> cannot be parsed
     */
    public static Chunking fromString(String spec) {
        spec = spec.trim().toLowerCase();
        if ("none".equals(spec)) {
            return Chunking.NONE;
        } else if ("single".equals(spec)) {
            return Chunking.SINGLE;
        } else if ("auto".equals(spec)) {
            return Chunking.AUTO;
        } else {
            return null;
        }
    }

    /**
     * Returns a string representation of this chunking mode parseable 
     * by {@link #fromString}.
     */
    public String toString() {
        switch (this) {
        case NONE:
            return "none";
        case SINGLE:
            return "single";
        case AUTO:
            return "auto";
        default:
            return "???";
        }
    }

    /**
     * Joins the string representations of all chunking modes. 
     * Useful in help/error messages.
     */
    public static String joinStringForms(String separator) {
        StringBuilder buffer = new StringBuilder();
        for (Chunking c : Chunking.values()) {
            if (buffer.length() > 0) {
                buffer.append(separator);
            }
            buffer.append(c.toString());
        }
        return buffer.toString();
    }
}

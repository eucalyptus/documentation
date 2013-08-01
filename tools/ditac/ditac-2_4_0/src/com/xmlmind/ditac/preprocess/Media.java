/*
 * Copyright (c) 2009-2013 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.preprocess;

/**
 * The media associated to the output format.
 *
 * @see PreProcessor#setMedia
 */
public enum Media {
    /**
     * Screen media (xhtml, html, Java Help, HTML Help, etc).
     */
    SCREEN,

    /**
     * Print media (PDF, PostScript, RTF, OpenOffice, etc).
     */
     PRINT;

    /**
     * Parses specified string representation of a media.
     *
     * @param spec string representation of a media
     * @return parsed media or <code>null</code> 
     * if <tt>spec</tt> cannot be parsed
     */
    public static Media fromString(String spec) {
        spec = spec.trim().toLowerCase();
        if ("screen".equals(spec)) {
            return Media.SCREEN;
        } else if ("print".equals(spec)) {
            return Media.PRINT;
        } else {
            return null;
        }
    }

    /**
     * Returns a string representation of this media parseable 
     * by {@link #fromString}.
     */
    @Override
    public String toString() {
        switch (this) {
        case SCREEN:
            return "screen";
        case PRINT:
            return "print";
        default:
            return "???";
        }
    }
 
    /**
     * Joins the string representations of all media types. 
     * Useful in help/error messages.
     */
    public static String joinStringForms(String separator) {
        StringBuilder buffer = new StringBuilder();
        for (Media c : Media.values()) {
            if (buffer.length() > 0) {
                buffer.append(separator);
            }
            buffer.append(c.toString());
        }
        return buffer.toString();
    }
}

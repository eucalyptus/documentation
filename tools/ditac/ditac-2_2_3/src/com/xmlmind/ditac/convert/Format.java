/*
 * Copyright (c) 2009-2011 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.convert;

import com.xmlmind.ditac.preprocess.Media;

/**
 * Output format of a Converter.
 *
 * @see Converter#run
 */
public enum Format {
    /**
     * XHTML 1.0.
     */
    XHTML,

    /**
     * XHTML 1.1.
     */
    XHTML1_1,

    /**
     * HTML 4.1.
     */
    HTML,

    /**
     * Java Help.
     */
    JAVA_HELP,

    /**
     * (Windows) HTML Help.
     */
    HTML_HELP,

    /**
     * Eclipse Help.
     */
    ECLIPSE_HELP,

    /**
     * Web Help.
     */
    WEB_HELP,

    /**
     * EPUB.
     */
    EPUB,

    /**
     * PostScript.
     */
    PS,

    /**
     * PDF.
     */
    PDF,

    /**
     * RTF (can be opened in MS Word 2000+).
     */
    RTF,

    /**
     * OpenOffice (.odt, can be opened in OpenOffice.org 2+).
     */
    ODT,

    /**
     * WordprocessingML (can be opened in MS Word 2003+).
     */
    WML,

    /**
     * Office Open XML (.docx, can be opened in Word 2007+).
     */
    DOCX,

    /**
     * XSL-FO. Intermediate format normally converted to {@link #PDF}, 
     * {@link #RTF}, etc, by XSL-FO processor such as 
     * Apache FOP, RenderX XEP, XMLmind XSL-FO Converter or 
     * Antenna House XSL Formatter.
     */
    FO;

    /**
     * Returns the format corresponding to specified path 
     * (full URL, full filename or simply a file extension).
     * Returns <code>null</code> if the extension is unknown.
     * <p>Note that "<tt>html</tt>" and "<tt>htm</tt>" 
     * return {@link #XHTML} and not {@link #HTML}. 
     */
    public static Format fromExtension(String path) {
        path = path.toLowerCase();
        if (path.endsWith("xhtml") ||
            path.endsWith("html") ||
            path.endsWith("htm")) {
            return Format.XHTML;
        } else if (path.endsWith("ps")) {
            return Format.PS;
        } else if (path.endsWith("pdf")) {
            return Format.PDF;
        } else if (path.endsWith("rtf") ||
                   path.endsWith("doc")) {
            return Format.RTF;
        } else if (path.endsWith("odt")) {
            return Format.ODT;
        } else if (path.endsWith("xml") ||
                   path.endsWith("wml")) {
            return Format.WML;
        } else if (path.endsWith("docx")) {
            return Format.DOCX;
        } else if (path.endsWith("fo")) {
            return Format.FO;
        } else if (path.endsWith("jar")) {
            return Format.JAVA_HELP;
        } else if (path.endsWith("chm")) {
            return Format.HTML_HELP;
        } else if (path.endsWith("epub")) {
            return Format.EPUB;
        } else {
            return null;
        }
        // Nothing for Eclipse Help and Web Help: use .html extension and
        // explicitly specify the format.
    }

    /**
     * Returns the format corresponding to the specified name.
     * Returns <code>null</code> if specified name is unknown.
     * <p>Specified name must be one of the string representations
     * returned by {@link #toString}.
     */
    public static Format fromString(String spec) {
        spec = spec.trim().toLowerCase();
        if ("xhtml".equals(spec)) {
            return Format.XHTML;
        } else if ("xhtml1.1".equals(spec)) {
            return Format.XHTML1_1;
        } else if ("html".equals(spec)) {
            return Format.HTML;
        } else if ("ps".equals(spec)) {
            return Format.PS;
        } else if ("pdf".equals(spec)) {
            return Format.PDF;
        } else if ("rtf".equals(spec)) {
            return Format.RTF;
        } else if ("odt".equals(spec)) {
            return Format.ODT;
        } else if ("wml".equals(spec)) {
            return Format.WML;
        } else if ("docx".equals(spec)) {
            return Format.DOCX;
        } else if ("fo".equals(spec)) {
            return Format.FO;
        } else if ("javahelp".equals(spec)) {
            return Format.JAVA_HELP;
        } else if ("htmlhelp".equals(spec)) {
            return Format.HTML_HELP;
        } else if ("eclipsehelp".equals(spec)) {
            return Format.ECLIPSE_HELP;
        } else if ("webhelp".equals(spec)) {
            return Format.WEB_HELP;
        } else if ("epub".equals(spec)) {
            return Format.EPUB;
        } else {
            return null;
        }
    }

    /**
     * Returns the media associated to this output format.
     */
    public Media toMedia() {
        switch (this) {
        case XHTML:
        case XHTML1_1:
        case HTML:
        case JAVA_HELP:
        case HTML_HELP:
        case ECLIPSE_HELP:
        case WEB_HELP:
        case EPUB:
            return Media.SCREEN;
        default:
            return Media.PRINT;
        }
    }

    /**
     * Returns a string representation of this format. 
     * This string representation is parseable by {@link #fromString}.
     */
    public String toString() {
        switch (this) {
        case XHTML:
            return "xhtml";
        case XHTML1_1:
            return "xhtml1.1";
        case HTML:
            return "html";
        case PS:
            return "ps";
        case PDF:
            return "pdf";
        case RTF:
            return "rtf";
        case ODT:
            return "odt";
        case WML:
            return "wml";
        case DOCX:
            return "docx";
        case FO:
            return "fo";
        case JAVA_HELP:
            return "javahelp";
        case HTML_HELP:
            return "htmlhelp";
        case ECLIPSE_HELP:
            return "eclipsehelp";
        case WEB_HELP:
            return "webhelp";
        case EPUB:
            return "epub";
        default:
            return "???";
        }
    }

    /**
     * Joins the string representations of all output formats. 
     * Useful in help/error messages.
     */
    public static String joinStringForms(String separator) {
        StringBuilder buffer = new StringBuilder();
        for (Format f : Format.values()) {
            if (buffer.length() > 0) {
                buffer.append(separator);
            }
            buffer.append(f.toString());
        }
        return buffer.toString();
    }
}

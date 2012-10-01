/*
 * Copyright (c) 2012 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of several XMLmind projects.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.util;

import java.util.HashMap;
import java.util.Locale;

/**
 * A collection of utility functions (static methods) operating on Locales.
 */
public final class LocaleUtil {
    private LocaleUtil() {}

    private static HashMap<String,Locale> langToLocale = 
        new HashMap<String,Locale>();

    /**
     * Returns the Locale corresponding to specified language.
     *
     * @param lang specifies the language: 
     * a two-letter ISO language code as defined by ISO-639, 
     * possibly followed by a two-letter ISO Country Code
     * as defined by ISO-3166. Examples: "en", "en-US", "fr", "fr-CA".
     * @return the Locale corresponding to specified language.
     * Note that this Locale is not necessarily supported by Java methods
     * such as <code>NumberFormat.getInstance()</code>.
     */
    public static Locale getLocale(String lang) {
        lang = LocaleUtil.normalizeLang(lang);

        synchronized (langToLocale) {
            Locale locale = langToLocale.get(lang);
            if (locale == null) {
                locale = LocaleUtil.createLocale(lang);
                langToLocale.put(lang, locale);
            }
            return locale;
        }
    }

    /**
     * Returns a normalized, possibly simplified, version of
     * specified language. For example, returns "en-US" for "en_us-win".
     */
    public static String normalizeLang(String lang) {
        // The allowed pattern for xsd:language is:
        // [a-zA-Z]{1,8}(-[a-zA-Z0-9]{1,8})*

        // Using '_' instead of '-' is a common mistake.
        String[] split = lang.split("[-_]");
        if (split.length >= 2) {
            StringBuilder buffer = new StringBuilder();
            buffer.append(split[0].toLowerCase(Locale.US));
            buffer.append('-');
            buffer.append(split[1].toUpperCase(Locale.US));
            return buffer.toString();
        } else {
            return lang.toLowerCase(Locale.US);
        }
    }

    private static Locale createLocale(String lang) {
        int pos = lang.indexOf('-');
        if (pos < 0) {
            return new Locale(lang);
        } else {
            return new Locale(lang.substring(0, pos), lang.substring(pos+1));
        }
    }
}
/*
 * Copyright (c) 2009-2012 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.preprocess;

import com.xmlmind.util.StringUtil;

/*package*/ final class TOCInfo {
    public static final String USER_DATA_KEY = "TOC_INFO";

    public static final TOCInfo NO_INFO =
        new TOCInfo(new String[0], null, null, TOCType.NONE);

    private String[] number;
    public final String role;
    public final String title; // Comes from navtitle. May be null.
    public final TOCType tocType;

    // -----------------------------------------------------------------------

    public TOCInfo(String[] number, String role, String title, 
                   TOCType tocType) {
        this.number = number;
        this.role = role;
        this.title = title;
        this.tocType = tocType;
    }

    public void incrementNumber(int incr) {
        number = incrementNumber(number, incr);
    }

    public String[] getNumber() {
        return number;
    }

    @Override
    public String toString() {
        StringBuilder buffer = new StringBuilder();
        toString(buffer);
        return buffer.toString();
    }

    public void toString(StringBuilder buffer) {
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
    }

    // -----------------------------------------------------------------------

    public static String[] incrementNumber(String[] number, int incr) {
        String[] num = number.clone();

        String last = number[number.length-1];
        int pos = last.indexOf('.');
        if (pos >= 0) {
            try {
                int parsed = Integer.parseInt(last.substring(pos+1));

                // Incr may be negative or null. Therefore for some cases,
                // index may be null (but not negative).

                int index = parsed + incr; 
                if (index < 0) {
                    // Should not happen.
                    index = 0;
                }

                num[num.length-1] =
                    last.substring(0, pos+1) + Integer.toString(index);
            } catch (NumberFormatException ignored) {}
        }

        return num;
    }

    public static int parseNumber(String[] number) {
        return parseNumberSegment(number[number.length-1]);
    }

    public static int parseNumberSegment(String segment) {
        int parsed = -1;

        int pos = segment.indexOf('.');
        if (pos >= 0) {
            try {
                parsed = Integer.parseInt(segment.substring(pos+1));
            } catch (NumberFormatException ignored) {}
        }

        return parsed;
    }

    public static String formatNumberSegment(String role, int index) {
        StringBuilder buffer = new StringBuilder(role);
        buffer.append('.');
        buffer.append(Integer.toString(index));
        return buffer.toString();
    }
}

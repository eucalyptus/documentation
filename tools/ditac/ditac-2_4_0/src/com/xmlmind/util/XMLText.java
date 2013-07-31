/*
 * Copyright (c) 2002-2011 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of several XMLmind projects.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.util;

import java.io.UnsupportedEncodingException;
import java.util.Hashtable;
import java.util.StringTokenizer;

/**
 * A collection of utility functions (static methods) related to XML
 * characters and XML text.
 */
public final class XMLText {
    private XMLText() {}

    /**
     * Tests if specified character is a XML space (<tt>'\t'</tt>,
     * <tt>'\r'</tt>, <tt>'\n'</tt>, <tt>' '</tt>).
     * 
     * @param c character to be tested
     * @return <code>true</code> if test is successful; <code>false</code>
     * otherwise
     */
    public static boolean isXMLSpace(char c) {
        switch (c) {
        case ' ': case '\t': case '\r': case '\n': // That is, #x20 #x9 #xD #xA
            return true;
        default:
            return false;
        }
    }

    /**
     * Tests if specified string only contains XML space (<tt>'\t'</tt>,
     * <tt>'\r'</tt>, <tt>'\n'</tt>, <tt>' '</tt>).
     * 
     * @param s string to be tested
     * @return <code>true</code> if <tt>s</tt> is empty or only contains XML
     * space; <code>false</code> otherwise
     */
    public static boolean isXMLSpace(String s) {
        int count = s.length();
        for (int i = 0; i < count; ++i) {
            switch (s.charAt(i)) {
            case ' ': case '\n': case '\r': case '\t':
                break;
            default:
                return false;
            }
        }
        return true;
    }

    /**
     * Tests if specified character is a character which can be contained in a
     * XML document.
     * 
     * @param c character to be tested
     * @return <code>true</code> if test is successful; <code>false</code>
     * otherwise
     */
    public static boolean isXMLChar(char c) {
        // Char ::= #x9 | #xA | #xD | [#x20-#xD7FF] | [#xE000-#xFFFD] | 
        //          [#x10000-#x10FFFF]

        switch (c) {
        case 0x9: case 0xA: case 0xD: // That is, '\t', '\n', '\r'
            return true;
        default:
            return
                ((c >= 0x20 && c <= 0xD7FF) || (c >= 0xE000 && c <= 0xFFFD));
        }
    }

    /**
     * Returns <code>false</code> if specified text contains non-XML
     * characters. Otherwise, return <code>true</code>.
     */
    public static boolean checkText(String text) {
        // Valid XML characters are specified by:
        // 
        // Char ::= #x9 | #xA | #xD | [#x20-#xD7FF] | [#xE000-#xFFFD] | 
        //          [#x10000-#x10FFFF]

        boolean invalidChar = false;

        int charCount = text.length();
        for (int i = 0; i < charCount; ++i) {
            char c = text.charAt(i);

            switch (c) {
            case 0x9:
            case 0xA:
            case 0xD:
                break;
            default:
                if (!((c >= 0x20 && c <= 0xD7FF) ||
                      (c >= 0xE000 && c <= 0xFFFD))) {
                    invalidChar = true;
                    break;
                }
            }
        }

        return !invalidChar;
    }

    /**
     * Returns a copy of specified text after removing all non-XML characters
     * (if any). Moreover, this function always replaces '\r' and "\r\n" by
     * '\n'.
     * 
     * @param text text to be filtered
     * @return filtered text
     */
    public static String filterText(String text) {
        char[] chars = text.toCharArray();
        final int textLength = chars.length;
        int charCount = 0;

        for (int i = 0; i < textLength; ++i) {
            char c = chars[i];

            switch (c) {
            case '\t':
            case '\n':
                chars[charCount++] = c;
                break;
            case '\r':
                if (i+1 < textLength && chars[i+1] == '\n') {
                    ++i;
                }
                chars[charCount++] = '\n';
                break;
            default:
                if ((c >= 0x20 && c <= 0xD7FF) || 
                    (c >= 0xE000 && c <= 0xFFFD)) {
                    chars[charCount++] = c;
                }
            }
        }

        return new String(chars, 0, charCount);
    }

    /**
     * Tests if specified character can used as the start of an NCName.
     * <p>Corresponds to: <tt>Letter | '_'</tt>.
     * 
     * @see #isNCNameOtherChar
     * @see #isNCNameChar
     */
    public static boolean isNCNameStartChar(char c) {
        switch (c) {
        case '_':
        case 0x0386: case 0x038C: case 0x03DA: case 0x03DC:
        case 0x03DE: case 0x03E0: case 0x0559: case 0x06D5:
        case 0x093D: case 0x09B2: case 0x0A5E: case 0x0A8D:
        case 0x0ABD: case 0x0AE0: case 0x0B3D: case 0x0B9C:
        case 0x0CDE: case 0x0E30: case 0x0E84: case 0x0E8A:
        case 0x0E8D: case 0x0EA5: case 0x0EA7: case 0x0EB0:
        case 0x0EBD: case 0x1100: case 0x1109: case 0x113C:
        case 0x113E: case 0x1140: case 0x114C: case 0x114E:
        case 0x1150: case 0x1159: case 0x1163: case 0x1165:
        case 0x1167: case 0x1169: case 0x1175: case 0x119E:
        case 0x11A8: case 0x11AB: case 0x11BA: case 0x11EB:
        case 0x11F0: case 0x11F9: case 0x1F59: case 0x1F5B:
        case 0x1F5D: case 0x1FBE: case 0x2126: case 0x212E:
        case 0x3007:
            return true;
        default:
            return 
               ((c >= 0x0041 && c <= 0x005A) || (c >= 0x0061 && c <= 0x007A) ||
                (c >= 0x00C0 && c <= 0x00D6) || (c >= 0x00D8 && c <= 0x00F6) ||
                (c >= 0x00F8 && c <= 0x00FF) || (c >= 0x0100 && c <= 0x0131) ||
                (c >= 0x0134 && c <= 0x013E) || (c >= 0x0141 && c <= 0x0148) ||
                (c >= 0x014A && c <= 0x017E) || (c >= 0x0180 && c <= 0x01C3) ||
                (c >= 0x01CD && c <= 0x01F0) || (c >= 0x01F4 && c <= 0x01F5) ||
                (c >= 0x01FA && c <= 0x0217) || (c >= 0x0250 && c <= 0x02A8) ||
                (c >= 0x02BB && c <= 0x02C1) || (c >= 0x0388 && c <= 0x038A) ||
                (c >= 0x038E && c <= 0x03A1) || (c >= 0x03A3 && c <= 0x03CE) ||
                (c >= 0x03D0 && c <= 0x03D6) || (c >= 0x03E2 && c <= 0x03F3) ||
                (c >= 0x0401 && c <= 0x040C) || (c >= 0x040E && c <= 0x044F) ||
                (c >= 0x0451 && c <= 0x045C) || (c >= 0x045E && c <= 0x0481) ||
                (c >= 0x0490 && c <= 0x04C4) || (c >= 0x04C7 && c <= 0x04C8) ||
                (c >= 0x04CB && c <= 0x04CC) || (c >= 0x04D0 && c <= 0x04EB) ||
                (c >= 0x04EE && c <= 0x04F5) || (c >= 0x04F8 && c <= 0x04F9) ||
                (c >= 0x0531 && c <= 0x0556) || (c >= 0x0561 && c <= 0x0586) ||
                (c >= 0x05D0 && c <= 0x05EA) || (c >= 0x05F0 && c <= 0x05F2) ||
                (c >= 0x0621 && c <= 0x063A) || (c >= 0x0641 && c <= 0x064A) ||
                (c >= 0x0671 && c <= 0x06B7) || (c >= 0x06BA && c <= 0x06BE) ||
                (c >= 0x06C0 && c <= 0x06CE) || (c >= 0x06D0 && c <= 0x06D3) ||
                (c >= 0x06E5 && c <= 0x06E6) || (c >= 0x0905 && c <= 0x0939) ||
                (c >= 0x0958 && c <= 0x0961) || (c >= 0x0985 && c <= 0x098C) ||
                (c >= 0x098F && c <= 0x0990) || (c >= 0x0993 && c <= 0x09A8) ||
                (c >= 0x09AA && c <= 0x09B0) || (c >= 0x09B6 && c <= 0x09B9) ||
                (c >= 0x09DC && c <= 0x09DD) || (c >= 0x09DF && c <= 0x09E1) ||
                (c >= 0x09F0 && c <= 0x09F1) || (c >= 0x0A05 && c <= 0x0A0A) ||
                (c >= 0x0A0F && c <= 0x0A10) || (c >= 0x0A13 && c <= 0x0A28) ||
                (c >= 0x0A2A && c <= 0x0A30) || (c >= 0x0A32 && c <= 0x0A33) ||
                (c >= 0x0A35 && c <= 0x0A36) || (c >= 0x0A38 && c <= 0x0A39) ||
                (c >= 0x0A59 && c <= 0x0A5C) || (c >= 0x0A72 && c <= 0x0A74) ||
                (c >= 0x0A85 && c <= 0x0A8B) || (c >= 0x0A8F && c <= 0x0A91) ||
                (c >= 0x0A93 && c <= 0x0AA8) || (c >= 0x0AAA && c <= 0x0AB0) ||
                (c >= 0x0AB2 && c <= 0x0AB3) || (c >= 0x0AB5 && c <= 0x0AB9) ||
                (c >= 0x0B05 && c <= 0x0B0C) || (c >= 0x0B0F && c <= 0x0B10) ||
                (c >= 0x0B13 && c <= 0x0B28) || (c >= 0x0B2A && c <= 0x0B30) ||
                (c >= 0x0B32 && c <= 0x0B33) || (c >= 0x0B36 && c <= 0x0B39) ||
                (c >= 0x0B5C && c <= 0x0B5D) || (c >= 0x0B5F && c <= 0x0B61) ||
                (c >= 0x0B85 && c <= 0x0B8A) || (c >= 0x0B8E && c <= 0x0B90) ||
                (c >= 0x0B92 && c <= 0x0B95) || (c >= 0x0B99 && c <= 0x0B9A) ||
                (c >= 0x0B9E && c <= 0x0B9F) || (c >= 0x0BA3 && c <= 0x0BA4) ||
                (c >= 0x0BA8 && c <= 0x0BAA) || (c >= 0x0BAE && c <= 0x0BB5) ||
                (c >= 0x0BB7 && c <= 0x0BB9) || (c >= 0x0C05 && c <= 0x0C0C) ||
                (c >= 0x0C0E && c <= 0x0C10) || (c >= 0x0C12 && c <= 0x0C28) ||
                (c >= 0x0C2A && c <= 0x0C33) || (c >= 0x0C35 && c <= 0x0C39) ||
                (c >= 0x0C60 && c <= 0x0C61) || (c >= 0x0C85 && c <= 0x0C8C) ||
                (c >= 0x0C8E && c <= 0x0C90) || (c >= 0x0C92 && c <= 0x0CA8) ||
                (c >= 0x0CAA && c <= 0x0CB3) || (c >= 0x0CB5 && c <= 0x0CB9) ||
                (c >= 0x0CE0 && c <= 0x0CE1) || (c >= 0x0D05 && c <= 0x0D0C) ||
                (c >= 0x0D0E && c <= 0x0D10) || (c >= 0x0D12 && c <= 0x0D28) ||
                (c >= 0x0D2A && c <= 0x0D39) || (c >= 0x0D60 && c <= 0x0D61) ||
                (c >= 0x0E01 && c <= 0x0E2E) || (c >= 0x0E32 && c <= 0x0E33) ||
                (c >= 0x0E40 && c <= 0x0E45) || (c >= 0x0E81 && c <= 0x0E82) ||
                (c >= 0x0E87 && c <= 0x0E88) || (c >= 0x0E94 && c <= 0x0E97) ||
                (c >= 0x0E99 && c <= 0x0E9F) || (c >= 0x0EA1 && c <= 0x0EA3) ||
                (c >= 0x0EAA && c <= 0x0EAB) || (c >= 0x0EAD && c <= 0x0EAE) ||
                (c >= 0x0EB2 && c <= 0x0EB3) || (c >= 0x0EC0 && c <= 0x0EC4) ||
                (c >= 0x0F40 && c <= 0x0F47) || (c >= 0x0F49 && c <= 0x0F69) ||
                (c >= 0x10A0 && c <= 0x10C5) || (c >= 0x10D0 && c <= 0x10F6) ||
                (c >= 0x1102 && c <= 0x1103) || (c >= 0x1105 && c <= 0x1107) ||
                (c >= 0x110B && c <= 0x110C) || (c >= 0x110E && c <= 0x1112) ||
                (c >= 0x1154 && c <= 0x1155) || (c >= 0x115F && c <= 0x1161) ||
                (c >= 0x116D && c <= 0x116E) || (c >= 0x1172 && c <= 0x1173) ||
                (c >= 0x11AE && c <= 0x11AF) || (c >= 0x11B7 && c <= 0x11B8) ||
                (c >= 0x11BC && c <= 0x11C2) || (c >= 0x1E00 && c <= 0x1E9B) ||
                (c >= 0x1EA0 && c <= 0x1EF9) || (c >= 0x1F00 && c <= 0x1F15) ||
                (c >= 0x1F18 && c <= 0x1F1D) || (c >= 0x1F20 && c <= 0x1F45) ||
                (c >= 0x1F48 && c <= 0x1F4D) || (c >= 0x1F50 && c <= 0x1F57) ||
                (c >= 0x1F5F && c <= 0x1F7D) || (c >= 0x1F80 && c <= 0x1FB4) ||
                (c >= 0x1FB6 && c <= 0x1FBC) || (c >= 0x1FC2 && c <= 0x1FC4) ||
                (c >= 0x1FC6 && c <= 0x1FCC) || (c >= 0x1FD0 && c <= 0x1FD3) ||
                (c >= 0x1FD6 && c <= 0x1FDB) || (c >= 0x1FE0 && c <= 0x1FEC) ||
                (c >= 0x1FF2 && c <= 0x1FF4) || (c >= 0x1FF6 && c <= 0x1FFC) ||
                (c >= 0x212A && c <= 0x212B) || (c >= 0x2180 && c <= 0x2182) ||
                (c >= 0x3041 && c <= 0x3094) || (c >= 0x30A1 && c <= 0x30FA) ||
                (c >= 0x3105 && c <= 0x312C) || (c >= 0xAC00 && c <= 0xD7A3) ||
                (c >= 0x4E00 && c <= 0x9FA5) || (c >= 0x3021 && c <= 0x3029));
        }
    }

    /**
     * Tests if specified character, even if not authorized as the first
     * character of an NCName, can be one of the other characters of an
     * NCName.
     * <p>Corresponds to: 
     * <tt>Digit | '.' | '-' | CombiningChar | Extender</tt>.
     * 
     * @see #isNCNameStartChar
     * @see #isNCNameChar
     */
    public static boolean isNCNameOtherChar(char c) {
        switch (c) {
        case '-': case '.':
        case 0x05BF: case 0x05C4: case 0x0670: case 0x093C:
        case 0x094D: case 0x09BC: case 0x09BE: case 0x09BF:
        case 0x09D7: case 0x0A02: case 0x0A3C: case 0x0A3E:
        case 0x0A3F: case 0x0ABC: case 0x0B3C: case 0x0BD7:
        case 0x0D57: case 0x0E31: case 0x0EB1: case 0x0F35:
        case 0x0F37: case 0x0F39: case 0x0F3E: case 0x0F3F:
        case 0x0F97: case 0x0FB9: case 0x20E1: case 0x3099:
        case 0x309A: case 0x00B7: case 0x02D0: case 0x02D1:
        case 0x0387: case 0x0640: case 0x0E46: case 0x0EC6:
        case 0x3005:
            return true;
        default:
            return
               ((c >= 0x0300 && c <= 0x0345) || (c >= 0x0360 && c <= 0x0361) ||
                (c >= 0x0483 && c <= 0x0486) || (c >= 0x0591 && c <= 0x05A1) ||
                (c >= 0x05A3 && c <= 0x05B9) || (c >= 0x05BB && c <= 0x05BD) ||
                (c >= 0x05C1 && c <= 0x05C2) || (c >= 0x064B && c <= 0x0652) ||
                (c >= 0x06D6 && c <= 0x06DC) || (c >= 0x06DD && c <= 0x06DF) ||
                (c >= 0x06E0 && c <= 0x06E4) || (c >= 0x06E7 && c <= 0x06E8) ||
                (c >= 0x06EA && c <= 0x06ED) || (c >= 0x0901 && c <= 0x0903) ||
                (c >= 0x093E && c <= 0x094C) || (c >= 0x0951 && c <= 0x0954) ||
                (c >= 0x0962 && c <= 0x0963) || (c >= 0x0981 && c <= 0x0983) ||
                (c >= 0x09C0 && c <= 0x09C4) || (c >= 0x09C7 && c <= 0x09C8) ||
                (c >= 0x09CB && c <= 0x09CD) || (c >= 0x09E2 && c <= 0x09E3) ||
                (c >= 0x0A40 && c <= 0x0A42) || (c >= 0x0A47 && c <= 0x0A48) ||
                (c >= 0x0A4B && c <= 0x0A4D) || (c >= 0x0A70 && c <= 0x0A71) ||
                (c >= 0x0A81 && c <= 0x0A83) || (c >= 0x0ABE && c <= 0x0AC5) ||
                (c >= 0x0AC7 && c <= 0x0AC9) || (c >= 0x0ACB && c <= 0x0ACD) ||
                (c >= 0x0B01 && c <= 0x0B03) || (c >= 0x0B3E && c <= 0x0B43) ||
                (c >= 0x0B47 && c <= 0x0B48) || (c >= 0x0B4B && c <= 0x0B4D) ||
                (c >= 0x0B56 && c <= 0x0B57) || (c >= 0x0B82 && c <= 0x0B83) ||
                (c >= 0x0BBE && c <= 0x0BC2) || (c >= 0x0BC6 && c <= 0x0BC8) ||
                (c >= 0x0BCA && c <= 0x0BCD) || (c >= 0x0C01 && c <= 0x0C03) ||
                (c >= 0x0C3E && c <= 0x0C44) || (c >= 0x0C46 && c <= 0x0C48) ||
                (c >= 0x0C4A && c <= 0x0C4D) || (c >= 0x0C55 && c <= 0x0C56) ||
                (c >= 0x0C82 && c <= 0x0C83) || (c >= 0x0CBE && c <= 0x0CC4) ||
                (c >= 0x0CC6 && c <= 0x0CC8) || (c >= 0x0CCA && c <= 0x0CCD) ||
                (c >= 0x0CD5 && c <= 0x0CD6) || (c >= 0x0D02 && c <= 0x0D03) ||
                (c >= 0x0D3E && c <= 0x0D43) || (c >= 0x0D46 && c <= 0x0D48) ||
                (c >= 0x0D4A && c <= 0x0D4D) || (c >= 0x0E34 && c <= 0x0E3A) ||
                (c >= 0x0E47 && c <= 0x0E4E) || (c >= 0x0EB4 && c <= 0x0EB9) ||
                (c >= 0x0EBB && c <= 0x0EBC) || (c >= 0x0EC8 && c <= 0x0ECD) ||
                (c >= 0x0F18 && c <= 0x0F19) || (c >= 0x0F71 && c <= 0x0F84) ||
                (c >= 0x0F86 && c <= 0x0F8B) || (c >= 0x0F90 && c <= 0x0F95) ||
                (c >= 0x0F99 && c <= 0x0FAD) || (c >= 0x0FB1 && c <= 0x0FB7) ||
                (c >= 0x20D0 && c <= 0x20DC) || (c >= 0x302A && c <= 0x302F) ||
                (c >= 0x0030 && c <= 0x0039) || (c >= 0x0660 && c <= 0x0669) ||
                (c >= 0x06F0 && c <= 0x06F9) || (c >= 0x0966 && c <= 0x096F) ||
                (c >= 0x09E6 && c <= 0x09EF) || (c >= 0x0A66 && c <= 0x0A6F) ||
                (c >= 0x0AE6 && c <= 0x0AEF) || (c >= 0x0B66 && c <= 0x0B6F) ||
                (c >= 0x0BE7 && c <= 0x0BEF) || (c >= 0x0C66 && c <= 0x0C6F) ||
                (c >= 0x0CE6 && c <= 0x0CEF) || (c >= 0x0D66 && c <= 0x0D6F) ||
                (c >= 0x0E50 && c <= 0x0E59) || (c >= 0x0ED0 && c <= 0x0ED9) ||
                (c >= 0x0F20 && c <= 0x0F29) || (c >= 0x3031 && c <= 0x3035) ||
                (c >= 0x309D && c <= 0x309E) || (c >= 0x30FC && c <= 0x30FE));
        }
    }

    /**
     * Tests if specified character can used in an NCName at a position other
     * the first one.
     * <p>Corresponds to: 
     * <tt>Letter | Digit | '.' | '-' | '_' | CombiningChar | Extender</tt>.
     * 
     * @see #isNCNameStartChar
     * @see #isNCNameOtherChar
     */
    public static boolean isNCNameChar(char c) {
        return (isNCNameStartChar(c) || isNCNameOtherChar(c));
    }

    /**
     * Tests if specified string is a lexically correct NCName.
     * 
     * @param s string to be tested
     * @return <code>true</code> if test is successful; <code>false</code>
     * otherwise
     */
    public static boolean isNCName(String s) {
        int count;
        if (s == null || (count = s.length()) == 0)
            return false;

        char c = s.charAt(0);
        if (!isNCNameStartChar(c))
            return false;

        for (int i = 1; i < count; ++i) {
            c = s.charAt(i);
            if (!isNCNameChar(c))
                return false;
        }

        return true;
    }

    /**
     * Tests if specified character can used as the start of an Name.
     * <p>Corresponds to: <tt>Letter | '_' | ':'</tt>.
     * 
     * @see #isNameOtherChar
     * @see #isNameChar
     */
    public static boolean isNameStartChar(char c) {
        if (c == ':')
            return true;
        else
            return isNCNameStartChar(c);
    }

    /**
     * Tests if specified character, even if not authorized as the first
     * character of an Name, can be one of the other characters of an
     * Name.
     * <p>Corresponds to: 
     * <tt>Digit | '.' | '-' | ':' | CombiningChar | Extender</tt>.
     * 
     * @see #isNameStartChar
     * @see #isNameChar
     */
    public static boolean isNameOtherChar(char c) {
        if (c == ':')
            return true;
        else
            return isNCNameOtherChar(c);
    }

    /**
     * Tests if specified character can used in an Name at a position other
     * the first one.
     * <p>Corresponds to: 
     * <tt>Letter|Digit | '.' | '-' | '_' | ':' | CombiningChar|Extender</tt>.
     * 
     * @see #isNameStartChar
     * @see #isNameOtherChar
     */
    public static boolean isNameChar(char c) {
        return (isNameStartChar(c) || isNameOtherChar(c));
    }

    /**
     * Tests if specified string is a lexically correct Name.
     * 
     * @param s string to be tested
     * @return <code>true</code> if test is successful; <code>false</code>
     * otherwise
     */
    public static boolean isName(String s) {
        int count;
        if (s == null || (count = s.length()) == 0)
            return false;

        char c = s.charAt(0);
        if (!isNameStartChar(c))
            return false;

        for (int i = 1; i < count; ++i) {
            c = s.charAt(i);
            if (!isNameChar(c))
                return false;
        }

        return true;
    }

    /**
     * Tests if specified string is a lexically correct NMTOKEN.
     * 
     * @param s string to be tested
     * @return <code>true</code> if test is successful; <code>false</code>
     * otherwise
     */
    public static boolean isNmtoken(String s) {
        int count;
        if (s == null || (count = s.length()) == 0)
            return false;

        for (int i = 0; i < count; ++i) {
            char c = s.charAt(i);
            if (!isNameChar(c))
                return false;
        }

        return true;
    }

    /**
     * Tests if specified string is a lexically correct target for a process
     * instruction.
     * <p>Note that Names starting with "<tt>xml</tt>" (case-insensitive) are
     * rejected.
     * 
     * @param s string to be tested
     * @return <code>true</code> if test is successful; <code>false</code>
     * otherwise
     */
    public static boolean isPITarget(String s) {
        if (s == null || s.length() == 0)
            return false;

        return (isName(s) && 
                !s.regionMatches(/*ignoreCase*/ true, 0, "xml", 0, 3));
    }

    // -----------------------------------------------------------------------

    /**
     * Replaces successive XML space characters by a single space character 
     * (<tt>' '</tt>) then removes leading and trailing space characters 
     * if any.
     * 
     * @param value string to be processed
     * @return processed string
     */
    public static String collapseWhiteSpace(String value) {
        StringBuilder buffer = new StringBuilder();
        compressWhiteSpace(value, buffer);

        int last = buffer.length() - 1;
        if (last >= 0) {
            if (buffer.charAt(last) == ' ') {
                buffer.deleteCharAt(last);
                --last;
            }

            if (last >= 0 && buffer.charAt(0) == ' ')
                buffer.deleteCharAt(0);
        }

        return buffer.toString();
    }

    /**
     * Replaces successive XML space characters (<tt>'\t'</tt>, <tt>'\r'</tt>,
     * <tt>'\n'</tt>, <tt>' '</tt>) by a single space character (<tt>' '</tt>).
     * 
     * @param value string to be processed
     * @return processed string
     */
    public static String compressWhiteSpace(String value) {
        StringBuilder buffer = new StringBuilder();
        compressWhiteSpace(value, buffer);
        return buffer.toString();
    }

    /**
     * Replaces successive XML space characters (<tt>'\t'</tt>, <tt>'\r'</tt>,
     * <tt>'\n'</tt>, <tt>' '</tt>) by a single space character (<tt>' '</tt>).
     * 
     * @param value string to be processed
     * @param buffer buffer used to store processed characters (characters are
     * appended to this buffer)
     */
    private static void compressWhiteSpace(String value, 
                                           StringBuilder buffer) {
        // No need to convert "\r\n" to a single '\n' because white spaces
        // are compressed.

        int length = value.length();
        char prevChar = '?';
        for (int i = 0; i < length; ++i) {
            char c = value.charAt(i);

            switch (c) {
            case '\t': case '\r': case '\n':
                c = ' ';
                break;
            }

            if (c == ' ') {
                if (prevChar != ' ') {
                    buffer.append(c);
                    prevChar = c;
                }
            } else {
                buffer.append(c);
                prevChar = c;
            }
        }
    }

    /**
     * Replaces sequence "<tt>\r\n</tt>" and characters <tt>'\t'</tt>,
     * <tt>'\r'</tt>, <tt>'\n'</tt> by a single space character <tt>' '</tt>.
     * 
     * @param value string to be processed
     * @return processed string
     */
    public static String replaceWhiteSpace(String value) {
        StringBuilder buffer = new StringBuilder();

        int length = value.length();
        char prevChar = '?';
        for (int i = 0; i < length; ++i) {
            char c = value.charAt(i);

            switch (c) {
            case '\t': case '\r': 
                buffer.append(' ');
                break;
            case '\n':
                // Equivalent to converting "\r\n" to a single '\n' then
                // converting '\n' to ' '.
                if (prevChar != '\r')
                    buffer.append(' ');
                break;
            default:
                buffer.append(c);
            }

            prevChar = c;
        }

        return buffer.toString();
    }

    // -----------------------------------------------------------------------

    /**
     * Splits specified string at XML whitespace character boundaries 
     * (<tt>'\t'</tt>, <tt>'\r'</tt>, <tt>'\n'</tt>, <tt>' '</tt>). 
     * Returns list of parts.
     * 
     * @param s string to be split
     * @return list of parts
     */
    public static String[] splitList(String s) {
        StringTokenizer tokens = new StringTokenizer(s, " \n\r\t");
        String[] split = new String[tokens.countTokens()];

        for (int i = 0; i < split.length; ++i)
            split[i] = tokens.nextToken();

        return split;
    }

    // -----------------------------------------------------------------------

    /**
     * Escapes specified string (that is, <tt>'&lt;'</tt> is replaced by 
     * "<tt>&amp;#60</tt>;", <tt>'&amp;'</tt> is replaced by 
     * "<tt>&amp;#38;</tt>", etc) then puts the escaped string between 
     * quotes (<tt>"</tt>).
     * 
     * @param string string to be escaped and quoted
     * @return escaped and quoted string
     */
    public static String quoteXML(String string) {
        StringBuilder quoted = new StringBuilder();
        quoteXML(string, quoted);
        return quoted.toString();
    }

    /**
     * Escapes specified string (that is, 
     * <tt>'&lt;'</tt> is replaced by "<tt>&amp;#60</tt>;",
     * <tt>'&amp;'</tt> is replaced by "<tt>&amp;#38;</tt>", etc) then puts
     * the escaped string between quotes (<tt>"</tt>).
     * 
     * @param string string to be escaped and quoted
     * @param quoted buffer used to store escaped and quoted string
     * (characters are appended to this buffer)
     */
    public static void quoteXML(String string, StringBuilder quoted) {
        quoted.append('\"');
        escapeXML(string, quoted);
        quoted.append('\"');
    }

    /**
     * Escapes specified string (that is, 
     * <tt>'&lt;'</tt> is replaced by "<tt>&amp;#60</tt>;",
     * <tt>'&amp;'</tt> is replaced by "<tt>&amp;#38;</tt>", etc).
     * 
     * @param string string to be escaped
     * @return escaped string
     */
    public static String escapeXML(String string) {
        StringBuilder escaped = new StringBuilder();
        escapeXML(string, escaped);
        return escaped.toString();
    }

    /**
     * Escapes specified string (that is, 
     * <tt>'&lt;'</tt> is replaced by "<tt>&amp;#60</tt>;",
     * <tt>'&amp;'</tt> is replaced by "<tt>&amp;#38;</tt>", etc).
     * 
     * @param string string to be escaped
     * @param escaped buffer used to store escaped string (characters are
     * appended to this buffer)
     */
    public static void escapeXML(String string, StringBuilder escaped) {
        char[] chars = string.toCharArray();
        escapeXML(chars, 0, chars.length, escaped);
    }

    /**
     * Escapes specified character array 
     * (that is, <tt>'&lt;'</tt> is replaced
     * by "<tt>&amp;#60</tt>;", <tt>'&amp;'</tt> is replaced 
     * by "<tt>&amp;#38;</tt>", etc).
     * 
     * @param chars character array to be escaped
     * @param offset specifies first character in array to be escaped
     * @param length number of characters in array to be escaped
     * @param escaped buffer used to store escaped string (characters are
     * appended to this buffer)
     */
    public static void escapeXML(char[] chars, int offset, int length, 
                                 StringBuilder escaped) {
        escapeXML(chars, offset, length, escaped, Integer.MAX_VALUE);
    }

    /**
     * Escapes specified character array (that is, <tt>'&lt;'</tt> is replaced
     * by "<tt>&amp;#60</tt>;", <tt>'&amp;'</tt> is replaced by 
     * "<tt>&amp;#38;</tt>", etc).
     * 
     * @param chars character array to be escaped
     * @param offset specifies first character in array to be escaped
     * @param length number of characters in array to be escaped
     * @param escaped buffer used to store escaped string (characters are
     * appended to this buffer)
     * @param maxCode characters with code &gt; maxCode are escaped as 
     * <tt>&amp;#<i>code</i>;</tt>.
     * Pass 127 for US-ASCII, 255 for ISO-8859-1, otherwise pass
     * <code>Integer.MAX_VALUE</code>.
     */
    public static void escapeXML(char[] chars, int offset, int length, 
                                 StringBuilder escaped, int maxCode) {
        int end = offset + length;
        for (int i = offset; i < end; ++i) {
            char c = chars[i];
            switch (c) {
            case '\'':
                escaped.append("&#39;");
                break;
            case '\"':
                escaped.append("&#34;");
                break;
            case '<':
                escaped.append("&#60;");
                break;
            case '>':
                escaped.append("&#62;");
                break;
            case '&':
                escaped.append("&#38;");
                break;
            default:
                if (c > maxCode) {
                    escaped.append("&#");
                    escaped.append(Integer.toString((int) c));
                    escaped.append(';');
                } else {
                    escaped.append(c);
                }
            }
        }
    }

    // -----------------------------------------------------------------------

    /**
     * Unescapes specified string. Inverse operation of {@link #escapeXML}.
     * 
     * @param text string to be unescaped
     * @return unescaped string
     */
    public static String unescapeXML(String text) {
        StringBuilder unescaped = new StringBuilder();
        unescapeXML(text, 0, text.length(), unescaped);
        return unescaped.toString();
    }

    /**
     * Unescapes specified string. Inverse operation of {@link #escapeXML}.
     * 
     * @param text string to be unescaped
     * @param offset specifies first character in string to be unescaped
     * @param length number of characters in string to be unescaped
     * @param unescaped buffer used to store unescaped string (characters are
     * appended to this buffer)
     */
    public static void unescapeXML(String text, int offset, int length,
                                   StringBuilder unescaped) {
        int end = offset + length;

        for (int i = offset; i < end; ++i) {
            char c = text.charAt(i);

            if (c == '&') {
                StringBuilder charRef = new StringBuilder();

                ++i;
                while (i < end) {
                    c = text.charAt(i);
                    if (c == ';')
                        break;
                    charRef.append(c);
                    ++i;
                }

                c = parseCharRef(charRef.toString());
            } 

            unescaped.append(c);
        }
    }

    private static char parseCharRef(String charRef) {
        if (charRef.length() >= 2 && charRef.charAt(0) == '#') {
            int i;

            try {
                if (charRef.charAt(1) == 'x')
                    i = Integer.parseInt(charRef.substring(2), 16);
                else
                    i = Integer.parseInt(charRef.substring(1));
            } catch (NumberFormatException e) {
                i = - 1;
            }

            if (i < 0 || i > Character.MAX_VALUE)
                return '?';
            else
                return (char) i;
        } if (charRef.equals("amp")) {
            return '&';
        } if (charRef.equals("apos")) {
            return '\'';
        } if (charRef.equals("quot")) {
            return '\"';
        } if (charRef.equals("lt")) {
            return '<';
        } if (charRef.equals("gt")) {
            return '>';
        } else {
            return '?';
        }
    }
}

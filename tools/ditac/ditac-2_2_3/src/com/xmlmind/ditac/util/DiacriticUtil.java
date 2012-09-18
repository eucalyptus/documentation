/*
 * Copyright (c) 2009-2010 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.util;

public final class DiacriticUtil {
    private DiacriticUtil() {}

    // -----------------------------------------------------------------------

    private static final void mapRange(int c1, int c2, char c) {
        for (; c1 <= c2; c1++) {
            diacritics[c1] = c;
        }
    }

    private static final void mapChar(int c1, char c) {
        diacritics[c1] = c;
    }

    private static char[] diacritics = new char[0x300];
    static {
        for (int c = 0; c < diacritics.length; c++) {
            diacritics[c] = (char) c;
        }

        mapRange(0x00C0, 0x00C5, ('A')); // LATIN CAPITAL LETTER A WITH GRAVE

        mapChar(0x00C6, (char) 0xe6); // LATIN CAPITAL LETTER AE
        mapChar(0x00C7, 'C'); // LATIN CAPITAL LETTER C WITH CEDILLA

        mapRange(0x00C8, 0x00CB, ('E'));
        mapRange(0x00CC, 0x00CF, ('I'));

        mapChar(0x00D1, 'N'); // LATIN CAPITAL LETTER N WITH TILDE

        mapRange(0x00D2, 0x00D8, 'O');
        mapRange(0x00D9, 0x00DC, 'U');

        mapChar(0x00DD, 'Y'); // LATIN CAPITAL LETTER Y WITH ACUTE

        mapRange(0x00E0, 0x00E5, 'a');

        mapChar(0x00E7, 'c'); // LATIN SMALL LETTER C WITH CEDILLA

        mapRange(0x00E8, 0x00EB, 'e');

        mapRange(0x00EC, 0x00EF, 'i');

        mapChar(0x00F0, (char) 0xd0); // LATIN SMALL LETTER ETH

        mapChar(0x00F1, 'n'); // LATIN SMALL LETTER N WITH TILDE

        mapRange(0x00F2, 0x00F8, 'o');

        mapRange(0x00F9, 0x00FC, 'u');

        mapChar(0x00FD, 'y'); // LATIN SMALL LETTER Y WITH ACUTE
        mapChar(0x00FE, (char) 0x00de); // LATIN SMALL LETTER THORN
        mapChar(0x00FF, 'y'); // LATIN SMALL LETTER Y WITH DIAERESIS

        mapRange(0x0100, 0x0105, 'a'); // MACRON BREVE OGONEK

        mapRange(0x0106, 0x010D, 'c'); // ACUTE, CIRCUMFLEX, DOT ABOVE, CARON

        mapRange(0x010E, 0x0111, 'd'); // CARON, STROKE

        mapRange(0x0112, 0x011B, 'e');

        mapRange(0x011C, 0x0123, 'g'); // CIRCUMFLEX BREVE DOT ABOVE CEDILLA
        mapRange(0x0124, 0x0127, 'h'); // 
        mapRange(0x0128, 0x0131, 'i');

        mapChar(0x0133, (char) 0x0132); // LATIN SMALL LIGATURE IJ

        mapRange(0x0134, 0x0135, 'j');
        mapRange(0x0136, 0x0137, 'k');

        mapRange(0x0139, 0x0142, 'l');
        mapRange(0x0143, 0x0149, 'n');

        mapRange(0x014C, 0x0151, 'o');

        mapRange(0x0154, 0x0159, 'r');
        mapRange(0x015A, 0x0161, 's');
        mapRange(0x0162, 0x0167, 't');
        mapRange(0x0168, 0x0173, 'u');
        mapRange(0x0174, 0x0175, 'w');
        mapRange(0x0176, 0x0178, 'y');
        mapRange(0x0179, 0x017E, 'z');

        mapChar(0x017F, 's'); // LATIN SMALL LETTER LONG S

        mapRange(0x0180, 0x0183, 'b');

        mapChar(0x0186, 'o'); // LATIN CAPITAL LETTER OPEN O

        mapRange(0x0187, 0x0188, 'c');

        mapRange(0x0189, 0x018C, 'd');

        mapChar(0x018E, 'E'); // LATIN CAPITAL LETTER REVERSED E
        mapChar(0x0190, 'E'); // LATIN CAPITAL LETTER OPEN E
        mapChar(0x0191, 'F'); // LATIN CAPITAL LETTER F WITH HOOK
        mapChar(0x0192, 'f'); // LATIN SMALL LETTER F WITH HOOK
        mapChar(0x0193, 'G'); // LATIN CAPITAL LETTER G WITH HOOK
        mapChar(0x0197, 'I'); // LATIN CAPITAL LETTER I WITH STROKE
        mapChar(0x0198, 'K'); // LATIN CAPITAL LETTER K WITH HOOK
        mapChar(0x0199, 'k'); // LATIN SMALL LETTER K WITH HOOK
        mapChar(0x019A, 'l'); // LATIN SMALL LETTER L WITH BAR
        mapChar(0x019C, 'M'); // LATIN CAPITAL LETTER TURNED M
        mapChar(0x019D, 'N'); // LATIN CAPITAL LETTER N WITH LEFT
        // HOOK
        mapChar(0x019E, 'n'); // LATIN SMALL LETTER N WITH LONG RIGHT LEG
        mapChar(0x019F, 'O'); // LATIN CAPITAL LETTER O WITH MIDDLE
        // TILDE
        mapChar(0x01A0, 'O'); // LATIN CAPITAL LETTER O WITH HORN
        mapChar(0x01A1, 'o'); // LATIN SMALL LETTER O WITH HORN
        mapChar(0x01A3, (char) 0x01a2); // LATIN SMALL LETTER OI
        mapChar(0x01A4, 'P'); // LATIN CAPITAL LETTER P WITH HOOK
        mapChar(0x01A5, 'p'); // LATIN SMALL LETTER P WITH HOOK
        mapChar(0x01AB, 't'); // LATIN SMALL LETTER T WITH PALATAL HOOK
        mapChar(0x01AC, 'T'); // LATIN CAPITAL LETTER T WITH HOOK
        mapChar(0x01AD, 't'); // LATIN SMALL LETTER T WITH HOOK
        mapChar(0x01AE, 'T'); // LATIN CAPITAL LETTER T WITH
        // RETROFLEX HOOK
        mapChar(0x01AF, 'U'); // LATIN CAPITAL LETTER U WITH HORN
        mapChar(0x01B0, 'u'); // LATIN SMALL LETTER U WITH HORN
        mapChar(0x01B2, 'V'); // LATIN CAPITAL LETTER V WITH HOOK
        mapChar(0x01B3, 'Y'); // LATIN CAPITAL LETTER Y WITH HOOK
        mapChar(0x01B4, 'y'); // LATIN SMALL LETTER Y WITH HOOK
        mapChar(0x01B5, 'Z'); // LATIN CAPITAL LETTER Z WITH STROKE
        mapChar(0x01B6, 'z'); // LATIN SMALL LETTER Z WITH STROKE

        mapChar(0x01B8, (char) 0X01B7); // LATIN CAPITAL LETTER EZH
                                            // REVERSED
        mapChar(0x01B9, (char) 0x01b7); // LATIN SMALL LETTER EZH REVERSED
        mapChar(0x01BA, (char) 0x01b7); // LATIN SMALL LETTER EZH WITH TAIL

        mapChar(0x01CD, 'A'); // LATIN CAPITAL LETTER A WITH CARON
        mapChar(0x01CE, 'a'); // LATIN SMALL LETTER A WITH CARON
        mapChar(0x01CF, 'I'); // LATIN CAPITAL LETTER I WITH CARON
        mapChar(0x01D0, 'i'); // LATIN SMALL LETTER I WITH CARON
        mapChar(0x01D1, 'O'); // LATIN CAPITAL LETTER O WITH CARON
        mapChar(0x01D2, 'o'); // LATIN SMALL LETTER O WITH CARON

        mapRange(0x01D3, 0x01DC, 'u');

        mapChar(0x01DD, 'e'); // LATIN SMALL LETTER TURNED E
        mapChar(0x01DE, 'A'); // LATIN CAPITAL LETTER A WITH DIAERESIS
                                    // AND MACRON
        mapChar(0x01DF, 'a'); // LATIN SMALL LETTER A WITH DIAERESIS AND
                                // MACRON
        mapChar(0x01E0, 'A'); // LATIN CAPITAL LETTER A WITH DOT ABOVE
                                    // AND MACRON
        mapChar(0x01E1, 'a'); // LATIN SMALL LETTER A WITH DOT ABOVE AND
                                // MACRON
        mapChar(0x01E2, (char) 0XC6); // LATIN CAPITAL LETTER AE WITH
                                            // MACRON
        mapChar(0x01E3, (char) 0xc6); // LATIN SMALL LETTER AE WITH MACRON
        mapChar(0x01E4, 'G'); // LATIN CAPITAL LETTER G WITH STROKE
        mapChar(0x01E5, 'g'); // LATIN SMALL LETTER G WITH STROKE
        mapChar(0x01E6, 'G'); // LATIN CAPITAL LETTER G WITH CARON
        mapChar(0x01E7, 'g'); // LATIN SMALL LETTER G WITH CARON
        mapChar(0x01E8, 'K'); // LATIN CAPITAL LETTER K WITH CARON
        mapChar(0x01E9, 'k'); // LATIN SMALL LETTER K WITH CARON
        mapChar(0x01EA, 'O'); // LATIN CAPITAL LETTER O WITH OGONEK
        mapChar(0x01EB, 'o'); // LATIN SMALL LETTER O WITH OGONEK
        mapChar(0x01EC, 'O'); // LATIN CAPITAL LETTER O WITH OGONEK AND
                                    // MACRON
        mapChar(0x01ED, 'o'); // LATIN SMALL LETTER O WITH OGONEK AND MACRON
        mapChar(0x01EE, (char) 0X01B7); // LATIN CAPITAL LETTER EZH WITH
                                            // CARON
        mapChar(0x01EF, (char) 0x01b7); // LATIN SMALL LETTER EZH WITH CARON
        mapChar(0x01F0, 'j'); // LATIN SMALL LETTER J WITH CARON

        mapChar(0x01F3, (char) 0x01f1); // LATIN SMALL LETTER DZ

        mapChar(0x01F4, 'G'); // LATIN CAPITAL LETTER G WITH ACUTE
        mapChar(0x01F5, 'g'); // LATIN SMALL LETTER G WITH ACUTE
        mapChar(0x01FA, 'A'); // LATIN CAPITAL LETTER A WITH RING ABOVE
                                    // AND ACUTE
        mapChar(0x01FB, 'a'); // LATIN SMALL LETTER A WITH RING ABOVE AND
                                // ACUTE
        mapChar(0x01FC, (char) 0XC6); // LATIN CAPITAL LETTER AE WITH
                                            // ACUTE
        mapChar(0x01FD, (char) 0xc6); // LATIN SMALL LETTER AE WITH ACUTE
        mapChar(0x01FE, 'O'); // LATIN CAPITAL LETTER O WITH STROKE AND
                                    // ACUTE
        mapChar(0x01FF, 'o'); // LATIN SMALL LETTER O WITH STROKE AND ACUTE
        mapChar(0x0200, 'A'); // LATIN CAPITAL LETTER A WITH DOUBLE GRAVE
        mapChar(0x0201, 'a'); // LATIN SMALL LETTER A WITH DOUBLE GRAVE
        mapChar(0x0202, 'A'); // LATIN CAPITAL LETTER A WITH INVERTED
                                    // BREVE
        mapChar(0x0203, 'a'); // LATIN SMALL LETTER A WITH INVERTED BREVE
        mapChar(0x0204, 'E'); // LATIN CAPITAL LETTER E WITH DOUBLE GRAVE
        mapChar(0x0205, 'e'); // LATIN SMALL LETTER E WITH DOUBLE GRAVE
        mapChar(0x0206, 'E'); // LATIN CAPITAL LETTER E WITH INVERTED
                                    // BREVE
        mapChar(0x0207, 'e'); // LATIN SMALL LETTER E WITH INVERTED BREVE
        mapChar(0x0208, 'I'); // LATIN CAPITAL LETTER I WITH DOUBLE GRAVE
        mapChar(0x0209, 'i'); // LATIN SMALL LETTER I WITH DOUBLE GRAVE
        mapChar(0x020A, 'I'); // LATIN CAPITAL LETTER I WITH INVERTED
                                    // BREVE
        mapChar(0x020B, 'i'); // LATIN SMALL LETTER I WITH INVERTED BREVE
        mapChar(0x020C, 'O'); // LATIN CAPITAL LETTER O WITH DOUBLE GRAVE
        mapChar(0x020D, 'o'); // LATIN SMALL LETTER O WITH DOUBLE GRAVE
        mapChar(0x020E, 'O'); // LATIN CAPITAL LETTER O WITH INVERTED
                                    // BREVE
        mapChar(0x020F, 'o'); // LATIN SMALL LETTER O WITH INVERTED BREVE
        mapChar(0x0210, 'R'); // LATIN CAPITAL LETTER R WITH DOUBLE GRAVE
        mapChar(0x0211, 'r'); // LATIN SMALL LETTER R WITH DOUBLE GRAVE
        mapChar(0x0212, 'R'); // LATIN CAPITAL LETTER R WITH INVERTED
                                    // BREVE
        mapChar(0x0213, 'r'); // LATIN SMALL LETTER R WITH INVERTED BREVE
        mapChar(0x0214, 'U'); // LATIN CAPITAL LETTER U WITH DOUBLE GRAVE
        mapChar(0x0215, 'u'); // LATIN SMALL LETTER U WITH DOUBLE GRAVE
        mapChar(0x0216, 'U'); // LATIN CAPITAL LETTER U WITH INVERTED
                                    // BREVE
        mapChar(0x0217, 'u'); // LATIN SMALL LETTER U WITH INVERTED BREVE
        mapChar(0x0250, 'a'); // LATIN SMALL LETTER TURNED A
        mapChar(0x0253, 'b'); // LATIN SMALL LETTER B WITH HOOK
        mapChar(0x0254, 'o'); // LATIN SMALL LETTER OPEN O
        mapChar(0x0255, 'c'); // LATIN SMALL LETTER C WITH CURL
        mapChar(0x0256, 'd'); // LATIN SMALL LETTER D WITH TAIL
        mapChar(0x0257, 'd'); // LATIN SMALL LETTER D WITH HOOK
        mapChar(0x0258, 'e'); // LATIN SMALL LETTER REVERSED E
        mapChar(0x025B, 'e'); // LATIN SMALL LETTER OPEN E
        mapChar(0x025C, 'e'); // LATIN SMALL LETTER REVERSED OPEN E
        mapChar(0x025D, 'e'); // LATIN SMALL LETTER REVERSED OPEN E WITH HOOK
        mapChar(0x025E, 'e'); // LATIN SMALL LETTER CLOSED REVERSED OPEN E
        mapChar(0x025F, 'j'); // LATIN SMALL LETTER DOTLESS J WITH STROKE
        mapChar(0x0260, 'g'); // LATIN SMALL LETTER G WITH HOOK
        mapChar(0x0261, 'g'); // LATIN SMALL LETTER SCRIPT G
        mapChar(0x0262, 'G'); // LATIN LETTER SMALL CAPITAL G
        mapChar(0x0265, 'h'); // LATIN SMALL LETTER TURNED H
        mapChar(0x0266, 'h'); // LATIN SMALL LETTER H WITH HOOK
        mapChar(0x0268, 'i'); // LATIN SMALL LETTER I WITH STROKE
        mapChar(0x026A, 'I'); // LATIN LETTER SMALL CAPITAL I
        mapChar(0x026B, 'l'); // LATIN SMALL LETTER L WITH MIDDLE TILDE
        mapChar(0x026C, 'l'); // LATIN SMALL LETTER L WITH BELT
        mapChar(0x026D, 'l'); // LATIN SMALL LETTER L WITH RETROFLEX HOOK
        mapChar(0x026F, 'm'); // LATIN SMALL LETTER TURNED M
        mapChar(0x0270, 'm'); // LATIN SMALL LETTER TURNED M WITH LONG LEG
        mapChar(0x0271, 'm'); // LATIN SMALL LETTER M WITH HOOK
        mapChar(0x0272, 'n'); // LATIN SMALL LETTER N WITH LEFT HOOK
        mapChar(0x0273, 'n'); // LATIN SMALL LETTER N WITH RETROFLEX HOOK
        mapChar(0x0274, 'N'); // LATIN LETTER SMALL CAPITAL N
        mapChar(0x0275, 'o'); // LATIN SMALL LETTER BARRED O
        mapChar(0x0276, '\u0152'); // LATIN LETTER SMALL CAPITAL OE
        mapChar(0x0279, 'r'); // LATIN SMALL LETTER TURNED R
        mapChar(0x027A, 'r'); // LATIN SMALL LETTER TURNED R WITH LONG LEG
        mapChar(0x027B, 'r'); // LATIN SMALL LETTER TURNED R WITH HOOK
        mapChar(0x027C, 'r'); // LATIN SMALL LETTER R WITH LONG LEG
        mapChar(0x027D, 'r'); // LATIN SMALL LETTER R WITH TAIL
        mapChar(0x027E, 'r'); // LATIN SMALL LETTER R WITH FISHHOOK
        mapChar(0x027F, 'r'); // LATIN SMALL LETTER REVERSED R WITH FISHHOOK
        mapChar(0x0280, 'R'); // LATIN LETTER SMALL CAPITAL R
        mapChar(0x0281, 'R'); // LATIN LETTER SMALL CAPITAL INVERTED R
        mapChar(0x0282, 's'); // LATIN SMALL LETTER S WITH HOOK
        mapChar(0x0284, 'j'); // LATIN SMALL LETTER DOTLESS J WITH STROKE AND
                                // HOOK
        mapChar(0x0287, 't'); // LATIN SMALL LETTER TURNED T
        mapChar(0x0288, 't'); // LATIN SMALL LETTER T WITH RETROFLEX HOOK
        mapChar(0x0289, 'u'); // LATIN SMALL LETTER U BAR
        mapChar(0x028B, 'v'); // LATIN SMALL LETTER V WITH HOOK
        mapChar(0x028C, 'v'); // LATIN SMALL LETTER TURNED V
        mapChar(0x028D, 'w'); // LATIN SMALL LETTER TURNED W
        mapChar(0x028E, 'z'); // LATIN SMALL LETTER TURNED Y
        mapChar(0x028F, 'Y'); // LATIN LETTER SMALL CAPITAL Y
        mapChar(0x0290, 'z'); // LATIN SMALL LETTER Z WITH RETROFLEX HOOK
        mapChar(0x0291, 'z'); // LATIN SMALL LETTER Z WITH CURL
        mapChar(0x0292, (char) 0x01b7); // LATIN SMALL LETTER EZH
        mapChar(0x0293, (char) 0x01b7); // LATIN SMALL LETTER EZH WITH CURL
        mapChar(0x0297, 'c'); // LATIN LETTER STRETCHED C
        mapChar(0x0299, 'B'); // LATIN LETTER SMALL CAPITAL B
        mapChar(0x029A, 'e'); // LATIN SMALL LETTER CLOSED OPEN E
        mapChar(0x029B, 'G'); // LATIN LETTER SMALL CAPITAL G WITH HOOK
        mapChar(0x029C, 'H'); // LATIN LETTER SMALL CAPITAL H
    }

    // -----------------------------------------------------------------------

    public static final char collapse(char c) {
        if (c >= diacritics.length) {
            return c;
        }
        char tc = diacritics[c];
        return (tc == 0)? c : tc;
    }

    public static final String collapse(String s) {
        char[] chars = s.toCharArray();

        int count = chars.length;
        for (int i = 0; i < count; ++i) {
            chars[i] = collapse(chars[i]);
        }

        return new String(chars, 0, count);
    }
}

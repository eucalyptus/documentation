/*
 * Copyright (c) 2009 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.preprocess;

import com.xmlmind.util.Localizer;

/*package*/ final class Msg {
    private static Localizer localizer = new Localizer(Msg.class);

    public static String msg(String id) {
        return localizer.msg(id);
    }

    public static String msg(String id, Object... args) {
        return localizer.msg(id, args);
    }
}

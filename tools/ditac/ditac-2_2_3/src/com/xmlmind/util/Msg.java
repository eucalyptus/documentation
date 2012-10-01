/*
 * Copyright (c) 2002-2008 Pixware. 
 *
 * Author: Hussein Shafie
 *
 * This file is part of several XMLmind projects.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.util;

/*package*/ final class Msg {
    private static Localizer localizer = new Localizer(Msg.class);

    public static String msg(String id) {
        return localizer.msg(id);
    }

    public static String msg(String id, Object... args) {
        return localizer.msg(id, args);
    }
}

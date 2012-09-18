/*
 * Copyright (c) 2002-2011 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of several XMLmind projects.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.util;

import java.util.ResourceBundle;
import java.text.MessageFormat;

/**
 * Helper class used to create localized, formatted, messages.
 */
public final class Localizer {
    private ResourceBundle resourceBundle;

    /**
     * Constructs a Localizer which uses <code>java.text.MessageFormat</code>s
     * found in <tt><i>package_name</i>.Messages<i>_locale</i>.properties</tt>
     * <code>java.util.ResourceBundle</code>s to create its localized,
     * formatted, messages.
     * <p>Example: <tt>com.xmlmind.foo.Messages_fr.properties</tt>, which is
     * used to create localized, formatted, messages for all classes in the
     * <tt>com.xmlmind.foo</tt> package, contains 2 message formats having
     * <tt>cannotOpen</tt> and <tt>cannotSave</tt> as their IDs.
     * <pre>cannotOpen=Ne peut ouvrir le fichier "{0}":\n{1}
     *
     *cannotSave=Ne peut enregistrer le fichier "{0}":\n{1}</pre>
     * 
     * @param cls Class used to specify <i>package_name</i>.
     */
    public Localizer(Class<?> cls) {
        String packageName = cls.getName();
        int pos = packageName.lastIndexOf('.');
        if (pos >= 0) {
            packageName = packageName.substring(0, pos);
        }

        resourceBundle = ResourceBundle.getBundle(packageName + ".Messages");
    }

    /**
     * Returns localized message having specified ID. Returns specified ID if
     * the message is not found.
     */
    public String msg(String id) {
        String message = null;
        try {
            message = resourceBundle.getString(id);
        } catch (Exception e) {
            return id;
        }
        return message;
    }

    /**
     * Returns localized message having specified ID and formatted using
     * specified arguments. Returns specified ID if the message is not found.
     */
    public String msg(String id, Object... args) {
        String message = null;
        try {
            message = resourceBundle.getString(id);
        } catch (Exception e) {
            return id;
        }
        return MessageFormat.format(message, args);
    }
}

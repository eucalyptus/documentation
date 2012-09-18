/*
 * Copyright (c) 2002-2008 Pixware. 
 *
 * Author: Hussein Shafie
 *
 * This file is part of several XMLmind projects.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.util;

/**
 * A collection of utility functions (static methods) operating on Objects.
 */
public final class ObjectUtil {
    private ObjectUtil() {}

    /**
     * Tests if specified objects are equal using <code>equals()</code>.
     * Unlike with <code>equals()</code>, both objects may be
     * <code>null</code> and two <code>null</code> objects are always
     * considered to be equal.
     * <p>This function is missing in java.util.Arrays which, on the other
     * hand, has all the other functions: <code>Arrays.equals(boolean[],
     * boolean[])</code>, <code>Arrays.equals(byte[], byte[])</code>, ...,
     * <code>Arrays.equals(Object[], Object[])</code>.
     */
    public static final boolean equals(Object o1, Object o2) {
        return ((o1 == null && o2 == null) ||
                (o1 != null && o1.equals(o2)));
    }
}

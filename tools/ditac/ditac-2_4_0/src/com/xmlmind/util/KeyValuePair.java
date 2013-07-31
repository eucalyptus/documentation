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
 * A key/value pair returned by some of the iterators of {@link
 * LinearHashtable}.
 */
public final class KeyValuePair<K,V> {
    /**
     * The hashed key. May not be <code>null</code>.
     */
    public K key;

    /**
     * The value associated to the above key. May not be <code>null</code>.
     */
    public V value;

    public KeyValuePair() {}

    public KeyValuePair(K key, V value) {
        this.key = key;
        this.value = value;
    }
}

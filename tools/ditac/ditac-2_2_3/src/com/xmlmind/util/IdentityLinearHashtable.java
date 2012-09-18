/*
 * Copyright (c) 2002-2011 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of several XMLmind projects.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.util;

import java.io.IOException;
import java.io.ObjectOutputStream;
import java.io.ObjectInputStream;

/*TEST_IDENTITY_LINEAR_HASHTABLE
import java.util.Iterator;
TEST_IDENTITY_LINEAR_HASHTABLE*/

/**
 * Identical to {@link LinearHashtable} except that keys are hashed using
 * {@link System#identityHashCode} and compared using <code>==</code>.
 * <p>This class is <em>not</em> thread-safe.
 */
public final class IdentityLinearHashtable<K,V> extends LinearHashtable<K,V> {
    private static final long serialVersionUID = 2856443646185780600L;

    public IdentityLinearHashtable() {
        super();
    }

    public IdentityLinearHashtable(int capacity) {
        super(capacity);
    }
    
    @Override
    public V get(K key) {
        int i = tableIndex(table, key);
        return (i < 0)? null : (V) table[i+1];
    }

    private static int tableIndex(Object[] table, Object key) {
        assert(key != null);
        int hash = System.identityHashCode(key);
        if (hash < 0) {
            hash = -hash;
        }

        final int tableLength = table.length;
        int i0 = 2*(hash % (tableLength/2));
        int i = i0;

        for (;;) {
            Object k = table[i];
            if (k == null || k == key) {
                return i;
            }

            i += 2;
            if (i == tableLength) {
                i = 0;
            }

            if (i == i0) {
                // Table full.
                return -1;
            }
        }
    }

    @Override
    public V put(K key, V value) {
        int i = tableIndex(table, key);
        if (i < 0) {
            // Grow table.
            final int tableLength = table.length;
            Object[] newTable = new Object[2*tableLength];
            
            for (int j = 0; j < tableLength; j += 2) {
                K curKey = (K) table[j];

                if (curKey != null) {
                    int k = tableIndex(newTable, curKey);
                    newTable[k] = curKey;
                    newTable[k+1] = table[j+1];
                }
            }

            table = newTable;
            i = tableIndex(table, key);
        }

        V oldValue = (V) table[i+1];
        table[i] = key;
        table[i+1] = value;

        return oldValue;
    }

    @Override
    public V remove(K key) {
        int i = tableIndex(table, key);
        if (i < 0 || table[i] == null) {
            return null;
        }

        V oldValue = (V) table[i+1];
        table[i] = null;
        table[i+1] = null;

        // Rehash from i.
        final int tableLength = table.length;
        for (;;) {
            i += 2;
            if (i == tableLength) {
                i = 0;
            }

            // Any object which has collided with the deleted object is
            // just after the deleted object. Thus, finding null means
            // there is no more objects which *could* have collided with
            // the deleted object.
            // This loop is guaranteed to stop because null has replaced
            // the deleted object.

            if (table[i] == null) {
                break;
            }

            K curKey = (K) table[i];
            int j = tableIndex(table, curKey); 

            // If j == i, the slot will not be empty!
            if (table[j] == null) {
                // Move to j because this slot is free.
                table[j] = curKey;
                table[j+1] = table[i+1];

                table[i] = null;
                table[i+1] = null;
            }
        }

        return oldValue;
    }

    // -----------------------------------------------------------------------

    private void writeObject(ObjectOutputStream stream)
        throws IOException {
        final int tableLength = table.length;
        stream.writeInt(tableLength);

        stream.writeInt(2*size());
        for (int i = 0; i < tableLength; i += 2) {
            if (table[i] != null) {
                stream.writeObject(table[i]);
                stream.writeObject(table[i+1]);
            }
        }
    }

    private void readObject(ObjectInputStream stream)
        throws IOException, ClassNotFoundException {
        table = new Object[stream.readInt()];

        int count = stream.readInt();
        for (int i = 0; i < count; i += 2) {
            Object key = stream.readObject();
            Object value = stream.readObject();

            int index = tableIndex(table, key);
            table[index] = key;
            table[index+1] = value;
        }
    }

    // -----------------------------------------------------------------------

    /*TEST_IDENTITY_LINEAR_HASHTABLE
    public static void main(String[] args) {
        try {
            test1();
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(2);
        }
    }

    private static void test1() throws RuntimeException {
        IdentityLinearHashtable<String, Integer> htab =
            new IdentityLinearHashtable<String, Integer>();

        htab.clear();
        assert(htab.size() == 0);

        String[] words = {
            "zero", "one", "two", "three", "four", 
            "five", "six", "seven", "eight", "nine", 
            "ten"
        };

        for (int i = words.length-1; i >= 0; --i) {
            String key = words[i].intern();
            Integer value = new Integer(i);

            htab.put(key, value);
            assert(htab.get(key).equals(value));
        }
        assert(htab.size() == words.length);
        // Literal strings are interned by the compiler
        assert(htab.containsKey("ten"));
        assert(htab.contains(new Integer(0)));

        IdentityLinearHashtable<String, Integer> copy =
            (IdentityLinearHashtable<String, Integer>) htab.clone();
        System.out.println(copy);

        String[] wordList = new String[copy.size()];
        copy.copyKeysInto(wordList);

        Integer[] intList = new Integer[copy.size()];
        copy.copyElementsInto(intList);

        Iterator<String> iter = copy.keys();
        while (iter.hasNext()) {
            String key = iter.next();
            System.out.println(key);
        }

        Iterator<Integer> iter2 = copy.elements();
        while (iter2.hasNext()) {
            Integer value = iter2.next();
            System.out.println(value);
        }

        Iterator<KeyValuePair<String,Integer>> iter3 = copy.entries();
        while (iter3.hasNext()) {
            KeyValuePair<String,Integer> entry = iter3.next();
            System.out.println(entry.key + "=" + entry.value);
        }

        for (int i = 0; i < words.length; ++i) {
            if ((i % 3) != 2) {
                htab.remove(words[i]);
                assert(!htab.containsKey(words[i]));
            } else {
                htab.put(words[i], words[i].length());
                assert(htab.get(words[i]).equals(words[i].length()));
            }
        }
        assert(htab.size() == words.length/3);

        htab.clear();
        assert(htab.size() == 0);
    }
    TEST_IDENTITY_LINEAR_HASHTABLE*/
}


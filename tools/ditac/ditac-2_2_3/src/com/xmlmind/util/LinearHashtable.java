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
import java.io.Serializable;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.Iterator;

/**
 * A hashtable which is more compact and less efficient 
 * than {@link java.util.Hashtable}.
 * <p>This implementation is the one used by Smalltalk. It is useful if you
 * need to have hundreds or even thousands of very small hashtables (with up
 * to 3 entries for most instances).
 * <p>LinearHashtable has exactly the same API as
 * <code>java.util.Hashtable</code>, therefore there is no need to document
 * again this API here.
 * <p>Note that the iterators returned by the methods of this class do not
 * support the <code>remove</code> operation and do not detect concurrent
 * modification.
 * <p>This class is <em>not</em> thread-safe.
 */
public class LinearHashtable<K,V> implements Cloneable, Serializable {
    protected transient Object[] table;

    private static final long serialVersionUID = -8580213005877781060L;

    /**
     * Constructs a hashtable with an initial capacity of 3 key/value pairs.
     */
    public LinearHashtable() {
        this(3);
    }

    /**
     * Constructs a hashtable with the specified initial capacity.
     * 
     * @param capacity the initial capacity expressed in number of key/value
     * pairs
     */
    public LinearHashtable(int capacity) {
        table = new Object[2*capacity];
    }

    /**
     * Returns the number of key/value pairs currently stored in this
     * hashtable. Note that calling this method is more expensive than calling
     * {@link java.util.Hashtable#size} because the size is recomputed each
     * time this method is called.
     * 
     * @return the number of key/value pairs currently stored in this
     * hashtable
     */
    public int size() {
        int size = 0;
        final int tableLength = table.length;
        for (int i = 0; i < tableLength; i += 2) {
            if (table[i] != null) {
                ++size;
            }
        }
        return size;
    }

    public boolean isEmpty() {
        return (size() == 0);
    }

    public boolean contains(V value) {
        final int tableLength = table.length;
        for (int i = 1; i < tableLength; i += 2) {
            Object v = table[i];
            if ((value == null)? (v == null) : value.equals(v)) {
                return true;
            }
        }
        return false;
    }

    public boolean containsKey(K key) {
        return (get(key) != null);
    }

    public V get(K key) {
        int i = indexOf(table, key);
        return (i < 0)? null : (V) table[i+1];
    }

    private static int indexOf(Object[] table, Object key) {
        assert(key != null);
        int hash = key.hashCode();
        if (hash < 0) {
            hash = -hash;
        }

        final int tableLength = table.length;
        int i0 = 2*(hash % (tableLength/2));
        int i = i0;

        for (;;) {
            Object k = table[i];
            if (k == null || k.equals(key)) {
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

    public V put(K key, V value) {
        int i = indexOf(table, key);
        if (i < 0) {
            // Grow table.
            final int tableLength = table.length;
            Object[] newTable = new Object[2*tableLength];
            
            for (int j = 0; j < tableLength; j += 2) {
                K curKey = (K) table[j];

                if (curKey != null) {
                    int k = indexOf(newTable, curKey);
                    newTable[k] = curKey;
                    newTable[k+1] = table[j+1];
                }
            }

            table = newTable;
            i = indexOf(table, key);
        }

        V oldValue = (V) table[i+1];
        table[i] = key;
        table[i+1] = value;

        return oldValue;
    }

    public V remove(K key) {
        int i = indexOf(table, key);
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
            int j = indexOf(table, curKey); 

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

    public void clear() {
        final int tableLength = table.length;
        for (int i = 0; i < tableLength; ++i) {
            table[i] = null;
        }
    }

    public Object clone() {
        LinearHashtable<K,V> copy;

        try {
            copy = (LinearHashtable<K,V>) super.clone();
        } catch (CloneNotSupportedException cannotHappen) {
            cannotHappen.printStackTrace();
            return null;
        }

        final int tableLength = table.length;
        copy.table = new Object[tableLength];
        System.arraycopy(table, 0, copy.table, 0, tableLength);
        return copy;
    }

    /**
     * Returns a string representation of this hashtable which may be used
     * during debugging.
     */
    public String toString() {
        StringBuilder buffer = new StringBuilder();

        buffer.append(getClass().getName());
        buffer.append('[');
        boolean first = true;
        final int tableLength = table.length;
        for (int i = 0; i < tableLength; i += 2) {
            if (table[i] != null) {
                if (first) {
                    first = false;
                } else {
                    buffer.append(',');
                }
                buffer.append(table[i]);
                buffer.append('=');
                buffer.append(table[i+1]);
            }
        }
        buffer.append(']');

        return buffer.toString();
    }

    // -----------------------------------------------------------------------

    /**
     * Copies the keys contained in this hashtable to the specified array.
     * 
     * @param array the array where the keys are to be copied
     */
    public void copyKeysInto(K[] array) {
        int count = 0;
        final int tableLength = table.length;
        for (int i = 0; i < tableLength; i += 2) {
            if (table[i] != null) {
                array[count++] = (K) table[i];
            }
        }
    }

    /**
     * Copies the elements contained in this hashtable to the specified array.
     * 
     * @param array the array where the elements are to be copied
     */
    public void copyElementsInto(V[] array) {
        int count = 0;
        final int tableLength = table.length;
        for (int i = 0; i < tableLength; i += 2) {
            if (table[i] != null) {
                array[count++] = (V) table[i+1];
            }
        }
    }

    public Iterator<K> keys() {
        return new KeyIterator<K>();
    }

    protected final class KeyIterator<K> implements Iterator<K> {
        private int index;

        public KeyIterator() {
            index = 0;
            moveToNext();
        }

        private void moveToNext() {
            final int tableLength = table.length;
            while (index < tableLength) {
                if (table[index] != null) {
                    break;
                }

                index += 2;
            }
        }

        public boolean hasNext() {
            return (index < table.length);
        }

        public K next() {
            K key;

            if (index < table.length) {
                key = (K) table[index];
                index += 2;
                moveToNext();
            } else {
                key = null;
            }

            return key;
        }

        public void remove() {
            throw new UnsupportedOperationException();
        }
    }

    public Iterator<V> elements() {
        return new ValueIterator<V>();
    }

    protected final class ValueIterator<V> implements Iterator<V> {
        private int index;

        public ValueIterator() {
            index = 0;
            moveToNext();
        }

        private void moveToNext() {
            final int tableLength = table.length;
            while (index < tableLength) {
                if (table[index] != null) {
                    break;
                }

                index += 2;
            }
        }

        public boolean hasNext() {
            return (index < table.length);
        }

        public V next() {
            V value;

            if (index < table.length) {
                value = (V) table[index+1];
                index += 2;
                moveToNext();
            } else {
                value = null;
            }

            return value;
        }

        public void remove() {
            throw new UnsupportedOperationException();
        }
    }

    /**
     * Returns an Iterator over all the entries contained in this hashtable.
     * <p>For efficiency reasons, the entry returned by this Iterator is
     * always the same object. <em><strong>Copy it if you need to store this
     * entry</strong></em>.
     */
    public Iterator<KeyValuePair<K,V>> entries() {
        return new EntryIterator<K,V>();
    }

    protected final class EntryIterator<K,V> 
                    implements Iterator<KeyValuePair<K,V>> {
        private int index;
        private KeyValuePair<K,V> entry;

        public EntryIterator() {
            index = 0;
            entry = new KeyValuePair<K,V>();
            moveToNext();
        }

        private void moveToNext() {
            final int tableLength = table.length;
            while (index < tableLength) {
                if (table[index] != null) {
                    break;
                }

                index += 2;
            }
        }

        public boolean hasNext() {
            return (index < table.length);
        }

        public KeyValuePair<K,V> next() {
            if (index < table.length) {
                entry.key = (K) table[index];
                entry.value = (V) table[index+1];
                index += 2;
                moveToNext();

                return entry;
            } else {
                entry.key = null;
                entry.value = null;

                return null;
            }
        }

        public void remove() {
            throw new UnsupportedOperationException();
        }
    }

    /**
     * Returns the <code>Object</code> table used to implement this kind of
     * hashtables.
     * <p>Keys are found at even indices.
     * <p>If the key object is not <code>null</code>, it is immediately
     * followed by its associated value (which are therefore found at even
     * indices).
     * <p>For example, the following code can be used to dump a
     * <code>LinearHashtable</code>:
     * <pre>Object[] table = htab.getKeyValueTable();
     * for (int i = 0; i &lt; table.length; i += 2) {
     *     if (table[i] != null) {
     *         System.err.println("key=" + table[i]);
     *         System.err.println("value=" + table[i+1]);
     *     }
     *  }</pre>
     * <p>Only use this method when you have a 
     * <em><strong>desperate</strong></em> need for speed. 
     * Otherwise, please use {@link #entries}.
     * <p>And, of course, <em><strong>do not modify the contents of the table
     * returned by this method</strong></em>.
     */
    public Object[] getKeyValueTable() {
        return table;
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

        // It is absolutely mandatory to rehash the entries because
        // the hashCode() of an object is often its System.identityHashCode().

        int count = stream.readInt();
        for (int i = 0; i < count; i += 2) {
            Object key = stream.readObject();
            Object value = stream.readObject();

            int index = indexOf(table, key);
            table[index] = key;
            table[index+1] = value;
        }
    }

    // -----------------------------------------------------------------------

    /*TEST_LINEAR_HASHTABLE
    public static void main(String[] args) {
        try {
            test1();
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(2);
        }
    }

    private static void test1() throws RuntimeException {
        LinearHashtable<String, Integer> htab =
            new LinearHashtable<String, Integer>();

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
        assert(htab.containsKey("ten"));
        assert(htab.contains(new Integer(0)));

        LinearHashtable<String, Integer> copy =
            (LinearHashtable<String, Integer>) htab.clone();
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
    TEST_LINEAR_HASHTABLE*/
}

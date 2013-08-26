/*
 * Copyright (c) 2010-2011 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.preprocess;

import java.util.HashMap;
import java.util.Arrays;
import org.w3c.dom.Element;
import com.xmlmind.ditac.util.DOMUtil;
import com.xmlmind.ditac.util.DITAUtil;

/**
 * Not part of the public, documented, API.
 */
public final class Keys {
    public static final class Entry implements Comparable<Entry> {
        /**
         * The key.
         */
        public final String key;

        /**
         * A <em>stand-alone</em> topicref representing this entry.
         * May be completely empty (no content, no attributes).
         * <p>The href attribute, if any, contains an absolute URI.
         * If it points to a topic, this URI ends with 
         * <tt>#<i>topi_id</i></tt>. (That is, the href attribute is 
         * ready-to-use.)
         * <p>This element has a ditac:absoluteHref="true" if the href 
         * attribute was specified by the DITA author as an absolute URI.
         */
        public final Element element;

        // -------------------------------------------------------------------

        public Entry(String key, Element element) {
            this.key = key;
            this.element = element;
        }

        public String getAttribute(String ns, String localName) {
            return DITAUtil.getNonEmptyAttribute(element, ns, localName);
        }

        public Element getMeta() {
            return DOMUtil.getFirstChildElement(element);
        }

        @Override
        public int hashCode() {
            return key.hashCode();
        }

        @Override
        public boolean equals(Object other) {
            if (other == null || !(other instanceof Entry)) {
                return false;
            }
            return key.equals(((Entry) other).key);
        }

        @Override
        public String toString() {
            Element copy = (Element) element.cloneNode(/*deep*/ true);
            copy.setAttributeNS(null, "keys", key);

            return DOMUtil.toString(copy);
        }

        public int compareTo(Entry other) {
            return key.compareTo(other.key);
        }
    }

    // -----------------------------------------------------------------------

    private HashMap<String, Entry> entries;
    private Entry[] all;

    public Keys() {
        entries = new HashMap<String, Entry>();
    }

    public void setEntry(Entry entry) {
        entries.put(entry.key, entry);
        all = null;
    }

    public Entry getEntry(String key) {
        return entries.get(key);
    }

    public Entry[] getAllEntries() {
        if (all == null) {
            all = new Entry[entries.size()];
            entries.values().toArray(all);
        }
        return all;
    }

    public boolean contains(String key) {
        return entries.containsKey(key);
    }

    public String getHref(String key) {
        Entry e = getEntry(key);
        return (e == null)? null : e.getAttribute(null, "href");
    }
                
    @Override
    public String toString() {
        StringBuilder buffer = new StringBuilder();

        Keys.Entry[] all = getAllEntries();
        Arrays.sort(all);

        for (Keys.Entry e : all) {
            buffer.append(e);
        }

        return buffer.toString();
    }
}

/*
 * Copyright (c) 2002-2012 Pixware SARL. All right reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of several XMLmind projects.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.util;

import java.io.IOException;
import java.io.File;
import java.io.FileInputStream;
import java.io.BufferedInputStream;
import java.io.FileOutputStream;
import java.io.BufferedOutputStream;
import java.net.URL;
import java.net.MalformedURLException;
import java.util.Iterator;
import java.util.Properties;
import java.util.StringTokenizer;
import java.awt.Rectangle;
import java.awt.Color;
import java.awt.Font;
import java.awt.print.Paper;

/**
 * Class used by an application to store the preferences of its user.
 * <p>This class is thread-safe.
 */
public class Preferences {
    /**
     * Persistent key/value map used to implement Preferences.
     * <p>Failure to load or save such map from/to its backing store is not a
     * fatal error. Implementations are not even required to report an error
     * message.
     */
    public interface Map {
        /**
         * Returns value corresponding to specified key. Returns
         * <code>null</code> if not found.
         */
        String getPreference(String key);

        /**
         * Adds or replaces value for specified key.
         */
        void putPreference(String key, String value);

        /**
         * Removes value corresponding to specified key, if any.
         */
        void removePreference(String key);

        /**
         * Makes this map empty.
         */
        void removeAllPreferences();

        /**
         * Returns the list of key/value pairs contained in this map. This
         * list may be empty but cannot be <code>null</code>.
         */
        String[] getAllPreferences();

        /**
         * Saves this map to its backing store.
         * 
         * @return <code>true</code> if map has been saved; <code>false</code>
         * otherwise (I/O error or the map is not persistent).
         */
        boolean save();
    }

    // -----------------------------------------------------------------------

    /**
     * Implementation of Preferences.Map based on java.util.Properties.
     */
    public static final class MapImpl implements Map {
        private File file;
        private String header;
        private Properties properties;

        /**
         * Constructs a Preferences.Map initialized using specified 
         * properties.
         * <p>Equivalent to <code>MapImpl(properties, null, null)</code>.
         * <p>This Preferences.Map cannot be saved to a file.
         */
        public MapImpl(Properties properties) {
            this(properties, null, null);
        }

        /**
         * Constructs a Preferences.Map initialized using specified 
         * property file.
         * <p>Equivalent to <code>MapImpl(null, file, header)</code>.
         */
        public MapImpl(File file, String header) {
            this(null, file, header);
        }
        
        /**
         * Constructs a Preferences.Map, possibly initialized 
         * using specified parameters.
         * <ul>
         * <li>If <tt>properties</tt> is specified, this java.util.Properties
         * is used by this Preferences.Map and <tt>file</tt>, if specified,
         * is not loaded.
         * <li>If <tt>properties</tt> is not specified and if <tt>file</tt>
         * is specified, the content of this file is loaded in a newly created
         * java.util.Properties.
         * <li>If <tt>properties</tt> and <tt>file</tt> are both not 
         * specified, a newly created, empty, java.util.Properties is used
         * by this Preferences.Map.
         * </ul>
         *
         * @param properties java.util.Properties used by this Preferences.Map.
         * May be <code>null</code>, in which case an new java.util.Properties
         * is created.
         * @param file Java<sup>TM</sup> properties file used as 
         * a backing store for this Preferences.Map.
         * May be <code>null</code>, in which case this Preferences.Map 
         * cannot be saved to a file.
         * @param header first line (generally giving info about the
         * application) which is to be saved in the properties file.
         * May be <code>null</code>, in which case no header line 
         * will be added to the saved properties file.
         */
        public MapImpl(Properties properties, File file, String header) {
            if (properties == null) {
                properties = new Properties();

                if (file != null) {
                    try {
                        BufferedInputStream in = 
                            new BufferedInputStream(new FileInputStream(file),
                                                    65536);
                        try {
                            properties.load(in);
                        } finally {
                            in.close();
                        }
                    } catch (IOException ignored) {
                        //ignored.printStackTrace();
                    }
                }
            }

            this.file = file;
            this.header = header;
            this.properties = properties;
        }

        /**
         * Returns the properties file used as a backing store for this map.
         */
        public File getFile() {
            return file;
        }
        
        /**
         * Returns the first line (generally giving info about the
         * application) which is to be saved in the properties file.
         */
        public String getHeader() {
            return header;
        }

        public String getPreference(String key) {
            return (String) properties.get(key);
        }

        public void putPreference(String key, String value) {
            properties.put(key, value);
        }

        public void removePreference(String key) {
            properties.remove(key);
        }

        public void removeAllPreferences() {
            properties.clear();
        }

        public String[] getAllPreferences() {
            String[] list = new String[properties.size() * 2];

            int i = 0;
            Iterator<java.util.Map.Entry<Object, Object>> iter = 
                properties.entrySet().iterator();
            while (iter.hasNext()) {
                java.util.Map.Entry<Object, Object> e = iter.next();

                list[i] = (String) e.getKey();
                list[i+1] = (String) e.getValue();
                i += 2;
            }

            return list;
        }

        public boolean save() {
            if (file == null) {
                return false;
            }

            try {
                File tmpFile = File.createTempFile("prefs", ".tmp", 
                                                   file.getParentFile());

                BufferedOutputStream out = 
                    new BufferedOutputStream(new FileOutputStream(tmpFile),
                                             65536);
                try {
                    properties.store(out, ((header == null)? "" : header));
                    out.flush();
                } finally {
                    out.close();
                }

                if (file.exists()) {
                    file.delete();
                }
                // renameTo is assumed to be atomic.
                tmpFile.renameTo(file);
            } catch (IOException ignored) {
                //ignored.printStackTrace();
                return false;
            }

            return true;
        }
    }

    // -----------------------------------------------------------------------

    /**
     * The persistent key/value map used to implement this Preferences
     * object.
     */
    public final Map map;

    /**
     * Constructs an empty <code>Preferences</code> object which cannot be
     * saved to a properties file.
     */
    public Preferences() {
        this(new MapImpl(null, null, null));
    }

    /**
     * Constructs a <code>Preferences</code> object which is initialized with
     * the content of a properties file and which can be saved back to this
     * properties file.
     * 
     * @param file Java<sup>TM</sup> file properties file used a backing store
     * for the preferences.
     * May be <code>null</code>.
     * @param header first (comment) line to be saved in the properties file.
     * May be <code>null</code>.
     */
    public Preferences(File file, String header) {
        this(new MapImpl(null, file, header));
    }

    /**
     * Constructs a Preferences object using specified persistent key/value
     * map to store user preferences.
     */
    public Preferences(Map map) {
        this.map = map;
    }

    /**
     * Adds or replaces preference.
     * 
     * @param key the name of the preference
     * @param value the value of the preference
     */
    public synchronized void putString(String key, String value) {
        map.putPreference(key, value);
    }

    /**
     * Returns specified preference.
     * 
     * @param key the name of the preference
     * @param fallback value returned if specified preference is not found
     * @return specified preference if found; returns <code>fallback</code>
     * otherwise
     */
    public synchronized String getString(String key, String fallback) {
        String value = map.getPreference(key);
        if (value == null) {
            return fallback;
        }

        return value;
    }

    /**
     * Adds or replaces preference.
     * 
     * @param key the name of the preference
     * @param value the value of the preference
     */
    public synchronized void putBoolean(String key, boolean value) {
        map.putPreference(key, value? "true" : "false");
    }

    /**
     * Returns specified preference.
     * 
     * @param key the name of the preference
     * @param fallback value returned if specified preference is not found or
     * cannot be parsed as a <code>boolean</code>
     * @return specified preference if found and valid; returns
     * <code>fallback</code> otherwise
     */
    public synchronized boolean getBoolean(String key, boolean fallback) {
        String value = map.getPreference(key);
        if (value == null) {
            return fallback;
        }

        if ("true".equals(value)) {
            return true;
        } else if ("false".equals(value)) {
            return false;
        } else {
            return fallback;
        }
    }

    /**
     * Adds or replaces preference.
     * 
     * @param key the name of the preference
     * @param value the value of the preference
     */
    public synchronized void putInt(String key, int value) {
        map.putPreference(key, Integer.toString(value));
    }

    /**
     * Returns specified preference.
     * 
     * @param key the name of the preference
     * @param min minimum allowed value for the preference
     * @param max maximum allowed value for the preference
     * @param fallback value returned if specified preference is not found or
     * cannot be parsed as an <code>int</code> or is less than
     * <code>min</code> or is greater than <code>max</code>
     * @return specified preference if found and valid; returns
     * <code>fallback</code> otherwise
     */
    public synchronized int getInt(String key, int min, int max,
                                   int fallback) {
        int i = getInt(key, fallback);
        if (i < min || i > max) {
            return fallback;
        } else {
            return i;
        }
    }

    /**
     * Returns specified preference.
     * 
     * @param key the name of the preference
     * @param fallback value returned if specified preference is not found or
     * cannot be parsed as an <code>int</code>
     * @return specified preference if found and valid; returns
     * <code>fallback</code> otherwise
     */
    public synchronized int getInt(String key, int fallback) {
        String value = map.getPreference(key);
        if (value == null)
            return fallback;

        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException ignored) {
            return fallback;
        }
    }

    /**
     * Adds or replaces preference.
     * 
     * @param key the name of the preference
     * @param value the value of the preference
     */
    public synchronized void putLong(String key, long value) {
        map.putPreference(key, Long.toString(value));
    }

    /**
     * Returns specified preference.
     * 
     * @param key the name of the preference
     * @param min minimum allowed value for the preference
     * @param max maximum allowed value for the preference
     * @param fallback value returned if specified preference is not found or
     * cannot be parsed as an <code>long</code> or is less than
     * <code>min</code> or is greater than <code>max</code>
     * @return specified preference if found and valid; returns
     * <code>fallback</code> otherwise
     */
    public synchronized long getLong(String key, long min, long max,
                                     long fallback) {
        long i = getLong(key, fallback);
        if (i < min || i > max) {
            return fallback;
        } else {
            return i;
        }
    }

    /**
     * Returns specified preference.
     * 
     * @param key the name of the preference
     * @param fallback value returned if specified preference is not found or
     * cannot be parsed as an <code>long</code>
     * @return specified preference if found and valid; returns
     * <code>fallback</code> otherwise
     */
    public synchronized long getLong(String key, long fallback) {
        String value = map.getPreference(key);
        if (value == null) {
            return fallback;
        }

        try {
            return Long.parseLong(value);
        } catch (NumberFormatException ignored) {
            return fallback;
        }
    }

    /**
     * Adds or replaces preference.
     * 
     * @param key the name of the preference
     * @param value the value of the preference
     */
    public synchronized void putDouble(String key, double value) {
        map.putPreference(key, Double.toString(value));
    }

    /**
     * Returns specified preference.
     * 
     * @param key the name of the preference
     * @param min minimum allowed value for the preference
     * @param max maximum allowed value for the preference
     * @param fallback value returned if specified preference is not found or
     * cannot be parsed as a <code>double</code> or is less than
     * <code>min</code> or is greater than <code>max</code>
     * @return specified preference if found and valid; returns
     * <code>fallback</code> otherwise
     */
    public synchronized double getDouble(String key, double min, double max, 
                                         double fallback) {
        double i = getDouble(key, fallback);
        if (i < min || i > max)
            return fallback;
        else
            return i;
    }

    /**
     * Returns specified preference.
     * 
     * @param key the name of the preference
     * @param fallback value returned if specified preference is not found or
     * cannot be parsed as a <code>double</code>
     * @return specified preference if found and valid; returns
     * <code>fallback</code> otherwise
     */
    public synchronized double getDouble(String key, double fallback) {
        String value = map.getPreference(key);
        if (value == null) {
            return fallback;
        }

        try {
            return Double.parseDouble(value);
        } catch (NumberFormatException ignored) {
            return fallback;
        }
    }

    /**
     * Adds or replaces preference.
     * 
     * @param key the name of the preference
     * @param value the value of the preference
     */
    public synchronized void putStrings(String key, String[] value) {
        StringBuilder buffer = new StringBuilder();

        for (int i = 0; i < value.length; ++i) {
            String s = value[i];

            if (s.indexOf('&') >= 0) {
                s = StringUtil.replaceAll(s, "&", "&amp;");
            }

            if (s.indexOf('\n') >= 0) {
                s = StringUtil.replaceAll(s, "\n", "&#xA;");
            }

            if (i > 0) {
                buffer.append('\n');
            }
            buffer.append(s);
        }

        map.putPreference(key, buffer.toString());
    }

    /**
     * Returns specified preference.
     * 
     * @param key the name of the preference
     * @param fallback value returned if specified preference is not found
     * @return specified preference if found; returns <code>fallback</code>
     * otherwise
     */
    public synchronized String[] getStrings(String key, String[] fallback) {
        String value = map.getPreference(key);
        if (value == null) {
            return fallback;
        }

        if (value.length() == 0) {
            return new String[0];
        }

        String[] list = StringUtil.split(value, '\n');
        for (int i = 0; i < list.length; ++i) {
            String s = list[i];

            if (s.indexOf("&#xA;") >= 0) {
                s = StringUtil.replaceAll(s, "&#xA;", "\n");
            }

            if (s.indexOf("&amp;") >= 0) {
                s = StringUtil.replaceAll(s, "&amp;", "&");
            }

            list[i] = s;
        }

        return list;
    }

    /**
     * Adds or replaces preference.
     * 
     * @param key the name of the preference
     * @param value the value of the preference
     */
    public synchronized void putInts(String key, int[] value) {
        StringBuilder buffer = new StringBuilder();

        for (int i = 0; i < value.length; ++i) {
            if (i > 0) {
                buffer.append(' ');
            }
            buffer.append(value[i]);
        }

        map.putPreference(key, buffer.toString());
    }

    /**
     * Returns specified preference.
     * 
     * @param key the name of the preference
     * @param fallback value returned if specified preference is not found or
     * cannot be parsed as an array of <code>int</code>s
     * @return specified preference if found and valid; returns
     * <code>fallback</code> otherwise
     */
    public synchronized int[] getInts(String key, int[] fallback) {
        String value = map.getPreference(key);
        if (value == null) {
            return fallback;
        }

        StringTokenizer tokens = new StringTokenizer(value);
        int[] list = new int[tokens.countTokens()];

        for (int i = 0; i < list.length; ++i) {
            try {
                list[i] = Integer.parseInt(tokens.nextToken());
            } catch (NumberFormatException ignored) {
                return fallback;
            }
        }

        return list;
    }

    /**
     * Adds or replaces preference.
     * 
     * @param key the name of the preference
     * @param value the value of the preference
     */
    public synchronized void putDoubles(String key, double[] value) {
        StringBuilder buffer = new StringBuilder();

        for (int i = 0; i < value.length; ++i) {
            if (i > 0) {
                buffer.append(' ');
            }
            buffer.append(value[i]);
        }

        map.putPreference(key, buffer.toString());
    }

    /**
     * Returns specified preference.
     * 
     * @param key the name of the preference
     * @param fallback value returned if specified preference is not found or
     * cannot be parsed as an array of <code>double</code>s
     * @return specified preference if found and valid; returns
     * <code>fallback</code> otherwise
     */
    public synchronized double[] getDoubles(String key, double[] fallback) {
        String value = map.getPreference(key);
        if (value == null) {
            return fallback;
        }

        StringTokenizer tokens = new StringTokenizer(value);
        double[] list = new double[tokens.countTokens()];

        for (int i = 0; i < list.length; ++i) {
            try {
                list[i] = Double.parseDouble(tokens.nextToken());
            } catch (NumberFormatException ignored) {
                return fallback;
            }
        }

        return list;
    }

    /**
     * Adds or replaces preference.
     * 
     * @param key the name of the preference
     * @param value the value of the preference
     */
    public synchronized void putURL(String key, URL value) {
        putString(key, value.toExternalForm());
    }

    /**
     * Returns specified preference.
     * 
     * @param key the name of the preference
     * @param fallback value returned if specified preference is not found or
     * cannot be parsed as an <code>URL</code>
     * @return specified preference if found and valid; returns
     * <code>fallback</code> otherwise
     */
    public synchronized URL getURL(String key, URL fallback) {
        String value = getString(key, null);
        if (value == null) {
            return fallback;
        }

        URL url = null;
        try {
            url = new URL(value);
        } catch (MalformedURLException ignored) {}

        return (url == null)? fallback : url;
    }

    
    /**
     * Adds or replaces preference.
     * 
     * @param key the name of the preference
     * @param urls the value of the preference
     */
    public synchronized void putURLs(String key, URL[] urls) {
        String[] locations = new String[urls.length];
        for (int i = 0; i < urls.length; ++i) {
            locations[i] = urls[i].toExternalForm();
        }
        putStrings(key, locations);
    }

    /**
     * Returns specified preference.
     * 
     * @param key the name of the preference
     * @param fallback value returned if specified preference is not found or
     * cannot be parsed as an array of <code>URL</code>s
     * @return specified preference if found and valid; returns
     * <code>fallback</code> otherwise
     */
    public synchronized URL[] getURLs(String key, URL[] fallback) {
        String[] locations = getStrings(key, null);
        if (locations == null) {
            return fallback;
        }

        URL[] urls = new URL[locations.length];
        for (int i = 0; i < locations.length; ++i) {
            URL url = null;
            try {
                url = new URL(locations[i]);
            } catch (MalformedURLException ignored) {}
            if (url == null) {
                return fallback;
            }

            urls[i] = url;
        }

        return urls;
    }

    /**
     * Considers that the specified preference contains a map 
     * which maps an URL to another URL; adds or replaces in this map 
     * the value corresponding to specified key.
     * 
     * @param key the name of the preference
     * @param urlKey the key for which an entry is to be added or replaced 
     * in the map
     * @param urlValue the value of <tt>urlKey</tt>.
     * May be <code>null</code> in case the map entry corresponding 
     * to <tt>urlKey</tt> is removed.
     * @param maxEntries capacity of the map (in terms of entries, not in
     * terms of URLs).
     * If this capacity is exceeded, the oldest entries (that is,
     * the first added ones) are automatically removed.
     * @see #getURLEntry
     * @see #putURLs
     * @see #getURLs
     */
    public synchronized void putURLEntry(String key, URL urlKey, URL urlValue, 
                                         int maxEntries) {
        String[] urlMap = getStrings(key, null);
        int urlMapLength = (urlMap == null)? 0 : urlMap.length;

        if (maxEntries < 1) {
            maxEntries = 1;
        }
        int maxLength = 2*maxEntries;

        String[] entries = new String[Math.max(maxLength, urlMapLength) + 2];
        int length = 0;

        if (urlMap != null) {
            int count = 2*(urlMapLength/2);
            for (int i = 0; i < count; i += 2) {
                try {
                    URL url = new URL(urlMap[i]);
                    
                    if (!url.equals(urlKey)) {
                        entries[length] = urlMap[i];
                        entries[length+1] = urlMap[i+1];
                        length += 2;
                    }
                } catch (MalformedURLException ignored) {}
            }
        }

        if (urlValue != null) {
            entries[length] = urlKey.toExternalForm();
            entries[length+1] = urlValue.toExternalForm();
            length += 2;
        }

        if (length == 0) {
            remove(key);
        } else {
            if (length != entries.length) {
                String[] entries2 = new String[length];
                System.arraycopy(entries, 0, entries2, 0, length);
                entries = entries2;
            }

            if (length > maxLength) {
                String[] entries2 = new String[maxLength];
                System.arraycopy(entries, length - maxLength,
                                 entries2, 0, maxLength);
                entries = entries2;
            } 

            putStrings(key, entries);
        }
    }

    /**
     * Considers that the specified preference contains a map 
     * which maps an URL to another URL; returns the value 
     * corresponding to specified key.
     *
     * @param key the name of the preference
     * @param urlKey the searched key
     * @param fallback returned value when <tt>urlKey</tt> is not found 
     * in the map
     * @return value corresponding to <tt>urlKey</tt> if any; 
     * <tt>fallback</tt> otherwise
     * @see #putURLEntry
     * @see #putURLs
     * @see #getURLs
     */
    public synchronized URL getURLEntry(String key, URL urlKey, URL fallback) {
        String[] urlMap = getStrings(key, null);
        if (urlMap == null) {
            return fallback;
        }

        for (int i = 0; i < urlMap.length; i += 2) {
            try {
                URL url = new URL(urlMap[i]);

                if (url.equals(urlKey)) {
                    return new URL(urlMap[i+1]);
                }
            } catch (MalformedURLException ignored) {}
        }
        return fallback;
    }

    /**
     * Adds or replaces preference.
     * 
     * @param key the name of the preference
     * @param value the value of the preference
     */
    public synchronized void putFont(String key, Font value) {
        StringBuilder buffer = new StringBuilder(value.getFamily());
        if (!value.isPlain()) {
            buffer.append('-');
            if (value.isBold()) {
                buffer.append("BOLD");
            }
            if (value.isItalic()) {
                buffer.append("ITALIC");
            }
        }
        buffer.append('-');
        buffer.append(Integer.toString(value.getSize()));

        putString(key, buffer.toString());
    }

    /**
     * Returns specified preference.
     * 
     * @param key the name of the preference
     * @param fallback value returned if specified preference is not found or
     * cannot be parsed as a <code>Font</code>
     * @return specified preference if found and valid; returns
     * <code>fallback</code> otherwise
     */
    public synchronized Font getFont(String key, Font fallback) {
        String value = getString(key, null);
        if (value == null) {
            return fallback;
        }

        Font font = Font.decode(value);
        if (font == null) {
            return fallback;
        }

        return font;
    }

    /**
     * Adds or replaces preference.
     * 
     * @param key the name of the preference
     * @param value the value of the preference
     */
    public synchronized void putColor(String key, Color value) {
        putInts(key, 
                new int[] {
                    value.getRed(), value.getGreen(), value.getBlue()
                });
    }

    /**
     * Returns specified preference.
     * 
     * @param key the name of the preference
     * @param fallback value returned if specified preference is not found or
     * cannot be parsed as a <code>Color</code>
     * @return specified preference if found and valid; returns
     * <code>fallback</code> otherwise
     */
    public synchronized Color getColor(String key, Color fallback) {
        int[] rgb = 
            getInts(key, 
                    new int[] {
                       fallback.getRed(),fallback.getGreen(),fallback.getBlue()
                    });

        if (rgb.length != 3 || 
            rgb[0] < 0 || rgb[0] > 255 || 
            rgb[1] < 0 || rgb[1] > 255 || 
            rgb[2] < 0 || rgb[2] > 255) {
            return fallback;
        } else {
            return new Color(rgb[0], rgb[1], rgb[2]);
        }
    }

    /**
     * Adds or replaces preference.
     * 
     * @param key the name of the preference
     * @param value the value of the preference
     */
    public synchronized void putRectangle(String key, Rectangle value) {
        putInts(key, new int[] {value.x, value.y, value.width, value.height});
    }

    /**
     * Returns specified preference.
     * 
     * @param key the name of the preference
     * @param fallback value returned if specified preference is not found or
     * cannot be parsed as a <code>Rectangle</code>
     * @return specified preference if found and valid; returns
     * <code>fallback</code> otherwise
     */
    public synchronized Rectangle getRectangle(String key,
                                               Rectangle fallback) {
        int[] r = getInts(
            key, 
            new int[] {fallback.x,fallback.y,fallback.width,fallback.height});
        if (r.length != 4 || r[2] < 0 || r[3] < 0) {
            return fallback;
        } else {
            return new Rectangle(r[0], r[1], r[2], r[3]);
        }
    }

    /**
     * Adds or replaces preference for the format of the paper 
     * used when printing documents.
     * 
     * @param key the name of the preference
     * @param paper the value of the preference
     */
    public synchronized void putPaper(String key, Paper paper) {
        putDoubles(key, new double[] {
            paper.getWidth(), paper.getHeight(), 
            paper.getImageableX(), paper.getImageableY(), 
            paper.getImageableWidth(), paper.getImageableHeight()
        });
    }

    /**
     * Returns specified preference.
     * 
     * @param key the name of the preference
     * @param fallback value returned if specified preference is not found or
     * cannot be parsed as a <code>Paper</code>
     * @return specified preference if found and valid; returns
     * <code>fallback</code> otherwise
     */
    public synchronized Paper getPaper(String key, Paper fallback) {
        double[] dim = getDoubles(key, null);
        if (dim == null) {
            return fallback;
        }

        Paper paper = newPaper(dim[0], dim[1], dim[2], dim[3], dim[4], dim[5]);
        if (paper == null) {
            return fallback;
        }

        return paper;
    }

    /**
     * Helper function: returns a new Paper initialized using specified
     * paper size and specified imageable area.
     */
    public static final Paper newPaper(double paperW, double paperH,
                                       double x, double y, 
                                       double width, double height) {
        if (paperW < 0 || paperH < 0 ||
            x < 0 || x >= paperW ||
            y < 0 || y >= paperH ||
            width <= 0 || width > paperW-x ||
            height <= 0 || height > paperH-y) {
            return null;
        }

        Paper paper = new Paper();
        paper.setSize(paperW, paperH);
        paper.setImageableArea(x, y, width, height);

        return paper;
    }

    /**
     * Removes specified preference.
     * 
     * @param key the name of the preference
     */
    public synchronized void remove(String key) {
        map.removePreference(key);
    }

    /**
     * Removes all preferences.
     */
    public synchronized void removeAll() {
        map.removeAllPreferences();
    }

    /**
     * Returns all preferences in the form of a list of key/value pairs. This
     * list may be empty but cannot be <code>null</code>.
     */
    public synchronized String[] getAll() {
        return map.getAllPreferences();
    }

    /**
     * Adds or replaces preferences with preferences read from another
     * <code>Preferences</code> object.
     * 
     * @param other the source <code>Preferences</code> object
     */
    public synchronized void putAll(Preferences other) {
        String[] all = other.map.getAllPreferences();
        for (int i = 0; i < all.length; i += 2) {
            map.putPreference(all[i], all[i+1]);
        }
    }

    /**
     * Adds or replaces preferences with preferences read 
     * from specified <code>java.util.Properties</code> object.
     * 
     * @param props specifies the preferences to be added or replaced
     */
    public synchronized void putAll(Properties props) {
        Iterator<java.util.Map.Entry<Object, Object>> iter = 
            props.entrySet().iterator();
        while (iter.hasNext()) {
            java.util.Map.Entry<Object, Object> e = iter.next();

            map.putPreference((String) e.getKey(), (String) e.getValue());
        }
    }

    /**
     * Equivalent to {@link #putAll(URL) 
     * putAll(FileUtil.fileToURL(propsFile))}.
     */
    public synchronized void putAll(File propsFile) throws IOException {
        putAll(FileUtil.fileToURL(propsFile));
    }

    /**
     * Adds or replaces preferences with preferences read 
     * from specified property file.
     * 
     * @param propsURL location of a property file which contains 
     * the preferences to be added or replaced
     * @exception IOException if there is problem loading 
     * the specified property file.
     */
    public synchronized void putAll(URL propsURL) 
        throws IOException {
        BufferedInputStream in = 
            new BufferedInputStream(URLUtil.openStreamNoCache(propsURL), 
                                    65536);

        Properties props = new Properties();
        try {
            props.load(in);
        } finally {
            in.close();
        }

        putAll(props);
    }

    /**
     * Saves preferences to the backing store.
     * 
     * @return <code>true</code> if preferences have been saved;
     * <code>false</code> otherwise (I/O error or this Preferences object is
     * not persistent).
     */
    public synchronized boolean save() {
        return map.save();
    }

    // -----------------------------------------------------------------------

    private static final Preferences[] appPreferences = new Preferences[1];

    /**
     * Specifies the Preferences object containing application-wide 
     * user preferences.
     * 
     * @param prefs application-wide user preferences.
     * May be <code>null</code> in which case a new, non-persistent, 
     * Preferences object will be used.
     * @see #getPreferences
     */
    public static final void setPreferences(Preferences prefs) {
        synchronized (appPreferences) {
            appPreferences[0] = prefs;
        }
    }

    /**
     * Returns the Preferences object containing application-wide 
     * user preferences.
     *
     * @return a non-null Preferences object
     * @see #setPreferences
     */
    public static final Preferences getPreferences() {
        synchronized (appPreferences) {
            if (appPreferences[0] == null) {
                appPreferences[0] = new Preferences();
            }
            return appPreferences[0];
        }
    }
}

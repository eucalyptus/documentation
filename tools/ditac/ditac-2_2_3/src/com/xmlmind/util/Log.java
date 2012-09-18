/*
 * Copyright (c) 2002-2008 Pixware. 
 *
 * Author: Hussein Shafie
 *
 * This file is part of several XMLmind projects.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.util;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Date;

/**
 * A simple log facility which implements the following services:
 * <ul>
 * <li>Log messages to a cyclic in-memory buffer.
 * <li>Access last logged messages.
 * <li>Clear last logged messages.
 * <li>List all the logs that have been created during a session.
 * </ul>
 * <p>In addition to the above services, this log facility can act as a 
 * <i>facade</i> for real logging tools such as those found in 
 * {@link java.util.logging.Logger}.
 * <p>This class is thread-safe.
 */
public final class Log {
    /**
     * Log levels.
     */
    public enum Level {
        /**
         * A non-fatal error message.
         */
        ERROR,

        /**
         * A warning message.
         */
        WARNING,

        /**
         * An information message.
         */
        INFO,

        /**
         * A low-level information message.
         */
        VERBOSE,

        /**
         * A debugging or trace message.
         */
        DEBUG
    }

    /**
     * Underlying logger.
     */
    public interface Recorder {
        /**
         * Records specified message.
         */
        void record(Level level, String message);
    }

    /**
     * Underlying logger factory.
     */
    public interface RecorderFactory {
        /**
         * Returns the logger having specified name. Creates one if needed to.
         */
        Recorder getRecorder(String name);
    }

    // -----------------------------------------------------------------------

    /**
     * A message recorder that does not nothing at.
     * <p>Default implementation of Recorder.
     */
    public static final class RecorderImpl implements Recorder {
        public void record(Level level, String message) {
            // Not recorded.
        }
    }

    /**
     * Creates and returns {@link RecorderImpl}s.
     * <p>Default implementation of RecorderFactory.
     */
    public static final class RecorderFactoryImpl implements RecorderFactory {
        public Recorder getRecorder(String name) { 
            return new RecorderImpl(); 
        }
    }

    // -----------------------------------------------------------------------

    private static Object lockRecorderFactory = new Object();
    private static RecorderFactory recorderFactory = new RecorderFactoryImpl();
    private static HashMap<String, Log> logs = new HashMap<String, Log>();

    /**
     * Specifies which RecorderFactory to use. Specify <code>null</code> 
     * to use the default implementation.
     */
    public static void setRecorderFactory(RecorderFactory factory) {
        synchronized (lockRecorderFactory) {
            if (factory == null)
                factory = new RecorderFactoryImpl();
            recorderFactory = factory;
        }
    }

    /**
     * Returns currently used RecorderFactory.
     */
    public static RecorderFactory getRecorderFactory() {
        synchronized (lockRecorderFactory) {
            return recorderFactory;
        }
    }

    /**
     * Returns the log having specified name. Creates one if needed to.
     */
    public static Log getLog(String name) {
        synchronized (lockRecorderFactory) {
            Log log = logs.get(name);
            if (log == null) {
                Recorder recorder = recorderFactory.getRecorder(name);
                log = new Log(recorder);
                logs.put(name, log);
            }

            return log;
        }
    }

    /**
     * Returns the names of all logs returned by {@link #getLog}.
     */
    public static String[] getNames() {
        synchronized (lockRecorderFactory) {
            String[] names = new String[logs.size()];
            logs.keySet().toArray(names);
            return names;
        }
    }

    // -----------------------------------------------------------------------

    /**
     * Default buffering capacity (1,000).
     */
    public static final int DEFAULT_CAPACITY = 1000;

    /**
     * Maximum buffering capacity (10,000).
     */
    public static final int MAX_CAPACITY = 10000;

    /**
     * A buffered item.
     */
    public static final class Item {
        /**
         * Level of the logged message.
         */
        public final Level level;

        /**
         * Logged message.
         */
        public final String message;

        /**
         * Date at which the message has been logged.
         */
        public final long date;

        /**
         * Constructs a buffered item containing specified message.
         */
        public Item(Level level, String message) {
            this.level = level;
            this.message = message;
            date = System.currentTimeMillis();
        }

        public String toString() {
            StringBuilder buffer = new StringBuilder();
            buffer.append(new Date(date));
            buffer.append(": ");
            buffer.append(level);
            buffer.append(": ");
            buffer.append(message);
            return buffer.toString();
        }
    }

    // -----------------------------------------------------------------------

    /**
     * The underlying logger used by this Log object.
     */
    public final Recorder recorder;

    private int capacity;
    private ArrayList<Item> items;

    private Log(Recorder recorder) {
        this.recorder = recorder;

        capacity = DEFAULT_CAPACITY;
        items = new ArrayList<Item>();
    }

    /**
     * Logs specified message at level {@link Level#ERROR}.
     */ 
    public void error(String message) {
        log(Level.ERROR, message);
    }

    /**
     * Logs specified message at level {@link Level#WARNING}.
     */ 
    public void warning(String message) {
        log(Level.WARNING, message);
    }

    /**
     * Logs specified message at level {@link Level#INFO}.
     */ 
    public void info(String message) {
        log(Level.INFO, message);
    }

    /**
     * Logs specified message at level {@link Level#VERBOSE}.
     */ 
    public void verbose(String message) {
        log(Level.VERBOSE, message);
    }

    /**
     * Logs specified message at level {@link Level#DEBUG}.
     */ 
    public void debug(String message) {
        log(Level.DEBUG, message);
    }

    /**
     * Logs specified message at specified level.
     */ 
    public synchronized void log(Level level, String message) {
        recorder.record(level, message);

        if (items.size() == capacity)
            items.remove(0);
        items.add(new Item(level, message));
    }

    /**
     * Specifies buffering capacity. Cannot exceed {@link #MAX_CAPACITY}.
     * <p>When the number of buffered items has reached this capacity, 
     * ``oldest''item is discarded to make room for newly buffered item.
     */
    public synchronized void setCapacity(int capacity) {
        if (capacity <= 0)
            capacity = DEFAULT_CAPACITY;
        else if (capacity > MAX_CAPACITY)
            capacity = MAX_CAPACITY;

        this.capacity = capacity;

        int remove = items.size() - capacity;
        if (remove > 0)
            items.subList(0, remove).clear();
    }

    /**
     * Returns buffering capacity.
     */
    public synchronized int getCapacity() {
        return capacity;
    }

    /**
     * Returns all buffered items.
     */
    public Item[] get() {
        return get(Integer.MAX_VALUE);
    }

    /**
     * Returns last buffered items.
     * 
     * @param maxCount return at most this number of items
     * @return a possibly empty array of items, 
     * first item being the ``oldest one''
     */
    public synchronized Item[] get(int maxCount) {
        int count = items.size();
        if (maxCount < 0)
            maxCount = count;

        Item[] list = new Item[Math.min(count, maxCount)];
        int j = 0;
        for (int i = count - list.length; i < count; ++i)
            list[j++] = items.get(i);

        return list;
    }

    /**
     * Returns all buffered items having at most specified level.
     *
     * @param maxLevel maximum level (inclusive) for returned items
     * @return a possibly empty array of items, 
     * first item being the ``oldest one''
     */
    public Item[] get(Level maxLevel) {
        return get(maxLevel, Integer.MAX_VALUE);
    }

    /**
     * Returns last buffered items having at most specified level.
     * 
     * @param maxLevel maximum level (inclusive) for returned items
     * @param maxCount return at most this number of items
     * @return a possibly empty array of items, 
     * first item being the ``oldest one''
     */
    public synchronized Item[] get(Level maxLevel, int maxCount) {
        int count = items.size();
        if (maxCount < 0)
            maxCount = count;

        ArrayList<Item> list = new ArrayList<Item>();
        int max = maxLevel.ordinal();

        int j = 0;
        for (int i = count - 1; i >= 0; --i) {
            Item item = items.get(i);

            if (item.level.ordinal() <= max) {
                list.add(item);

                ++j;
                if (j == maxCount)
                    break;
            }
        }

        Item[] result = new Item[j];
        for (int i = 0; i < j; ++i) 
            result[i] = list.get(j - 1 - i);

        return result;
    }

    /**
     * Removes all buffered items.
     */
    public synchronized void clear() {
        items = new ArrayList<Item>();
    }
}

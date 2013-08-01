/*
 * Copyright (c) 2007-2010 Pixware. 
 *
 * Author: Hussein Shafie
 *
 * This file is part of several XMLmind projects.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.util;

/**
 * Interface implemented by objects wishing to monitor the execution of a
 * lengthy task.
 */
public interface ProgressMonitor {
    /**
     * Invoked by the lengthy task to inform this monitor that the execution
     * of the task has started.
     * <p>This method is guaranteed to be invoked once before any other
     * method.
     */
    void start();

    /**
     * Invoked by the lengthy task to give this monitor information about the
     * step being executed.
     * <p>This method may be invoked any number of times (including 0), at any
     * time, between {@link #start} and {@link #stop}.
     * 
     * @param message message containing information about the step being
     * executed
     * @param messageType type of message. 
     * May be <code>null</null> which is equivalent to INFO.
     * @return <code>false</code> if this monitor wants to cancel the lengthy
     * task; <code>true</code> otherwise
     */
    boolean message(String message, Console.MessageType messageType);

    /**
     * Invoked by the lengthy task to inform this monitor about the total
     * numbers of steps comprising the task.
     * <p>This method is guaranteed to be invoked once before any invocation
     * of {@link #step}. Therefore the simplest sequence of invocations is:
     * <pre>start
     *stepCount
     *step
     *step
     *...
     *step
     *stop</pre>
     * <p>Note that in the above example, {@link #message} is never invoked.
     * 
     * @param stepCount total numbers of steps comprising the lengthy task.
     * This number is computed once for all. A negative value means that this
     * number cannot be determined.
     * @return <code>false</code> if this monitor wants to cancel the lengthy
     * task; <code>true</code> otherwise
     */
    boolean stepCount(int stepCount);

    /**
     * Invoked by the lengthy task to inform this monitor each time a new step
     * is about to be executed.
     * 
     * @param step current step. First step is step 0. Last step is step
     * <i>stepCount</i>-1, when <i>stepCount</i> is strictly positive.
     * @return <code>false</code> if this monitor wants to cancel the lengthy
     * task; <code>true</code> otherwise
     */
    boolean step(int step);

    /**
     * Invoked by the lengthy task to inform this monitor that the execution
     * of the task has stopped, whatever the reason (success, canceled,
     * error).
     * <p>This method is guaranteed to be invoked once when {@link #start} has
     * also been invoked. No other method will be invoked after that.
     */
    void stop();
}

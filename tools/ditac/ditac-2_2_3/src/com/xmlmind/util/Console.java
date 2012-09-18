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
 * Interface implemented by objects which are required to report information,
 * warnings and non-fatal errors to the user.
 * <p>The implementation is generally expected to be thread-safe.
 */
public interface Console {
    /**
     * Message types.
     */
    enum MessageType {
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
     * Show specified message to user.
     * 
     * @param message a possibly multi-line message
     * @param messageType type of message: {@link MessageType#INFO}, {@link
     * MessageType#WARNING}, {@link MessageType#ERROR} or {@link
     * MessageType#DEBUG}.
     */
    void showMessage(String message, MessageType messageType);
}

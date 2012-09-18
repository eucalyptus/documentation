/*
 * Copyright (c) 2009 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.util;

import java.io.PrintStream;
import com.xmlmind.util.Console;

/**
 * An implementation of Console which prints its messages to
 * {@link java.lang.System#err} and {@link java.lang.System#out}.
 */
public class SimpleConsole implements Console {
    private String prefix;
    private boolean showMessageType;
    private MessageType errorLevel;

    // -----------------------------------------------------------------------

    public SimpleConsole() {
        this(null, false, MessageType.INFO);
    }

    public SimpleConsole(String prefix, boolean showMessageType,
                         MessageType errorLevel) {
        this.prefix = prefix;
        this.showMessageType = showMessageType;
        this.errorLevel = errorLevel;
    }

    public void setPrefix(String prefix) {
        this.prefix = prefix;
    }

    public String getPrefix() {
        return prefix;
    }

    public void setShowingMessageType(boolean show) {
        showMessageType = show;
    }

    public boolean isShowingMessageType() {
        return showMessageType;
    }

    public void setErrorLevel(MessageType level) {
       errorLevel = level;
    }

    public MessageType getErrorLevel() {
        return errorLevel;
    }

    public void showMessage(String message, MessageType messageType) {
        PrintStream output;
        if (messageType.ordinal() >= errorLevel.ordinal()) {
            output = System.out;
        } else {
            output = System.err;
        }
        if (prefix != null) {
            output.print(prefix);
        } 
        if (showMessageType) {
            output.print(messageType);
            output.print(": ");
        }
        output.println(message);
    }
}

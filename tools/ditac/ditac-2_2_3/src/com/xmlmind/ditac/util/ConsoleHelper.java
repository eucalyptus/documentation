/*
 * Copyright (c) 2009-2012 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.util;

import org.w3c.dom.Element;
import com.xmlmind.util.Console;

public class ConsoleHelper implements Console {
    public final Console console;

    protected Console.MessageType verbosity;

    // -----------------------------------------------------------------------

    public ConsoleHelper(Console console) {
        this.console = console;
        verbosity = Console.MessageType.WARNING;
    }

    public void setVerbosity(Console.MessageType verbosity) {
        this.verbosity = verbosity;
    }

    public Console.MessageType getVerbosity() {
        return verbosity;
    }

    public boolean isVerbose() {
        return (verbosity.compareTo(Console.MessageType.VERBOSE) >= 0);
    }

    // -----------------------------------------------------------------------

    public void error(String message) {
        showMessage(message, Console.MessageType.ERROR);
    }

    public void warning(String message) {
        showMessage(message, Console.MessageType.WARNING);
    }

    public void info(String message) {
        showMessage( message, Console.MessageType.INFO);
    }

    public void verbose(String message) {
        showMessage(message, Console.MessageType.VERBOSE);
    }

    public void debug(String message) {
        showMessage(message, Console.MessageType.DEBUG);
    }

    // -----------------------------------------------------------------------

    public void error(Element element, String message) {
        showMessage(prependLocation(element, message),
                    Console.MessageType.ERROR);
    }

    public void warning(Element element, String message) {
        showMessage(prependLocation(element, message),
                    Console.MessageType.WARNING);
    }

    public void info(Element element,  String message) {
        showMessage(prependLocation(element, message),
                    Console.MessageType.INFO);
    }

    public void verbose(Element element, String message) {
        showMessage(prependLocation(element, message),
                    Console.MessageType.VERBOSE);
    }

    public void debug(Element element, String message) {
        showMessage(prependLocation(element, message),
                    Console.MessageType.DEBUG);
    }

    protected String prependLocation(Element element, String message) {
        return prependElementLocation(element, message);
    }

    public static String prependElementLocation(Element element,
                                                String message) {
        if (element != null) {
            NodeLocation location = 
                (NodeLocation) element.getUserData(NodeLocation.USER_DATA_KEY);
            if (location == null) {
                location = NodeLocation.UNKNOWN_LOCATION;
            }

            StringBuilder buffer = new StringBuilder();
            location.toString(buffer);
            buffer.append(": ");
            buffer.append(message);

            message = buffer.toString();
        }
        return message;
    }

    // -----------------------------------------------------------------------

    public boolean isShowing(Console.MessageType messageType) {
        return (console != null &&
                messageType.ordinal() <= verbosity.ordinal());
    }

    public void showMessage(String message, Console.MessageType messageType) {
        if (isShowing(messageType)) {
            console.showMessage(message, messageType);
        }
    }
}

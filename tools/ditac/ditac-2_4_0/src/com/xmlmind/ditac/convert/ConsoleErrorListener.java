/*
 * Copyright (c) 2009-2010 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.convert;

import javax.xml.transform.ErrorListener;
import javax.xml.transform.TransformerException;
import com.xmlmind.util.Console;

/**
 * An implementation of {@link javax.xml.transform.ErrorListener} which 
 * displays its messages on a {@link com.xmlmind.util.Console}.
 */
public final class ConsoleErrorListener implements ErrorListener {
    /**
     * The Console used to display messages.
     * May be <code>null</code>, in which case messages are never displayed.
     */
    public final Console console;

    /**
     * Constructs a ConsoleErrorListener using specified console.
     *
     * @param console the Console used to display messages. 
     * May be <code>null</code>, in which case messages are never displayed.
     */
    public ConsoleErrorListener(Console console) {
        this.console = console;
    }

    public void warning(TransformerException e) 
        throws TransformerException {
        if (console != null) {
            console.showMessage(Msg.msg("transformWarning",
                                        e.getMessageAndLocation()),
                                Console.MessageType.WARNING);
        }
    }

    public void error(TransformerException e) 
        throws TransformerException {
        if (console != null) {
            console.showMessage(Msg.msg("transformError",
                                        e.getMessageAndLocation()),
                                Console.MessageType.ERROR);
        }
    }

    public void fatalError(TransformerException e) 
        throws TransformerException {
        if (console != null) {
            console.showMessage(Msg.msg("transformFatalError",
                                        e.getMessageAndLocation()),
                                Console.MessageType.ERROR);
        }

        // Just in case.
        throw e;
    }
}

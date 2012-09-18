/*
 * Copyright (c) 2009-2012 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.util;

public final class NodeLocation {
    public static final String USER_DATA_KEY = "NODE_LOCATION";

    public static final NodeLocation UNKNOWN_LOCATION =
        new NodeLocation(null, -1, -1, null);

    public final String systemId;
    public final int lineNumber;
    public final int columnNumber;
    public final String elementPointer;

    // -----------------------------------------------------------------------

    public NodeLocation(String systemId, int lineNumber, int columnNumber,
                        String elementPointer) {
        this.systemId = systemId;
        this.lineNumber = lineNumber;
        this.columnNumber = columnNumber;
        this.elementPointer = elementPointer;
    }

    @Override
    public String toString() {
        StringBuilder buffer = new StringBuilder();
        toString(buffer);
        return buffer.toString();
    }

    public void toString(StringBuilder buffer) {
        if (systemId != null) {
            buffer.append(systemId);
        }
        buffer.append(':');
        if (lineNumber > 0) {
            buffer.append(Integer.toString(lineNumber));
        }
        buffer.append(':');
        if (columnNumber > 0) {
            buffer.append(Integer.toString(columnNumber));
        }
    }
}

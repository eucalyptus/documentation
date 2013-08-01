/*
 * Copyright (c) 2009-2013 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.util;

import java.util.Stack;
import org.xml.sax.SAXException;
import org.xml.sax.Locator;
import org.xml.sax.Attributes;
import org.xml.sax.helpers.DefaultHandler;
import org.w3c.dom.Node;
import org.w3c.dom.ProcessingInstruction;
import org.w3c.dom.Element;
import org.w3c.dom.Document;

public class SAXToDOM extends DefaultHandler {
    public final Document doc;
    public final boolean addElementPointer;

    protected Stack<Node> nodeStack;
    protected StringBuilder buffer;
    protected Locator locator;

    // -----------------------------------------------------------------------

    public SAXToDOM(Document doc, boolean addElementPointer) {
        this.doc = doc;
        this.addElementPointer = addElementPointer;

        nodeStack = new Stack<Node>();
        nodeStack.push(doc);
    }

    @Override
    public void setDocumentLocator(Locator locator) {
        this.locator = locator;
    }

    @Override
    public void startElement(String uri, String localName, String qName,
                             Attributes atts)
        throws SAXException {
        flushBuffer();

        Node parent = nodeStack.peek();

        Element element = createElement(parent, uri, qName, atts);

        parent.appendChild(element);

        nodeStack.push(element);
    }

    protected Element createElement(Node parent, String uri, String qName,
                                    Attributes atts) {
        Element element = 
            doc.createElementNS(((uri == null || uri.length() == 0)? 
                                 null : uri), 
                                qName);

        int attCount = atts.getLength();
        for (int i = 0; i < attCount; ++i) {
            String attName = atts.getQName(i);
            if (attName.startsWith("xmlns")) {
                continue;
            }

            String attURI = atts.getURI(i);

            element.setAttributeNS(((attURI == null || attURI.length() == 0)? 
                                    null : attURI), 
                                   attName, atts.getValue(i));
        }

        NodeLocation location = null;
        if (locator != null) {
            String systemId = locator.getSystemId();
            if (systemId != null) {
                String elementPointer = null;
                if (addElementPointer) {
                    elementPointer = nextElementPointer(parent);
                }

                location = new NodeLocation(systemId,
                                            locator.getLineNumber(), 
                                            locator.getColumnNumber(),
                                            elementPointer);
            }
        }
        if (location != null) {
            element.setUserData(NodeLocation.USER_DATA_KEY, location,
                                DOMUtil.COPY_USER_DATA);
        }

        return element;
    }

    protected static String nextElementPointer(Node parent) {
        String elementPointer;
        if (parent.getNodeType() == Node.ELEMENT_NODE) {
            elementPointer = null;

            NodeLocation location = 
                (NodeLocation) parent.getUserData(NodeLocation.USER_DATA_KEY);
            if (location != null) {
                elementPointer = location.elementPointer;
            }

            if (elementPointer == null) {
                return null;
            }
        } else { // Document.
            elementPointer = "";
        }

        // Count sibling elements ---

        int index = 1;

        Node child = parent.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                ++index;
            }

            child = child.getNextSibling();
        }

        StringBuilder buffer = new StringBuilder();
        buffer.append(elementPointer);
        buffer.append('/');
        buffer.append(Integer.toString(index));
        return buffer.toString();
    }

    @Override
    public void endElement(String uri, String localName, String qName)
        throws SAXException {
        flushBuffer();

        nodeStack.pop();
    }

    protected void flushBuffer() {
        if (buffer != null) {
            Node parent = nodeStack.peek();
            parent.appendChild(doc.createTextNode(buffer.toString()));
            buffer = null;
        }
    }

    @Override
    public void characters(char[] ch, int start, int length)
        throws SAXException {
        if (buffer == null) {
            buffer = new StringBuilder();
        }
        buffer.append(ch, start, length);
    }

    @Override
    public void processingInstruction(String target, String data)
        throws SAXException {
        Node parent = nodeStack.peek();

        ProcessingInstruction pi = 
            doc.createProcessingInstruction(target, data);

        parent.appendChild(pi);
    }
}

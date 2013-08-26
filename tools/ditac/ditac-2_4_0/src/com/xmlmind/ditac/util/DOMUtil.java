/*
 * Copyright (c) 2009-2011 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.util;

import static javax.xml.XMLConstants.XML_NS_URI;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.DOMConfiguration;
import org.w3c.dom.DOMImplementation;
import org.w3c.dom.UserDataHandler;
import org.w3c.dom.Node;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Attr;
import org.w3c.dom.Element;
import org.w3c.dom.Document;
import org.w3c.dom.ls.DOMImplementationLS;
import org.w3c.dom.ls.LSSerializer;
import com.xmlmind.util.ThrowableUtil;
import com.xmlmind.util.ObjectUtil;

public final class DOMUtil {
    private DOMUtil() {}

    // -----------------------------------------------------------------------

    public static Document newDocument() {
        DOMImplementation impl = getDOMImplementation();
        return impl.createDocument(null, null, null);
    }

    /*package*/ static DOMImplementation getDOMImplementation() {
        DOMImplementation impl;
        try {
            DocumentBuilder builder =
                DocumentBuilderFactory.newInstance().newDocumentBuilder();
            impl = builder.getDOMImplementation();

            // Check whether it actually implements DOM3 Load & Save.
            DOMImplementationLS implLS = (DOMImplementationLS) impl;
        } catch (Exception shouldNotHappen) {
            throw new RuntimeException(
                Msg.msg("cannotGetDOMImplementationLS",
                        ThrowableUtil.reason(shouldNotHappen)));
        }
        return impl;
    }

    /**
     * Returns an indented string representation of specified XML node. 
     * Returns <code>null</code> if for any reason, an XML serializer
     * fails to be created and configured.
     * <p>Used to test and debug this software.
     */
    public static String toString(Node node) {
        try {
            DOMImplementationLS impl =
                (DOMImplementationLS) getDOMImplementation();

            LSSerializer writer = impl.createLSSerializer();

            DOMConfiguration config = writer.getDomConfig();
            config.setParameter("xml-declaration", Boolean.FALSE);
            config.setParameter("discard-default-content", Boolean.FALSE);
            // Not supported by Java 1.5. Requires Java 1.6+.
            config.setParameter("format-pretty-print", Boolean.TRUE);

            return writer.writeToString(node);
        } catch (Exception ignored) {
            //ignored.printStackTrace();
            return null;
        }
    }

    // -----------------------------------------------------------------------

    public static void copyChildren(Element from, Element to, Document doc) {
        Node child = from.getFirstChild();
        while (child != null) {
            to.appendChild(doc.importNode(child, /*deep*/ true));

            child = child.getNextSibling();
        }
    }

    // -----------------------------------------------------------------------

    public static void removeChildren(Node parent) {
        Node child = parent.getFirstChild();
        while (child != null) {
            Node next = child.getNextSibling();

            parent.removeChild(child);

            child = next;
        }
    }

    // -----------------------------------------------------------------------

    public static void setXMLId(Element element, String id) {
        element.setAttributeNS(XML_NS_URI, "xml:id", id);
    }

    public static String getXMLId(Element element) {
        String value = element.getAttributeNS(XML_NS_URI, "id");
        if (value != null && (value = value.trim()).length() == 0) {
            value = null;
        }
        return value;
    }

    // -----------------------------------------------------------------------

    public static void setXMLLang(Element element, String lang) {
        element.setAttributeNS(XML_NS_URI, "xml:lang", lang);
    }

    public static String getXMLLang(Element element) {
        String value = element.getAttributeNS(XML_NS_URI, "lang");
        if (value != null && (value = value.trim()).length() == 0) {
            value = null;
        }
        return value;
    }

    // -----------------------------------------------------------------------

    public static boolean hasName(Node node,
                                  String namespace, String localName) {
        String localName2 = node.getLocalName();
        if (localName2 == null) {
            return false;
        }

        return (localName.equals(localName2) &&
                ObjectUtil.equals(namespace, node.getNamespaceURI()));
    }

    public static boolean sameName(Node node1, Node node2) {
        return (ObjectUtil.equals(node1.getLocalName(), 
                                  node2.getLocalName()) &&
                ObjectUtil.equals(node1.getNamespaceURI(), 
                                  node2.getNamespaceURI()));
    }

    public static String formatName(Node node) {
        if (node == null) {
            return null;
        }

        String localName = node.getLocalName();
        if (localName == null) {
            return null;
        }

        String namespace = node.getNamespaceURI();
        if (namespace == null) {
            return localName;
        }

        StringBuilder buffer = new StringBuilder();
        buffer.append('{');
        buffer.append(namespace);
        buffer.append('}');
        buffer.append(localName);
        return buffer.toString();
    }

    // -----------------------------------------------------------------------

    public static final class CopyUserData implements UserDataHandler {
        public void handle(short operation, String key, Object data,
                           Node src, Node dst) {
            if (data != null) {
                switch (operation) {
                case UserDataHandler.NODE_IMPORTED:
                case UserDataHandler.NODE_CLONED:
                    dst.setUserData(key, data, this);
                    break;
                }
            }
        }
    }
    public static final CopyUserData COPY_USER_DATA = new CopyUserData();

    // -----------------------------------------------------------------------

    public static void removeUserData(Node node, String key) {
        node.setUserData(key, null, null);

        Node child = node.getFirstChild();
        while (child != null) {
            removeUserData(child, key);

            child = child.getNextSibling();
        }
    }

    // -----------------------------------------------------------------------

    public static boolean hasContent(Node node) {
        Node child = node.getFirstChild();
        while (child != null) {
            switch (child.getNodeType()) {
            case Node.TEXT_NODE:
            case Node.ELEMENT_NODE:
                return true;
            }
            child = child.getNextSibling();
        }
        return false;
    }

    // -----------------------------------------------------------------------

    public static final Element[] NO_ELEMENTS = new Element[0];

    public static Element getFirstChildElement(Node node) {
        return getNthChildElement(node, 0);
    }

    public static Element getLastChildElement(Node node) {
        Node child = node.getLastChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                return (Element) child;
            }

            child = child.getPreviousSibling();
        }
        return null;
    }

    public static Element getNthChildElement(Node node, int index) {
        int i = 0;

        Node child = node.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                if (index == i) {
                    return (Element) child;
                }
                ++i;
            }

            child = child.getNextSibling();
        }

        return null;
    }

    public static int indexOfChildElement(Element element) {
        Node parent = element.getParentNode();
        if (parent == null) {
            return -1;
        } else {
            return indexOfChildElement(parent, element);
        }
    }

    private static int indexOfChildElement(Node parent, Element element) {
        int index = 0;
        Node child = parent.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                if (child == element) {
                    return index;
                }
                ++index;
            }

            child = child.getNextSibling();
        }

        return -1;
    }

    public static Element getChildElementByName(Node node,
                                                String namespace,
                                                String localName) {
        Node child = node.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                String ns = childElement.getNamespaceURI();

                if (childElement.getLocalName().equals(localName) &&
                    ((namespace == null && ns == null) ||
                     (namespace != null && namespace.equals(ns)))) {
                    return childElement;
                }
            }

            child = child.getNextSibling();
        }

        return null;
    }

    // -----------------------------------------------------------------------

    public static String lookupAttribute(Element element, String namespace, 
                                         String localName) {
        while (element != null) {
            String value = element.getAttributeNS(namespace, localName);
            if (value != null && value.length() > 0) {
                return value;
            }

            element = getParentElement(element);
        }

        // This differs from getAttributeNS which returns "" and not null!
        return null;
    }

    // -----------------------------------------------------------------------

    public static Element getParentElement(Node node) {
        Node parent = node.getParentNode();
        if (parent == null || parent.getNodeType() != Node.ELEMENT_NODE) {
            return null;
        } else {
            return (Element) parent;
        }
    }

    // -----------------------------------------------------------------------

    public static Element getNextElement(Node node) {
        node = node.getNextSibling();
        while (node != null) {
            if (node.getNodeType() == Node.ELEMENT_NODE) {
                return (Element) node;
            } 

            node = node.getNextSibling();
        }

        return null;
    }

    // -----------------------------------------------------------------------

    public static Document getAncestorDocument(Node node) {
        while (node != null) {
            if (node.getNodeType() == Node.DOCUMENT_NODE) {
                return (Document) node;
            }

            node = node.getParentNode();
        }

        return null;
    }

    // -----------------------------------------------------------------------

    public static boolean isAncestorOf(Node ancestor, Node node) {
        while (node != null) {
            if (node == ancestor) {
                return true;
            }

            node = node.getParentNode();
        }

        return false;
    }

    // -----------------------------------------------------------------------

    public static void copyAllAttributes(Element from, Element to) {
        NamedNodeMap attrs = from.getAttributes();
        int attrCount = attrs.getLength();

        for (int i = 0; i < attrCount; ++i) {
            Attr attr = (Attr) attrs.item(i);

            to.setAttributeNS(attr.getNamespaceURI(), /*QName*/ attr.getName(),
                              attr.getValue());
        }
    }

    public static void removeAllAttributes(Element element) {
        // A NamedNodeMap is live.
        NamedNodeMap attrs = element.getAttributes();
        int attrCount = attrs.getLength();

        for (int i = attrCount-1; i >= 0; --i) {
            Attr attr = (Attr) attrs.item(i);

            attrs.removeNamedItemNS(attr.getNamespaceURI(), 
                                    attr.getLocalName());
        }
    }
}

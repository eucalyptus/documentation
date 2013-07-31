/*
 * Copyright (c) 2009-2013 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.util;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import org.w3c.dom.Node;
import org.w3c.dom.Element;
import com.xmlmind.util.ArrayUtil;
import com.xmlmind.util.StringList;
import com.xmlmind.util.StringUtil;
import com.xmlmind.util.URIComponent;
import com.xmlmind.util.URLUtil;
import com.xmlmind.util.XMLText;

public final class DITAUtil {
    private DITAUtil() {}

    // -----------------------------------------------------------------------

    public static final String DITAC_NS_URI =
        "http://www.xmlmind.com/ditac/schema/ditac";

    public static boolean hasDITANamespace(Node node) {
        String uri = node.getNamespaceURI();
        return (uri == null || DITAC_NS_URI.equals(uri));
    }

    // -----------------------------------------------------------------------

    public static String ensureHasValidID(Element element, 
                                          ConsoleHelper console) {
        String id = getNonEmptyAttribute(element, null, "id");

        boolean validId = true;
        if (id == null || !(validId = XMLText.isNmtoken(id))) {
            // DTD ==> ID is a Name; XSD ==> ID is a NCName.
            // The id of a descendant element is a NMTOKEN.

            if (!validId && console != null) {
                console.warning(element, Msg.msg("invalidAttribute", id, "id"));
            }

            id = generateID(element);
            element.setAttributeNS(null, "id", id);
        }

        return id;
    }

    public static String getNonEmptyAttribute(Element element,
                                              String namespace,
                                              String localName) {
        String value = element.getAttributeNS(namespace, localName);
        if (value == null ||
            (value = value.trim()).length() == 0 ||
            // "???" is a placeholder value often used by XMLmind XML Editor.
            "???".equals(value)) {
            value = null;
        }
        return value;
    }

    public static String generateID(Object object) {
        StringBuilder buffer = new StringBuilder("I_");
        buffer.append(Integer.toString(System.identityHashCode(object),
                                       Character.MAX_RADIX));
        buffer.append('_');
        return buffer.toString();
    }

    // -----------------------------------------------------------------------

    /**
     * Find descendant element having specified id attribute.
     * 
     * @param node <em>document</em> or element node being searched
     * @param id value of the id attribute
     * @return found element or <code>nnull</code>
     */
    public static Element findElementById(Node node, String id) {
        Node child = node.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                String value = childElement.getAttributeNS(null, "id");
                if (value != null && value.length() > 0) {
                    value = value.trim();
                    if (value.equals(id)) {
                        return childElement;
                    }
                }

                Element found = findElementById(childElement, id);
                if (found != null) {
                    return found;
                }
            }

            child = child.getNextSibling();
        }

        return null;
    }

    // -----------------------------------------------------------------------

    public static boolean hasClass(Element element, String name) {
        String value = element.getAttributeNS(null, "class");
        if (value != null && value.length() > 0) {
            int pos = value.indexOf(name);
            if (pos >= 0) {
                if (pos == 0 || value.charAt(pos-1) != ' ') {
                    return false;
                }

                pos += name.length();
                if (pos >= value.length() || value.charAt(pos) != ' ') {
                    return false;
                }

                return true;
            } else {
                if (name.startsWith("*/")) {
                    name = name.substring(1);
                    pos = value.indexOf(name);
                    if (pos > 0) {
                        pos += name.length();
                        if (pos >= value.length() || 
                            value.charAt(pos) != ' ') {
                            return false;
                        }

                        return true;
                    }
                }
            }
        }
        return false;
    }

    public static boolean hasClass(Element element, String... classes) {
        for (String cls : classes) {
            if (DITAUtil.hasClass(element, cls)) {
                return true;
            }
        }

        return false;
    }

    public static Element findChildByClass(Element element, String cls) {
        Node child = element.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                if (DITAUtil.hasClass(childElement, cls)) {
                    return childElement;
                }
            }

            child = child.getNextSibling();
        }

        return null;
    }
            
    public static Element findChildByClass(Element element,
                                           int firstClass, 
                                           String... classes) {
        int classCount = classes.length;

        Node child = element.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                for (int i = firstClass; i < classCount; ++i) {
                    if (DITAUtil.hasClass(childElement, classes[i])) {
                        return childElement;
                    }
                }
            }

            child = child.getNextSibling();
        }

        return null;
    }

    public static Element[] findChildrenByClass(Element element, String cls) {
        Element[] found = DOMUtil.NO_ELEMENTS;

        Node child = element.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                if (DITAUtil.hasClass(childElement, cls)) {
                    found = ArrayUtil.append(found, childElement);
                }
            }

            child = child.getNextSibling();
        }

        return found;
    }
            
    public static Element findAncestorByClass(Element element, String cls) {
        while (element != null) {
            if (DITAUtil.hasClass(element, cls)) {
                return element;
            }

            Node parent = element.getParentNode();
            if (parent == null || parent.getNodeType() != Node.ELEMENT_NODE) {
                element = null;
            } else {
                element = (Element) parent;
            }
        }

        return null;
    }
            
    public static Element getParentByClass(Element element, String cls) {
        Node parent = element.getParentNode();
        if (parent != null && 
            parent.getNodeType() == Node.ELEMENT_NODE &&
            DITAUtil.hasClass((Element) parent, cls)) {
            return (Element) parent;
        }

        return null;
    }

    // -----------------------------------------------------------------------

    public static boolean isSpecializedFrom(Element derived, Element base) {
        String derivedClass = getNonEmptyAttribute(derived, null, "class");
        String baseClass = getNonEmptyAttribute(base, null, "class");
        if (derivedClass == null || baseClass == null) {
            return false;
        }

        // Examples:
        //
        // "- topic/ol task/steps " and "- topic/ol " 
        // "+ topic/ph sw-d/filepath " and "- topic/ph "
        //
        // ("-" for element types defined in structural vocabulary modules,
        // "+" for element types defined in domain modules.)

        derivedClass = XMLText.collapseWhiteSpace(derivedClass);
        baseClass = XMLText.collapseWhiteSpace(baseClass);

        return derivedClass.regionMatches(2, baseClass, 2, 
                                          baseClass.length()-2);
    }

    // -----------------------------------------------------------------------

    public static final String[] FILTER_ATTRIBUTES = {
        "rev",
        "audience",
        "platform",
        "product",
        "otherprops",
        "props"
    };

    public static String[] getFilterAttributes(Element element) {
        return getMetaAttributes(element, FILTER_ATTRIBUTES, "a(props");
    }

    public static boolean filterAttributeIsSingle(int index) {
        return (index == 0);
    }

    public static final String[] OTHER_META_ATTRIBUTES = {
        "xml:lang",
        "translate",
        "dir",
        "outputclass",
        "importance",
        "status",
        "base"
    };

    public static boolean otherMetaAttributeIsSingle(int index) {
        return (index < OTHER_META_ATTRIBUTES.length-1);
    }

    public static String[] getOtherMetaAttributes(Element element) {
        return getMetaAttributes(element, OTHER_META_ATTRIBUTES, "a(base");
    }

    private static String[] getMetaAttributes(Element element, 
                                              String[] attrNames,
                                              String specializationPrefix) {
        String domains = null;

        while (element != null) {
            String value = element.getAttributeNS(null, "domains");
            if (value != null && value.length() > 0) {
                domains = value.trim();
                break;
            }
            
            Node parent = element.getParentNode();
            if (parent == null || parent.getNodeType() != Node.ELEMENT_NODE) {
                // Done.
                element = null;
            } else {
                element = (Element) parent;
            }
        }

        String[] allAttrNames = attrNames;

        if (domains != null) {
            int pos = 0;
            for (;;) {
                pos = domains.indexOf(specializationPrefix, pos);
                if (pos < 0) {
                    break;
                }

                pos += 7;
                int start = pos;

                pos = domains.indexOf(')', pos);
                if (pos < 0) {
                    break;
                }

                int end = pos;
                ++pos;

                String[] names = 
                    XMLText.splitList(domains.substring(start, end));
                for (String name : names) {
                    allAttrNames = StringList.append(allAttrNames, name);
                }
            }
        }

        return allAttrNames;
    }

    // -----------------------------------------------------------------------

    public static boolean isValidKey(String s) {
        int count;
        if (s == null || (count = s.length()) == 0) {
            return false;
        }

        // RFC 2396:
        // unreserved  = alphanum | mark
        // mark        = "-" | "_" | "." | "!" | "~" | "*" | "'" | "(" | ")"
        //
        // Note that DITA-excluded characters:
        // "{", "}", "[", "]", "/", "#", "?", whitespace
        // are not part of the above unreserved characters.

        for (int i = 0; i < count; ++i) {
            char c = s.charAt(i);

            switch (c) {
            case '-': case '_': case '.': case '!': case '~': 
            case '*': case '\'': case '(': case ')':
                break;
            default:
                if (!Character.isLetterOrDigit(c)) {
                    return false;
                }
            }
        }

        return true;
    }

    // -----------------------------------------------------------------------

    /**
     * Returns the URL of the topic referenced by specified topicref, if
     * this topic is a local one (that is, format=dita, scope=local).
     * <p>Specified topicref is expected to come from a <i>simple</i> map,
     * where all attributes and metadata have been cascaded.
     */
    public static URL getLocalTopicURL(Element topicref) {
        URL url = null;
        try {
            url = doGetLocalTopicURL(topicref);
        } catch (IllegalArgumentException ignored) {}
        return url;
    }

    public static URL doGetLocalTopicURL(Element topicref) 
        throws IllegalArgumentException {
        String href = DITAUtil.getNonEmptyAttribute(topicref, null, "href");
        if (href == null) {
            return null;
        }

        String scope = DITAUtil.getNonEmptyAttribute(topicref, null, "scope");
        if (scope != null && !"local".equals(scope)) {
            return null;
        }

        String format = DITAUtil.getFormat(topicref, href);
        if (format == null) {
            throw new IllegalArgumentException(Msg.msg("missingAttribute",
                                                       "format"));
        }
        if (!"dita".equals(format)) {
            return null;
        }

        // Remember that LoadedDocuments automatically resolves relative URLs.
        URL url = null;
        try {
            url = URLUtil.createURL(href);
        } catch (MalformedURLException ignored) {
            throw new IllegalArgumentException(Msg.msg("invalidAttribute", 
                                                       href, "href"));
        }

        return url;
    }

    public static String getFormat(Element topicref, String href) {
        String format = DITAUtil.getNonEmptyAttribute(topicref, null, "format");
        if (format == null) {
            if (href != null) {
                format = DITAUtil.guessFormat(href);
            }
        } else {
            format = format.toLowerCase();
        }
        return format;
    }

    /**
     * Returns the lower-case DITA format (dita, ditamap, html, etc) 
     * corresponding to the file extension of specified relative or 
     * absolute URL. Returns <code>null</code> if such format cannot 
     * be determined.
     */
    public static String guessFormat(String href) {
        String format = null;

        href = URIComponent.setFragment(href, null);
        if (href.length() > 0) {
            String ext = URIComponent.getExtension(href);
            if (ext != null && (ext = ext.trim()).length() > 0) {
                format = ext.toLowerCase();

                if ("xml".equals(format)) {
                    format = "dita";
                } else if ("htm".equals(format) ||
                           "shtml".equals(format) ||
                           "xhtml".equals(format)) {
                    format = "html";
                } 
                // Otherwise, use ext as is.
            }

            if (format == null &&
                (href.startsWith("http://") ||
                 href.startsWith("https://"))) {
                format = "html";
            }
        }
        // Otherwise, href is a pure fragment: cannot really guess the format.

        return format;
    }

    /**
     * Returns the topic ID referenced in the fragment of specified URL.
     * Returns <code>null</code> if there is no such ID.
     * <p>Example returns <tt>foo</tt> for 
     * <tt>file:///tmp/bar.dita#foo/gee</tt>.
     */
    public static String getTopicId(URL url) {
        String fragment = URLUtil.getFragment(url);
        if (fragment != null) {
            int pos = fragment.lastIndexOf('/');
            if (pos > 0 && pos+1 < fragment.length()) {
                fragment = fragment.substring(0, pos);
            }
        }
        return fragment;
    }

    // -----------------------------------------------------------------------

    public static String inheritFormat(Element topicref, String href) {
        String format = inheritAttribute(topicref, null, "format");
        if (format == null) {
            if (href != null) {
                format = DITAUtil.guessFormat(href);
            }
        } else {
            format = format.toLowerCase();
        }
        return format;
    }

    public static String inheritAttribute(Element element, String namespace, 
                                           String localName) {
        int cellIndex = -1;

        while (element != null) {
            if (cellIndex >= 0 && DITAUtil.hasClass(element, "map/reltable")) {
                Element header = 
                    DITAUtil.findChildByClass(element, "map/relheader");
                if (header != null) {
                    Element colspec =
                        DOMUtil.getNthChildElement(header, cellIndex);
                    if (colspec != null) {
                        String value = 
                            colspec.getAttributeNS(namespace, localName);
                        if (value != null && value.length() > 0) {
                            return value;
                        }
                    }
                }
            }

            String value = element.getAttributeNS(namespace, localName);
            if (value != null && value.length() > 0) {
                return value;
            }

            if (DITAUtil.hasClass(element, "map/relcell")) {
                cellIndex = DOMUtil.indexOfChildElement(element);
            }

            element = DOMUtil.getParentElement(element);
        }

        // This differs from getAttributeNS which returns "" and not null!
        return null;
    }

    // -----------------------------------------------------------------------

    public static String getSubRole(String role) {
        if ("part".equals(role)) {
            return "chapter";
        } else if ("chapter".equals(role)) {
            return "section1";
        } else if ("section1".equals(role)) {
            return "section2";
        } else if ("section2".equals(role)) {
            return "section3";
        } else if ("section3".equals(role)) {
            return "section4";
        } else if ("section4".equals(role)) {
            return "section5";
        } else if ("section5".equals(role)) {
            return "section6";
        } else if ("section6".equals(role)) {
            return "section7";
        } else if ("section7".equals(role)) {
            return "section8";
        } else if ("section8".equals(role)) {
            return "section9";
        } else if ("section9".equals(role)) {
            return "section9";
        } else if ("appendices".equals(role)) {
            return "appendix";
        } else {
            // Fallback.
            return "section1";
        }
    }

    // -----------------------------------------------------------------------

    private static Boolean checkDomains;

    public static boolean checkDomains(String superset, String subset) {
        if (checkDomains == null) {
            String prop = System.getProperty("DITAC_CHECK_DOMAINS");
            checkDomains = ((prop != null && prop.length() > 0)? 
                             Boolean.TRUE : Boolean.FALSE);
        }

        if (checkDomains == Boolean.TRUE) {
            return doCheckDomains(superset, subset);
        } else {
            return true;
        }
    }

    public static boolean doCheckDomains(String superset, String subset) {
        superset = XMLText.collapseWhiteSpace(superset);
        subset = XMLText.collapseWhiteSpace(subset);

        if (superset.equals(subset) || superset.indexOf(subset) >= 0) {
            return true;
        }

        String[] supersetList = splitDomains(superset);
        String[] subsetList = splitDomains(subset);

        for (String domain1 : subsetList) {
            String domain2 = findDomain(supersetList, domain1);
            if (domain2 == null ||
                !domainIsLessConstrainedThan(domain2, domain1)) {
                return false;
            }
        }

        return true;
    }

    private static String[] splitDomains(String domains) {
        ArrayList<String> list = new ArrayList<String>();

        int count = domains.length();
        int start = -1;
            
        for (int i = 0; i < count; ++i) {
            char c = domains.charAt(i);

            switch (c) {
            case '(':
                // Ignore attribute domains such as "a(props new)".
                if (i == 0 || domains.charAt(i-1) != 'a') {
                    start = i;
                }
                break;
            case ')':
                if (start >= 0) {
                    if (i - start > 1) {
                        list.add(domains.substring(start, i+1));
                    }
                    start = -1;
                }
                break;
            }
        }

        String[] parts = new String[list.size()];
        list.toArray(parts);

        return parts;
    }

    private static String findDomain(String[] list, String domain) {
        for (String item : list) {
            if (item.equals(domain)) {
                return item;
            }
        }

        String[] domainParts = splitDomain(domain);

        for (String item : list) {
            String[] itemParts = splitDomain(item);

            boolean foundDomainParts = true;

            for (String domainPart : domainParts) {
                if (!domainPart.endsWith("-c")) {
                    boolean foundDomainPart = false;

                    for (String itemPart : itemParts) {
                        if (itemPart.equals(domainPart)) {
                            foundDomainPart = true;
                            break;
                        }
                    }

                    if (!foundDomainPart) {
                        foundDomainParts = false;
                        break;
                    }
                }
            }

            if (foundDomainParts) {
                return item;
            }
        }

        return null;
    }

    private static String[] splitDomain(String domain) {
        assert(domain.length() > 2);
        assert(domain.charAt(0) == '(');
        assert(domain.charAt(domain.length()-1) == ')');

        return StringUtil.split(domain.substring(1, domain.length()-1), ' ');
    }

    private static boolean domainIsLessConstrainedThan(String less,
                                                       String more) {
        if (less.indexOf("-c") < 0) {
            return true;
        }

        String[] lessParts = splitDomain(less);
        String[] moreParts = splitDomain(more);

        for (String lessPart : lessParts) {
            if (lessPart.endsWith("-c")) {
                boolean foundLessPart = false;

                for (String morePart : moreParts) {
                    if (morePart.equals(lessPart)) {
                        foundLessPart = true;
                        break;
                    }
                }

                if (!foundLessPart) {
                    return false;
                }
            }
        }

        return true;
    }

    public static void main(String[] args) {
        for (int i = 0; i < args.length; i += 2) {
            String superset = args[i];
            String subset = args[i+1];

            System.out.print('"');
            System.out.print(superset);
            System.out.print("\" is a superset of \"");
            System.out.print(subset);
            System.out.print("\": ");
            System.out.println(DITAUtil.doCheckDomains(superset, subset)? 
                               "yes" : "NO");
        }
    }
}

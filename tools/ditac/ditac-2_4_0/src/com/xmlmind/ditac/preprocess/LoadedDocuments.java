/*
 * Copyright (c) 2010-2013 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.preprocess;

import java.io.IOException;
import java.io.File;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Iterator;
import java.util.HashMap;
import org.w3c.dom.Node;
import org.w3c.dom.ProcessingInstruction;
import org.w3c.dom.Attr;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Element;
import org.w3c.dom.Document;
import com.xmlmind.util.ObjectUtil;
import com.xmlmind.util.StringList;
import com.xmlmind.util.StringUtil;
import com.xmlmind.util.FileUtil;
import com.xmlmind.util.URIComponent;
import com.xmlmind.util.URLUtil;
import com.xmlmind.util.XMLText;
import com.xmlmind.util.Console;
import com.xmlmind.ditac.util.SimpleConsole;
import com.xmlmind.ditac.util.ConsoleHelper;
import com.xmlmind.ditac.util.LoadDocument;
import com.xmlmind.ditac.util.DOMUtil;
import com.xmlmind.ditac.util.DITAUtil;
import com.xmlmind.ditac.util.Resolve;
import static com.xmlmind.ditac.preprocess.CascadeMeta.TOPICMETA_ELEMENTS;
import static com.xmlmind.ditac.preprocess.CascadeMeta.CASCADED_ELEMENTS;
import static com.xmlmind.ditac.preprocess.CascadeMeta.CASCADED_ELEMENT_SINGLE;

/*package*/ class LoadedDocuments implements Constants {
    private Keys keys;
    private ConsoleHelper console;
    private HashMap<URL, LoadedDocument> docs;

    // -----------------------------------------------------------------------

    public LoadedDocuments() {
        this(null, null);
    }

    public LoadedDocuments(Keys keys, Console console) {
        docs = new HashMap<URL, LoadedDocument>();
        setKeys(keys);
        setConsole(console);
    }

    public void setKeys(Keys keys) {
        this.keys = keys;
    }

    /**
     * Returns the key space which is to be used to resolve conkeyrefs and
     * keyrefs. May return <code>null</code>.
     */
    public Keys getKeys() {
        return keys;
    }

    public void setConsole(Console c) {
        if (c == null) {
            c = new SimpleConsole();
        }
        this.console = ((c instanceof ConsoleHelper)? 
                        (ConsoleHelper) c : new ConsoleHelper(c));
    }

    public ConsoleHelper getConsole() {
        return console;
    }

    public  LoadedDocument load(File file) 
        throws IOException {
        return load(file, true);
    }

    public  LoadedDocument load(File file, boolean process) 
        throws IOException {
        return load(FileUtil.fileToURL(file), process);
    }

    public LoadedDocument load(URL url)
        throws IOException {
        return load(url, true);
    }

    public LoadedDocument load(URL url, boolean process)
        throws IOException {
        if (url.getRef() != null) {
            url = URLUtil.setFragment(url, null);
        }

        LoadedDocument doc = docs.get(url);
        if (doc == null) {
            console.info(Msg.msg("loadingDoc", URLUtil.toLabel(url)));
            Document loaded = LoadDocument.load(url);

            try {
                doc = put(url, loaded, process);
            } catch (IllegalArgumentException e) {
                throw new IOException(e.getMessage());
            }

            // Not a fatal error.
            checkDITAVersion(doc);
        }
        return doc;
    }

    public LoadedDocument put(URL url, Document loaded, boolean process) {
        if (url.getRef() != null) {
            url = URLUtil.setFragment(url, null);
        }

        LoadedDocument doc = createLoadedDocument(url, loaded);
        // Preload all topics.
        doc.getTopics(console);

        docs.put(url, doc);
        
        if (process) {
            process(loaded, url);
        }

        return doc;
    }

    protected LoadedDocument createLoadedDocument(URL url, Document doc) {
        return new LoadedDocument(url, doc);
    }

    public LoadedDocument get(URL url) {
        if (url.getRef() != null) {
            url = URLUtil.setFragment(url, null);
        }

        return docs.get(url);
    }

    public int size() {
        return docs.size();
    }

    public Iterator<LoadedDocument> iterator() {
        return docs.values().iterator();
    }

    // -----------------------------------------------------------------------

    private final boolean checkDITAVersion(LoadedDocument loadedDoc) {
        boolean checked = true;

        if (loadedDoc.type == LoadedDocument.Type.MULTI_TOPIC) {
            Element root = loadedDoc.document.getDocumentElement();

            Node child = root.getFirstChild();
            while (child != null) {
                if (child.getNodeType() == Node.ELEMENT_NODE) {
                    if (!checkDITAVersion((Element) child)) {
                        checked = false;
                    }
                }

                child = child.getNextSibling();
            }
        } else {
            checked = checkDITAVersion(loadedDoc.document.getDocumentElement());
        }

        return checked;
    }

    private static final String[] SUPPORTED_VERSIONS = {
        "1.0", "1.1", "1.2"
    };

    private final boolean checkDITAVersion(Element element) {
        String version = element.getAttributeNS(
            "http://dita.oasis-open.org/architecture/2005/", 
            "DITAArchVersion");
        if (version == null || (version = version.trim()).length() == 0) {
            console.error(element, Msg.msg("missingAttribute",
                                           "ditaarch:DITAArchVersion"));
            return false;
        } else {
            boolean supported = false;
            for (int i = 0; i < SUPPORTED_VERSIONS.length; ++i) {
                if (SUPPORTED_VERSIONS[i].equals(version)) {
                    supported = true;
                    break;
                }
            }
            if (!supported) {
                console.warning(element, 
                                Msg.msg("unsupportedDITAVersion",
                                        version,
                                        StringUtil.join(", ",
                                                        SUPPORTED_VERSIONS)));
            }
            return true;
        }
    }

    private final void process(Node tree, URL baseURL) {
        Node child = tree.getFirstChild();
        while (child != null) {
            Node next = child.getNextSibling();

            switch (child.getNodeType()) {
            case Node.ELEMENT_NODE:
                if (DITAUtil.hasDITANamespace(child)) { // Skip SVG and MathML.
                    Element childElement = (Element) child;

                    // Make sure that certain elements have an ID ---

                    ensureHasValidID(childElement);

                    // Use absolute URLs everywhere --- 
                    // This avoids adding xml:base attributes during the
                    // transclusion step
                    // Ignore navref/@mapref.

                    String value = 
                        DITAUtil.getNonEmptyAttribute(childElement,
                                                      null, "conref");
                    if (value != null) {
                        resolveHref(childElement, "conref", value, baseURL);
                    }

                    value = DITAUtil.getNonEmptyAttribute(childElement,
                                                          null, "conrefend");
                    if (value != null) {
                        resolveHref(childElement, "conrefend", value, baseURL);
                    }

                    value = DITAUtil.getNonEmptyAttribute(childElement,
                                                          null, "href");
                    if (value != null) {
                        resolveHref(childElement, "href", value, baseURL);
                    }

                    // Substitute keyref ---

                    if (keys != null) {
                        value = 
                            DITAUtil.getNonEmptyAttribute(childElement,
                                                          null, "conkeyref");
                        if (value != null) {
                            resolveConkeyref(childElement, value);
                        }

                        value = DITAUtil.getNonEmptyAttribute(childElement,
                                                              null, "keyref");
                        if (value != null) {
                            processKeyref(childElement, value);
                        }
                    }

                    if (DITAUtil.hasClass(childElement, "topic/object")) {
                        resolveObjectURLs(childElement, baseURL);
                    }

                    process(childElement, baseURL);
                }
                break;

            case Node.PROCESSING_INSTRUCTION_NODE:
                if ("onclick".equals(
                        ((ProcessingInstruction) child).getTarget())) {
                    Element parent = DOMUtil.getParentElement(child);
                    if (parent != null) {
                        DITAUtil.ensureHasValidID(parent, console);
                    }
                }
                break;
            }

            child = next;
        }
    }

    private static final String[] ANCHOR_ELEMENTS = {
        "topic/section", 	// For toc
        "topic/table", 		// For tablelist
        "topic/fig", 		// For figurelist
        "topic/example", 	// For ditac:exampleList
        "topic/indexterm" 	// For indexlist
    };
    private static final int ANCHOR_ELEMENT_COUNT = ANCHOR_ELEMENTS.length;

    private final void ensureHasValidID(Element element) {
        if (DITAUtil.hasClass(element, "topic/topic")) {
            DITAUtil.ensureHasValidID(element, console);
        } else { // Not a topic
            for (int i = 0; i < ANCHOR_ELEMENT_COUNT; ++i) {
                if (DITAUtil.hasClass(element, ANCHOR_ELEMENTS[i])) {
                    DITAUtil.ensureHasValidID(element, console);
                    break;
                }
            }
        }
    }

    private static final void resolveObjectURLs(Element element, URL baseURL) {
        // Get rid of codebase ---

        URL codebase = null;

        String location = DITAUtil.getNonEmptyAttribute(element,
                                                        null, "codebase");
        // No longer useful.
        element.removeAttributeNS(null, "codebase");

        if (location != null) {
            try {
                codebase = Resolve.resolveURI(location, baseURL);
            } catch (MalformedURLException ignored) {}
        }

        // Resolve URLs ---

        location = DITAUtil.getNonEmptyAttribute(element, null, "classid");
        if (location != null) {
            if (location.startsWith("clsid:")) {
                // Mark as absolute URL.
                element.setAttributeNS(DITAC_NS_URI, 
                                       DITAC_PREFIX + "absoluteClassid",
                                       "true");
            } else {
                resolveObjectURL(element, "classid", location,
                                 codebase, baseURL);
            }
        }
        
        location = DITAUtil.getNonEmptyAttribute(element, null, "data");
        if (location != null) {
            resolveObjectURL(element, "data", location, codebase, baseURL);
        }
        
        location = DITAUtil.getNonEmptyAttribute(element, null, "archive");
        if (location != null) {
            resolveObjectURLs(element, "archive", location, codebase, baseURL);
        }
        
        for (Element param :
             DITAUtil.findChildrenByClass(element, "topic/param")) {
            String name = DITAUtil.getNonEmptyAttribute(param, null, "name");
            if ("source.src".equals(name)) {
                location = DITAUtil.getNonEmptyAttribute(param, null, "value");
                if (location != null) {
                    resolveObjectURL(param, "value", location, 
                                     /*codebase*/ null, baseURL);
                }
            } else if ("poster".equals(name)) {
                location = DITAUtil.getNonEmptyAttribute(param, null, "value");
                if (location != null) {
                    resolveObjectURL(param, "value", location, 
                                     /*codebase*/ null, baseURL);
                }
            } else if ("movie".equals(name)) {
                String type = 
                    DITAUtil.getNonEmptyAttribute(element, null, "type");

                location = DITAUtil.getNonEmptyAttribute(param, null, "value");
                if (location != null &&
                    ((location.toLowerCase().endsWith(".swf")) || 
                     (type != null && 
                     type.equalsIgnoreCase("application/x-shockwave-flash")))) {
                    resolveObjectURL(param, "value", location, 
                                     /*codebase*/ null, baseURL);
                }
            }
        }
    }

    private static final void resolveObjectURLs(Element element, 
                                                String attrName, 
                                                String attrValue, 
                                                URL codebase, URL baseURL) {
        String[] hrefs = XMLText.splitList(attrValue);
        int hrefCount = hrefs.length;
        String[] absoluteFlags = new String[hrefCount];

        for (int i = 0; i < hrefCount; ++i) {
            String href = hrefs[i];
            href = joinObjectURL(codebase, href);

            absoluteFlags[i] = "false";

            if (href.startsWith("#")) {
                href = baseURL.toExternalForm() + href;
            } else {
                boolean resolve = true;

                // Absolute URL?
                try {
                    URL url = Resolve.resolveURI(href, null);
                    href = url.toExternalForm();
                    resolve = false;

                    absoluteFlags[i] = "true";
                } catch (MalformedURLException ignored) {}

                if (resolve) {
                    // Relative URL?
                    try {
                        URL url = URLUtil.createURL(baseURL, href);
                        href = url.toExternalForm();
                    } catch (MalformedURLException ignored) {}
                }
            }

            hrefs[i] = href;
        }

        element.setAttributeNS(null, attrName, StringUtil.join(' ', hrefs));
        // Mark absolute URLs.
        element.setAttributeNS(
            DITAC_NS_URI,
            DITAC_PREFIX + "absolute" + StringUtil.capitalize(attrName), 
            StringUtil.join(' ', absoluteFlags));
    }

    private static final void resolveObjectURL(Element element, 
                                               String attrName, 
                                               String attrValue, 
                                               URL codebase, URL baseURL) {
        attrValue = joinObjectURL(codebase, attrValue);
        String href = attrValue;

        if (attrValue.startsWith("#")) {
            href = baseURL.toExternalForm() + attrValue;
        } else {
            boolean resolve = true;

            // Absolute URL?
            try {
                URL url = Resolve.resolveURI(attrValue, null);
                href = url.toExternalForm();
                resolve = false;

                // Mark absolute URLs.
                element.setAttributeNS(
                    DITAC_NS_URI, 
                    DITAC_PREFIX + "absolute" + StringUtil.capitalize(attrName),
                    "true");
            } catch (MalformedURLException ignored) {}

            if (resolve) {
                // Relative URL?
                try {
                    URL url = URLUtil.createURL(baseURL, attrValue);
                    href = url.toExternalForm();
                } catch (MalformedURLException ignored) {}
            }
        }

        element.setAttributeNS(null, attrName, href);
    }

    private static final String joinObjectURL(URL codebase, String path) {
        if (codebase != null) {
            try {
                URL url = URLUtil.createURL(codebase, path);
                path = url.toExternalForm();
            } catch (MalformedURLException ignored) {}
        }
        return path;
    }

    private static final void resolveHref(Element element, 
                                          String attrName, String attrValue, 
                                          URL baseURL) {
        String href = attrValue;

        if (attrValue.startsWith("#")) {
            href = baseURL.toExternalForm() + attrValue;
        } else {
            boolean resolve = true;

            // Absolute URL?
            try {
                URL url = Resolve.resolveURI(attrValue, null);
                // This allows to cope with URIs making using of advanced
                // features of XML catalogs.
                href = url.toExternalForm();
                resolve = false;

                if (attrName.equals("href")) {
                    // Mark absolute hrefs.
                    element.setAttributeNS(DITAC_NS_URI, ABSOLUTE_HREF_QNAME,
                                           "true");
                }
            } catch (MalformedURLException ignored) {}

            String scope;
            if (resolve &&
                attrName.equals("href") &&
                (scope = 
                 DITAUtil.inheritAttribute(element, null, "scope")) != null &&
                !"local".equals(scope) &&
                !DITAUtil.hasClass(element, "topic/image")) {
                // Unless the element is an image, do not resolve an href
                // pointing to a peer or external resource.
                href = attrValue;
                resolve = false;
            }

            if (resolve) {
                // Relative URL?
                
                // Also performed on @scope other than "local" and
                // on @format other than "dita" and "ditamap",
                // but we do not care.

                try {
                    URL url = URLUtil.createURL(baseURL, attrValue);
                    href = url.toExternalForm();
                } catch (MalformedURLException ignored) {}
            }
        }

        element.setAttributeNS(null, attrName, href);
    }

    private final void resolveConkeyref(Element element, String attrValue) {
        element.removeAttributeNS(null, "conkeyref");

        String[] split = splitKeyref(element, "conkeyref", attrValue);
        if (split == null) {
            return;
        }
        String key = split[0];
        String id = split[1];

        String resolved = keys.getHref(key);
        if (resolved != null) {
            resolved = addIdToHref(resolved, id);

            // Add or replace conref.
            element.setAttributeNS(null, "conref", resolved);
        } else {
            if (DITAUtil.getNonEmptyAttribute(element,null,"conref") != null) {
                console.warning(element, 
                                Msg.msg("cannotResolveKeyref", 
                                        "conkeyref", attrValue, "conref"));
            } else {
                console.warning(element, 
                                Msg.msg("cannotResolveKeyref2",
                                        "conkeyref", attrValue, "conref"));
            }
        }
    }

    private final String[] splitKeyref(Element element,
                                       String attrName, String attrValue) {
        String key, id;
        int pos = attrValue.indexOf('/');
        if (pos < 0) {
            key = attrValue;
            id = null;
        } else {
            key = attrValue.substring(0, pos);
            id = attrValue.substring(pos+1);
        }

        if (!DITAUtil.isValidKey(key) ||
            (id != null && !XMLText.isNmtoken(id))) {
            console.error(element,
                          Msg.msg("invalidAttribute", attrValue, attrName));
            return null;
        }
        
        return new String[] { key, id };
    }

    private static final String addIdToHref(String href, String id) {
        if (id != null) {
            if (URIComponent.getRawFragment(href) != null) {
                href += "/" + URIComponent.quoteFragment(id);
            } else {
                href += "#" + URIComponent.quoteFragment(id);
            }
        }

        return href;
    }

    private static final String[] LINKING_ATTRIBUTES = {
        null, "href", "href", // Must be first item
        null, "scope", "scope",
        null, "format", "format",
        DITAC_NS_URI, ABSOLUTE_HREF_QNAME, ABSOLUTE_HREF_NAME 
    };

    private final void processKeyref(Element element, String attrValue) {
        element.removeAttributeNS(null, "keyref");

        String[] split = splitKeyref(element, "keyref", attrValue);
        if (split == null) {
            return;
        }
        String key = split[0];
        String id = split[1];

        Keys.Entry entry = keys.getEntry(key);
        if (entry == null) {
            if (DITAUtil.getNonEmptyAttribute(element, null, "href") != null) {
                console.warning(element, 
                                Msg.msg("cannotResolveKeyref", 
                                        "keyref", attrValue, "href"));
            } else {
                console.warning(element, 
                                Msg.msg("cannotResolveKeyref2",
                                        "keyref", attrValue, "href"));
            }
            return;
        }

        // Replace @keyref by @href and its companion linking attributes ---

        String href = entry.getAttribute(null, "href");
        if (href != null &&
            "none".equals(entry.getAttribute(null, "linking"))) {
            href = null;
        }

        if (href != null) {
            // Replace @href and its companion linking attributes.

            href = addIdToHref(href, id);

            for (int i = 0; i < LINKING_ATTRIBUTES.length; i += 3) {
                String ns = LINKING_ATTRIBUTES[i];
                String qName = LINKING_ATTRIBUTES[i+1];
                String localName = LINKING_ATTRIBUTES[i+2];

                String value;
                if (i == 0) {
                    value = href;
                } else {
                    value = entry.getAttribute(ns, localName);
                }
                if (value == null) {
                    element.removeAttributeNS(ns, localName);
                } else {
                    element.setAttributeNS(ns, qName, value);
                }
            }
        } else {
            // Remove @href and its companion linking attributes.

            for (int i = 0; i < LINKING_ATTRIBUTES.length; i += 3) {
                String ns = LINKING_ATTRIBUTES[i];
                String localName = LINKING_ATTRIBUTES[i+2];

                element.removeAttributeNS(ns, localName);
            }
        }

        // Inject content coming from the key definition ---

        if (DITAUtil.hasClass(element, "map/topicref")) {
            addContent2(entry, element);
        } else {
            addContent(entry, element);
        }

        // Remove void elements ---

        if (href == null && !DOMUtil.hasContent(element)) {
            element.getParentNode().removeChild(element);
        }
    }
    
    // "glossentry/glossAlternateFor" is a "topic/xref".
    // "abbrev-d/abbreviated-form" is a "topic/term".
    private static final String[] VARIABLE_ELEMENTS = {
        "topic/dt",
        "topic/cite",
        "topic/term",
        "topic/keyword",
        "topic/ph"
    };

    private final void addContent(Keys.Entry entry, Element element) {
        // XXE creates link element containing an empty linktext child.
        // Get rid of these empty child elements.
        boolean isLink = DITAUtil.hasClass(element, "topic/link");
        if (isLink) {
            Element child = 
                DITAUtil.findChildByClass(element, "topic/linktext");
            if (child != null && !DOMUtil.hasContent(child)) {
                element.removeChild(child);
            }
            
            child = DITAUtil.findChildByClass(element, "topic/desc");
            if (child != null && !DOMUtil.hasContent(child)) {
                element.removeChild(child);
            }
        }

        if (!DOMUtil.hasContent(element)) {
            Element meta = entry.getMeta();
            if (meta != null) {
                // LIMITATION: matching element content taken from a key
                // definition is limited to the following cases:

                if (isLink) {
                    Element linktext = 
                        DITAUtil.findChildByClass(meta, "map/linktext");
                    if (linktext != null) {
                        Element copy = copyElement(linktext, 
                                                  "linktext", "topic/linktext",
                                                  element.getOwnerDocument());
                        element.appendChild(copy);
                    }

                    Element shortdesc = 
                        DITAUtil.findChildByClass(meta, "map/shortdesc");
                    if (shortdesc != null) {
                        Element copy = copyElement(shortdesc, 
                                                   "desc", "topic/desc", 
                                                   element.getOwnerDocument());
                        element.appendChild(copy);
                    }
                } else if (DITAUtil.hasClass(element, "topic/xref")) {
                    Element linktext = 
                        DITAUtil.findChildByClass(meta, "map/linktext");
                    if (linktext != null) {
                        DOMUtil.copyChildren(linktext, element, 
                                             element.getOwnerDocument());
                    }
                } else {
                    if (DITAUtil.hasClass(element, VARIABLE_ELEMENTS)) {
                        Element container = null;

                        Element keywords = 
                            DITAUtil.findChildByClass(meta, "topic/keywords");
                        if (keywords != null) {
                            container = 
                                DITAUtil.findChildByClass(keywords, 
                                                          "topic/keyword");
                        }

                        if (container == null) {
                            container =
                              DITAUtil.findChildByClass(meta, "map/linktext");
                        }

                        if (container != null) {
                            DOMUtil.copyChildren(container, element, 
                                                 element.getOwnerDocument());
                        }
                    }
                }
            }
        }
    }

    private static final Element copyElement(Element from, 
                                             String toQName, String toClass, 
                                             Document doc) {
        Element to = doc.createElementNS(null, toQName);

        NamedNodeMap attrs = from.getAttributes();
        int attrCount = attrs.getLength();

        for (int i = 0; i < attrCount; ++i) {
            Attr attr = (Attr) attrs.item(i);

            to.setAttributeNS(attr.getNamespaceURI(), /*qName*/ attr.getName(),
                              attr.getValue());
        }

        to.setAttributeNS(null, "class", "- " + toClass + " ");

        DOMUtil.copyChildren(from, to, doc);

        return to;
    }

    private final void addContent2(Keys.Entry entry, Element element) {
        // NOT CONFORMING: we do not really understand the spec.

        // Add the attributes found in entry.element.
        // However give priority to those already found in element.
        // (Like what happens when processing a conref.)

        NamedNodeMap attrs = entry.element.getAttributes();
        int attrCount = attrs.getLength();

        for (int j = 0; j < attrCount; ++j) {
            Attr attr = (Attr) attrs.item(j);

            String ns = attr.getNamespaceURI();
            String attrQName = attr.getName();

            boolean add;
            if ("xml:lang".equals(attrQName) ||
                "dir".equals(attrQName) ||
                "translate".equals(attrQName)) {
                // Always taken from the key definition (where they have been
                // properly cascaded).
                add = true;
            } else if ("keys".equals(attrQName) ||
                       "processing-role".equals(attrQName) ||
                       "id".equals(attrQName)) {
                // Never taken from the key definition.
                add = false;
            } else {
                String attrLocalName = attr.getLocalName();

                add = true;
                for (int i = 0; i < LINKING_ATTRIBUTES.length; i += 3) {
                    if (ObjectUtil.equals(LINKING_ATTRIBUTES[i], ns) &&
                        LINKING_ATTRIBUTES[i+2].equals(attrLocalName)) {
                        // This attribute has already been processed
                        // earlier in processKeyref.
                        add = false;
                        break;
                    }
                }

                if (add) {
                    add = (DITAUtil.getNonEmptyAttribute(element, ns, 
                                                        attrLocalName) == null);
                }
            }
            
            if (add) {
                element.setAttributeNS(ns, attrQName, attr.getValue());
            }
        }

        // Combine metadata ---

        Element srcMeta = entry.getMeta();
        if (srcMeta != null) {
            Element dstMeta = 
                DITAUtil.findChildByClass(element, "map/topicmeta");

            // Lockmeta=no means priority to what's found in the key
            // definition.
            // By default, lockmeta=yes which means priority to what's found
            // in the topicref referencing the key definition.

            boolean lockmeta = true;
            if (dstMeta != null &&
                "no".equals(DITAUtil.getNonEmptyAttribute(dstMeta, 
                                                          null, "lockmeta"))) {
                lockmeta = false;
            }

            Document doc = element.getOwnerDocument();

            if (dstMeta == null) {
                dstMeta = doc.createElementNS(null, "topicmeta");
                dstMeta.setAttributeNS(null, "class", "- map/topicmeta ");

                element.insertBefore(dstMeta, element.getFirstChild());
            }

            Node child = srcMeta.getFirstChild();
            while (child != null) {
                if (child.getNodeType() == Node.ELEMENT_NODE) {
                    Element childElement = (Element) child;

                    String cls = null;
                    boolean single = false;

                    for (int k = 0; k < CASCADED_ELEMENTS.length; ++k) {
                        String c = CASCADED_ELEMENTS[k];

                        if (DITAUtil.hasClass(childElement, c)) {
                            cls = c;
                            single = CASCADED_ELEMENT_SINGLE[k];
                            break;
                        }
                    }

                    if (cls != null) {
                        Element existing = 
                            DITAUtil.findChildByClass(dstMeta, cls);

                        if (!single || existing == null) {
                            Element before = DITAUtil.findChildByClass(
                                dstMeta,
                                StringList.indexOf(TOPICMETA_ELEMENTS, 
                                                   cls), 
                                TOPICMETA_ELEMENTS);
                            insertBefore(dstMeta, childElement, before, doc);
                        } else {
                            // single && existing != null

                            if (!lockmeta) {
                                replaceChild(dstMeta, childElement, existing,
                                             doc);
                            }
                        }
                    }
                }

                child = child.getNextSibling();
            }
        }
    }

    private static final void insertBefore(Element parent, Element newChild, 
                                           Element before, Document doc) {
        Node copy = doc.importNode(newChild, /*deep*/ true);
        parent.insertBefore(copy, before);
    }

    private static final void replaceChild(Element parent, Element newChild, 
                                           Element oldChild, Document doc) {
        Node copy = doc.importNode(newChild, /*deep*/ true);
        parent.replaceChild(copy, oldChild);
    }

    // -----------------------------------------------------------------------

    public static void main(String[] args) throws Exception {
        Keys keys = null;
        boolean usage = false;

        int i = 0;
        for (; i < args.length; ++i) {
            String arg = args[i];

            if ("-k".equals(arg)) {
                if (i+1 >= args.length) {
                    usage = true;
                    break;
                }

                File mapFile = new File(args[++i]);
                
                KeysLoader keysLoader = new KeysLoader();
                if (!keysLoader.loadMap(mapFile)) {
                    System.exit(2);
                }
                keys = keysLoader.createKeys();
            } else {
                if (arg.startsWith("-")) {
                    usage = true;
                }
                break;
            }
        }

        if (!usage && i+2 != args.length) {
            usage = true;
        }

        if (usage) {
            System.err.println(
                "usage: java com.xmlmind.ditac.preprocess.LoadedDocuments" +
                " [ -k map_file ] in_xml_file out_xml_file");
            System.exit(1);
        }

        File inFile = new File(args[i]);
        File outFile = new File(args[i+1]);

        LoadedDocuments loadedDocs = new LoadedDocuments(keys, null);
        LoadedDocument loadedDoc = loadedDocs.load(inFile.toURI().toURL());

        LoadedTopic[] topics = loadedDoc.getTopics();
        if (topics != null) {
            System.out.println("Topics:");
            listTopics(topics, 0);
        }

        com.xmlmind.ditac.util.SaveDocument.save(loadedDoc.document, outFile);
    }

    private static final void listTopics(LoadedTopic[] topics, int indent) {
        for (int i = 0; i < topics.length; ++i) {
            LoadedTopic topic = topics[i];

            int count = indent;
            while (count > 0) {
                System.out.print(' ');
                --count;
            }
            System.out.println(topic.topicId);

            LoadedTopic[] subTopics = topic.topics;
            if (subTopics != null) {
                listTopics(subTopics, indent+4);
            }
        }
    }
}

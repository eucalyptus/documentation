/*
 * Copyright (c) 2009-2012 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.preprocess;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.Iterator;
import java.util.Map;
import java.util.IdentityHashMap;
import java.util.List;
import java.util.ArrayList;
import org.w3c.dom.Node;
import org.w3c.dom.Element;
import org.w3c.dom.Document;
import com.xmlmind.util.ArrayUtil;
import com.xmlmind.util.URIComponent;
import com.xmlmind.util.URLUtil;
import com.xmlmind.util.Console;
import com.xmlmind.ditac.util.DOMUtil;
import com.xmlmind.ditac.util.DITAUtil;
import com.xmlmind.ditac.util.SimpleConsole;
import com.xmlmind.ditac.util.ConsoleHelper;

/*package*/ final class LinkGenerator {
    private enum Linking {
        NONE,
        SOURCE_ONLY,
        TARGET_ONLY,
        NORMAL
    }

    private static final class Entry {
        // Whether external or local scope.
        public final String href;
        public final String scope;
        public final String format;
        public final Linking linking;
        public final Element linktext;
        public final Element shortdesc;

        // Points to or inside this topic.
        public final String topicId;
        public final String elementId;
        public final Element topic;

        public Entry(String href, String scope, String format,
                     Linking linking, Element linktext, Element shortdesc,
                     String topicId, String elementId, Element topic) {
            this.href = href;
            this.scope = scope;
            this.format = format;
            this.linking = linking;
            this.linktext = linktext;
            this.shortdesc = shortdesc;

            this.topicId = topicId;
            this.elementId = elementId;
            this.topic = topic;
        }

        @Override
        public boolean equals(Object other) {
            if (other == null || !(other instanceof Entry)) {
                return false;
            }
            return href.equals(((Entry) other).href);
        }
    }

    // -----------------------------------------------------------------------

    private enum CollectionType {
        SEQUENCE,
        FAMILY,
        CHOICE,
        UNORDERED;

        public static CollectionType fromString(String spec) {
            if ("sequence".equals(spec)) {
                return SEQUENCE;
            } else if ("family".equals(spec)) {
                return FAMILY;
            } else if ("choice".equals(spec)) {
                return CHOICE;
            } else if ("unordered".equals(spec)) {
                return UNORDERED;
            } else {
                return null;
            }
        }

        @Override
        public String toString() {
            switch (this) {
            case SEQUENCE:
                return "sequence";
            case FAMILY:
                return "family";
            case CHOICE:
                return "choice";
            case UNORDERED:
                return "unordered";
            default:
                return "???";
            }
        }
    }

    private ConsoleHelper console;

    private String mapHref;

    // -----------------------------------------------------------------------

    public LinkGenerator() {
        this(null);
    }

    public LinkGenerator(Console c) {
        setConsole(c);
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

    public void processMap(Element map, URL mapURL,
                           LoadedDocuments loadedDocs) {
        // Process @collection-type (but not inside reltables) ---

        mapHref = mapURL.toExternalForm();
        ArrayList<Entry> childList = new ArrayList<Entry>();

        processHierarchy(map, loadedDocs, childList);

        // Process reltables ---

        IdentityHashMap<Element, Entry[]> collected = 
            new IdentityHashMap<Element, Entry[]>();

        Node child = map.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                if (DITAUtil.hasClass(childElement, "map/reltable")) {
                    processColumns(childElement, loadedDocs, collected);

                    processRows(childElement, loadedDocs, collected);
                }
            }

            child = child.getNextSibling();
        }

        Iterator<Map.Entry<Element, Entry[]>> iter = 
            collected.entrySet().iterator();
        while (iter.hasNext()) {
            Map.Entry<Element, Entry[]> e = iter.next();

            Element topic = e.getKey();
            Entry[] entries = e.getValue();

            addRelatedLinks(topic, entries);
        }
    }

    // -----------------------------------------------------------------------

    private void processHierarchy(Element topicrefOrMap,
                                  LoadedDocuments loadedDocs,
                                  List<Entry> childList) {
        CollectionType collectionType = null;
        String type = DITAUtil.getNonEmptyAttribute(topicrefOrMap, 
                                                    null, "collection-type");
        if (type != null) {
            collectionType = CollectionType.fromString(type);
        }
        if (collectionType == null) {
            collectionType = CollectionType.UNORDERED;
        }

        processCollection(topicrefOrMap, collectionType, loadedDocs, childList);

        // Recurse ---

        // LIMITATION: @collection-type is ignored inside reltables.

        Node child = topicrefOrMap.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                if (DITAUtil.hasClass(childElement, "map/topicref") &&
                    // Does not make sense inside frontmatter/backmatter.
                    // For example, inside a glossary.
                    !DITAUtil.hasClass(childElement, 
                                       "bookmap/frontmatter",
                                       "bookmap/backmatter")) {
                    processHierarchy(childElement, loadedDocs, childList);
                }
            }

            child = child.getNextSibling();
        }
    }

    private void processCollection(Element topicrefOrMap, 
                                   CollectionType collectionType,
                                   LoadedDocuments loadedDocs,
                                   List<Entry> childList) {
        Entry parent = null;

        String href =
            DITAUtil.getNonEmptyAttribute(topicrefOrMap, null, "href");
        if (href != null) {
            parent = createEntry(topicrefOrMap, href, loadedDocs);
            if (parent != null && parent.topic == null) {
                parent = null;
            }
        }

        childList.clear();

        Node child = topicrefOrMap.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                if (DITAUtil.hasClass(childElement, "map/topicref") &&
                    (href = 
                     DITAUtil.getNonEmptyAttribute(childElement,
                                                   null, "href")) != null) {
                    Entry entry = createEntry(childElement, href, 
                                              loadedDocs);
                    if (entry != null && entry.topic == null) {
                        entry = null;
                    }
                    if (entry != null) {
                        childList.add(entry);
                    }
                }
            }

            child = child.getNextSibling();
        }
        
        int childCount = childList.size();
        if (childCount > 0) {
            if (parent != null) {
                linkParentToChildren(parent, childList, childCount, 
                                     collectionType);
            }

            switch (collectionType) {
            case FAMILY:
                {
                    for (int i = 0; i < childCount; ++i) {
                        Entry entry = childList.get(i);

                        linkFamilyMembers(entry, parent, childList, 
                                          childCount, i);
                    }
                }
                break;
            case SEQUENCE:
                {
                    Entry previous = null;
                    for (int i = 0; i < childCount; ++i) {
                        Entry entry = childList.get(i);

                        Entry next = 
                            (i+1 < childCount)? childList.get(i+1) : null;
                        linkSequenceMembers(entry, parent, previous, next);
                        previous = entry;
                    }
                }
                break;
            default:
                {
                    for (int i = 0; i < childCount; ++i) {
                        Entry entry = childList.get(i);

                        linkMembers(entry, parent, collectionType);
                    }
                }
            }
        }
    }

    private void linkParentToChildren(Entry parent, 
                                      List<Entry> childList, int childCount,
                                      CollectionType collectionType) {
        switch (parent.linking) {
        case NORMAL:
        case SOURCE_ONLY:
            {
                Element topic = parent.topic;
                assert(topic != null);

                Document doc = topic.getOwnerDocument();
                assert(doc != null);

                String linkpoolType = collectionType.toString() + "-parent";
                Element linkpool = 
                    addLinkpool(topic, /*prepend*/ true, linkpoolType, doc);

                for (int i = 0; i < childCount; ++i) {
                    addLink(linkpool, childList.get(i), "child", doc);
                }
            }
            break;
        }
    }

    private void linkFamilyMembers(Entry from, Entry parent, 
                                   List<Entry> siblingList, 
                                   int siblingCount, int topicIndex) {
        switch (from.linking) {
        case NORMAL:
        case SOURCE_ONLY:
            {
                Element topic = from.topic;
                assert(topic != null);

                Document doc = topic.getOwnerDocument();
                assert(doc != null);

                Element linkpool = 
                    addLinkpool(topic, /*prepend*/ true, "family-members", 
                                doc);

                if (parent != null) {
                    addLink(linkpool, parent, "parent", doc);
                }

                for (int i = 0; i < siblingCount; ++i) {
                    if (i != topicIndex) {
                        addLink(linkpool, siblingList.get(i), "sibling", doc);
                    }
                }
            }
            break;
        }
    }

    private void linkSequenceMembers(Entry from, Entry parent, 
                                     Entry previous, Entry next) {
        switch (from.linking) {
        case NORMAL:
        case SOURCE_ONLY:
            {
                Element topic = from.topic;
                assert(topic != null);

                Document doc = topic.getOwnerDocument();
                assert(doc != null);

                Element linkpool = 
                    addLinkpool(topic, /*prepend*/ true, "sequence-members", 
                                doc);

                if (parent != null) {
                    addLink(linkpool, parent, "parent", doc);
                }

                if (previous != null) {
                    addLink(linkpool, previous, "previous", doc);
                }

                if (next != null) {
                    addLink(linkpool, next, "next", doc);
                }
            }
            break;
        }
    }

    private void linkMembers(Entry from, Entry parent, 
                             CollectionType collectionType) {
        // In the case of choice and unordered, the siblings are not linked to
        // each other in any way. Therefore this leaves us with the link to
        // parent alone.

        if (parent != null) {
            switch (from.linking) {
            case NORMAL:
            case SOURCE_ONLY:
                {
                    Element topic = from.topic;
                    assert(topic != null);

                    Document doc = topic.getOwnerDocument();
                    assert(doc != null);

                    String linkpoolType = 
                        collectionType.toString() + "-members";
                    Element linkpool = 
                        addLinkpool(topic, /*prepend*/ true, linkpoolType, doc);

                    addLink(linkpool, parent, "parent", doc);
                }
                break;
            }
        }
    }

    private static void addLink(Element linkpool, Entry to, String role,
                                Document doc) {
        switch (to.linking) {
        case NORMAL:
        case TARGET_ONLY:
            {
                Element link = addLink(linkpool, to, doc);
                link.setAttributeNS(null, "role", role);
            }
            break;
        }
    }

    // -----------------------------------------------------------------------

    private void processColumns(Element reltable, 
                                LoadedDocuments loadedDocs,
                                Map<Element, Entry[]> collected) {
        Element relheader = 
            DITAUtil.findChildByClass(reltable, "map/relheader");
        if (relheader == null) {
            return;
        }

        int column = 0;
        ArrayList<Entry[]> cellList = new ArrayList<Entry[]>();
        ArrayList<Entry> entryList = new ArrayList<Entry>();

        Node child = relheader.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                if (DITAUtil.hasClass(childElement, "map/relcolspec")) {
                    cellList.clear();

                    entryList.clear();
                    processCell(childElement, loadedDocs, entryList);

                    if (entryList.size() > 0) {
                        Entry[] entries = new Entry[entryList.size()];
                        entryList.toArray(entries);
                        cellList.add(entries);

                        processColumn(reltable, column, loadedDocs, 
                                      entryList, cellList);

                        addColumn(cellList, collected);
                    }
                    // Otherwise the relcolspec does not contain topicrefs.

                    ++column;
                }
            }

            child = child.getNextSibling();
        }
    }

    private void processColumn(Element reltable, int column,
                               LoadedDocuments loadedDocs, 
                               List<Entry> entryList,
                               List<Entry[]> cellList) {
        Node child = reltable.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                if (DITAUtil.hasClass(childElement, "map/relrow")) {
                    Element relcell = 
                        DOMUtil.getNthChildElement(childElement, column);
                    if (relcell != null &&
                        DITAUtil.hasClass(relcell, "map/relcell")) {
                        entryList.clear();
                        processCell(relcell, loadedDocs, entryList);

                        Entry[] entries = new Entry[entryList.size()];
                        entryList.toArray(entries);
                        cellList.add(entries);
                    }
                }
            }

            child = child.getNextSibling();
        }
    }

    private static void addColumn(List<Entry[]> cellList,
                                  Map<Element, Entry[]> collected) {
        int cellCount = cellList.size();
        if (cellCount < 2) {
            return;
        }

        Entry[] sources = cellList.get(0);

        for (int j = 1; j < cellCount; ++j) {
            Entry[] targets = cellList.get(j);

            addLinks(sources, targets, collected);
            addLinks(targets, sources, collected);
        }
    }            

    private static void addLinks(Entry[] sources, Entry[] targets,
                                 Map<Element, Entry[]> collected) {
        for (int k = 0; k < sources.length; ++k) {
            Entry source = sources[k];

            switch (source.linking) {
            case NORMAL:
            case SOURCE_ONLY:
                assert(source.topic != null);
                for (int l = 0; l < targets.length; ++l) {
                    Entry target = targets[l];

                    if (target.topic == source.topic) {
                        continue;
                    }

                    switch (target.linking) {
                    case NORMAL:
                    case TARGET_ONLY:
                        {
                            Entry[] entries = collected.get(source.topic);
                            if (entries == null) {
                                entries = new Entry[] { target };
                            } else {
                                if (ArrayUtil.indexOf(entries, target) < 0) {
                                    entries = ArrayUtil.append(entries,target);
                                }
                            }
                            collected.put(source.topic, entries);
                        }
                        break;
                    }
                }
                break;
            }
        }
    }

    // -----------------------------------------------------------------------

    private void processRows(Element reltable, 
                             LoadedDocuments loadedDocs,
                             Map<Element, Entry[]> collected) {
        ArrayList<Entry[]> cellList = new ArrayList<Entry[]>();

        Node child = reltable.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                if (DITAUtil.hasClass(childElement, "map/relrow")) {
                    cellList.clear();
                    processRow(childElement, loadedDocs, cellList);

                    addRow(cellList, collected);
                }
            }

            child = child.getNextSibling();
        }
    }

    private void processRow(Element relrow, 
                            LoadedDocuments loadedDocs, 
                            List<Entry[]> cellList) {
        ArrayList<Entry> entryList = new ArrayList<Entry>();

        Node child = relrow.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                if (DITAUtil.hasClass(childElement, "map/relcell")) {
                    entryList.clear();
                    processCell(childElement, loadedDocs, entryList);

                    Entry[] entries = new Entry[entryList.size()];
                    entryList.toArray(entries);
                    cellList.add(entries);
                }
            }

            child = child.getNextSibling();
        }
    }

    private void processCell(Element relcell, 
                             LoadedDocuments loadedDocs, 
                             List<Entry> entryList) {
        Node child = relcell.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                String href;
                if (DITAUtil.hasClass(childElement, "map/topicref") &&
                    (href = 
                     DITAUtil.getNonEmptyAttribute(childElement,
                                                   null, "href")) != null) {
                    Entry entry = createEntry(childElement, href, 
                                              loadedDocs);
                    if (entry != null) {
                        entryList.add(entry);
                    }
                }

                processCell(childElement, loadedDocs, entryList);
            }

            child = child.getNextSibling();
        }
    }

    private Entry createEntry(Element topicref, String href, 
                              LoadedDocuments loadedDocs) {
        // scope ---

        String scope = DITAUtil.getNonEmptyAttribute(topicref, null, "scope");

        // format ---

        String format = DITAUtil.getFormat(topicref, href);
        if (format == null) {
            console.warning(topicref, Msg.msg("missingAttribute", "format"));
            return null;
        }

        // linking ---

        Linking linking = Linking.NORMAL;

        String value = DITAUtil.getNonEmptyAttribute(topicref, null, "linking");
        if (value != null) {
            if ("none".equals(value)) {
                linking = Linking.NONE;
            } else if ("sourceonly".equals(value)) {
                linking = Linking.SOURCE_ONLY;
            } else if ("targetonly".equals(value)) {
                linking = Linking.TARGET_ONLY;
            } else if ("normal".equals(value)) {
                linking = Linking.NORMAL;
            } else {
                console.warning(topicref, 
                                Msg.msg("invalidAttribute", value, "linking"));
                linking = Linking.NONE;
            }
        }

        // linktext, shortdesc ---

        Element linktext = null;
        Element shortdesc = null;

        Element topicmeta = DITAUtil.findChildByClass(topicref, 
                                                      "map/topicmeta");
        if (topicmeta != null) {
            // Notice "map/linktext" and not "topic/linktext".
            linktext = DITAUtil.findChildByClass(topicmeta, 
                                                 "map/linktext");

            // Notice "map/shortdesc" and not "topic/shortdesc".
            shortdesc = DITAUtil.findChildByClass(topicmeta, 
                                                  "map/shortdesc");
        }

        // topicId, elementId, topic ---

        String topicId = null;
        String elementId = null;
        Element topic = null;

        if ((scope == null || "local".equals(scope)) &&
            "dita".equals(format)) {
            // Points to a local topic.

            URL url;
            try {
                url = URLUtil.createURL(href);
            } catch (MalformedURLException ignored) {
                console.warning(topicref, Msg.msg("invalidAttribute", 
                                                  href, "href"));
                return null;
            }

            String fragment = URLUtil.getFragment(url);
            url = URLUtil.setFragment(url, null);

            // LoadedDocuments.get() is sufficient in production.
            // We use load() here just to be able to run the test drive below.
            LoadedDocument loadedDoc = null;
            try {
                loadedDoc = loadedDocs.load(url);
            } catch (Exception shouldNotHappen) {}

            if (loadedDoc != null) {
                if (fragment != null) {
                    int pos = fragment.indexOf('/');
                    if (pos > 0 && pos+1 < fragment.length()) {
                        topicId = fragment.substring(0, pos);
                        elementId =  fragment.substring(pos+1);
                    } else {
                        topicId = fragment;
                    }
                }

                LoadedTopic loadedTopic = null;
                if (topicId != null) {
                    loadedTopic = loadedDoc.findTopicById(topicId);
                } else {
                    loadedTopic = loadedDoc.getFirstTopic();
                }

                if (loadedTopic != null) {
                    if (loadedTopic.isExcluded()) {
                        return null;
                    } else {
                        topicId = loadedTopic.topicId;
                        topic = loadedTopic.element;

                        // Normalize href ---

                        StringBuilder buffer = 
                            new StringBuilder(url.toExternalForm());
                        buffer.append('#');
                        buffer.append(URIComponent.quoteFragment(topicId));
                        if (elementId != null) {
                          buffer.append('/');
                          buffer.append(URIComponent.quoteFragment(elementId));
                        }
                        href = buffer.toString();
                    }
                } else {
                    console.warning(topicref, 
                                    Msg.msg("pointsOutsidePreprocessedTopics",
                                            href));
                    return null;
                }
            } else {
                console.warning(topicref, 
                                Msg.msg("pointsOutsidePreprocessedTopics",
                                        href));
                return null;
            }
        } else {
            // Points to an external resource.

            if (linking != Linking.NONE) {
                linking = Linking.TARGET_ONLY;
            }
        }

        return new Entry(href, scope, format, linking, linktext, shortdesc, 
                         topicId, elementId, topic);
    }

    private static void addRow(List<Entry[]> cellList,
                               Map<Element, Entry[]> collected) {
        int cellCount = cellList.size();
        for (int i = 0; i < cellCount; ++i) {
            Entry[] sources = cellList.get(i);

            for (int j = 0; j < cellCount; ++j) {
                if (j == i) {
                    continue;
                }
                Entry[] targets = cellList.get(j);

                addLinks(sources, targets, collected);
            }
        }
    }            

    // -----------------------------------------------------------------------

    private void addRelatedLinks(Element topic, Entry[] entries) {
        Document doc = topic.getOwnerDocument();
        assert(doc != null);

        Element linkpool = addLinkpool(topic, /*prepend*/ false, "related",
                                       doc);

        for (int i = 0; i < entries.length; ++i) {
            addLink(linkpool, entries[i], doc);
        }
    }

    private Element addLinkpool(Element topic,
                                boolean prepend, String linkpoolType,
                                Document doc) {
        Element relatedLinks = 
            DITAUtil.findChildByClass(topic, "topic/related-links");
        if (relatedLinks == null) {
            relatedLinks = doc.createElementNS(null, "related-links");
            relatedLinks.setAttributeNS(null, 
                                        "class", "- topic/related-links ");

            topic.insertBefore(relatedLinks, 
                              DITAUtil.findChildByClass(topic, "topic/topic"));
        }

        Element linkpool = doc.createElementNS(null, "linkpool");
        linkpool.setAttributeNS(null, "class", "- topic/linkpool ");

        if (mapHref != null && linkpoolType != null) {
            // mapkeyref is a standard DITA 1.2 attribute meant for this use.
            linkpool.setAttributeNS(null, "mapkeyref", 
                                    mapHref + " type=" + linkpoolType);
        }

        Node before = null;
        if (prepend) {
            before = relatedLinks.getFirstChild();
        }
        relatedLinks.insertBefore(linkpool, before);

        return linkpool;
    }

    private static Element addLink(Element parent, Entry entry, Document doc) {
        Element link = doc.createElementNS(null, "link");
        parent.appendChild(link);

        link.setAttributeNS(null, "class", "- topic/link ");

        link.setAttributeNS(null, "href", entry.href);

        if (entry.scope != null) {
            link.setAttributeNS(null, "scope", entry.scope);
        }

        if (entry.format != null) {
            link.setAttributeNS(null, "format", entry.format);
        }

        if (entry.linktext != null) {
            Element linktext = 
                (Element) doc.importNode(entry.linktext, /*deep*/ true);
            linktext.setAttributeNS(null, "class", "- topic/linktext ");
            link.appendChild(linktext);
        }

        if (entry.shortdesc != null) {
            Element desc = doc.createElementNS(null, "desc");
            desc.setAttributeNS(null, "class", "- topic/desc ");
            link.appendChild(desc);

            DOMUtil.copyChildren(entry.shortdesc, desc, doc);
        }

        return link;
    }

    // -----------------------------------------------------------------------

    public static void main(String[] args) 
        throws Exception {
        java.io.File inFile = null;
        java.io.File outDir = null;
        if (args.length != 2 ||
            !(inFile = new java.io.File(args[0])).isFile() ||
            !(outDir = new java.io.File(args[1])).isDirectory()) {
            System.err.println(
                "usage: java com.xmlmind.ditac.preprocess.LinkGenerator" +
                " in_map_file out_dir");
            System.exit(1);
        }

        LoadedDocuments loadedDocs = new LoadedDocuments();
        LoadedDocument loadedMap = loadedDocs.load(inFile);
        switch (loadedMap.type) {
        case BOOKMAP:
        case MAP:
            break;
        default:
            System.err.println("'" + inFile + "' does not contain a map");
            System.exit(1);
        }

        (new LinkGenerator()).processMap(
            loadedMap.document.getDocumentElement(), loadedMap.url,
            loadedDocs);

        java.util.Iterator<LoadedDocument> iter = loadedDocs.iterator();
        while (iter.hasNext()) {
            LoadedDocument loadedDoc = iter.next();
            if (loadedDoc != loadedMap) {
                java.io.File outFile = new java.io.File(
                    outDir, 
                    com.xmlmind.util.URLUtil.getBaseName(loadedDoc.url));

                com.xmlmind.ditac.util.SaveDocument.save(loadedDoc.document, 
                                                         outFile);
            }
        }
    }
}

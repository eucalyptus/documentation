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
import java.util.HashSet;
import java.util.ArrayList;
import java.util.Stack;
import org.w3c.dom.Node;
import org.w3c.dom.Element;
import org.w3c.dom.Document;
import com.xmlmind.util.URIComponent;
import com.xmlmind.util.URLUtil;
import com.xmlmind.util.XMLText;
import com.xmlmind.util.Console;
import com.xmlmind.ditac.util.DOMUtil;
import com.xmlmind.ditac.util.DITAUtil;
import com.xmlmind.ditac.util.SimpleConsole;
import com.xmlmind.ditac.util.ConsoleHelper;

/*package*/ final class Chunker {
    private boolean defaultPolicyIsByTopic;
    private String defaultRootName;
    private ConsoleHelper console;

    private LoadedDocument mainMap;
    private LoadedDocuments loadedDocs;
    private Stack<Chunk> chunkStack;
    private ArrayList<Chunk> chunkList;
    private HashSet<String> rootNames;
    private String mainMapRootName;

    private enum Select {
        TOPIC,
        BRANCH,
        DOCUMENT
    }

    // -----------------------------------------------------------------------

    public Chunker() {
        this(false, null, null);
    }

    public Chunker(boolean byTopic, String rootName, Console c) {
        defaultPolicyIsByTopic = byTopic;
        defaultRootName = rootName;
        setConsole(c);
    }

    public void setByTopic(boolean byTopic) {
        defaultPolicyIsByTopic = byTopic;
    }

    public boolean isByTopic() {
        return defaultPolicyIsByTopic;
    }

    public void setRootName(String rootName) {
        defaultRootName = rootName;
    }

    public String getRootName() {
        return defaultRootName;
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

    public Chunk[] processMap(LoadedDocument mainMap,
                              LoadedDocuments loadedDocs) {
        this.mainMap = mainMap;
        this.loadedDocs = loadedDocs;

        chunkStack = new Stack<Chunk>();
        chunkList = new ArrayList<Chunk>();
        rootNames = new HashSet<String>();

        if (!process(mainMap.document)) {
            return null;
        }

        int count = chunkList.size();
        if (count == 0) {
            console.error(Msg.msg("noChunks"));
            return null;
        }

        Chunk[] chunks = new Chunk[count];
        chunkList.toArray(chunks);
        return chunks;
    }

    private boolean process(Node node) {
        Node child = node.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                // Topicrefs found inside reltables are ignored.

                if (DITAUtil.hasClass(childElement, "map/topicref") ||
                    DITAUtil.hasClass(childElement, "map/map")) {
                    String chunkValue =
                        childElement.getAttributeNS(null, "chunk");
                    boolean pushChunk = 
                        (chunkValue != null && 
                         chunkValue.indexOf("to-content") >= 0);
                    Chunk topChunk = null;

                    if (pushChunk) {
                        topChunk = createChunk(childElement);
                        if (topChunk != null) {
                            chunkStack.push(topChunk);
                        } else {
                            // Otherwise, ignored topicref such as
                            // scope=external.

                            pushChunk = false;
                            topChunk = getTopChunk();
                        }
                    } else {
                        topChunk = getTopChunk();
                    }

                    if (topChunk == null) {
                        if (!addChunk(childElement)) {
                            return false;
                        }
                    } else {
                        if (!addEntries(topChunk, childElement)) {
                            return false;
                        }
                    }

                    if (!process(childElement)) {
                        return false;
                    }

                    if (pushChunk) {
                        chunkStack.pop();

                        // Replace the previous top chunk by an empty copy.
                        topChunk = getTopChunk();
                        if (topChunk != null) {
                            chunkStack.pop();
                            chunkStack.push(new Chunk(topChunk.rawRootName));
                        }
                    }
                }
            }

            child = child.getNextSibling();
        }

        return true;
    }

    private Chunk getTopChunk() {
        return chunkStack.empty()? null : chunkStack.peek();
    }

    private boolean addChunk(Element element) {
        boolean byTopic = defaultPolicyIsByTopic;

        String chunkValue = element.getAttributeNS(null, "chunk");
        if (chunkValue != null) {
            if (chunkValue.indexOf("by-topic") >= 0) {
                byTopic = true;
            } else if (chunkValue.indexOf("by-document") >= 0) {
                byTopic = false;
            }
        }

        if (byTopic) {
            if (!expandTopicrefs(element)) {
                return false;
            }
        }

        Chunk chunk = createChunk(element);
        if (chunk != null) {
            return addEntries(chunk, element);
        } else {
            // Otherwise, ignored topicref such as scope=external.
            return true;
        }
    }
    
    private boolean expandTopicrefs(Element element) {
        String href = DITAUtil.getNonEmptyAttribute(element, null, "href");
        if (href != null) {
            URL url = null;
            try {
                url = URLUtil.createURL(href);
            } catch (MalformedURLException ignored) {}

            if (url != null) {
                String topicId = DITAUtil.getTopicId(url);
                url = URLUtil.setFragment(url, null);

                LoadedDocument loadedDoc = loadedDocs.get(url);
                // loadedDoc is null when for example, scope=external.

                if (loadedDoc != null && 
                    (loadedDoc.type == LoadedDocument.Type.MULTI_TOPIC || 
                     loadedDoc.type == LoadedDocument.Type.TOPIC)) {
                    Select select = 
                        (topicId == null)? Select.DOCUMENT : Select.TOPIC;

                    String value = element.getAttributeNS(null, "chunk");
                    if (value != null) {
                        if (value.indexOf("select-document") >= 0) {
                            select = Select.DOCUMENT;
                        } else if (value.indexOf("select-branch") >= 0) {
                            select = Select.BRANCH;
                        } else if (value.indexOf("select-topic") >= 0) {
                            select = Select.TOPIC;
                        }
                    }

                    LoadedTopic loadedTopic = null;

                    if (topicId != null) {
                        loadedTopic = loadedDoc.findTopicById(topicId);
                        if (loadedTopic == null) {
                            console.error(
                                Msg.msg("topicNotFound", topicId, 
                                        URLUtil.toLabel(loadedDoc.url)));
                            return false;
                        }
                    } else {
                        loadedTopic = loadedDoc.getFirstTopic();
                    }

                    switch (select) {
                    case TOPIC:
                        // Nothing special to do.
                        break;
                    case BRANCH:
                        if (loadedTopic.topics.length > 0) {
                            expandBranch(loadedTopic, element);
                        }
                        // Otherwise, no nested topics.
                        break;
                    case DOCUMENT:
                        if (loadedDoc.getSingleTopic() == null) {
                            expandDocument(loadedDoc, element);
                        }
                        // Otherwise, a single topic with no nested topics.
                        break;
                    }
                }
            }
        }

        return true;
    }

    private static void expandDocument(LoadedDocument loadedDoc, 
                                       Element anchor) {
        Node parent = anchor.getParentNode();
        Node before = anchor.getNextSibling();

        LoadedTopic[] loadedTopics = loadedDoc.getTopics();
        for (int i = 0; i < loadedTopics.length; ++i) {
            LoadedTopic loadedTopic = loadedTopics[i];

            Element topicref;
            if (i > 0) {
                topicref = (Element) anchor.cloneNode(/*deep*/ false);
                parent.insertBefore(topicref, before);
            } else {
                topicref = anchor;
            }

            expandBranch(loadedTopic, topicref);
        }
    }

    private static void expandBranch(LoadedTopic loadedTopic, 
                                     Element anchor) {
        anchor.setAttributeNS(null, "href", loadedTopic.getHref());
        anchor.setAttributeNS(null, "chunk", "by-topic");

        Document doc = anchor.getOwnerDocument();

        LoadedTopic[] nestedTopics = loadedTopic.topics;
        for (int i = 0; i < nestedTopics.length; ++i) {
            LoadedTopic nestedTopic = nestedTopics[i];

            Element topicref = doc.createElementNS(null, "topicref");
            topicref.setAttributeNS(null, "class", "- map/topicref ");
            anchor.appendChild(topicref);

            expandBranch(nestedTopic, topicref);
        }
    }

    private Chunk createChunk(Element element) {
        String rootName = null;

        String copyTo = 
            DITAUtil.getNonEmptyAttribute(element, null, "copy-to");

        String href = DITAUtil.getNonEmptyAttribute(element, null, "href");
        if (href == null) {
            // A map has no href.
            //
            // Attribute href may be omitted from all sorts of topicrefs.  In
            // such case, consider the topicref as being a kind of topicgroup.

            rootName = (copyTo == null)? defaultRootName() : copyTo;
        } else {
            URL url = null;
            try {
                url = URLUtil.createURL(href);
            } catch (MalformedURLException ignored) {}

            if (url != null) {
                String topicId = DITAUtil.getTopicId(url);
                url = URLUtil.setFragment(url, null);

                LoadedDocument loadedDoc = loadedDocs.get(url);
                // loadedDoc is null when for example, scope=external.

                if (loadedDoc != null && 
                    (loadedDoc.type == LoadedDocument.Type.MULTI_TOPIC || 
                     loadedDoc.type == LoadedDocument.Type.TOPIC)) {
                    if (copyTo != null) {
                        rootName = copyTo;
                    } else {
                        String loadedDocBaseName = URLUtil.getBaseName(url);
                        if (loadedDocBaseName != null && 
                            loadedDocBaseName.startsWith(
                                WrapTopicrefTitle.BASENAME_PREFIX)) {
                            rootName = defaultRootName();
                        } else {
                            boolean byTopic = defaultPolicyIsByTopic;

                            String value = 
                                element.getAttributeNS(null, "chunk");
                            if (value != null) {
                                if (value.indexOf("by-topic") >= 0) {
                                    byTopic = true;
                                } else if (value.indexOf("by-document") >= 0) {
                                    byTopic = false;
                                }
                            }

                            if (byTopic) {
                                LoadedTopic loadedTopic = null;

                                if (topicId != null) {
                                    loadedTopic = 
                                        loadedDoc.findTopicById(topicId);
                                } else {
                                    loadedTopic = loadedDoc.getFirstTopic();
                                }

                                if (loadedTopic != null) {
                                    rootName = loadedTopic.topicId;
                                }
                            } else {
                                rootName = loadedDocBaseName;
                            }
                        }
                    }
                }
            }
        }

        return (rootName == null)? null : new Chunk(rootName);
    }

    private String defaultRootName() {
        if (defaultRootName == null) {
            if (mainMapRootName == null) {
                mainMapRootName = URLUtil.getBaseName(mainMap.url);
                mainMapRootName =
                    URIComponent.setExtension(mainMapRootName, null);
            }
            return mainMapRootName;
        } else {
            return defaultRootName;
        }
    }

    private boolean addEntries(Chunk chunk, Element element) {
        assert(chunk != null);

        String href = DITAUtil.getNonEmptyAttribute(element, null, "href");
        if (href == null) {
            if (DITAUtil.hasClass(element, "map/topicref")) {
                ChunkEntry.Type entryType = null;

                if (DITAUtil.hasClass(element, "bookmap/toc")) {
                    entryType = ChunkEntry.Type.TOC;
                } else if (DITAUtil.hasClass(element, "bookmap/figurelist")) {
                    entryType = ChunkEntry.Type.FIGURE_LIST;
                } else if (DITAUtil.hasClass(element, "bookmap/tablelist")) {
                    entryType = ChunkEntry.Type.TABLE_LIST;
                } else if (DITAUtil.hasClass(element, "*/examplelist")) {
                    entryType = ChunkEntry.Type.EXAMPLE_LIST;
                } else if (DITAUtil.hasClass(element, "bookmap/indexlist")) {
                    entryType = ChunkEntry.Type.INDEX_LIST;
                }

                if (entryType != null) {
                    TOCInfo info = setTOCInfo(element);

                    addChunkEntry(chunk, entryType, info.getNumber(), 
                                  info.role, info.title, info.tocType, null);
                }
            }
        } else {
            URL url = null;
            try {
                url = URLUtil.createURL(href);
            } catch (MalformedURLException ignored) {}

            if (url != null) {
                String topicId = DITAUtil.getTopicId(url);
                url = URLUtil.setFragment(url, null);

                LoadedDocument loadedDoc = loadedDocs.get(url);
                // loadedDoc is null when for example, scope=external.

                if (loadedDoc != null && 
                    (loadedDoc.type == LoadedDocument.Type.MULTI_TOPIC || 
                     loadedDoc.type == LoadedDocument.Type.TOPIC)) {
                    Select select = 
                        (topicId == null)? Select.DOCUMENT : Select.TOPIC;

                    String value = element.getAttributeNS(null, "chunk");
                    if (value != null) {
                        if (value.indexOf("select-document") >= 0) {
                            select = Select.DOCUMENT;
                        } else if (value.indexOf("select-branch") >= 0) {
                            select = Select.BRANCH;
                        } else if (value.indexOf("select-topic") >= 0) {
                            select = Select.TOPIC;
                        }
                    }

                    LoadedTopic loadedTopic = null;

                    if (topicId != null) {
                        loadedTopic = loadedDoc.findTopicById(topicId);
                        if (loadedTopic == null) {
                            console.error(
                                Msg.msg("topicNotFound", topicId, 
                                        URLUtil.toLabel(loadedDoc.url)));
                            return false;
                        }
                    } else {
                        loadedTopic = loadedDoc.getFirstTopic();
                    }

                    TOCInfo info = setTOCInfo(element);
                    switch (select) {
                    case TOPIC:
                        if (!addTopic(chunk, info.getNumber(), info.role, 
                                      info.title, info.tocType, loadedTopic)) {
                            info.incrementNumber(-1);
                        }
                        break;
                    case BRANCH:
                        if (!addBranch(chunk, info.getNumber(), info.role, 
                                      info.title, info.tocType, loadedTopic)) {
                            info.incrementNumber(-1);
                        }
                        break;
                    case DOCUMENT:
                        {
                            int added = 
                                addDocument(chunk, info.getNumber(), info.role,
                                           info.title, info.tocType, loadedDoc);
                            info.incrementNumber(added-1);
                        }
                        break;
                    }
                }
            }
        }

        return true;
    }

    private int addDocument(Chunk chunk, String[] number, String role,
                            String title, TOCType tocType, 
                            LoadedDocument loadedDoc) {
        int added = 0;

        LoadedTopic singleTopic = loadedDoc.getSingleTopic();
        if (singleTopic != null) {
            if (addTopic(chunk, number, role, title, tocType, singleTopic)) {
                ++added;
            }
        } else {
            LoadedTopic[] topics = loadedDoc.getTopics();
            if (topics != null) {
                for (int i = 0; i < topics.length; ++i) {
                    String[] num = TOCInfo.incrementNumber(number, added);

                    if (addBranch(chunk, num, role, null, tocType, topics[i])) {
                        ++added;
                    }
                }
            }
        }

        return added;
    }

    private boolean addBranch(Chunk chunk, String[] number, String role,
                              String title, TOCType tocType, 
                              LoadedTopic loadedTopic) {
        if (!addTopic(chunk, number, role, title, tocType, loadedTopic)) {
            return false;
        }

        LoadedTopic[] nestedTopics = loadedTopic.topics;
        if (nestedTopics != null) {
            int numberLength = number.length;
            String subRole = DITAUtil.getSubRole(role);

            int j = 1;
            for (int i = 0; i < nestedTopics.length; ++i) {
                String[] num = new String[numberLength+1];
                System.arraycopy(number, 0, num, 0, numberLength);
                num[numberLength] = TOCInfo.formatNumberSegment(subRole, j);

                if (addBranch(chunk, num, subRole, null, tocType, 
                              nestedTopics[i])) {
                    ++j;
                }
            }
        }
        return true;
    }

    private boolean addTopic(Chunk chunk, String[] number, String role,
                             String title, TOCType tocType, 
                             LoadedTopic loadedTopic) {
        if (loadedTopic.isExcluded()) {
            return false;
        } else {
            addChunkEntry(chunk, ChunkEntry.Type.TOPIC, number,
                          role, title, tocType, loadedTopic);
            return true;
        }
    }

    private void addChunkEntry(Chunk chunk, ChunkEntry.Type type,
                               String[] number, String role,
                               String title, TOCType tocType,
                               LoadedTopic loadedTopic) {
        chunk.appendEntry(new ChunkEntry(chunk, type, number, role, title, 
                                         tocType, loadedTopic));

        // First chunk filled with entries is first chunk added to the list.
        //
        // An empty chunk will never be added to the list.

        boolean found = false;
        for (int i = chunkList.size()-1; i >= 0; --i) {
            if (chunkList.get(i) == chunk) {
                found = true;
                break;
            }
        }

        if (!found) {
            chunk.initRootName(uniqueRootName(chunk));

            chunkList.add(chunk);
        }
    }

    private String uniqueRootName(Chunk chunk) {
        String defaultRootName = defaultRootName();

        String name = chunk.rawRootName;
        if (name == null || (name = name.trim()).length() == 0) {
            name = defaultRootName;
        } else if (!defaultRootName.equals(name)) {
            int pos = name.lastIndexOf('/');
            if (pos >= 0) {
                name = name.substring(pos+1);
            }

            pos = name.lastIndexOf('\\');
            if (pos >= 0) {
                name = name.substring(pos+1);
            }

            pos = name.lastIndexOf('.');
            if (pos > 0) {
                name = name.substring(0, pos);
            }

            if (name.length() == 0) {
                name = defaultRootName;
            }
        }

        String name2 = name;
        int counter = 2;

        while (rootNames.contains(name2)) {
            if (counter > 100) {
                // Too much conflicts. Use a more radical approach
                // (which gives rather long and unreadable rootnames).
                name2 = name + "-" + 
                    Long.toString(System.identityHashCode(chunk), 
                                  Character.MAX_RADIX);
                break;
            }

            StringBuilder buffer = new StringBuilder(name);
            buffer.append('-');
            buffer.append(Integer.toString(counter++));
            name2 = buffer.toString();
        }

        rootNames.add(name2);
        return name2;
    }

    // -----------------------------------
    // setTOCInfo
    // -----------------------------------

    private static TOCInfo setTOCInfo(Element topicref) {
        Node parent = topicref.getParentNode();
        if (parent == null ||
            !DITAUtil.hasClass(topicref, "map/topicref")) {
            // Do not annotate the element.
            return TOCInfo.NO_INFO;
        }

        TOCInfo parentInfo = null;

        for (;;) {
            // This allows to skip topicref ancestors which play no role in
            // terms of hierarchy (e.g. topicgroup).

            parentInfo = (TOCInfo) parent.getUserData(TOCInfo.USER_DATA_KEY);
            if (parentInfo != null) {
                break;
            }

            parent = parent.getParentNode();
            if (parent == null ||
                parent.getNodeType() != Node.ELEMENT_NODE ||
                !DITAUtil.hasClass((Element) parent, "map/topicref")) {
                break;
            }
        }

        String role;

        if (parentInfo == null) {
            role = getRootRole(topicref);
        } else {
            role = DITAUtil.getSubRole(parentInfo.role);
        }

        int index = 1;

        Node preceding = precedingNode(topicref);
        while (preceding != null) {
            TOCInfo precedingInfo = 
                (TOCInfo) preceding.getUserData(TOCInfo.USER_DATA_KEY);
            if (precedingInfo != null && precedingInfo.role.equals(role)) {
                index = TOCInfo.parseNumber(precedingInfo.getNumber()) + 1;
                break;
            }

            preceding = precedingNode(preceding);
        }

        String[] number;
        if (parentInfo == null) {
            number = new String[] { TOCInfo.formatNumberSegment(role, index) };
        } else {
            String[] parentNumber = parentInfo.getNumber();
            int count = parentNumber.length;
            number = new String[count+1];
            System.arraycopy(parentNumber, 0, number, 0, count);
            number[count] = TOCInfo.formatNumberSegment(role, index);
        }

        String navtitle = getLockedNavtitle(topicref);

        TOCType tocType = getTOCType(topicref);

        TOCInfo info = new TOCInfo(number, role, navtitle, tocType);
        topicref.setUserData(TOCInfo.USER_DATA_KEY, info, null);
        return info;
    }

    private static Node precedingNode(Node node) {
        for (;;) {
            // This allows to skip topicref ancestors which play no role in
            // terms of hierarchy (e.g. topicgroup).

            Node previous = node.getPreviousSibling();
            if (previous != null) {
                Node preceding = previous;
                while (preceding != null) {
                    previous = preceding;

                    if (preceding.getNodeType() != Node.ELEMENT_NODE ||
                        !DITAUtil.hasClass((Element) preceding, 
                                           "map/topicref") ||
                        preceding.getUserData(TOCInfo.USER_DATA_KEY) != null) {
                        break;
                    }
                    preceding = preceding.getLastChild();
                }

                return previous;
            }

            Node parent = node.getParentNode();
            if (parent == null ||
                parent.getNodeType() != Node.ELEMENT_NODE ||
                !DITAUtil.hasClass((Element) parent, "map/topicref") ||
                parent.getUserData(TOCInfo.USER_DATA_KEY) != null) {
                break;
            }
            node = parent;
        }

        return null;
    }

    private static final String[] ROOT_ROLES = {
        "bookmap/toc",
        "bookmap/figurelist",
        "bookmap/tablelist",
        "bookmap/abbrevlist",
        "bookmap/trademarklist",
        "bookmap/bibliolist",
        "bookmap/glossarylist",
        "bookmap/indexlist",
        "bookmap/booklist",
        "bookmap/notices",
        "bookmap/dedication",
        "bookmap/colophon",
        "bookmap/bookabstract",
        "bookmap/draftintro",
        "bookmap/preface",
        "bookmap/part",
        "bookmap/chapter",
        "bookmap/appendices",
        "bookmap/appendix",
        "bookmap/amendments"
    };
    private static final int ROOT_ROLE_COUNT = ROOT_ROLES.length;

    private static String getRootRole(Element topicref) {
        for (int i = 0; i < ROOT_ROLE_COUNT; ++i) {
            String cls = ROOT_ROLES[i];

            if (DITAUtil.hasClass(topicref, cls)) {
                return cls.substring(cls.lastIndexOf('/') + 1);
            }
        }

        if (isFrontmatterSection(topicref, "bookmap/frontmatter")) {
            // A plain topicref contained in frontmatter. Not a normal
            // section1.
            return "frontmattersection";
        } else if (isFrontmatterSection(topicref, "bookmap/backmatter")) {
            // A plain topicref contained in backmatter. Not a normal
            // section1.
            return "backmattersection";
        } else {
            // Fallback.
            return "section1";
        }
    }

    private static boolean isFrontmatterSection(Element topicref,
                                                String frontmatterClass) {
        if (DITAUtil.getParentByClass(topicref, frontmatterClass) != null) {
            return true;
        } else {
            Element parent = DOMUtil.getParentElement(topicref);
            if (parent != null &&
                DITAUtil.getParentByClass(parent, frontmatterClass) != null &&
                DITAUtil.hasClass(parent, "map/topicref") &&
                DITAUtil.getNonEmptyAttribute(parent, null, "href") == null &&
                getNavtitle(parent) == null) {
                // This copes with the most common case other than the above
                // one:
                // topicref is contained in a dummy topicgroup (no href, no
                // title) itself contained in frontmatter/backmatter.
                return true;
            }
        }
        return false;
    }

    private static String getNavtitle(Element topicref) {
        String title = null;

        Element topicmeta = 
            DITAUtil.findChildByClass(topicref, "map/topicmeta");
        if (topicmeta != null) {
            Element navtitle = 
                DITAUtil.findChildByClass(topicmeta, "topic/navtitle");
            if (navtitle != null) {
                title = navtitle.getTextContent();
                if (title != null &&
                    (title=XMLText.collapseWhiteSpace(title)).length() == 0) {
                    title = null;
                }
            }
        }

        if (title == null) {
            title = DITAUtil.getNonEmptyAttribute(topicref, null, "navtitle");
            if (title != null &&
                (title = XMLText.collapseWhiteSpace(title)).length() == 0) {
                title = null;
            }
        }

        return title;
    }

    private static String getLockedNavtitle(Element topicref) {
        String title = getNavtitle(topicref);
        if (title != null) {
            String locktitle =
                DITAUtil.getNonEmptyAttribute(topicref, null, "locktitle");
            if (locktitle == null || !"yes".equals(locktitle)) {
                title = null;
            }
        }

        return title;
    }

    private static TOCType getTOCType(Element topicref) {
        if ("no".equals(DITAUtil.getNonEmptyAttribute(topicref, null, "toc"))) {
            return TOCType.NONE;
        } else {
            // Note that the frontmatter/backmatter TOC contains a reference
            // to <toc>. This is useful to implement PDF outline.

            if (DITAUtil.findAncestorByClass(topicref,
                                             "bookmap/frontmatter") != null) {
                return TOCType.FRONTMATTER;
            } else if (DITAUtil.findAncestorByClass(topicref, 
                                                "bookmap/backmatter") != null) {
                return TOCType.BACKMATTER;
            } else {
                return TOCType.BODY;
            }
        }
    }
}

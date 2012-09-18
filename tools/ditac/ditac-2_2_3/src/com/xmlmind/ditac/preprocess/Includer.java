/*
 * Copyright (c) 2009-2011 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.preprocess;

import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;
import org.w3c.dom.Node;
import org.w3c.dom.Element;
import org.w3c.dom.Document;
import com.xmlmind.util.ThrowableUtil;
import com.xmlmind.util.URLUtil;
import com.xmlmind.util.Console;
import com.xmlmind.ditac.util.NodeLocation;
import com.xmlmind.ditac.util.DOMUtil;
import com.xmlmind.ditac.util.DITAUtil;
import com.xmlmind.ditac.util.SimpleConsole;
import com.xmlmind.ditac.util.ConsoleHelper;

/*package*/ abstract class Includer {
    protected Keys keys;
    protected ConsoleHelper console;

    private Docs docs;
    private ArrayList<Doc> docList;
    private int processedDocCount;
    private int inclCounter;

    private static final int MAX_ITERATIONS = 100;

    private static final String INCL_ID_KEY = "INCL_ID";

    // -----------------------------------------------------------------------

    protected Includer() {
        this(null, null);
    }

    protected Includer(Keys keys, Console c) {
        setKeys(keys);
        setConsole(c);
    }

    public void setKeys(Keys keys) {
        this.keys = keys;
    }

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

    public boolean process(LoadedDocument loadedDoc) 
        throws IOException {
        return process(new LoadedDocument[] { loadedDoc });
    }

    public boolean process(LoadedDocument[] loadedDocs) 
        throws IOException {
        docs = new Docs(keys, console);
        docList = new ArrayList<Doc>();
        processedDocCount = 0;

        for (int i = 0; i < loadedDocs.length; ++i) {
            LoadedDocument loadedDoc = loadedDocs[i];

            Doc doc = (Doc) docs.put(loadedDoc.url, loadedDoc.document, 
                                     /*process*/ false);
            doc.isWorkingCopy = false;
            docList.add(doc);
            ++processedDocCount;

            collectIncludes(/*parentInclId*/ null, doc.document, doc);
        }

        return process();
    }

    // -----------------------------------------------------------------------
    // Implementation
    // -----------------------------------------------------------------------

    // -----------------------------------------
    // InclusionException
    // -----------------------------------------

    protected static final class InclusionException extends Exception {
        public InclusionException(String message) {
            super(message);
        }
    }

    // -----------------------------------------
    // Incl
    // -----------------------------------------

    protected static abstract class Incl {
        public final Element directiveElement;

        public int[] id;

        public Node[] replacementNodes;
        public Node[] appendedNodes; // e.g. reltables

        protected Incl(Element directiveElement) {
            this.directiveElement = directiveElement;
        }
    }

    // -----------------------------------------
    // Doc
    // -----------------------------------------

    protected static final class Doc extends LoadedDocument {
        public boolean isWorkingCopy;
        public ArrayList<Incl> processList;

        public Doc(URL url, Document document, boolean isWorkingCopy) {
            super(url, document);

            this.isWorkingCopy = isWorkingCopy;
            processList = new ArrayList<Incl>();
        }
    }

    // -----------------------------------------
    // Docs
    // -----------------------------------------

    protected static final class Docs extends LoadedDocuments {
        public Docs(Keys keys, Console console) {
            super(keys, console);
        }

        @Override
        protected LoadedDocument createLoadedDocument(URL url, Document doc) {
            return new Doc(url, doc, /*isWorkingCopy*/ true);
        }
    }

    private boolean collectIncludes(int[] parentInclId, Node tree, Doc doc) {
        Node firstChild = tree.getFirstChild();
        if (firstChild == null) {
            // Nothing to do.
            return true;
        }
        Node lastChild = tree.getLastChild();
        return collectIncludes(parentInclId, firstChild, lastChild, doc);
    }

    private boolean collectIncludes(int[] parentInclId,
                                    Node firstChild, Node lastChild,
                                    Doc doc) {
        Node child = firstChild;
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                Incl incl = detectInclusion(childElement);
                if (incl != null) {
                    int[] inclId = newInclId(parentInclId, childElement);
                    if (inclId == null) {
                        // Inclusion loop.
                        return false;
                    }

                    incl.id = inclId;
                }

                if (incl != null) {
                    doc.processList.add(incl);
                } else {
                    if (!collectIncludes(parentInclId, childElement, doc)) {
                        return false;
                    }
                }

            }
            child = nextSibling(child, lastChild);
        }

        return true;
    }

    protected abstract Incl detectInclusion(Element element);

    private int[] newInclId(int[] parentInclId, Element directive) {
        int id;

        Integer prop = (Integer) directive.getUserData(INCL_ID_KEY);
        if (prop == null) {
            id = inclCounter++;
            directive.setUserData(INCL_ID_KEY, new Integer(id),
                                  DOMUtil.COPY_USER_DATA);
        } else {
            id = prop.intValue();

            if (parentInclId != null) {
                for (int i = parentInclId.length-1; i >= 0; --i) {
                    if (parentInclId[i] == id) {
                        // Inclusion loop.
                        return null;
                    }
                }
            }
        }

        if (parentInclId == null) {
            return new int[] { id };
        }

        int count = parentInclId.length;
        int[] inclId = new int[count+1];
        System.arraycopy(parentInclId, 0, inclId, 0, count);
        inclId[count] = id;

        return inclId;
    }

    private static Node nextSibling(Node child, Node lastChild) {
        if (child == lastChild) {
            return null;
        } else {
            return child.getNextSibling();
        }
    }

    private boolean process()
        throws IOException {
        // MAX_ITERATIONS is just a security: the algorithm does not count on
        // reaching this number of iterations.

        long now = System.currentTimeMillis();
        boolean lastIteration = false;
        int iteration = 0;

        for (; iteration < MAX_ITERATIONS; ++iteration) {
            console.debug(Msg.msg("iteration", iteration));

            int remainDocCount = processedDocCount;
            int initialDocCount = docList.size();
            int changeCount = 0;

            for (int j = 0; j < processedDocCount; ++j) {
                Doc doc = docList.get(j);

                if (doc.processList.size() > 0) {
                    console.debug(Msg.msg("processingDoc", doc.url, 
                                          doc.processList.size()));

                    if (process(doc, lastIteration)) {
                        ++changeCount;
                    }

                    console.debug(Msg.msg("docProcessed", doc.url, 
                                          doc.processList.size()));
                }

                if (doc.processList.size() == 0) {
                    --remainDocCount;
                }
            }

            if (remainDocCount == 0) {
                // All documents which are not working copies fully processed.
                break;
            }

            int docCount = docList.size();
            for (int j = processedDocCount; j < docCount; ++j) {
                Doc doc = docList.get(j);

                if (doc.processList.size() > 0) {
                    console.debug(Msg.msg("processingDoc", doc.url, 
                                          doc.processList.size()));

                    if (process(doc, lastIteration)) {
                        ++changeCount;
                    }

                    console.debug(Msg.msg("docProcessed", doc.url, 
                                          doc.processList.size()));
                }
            }

            if (lastIteration) {
                // Stop here.
                break;
            } else {
                if (docList.size() > initialDocCount) {
                    ++changeCount;
                }

                if (changeCount == 0) {
                    lastIteration = true;
                }
            }
        }

        // Clean-up ---

        boolean done = true;

        for (int j = 0; j < processedDocCount; ++j) {
            Doc doc = docList.get(j);

            DOMUtil.removeUserData(doc.document, INCL_ID_KEY);

            if (doc.processList.size() > 0) {
                error(doc, Msg.msg("notFullyProcessed", 1+iteration));
                done = false;
            }
        }

        console.debug(Msg.msg("allDocsProcessed", 
                              1+iteration, System.currentTimeMillis()-now));
        return done;
    }

    private void error(Doc doc, String message) {
        StringBuilder buffer = new StringBuilder(doc.url.toExternalForm());
        buffer.append("::: ");
        buffer.append(message);
        console.error(buffer.toString());
    }

    private boolean process(Doc doc, boolean lastIteration) 
        throws IOException {
        int inclCount = doc.processList.size();
        Incl[] incls = new Incl[inclCount];
        doc.processList.toArray(incls);

        doc.processList.clear();

        int removeCount = inclCount;
        int retryCount = 0;

        for (int i = 0; i < inclCount; ++i) {
            Incl incl = incls[i];

            try {
                fetchIncluded(incl);
            } catch (InclusionException e) {
                if (lastIteration) {
                    error(incl, Msg.msg("cannotFetchIncludedNodes", 
                                        ThrowableUtil.reason(e)));
                }

                doc.processList.add(incl);
                --removeCount;
                ++retryCount;
            }
            
            if (incl.replacementNodes != null) {
                if (incl.replacementNodes.length == 0) {
                    error(incl, Msg.msg("noReplacementNodes"));
                    incl.replacementNodes = incl.appendedNodes = null;
                }
            }
        }

        // Replacement is a separate step because we don't want to invoke
        // fetchIncluded() on a document we are modifying.

        for (int i = 0; i < inclCount; ++i) {
            Incl incl = incls[i];

            Node[] replacement = incl.replacementNodes;
            Node[] appended = incl.appendedNodes;
            incl.replacementNodes = null;
            incl.appendedNodes = null;

            if (replacement != null) {
                replaceNode(incl.directiveElement, replacement);

                if (!collectIncludes(incl.id, replacement[0], 
                                     replacement[replacement.length-1], doc)) {
                    // Restore directive (including INCL_ID_KEY on directive).
                    replaceNodes(replacement, incl.directiveElement);

                    error(incl, Msg.msg("inclusionLoop"));
                }
            }

            if (appended != null) {
                Node insertParent = null;
                Node insertBefore = null;
                if (replacement == null) {
                    // This happens with map transclusion where the included
                    // map only contains reltables.

                    insertParent = incl.directiveElement.getParentNode();
                    insertBefore = incl.directiveElement.getNextSibling();
                    insertParent.removeChild(incl.directiveElement);
                }

                // reltables can be safely added at the end of a map or a
                // bookmap.
                appendNodes(appended, doc);

                if (!collectIncludes(incl.id, appended[0], 
                                     appended[appended.length-1], doc)) {
                    removeNodes(appended);
                    if (insertParent != null) {
                        // Restore directive (including INCL_ID_KEY on
                        // directive).
                        insertParent.insertBefore(incl.directiveElement,
                                                  insertBefore);
                    }

                    error(incl, Msg.msg("inclusionLoop"));
                }
            }
        }

        // Has something changed for this Doc?

        int addCount = doc.processList.size() - retryCount;
        return (addCount != 0 || removeCount != 0);
    }

    protected abstract void fetchIncluded(Incl incl)
        throws IOException, InclusionException;

    protected Doc fetchDoc(URL url) 
        throws IOException {
        Doc doc = (Doc) docs.get(url);
        if (doc == null) {
            long now = System.currentTimeMillis();
            String docLocation = URLUtil.toLabel(url);
            console.verbose(Msg.msg("cachingDocument", docLocation));

            doc = (Doc) docs.load(url);
            docList.add(doc);

            console.verbose(Msg.msg("documentCached", docLocation, 
                                    (System.currentTimeMillis()-now)));

            collectIncludes(/*parentInclId*/ null, doc.document, doc);
        }

        return doc;
    }

    protected static void copyUserData(Node from, Node to) {
        Object value = from.getUserData(NodeLocation.USER_DATA_KEY);
        if (value != null) {
            to.setUserData(NodeLocation.USER_DATA_KEY, value,
                           DOMUtil.COPY_USER_DATA);
        }

        value = from.getUserData(INCL_ID_KEY);
        if (value != null) {
            to.setUserData(INCL_ID_KEY, value,
                           DOMUtil.COPY_USER_DATA);
        }
    }

    private static void replaceNode(Node from, Node[] to) {
        Node parent = from.getParentNode();
        Node before = from.getNextSibling();

        parent.removeChild(from);
        for (int i = 0; i < to.length; ++i) {
            parent.insertBefore(to[i], before);
        }
    }

    private static void replaceNodes(Node[] from, Node to) {
        int count = from.length;
        if (count == 0) {
            return;
        }
        Node parent = from[0].getParentNode();
        Node before = from[count-1].getNextSibling();

        for (int i = 0; i < count; ++i) {
            parent.removeChild(from[i]);
        }
        parent.insertBefore(to, before);
    }

    private static void appendNodes(Node[] appended, Doc doc) {
        Node parent = doc.document.getDocumentElement();
        
        for (int i = 0; i < appended.length; ++i) {
            parent.appendChild(appended[i]);
        }
    }

    private static void removeNodes(Node[] removed) {
        int count = removed.length;
        if (count == 0) {
            return;
        }
        Node parent = removed[0].getParentNode();

        for (int i = 0; i < count; ++i) {
            parent.removeChild(removed[i]);
        }
    }

    private void error(Incl incl, String message) {
        console.error(incl.directiveElement, message);
    }
}

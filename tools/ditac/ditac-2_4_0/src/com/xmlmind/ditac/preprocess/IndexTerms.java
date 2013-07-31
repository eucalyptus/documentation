/*
 * Copyright (c) 2009-2012 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.preprocess;

import java.util.Locale;
import java.util.Map;
import java.util.HashMap;
import java.util.Comparator;
import java.util.Arrays;
import java.text.Collator;
import org.w3c.dom.Node;
import org.w3c.dom.Element;
import org.w3c.dom.Document;
import com.xmlmind.util.LocaleUtil;
import com.xmlmind.util.ArrayUtil;
import com.xmlmind.util.StringList;
import com.xmlmind.util.StringUtil;
import com.xmlmind.util.XMLText;
import com.xmlmind.util.Console;
import com.xmlmind.ditac.util.DiacriticUtil;
import com.xmlmind.ditac.util.DOMUtil;
import com.xmlmind.ditac.util.DITAUtil;
import com.xmlmind.ditac.util.SimpleConsole;
import com.xmlmind.ditac.util.ConsoleHelper;

/*package*/ final class IndexTerms implements Constants {
    private ConsoleHelper console;
    private HashMap<String, IndexTerm> indexTerms;
    private HashMap<String, IndexAnchorPair> startToAnchor;

    // -----------------------------------------------------------------------

    public IndexTerms() {
        this(null);
    }

    public IndexTerms(Console c) {
        setConsole(c);
        indexTerms = new HashMap<String, IndexTerm>();
        startToAnchor = new HashMap<String, IndexAnchorPair>();
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
    
    // -----------------------------------------------------------------------
    // collect
    // -----------------------------------------------------------------------

    public void collect(Element indexTermElement, String file) {
        ParsedIndexTerm parsed = parseIndexTerm(indexTermElement);
        if (parsed == null) {
            return;
        }

        if (parsed.end != null) {
            finishAnchorPair(parsed, file);
            // Nothing else to do.
        } else {
            boolean newIndexTerm = false;

            IndexTerm indexTerm = indexTerms.get(parsed.term);
            if (indexTerm == null) {
                indexTerm = new IndexTerm(parsed.term);
                newIndexTerm = true;
            }

            if (!merge(parsed, file, new String[] { parsed.term },
                       indexTerm)) {
                return;
            }

            if (newIndexTerm) {
                indexTerms.put(parsed.term, indexTerm);
            }
        }
    }

    // --------------------------------------
    // parseIndexTerm
    //
    // This step locally checks the 
    // consistency of the ParsedIndexTerm.
    // --------------------------------------

    private static final class ParsedIndexTerm {
        public final Element source;
        public String term;
        public String start;
        public String end;
        public String id;
        public String sortAs;
        // Note that multiple index-see elements are OK.
        public IndexTermRef[] seeList;
        public IndexTermRef[] seeAlsoList;        
        public ParsedIndexTerm[] subTermList;

        public ParsedIndexTerm(Element source) {
            this.source = source;
        }

        public void addSee(IndexTermRef see) {
            if (seeList == null) {
                seeList = new IndexTermRef[] { see };
            } else {
                seeList = ArrayUtil.append(seeList, see);
            }
        }

        public void addSeeAlso(IndexTermRef seeAlso) {
            if (seeAlsoList == null) {
                seeAlsoList = new IndexTermRef[] { seeAlso };
            } else {
                seeAlsoList = ArrayUtil.append(seeAlsoList, seeAlso);
            }
        }

        public void addSubTerm(ParsedIndexTerm subTerm) {
            if (subTermList == null) {
                subTermList = new ParsedIndexTerm[] { subTerm };
            } else {
                subTermList = ArrayUtil.append(subTermList, subTerm);
            }
        }

        public void setAnchorId(String anchorId) {
            id = anchorId;
            if (subTermList != null) {
                for (int i = 0; i < subTermList.length; ++i) {
                    subTermList[i].setAnchorId(anchorId);
                }
            }
        }
    }

    private ParsedIndexTerm parseIndexTerm(Element element) {
        ParsedIndexTerm parsed = doParseIndexTerm(element);

        if (parsed != null) {
            // Use the ID of the topmost indexterm as the *anchor* ID of all
            // nested indexterms.
            parsed.setAnchorId(parsed.id);
        }

        return parsed;
    }

    private ParsedIndexTerm doParseIndexTerm(Element element) {
        ParsedIndexTerm parsed = new ParsedIndexTerm(element);

        parsed.id = element.getAttributeNS(null, "id");
        assert(parsed.id != null && parsed.id.length() > 0);

        parsed.end = getRangeAttribute(element, "end");
        if (parsed.end != null) {
            if (DOMUtil.hasContent(element)) {
                console.warning(element, Msg.msg("nonEmptyIndexTermEnd"));
            }
            // Ignore any other content.
            return parsed;
        }

        parsed.term = getTerm(element);
        if (parsed.term == null) {
            console.warning(element, Msg.msg("missingIndexTerm"));
            return null;
        }

        parsed.start = getRangeAttribute(element, "start");

        Node child = element.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                if (DITAUtil.hasClass(childElement, "topic/indexterm")) {
                    ParsedIndexTerm parsed2 = doParseIndexTerm(childElement);
                    if (parsed2 != null) {
                        parsed.addSubTerm(parsed2);
                    }
                } else if (DITAUtil.hasClass(childElement, 
                                             "indexing-d/index-see")) {
                    IndexTermRef ref = parseIndexTermRef(childElement);
                    if (ref != null) {
                        parsed.addSee(ref);
                    }
                } else if (DITAUtil.hasClass(childElement, 
                                             "indexing-d/index-see-also")) {
                    IndexTermRef ref = parseIndexTermRef(childElement);
                    if (ref != null) {
                        parsed.addSeeAlso(ref);
                    }
                } else if (DITAUtil.hasClass(childElement, 
                                             "indexing-d/index-sort-as")) {
                    String sortAs = parseSortAs(childElement);
                    if (sortAs != null) {
                        if (parsed.sortAs != null) {
                            console.warning(element,
                                            Msg.msg("multipleIndexSortAs"));
                        }
                        parsed.sortAs = sortAs;
                    }
                }
            }

            child = child.getNextSibling();
        }

        // Check the consistency of the lists ---

        if (parsed.seeList != null && parsed.seeAlsoList != null) {
            // We'll not treat see as see-also (because this is questionable).
            parsed.seeList = null;
            console.warning(element, Msg.msg("bothIndexSeeAndIndexSeeAlso"));
        }

        if (parsed.seeList != null && parsed.subTermList != null) {
            parsed.seeList = null;
            console.warning(element, Msg.msg("seeOnNonLeafIndexTerm"));
        }

        // NOT CONFORMING: a non-leaf term can have anchors (single or range)
        // and see-also.

        return parsed;
    }

    private static String getTerm(Element element) {
        StringBuilder buffer = new StringBuilder();

        Node child = element.getFirstChild();
        loop: while (child != null) {
            switch (child.getNodeType()) {
            case Node.TEXT_NODE:
                buffer.append(child.getTextContent());
                break;

            case Node.ELEMENT_NODE:
                {
                    Element childElement = (Element) child;

                    if (DITAUtil.hasClass(childElement, "topic/indexterm") ||
                        DITAUtil.hasClass(childElement, "topic/index-base")) {
                        break loop;
                    }
                    buffer.append(childElement.getTextContent());
                }
                break;
            }

            child = child.getNextSibling();
        }

        String term = buffer.toString();
        term = XMLText.collapseWhiteSpace(term);
        if (term.length() == 0) {
            term = null;
        }

        // LIMITATION: we have lost the ``formatting'' of term.
        return term;
    }

    private static String getRangeAttribute(Element element, String attrName) {
        String value = element.getAttributeNS(null, attrName);
        if (value != null) {
            value = XMLText.collapseWhiteSpace(value);
            if (value.length() == 0) {
                value = null;
            }
        }
        return value;
    }

    private IndexTermRef parseIndexTermRef(Element element) {
        StringBuilder buffer = new StringBuilder();
        
        String term = getTerm(element);
        if (term == null) {
            console.warning(element, Msg.msg("missingIndexTerm"));
            return null;
        }
        buffer.append(term);
            
        Element nestedElement = element;
        for (;;) {
            Element childElement = 
                DITAUtil.findChildByClass(nestedElement, "topic/indexterm");
            if (childElement == null) {
                break;
            }

            term = getTerm(childElement);
            if (term == null) {
                console.warning(childElement, Msg.msg("missingIndexTerm"));
                return null;
            }
            buffer.append('\n');
            buffer.append(term);

            nestedElement = childElement;
        }

        return new IndexTermRef(element,
                                StringUtil.split(buffer.toString(), '\n'));
    }

    private String parseSortAs(Element element) {
        String value = element.getTextContent();
        value = XMLText.collapseWhiteSpace(value);
        if (value.length() == 0) {
            console.warning(element, Msg.msg("emptyIndexSortAs"));
            value = null;
        }
        return value;
    }

    // --------------------------------------
    // merge
    //
    // This step does *not* check the 
    // consistency of the merged IndexTerm.
    // --------------------------------------

    private boolean merge(ParsedIndexTerm parsed, String file, 
                          String[] term, IndexTerm indexTerm) {
        assert(parsed.term != null);

        // Add anchor ---

        ParsedIndexTerm[] parsedSubTermList = parsed.subTermList;
        IndexTermRef[] parsedSeeList = parsed.seeList;

        boolean addAnchor = (parsedSeeList == null);
        if (addAnchor) {
            if (parsed.start != null) {
                // Consider parsed as having an anchor, even if it has sub
                // terms.

                if (startToAnchor.containsKey(parsed.start)) {
                    // LIMITATION: overlapping index ranges are not supported.
                    console.warning(parsed.source, 
                                    Msg.msg("overlappingIndexRange", 
                                            parsed.start));
                    startToAnchor.remove(parsed.start);
                    return false;
                }

                IndexAnchorPair anchorPair = 
                    new IndexAnchorPair(parsed.source, file, 
                                        parsed.id, parsed.start);
                indexTerm.addAnchor(anchorPair);

                startToAnchor.put(parsed.start, anchorPair);
            } else {
                if (parsedSubTermList != null) {
                    for (int i = 0; i < parsedSubTermList.length; ++i) {
                        if (parsedSubTermList[i].end == null) {
                            addAnchor = false;
                            break;
                        }
                    }
                }
                if (addAnchor) {
                    indexTerm.addAnchor(new IndexAnchor(parsed.source, 
                                                        file, parsed.id));
                }
                // Otherwise parsed being a non-leaf has no anchor of its own.
            }
        }

        // Update sortAs ---

        if (parsed.sortAs != null) {
            String sortAs = indexTerm.getSortAs();
            if (sortAs != null && !sortAs.equals(parsed.sortAs)) {
                console.warning(parsed.source, 
                                Msg.msg("multipleIndexSortAs2",
                                        termLabel(term)));
            }
            indexTerm.setSortAs(parsed.sortAs);
        }

        // Update seeList ---

        IndexTermRef[] seeList = indexTerm.getSeeList();

        if (parsedSeeList != null) {
            for (int i = 0; i < parsedSeeList.length; ++i) {
                IndexTermRef parsedSee = parsedSeeList[i];

                boolean found = false;

                if (seeList != null) {
                    for (int j = 0; j < seeList.length; ++j) {
                        if (seeList[j].equals(parsedSee)) {
                            found = true;
                            break;
                        }
                    }
                }

                if (!found) {
                    // Note that multiple see items are OK.
                    indexTerm.addSee(parsedSee);
                    seeList = indexTerm.getSeeList();
                }
            }
        }

        // Update seeAlsoList ---

        IndexTermRef[] seeAlsoList = indexTerm.getSeeAlsoList();

        IndexTermRef[] parsedSeeAlsoList = parsed.seeAlsoList;
        if (parsedSeeAlsoList != null) {
            for (int i = 0; i < parsedSeeAlsoList.length; ++i) {
                IndexTermRef parsedSeeAlso = parsedSeeAlsoList[i];

                boolean found = false;

                if (seeAlsoList != null) {
                    for (int j = 0; j < seeAlsoList.length; ++j) {
                        if (seeAlsoList[j].equals(parsedSeeAlso)) {
                            found = true;
                            break;
                        }
                    }
                }

                if (!found) {
                    indexTerm.addSeeAlso(parsedSeeAlso);
                    seeAlsoList = indexTerm.getSeeAlsoList();
                }
            }
        }

        // Update subTermList ---

        IndexTerm[] subTermList = indexTerm.getSubTermList();

        if (parsedSubTermList != null) {
            for (int i = 0; i < parsedSubTermList.length; ++i) {
                ParsedIndexTerm parsedSubTerm = parsedSubTermList[i];

                if (parsedSubTerm.end != null) {
                    finishAnchorPair(parsedSubTerm, file);
                } else {
                    String t = parsedSubTerm.term;
                    assert(t != null);

                    IndexTerm subTerm = null;

                    if (subTermList != null) {
                        for (int j = 0; j < subTermList.length; ++j) {
                            IndexTerm st = subTermList[j];
                            if (st.term.equals(t)) {
                                subTerm = st;
                                break;
                            }
                        }
                    }

                    boolean newSubTerm = false;

                    if (subTerm == null) {
                        subTerm = new IndexTerm(t);
                        newSubTerm = true;
                    }

                    if (!merge(parsedSubTerm, file, StringList.append(term, t),
                               subTerm)) {
                        continue;
                    }

                    if (newSubTerm) {
                        indexTerm.addSubTerm(subTerm);

                        // An indexterm can contain the same sub term several
                        // times: do not recreate the sub term in such case.
                        subTermList = indexTerm.getSubTermList();
                    }
                }
            }
        }

        return true;
    }

    private void finishAnchorPair(ParsedIndexTerm parsed, String file) {
        IndexAnchorPair anchorPair = startToAnchor.remove(parsed.end);
        if (anchorPair == null) {
            console.warning(parsed.source, 
                            Msg.msg("indexRangeStartNotFound", 
                                    parsed.end));
        } else {
            anchorPair.setAnchor2(parsed.source, file, parsed.id);
        }
    }

    private static String termLabel(String[] term) {
        return StringUtil.join(" / ", term);
    }

    // -----------------------------------------------------------------------
    // addEntries
    // -----------------------------------------------------------------------

    public void addEntries(String lang, Document doc,
                           Element indexListElement) {
        if (indexTerms.size() == 0) {
            // Nothing to do.
            return;
        }

        Locale locale = LocaleUtil.getLocale(lang);
        IndexTerm[] entries = sort(locale);

        finish(entries);

        // Associate an ID to all index terms ---

        HashMap<String, String> termToId = new HashMap<String, String>();

        int entryCount = entries.length;
        for (int i = 0; i < entryCount; ++i) {
            IndexTerm entry = entries[i];

            identify(entry, null, termToId);
        }

        // Add symbol entries, if any ---

        Element divElement = null;

        for (int i = 0; i < entryCount; ++i) {
            IndexTerm entry = entries[i];

            String sa = entry.getSortAs();
            String term = (sa == null)? entry.term : sa;

            if (!Character.isLetter(term.charAt(0))) {
                if (divElement == null) {
                    divElement = doc.createElementNS(DITAC_NS_URI,
                                                     "ditac:div");
                    indexListElement.appendChild(divElement);

                    divElement.setAttributeNS(null, "title", "symbols");
                }

                addEntry(entry, new String[] { entry.term },
                         termToId, doc, divElement);
            }
        }

        // Add non-symbol entries, if any ---

        Collator collator = createFirstLetterCollator(locale);
        char prevFirstChar = '\0';

        for (int i = 0; i < entryCount; ++i) {
            IndexTerm entry = entries[i];

            String sa = entry.getSortAs();
            String term = (sa == null)? entry.term : sa;
            char firstChar = term.charAt(0);

            if (Character.isLetter(firstChar)) {
                if (prevFirstChar == '\0' ||
                    collator.compare(Character.toString(prevFirstChar), 
                                     Character.toString(firstChar)) != 0) {
                    divElement = doc.createElementNS(DITAC_NS_URI,
                                                     "ditac:div");
                    indexListElement.appendChild(divElement);

                    divElement.setAttributeNS(null, "title",
                                              toDivTitle(firstChar));
                }
                prevFirstChar = firstChar;

                addEntry(entry, new String[] { entry.term },
                         termToId, doc, divElement);
            }
        }
    }
    
    private static void identify(IndexTerm indexTerm, String parentTerm,
                                 Map<String, String> termToId) {
        StringBuilder buffer = new StringBuilder();
        if (parentTerm != null) {
            buffer.append(parentTerm);
            buffer.append('\n');
        }
        buffer.append(indexTerm.term);
        String term = buffer.toString();

        termToId.put(term, DITAUtil.generateID(indexTerm));

        IndexTerm[] subTermList = indexTerm.getSubTermList();
        if (subTermList != null) {
            for (int i = 0; i < subTermList.length; ++i) {
                IndexTerm subTerm = subTermList[i];
                    
                identify(subTerm, term, termToId);
            }
        }
    }

    private static String toDivTitle(char c) {
        char collapsed = Character.toUpperCase(DiacriticUtil.collapse(c));
        return Character.toString(collapsed);
    }

    private void addEntry(IndexTerm indexTerm, String[] term, 
                          Map<String, String> termToId,
                          Document doc, Element parent) {
        Element indexEntry =
            doc.createElementNS(DITAC_NS_URI, "ditac:indexEntry");
        parent.appendChild(indexEntry);

        DOMUtil.setXMLId(indexEntry, DITAUtil.generateID(indexTerm));

        indexEntry.setAttributeNS(null, "term", indexTerm.term);

        String sortAs = indexTerm.getSortAs();
        if (sortAs != null) {
            indexEntry.setAttributeNS(null, "sortAs", sortAs);
        }

        IndexAnchor[] anchorList = indexTerm.getAnchorList();
        IndexTermRef[] seeList = indexTerm.getSeeList();
        IndexTermRef[] seeAlsoList = indexTerm.getSeeAlsoList();
        IndexTerm[] subTermList = indexTerm.getSubTermList();

        boolean isSeeEntry = (seeList != null && anchorList == null &&
                              seeAlsoList == null && subTermList == null);

        if (anchorList != null) {
            int num = 0;
            for (int i = 0; i < anchorList.length; ++i) {
                IndexAnchor anchor = anchorList[i];

                Element indexAnchor = 
                    doc.createElementNS(DITAC_NS_URI, "ditac:indexAnchor");
                indexEntry.appendChild(indexAnchor);

                indexAnchor.setAttributeNS(null, "number", 
                                           Integer.toString(++num));
                indexAnchor.setAttributeNS(null, "file", anchor.file);
                indexAnchor.setAttributeNS(null, "id", anchor.getId());

                if (anchor instanceof IndexAnchorPair) {
                    IndexAnchorPair anchorPair = (IndexAnchorPair) anchor;
                    if (anchorPair.getSource2() != null) {
                        indexAnchor.setAttributeNS(null, "number2", 
                                                   Integer.toString(++num));
                        indexAnchor.setAttributeNS(null, "file2", 
                                                   anchorPair.getFile2());
                        indexAnchor.setAttributeNS(null, "id2", 
                                                   anchorPair.getId2());
                    }
                }
            }
        }

        if (seeAlsoList != null) {
            for (int i = 0; i < seeAlsoList.length; ++i) {
                IndexTermRef ref = seeAlsoList[i];

                Element seeAlso = 
                    doc.createElementNS(DITAC_NS_URI, "ditac:indexSeeAlso");
                indexEntry.appendChild(seeAlso);

                setRefAttributes(ref, termToId, seeAlso);
            }
        }

        if (subTermList != null) {
            for (int i = 0; i < subTermList.length; ++i) {
                IndexTerm subTerm = subTermList[i];

                addEntry(subTerm, ArrayUtil.append(term, subTerm.term),
                         termToId, doc, indexEntry);
            }
        }

        if (seeList != null) {
            if (isSeeEntry) {
                for (int i = 0; i < seeList.length; ++i) {
                    IndexTermRef ref = seeList[i];

                    Element see = 
                        doc.createElementNS(DITAC_NS_URI, "ditac:indexSee");
                    indexEntry.appendChild(see);

                    setRefAttributes(ref, termToId, see);
                }
            } else {
                for (int i = 0; i < seeList.length; ++i) {
                    IndexTermRef see = seeList[i];

                    console.warning(see.source, 
                                    Msg.msg("seeOnNonLeafIndexTerm2", 
                                            termLabel(term)));
                }
            }
        }
    }

    private void setRefAttributes(IndexTermRef ref, 
                                  Map<String, String> termToId,
                                  Element seeAlso) {
        String redirection = StringUtil.join('\n', ref.term);
        seeAlso.setAttributeNS(null, "term", redirection);

        String redirectionId = termToId.get(redirection);
        if (redirectionId == null) {
            console.warning(ref.source, 
                            Msg.msg("noSuchIndexTerm", termLabel(ref.term)));
        } else {
            seeAlso.setAttributeNS(null, "ref", redirectionId);
        }
    }

    // --------------------------------------
    // sort
    // --------------------------------------

    private IndexTerm[] sort(Locale locale) {
        IndexTerm[] entries = new IndexTerm[indexTerms.size()];
        indexTerms.values().toArray(entries);

        final Collator termCollator = createTermCollator(locale);

        Comparator<IndexTerm> termCompare = new Comparator<IndexTerm>() {
            public int compare(IndexTerm term1, IndexTerm term2) {
                String sa1 = term1.getSortAs();
                String t1 = (sa1 == null)? term1.term : sa1;

                String sa2 = term2.getSortAs();
                String t2 = (sa2 == null)? term2.term : sa2;

                int delta = termCollator.compare(t1, t2);
                if (delta != 0) {
                    return delta;
                } else {
                    return termCollator.compare(term1.term, term2.term);
                }
            }
        };

        Comparator<IndexTermRef> termRefCompare = 
            new Comparator<IndexTermRef>() {
            public int compare(IndexTermRef ref1, IndexTermRef ref2) {
                String[] t1 = ref1.term;
                String[] t2 = ref2.term;

                int count = Math.min(t1.length, t2.length);
                for (int i = 0; i < count; ++i) {
                    int delta = termCollator.compare(t1[i], t2[i]);
                    if (delta != 0) {
                        return delta;
                    }
                }

                return t1.length - t2.length;
            }
        };

        if (entries.length > 1) {
            Arrays.sort(entries, termCompare);
        }

        for (int i = 0; i < entries.length; ++i) {
            IndexTerm entry = entries[i];

            sortEntry(entry, termRefCompare, termCompare);
        }

        return entries;
    }
            
    private static void sortEntry(IndexTerm indexTerm, 
                                  Comparator<IndexTermRef> termRefCompare, 
                                  Comparator<IndexTerm> termCompare) {
        // indexTerm.anchorList is already sorted by document order.

        IndexTermRef[] seeList = indexTerm.getSeeList();
        if (seeList != null && seeList.length > 1) {
            Arrays.sort(seeList, termRefCompare);
        }

        IndexTermRef[] seeAlsoList = indexTerm.getSeeAlsoList();
        if (seeAlsoList != null && seeAlsoList.length > 1) {
            Arrays.sort(seeAlsoList, termRefCompare);
        }

        IndexTerm[] subTermList = indexTerm.getSubTermList();
        if (subTermList != null) {
            if (subTermList.length > 1) {
                Arrays.sort(subTermList, termCompare);
            }

            for (int i = 0; i < subTermList.length; ++i) {
                IndexTerm subTerm = subTermList[i];
                    
                sortEntry(subTerm, termRefCompare, termCompare);
            }
        }
    }

    private static Collator createTermCollator(Locale locale) {
        Collator collator = Collator.getInstance(locale);
        collator.setDecomposition(Collator.FULL_DECOMPOSITION);
        collator.setStrength(Collator.IDENTICAL);
        return collator;
    }

    private static Collator createFirstLetterCollator(Locale locale) {
        Collator collator = Collator.getInstance(locale);
        collator.setDecomposition(Collator.FULL_DECOMPOSITION);
        collator.setStrength(Collator.PRIMARY);
        return collator;
    }

    // --------------------------------------
    // finish
    // --------------------------------------

    private void finish(IndexTerm[] entries) {
        for (int i = 0; i < entries.length; ++i) {
            finishAnchors(entries[i]);
        }
    }

    private void finishAnchors(IndexTerm indexTerm) {
        IndexAnchor[] anchorList = indexTerm.getAnchorList();
        if (anchorList != null) {
            for (int i = 0; i < anchorList.length; ++i) {
                IndexAnchor anchor = anchorList[i];
                Element source = anchor.source;

                if (DITAUtil.findAncestorByClass(source,
                                                 "topic/prolog") != null) {
                    String id = markStartOfTopic(source);
                    if (id != null) {
                        anchor.setId(id);
                    }
                }

                if (anchor instanceof IndexAnchorPair) {
                    IndexAnchorPair anchorPair = (IndexAnchorPair) anchor;
                    Element source2 = anchorPair.getSource2();

                    if (source2 == null) {
                        // LIMITATION: the implicit end of range is always
                        // after the last child of the topic, not including
                        // nested topics.

                        String id2 = markEndOfTopic(source);
                        if (id2 != null) {
                            // A topic is never split between several files.
                            anchorPair.setAnchor2(source, 
                                                  anchorPair.file, id2);
                        }
                    } else {
                        if (DITAUtil.findAncestorByClass(source2,
                                                       "topic/prolog")!=null) {
                            String id2 = markEndOfTopic(source2);
                            if (id2 != null) {
                                anchorPair.setAnchor2(source2, 
                                                      anchorPair.getFile2(),
                                                      id2);
                            }
                        }
                    }
                }
            }
        }

        IndexTerm[] subTermList = indexTerm.getSubTermList();
        if (subTermList != null) {
            for (int i = 0; i < subTermList.length; ++i) {
                IndexTerm subTerm = subTermList[i];
                    
                finishAnchors(subTerm);
            }
        }
    }

    private String markStartOfTopic(Element indexterm) {
        Element topic = DITAUtil.findAncestorByClass(indexterm, "topic/topic");
        if (topic == null) {
            // Should not happen.
            return null;
        }
        String topicId = topic.getAttributeNS(null, "id");
        assert(topicId != null && topicId.length() > 0);

        String titleId = null;

        Element title = DITAUtil.findChildByClass(topic, "topic/title");
        if (title != null) {
            titleId = DITAUtil.getNonEmptyAttribute(title, null, "id");
            if (titleId == null) {
                titleId = joinId(topicId, "__TT");
                title.setAttributeNS(null, "id", titleId);
            }
        }

        return titleId;
    }

    private static String joinId(String topicId, String id) {
        StringBuilder buffer = new StringBuilder(topicId);
        buffer.append(ID_SEPARATOR);
        buffer.append(id);
        return buffer.toString();
    }

    private String markEndOfTopic(Element indexterm) {
        Element topic = DITAUtil.findAncestorByClass(indexterm, "topic/topic");
        if (topic == null) {
            // Should not happen.
            return null;
        }
        String topicId = topic.getAttributeNS(null, "id");
        assert(topicId != null && topicId.length() > 0);

        boolean found = false;
        Element after = null;

        Node child = topic.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                if (DITAUtil.hasClass(childElement, "topic/topic")) {
                    // Done.
                    break;
                }

                if (DOMUtil.hasName(childElement, DITAC_NS_URI, "anchor")) {
                    found = true;
                    break;
                }

                after = childElement;
            }

            child = child.getNextSibling();
        }

        String anchorId = joinId(topicId, "__EOT");

        if (!found && after != null) {
            Document doc = topic.getOwnerDocument();
            Element anchor = doc.createElementNS(DITAC_NS_URI, "ditac:anchor");
            DOMUtil.setXMLId(anchor, anchorId);

            topic.insertBefore(anchor, after.getNextSibling());
        }

        return anchorId;
    }
}

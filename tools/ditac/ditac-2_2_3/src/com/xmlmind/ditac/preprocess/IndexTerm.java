/*
 * Copyright (c) 2009-2010 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.preprocess;

import com.xmlmind.util.ArrayUtil;

/*package*/ final class IndexTerm {
    public final String term;

    private String sortAs;
    private IndexAnchor[] anchorList;
    private IndexTermRef[] seeList;
    private IndexTermRef[] seeAlsoList;
    private IndexTerm[] subTermList;

    // -----------------------------------------------------------------------

    public IndexTerm(String term) {
        this.term = term;
    }

    public void setSortAs(String sortAs) {
        this.sortAs = sortAs;
    }

    public String getSortAs() {
        return sortAs;
    }

    public void addAnchor(IndexAnchor anchor) {
        // Anchors are added in document order.
        if (anchorList == null) {
            anchorList = new IndexAnchor[] { anchor };
        } else {
            anchorList = ArrayUtil.append(anchorList, anchor);
        }
    }

    public IndexAnchor[] getAnchorList() {
        return anchorList;
    }

    public void addSee(IndexTermRef see) {
        if (seeList == null) {
            seeList = new IndexTermRef[] { see };
        } else {
            seeList = ArrayUtil.append(seeList, see);
        }
    }

    public void clearSeeList() {
        seeList = null;
    }

    public IndexTermRef[] getSeeList() {
        return seeList;
    }

    public void addSeeAlso(IndexTermRef seeAlso) {
        if (seeAlsoList == null) {
            seeAlsoList = new IndexTermRef[] { seeAlso };
        } else {
            seeAlsoList = ArrayUtil.append(seeAlsoList, seeAlso);
        }
    }

    public void clearSeeAlsoList() {
        seeAlsoList = null;
    }

    public IndexTermRef[] getSeeAlsoList() {
        return seeAlsoList;
    }

    public void addSubTerm(IndexTerm subTerm) {
        if (subTermList == null) {
            subTermList = new IndexTerm[] { subTerm };
        } else {
            subTermList = ArrayUtil.append(subTermList, subTerm);
        }
    }

    public IndexTerm[] getSubTermList() {
        return subTermList;
    }
}

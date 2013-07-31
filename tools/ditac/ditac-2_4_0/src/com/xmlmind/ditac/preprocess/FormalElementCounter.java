/*
 * Copyright (c) 2009-2010 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.preprocess;

/*package*/ final class FormalElementCounter {
    public final String type;

    private String prefix;
    private int nonChapterCount;
    private String partNumber;
    private String[] chapterNumber;
    private int perChapterCount;

    // -----------------------------------------------------------------------

    public FormalElementCounter(String type) {
        this.type = type;
        prefix = type + ".";
        nonChapterCount = 0;
        partNumber = null;
        chapterNumber = null;
        perChapterCount = 0;
    }

    public void traversing(ChunkEntry entry) {
        // Unlike part elements, a bookmap may contain only a single
        // appendices element. Therefore, no need to count appendices
        // elements.

        String[] num = entry.number;
        if (num.length > 0 && num[0].startsWith("part.")) {
            partNumber = num[0];
        } else {
            partNumber = null;
        }

        // The following, very simple, implementation works because a
        // chapter/appendix cannot have chapter/appendix descendants.

        // Inside a chapter or appendix? ---

        int index = -1;
        for (int i = 0; i < num.length; ++i) {
            if (num[i].startsWith("chapter.") ||
                num[i].startsWith("appendix.")) {
                index = i;
                break;
            }
        }

        if (index < 0) {
            // No, use nonChapterCount ---

            chapterNumber = null;
            perChapterCount = 0;
        } else {
            // Yes, use same or new perChapterCount ---

            boolean newChapterNumber;
            if (chapterNumber != null && index+1 == chapterNumber.length) {
                newChapterNumber = false;
                for (int i = 0; i <= index; ++i) {
                    if (!num[i].equals(chapterNumber[i])) {
                        newChapterNumber = true;
                        break;
                    }
                }
            } else {
                newChapterNumber = true;
            }

            if (newChapterNumber) {
                chapterNumber = new String[index+1];
                System.arraycopy(num, 0, chapterNumber, 0, index+1);
                perChapterCount = 0;
            }
        }
    }

    public void increment() {
        if (chapterNumber != null) {
            ++perChapterCount;
        } else {
            ++nonChapterCount;
        }
    }

    public String format() {
        StringBuilder buffer = new StringBuilder();

        if (chapterNumber != null) {
            for (int i = 0; i < chapterNumber.length; ++i) {
                if (i > 0) {
                    buffer.append(' ');
                }
                buffer.append(chapterNumber[i]);
            }

            buffer.append(' ');
            buffer.append(prefix);
            buffer.append(Integer.toString(perChapterCount));
        } else {
            // Note that in the case above, chapterNumber already includes the
            // number of its parent part, if any.

            if (partNumber != null) {
                buffer.append(partNumber);
                buffer.append(' ');
            }

            buffer.append(prefix);
            buffer.append(Integer.toString(nonChapterCount));
        }

        return buffer.toString();
    }
}

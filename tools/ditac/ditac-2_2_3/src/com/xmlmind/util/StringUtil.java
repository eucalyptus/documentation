/*
 * Copyright (c) 2002-2011 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of several XMLmind projects.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.util;

import java.util.StringTokenizer;
import java.util.ArrayList;

/**
 * A collection of utility functions (static methods) operating on Strings.
 */
public final class StringUtil {
    private StringUtil() {}

    /**
     * A ready-to-use empty list of Strings.
     */
    public static final String[] EMPTY_LIST = new String[0];

    /**
     * Splits specified string at whitespace character boundaries. Returns
     * list of parts.
     * 
     * @param s string to be split
     * @return list of parts
     */
    public static String[] split(String s) {
        StringTokenizer tokens = new StringTokenizer(s);
        String[] split = new String[tokens.countTokens()];

        for (int i = 0; i < split.length; ++i) {
            split[i] = tokens.nextToken();
        }

        return split;
    }

    /**
     * Splits String <tt>string</tt> at occurrences of char
     * <tt>separatorChar</tt>.
     * 
     * @param string the String to be split
     * @param separatorChar the char where to split
     * @return the list of substrings resulting from splitting String
     * <tt>string</tt> at occurrences of char <tt>separatorChar</tt>.
     * <p>Note that each occurrence of <tt>separatorChar</tt> specifies the
     * end of a substring. Therefore, the returned list may contain empty
     * substrings if consecutive <tt>separatorChar</tt>s are found in String
     * <tt>string</tt>.
     * <p>However, for consistency with all the other split methods, this
     * method returns an empty array for the empty string.
     */
    public static String[] split(String string, char separatorChar) {
        if (string.length() == 0)
            return EMPTY_LIST;

        // Count elements ---

        int elementCount = 0;
        int sep = 0;
        while ((sep = string.indexOf(separatorChar, sep)) >= 0) {
            ++elementCount;
            ++sep;
        } 
        ++elementCount;

        // Build element array ---

        String[] elements = new String[elementCount];

        elementCount = 0;
        sep = 0;
        int nextSep;
        while ((nextSep = string.indexOf(separatorChar, sep)) >= 0) {
             elements[elementCount++] = 
                 (sep == nextSep)? "" : string.substring(sep, nextSep);
             sep = nextSep + 1;
        } 
        elements[elementCount++] = string.substring(sep);

        return elements;
    }

    /*TEST_SPLIT
    public static final void main(String[] args) {
        String[] list = null;

        switch (args.length) {
        case 1:
            list = split(args[0]);
            break;
        case 2:
            if (args[1].length() == 1) {
                list = split(args[0], args[1].charAt(0));
                break;
            }
            //FALLTHROUGH
        default:
            System.err.println(
                "usage: com.xmlmind.util.StringUtil string separ?");
            System.exit(1);
        }

        for (int i = 0; i < list.length; ++i) 
            System.out.println("[" + i + "] \"" + list[i] + "\"");
    }
    TEST_SPLIT*/

    /**
     * Equivalent to {@link #join(String, String[])
     * join(Character.toString(separatorChar), strings)}.
     */
    public static String join(char separatorChar, String... strings) {
        return join(Character.toString(separatorChar), strings);
    }

    /**
     * Joins the items of the specified list of Strings using specified
     * separator.
     * 
     * @param separator the string used to join items
     * @param strings the list where items are to be joined
     * @return a string where all list items have been joined
     */
    public static String join(String separator, String... strings) {
        int count = strings.length;
        switch (count) {
        case 0:
            return "";
        case 1:
            return strings[0];
        default:
            {
                StringBuilder buffer = new StringBuilder();

                buffer.append(strings[0]);
                for (int i = 1; i < count; ++i) {
                    buffer.append(separator);
                    buffer.append(strings[i]);
                }

                return buffer.toString();
            }
        }
    }

    // -----------------------------------------------------------------------

    /**
     * Splits specified string at word boundaries, returning an array of lines
     * having at most specified number of characters.
     * 
     * @param text string to be split at word boundaries
     * @param maxLineLength the number of characters contained in a line
     * should not exceed this value
     * @return a (possibly empty) array of lines
     */
    public static final String[] wordWrap(String text, int maxLineLength) {
        ArrayList<String> wrappedLines = new ArrayList<String>();

        String[] lines = split(text, '\n');
        for (int i = 0; i < lines.length; ++i) {
            String line = lines[i];

            line = line.trim();
            if (line.length() == 0) {
                wrappedLines.add("");
                continue;
            }

            StringBuilder wrappedLine = new StringBuilder();

            StringTokenizer words = new StringTokenizer(line);
            while (words.hasMoreTokens()) {
                String word = words.nextToken();

                int wrappedLineLength = wrappedLine.length();
                if (wrappedLineLength > 0 && 
                    wrappedLineLength + word.length() > maxLineLength) {
                    wrappedLines.add(wrappedLine.toString());

                    wrappedLine = new StringBuilder();
                    wrappedLineLength = 0;
                }

                if (wrappedLineLength > 0)
                    wrappedLine.append(' ');
                wrappedLine.append(word);
            }

            if (wrappedLine.length() > 0)
                wrappedLines.add(wrappedLine.toString());
        }

        String[] result = new String[wrappedLines.size()];
        wrappedLines.toArray(result);

        return result;
    }

    /*TEST_WORD_WRAP
    public static void main(String[] args) {
        for (int i = 0; i < args.length; ++i) {
            String arg = StringUtil.replaceAll(args[i], "&#xA;", "\n");

            System.out.print("{");
            System.out.print(arg);
            System.out.println("}\n-->");

            String[] lines = StringUtil.wordWrap(arg, 40);
            System.out.print("{");
            for (int j = 0; j < lines.length; ++j) {
                if (j > 0)
                    System.out.println();
                System.out.print(lines[j]);
            }
            System.out.print("}");

            System.out.println();
        }
    }
    TEST_WORD_WRAP*/

    // -----------------------------------------------------------------------

    /**
     * Splits specified string in a manner which is similar to what is done
     * for command line arguments. Returns the list of ``command line
     * arguments''.
     * <p>Example: returns <code>{"one", "two", "three", " \"four\" ", "
     * 'five' "}</code> for input string:
     * <pre>one   "two"    'three'   " \"four\" "   " 'five' "</pre>
     * <p>Note that escaped sequences such as "\n" and "\t" contained in
     * specified string are left as is. The reason for this is that specified
     * string may contain any whitespace character including '\n' and '\t',
     * provided that these characters are contained in a quoted argument.
     */
    public static String[] splitArguments(String string) {
        ArrayList<String> list = new ArrayList<String>();
        char quote = 0;
        StringBuilder arg = null;

        int length = string.length();
        for (int i = 0; i < length; ++i) {
            char c = string.charAt(i);

            if (Character.isWhitespace(c)) {
                if (quote != 0) {
                    arg.append(c);
                } else {
                    if (arg != null) {
                        list.add(arg.toString());
                        arg = null;
                    }
                }
            } else {
                if (arg == null) {
                    arg = new StringBuilder();

                    switch (c) {
                    case '\"': case '\'':
                        quote = c;
                        break;
                    default:
                        arg.append(c);
                    }
                } else {
                    if (c == quote) {
                        int last = arg.length()-1;
                        if (last >= 0 && arg.charAt(last) == '\\') {
                            arg.setCharAt(last, quote);
                        } else {
                            list.add(arg.toString());
                            arg = null;
                            quote = 0;
                        }
                    } else {
                        arg.append(c);
                    }
                }
            }
        }

        if (arg != null) {
            list.add(arg.toString());
        }

        String[] args = new String[list.size()];
        return list.toArray(args);
    }

    /**
     * Inverse operation of {@link #splitArguments}. Returns ``command line''.
     * 
     * @see #quoteArgument
     */
    public static String joinArguments(String... args) {
        StringBuilder joined = new StringBuilder();

        for (int i = 0; i < args.length; ++i) {
            if (i > 0)
                joined.append(' ');
            joined.append(quoteArgument(args[i]));
        }

        return joined.toString();
    }

    /**
     * Quotes specified string using <tt>'\"'</tt> if needed to. Returns
     * quoted string.
     * <p>Note that whitespace characters such as '\n' and '\t' are not
     * escaped as "\n" and "\t". Instead, the whole string is quoted. This is
     * sufficient to allow it to contain any whitespace character.
     * 
     * @see #joinArguments
     */
    public static String quoteArgument(String arg) {
        int length = arg.length();

        boolean needQuotes;
        if (length == 0) {
            needQuotes = true;
        } else {
            switch (arg.charAt(0)) {
            case '\"': case '\'':
                needQuotes = true;
                break;
            default:
                {
                    needQuotes = false;
                    for (int i = 0; i < length; ++i) {
                        if (Character.isWhitespace(arg.charAt(i))) {
                            needQuotes = true;
                            break;
                        }
                    }
                }
            }
        }
        if (!needQuotes)
            return arg;

        StringBuilder quoted = new StringBuilder();
        quoted.append('\"');
        for (int i = 0; i < length; ++i) {
            char c = arg.charAt(i);

            if (c == '\"') 
                quoted.append("\\\"");
            else
                quoted.append(c);
        }
        quoted.append('\"');

        return quoted.toString();
    }

    /*TEST_SPLIT_ARGS
    public static void main(String[] args) {
        for (int i = 0; i < args.length; ++i) {
            String arg = StringUtil.replaceAll(args[i], "&#xA;", "\n");
            String[] split = splitArguments(arg);

            System.out.print('{');
            System.out.print(arg);
            System.out.println('}');
            System.out.print("JOINED {");
            System.out.print(joinArguments(split));
            System.out.println('}');
            for (int j = 0; j < split.length; ++j) {
                System.out.print("\tPART {");
                System.out.print(split[j]);
                System.out.println('}');
            }
            System.out.println();
        }
        System.out.flush();
    }
    TEST_SPLIT_ARGS*/

    // -----------------------------------------------------------------------

    /**
     * Equivalent to {@link
     * #substituteVars(String, char[], Object[], String[], String, boolean)
     * substituteVars(text, names, values, null, null, false)}.
     */
    public static String substituteVars(String text,
                                        char[] names, Object[] values) {
        return substituteVars(text, names, values, null, null, false);
    }

    /**
     * Equivalent to {@link
     * #substituteVars(String, char[], Object[], String[], String, boolean)
     * substituteVars(text, names, values, args, allArgs, false)}.
     */
    public static String substituteVars(String text, 
                                        char[] names, Object[] values, 
                                        String[] args, String allArgs) {
        return substituteVars(text, names, values, args, allArgs, false);
    }

    /**
     * Returns specified text where %0, %1, ..., %9, %* and %<i>X</i>, 
     * %<i>Y</i>, etc, variables have been subsituted by specified values.
     * <p>"%%" may be used to escape character "%".
     * <p>A variable, whether named or not, %<i>X</i> may also be specified as
     * %{<i>X</i>} etc.
     * 
     * @param text text containing variables
     * @param names the one-character long name of named variables %<i>X</i>,
     * %<i>Y</i>, etc.
     * @param values the values of named variables %<i>X</i>, %<i>Y</i>, etc.
     * <p>These objects are converted to strings using the
     * <code>toString()</code> method.
     * <p>When there are no enough values, the corresponding variables are not
     * replaced.
     * @param args the values of <tt>%0</tt>, <tt>%1</tt>, ..., 
     * <tt>%9</tt> variables.
     * <p>When there are no enough values, the corresponding variables are
     * replaced by the empty string.
     * @param allArgs the values of <tt>%*</tt> variable. 
     * <p>May be <code>null</code>, in which case, <tt>args</tt> are joined 
     * using {@link #joinArguments} to form <tt>allArgs</tt>.
     * @param allowForeignVars if <code>true</code>, unknown variables
     * specified as %{<i>var_name</i>} are assumed to be system properties or
     * environment variables and are subsituted as such.
     * @return specified text where variables have been subsituted with their
     * values
     */
    public static String substituteVars(String text, 
                                        char[] names, Object[] values, 
                                        String[] args, String allArgs,
                                        boolean allowForeignVars) {
        StringBuilder buffer = new StringBuilder();
        int state = 0;
        
        int length = text.length();
        for (int i = 0; i < length; ++i) {
            char c = text.charAt(i);

            switch (state) {
            case 1: // Seen "%"
                switch (c) {
                case '%':
                    buffer.append('%');
                    state = 0;
                    break;

                case '{':
                    state = 2;
                    break;

                case '*':
                case '0': case '1': case '2': case '3': case '4':
                case '5': case '6': case '7': case '8': case '9':
                    if (args == null) {
                        // Not a variable.
                        buffer.append('%');
                        buffer.append(c);
                    } else {
                        if (c == '*') {
                            buffer.append((allArgs == null)?
                                          joinArguments(args) : allArgs);
                        } else {
                            // c is a digit ---

                            int j = i+1;
                            while (j < length) {
                                char cc = text.charAt(j);
                                if (cc >= '0' && cc <= '9') {
                                    ++j;
                                } else {
                                    break;
                                }
                            }
                            String indexSpec = text.substring(i, j);

                            int index = -1;
                            try {
                                index = Integer.parseInt(indexSpec);
                            } catch (NumberFormatException cannotHappen) {}

                            if (index >= 0 && index < args.length) {
                                buffer.append(args[index]);
                            } else {
                                // Not a variable.
                                buffer.append('%');
                                buffer.append(indexSpec);
                            }

                            i = j-1;
                        }
                    }
                    state = 0;
                    break;

                default:
                    if (names == null) {
                        // Not a variable.
                        buffer.append('%');
                        buffer.append(c);
                    } else {
                        Object value = null;
                        for (int j = 0; j < names.length; ++j) {
                            if (c == names[j]) {
                                value = values[j];
                                break;
                            }
                        }
                        if (value == null) {
                            // Not a variable.
                            buffer.append('%');
                            buffer.append(c);
                        } else {
                            buffer.append(value.toString());
                        }
                    }
                    state = 0;
                }
                break;

            case 2: // Seen "%{"
                switch (c) {
                case '*':
                case '0': case '1': case '2': case '3': case '4':
                case '5': case '6': case '7': case '8': case '9':
                    if (args == null) {
                        // Not a variable.
                        buffer.append("%{");
                        buffer.append(c);
                        state = 0;
                    } else {
                        if (c == '*') {
                            buffer.append((allArgs == null)?
                                          joinArguments(args) : allArgs);
                            state = 3;
                        } else {
                            // c is a digit ---

                            int j = i+1;
                            while (j < length) {
                                char cc = text.charAt(j);
                                if (cc >= '0' && cc <= '9') {
                                    ++j;
                                } else {
                                    break;
                                }
                            }
                            String indexSpec = text.substring(i, j);

                            int index = -1;
                            try {
                                index = Integer.parseInt(indexSpec);
                            } catch (NumberFormatException cannotHappen) {}

                            if (index >= 0 && index < args.length) {
                                buffer.append(args[index]);
                                state = 3;
                            } else {
                                // Not a variable.
                                buffer.append("%{");
                                buffer.append(indexSpec);
                                state = 0;
                            }

                            i = j-1;
                        }
                    }
                    break;

                default:
                    if (names == null) {
                        if (allowForeignVars) {
                            int end = text.indexOf('}', i+1);
                            if (end > i+1) {
                                String value = getForeignVar(text, i, end);
                                if (value != null) {
                                    buffer.append(value);
                                    state = 3;
                                    i = end-1;
                                }
                            }
                        }

                        if (state != 3) {
                            // Not a variable.
                            buffer.append("%{");
                            buffer.append(c);
                            state = 0;
                        }
                    } else {
                        // Note that "%{%}" and "%{{}" are supported.

                        Object found = null;

                        for (int j = 0; j < names.length; ++j) {
                            if (c == names[j]) {
                                found = values[j];
                                break;
                            }
                        }

                        if (found != null &&
                            i+1 < length &&
                            text.charAt(i+1) == '}') {
                            buffer.append(found.toString());
                            state = 3;
                        } else {
                            if (allowForeignVars) {
                                int end = text.indexOf('}', i+1);
                                if (end > i+1) {
                                    String value = getForeignVar(text, i, end);
                                    if (value != null) {
                                        buffer.append(value);
                                        state = 3;
                                        i = end-1;
                                    }
                                }
                            }

                            if (state != 3) {
                                // Not a variable.
                                buffer.append("%{");
                                buffer.append(c);
                                state = 0;
                            }
                        }
                    }
                }
                break;
                
            case 3: // Seen "%{x"
                if (c != '}') {
                    buffer.append(c);
                }
                state = 0;
                break;

            default:
                if (c == '%') {
                    state = 1;
                } else {
                    buffer.append(c);
                }
            }
        }

        switch (state) {
        case 1:
            buffer.append('%');
            break;
        case 2:
            buffer.append("%{");
            break;
        }

        return buffer.toString();
    }

    private static String getForeignVar(String text, int start, int end) {
        String value = null;

        String name = text.substring(start, end).trim();
        if (name.length() > 0) {
            value = System.getProperty(name);
            if (value == null) {
                value = System.getenv(name);
            }
        }

        return value;
    }

    /*TEST_SUBSTITUTE_VARS
    public static void main(String[] args) {
        String text = null;
        ArrayList<String> argList = new ArrayList<String>();
        ArrayList<Object> varList = new ArrayList<Object>();

        if (args.length > 2) {
            text = args[0];

            for (int i = 1; i < args.length; ++i) {
                String arg = args[i];

                if (arg.startsWith("-")) {
                    if (arg.length() != 2 || i + 1 >= args.length) {
                        // Syntax error.
                        text = null;
                        break;
                    }

                    varList.add(new Character(arg.charAt(1)));
                    ++i;
                    varList.add(args[i]);
                } else {
                    argList.add(arg);
                }
            }
        }

        if (text == null || (argList.size() == 0 && varList.size() == 0)) {
            System.err.println(
                "usage: java com.xmlmind.util.StringUtil" +
                " text (-c value | value) ... (-c value | value)");
            System.exit(1);
        }

        String[] args2;
        int count = argList.size();
        if (count == 0) {
            args2 = null;
        } else {
            args2 = new String[count];
            argList.toArray(args2);
        }

        char[] varNames;
        String[] varValues;
        count = varList.size();
        if (count == 0) {
            varNames = null;
            varValues = null;
        } else {
            varNames = new char[count/2];
            varValues = new String[count/2];

            for (int k = 0; k < count; k += 2) {
                int l = k/2;
                varNames[l] = ((Character) varList.get(k)).charValue();
                varValues[l] = (String) varList.get(k+1);
            }
        }

        System.out.println("'" + text + "' where:");

        if (args2 != null) {
            for (int i = 0; i < args2.length; ++i)
                System.out.println("\t%" + i + " = '" + args2[i] + "'");
        }

        if (varNames != null) {
            for (int i = 0; i < varNames.length; ++i)
                System.out.println("\t%" + varNames[i] + " = '" + 
                                   varValues[i] + "'");
        }

        System.out.println("gives '" + 
                           substituteVars(text, varNames, varValues, 
                                          args2, null, true) +
                           "'");
    }
    TEST_SUBSTITUTE_VARS*/

    // -----------------------------------------------------------------------

    /**
     * Replaces substring <code>oldSub</code> by substring <code>newSub</code>
     * inside String <code>string</code>.
     * 
     * @param string the String where replacements are to be performed
     * @param oldSub the substring to replace
     * @param newSub the replacement substring
     * @return a string where all replacements have been performed
     * @see java.lang.String#replace
     */
    public static String replaceAll(String string, 
                                    String oldSub, String newSub) {
        StringBuilder replaced = new StringBuilder();
        int oldSubLength = oldSub.length();
        int begin, end;

        begin = 0;
        while ((end = string.indexOf(oldSub, begin)) >= 0) {
            if (end > begin) {
                replaced.append(string.substring(begin, end));
            }
            replaced.append(newSub);
            begin = end + oldSubLength;
        }
        if (begin < string.length()) {
            replaced.append(string.substring(begin));
        }

        return replaced.toString();
    }

    /*TEST_REPLACE_ALL
    public static final void main(String[] args) {
        System.out.println("'" +
                           StringUtil.replaceAll(args[0], args[1], args[2]) +
                           "'");
    }
    TEST_REPLACE_ALL*/

    // -----------------------------------------------------------------------

    /**
     * Returns the specified string with its first character converted to
     * upper case.
     * 
     * @param string the String to be processed
     * @return the specified string with its first character converted to
     * upper case
     */
    public static String capitalize(String string) {
        int length = string.length();
        if (length == 0) {
            return string;
        } else if (length == 1) {
            return string.toUpperCase();
        } else {
            return (Character.toUpperCase(string.charAt(0)) + 
                    string.substring(1));
        }
    }

    /**
     * Returns the specified string with its first character converted to
     * lower case.
     * 
     * @param string the String to be processed
     * @return the specified string with its first character converted to
     * lower case
     */
    public static String uncapitalize(String string) {
        int length = string.length();
        if (length == 0) {
            return string;
        } else if (length == 1) {
            return string.toLowerCase();
        } else {
            return (Character.toLowerCase(string.charAt(0)) + 
                    string.substring(1));
        }
    }

    // -----------------------------------------------------------------------

    /**
     * Like {@link #escape} but puts a double quote character (<tt>'\"'</tt>)
     * around the escaped string.
     */
    public static String quote(String string) {
        StringBuilder buffer = new StringBuilder();

        buffer.append('\"');
        escape(string, buffer);
        buffer.append('\"');

        return buffer.toString();
    }

    /**
     * Returns the specified string with all non-ASCII characters and
     * non-printable ASCII characters replaced by the corresponding Java
     * escape sequences (that is <tt>'\n'</tt>, <tt>'\u00E9'</tt>, etc).
     * 
     * @param string the String to be escaped
     * @return the specified string with all non-ASCII characters and
     * non-printable ASCII characters replaced by the corresponding Java
     * escape sequences
     */
    public static String escape(String string) {
        StringBuilder buffer = new StringBuilder();
        escape(string, buffer);
        return buffer.toString();
    }

    /**
     * Same as {@link #escape(String)} except that the escaped string is
     * appended to specified buffer.
     */
    public static void escape(String string, StringBuilder buffer) {
        int length = string.length();
        for (int i = 0; i < length; ++i) {
            char c = string.charAt(i);

            switch (c) {
            case '\b':
                buffer.append("\\b");
                break;
            case '\t':
                buffer.append("\\t");
                break;
            case '\n':
                buffer.append("\\n");
                break;
            case '\f':
                buffer.append("\\f");
                break;
            case '\r':
                buffer.append("\\r");
                break;
            case '\"':
                buffer.append("\\\"");
                break;
            case '\'':
                buffer.append("\\'");
                break;
            case '\\':
                buffer.append("\\\\");
                break;
            default:
                if (c >= 0x0020 && c <= 0x007E) {
                    buffer.append(c);
                } else {
                    escape(c, buffer);
                }
            }
        }
    }

    /**
     * Returns the <tt>\\u<i>XXXX</i></tt> Java escape sequence corresponding
     * to specified character.
     * 
     * @param c the character to be escaped
     * @return A <tt>\\u<i>XXXX</i></tt> Java escape sequence
     */
    public static String escape(char c) {
        StringBuilder buffer = new StringBuilder();
        escape(c, buffer);
        return buffer.toString();
    }

    /**
     * Same as {@link #escape(char)} expect that the <tt>\\u<i>XXXX</i></tt>
     * Java escape sequence is appended to specified buffer.
     */
    public static void escape(char c, StringBuilder buffer) {
        buffer.append("\\u");

        String hex = Integer.toString((int) c, 16);

        int hexLength = hex.length();
        while (hexLength < 4) {
            buffer.append('0');
            ++hexLength;
        }

        buffer.append(hex);
    }

    /**
     * Like {@link #unescape} but removes the double quote characters 
     * (<tt>'\"'</tt>), if any, before unescaping the string.
     */
    public static String unquote(String string) {
        int length = string.length();

        if (length >= 2 && 
            string.charAt(0) == '\"' && string.charAt(length-1) == '\"')
            return unescape(string, 1, length-2);
        else
            return unescape(string, 0, length);
    }

    /**
     * Returns the specified string with Java escape sequences (that is
     * <tt>'\n'</tt>, <tt>'\u00E9'</tt>, etc) replaced by the corresponding
     * character.
     * 
     * @param string the String to be unescaped
     * @return the specified string with Java escape sequences replaced by the
     * corresponding character
     */
    public static String unescape(String string) {
        return unescape(string, 0, string.length());
    }

    private static String unescape(String string, int offset, int length) {
        StringBuilder buffer = new StringBuilder();

        int end = offset + length;
        for (int i = offset; i < end; ++i) {
            char c = string.charAt(i);

            switch (c) {
            case '\\':
                if (i + 1 == end) {
                    buffer.append(c);
                } else {
                    switch (string.charAt(i+1)) {
                    case 'b':
                        buffer.append('\b');
                        ++i;
                        break;
                    case 't':
                        buffer.append('\t');
                        ++i;
                        break;
                    case 'n':
                        buffer.append('\n');
                        ++i;
                        break;
                    case 'f':
                        buffer.append('\f');
                        ++i;
                        break;
                    case 'r':
                        buffer.append('\r');
                        ++i;
                        break;
                    case '\"':
                        buffer.append('\"');
                        ++i;
                        break;
                    case '\'':
                        buffer.append('\'');
                        ++i;
                        break;
                    case '\\':
                        buffer.append('\\');
                        ++i;
                        break;
                    case 'u':
                        if (i + 5 < end) {
                            int escaped = -1;
                            try {
                                escaped =
                                    Integer.parseInt(string.substring(i+2,i+6),
                                                     16);
                            } catch (NumberFormatException ignored) {}

                            if (escaped >= 0) {
                                buffer.append((char) escaped);
                                i += 5;
                                break;
                            }
                        }
                        /*FALLTHROUGH*/
                    default:
                        buffer.append(c);
                    }
                }
                break;
            default:
                buffer.append(c);
            }
        }
        
        return buffer.toString();
    }

    /*TEST_QUOTE
    public static final void main(String[] args) {
        for (int i = 0; i < args.length; ++i) {
            String arg = args[i];
            String arg2 = quote(arg);

            System.out.print("'");
            System.out.print(arg);
            System.out.print("' = ");
            System.out.print(arg2);
            System.out.print(" = ");
            System.out.println(unquote(arg2));

            System.out.print("unquote '");
            System.out.print(arg);
            System.out.print("' --> ");
            System.out.println(unquote(arg));
        }
    }
    TEST_QUOTE*/
}

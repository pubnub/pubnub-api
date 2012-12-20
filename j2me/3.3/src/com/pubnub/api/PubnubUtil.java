/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.pubnub.api;

import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Vector;

/**
 *
 * @author Pubnub
 */
class PubnubUtil {

    public static String[] splitString(String source, String delimiter) {

        int delimiterCount = 0;
        int index = 0;
        String tmpStr = source;

        String[] splittedList;

        while ((index = tmpStr.indexOf(delimiter)) != -1) {

            tmpStr = tmpStr.substring(index + delimiter.length());
            delimiterCount++;
        }

        splittedList = new String[delimiterCount+1];

        int counter = 0;
        tmpStr = source;


        do  {
            int nextIndex = tmpStr.indexOf(delimiter, index + 1);

            if (nextIndex != -1) {
                splittedList[counter++] = tmpStr.substring(index + delimiter.length(), nextIndex);
                tmpStr = tmpStr.substring(nextIndex);

            } else {
                splittedList[counter++] = tmpStr.substring(index + delimiter.length());
                tmpStr = tmpStr.substring(index + 1);
            }
        } while ((index = tmpStr.indexOf(delimiter)) != -1 );

        return splittedList;
    }

    public static String joinString(String[] sourceArray, String delimiter) {
        StringBuffer sb = new StringBuffer();

        for (int i = 0; i < sourceArray.length - 1; i++) {
            sb.append(sourceArray[i]).append(delimiter);
        }
        sb.append(sourceArray[sourceArray.length - 1]);

        return sb.toString();
    }

    public static String urlEncode(String sUrl) {
        StringBuffer urlOK = new StringBuffer();
        for (int i = 0; i < sUrl.length(); i++) {
            char ch = sUrl.charAt(i);
            switch (ch) {
                case '<':
                    urlOK.append("%3C");
                    break;
                case '>':
                    urlOK.append("%3E");
                    break;
                case '/':
                    urlOK.append("%2F");
                    break;
                case ' ':
                    urlOK.append("%20");
                    break;
                case ':':
                    urlOK.append("%3A");
                    break;
                case '-':
                    urlOK.append("%2D");
                    break;
                default:
                    urlOK.append(ch);
                    break;
            }
        }
        return urlOK.toString();
    }
    

	public static synchronized String[] hashtableKeysToArray(Hashtable ht) {
		Vector v = new Vector();
		String[] sa = null;
		int count = 0;

		Enumeration e = ht.keys();
		while (e.hasMoreElements()) {
			String s = (String) e.nextElement();
			v.addElement(s);
			count++;
		}

		sa = new String[count];

		v.copyInto(sa);

		return sa;

	}

	public static synchronized String hashTableKeysToDelimitedString(Hashtable ht,
			String delimiter) {

		StringBuffer sb = new StringBuffer();

		boolean first = true;

		Enumeration e = ht.keys();

		while (e.hasMoreElements()) {

			String s = (String) e.nextElement();

			if (first) {

				sb.append(s);
				first = false;

			} else {

				sb.append(delimiter).append(s);

			}

		}

		return sb.toString();

	}
}

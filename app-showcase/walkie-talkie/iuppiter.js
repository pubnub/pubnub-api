/**
$Id: Iuppiter.js 3026 2010-06-23 10:03:13Z Bear $

Copyright (c) 2010 Nuwa Information Co., Ltd, and individual contributors.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice,
     this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in the
     documentation and/or other materials provided with the distribution.

  3. Neither the name of Nuwa Information nor the names of its contributors
     may be used to endorse or promote products derived from this software
     without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

$Author: Bear $
$Date: 2010-06-23 18:03:13 +0800 (星期三, 23 六月 2010) $
$Revision: 3026 $
*/

if (typeof Iuppiter === 'undefined')
    Iuppiter = {
        version: '$Revision: 3026 $'.substring(11).replace(" $", ""),
    };

/**
 * Convert string value to a byte array.
 *
 * @param {String} input The input string value.
 * @return {Array} A byte array from string value.
 */
Iuppiter.toByteArray = function(input) {
    var b = [], i, unicode;
    for(i = 0; i < input.length; i++) {
        unicode = input.charCodeAt(i);
        // 0x00000000 - 0x0000007f -> 0xxxxxxx
        if (unicode <= 0x7f) {
            b.push(unicode);
        // 0x00000080 - 0x000007ff -> 110xxxxx 10xxxxxx
        } else if (unicode <= 0x7ff) {
            b.push((unicode >> 6) | 0xc0);
            b.push((unicode & 0x3F) | 0x80);
        // 0x00000800 - 0x0000ffff -> 1110xxxx 10xxxxxx 10xxxxxx
        } else if (unicode <= 0xffff) {
            b.push((unicode >> 12) | 0xe0);
            b.push(((unicode >> 6) & 0x3f) | 0x80);
            b.push((unicode & 0x3f) | 0x80);
        // 0x00010000 - 0x001fffff -> 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
        } else {
            b.push((unicode >> 18) | 0xf0);
            b.push(((unicode >> 12) & 0x3f) | 0x80);
            b.push(((unicode >> 6) & 0x3f) | 0x80);
            b.push((unicode & 0x3f) | 0x80);
        }
    }

    return b;
}

/**
 * Base64 Class.
 * Reference: http://code.google.com/p/javascriptbase64/
 *            http://www.stringify.com/static/js/base64.js
 * They both under MIT License.
 */
Iuppiter.Base64 = {

    /// Encoding characters table.
    CA: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",

    /// Encoding characters table for url safe encoding.
    CAS: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_",

    /// Decoding reference table.
    IA: new Array(256),

    /// Decoding reference table for url safe encoded string.
    IAS: new Array(256),

    /**
 * Constructor.
 */
    init: function(){
        /// Initialize variables for Base64 namespace.
        var i;

        for (i = 0; i < 256; i++) {
            Iuppiter.Base64.IA[i] = -1;
            Iuppiter.Base64.IAS[i] = -1;
        }

        for (i = 0, iS = Iuppiter.Base64.CA.length; i < iS; i++) {
            Iuppiter.Base64.IA[Iuppiter.Base64.CA.charCodeAt(i)] = i;
            Iuppiter.Base64.IAS[Iuppiter.Base64.CAS.charCodeAt(i)] = i;
        }

        Iuppiter.Base64.IA['='] = Iuppiter.Base64.IAS['='] = 0;
    },

    /**
 * Encode base64.
 *
 * @param {Array|String} input A byte array or a string.
 * @param {Boolean} urlsafe True if you want to make encoded string is url
 *                          safe.
 * @return {String} Encoded base64 string.
 */
    encode: function(input, urlsafe) {
        var ca, dArr, sArr, sLen,
            eLen, dLen, s, d, left,
            i;

        if(urlsafe)
            ca = Iuppiter.Base64.CAS;
        else
            ca = Iuppiter.Base64.CA;

        if(input.constructor == Array)
            sArr = input;
        else
            sArr = Iuppiter.toByteArray(input);

        sLen = sArr.length;

        eLen = (sLen / 3) * 3;              // Length of even 24-bits.
        dLen = ((sLen - 1) / 3 + 1) << 2;   // Length of returned array
        dArr = new Array(dLen);

        // Encode even 24-bits
        for (s = 0, d = 0; s < eLen;) {
            // Copy next three bytes into lower 24 bits of int, paying attension to sign.
            i = (sArr[s++] & 0xff) << 16 | (sArr[s++] & 0xff) << 8 |
                (sArr[s++] & 0xff);

            // Encode the int into four chars
            dArr[d++] = ca.charAt((i >> 18) & 0x3f);
            dArr[d++] = ca.charAt((i >> 12) & 0x3f);
            dArr[d++] = ca.charAt((i >> 6) & 0x3f);
            dArr[d++] = ca.charAt(i & 0x3f);
        }

        // Pad and encode last bits if source isn't even 24 bits.
        left = sLen - eLen; // 0 - 2.
        if (left > 0) {
            // Prepare the int
            i = ((sArr[eLen] & 0xff) << 10) |
                 (left == 2 ? ((sArr[sLen - 1] & 0xff) << 2) : 0);

            // Set last four chars
            dArr[dLen - 4] = ca.charAt(i >> 12);
            dArr[dLen - 3] = ca.charAt((i >> 6) & 0x3f);
            dArr[dLen - 2] = left == 2 ? ca.charAt(i & 0x3f) : '=';
            dArr[dLen - 1] = '=';
        }

        return dArr.join("");
    },

    /**
 * Decode base64 encoded string or byte array.
 *
 * @param {Array|String} input A byte array or encoded string.
 * @param {Object} urlsafe True if the encoded string is encoded by urlsafe.
 * @return {Array|String} A decoded byte array or string depends on input
 *                        argument's type.
 */
    decode: function(input, urlsafe) {
        var ia, dArr, sArr, sLen, bytes,
            sIx, eIx, pad, cCnt, sepCnt, len,
            d, cc, left,
            i, j, r;

        if(urlsafe)
            ia = Iuppiter.Base64.IAS;
        else
            ia = Iuppiter.Base64.IA;

        if(input.constructor == Array) {
            sArr = input;
            bytes = true;
        }
        else {
            sArr = Iuppiter.toByteArray(input);
            bytes = false;
        }

        sLen = sArr.length;

        sIx = 0;
        eIx = sLen - 1;    // Start and end index after trimming.

        // Trim illegal chars from start
        while (sIx < eIx && ia[sArr[sIx]] < 0)
            sIx++;

        // Trim illegal chars from end
        while (eIx > 0 && ia[sArr[eIx]] < 0)
            eIx--;

        // get the padding count (=) (0, 1 or 2)
        // Count '=' at end.
        pad = sArr[eIx] == '=' ? (sArr[eIx - 1] == '=' ? 2 : 1) : 0;
        cCnt = eIx - sIx + 1;   // Content count including possible separators
        sepCnt = sLen > 76 ? (sArr[76] == '\r' ? cCnt / 78 : 0) << 1 : 0;

        // The number of decoded bytes
        len = ((cCnt - sepCnt) * 6 >> 3) - pad;
        dArr = new Array(len);       // Preallocate byte[] of exact length

        // Decode all but the last 0 - 2 bytes.
        d = 0;
        for (cc = 0, eLen = (len / 3) * 3; d < eLen;) {
            // Assemble three bytes into an int from four "valid" characters.
            i = ia[sArr[sIx++]] << 18 | ia[sArr[sIx++]] << 12 |
                ia[sArr[sIx++]] << 6 | ia[sArr[sIx++]];

            // Add the bytes
            dArr[d++] = (i >> 16) & 0xff;
            dArr[d++] = (i >> 8) & 0xff;
            dArr[d++] = i & 0xff;

            // If line separator, jump over it.
            if (sepCnt > 0 && ++cc == 19) {
                sIx += 2;
                cc = 0;
            }
        }

        if (d < len) {
            // Decode last 1-3 bytes (incl '=') into 1-3 bytes
            i = 0;
            for (j = 0; sIx <= eIx - pad; j++)
                i |= ia[sArr[sIx++]] << (18 - j * 6);

            for (r = 16; d < len; r -= 8)
                dArr[d++] = (i >> r) & 0xff;
        }

        if(bytes) {
            return dArr;
        }
        else {
            for(i = 0; i < dArr.length; i++)
                dArr[i] = String.fromCharCode(dArr[i]);

            return dArr.join('');
        }
    }
};

Iuppiter.Base64.init();

(function() {

// Constants was used for compress/decompress function.
NBBY = 8,
MATCH_BITS = 6,
MATCH_MIN = 3,
MATCH_MAX = ((1 << MATCH_BITS) + (MATCH_MIN - 1)),
OFFSET_MASK = ((1 << (16 - MATCH_BITS)) - 1),
LEMPEL_SIZE = 256;

/**
 * Compress string or byte array using fast and efficient algorithm.
 *
 * Because of weak of javascript's natural, many compression algorithm
 * become useless in javascript implementation. The main problem is
 * performance, even the simple Huffman, LZ77/78 algorithm will take many
 * many time to operate. We use LZJB algorithm to do that, it suprisingly
 * fulfills our requirement to compress string fastly and efficiently.
 *
 * Our implementation is based on
 * http://src.opensolaris.org/source/raw/onnv/onnv-gate/
 * usr/src/uts/common/os/compress.c
 * It is licensed under CDDL.
 *
 * Please note it depends on toByteArray utility function.
 *
 * @param {String|Array} input The string or byte array that you want to
 *                             compress.
 * @return {Array} Compressed byte array.
 */
Iuppiter.compress = function(input) {
    var sstart, dstart = [], slen,
        src = 0, dst = 0,
        cpy, copymap,
        copymask = 1 << (NBBY - 1),
        mlen, offset,
        hp,
        lempel = new Array(LEMPEL_SIZE),
        i, bytes;

    // Initialize lempel array.
    for(i = 0; i < LEMPEL_SIZE; i++)
        lempel[i] = 3435973836;

    // Using byte array or not.
    if(input.constructor == Array) {
        sstart = input;
        bytes = true;
    }
    else {
        sstart = Iuppiter.toByteArray(input);
        bytes = false;
    }

    slen = sstart.length;

    while (src < slen) {
        if ((copymask <<= 1) == (1 << NBBY)) {
            if (dst >= slen - 1 - 2 * NBBY) {
                mlen = slen;
                for (src = 0, dst = 0; mlen; mlen--)
                    dstart[dst++] = sstart[src++];
                return dstart;
            }
            copymask = 1;
            copymap = dst;
            dstart[dst++] = 0;
        }
        if (src > slen - MATCH_MAX) {
            dstart[dst++] = sstart[src++];
            continue;
        }
        hp = ((sstart[src] + 13) ^
              (sstart[src + 1] - 13) ^
               sstart[src + 2]) &
             (LEMPEL_SIZE - 1);
        offset = (src - lempel[hp]) & OFFSET_MASK;
        lempel[hp] = src;
        cpy = src - offset;
        if (cpy >= 0 && cpy != src &&
            sstart[src] == sstart[cpy] &&
            sstart[src + 1] == sstart[cpy + 1] &&
            sstart[src + 2] == sstart[cpy + 2]) {
            dstart[copymap] |= copymask;
            for (mlen = MATCH_MIN; mlen < MATCH_MAX; mlen++)
                if (sstart[src + mlen] != sstart[cpy + mlen])
                    break;
            dstart[dst++] = ((mlen - MATCH_MIN) << (NBBY - MATCH_BITS)) |
                            (offset >> NBBY);
            dstart[dst++] = offset;
            src += mlen;
        } else {
            dstart[dst++] = sstart[src++];
        }
    }

    return dstart;
};

/**
 * Decompress string or byte array using fast and efficient algorithm.
 *
 * Our implementation is based on
 * http://src.opensolaris.org/source/raw/onnv/onnv-gate/
 * usr/src/uts/common/os/compress.c
 * It is licensed under CDDL.
 *
 * Please note it depends on toByteArray utility function.
 *
 * @param {String|Array} input The string or byte array that you want to
 *                             compress.
 * @param {Boolean} _bytes Returns byte array if true otherwise string.
 * @return {String|Array} Decompressed string or byte array.
 */
Iuppiter.decompress = function(input, _bytes) {
    var sstart, dstart = [], slen,
        src = 0, dst = 0,
        cpy, copymap,
        copymask = 1 << (NBBY - 1),
        mlen, offset,
        i, bytes, get;
        
    // Using byte array or not.
    if(input.constructor == Array) {
        sstart = input;
        bytes = true;
    }
    else {
        sstart = Iuppiter.toByteArray(input);
        bytes = false;
    }    
    
    // Default output string result.
    if(typeof(_bytes) == 'undefined')
        bytes = false;
    else
        bytes = _bytes;
    
    slen = sstart.length;    
    
    get = function() {
        if(bytes) {
            return dstart;
        }
        else {
            // Decompressed string.
            for(i = 0; i < dst; i++)
                dstart[i] = String.fromCharCode(dstart[i]);

            return dstart.join('')
        }
    };   
            
	while (src < slen) {
		if ((copymask <<= 1) == (1 << NBBY)) {
			copymask = 1;
			copymap = sstart[src++];
		}
		if (copymap & copymask) {
			mlen = (sstart[src] >> (NBBY - MATCH_BITS)) + MATCH_MIN;
			offset = ((sstart[src] << NBBY) | sstart[src + 1]) & OFFSET_MASK;
			src += 2;
			if ((cpy = dst - offset) >= 0)
				while (--mlen >= 0)
					dstart[dst++] = dstart[cpy++];
			else
				/*
				 * offset before start of destination buffer
				 * indicates corrupt source data
				 */
				return get();
		} else {
			dstart[dst++] = sstart[src++];
		}
	}
    
	return get();
};

})();

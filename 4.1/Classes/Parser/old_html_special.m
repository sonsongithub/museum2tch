//
//  old_html_special.m
//  2tch
//
//  Created by sonson on 09/02/15.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "old_html_special.h"

int code_length[] = {
0,
0,
13,
37,
59,
72,
61,
7,
1,
};
int code_number_length[] = {
0,
0,
4,
156,
90,
};
char *code_l2[13] = {
"lt",	// 0x3C, < , less-than sign
"ge",	// 0x2265, ?, greater-than or equal to
"le",	// 0x2264, ?, less-than or equal to
"gt",	// 0x3E, > , greater-than sign
"ne",	// 0x2260, ≠, not equal to
"or",	// 0x2228, ∨, logical or = vee
"Mu",	// 0x39C, Μ, greek capital letter mu
"Nu",	// 0x39D, Ν, greek capital letter nu
"Pi",	// 0x3A0, Π, greek capital letter pi
"ni",	// 0x220B, ∋, contains as member
"pi",	// 0x3C0, π, greek small letter pi
"mu",	// 0x3BC, μ, greek small letter mu
"nu",	// 0x3BD, ν, greek small letter nu
};
char *code_l3[37] = {
"Tau",	// 0x3A4, Τ, greek capital letter tau
"#xi",	// 0x3BE, ξ, greek small letter xi
"yen",	// 0xA5, ¥, yen sign = yuan sign
"not",	// 0xAC, ¬, not sign
"shy",	// 0xAD, ­, soft hyphen = discretionary hyphen
"reg",	// 0xAE, ®, registered sign = registered trade mark sign
"eta",	// 0x3B7, η, greek small letter eta
"deg",	// 0xB0, °, degree sign
"Psi",	// 0x3A8, Ψ, greek capital letter psi
"Chi",	// 0x3A7, Χ, greek capital letter chi
"Phi",	// 0x3A6, Φ, greek capital letter phi
"sum",	// 0x2211, ∑, n-ary sumation
"uml",	// 0xA8, ¨, diaeresis = spacing diaeresis
"Rho",	// 0x3A1, Ρ, greek capital letter rho
"rho",	// 0x3C1, ρ, greek small letter rho
"#xi",	// 0x39E, Ξ, greek capital letter xi
"tau",	// 0x3C4, τ, greek small letter tau
"phi",	// 0x3C6, φ, greek small letter phi
"Eta",	// 0x397, Η, greek capital letter eta
"ang",	// 0x2220, ∠, angle
"and",	// 0x2227, ∧, logical and = wedge
"chi",	// 0x3C7, χ, greek small letter chi
"cap",	// 0x2229, ∩, intersection = cap
"rlm",	// 0x200F, ?, right-to-left mark
"lrm",	// 0x200E, ?, left-to-right mark
"cup",	// 0x222A, ∪, union = cup
"zwj",	// 0x200D, ?, zero width joiner
"int",	// 0x222B, ∫, integral
"sim",	// 0x223C, ?, tilde operator = varies with = similar to
"psi",	// 0x3C8, ψ, greek small letter psi
"eth",	// 0xF0, ð, latin small letter eth
"amp",	// 0x26, & , ampersand
"piv",	// 0x3D3, ?, greek pi symbol
"sub",	// 0x2282, ⊂, subset of
"sup",	// 0x2283, ⊃, superset of
"loz",	// 0x25CA, ?, lozenge
"ETH",	// 0xD0, Ð, latin capital letter ETH
};
char *code_l4[59] = {
"ensp",	// 0x2002, ?, en space
"Iuml",	// 0xCF, Ï, latin capital letter I with diaeresis
"uArr",	// 0x21D1, ?, upwards double arrow
"lArr",	// 0x21D0, ?, leftwards double arrow
"rang",	// 0x232A, ?, right-pointing angle bracket = ket
"lang",	// 0x2329, ?, left-pointing angle bracket = bra
"harr",	// 0x2194, ?, left right arrow
"darr",	// 0x2193, ↓, downwards arrow
"Ouml",	// 0xD6, Ö, latin capital letter O with diaeresis
"rarr",	// 0x2192, →, rightwards arrow
"uarr",	// 0x2191, ↑, upwards arrow
"sdot",	// 0x22C5, ?, dot operator
"perp",	// 0x22A5, ⊥, up tack = orthogonal to = perpendicular
"larr",	// 0x2190, ←, leftwards arrow
"Uuml",	// 0xDC, Ü, latin capital letter U with diaeresis
"hArr",	// 0x21D4, ⇔, left right double arrow
"real",	// 0x211C, ?, blackletter capital R = real part symbol
"part",	// 0x2202, ∂, partial differential
"supe",	// 0x2287, ⊇, superset of or equal to
"sube",	// 0x2286, ⊆, subset of or equal to
"bull",	// 0x2022, ?, bullet = black small circle
"nsub",	// 0x2284, ?, not a subset of
"auml",	// 0xE4, ä, latin small letter a with diaeresis
"quot",	// 0x22,  , quotation mark = APL quote
"nbsp",	// 0xA0,  , no-break space = non-breaking space
"Euml",	// 0xCB, Ë, latin capital letter E with diaeresis
"cent",	// 0xA2, ¢, cent sign
"isin",	// 0x2208, ∈, element of
"Beta",	// 0x392, Β, greek capital letter beta
"euml",	// 0xEB, ë, latin small letter e with diaeresis
"emsp",	// 0x2003, ?, em space
"sect",	// 0xA7, §, section sign
"copy",	// 0xA9, ©, copyright sign
"iuml",	// 0xEF, ï, latin small letter i with diaeresis
"zwnj",	// 0x200C, ?, zero width non-joiner
"ordf",	// 0xAA, ª, feminine ordinal indicator
"iota",	// 0x3B9, ι, greek small letter iota
"cong",	// 0x2245, ?, approximately equal to
"macr",	// 0xAF, ¯, macron = spacing macron = overline = APL overbar
"zeta",	// 0x3B6, ζ, greek small letter zeta
"ouml",	// 0xF6, ö, latin small letter o with diaeresis
"Auml",	// 0xC4, Ä, latin capital letter A with diaeresis
"prod",	// 0x220F, ?, n-ary product = product sign
"beta",	// 0x3B2, β, greek small letter beta
"sup2",	// 0xB2, ², superscript two = superscript digit two = squared
"sup3",	// 0xB3, ³, superscript three = superscript digit three = cubed
"uuml",	// 0xFC, ü, latin small letter u with diaeresis
"dArr",	// 0x21D3, ?, downwards double arrow
"para",	// 0xB6, ¶, pilcrow sign = paragraph sign
"yuml",	// 0xFF, ÿ, latin small letter y with diaeresis
"sup1",	// 0xB9, ¹, superscript one = superscript digit one
"ordm",	// 0xBA, º, masculine ordinal indicator
"Iota",	// 0x399, Ι, greek capital letter iota
"Zeta",	// 0x396, Ζ, greek capital letter zeta
"Yuml",	// 0x0178, ? , latin capital letter Y with diaeresis
"fnof",	// 0x00;, ? , latin small f with hook = function = florin
"circ",	// 0x02C6, ? , modifier letter circumflex accent
"prop",	// 0x221D, ∝, proportional to
"rArr",	// 0x21D2, ⇒, rightwards double arrow
};
char *code_l5[72] = {
"Alpha",	// 0x391, Α, greek capital letter alpha
"Gamma",	// 0x393, Γ, greek capital letter gamma
"Delta",	// 0x394, Δ, greek capital letter delta
"tilde",	// 0x02DC, ? , small tilde
"infin",	// 0x221E, ∞, infinity
"raquo",	// 0xBB, », right-pointing double angle quotation mark = right pointing guillemet
"Theta",	// 0x398, Θ, greek capital letter theta
"rsquo",	// 0x2019, ’, right single quotation mark
"Kappa",	// 0x39A, Κ, greek capital letter kappa
"radic",	// 0x221A, √, square root = radical sign
"oelig",	// 0x0153, ? , latin small ligature oe
"OElig",	// 0x0152, ? , latin capital ligature OE
"cedil",	// 0xB8, ¸, cedilla = spacing cedilla
"minus",	// 0x2212, ?, minus sign
"sbquo",	// 0x201A, ?, single low-9 quotation mark
"thorn",	// 0xFE, þ, latin small letter thorn with
"lsquo",	// 0x2018, ‘, left single quotation mark
"micro",	// 0xB5, µ, micro sign
"acute",	// 0xB4, ´, acute accent = spacing acute
"ucirc",	// 0xFB, û, latin small letter u with circumflex
"mdash",	// 0x2014, ?, em dash
"ldquo",	// 0x201C, “, left double quotation mark
"Omega",	// 0x3A9, Ω, greek capital letter omega
"alpha",	// 0x3B1, α, greek small letter alpha
"ndash",	// 0x2013, ?, en dash
"gamma",	// 0x3B3, γ, greek small letter gamma
"delta",	// 0x3B4, δ, greek small letter delta
"Acirc",	// 0xC2, Â, latin capital letter A with circumflex
"Aring",	// 0xC5, Å, latin capital letter A with ring above = latin capital letter A ring
"ocirc",	// 0xF4, ô, latin small letter o with circumflex
"theta",	// 0x3B8, θ, greek small letter theta
"asymp",	// 0x2248, ?, almost equal to = asymptotic to
"kappa",	// 0x3BA, κ, greek small letter kappa
"laquo",	// 0xAB, «, left-pointing double angle quotation mark = left pointing guillemet
"AElig",	// 0xC6, Æ, latin capital letter AE = latin capital ligature AE
"icirc",	// 0xEE, î, latin small letter i with circumflex
"equiv",	// 0x2261, ≡, identical to
"notin",	// 0x2209, ?, not an element of
"ecirc",	// 0xEA, ê, latin small letter e with circumflex
"bdquo",	// 0x201E, ?, double low-9 quotation mark
"Icirc",	// 0xCE, Î, latin capital letter I with circumflex
"sigma",	// 0x3C3, σ, greek small letter sigma
"pound",	// 0xA3, £, pound sign
"nabla",	// 0x2207, ∇, nabla = backward difference
"Ecirc",	// 0xCA, Ê, latin capital letter E with circumflex
"iexcl",	// 0xA1, ¡, inverted exclamation mark
"aelig",	// 0xE6, æ, latin small letter ae = latin small ligature ae
"omega",	// 0x3C9, ω, greek small letter omega
"empty",	// 0x2205, ?, empty set = null set = diameter
"upsih",	// 0x3D2, ?, greek upsilon with hook symbol
"aring",	// 0xE5, å, latin small letter a with ring above = latin small letter a ring
"acirc",	// 0xE2, â, latin small letter a with circumflex
"exist",	// 0x2203, ∃, there exists
"prime",	// 0x2032, ′, prime = minutes = feet
"Prime",	// 0x2033, ″, double prime = seconds = inches
"oline",	// 0x203E, ?, overline = spacing overscore
"frasl",	// 0x2044, ?, fraction slash
"szlig",	// 0xDF, ß, latin small letter sharp s = ess-zed
"image",	// 0x2111, ?, blackletter capital I = imaginary part
"THORN",	// 0xDE, Þ, latin capital letter THORN
"trade",	// 0x2122, ™, trade mark sign
"oplus",	// 0x2295, ?, circled plus = direct sum
"Ucirc",	// 0xDB, Û, latin capital letter U with circumflex
"lceil",	// 0x2308, ?, left ceiling = apl upstile
"times",	// 0xD7, ×, multiplication sign
"rceil",	// 0x2309, ?, right ceiling
"Ocirc",	// 0xD4, Ô, latin capital letter O with circumflex
"crarr",	// 0x21B5, ?, downwards arrow with corner leftwards = carriage return
"diams",	// 0x2666, ?, black diamond suit
"clubs",	// 0x2663, ?, black club suit = shamrock
"rdquo",	// 0x201D, ”, right double quotation mark
"Sigma",	// 0x3A3, Σ, greek capital letter sigma
};
char *code_l6[61] = {
"lsaquo",	// 0x2039, ?, single left-pointing angle quotation mark 
"forall",	// 0x2200, ∀, for all
"weierp",	// 0x2118, ?, script capital P = power set = Weierstrass p
"hellip",	// 0x2026, …, horizontal ellipsis = three dot leader
"permil",	// 0x2030, ‰, per mille sign
"Dagger",	// 0x2021, ‡, double dagger
"sigmaf",	// 0x3C2, ?, greek small letter final sigma
"dagger",	// 0x2020, †, dagger
"lambda",	// 0x3BB, λ, greek small letter lambda
"curren",	// 0xA4, ¤, currency sign
"brvbar",	// 0xA6, ¦, broken bar = broken vertical bar
"plusmn",	// 0xB1, ±, plus-minus sign = plus-or-minus sign
"lowast",	// 0x2217, ?, asterisk operator
"Lambda",	// 0x39B, Λ, greek capital letter lambda
"middot",	// 0xB7, ·, middle dot = Georgian comma = Greek middle dot
"scaron",	// 0x0161, ? , latin small letter s with caron
"Scaron",	// 0x0160, ? , latin capital letter S with caron
"yacute",	// 0xFD, ý, latin small letter y with acute
"uacute",	// 0xFA, ú, latin small letter u with acute
"ugrave",	// 0xF9, ù, latin small letter u with grave
"oslash",	// 0xF8, ø, latin small letter o with stroke, = latin small letter o slash
"divide",	// 0xF7, ÷, division sign
"there4",	// 0x2234, ∴, therefore
"otilde",	// 0xF5, õ, latin small letter o with tilde
"oacute",	// 0xF3, ó, latin small letter o with acute
"ograve",	// 0xF2, ò, latin small letter o with grave
"ntilde",	// 0xF1, ñ, latin small letter n with tilde
"iacute",	// 0xED, í, latin small letter i with acute
"igrave",	// 0xEC, ì, latin small letter i with grave
"eacute",	// 0xE9, é, latin small letter e with acute
"egrave",	// 0xE8, è, latin small letter e with grave
"ccedil",	// 0xE7, ç, latin small letter c with cedilla
"atilde",	// 0xE3, ã, latin small letter a with tilde
"aacute",	// 0xE1, á, latin small letter a with acute
"agrave",	// 0xE0, à, latin small letter a with grave = latin small letter a grave
"Yacute",	// 0xDD, Ý, latin capital letter Y with acute
"otimes",	// 0x2297, ?, circled times = vector product
"Uacute",	// 0xDA, Ú, latin capital letter U with acute
"Ugrave",	// 0xD9, Ù, latin capital letter U with grave
"Oslash",	// 0xD8, Ø, latin capital letter O with stroke = latin capital letter O slash
"Otilde",	// 0xD5, Õ, latin capital letter O with tilde
"lfloor",	// 0x230A, ?, left floor = apl downstile
"rfloor",	// 0x230B, ?, right floor
"Oacute",	// 0xD3, Ó, latin capital letter O with acute
"Ograve",	// 0xD2, Ò, latin capital letter O with grave
"Ntilde",	// 0xD1, Ñ, latin capital letter N with tilde
"spades",	// 0x2660, ?, black spade suit
"Iacute",	// 0xCD, Í, latin capital letter I with acute
"hearts",	// 0x2665, ?, black heart suit = valentine
"Igrave",	// 0xCC, Ì, latin capital letter I with grave
"Eacute",	// 0xC9, É, latin capital letter E with acute
"frac14",	// 0xBC, ¼, vulgar fraction one quarter = fraction one quarter
"thinsp",	// 0x2009, ?, thin space
"Ccedil",	// 0xC7, Ç, latin capital letter C with cedilla
"Atilde",	// 0xC3, Ã, latin capital letter A with tilde
"Aacute",	// 0xC1, Á, latin capital letter A with acute
"Agrave",	// 0xC0, À, latin capital letter A with grave = latin capital letter A grave
"iquest",	// 0xBF, ¿, inverted question mark = turned question mark
"frac34",	// 0xBE, ¾, vulgar fraction three quarters = fraction three quarters
"frac12",	// 0xBD, ½, vulgar fraction one half = fraction one half
"Egrave",	// 0xC8, È, latin capital letter E with grave
};
char *code_l7[7] = {
"Epsilon",	// 0x395, Ε, greek capital letter epsilon
"Omicron",	// 0x39F, Ο, greek capital letter omicron
"Upsilon",	// 0x3A5, Υ, greek capital letter upsilon
"epsilon",	// 0x3B5, ε, greek small letter epsilon
"alefsym",	// 0x2135, ?, alef symbol = first transfinite cardinal
"upsilon",	// 0x3C5, υ, greek small letter upsilon
"omicron",	// 0x3BF, ο, greek small letter omicron
};
char *code_l8[1] = {
"thetasym",	// 0x3D1, ?, greek small letter theta symbol
};
char *code_number_l2[4] = {
"34",	// 0x22,  , quotation mark = APL quote
"38",	// 0x26, & , ampersand
"60",	// 0x3C, < , less-than sign
"62",	// 0x3E, > , greater-than sign
};
char *code_number_l3[156] = {
"160",	// 0xA0,  , no-break space = non-breaking space
"161",	// 0xA1, ¡, inverted exclamation mark
"162",	// 0xA2, ¢, cent sign
"163",	// 0xA3, £, pound sign
"164",	// 0xA4, ¤, currency sign
"165",	// 0xA5, ¥, yen sign = yuan sign
"166",	// 0xA6, ¦, broken bar = broken vertical bar
"167",	// 0xA7, §, section sign
"168",	// 0xA8, ¨, diaeresis = spacing diaeresis
"169",	// 0xA9, ©, copyright sign
"170",	// 0xAA, ª, feminine ordinal indicator
"171",	// 0xAB, «, left-pointing double angle quotation mark = left pointing guillemet
"172",	// 0xAC, ¬, not sign
"173",	// 0xAD, ­, soft hyphen = discretionary hyphen
"174",	// 0xAE, ®, registered sign = registered trade mark sign
"175",	// 0xAF, ¯, macron = spacing macron = overline = APL overbar
"176",	// 0xB0, °, degree sign
"177",	// 0xB1, ±, plus-minus sign = plus-or-minus sign
"178",	// 0xB2, ², superscript two = superscript digit two = squared
"179",	// 0xB3, ³, superscript three = superscript digit three = cubed
"180",	// 0xB4, ´, acute accent = spacing acute
"181",	// 0xB5, µ, micro sign
"182",	// 0xB6, ¶, pilcrow sign = paragraph sign
"183",	// 0xB7, ·, middle dot = Georgian comma = Greek middle dot
"184",	// 0xB8, ¸, cedilla = spacing cedilla
"185",	// 0xB9, ¹, superscript one = superscript digit one
"186",	// 0xBA, º, masculine ordinal indicator
"187",	// 0xBB, », right-pointing double angle quotation mark = right pointing guillemet
"188",	// 0xBC, ¼, vulgar fraction one quarter = fraction one quarter
"189",	// 0xBD, ½, vulgar fraction one half = fraction one half
"190",	// 0xBE, ¾, vulgar fraction three quarters = fraction three quarters
"191",	// 0xBF, ¿, inverted question mark = turned question mark
"192",	// 0xC0, À, latin capital letter A with grave = latin capital letter A grave
"193",	// 0xC1, Á, latin capital letter A with acute
"194",	// 0xC2, Â, latin capital letter A with circumflex
"195",	// 0xC3, Ã, latin capital letter A with tilde
"196",	// 0xC4, Ä, latin capital letter A with diaeresis
"197",	// 0xC5, Å, latin capital letter A with ring above = latin capital letter A ring
"198",	// 0xC6, Æ, latin capital letter AE = latin capital ligature AE
"199",	// 0xC7, Ç, latin capital letter C with cedilla
"200",	// 0xC8, È, latin capital letter E with grave
"201",	// 0xC9, É, latin capital letter E with acute
"202",	// 0xCA, Ê, latin capital letter E with circumflex
"203",	// 0xCB, Ë, latin capital letter E with diaeresis
"204",	// 0xCC, Ì, latin capital letter I with grave
"205",	// 0xCD, Í, latin capital letter I with acute
"206",	// 0xCE, Î, latin capital letter I with circumflex
"207",	// 0xCF, Ï, latin capital letter I with diaeresis
"208",	// 0xD0, Ð, latin capital letter ETH
"209",	// 0xD1, Ñ, latin capital letter N with tilde
"210",	// 0xD2, Ò, latin capital letter O with grave
"211",	// 0xD3, Ó, latin capital letter O with acute
"212",	// 0xD4, Ô, latin capital letter O with circumflex
"213",	// 0xD5, Õ, latin capital letter O with tilde
"214",	// 0xD6, Ö, latin capital letter O with diaeresis
"215",	// 0xD7, ×, multiplication sign
"216",	// 0xD8, Ø, latin capital letter O with stroke = latin capital letter O slash
"217",	// 0xD9, Ù, latin capital letter U with grave
"218",	// 0xDA, Ú, latin capital letter U with acute
"219",	// 0xDB, Û, latin capital letter U with circumflex
"220",	// 0xDC, Ü, latin capital letter U with diaeresis
"221",	// 0xDD, Ý, latin capital letter Y with acute
"222",	// 0xDE, Þ, latin capital letter THORN
"223",	// 0xDF, ß, latin small letter sharp s = ess-zed
"224",	// 0xE0, à, latin small letter a with grave = latin small letter a grave
"225",	// 0xE1, á, latin small letter a with acute
"226",	// 0xE2, â, latin small letter a with circumflex
"227",	// 0xE3, ã, latin small letter a with tilde
"228",	// 0xE4, ä, latin small letter a with diaeresis
"229",	// 0xE5, å, latin small letter a with ring above = latin small letter a ring
"230",	// 0xE6, æ, latin small letter ae = latin small ligature ae
"231",	// 0xE7, ç, latin small letter c with cedilla
"232",	// 0xE8, è, latin small letter e with grave
"233",	// 0xE9, é, latin small letter e with acute
"234",	// 0xEA, ê, latin small letter e with circumflex
"235",	// 0xEB, ë, latin small letter e with diaeresis
"236",	// 0xEC, ì, latin small letter i with grave
"237",	// 0xED, í, latin small letter i with acute
"238",	// 0xEE, î, latin small letter i with circumflex
"239",	// 0xEF, ï, latin small letter i with diaeresis
"240",	// 0xF0, ð, latin small letter eth
"241",	// 0xF1, ñ, latin small letter n with tilde
"242",	// 0xF2, ò, latin small letter o with grave
"243",	// 0xF3, ó, latin small letter o with acute
"244",	// 0xF4, ô, latin small letter o with circumflex
"245",	// 0xF5, õ, latin small letter o with tilde
"246",	// 0xF6, ö, latin small letter o with diaeresis
"247",	// 0xF7, ÷, division sign
"248",	// 0xF8, ø, latin small letter o with stroke, = latin small letter o slash
"249",	// 0xF9, ù, latin small letter u with grave
"250",	// 0xFA, ú, latin small letter u with acute
"251",	// 0xFB, û, latin small letter u with circumflex
"252",	// 0xFC, ü, latin small letter u with diaeresis
"253",	// 0xFD, ý, latin small letter y with acute
"254",	// 0xFE, þ, latin small letter thorn with
"255",	// 0xFF, ÿ, latin small letter y with diaeresis
"338",	// 0x0152, ? , latin capital ligature OE
"339",	// 0x0153, ? , latin small ligature oe
"352",	// 0x0160, ? , latin capital letter S with caron
"353",	// 0x0161, ? , latin small letter s with caron
"376",	// 0x0178, ? , latin capital letter Y with diaeresis
"402",	// 0x00;, ? , latin small f with hook = function = florin
"710",	// 0x02C6, ? , modifier letter circumflex accent
"732",	// 0x02DC, ? , small tilde
"913",	// 0x391, Α, greek capital letter alpha
"914",	// 0x392, Β, greek capital letter beta
"915",	// 0x393, Γ, greek capital letter gamma
"916",	// 0x394, Δ, greek capital letter delta
"917",	// 0x395, Ε, greek capital letter epsilon
"918",	// 0x396, Ζ, greek capital letter zeta
"919",	// 0x397, Η, greek capital letter eta
"920",	// 0x398, Θ, greek capital letter theta
"921",	// 0x399, Ι, greek capital letter iota
"922",	// 0x39A, Κ, greek capital letter kappa
"923",	// 0x39B, Λ, greek capital letter lambda
"924",	// 0x39C, Μ, greek capital letter mu
"925",	// 0x39D, Ν, greek capital letter nu
"926",	// 0x39E, Ξ, greek capital letter xi
"927",	// 0x39F, Ο, greek capital letter omicron
"928",	// 0x3A0, Π, greek capital letter pi
"929",	// 0x3A1, Ρ, greek capital letter rho
"931",	// 0x3A3, Σ, greek capital letter sigma
"932",	// 0x3A4, Τ, greek capital letter tau
"933",	// 0x3A5, Υ, greek capital letter upsilon
"934",	// 0x3A6, Φ, greek capital letter phi
"935",	// 0x3A7, Χ, greek capital letter chi
"936",	// 0x3A8, Ψ, greek capital letter psi
"937",	// 0x3A9, Ω, greek capital letter omega
"945",	// 0x3B1, α, greek small letter alpha
"946",	// 0x3B2, β, greek small letter beta
"947",	// 0x3B3, γ, greek small letter gamma
"948",	// 0x3B4, δ, greek small letter delta
"949",	// 0x3B5, ε, greek small letter epsilon
"950",	// 0x3B6, ζ, greek small letter zeta
"951",	// 0x3B7, η, greek small letter eta
"952",	// 0x3B8, θ, greek small letter theta
"953",	// 0x3B9, ι, greek small letter iota
"954",	// 0x3BA, κ, greek small letter kappa
"955",	// 0x3BB, λ, greek small letter lambda
"956",	// 0x3BC, μ, greek small letter mu
"957",	// 0x3BD, ν, greek small letter nu
"958",	// 0x3BE, ξ, greek small letter xi
"959",	// 0x3BF, ο, greek small letter omicron
"960",	// 0x3C0, π, greek small letter pi
"961",	// 0x3C1, ρ, greek small letter rho
"962",	// 0x3C2, ?, greek small letter final sigma
"963",	// 0x3C3, σ, greek small letter sigma
"964",	// 0x3C4, τ, greek small letter tau
"965",	// 0x3C5, υ, greek small letter upsilon
"966",	// 0x3C6, φ, greek small letter phi
"967",	// 0x3C7, χ, greek small letter chi
"968",	// 0x3C8, ψ, greek small letter psi
"969",	// 0x3C9, ω, greek small letter omega
"977",	// 0x3D1, ?, greek small letter theta symbol
"978",	// 0x3D2, ?, greek upsilon with hook symbol
"982",	// 0x3D3, ?, greek pi symbol
};
char *code_number_l4[90] = {
"8194",	// 0x2002, ?, en space
"8195",	// 0x2003, ?, em space
"8201",	// 0x2009, ?, thin space
"8204",	// 0x200C, ?, zero width non-joiner
"8205",	// 0x200D, ?, zero width joiner
"8206",	// 0x200E, ?, left-to-right mark
"8207",	// 0x200F, ?, right-to-left mark
"8211",	// 0x2013, ?, en dash
"8212",	// 0x2014, ?, em dash
"8216",	// 0x2018, ‘, left single quotation mark
"8217",	// 0x2019, ’, right single quotation mark
"8218",	// 0x201A, ?, single low-9 quotation mark
"8220",	// 0x201C, “, left double quotation mark
"8221",	// 0x201D, ”, right double quotation mark
"8222",	// 0x201E, ?, double low-9 quotation mark
"8224",	// 0x2020, †, dagger
"8225",	// 0x2021, ‡, double dagger
"8226",	// 0x2022, ?, bullet = black small circle
"8230",	// 0x2026, …, horizontal ellipsis = three dot leader
"8240",	// 0x2030, ‰, per mille sign
"8242",	// 0x2032, ′, prime = minutes = feet
"8243",	// 0x2033, ″, double prime = seconds = inches
"8249",	// 0x2039, ?, single left-pointing angle quotation mark 
"8254",	// 0x203E, ?, overline = spacing overscore
"8260",	// 0x2044, ?, fraction slash
"8465",	// 0x2111, ?, blackletter capital I = imaginary part
"8472",	// 0x2118, ?, script capital P = power set = Weierstrass p
"8476",	// 0x211C, ?, blackletter capital R = real part symbol
"8482",	// 0x2122, ™, trade mark sign
"8501",	// 0x2135, ?, alef symbol = first transfinite cardinal
"8592",	// 0x2190, ←, leftwards arrow
"8593",	// 0x2191, ↑, upwards arrow
"8594",	// 0x2192, →, rightwards arrow
"8595",	// 0x2193, ↓, downwards arrow
"8596",	// 0x2194, ?, left right arrow
"8629",	// 0x21B5, ?, downwards arrow with corner leftwards = carriage return
"8656",	// 0x21D0, ?, leftwards double arrow
"8657",	// 0x21D1, ?, upwards double arrow
"8658",	// 0x21D2, ⇒, rightwards double arrow
"8659",	// 0x21D3, ?, downwards double arrow
"8660",	// 0x21D4, ⇔, left right double arrow
"8704",	// 0x2200, ∀, for all
"8706",	// 0x2202, ∂, partial differential
"8707",	// 0x2203, ∃, there exists
"8709",	// 0x2205, ?, empty set = null set = diameter
"8711",	// 0x2207, ∇, nabla = backward difference
"8712",	// 0x2208, ∈, element of
"8713",	// 0x2209, ?, not an element of
"8715",	// 0x220B, ∋, contains as member
"8719",	// 0x220F, ?, n-ary product = product sign
"8721",	// 0x2211, ∑, n-ary sumation
"8722",	// 0x2212, ?, minus sign
"8727",	// 0x2217, ?, asterisk operator
"8730",	// 0x221A, √, square root = radical sign
"8733",	// 0x221D, ∝, proportional to
"8734",	// 0x221E, ∞, infinity
"8736",	// 0x2220, ∠, angle
"8743",	// 0x2227, ∧, logical and = wedge
"8744",	// 0x2228, ∨, logical or = vee
"8745",	// 0x2229, ∩, intersection = cap
"8746",	// 0x222A, ∪, union = cup
"8747",	// 0x222B, ∫, integral
"8756",	// 0x2234, ∴, therefore
"8764",	// 0x223C, ?, tilde operator = varies with = similar to
"8773",	// 0x2245, ?, approximately equal to
"8776",	// 0x2248, ?, almost equal to = asymptotic to
"8800",	// 0x2260, ≠, not equal to
"8801",	// 0x2261, ≡, identical to
"8804",	// 0x2264, ?, less-than or equal to
"8805",	// 0x2265, ?, greater-than or equal to
"8834",	// 0x2282, ⊂, subset of
"8835",	// 0x2283, ⊃, superset of
"8836",	// 0x2284, ?, not a subset of
"8838",	// 0x2286, ⊆, subset of or equal to
"8839",	// 0x2287, ⊇, superset of or equal to
"8853",	// 0x2295, ?, circled plus = direct sum
"8855",	// 0x2297, ?, circled times = vector product
"8869",	// 0x22A5, ⊥, up tack = orthogonal to = perpendicular
"8901",	// 0x22C5, ?, dot operator
"8968",	// 0x2308, ?, left ceiling = apl upstile
"8969",	// 0x2309, ?, right ceiling
"8970",	// 0x230A, ?, left floor = apl downstile
"8971",	// 0x230B, ?, right floor
"9001",	// 0x2329, ?, left-pointing angle bracket = bra
"9002",	// 0x232A, ?, right-pointing angle bracket = ket
"9674",	// 0x25CA, ?, lozenge
"9824",	// 0x2660, ?, black spade suit
"9827",	// 0x2663, ?, black club suit = shamrock
"9829",	// 0x2665, ?, black heart suit = valentine
"9830",	// 0x2666, ?, black diamond suit
};
int int_l2[] = {
0x3C,	// lt, < , less-than sign
0x2265,	// ge, ?, greater-than or equal to
0x2264,	// le, ?, less-than or equal to
0x3E,	// gt, > , greater-than sign
0x2260,	// ne, ≠, not equal to
0x2228,	// or, ∨, logical or = vee
0x39C,	// Mu, Μ, greek capital letter mu
0x39D,	// Nu, Ν, greek capital letter nu
0x3A0,	// Pi, Π, greek capital letter pi
0x220B,	// ni, ∋, contains as member
0x3C0,	// pi, π, greek small letter pi
0x3BC,	// mu, μ, greek small letter mu
0x3BD,	// nu, ν, greek small letter nu
};
int int_l3[] = {
0x3A4,	// Tau, Τ, greek capital letter tau
0x3BE,	// #xi, ξ, greek small letter xi
0xA5,	// yen, ¥, yen sign = yuan sign
0xAC,	// not, ¬, not sign
0xAD,	// shy, ­, soft hyphen = discretionary hyphen
0xAE,	// reg, ®, registered sign = registered trade mark sign
0x3B7,	// eta, η, greek small letter eta
0xB0,	// deg, °, degree sign
0x3A8,	// Psi, Ψ, greek capital letter psi
0x3A7,	// Chi, Χ, greek capital letter chi
0x3A6,	// Phi, Φ, greek capital letter phi
0x2211,	// sum, ∑, n-ary sumation
0xA8,	// uml, ¨, diaeresis = spacing diaeresis
0x3A1,	// Rho, Ρ, greek capital letter rho
0x3C1,	// rho, ρ, greek small letter rho
0x39E,	// #xi, Ξ, greek capital letter xi
0x3C4,	// tau, τ, greek small letter tau
0x3C6,	// phi, φ, greek small letter phi
0x397,	// Eta, Η, greek capital letter eta
0x2220,	// ang, ∠, angle
0x2227,	// and, ∧, logical and = wedge
0x3C7,	// chi, χ, greek small letter chi
0x2229,	// cap, ∩, intersection = cap
0x200F,	// rlm, ?, right-to-left mark
0x200E,	// lrm, ?, left-to-right mark
0x222A,	// cup, ∪, union = cup
0x200D,	// zwj, ?, zero width joiner
0x222B,	// int, ∫, integral
0x223C,	// sim, ?, tilde operator = varies with = similar to
0x3C8,	// psi, ψ, greek small letter psi
0xF0,	// eth, ð, latin small letter eth
0x26,	// amp, & , ampersand
0x3D3,	// piv, ?, greek pi symbol
0x2282,	// sub, ⊂, subset of
0x2283,	// sup, ⊃, superset of
0x25CA,	// loz, ?, lozenge
0xD0,	// ETH, Ð, latin capital letter ETH
};
int int_l4[] = {
0x2002,	// ensp, ?, en space
0xCF,	// Iuml, Ï, latin capital letter I with diaeresis
0x21D1,	// uArr, ?, upwards double arrow
0x21D0,	// lArr, ?, leftwards double arrow
0x232A,	// rang, ?, right-pointing angle bracket = ket
0x2329,	// lang, ?, left-pointing angle bracket = bra
0x2194,	// harr, ?, left right arrow
0x2193,	// darr, ↓, downwards arrow
0xD6,	// Ouml, Ö, latin capital letter O with diaeresis
0x2192,	// rarr, →, rightwards arrow
0x2191,	// uarr, ↑, upwards arrow
0x22C5,	// sdot, ?, dot operator
0x22A5,	// perp, ⊥, up tack = orthogonal to = perpendicular
0x2190,	// larr, ←, leftwards arrow
0xDC,	// Uuml, Ü, latin capital letter U with diaeresis
0x21D4,	// hArr, ⇔, left right double arrow
0x211C,	// real, ?, blackletter capital R = real part symbol
0x2202,	// part, ∂, partial differential
0x2287,	// supe, ⊇, superset of or equal to
0x2286,	// sube, ⊆, subset of or equal to
0x2022,	// bull, ?, bullet = black small circle
0x2284,	// nsub, ?, not a subset of
0xE4,	// auml, ä, latin small letter a with diaeresis
0x22,	// quot,  , quotation mark = APL quote
0xA0,	// nbsp,  , no-break space = non-breaking space
0xCB,	// Euml, Ë, latin capital letter E with diaeresis
0xA2,	// cent, ¢, cent sign
0x2208,	// isin, ∈, element of
0x392,	// Beta, Β, greek capital letter beta
0xEB,	// euml, ë, latin small letter e with diaeresis
0x2003,	// emsp, ?, em space
0xA7,	// sect, §, section sign
0xA9,	// copy, ©, copyright sign
0xEF,	// iuml, ï, latin small letter i with diaeresis
0x200C,	// zwnj, ?, zero width non-joiner
0xAA,	// ordf, ª, feminine ordinal indicator
0x3B9,	// iota, ι, greek small letter iota
0x2245,	// cong, ?, approximately equal to
0xAF,	// macr, ¯, macron = spacing macron = overline = APL overbar
0x3B6,	// zeta, ζ, greek small letter zeta
0xF6,	// ouml, ö, latin small letter o with diaeresis
0xC4,	// Auml, Ä, latin capital letter A with diaeresis
0x220F,	// prod, ?, n-ary product = product sign
0x3B2,	// beta, β, greek small letter beta
0xB2,	// sup2, ², superscript two = superscript digit two = squared
0xB3,	// sup3, ³, superscript three = superscript digit three = cubed
0xFC,	// uuml, ü, latin small letter u with diaeresis
0x21D3,	// dArr, ?, downwards double arrow
0xB6,	// para, ¶, pilcrow sign = paragraph sign
0xFF,	// yuml, ÿ, latin small letter y with diaeresis
0xB9,	// sup1, ¹, superscript one = superscript digit one
0xBA,	// ordm, º, masculine ordinal indicator
0x399,	// Iota, Ι, greek capital letter iota
0x396,	// Zeta, Ζ, greek capital letter zeta
0x0178,	// Yuml, ? , latin capital letter Y with diaeresis
0x00,	// fnof, ? , latin small f with hook = function = florin
0x02C6,	// circ, ? , modifier letter circumflex accent
0x221D,	// prop, ∝, proportional to
0x21D2,	// rArr, ⇒, rightwards double arrow
};
int int_l5[] = {
0x391,	// Alpha, Α, greek capital letter alpha
0x393,	// Gamma, Γ, greek capital letter gamma
0x394,	// Delta, Δ, greek capital letter delta
0x02DC,	// tilde, ? , small tilde
0x221E,	// infin, ∞, infinity
0xBB,	// raquo, », right-pointing double angle quotation mark = right pointing guillemet
0x398,	// Theta, Θ, greek capital letter theta
0x2019,	// rsquo, ’, right single quotation mark
0x39A,	// Kappa, Κ, greek capital letter kappa
0x221A,	// radic, √, square root = radical sign
0x0153,	// oelig, ? , latin small ligature oe
0x0152,	// OElig, ? , latin capital ligature OE
0xB8,	// cedil, ¸, cedilla = spacing cedilla
0x2212,	// minus, ?, minus sign
0x201A,	// sbquo, ?, single low-9 quotation mark
0xFE,	// thorn, þ, latin small letter thorn with
0x2018,	// lsquo, ‘, left single quotation mark
0xB5,	// micro, µ, micro sign
0xB4,	// acute, ´, acute accent = spacing acute
0xFB,	// ucirc, û, latin small letter u with circumflex
0x2014,	// mdash, ?, em dash
0x201C,	// ldquo, “, left double quotation mark
0x3A9,	// Omega, Ω, greek capital letter omega
0x3B1,	// alpha, α, greek small letter alpha
0x2013,	// ndash, ?, en dash
0x3B3,	// gamma, γ, greek small letter gamma
0x3B4,	// delta, δ, greek small letter delta
0xC2,	// Acirc, Â, latin capital letter A with circumflex
0xC5,	// Aring, Å, latin capital letter A with ring above = latin capital letter A ring
0xF4,	// ocirc, ô, latin small letter o with circumflex
0x3B8,	// theta, θ, greek small letter theta
0x2248,	// asymp, ?, almost equal to = asymptotic to
0x3BA,	// kappa, κ, greek small letter kappa
0xAB,	// laquo, «, left-pointing double angle quotation mark = left pointing guillemet
0xC6,	// AElig, Æ, latin capital letter AE = latin capital ligature AE
0xEE,	// icirc, î, latin small letter i with circumflex
0x2261,	// equiv, ≡, identical to
0x2209,	// notin, ?, not an element of
0xEA,	// ecirc, ê, latin small letter e with circumflex
0x201E,	// bdquo, ?, double low-9 quotation mark
0xCE,	// Icirc, Î, latin capital letter I with circumflex
0x3C3,	// sigma, σ, greek small letter sigma
0xA3,	// pound, £, pound sign
0x2207,	// nabla, ∇, nabla = backward difference
0xCA,	// Ecirc, Ê, latin capital letter E with circumflex
0xA1,	// iexcl, ¡, inverted exclamation mark
0xE6,	// aelig, æ, latin small letter ae = latin small ligature ae
0x3C9,	// omega, ω, greek small letter omega
0x2205,	// empty, ?, empty set = null set = diameter
0x3D2,	// upsih, ?, greek upsilon with hook symbol
0xE5,	// aring, å, latin small letter a with ring above = latin small letter a ring
0xE2,	// acirc, â, latin small letter a with circumflex
0x2203,	// exist, ∃, there exists
0x2032,	// prime, ′, prime = minutes = feet
0x2033,	// Prime, ″, double prime = seconds = inches
0x203E,	// oline, ?, overline = spacing overscore
0x2044,	// frasl, ?, fraction slash
0xDF,	// szlig, ß, latin small letter sharp s = ess-zed
0x2111,	// image, ?, blackletter capital I = imaginary part
0xDE,	// THORN, Þ, latin capital letter THORN
0x2122,	// trade, ™, trade mark sign
0x2295,	// oplus, ?, circled plus = direct sum
0xDB,	// Ucirc, Û, latin capital letter U with circumflex
0x2308,	// lceil, ?, left ceiling = apl upstile
0xD7,	// times, ×, multiplication sign
0x2309,	// rceil, ?, right ceiling
0xD4,	// Ocirc, Ô, latin capital letter O with circumflex
0x21B5,	// crarr, ?, downwards arrow with corner leftwards = carriage return
0x2666,	// diams, ?, black diamond suit
0x2663,	// clubs, ?, black club suit = shamrock
0x201D,	// rdquo, ”, right double quotation mark
0x3A3,	// Sigma, Σ, greek capital letter sigma
};
int int_l6[] = {
0x2039,	// lsaquo, ?, single left-pointing angle quotation mark 
0x2200,	// forall, ∀, for all
0x2118,	// weierp, ?, script capital P = power set = Weierstrass p
0x2026,	// hellip, …, horizontal ellipsis = three dot leader
0x2030,	// permil, ‰, per mille sign
0x2021,	// Dagger, ‡, double dagger
0x3C2,	// sigmaf, ?, greek small letter final sigma
0x2020,	// dagger, †, dagger
0x3BB,	// lambda, λ, greek small letter lambda
0xA4,	// curren, ¤, currency sign
0xA6,	// brvbar, ¦, broken bar = broken vertical bar
0xB1,	// plusmn, ±, plus-minus sign = plus-or-minus sign
0x2217,	// lowast, ?, asterisk operator
0x39B,	// Lambda, Λ, greek capital letter lambda
0xB7,	// middot, ·, middle dot = Georgian comma = Greek middle dot
0x0161,	// scaron, ? , latin small letter s with caron
0x0160,	// Scaron, ? , latin capital letter S with caron
0xFD,	// yacute, ý, latin small letter y with acute
0xFA,	// uacute, ú, latin small letter u with acute
0xF9,	// ugrave, ù, latin small letter u with grave
0xF8,	// oslash, ø, latin small letter o with stroke, = latin small letter o slash
0xF7,	// divide, ÷, division sign
0x2234,	// there4, ∴, therefore
0xF5,	// otilde, õ, latin small letter o with tilde
0xF3,	// oacute, ó, latin small letter o with acute
0xF2,	// ograve, ò, latin small letter o with grave
0xF1,	// ntilde, ñ, latin small letter n with tilde
0xED,	// iacute, í, latin small letter i with acute
0xEC,	// igrave, ì, latin small letter i with grave
0xE9,	// eacute, é, latin small letter e with acute
0xE8,	// egrave, è, latin small letter e with grave
0xE7,	// ccedil, ç, latin small letter c with cedilla
0xE3,	// atilde, ã, latin small letter a with tilde
0xE1,	// aacute, á, latin small letter a with acute
0xE0,	// agrave, à, latin small letter a with grave = latin small letter a grave
0xDD,	// Yacute, Ý, latin capital letter Y with acute
0x2297,	// otimes, ?, circled times = vector product
0xDA,	// Uacute, Ú, latin capital letter U with acute
0xD9,	// Ugrave, Ù, latin capital letter U with grave
0xD8,	// Oslash, Ø, latin capital letter O with stroke = latin capital letter O slash
0xD5,	// Otilde, Õ, latin capital letter O with tilde
0x230A,	// lfloor, ?, left floor = apl downstile
0x230B,	// rfloor, ?, right floor
0xD3,	// Oacute, Ó, latin capital letter O with acute
0xD2,	// Ograve, Ò, latin capital letter O with grave
0xD1,	// Ntilde, Ñ, latin capital letter N with tilde
0x2660,	// spades, ?, black spade suit
0xCD,	// Iacute, Í, latin capital letter I with acute
0x2665,	// hearts, ?, black heart suit = valentine
0xCC,	// Igrave, Ì, latin capital letter I with grave
0xC9,	// Eacute, É, latin capital letter E with acute
0xBC,	// frac14, ¼, vulgar fraction one quarter = fraction one quarter
0x2009,	// thinsp, ?, thin space
0xC7,	// Ccedil, Ç, latin capital letter C with cedilla
0xC3,	// Atilde, Ã, latin capital letter A with tilde
0xC1,	// Aacute, Á, latin capital letter A with acute
0xC0,	// Agrave, À, latin capital letter A with grave = latin capital letter A grave
0xBF,	// iquest, ¿, inverted question mark = turned question mark
0xBE,	// frac34, ¾, vulgar fraction three quarters = fraction three quarters
0xBD,	// frac12, ½, vulgar fraction one half = fraction one half
0xC8,	// Egrave, È, latin capital letter E with grave
};
int int_l7[] = {
0x395,	// Epsilon, Ε, greek capital letter epsilon
0x39F,	// Omicron, Ο, greek capital letter omicron
0x3A5,	// Upsilon, Υ, greek capital letter upsilon
0x3B5,	// epsilon, ε, greek small letter epsilon
0x2135,	// alefsym, ?, alef symbol = first transfinite cardinal
0x3C5,	// upsilon, υ, greek small letter upsilon
0x3BF,	// omicron, ο, greek small letter omicron
};
int int_l8[] = {
0x3D1,	// thetasym, ?, greek small letter theta symbol
};
int int_number_l2[] = {
0x22,	// 34,  , quotation mark = APL quote
0x26,	// 38, & , ampersand
0x3C,	// 60, < , less-than sign
0x3E,	// 62, > , greater-than sign
};
int int_number_l3[] = {
0xA0,	// 160,  , no-break space = non-breaking space
0xA1,	// 161, ¡, inverted exclamation mark
0xA2,	// 162, ¢, cent sign
0xA3,	// 163, £, pound sign
0xA4,	// 164, ¤, currency sign
0xA5,	// 165, ¥, yen sign = yuan sign
0xA6,	// 166, ¦, broken bar = broken vertical bar
0xA7,	// 167, §, section sign
0xA8,	// 168, ¨, diaeresis = spacing diaeresis
0xA9,	// 169, ©, copyright sign
0xAA,	// 170, ª, feminine ordinal indicator
0xAB,	// 171, «, left-pointing double angle quotation mark = left pointing guillemet
0xAC,	// 172, ¬, not sign
0xAD,	// 173, ­, soft hyphen = discretionary hyphen
0xAE,	// 174, ®, registered sign = registered trade mark sign
0xAF,	// 175, ¯, macron = spacing macron = overline = APL overbar
0xB0,	// 176, °, degree sign
0xB1,	// 177, ±, plus-minus sign = plus-or-minus sign
0xB2,	// 178, ², superscript two = superscript digit two = squared
0xB3,	// 179, ³, superscript three = superscript digit three = cubed
0xB4,	// 180, ´, acute accent = spacing acute
0xB5,	// 181, µ, micro sign
0xB6,	// 182, ¶, pilcrow sign = paragraph sign
0xB7,	// 183, ·, middle dot = Georgian comma = Greek middle dot
0xB8,	// 184, ¸, cedilla = spacing cedilla
0xB9,	// 185, ¹, superscript one = superscript digit one
0xBA,	// 186, º, masculine ordinal indicator
0xBB,	// 187, », right-pointing double angle quotation mark = right pointing guillemet
0xBC,	// 188, ¼, vulgar fraction one quarter = fraction one quarter
0xBD,	// 189, ½, vulgar fraction one half = fraction one half
0xBE,	// 190, ¾, vulgar fraction three quarters = fraction three quarters
0xBF,	// 191, ¿, inverted question mark = turned question mark
0xC0,	// 192, À, latin capital letter A with grave = latin capital letter A grave
0xC1,	// 193, Á, latin capital letter A with acute
0xC2,	// 194, Â, latin capital letter A with circumflex
0xC3,	// 195, Ã, latin capital letter A with tilde
0xC4,	// 196, Ä, latin capital letter A with diaeresis
0xC5,	// 197, Å, latin capital letter A with ring above = latin capital letter A ring
0xC6,	// 198, Æ, latin capital letter AE = latin capital ligature AE
0xC7,	// 199, Ç, latin capital letter C with cedilla
0xC8,	// 200, È, latin capital letter E with grave
0xC9,	// 201, É, latin capital letter E with acute
0xCA,	// 202, Ê, latin capital letter E with circumflex
0xCB,	// 203, Ë, latin capital letter E with diaeresis
0xCC,	// 204, Ì, latin capital letter I with grave
0xCD,	// 205, Í, latin capital letter I with acute
0xCE,	// 206, Î, latin capital letter I with circumflex
0xCF,	// 207, Ï, latin capital letter I with diaeresis
0xD0,	// 208, Ð, latin capital letter ETH
0xD1,	// 209, Ñ, latin capital letter N with tilde
0xD2,	// 210, Ò, latin capital letter O with grave
0xD3,	// 211, Ó, latin capital letter O with acute
0xD4,	// 212, Ô, latin capital letter O with circumflex
0xD5,	// 213, Õ, latin capital letter O with tilde
0xD6,	// 214, Ö, latin capital letter O with diaeresis
0xD7,	// 215, ×, multiplication sign
0xD8,	// 216, Ø, latin capital letter O with stroke = latin capital letter O slash
0xD9,	// 217, Ù, latin capital letter U with grave
0xDA,	// 218, Ú, latin capital letter U with acute
0xDB,	// 219, Û, latin capital letter U with circumflex
0xDC,	// 220, Ü, latin capital letter U with diaeresis
0xDD,	// 221, Ý, latin capital letter Y with acute
0xDE,	// 222, Þ, latin capital letter THORN
0xDF,	// 223, ß, latin small letter sharp s = ess-zed
0xE0,	// 224, à, latin small letter a with grave = latin small letter a grave
0xE1,	// 225, á, latin small letter a with acute
0xE2,	// 226, â, latin small letter a with circumflex
0xE3,	// 227, ã, latin small letter a with tilde
0xE4,	// 228, ä, latin small letter a with diaeresis
0xE5,	// 229, å, latin small letter a with ring above = latin small letter a ring
0xE6,	// 230, æ, latin small letter ae = latin small ligature ae
0xE7,	// 231, ç, latin small letter c with cedilla
0xE8,	// 232, è, latin small letter e with grave
0xE9,	// 233, é, latin small letter e with acute
0xEA,	// 234, ê, latin small letter e with circumflex
0xEB,	// 235, ë, latin small letter e with diaeresis
0xEC,	// 236, ì, latin small letter i with grave
0xED,	// 237, í, latin small letter i with acute
0xEE,	// 238, î, latin small letter i with circumflex
0xEF,	// 239, ï, latin small letter i with diaeresis
0xF0,	// 240, ð, latin small letter eth
0xF1,	// 241, ñ, latin small letter n with tilde
0xF2,	// 242, ò, latin small letter o with grave
0xF3,	// 243, ó, latin small letter o with acute
0xF4,	// 244, ô, latin small letter o with circumflex
0xF5,	// 245, õ, latin small letter o with tilde
0xF6,	// 246, ö, latin small letter o with diaeresis
0xF7,	// 247, ÷, division sign
0xF8,	// 248, ø, latin small letter o with stroke, = latin small letter o slash
0xF9,	// 249, ù, latin small letter u with grave
0xFA,	// 250, ú, latin small letter u with acute
0xFB,	// 251, û, latin small letter u with circumflex
0xFC,	// 252, ü, latin small letter u with diaeresis
0xFD,	// 253, ý, latin small letter y with acute
0xFE,	// 254, þ, latin small letter thorn with
0xFF,	// 255, ÿ, latin small letter y with diaeresis
0x0152,	// 338, ? , latin capital ligature OE
0x0153,	// 339, ? , latin small ligature oe
0x0160,	// 352, ? , latin capital letter S with caron
0x0161,	// 353, ? , latin small letter s with caron
0x0178,	// 376, ? , latin capital letter Y with diaeresis
0x00,	// 402, ? , latin small f with hook = function = florin
0x02C6,	// 710, ? , modifier letter circumflex accent
0x02DC,	// 732, ? , small tilde
0x391,	// 913, Α, greek capital letter alpha
0x392,	// 914, Β, greek capital letter beta
0x393,	// 915, Γ, greek capital letter gamma
0x394,	// 916, Δ, greek capital letter delta
0x395,	// 917, Ε, greek capital letter epsilon
0x396,	// 918, Ζ, greek capital letter zeta
0x397,	// 919, Η, greek capital letter eta
0x398,	// 920, Θ, greek capital letter theta
0x399,	// 921, Ι, greek capital letter iota
0x39A,	// 922, Κ, greek capital letter kappa
0x39B,	// 923, Λ, greek capital letter lambda
0x39C,	// 924, Μ, greek capital letter mu
0x39D,	// 925, Ν, greek capital letter nu
0x39E,	// 926, Ξ, greek capital letter xi
0x39F,	// 927, Ο, greek capital letter omicron
0x3A0,	// 928, Π, greek capital letter pi
0x3A1,	// 929, Ρ, greek capital letter rho
0x3A3,	// 931, Σ, greek capital letter sigma
0x3A4,	// 932, Τ, greek capital letter tau
0x3A5,	// 933, Υ, greek capital letter upsilon
0x3A6,	// 934, Φ, greek capital letter phi
0x3A7,	// 935, Χ, greek capital letter chi
0x3A8,	// 936, Ψ, greek capital letter psi
0x3A9,	// 937, Ω, greek capital letter omega
0x3B1,	// 945, α, greek small letter alpha
0x3B2,	// 946, β, greek small letter beta
0x3B3,	// 947, γ, greek small letter gamma
0x3B4,	// 948, δ, greek small letter delta
0x3B5,	// 949, ε, greek small letter epsilon
0x3B6,	// 950, ζ, greek small letter zeta
0x3B7,	// 951, η, greek small letter eta
0x3B8,	// 952, θ, greek small letter theta
0x3B9,	// 953, ι, greek small letter iota
0x3BA,	// 954, κ, greek small letter kappa
0x3BB,	// 955, λ, greek small letter lambda
0x3BC,	// 956, μ, greek small letter mu
0x3BD,	// 957, ν, greek small letter nu
0x3BE,	// 958, ξ, greek small letter xi
0x3BF,	// 959, ο, greek small letter omicron
0x3C0,	// 960, π, greek small letter pi
0x3C1,	// 961, ρ, greek small letter rho
0x3C2,	// 962, ?, greek small letter final sigma
0x3C3,	// 963, σ, greek small letter sigma
0x3C4,	// 964, τ, greek small letter tau
0x3C5,	// 965, υ, greek small letter upsilon
0x3C6,	// 966, φ, greek small letter phi
0x3C7,	// 967, χ, greek small letter chi
0x3C8,	// 968, ψ, greek small letter psi
0x3C9,	// 969, ω, greek small letter omega
0x3D1,	// 977, ?, greek small letter theta symbol
0x3D2,	// 978, ?, greek upsilon with hook symbol
0x3D3,	// 982, ?, greek pi symbol
};
int int_number_l4[] = {
0x2002,	// 8194, ?, en space
0x2003,	// 8195, ?, em space
0x2009,	// 8201, ?, thin space
0x200C,	// 8204, ?, zero width non-joiner
0x200D,	// 8205, ?, zero width joiner
0x200E,	// 8206, ?, left-to-right mark
0x200F,	// 8207, ?, right-to-left mark
0x2013,	// 8211, ?, en dash
0x2014,	// 8212, ?, em dash
0x2018,	// 8216, ‘, left single quotation mark
0x2019,	// 8217, ’, right single quotation mark
0x201A,	// 8218, ?, single low-9 quotation mark
0x201C,	// 8220, “, left double quotation mark
0x201D,	// 8221, ”, right double quotation mark
0x201E,	// 8222, ?, double low-9 quotation mark
0x2020,	// 8224, †, dagger
0x2021,	// 8225, ‡, double dagger
0x2022,	// 8226, ?, bullet = black small circle
0x2026,	// 8230, …, horizontal ellipsis = three dot leader
0x2030,	// 8240, ‰, per mille sign
0x2032,	// 8242, ′, prime = minutes = feet
0x2033,	// 8243, ″, double prime = seconds = inches
0x2039,	// 8249, ?, single left-pointing angle quotation mark 
0x203E,	// 8254, ?, overline = spacing overscore
0x2044,	// 8260, ?, fraction slash
0x2111,	// 8465, ?, blackletter capital I = imaginary part
0x2118,	// 8472, ?, script capital P = power set = Weierstrass p
0x211C,	// 8476, ?, blackletter capital R = real part symbol
0x2122,	// 8482, ™, trade mark sign
0x2135,	// 8501, ?, alef symbol = first transfinite cardinal
0x2190,	// 8592, ←, leftwards arrow
0x2191,	// 8593, ↑, upwards arrow
0x2192,	// 8594, →, rightwards arrow
0x2193,	// 8595, ↓, downwards arrow
0x2194,	// 8596, ?, left right arrow
0x21B5,	// 8629, ?, downwards arrow with corner leftwards = carriage return
0x21D0,	// 8656, ?, leftwards double arrow
0x21D1,	// 8657, ?, upwards double arrow
0x21D2,	// 8658, ⇒, rightwards double arrow
0x21D3,	// 8659, ?, downwards double arrow
0x21D4,	// 8660, ⇔, left right double arrow
0x2200,	// 8704, ∀, for all
0x2202,	// 8706, ∂, partial differential
0x2203,	// 8707, ∃, there exists
0x2205,	// 8709, ?, empty set = null set = diameter
0x2207,	// 8711, ∇, nabla = backward difference
0x2208,	// 8712, ∈, element of
0x2209,	// 8713, ?, not an element of
0x220B,	// 8715, ∋, contains as member
0x220F,	// 8719, ?, n-ary product = product sign
0x2211,	// 8721, ∑, n-ary sumation
0x2212,	// 8722, ?, minus sign
0x2217,	// 8727, ?, asterisk operator
0x221A,	// 8730, √, square root = radical sign
0x221D,	// 8733, ∝, proportional to
0x221E,	// 8734, ∞, infinity
0x2220,	// 8736, ∠, angle
0x2227,	// 8743, ∧, logical and = wedge
0x2228,	// 8744, ∨, logical or = vee
0x2229,	// 8745, ∩, intersection = cap
0x222A,	// 8746, ∪, union = cup
0x222B,	// 8747, ∫, integral
0x2234,	// 8756, ∴, therefore
0x223C,	// 8764, ?, tilde operator = varies with = similar to
0x2245,	// 8773, ?, approximately equal to
0x2248,	// 8776, ?, almost equal to = asymptotic to
0x2260,	// 8800, ≠, not equal to
0x2261,	// 8801, ≡, identical to
0x2264,	// 8804, ?, less-than or equal to
0x2265,	// 8805, ?, greater-than or equal to
0x2282,	// 8834, ⊂, subset of
0x2283,	// 8835, ⊃, superset of
0x2284,	// 8836, ?, not a subset of
0x2286,	// 8838, ⊆, subset of or equal to
0x2287,	// 8839, ⊇, superset of or equal to
0x2295,	// 8853, ?, circled plus = direct sum
0x2297,	// 8855, ?, circled times = vector product
0x22A5,	// 8869, ⊥, up tack = orthogonal to = perpendicular
0x22C5,	// 8901, ?, dot operator
0x2308,	// 8968, ?, left ceiling = apl upstile
0x2309,	// 8969, ?, right ceiling
0x230A,	// 8970, ?, left floor = apl downstile
0x230B,	// 8971, ?, right floor
0x2329,	// 9001, ?, left-pointing angle bracket = bra
0x232A,	// 9002, ?, right-pointing angle bracket = ket
0x25CA,	// 9674, ?, lozenge
0x2660,	// 9824, ?, black spade suit
0x2663,	// 9827, ?, black club suit = shamrock
0x2665,	// 9829, ?, black heart suit = valentine
0x2666,	// 9830, ?, black diamond suit
};

int utf8codeOfHTMLSpecialCharacter( char*p, int length ) {
	int j;
	int *int_codeTable = NULL;
	char **char_codeTable = NULL;
	
	if( *p == '#' && *(p+1) != 'x' ) {
		p++;
		switch( length - 1 ) {
			case 2:
				int_codeTable = int_number_l2;
				char_codeTable = code_number_l2;
				break;
			case 3:
				int_codeTable = int_number_l3;
				char_codeTable = code_number_l3;
				break;
			case 4:
				int_codeTable = int_number_l4;
				char_codeTable = code_number_l4;
				break;
			default:
				return 0;
		}
		for( j = 0; j < code_number_length[length-1]; j++ ) {
			if( !strncmp( p, char_codeTable[j], length-1 ) ) {
				return int_codeTable[j];
			}
		}
	}
	else {
		switch( length ) {
			case 2:
				int_codeTable = int_l2;
				char_codeTable = code_l2;
				break;
			case 3:
				int_codeTable = int_l3;
				char_codeTable = code_l3;
				break;
			case 4:
				int_codeTable = int_l4;
				char_codeTable = code_l4;
				break;
			case 5:
				int_codeTable = int_l5;
				char_codeTable = code_l5;
				break;
			case 6:
				int_codeTable = int_l6;
				char_codeTable = code_l6;
				break;
			case 7:
				int_codeTable = int_l7;
				char_codeTable = code_l7;
				break;
			case 8:
				int_codeTable = int_l8;
				char_codeTable = code_l8;
				break;
			default:
				return 0;
		}
		for( j = 0; j < code_length[length]; j++ ) {
			if( !strncmp( p, char_codeTable[j], length ) ) {
				return int_codeTable[j];
			}
		}
	}
	return 0;
}

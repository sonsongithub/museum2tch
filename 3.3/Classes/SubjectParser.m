//
//  DatParser.m
//  parser
//
//  Created by sonson on 08/12/11.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SubjectParser.h"
#import "StringDecoder.h"

int code_length[] = {
	0,	// dummy
	0,	// dummy
	13,
	37,
	59,
	72,
	61,
	7,
	1
};

char *code_l2[13] = {
	"lt",
	"ge",
	"le",
	"gt",
	"ne",
	"or",
	"Mu",
	"Nu",
	"Pi",
	"ni",
	"pi",
	"mu",
	"nu"
};

char *code_l3[37] = {
	"Tau",
	"#xi",
	"yen",
	"not",
	"shy",
	"reg",
	"eta",
	"deg",
	"Psi",
	"Chi",
	"Phi",
	"sum",
	"uml",
	"Rho",
	"rho",
	"#xi",
	"tau",
	"phi",
	"Eta",
	"ang",
	"and",
	"chi",
	"cap",
	"rlm",
	"lrm",
	"cup",
	"zwj",
	"int",
	"sim",
	"psi",
	"eth",
	"amp",
	"piv",
	"sub",
	"sup",
	"loz",
	"ETH"
};

char *code_l4[59] = {
	"ensp",
	"Iuml",
	"uArr",
	"lArr",
	"rang",
	"lang",
	"harr",
	"darr",
	"Ouml",
	"rarr",
	"uarr",
	"sdot",
	"perp",
	"larr",
	"Uuml",
	"hArr",
	"real",
	"part",
	"supe",
	"sube",
	"bull",
	"nsub",
	"auml",
	"quot",
	"nbsp",
	"Euml",
	"cent",
	"isin",
	"Beta",
	"euml",
	"emsp",
	"sect",
	"copy",
	"iuml",
	"zwnj",
	"ordf",
	"iota",
	"cong",
	"macr",
	"zeta",
	"ouml",
	"Auml",
	"prod",
	"beta",
	"sup2",
	"sup3",
	"uuml",
	"dArr",
	"para",
	"yuml",
	"sup1",
	"ordm",
	"Iota",
	"Zeta",
	"Yuml",
	"fnof",
	"circ",
	"prop",
	"rArr"
};

char *code_l5[72] = {
	"Alpha",
	"Gamma",
	"Delta",
	"tilde",
	"infin",
	"raquo",
	"Theta",
	"rsquo",
	"Kappa",
	"radic",
	"oelig",
	"OElig",
	"cedil",
	"minus",
	"sbquo",
	"thorn",
	"lsquo",
	"micro",
	"acute",
	"ucirc",
	"mdash",
	"ldquo",
	"Omega",
	"alpha",
	"ndash",
	"gamma",
	"delta",
	"Acirc",
	"Aring",
	"ocirc",
	"theta",
	"asymp",
	"kappa",
	"laquo",
	"AElig",
	"icirc",
	"equiv",
	"notin",
	"ecirc",
	"bdquo",
	"Icirc",
	"sigma",
	"pound",
	"nabla",
	"Ecirc",
	"iexcl",
	"aelig",
	"omega",
	"empty",
	"upsih",
	"aring",
	"acirc",
	"exist",
	"prime",
	"Prime",
	"oline",
	"frasl",
	"szlig",
	"image",
	"THORN",
	"trade",
	"oplus",
	"Ucirc",
	"lceil",
	"times",
	"rceil",
	"Ocirc",
	"crarr",
	"diams",
	"clubs",
	"rdquo",
	"Sigma"
};

char *code_l6[61] = {
	"lsaquo",
	"forall",
	"weierp",
	"hellip",
	"permil",
	"Dagger",
	"sigmaf",
	"dagger",
	"lambda",
	"curren",
	"brvbar",
	"plusmn",
	"lowast",
	"Lambda",
	"middot",
	"scaron",
	"Scaron",
	"yacute",
	"uacute",
	"ugrave",
	"oslash",
	"divide",
	"there4",
	"otilde",
	"oacute",
	"ograve",
	"ntilde",
	"iacute",
	"igrave",
	"eacute",
	"egrave",
	"ccedil",
	"atilde",
	"aacute",
	"agrave",
	"Yacute",
	"otimes",
	"Uacute",
	"Ugrave",
	"Oslash",
	"Otilde",
	"lfloor",
	"rfloor",
	"Oacute",
	"Ograve",
	"Ntilde",
	"spades",
	"Iacute",
	"hearts",
	"Igrave",
	"Eacute",
	"frac14",
	"thinsp",
	"Ccedil",
	"Atilde",
	"Aacute",
	"Agrave",
	"iquest",
	"frac34",
	"frac12",
	"Egrave"
};

char *code_l7[7] = {
	"Epsilon",
	"Omicron",
	"Upsilon",
	"epsilon",
	"alefsym",
	"upsilon",
	"omicron"
};

char *code_l8[1] = {
	"thetasym"
};

int int_l2[] = {
	0x3C,
	0x2265,
	0x2264,
	0x3E,
	0x2260,
	0x2228,
	0x39C,
	0x39D,
	0x3A0,
	0x220B,
	0x3C0,
	0x3BC,
	0x3BD
};

int int_l3[] = {
	0x3A4,
	0x3BE,
	0xA5,
	0xAC,
	0xAD,
	0xAE,
	0x3B7,
	0xB0,
	0x3A8,
	0x3A7,
	0x3A6,
	0x2211,
	0xA8,
	0x3A1,
	0x3C1,
	0x39E,
	0x3C4,
	0x3C6,
	0x397,
	0x2220,
	0x2227,
	0x3C7,
	0x2229,
	0x200F,
	0x200E,
	0x222A,
	0x200D,
	0x222B,
	0x223C,
	0x3C8,
	0xF0,
	0x26,
	0x3D3,
	0x2282,
	0x2283,
	0x25CA,
	0xD0
};

int int_l4[] = {
	0x2002,
	0xCF,
	0x21D1,
	0x21D0,
	0x232A,
	0x2329,
	0x2194,
	0x2193,
	0xD6,
	0x2192,
	0x2191,
	0x22C5,
	0x22A5,
	0x2190,
	0xDC,
	0x21D4,
	0x211C,
	0x2202,
	0x2287,
	0x2286,
	0x2022,
	0x2284,
	0xE4,
	0x22,
	0xA0,
	0xCB,
	0xA2,
	0x2208,
	0x392,
	0xEB,
	0x2003,
	0xA7,
	0xA9,
	0xEF,
	0x200C,
	0xAA,
	0x3B9,
	0x2245,
	0xAF,
	0x3B6,
	0xF6,
	0xC4,
	0x220F,
	0x3B2,
	0xB2,
	0xB3,
	0xFC,
	0x21D3,
	0xB6,
	0xFF,
	0xB9,
	0xBA,
	0x399,
	0x396,
	0x0178,
	0x00,
	0x02C6,
	0x221D,
	0x21D2
};
int int_l5[] = {
	0x391,
	0x393,
	0x394,
	0x02DC,
	0x221E,
	0xBB,
	0x398,
	0x2019,
	0x39A,
	0x221A,
	0x0153,
	0x0152,
	0xB8,
	0x2212,
	0x201A,
	0xFE,
	0x2018,
	0xB5,
	0xB4,
	0xFB,
	0x2014,
	0x201C,
	0x3A9,
	0x3B1,
	0x2013,
	0x3B3,
	0x3B4,
	0xC2,
	0xC5,
	0xF4,
	0x3B8,
	0x2248,
	0x3BA,
	0xAB,
	0xC6,
	0xEE,
	0x2261,
	0x2209,
	0xEA,
	0x201E,
	0xCE,
	0x3C3,
	0xA3,
	0x2207,
	0xCA,
	0xA1,
	0xE6,
	0x3C9,
	0x2205,
	0x3D2,
	0xE5,
	0xE2,
	0x2203,
	0x2032,
	0x2033,
	0x203E,
	0x2044,
	0xDF,
	0x2111,
	0xDE,
	0x2122,
	0x2295,
	0xDB,
	0x2308,
	0xD7,
	0x2309,
	0xD4,
	0x21B5,
	0x2666,
	0x2663,
	0x201D,
	0x3A3
};

int int_l6[] = {
	0x2039,
	0x2200,
	0x2118,
	0x2026,
	0x2030,
	0x2021,
	0x3C2,
	0x2020,
	0x3BB,
	0xA4,
	0xA6,
	0xB1,
	0x2217,
	0x39B,
	0xB7,
	0x0161,
	0x0160,
	0xFD,
	0xFA,
	0xF9,
	0xF8,
	0xF7,
	0x2234,
	0xF5,
	0xF3,
	0xF2,
	0xF1,
	0xED,
	0xEC,
	0xE9,
	0xE8,
	0xE7,
	0xE3,
	0xE1,
	0xE0,
	0xDD,
	0x2297,
	0xDA,
	0xD9,
	0xD8,
	0xD5,
	0x230A,
	0x230B,
	0xD3,
	0xD2,
	0xD1,
	0x2660,
	0xCD,
	0x2665,
	0xCC,
	0xC9,
	0xBC,
	0x2009,
	0xC7,
	0xC3,
	0xC1,
	0xC0,
	0xBF,
	0xBE,
	0xBD,
	0xC8
};

int int_l7[] = {
	0x395,
	0x39F,
	0x3A5,
	0x3B5,
	0x2135,
	0x3C5,
	0x3BF
};

int int_l8[] = {
	0x3D1
};

int utf8codeOfHTMLSpecialCharacter( char*p, int length ) {
	int j;
	int *int_codeTable = NULL;
	char **char_codeTable = NULL;
	
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
	return 0;
}

NSMutableString* parseTitle( char*p, int head, int tail ) {
	NSMutableString* string = [[NSMutableString alloc] init];
	
	int i;
	int ampersand = -1;
	int terminate = head;
	
	for( i = head; i < tail; i++ ) {
		if( *( p + i ) == '&' ) {
			ampersand = i;
		}
		if( *( p + i ) == ';' && ampersand != -1) {
			NSString* a = [StringDecoder decodeBytesFrom:p + terminate length:ampersand - terminate];
			int code = utf8codeOfHTMLSpecialCharacter( p+ampersand+1, i-ampersand-1 );
			if( a != nil )
				[string appendString:a];
			if( code != 0 )
				[string appendString:[NSString stringWithFormat:@"%C", code]];
			[a release];
			ampersand = -1;
			terminate = i+1;
		}
	}
	NSString* a = [StringDecoder decodeBytesFrom:p + terminate length:tail-terminate];
	if( a != nil )
		[string appendString:a];
	[a release];
	return string;
}

int searchDivider( char*p, int head, int tail ) {
	int i;
	const char* dat_template = ".dat<>";
	if( tail - head < 6 )
		return -1;
	for( i = head; i < tail - 6; i++ ) {
		if( !strncmp( p + i, dat_template, 6 ) )
			return i;
	}
	return -1;
}

int searchResNumber( char*p, int head, int tail ) {
	int i;
	if( *( p + tail ) != ')' )
		return -1;
	for( i = 0; i < tail - head; i++ ) {
		if( *( p + tail - i ) == '(' )
			return tail - i;
	}
	return -1;
}



@implementation SubjectData

@synthesize title = title_;
@synthesize path = path_;
@synthesize dat = dat_;
@synthesize res = res_;

- (id)init {
	self = [super init];
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	self.title = [coder decodeObjectForKey:@"title"];
	self.path = [coder decodeObjectForKey:@"path"];
	self.dat = [coder decodeIntForKey:@"dat"];
	self.res = [coder decodeIntForKey:@"res"];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.title forKey:@"title"];
	[encoder encodeObject:self.path forKey:@"path"];
	[encoder encodeInt:self.dat forKey:@"dat"];
	[encoder encodeInt:self.res forKey:@"res"];
}

- (void)dealloc {
	[title_ release];
	[path_ release];
	[super dealloc];
}

@end

@implementation SubjectParser

+ (void)parse:(NSData*)data {
	DNSLogMethod
	int i,head = 0;
	int dat = 0;
	int res = 0;
	char traceBuff[20];
	char *p = (char*)[data bytes];
	int length = [data length];
	for( i = 0; i < length; i++ ) {
		unsigned char c = *( p + i );
		if( c == 0x0A ) {
			// search <> from head to i
			int tail_dat_number = searchDivider( p, head, i );
			if( tail_dat_number != -1 ) {
				int tail_title = searchResNumber( p, tail_dat_number, i-1);
				if( tail_title != -1 ) {
					// success extraction
					// extract dat
					memcpy( traceBuff, p + head, tail_dat_number - head );
					traceBuff[tail_dat_number-head] = '\0';
					sscanf( traceBuff, "%d", &dat );
					
					// extract res number
					memcpy( traceBuff, p + tail_title + 1, i - 1 - (tail_title+1) );
					traceBuff[i - 1 - (tail_title+1)] = '\0';
					sscanf( traceBuff, "%d", &res );
					
					// extract title
					NSString * title = parseTitle( p, tail_dat_number + 6, tail_title );
					[title release];
				}
			}
			head = i + 1;
		}
	}
}

+ (BOOL)appendTarget:(NSMutableArray*)array path:(NSString*)path {
	DNSLogMethod
	
}

+ (void)parse:(NSData*)data appendTarget:(NSMutableArray*)array {
	DNSLogMethod
	int i,head = 0;
	int dat = 0;
	int res = 0;
	char traceBuff[20];
	char *p = (char*)[data bytes];
	int length = [data length];
	for( i = 0; i < length; i++ ) {
		unsigned char c = *( p + i );
		if( c == 0x0A ) {
			// search <> from head to i
			int tail_dat_number = searchDivider( p, head, i );
			if( tail_dat_number != -1 ) {
				int tail_title = searchResNumber( p, tail_dat_number, i-1);
				if( tail_title != -1 ) {
					
					SubjectData* data = [[SubjectData alloc] init];
					
					// success extraction
					// extract dat
					memcpy( traceBuff, p + head, tail_dat_number - head );
					traceBuff[tail_dat_number-head] = '\0';
					sscanf( traceBuff, "%d", &dat );
					
					// extract res number
					memcpy( traceBuff, p + tail_title + 1, i - 1 - (tail_title+1) );
					traceBuff[i - 1 - (tail_title+1)] = '\0';
					sscanf( traceBuff, "%d", &res );
					
					// extract title
					NSString * title = parseTitle( p, tail_dat_number + 6, tail_title );
					
					data.title = title;
					data.dat = dat;
					data.res = res;
					[array addObject:data];
					[data release];
					
					[title release];
				}
			}
			head = i + 1;
		}
	}
}

@end

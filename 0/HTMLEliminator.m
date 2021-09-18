
#import "HTMLEliminator.h"


@implementation HTMLEliminator

// override method

- (void) dealloc {
	[specialChars_ release];
	DNSLog( @"HTMLEliminator - dealloc" );
	[super dealloc];
}

- (id) init {
	self = [super init];
	if (self != nil) {
		DNSLog( @"HTMLEliminator - init" );
		[self makeConvertEliminateDataTable];
	}
	return self;
}

// original method

- (void) convertHTMLTag:(NSMutableString*)str{
	NSArray *keys = [specialTags_ allKeys];
	int i;
	for( i = 0; i < [keys count]; i++ ) {
		id before = [keys objectAtIndex:i];
		id after = [specialTags_ valueForKey:before];
		[str replaceOccurrencesOfString:before withString:after options:NSLiteralSearch range:NSMakeRange(0, [str length])];
	}
}

- (void) convertSpecialChar:(NSMutableString*)str {
	NSArray *keys = [specialChars_ allKeys];
	int i;
	for( i = 0; i < [keys count]; i++ ) {
		id before = [keys objectAtIndex:i];
		id after = [specialChars_ valueForKey:before];
		[str replaceOccurrencesOfString:before withString:after options:NSLiteralSearch range:NSMakeRange(0, [str length])];
	}
}

- (void) eliminateHTMLTag:(NSMutableString*)str {
	int del = 0;
	int i = 0;
	
	for(i = 0; i< ([str length]); i++) {
		BOOL deleted = NO;
		if([str characterAtIndex: i] == '<')
			del ++;

		if(del > 0) {
			deleted = YES;
		}

		if([str characterAtIndex: i] == '>') {
			if(del > 0)
			del --;
		}

		if(deleted) {
			NSRange r = NSMakeRange(i, 1);
			[str deleteCharactersInRange: r];
			i--;
		}
	}
}

- (NSString*) eliminate:(NSString*)inputStr {
	NSMutableString *str = [NSMutableString stringWithString:inputStr];
	[self convertHTMLTag:str];
	[self eliminateHTMLTag:str];
	[self convertSpecialChar:str];
	return str;
}

- (void) makeConvertEliminateDataTable {
	specialChars_ = [[NSDictionary dictionaryWithObjectsAndKeys:
				[NSString stringWithFormat:@"%C", 0x22 ],		@"&quot;", 
				[NSString stringWithFormat:@"%C", 0x26 ],		@"&amp;", 
				[NSString stringWithFormat:@"%C", 0x3C ],		@"&lt;", 
				[NSString stringWithFormat:@"%C", 0x3E ],		@"&gt;", 
				[NSString stringWithFormat:@"%C", 0xA0 ],		@"&nbsp;",
				[NSString stringWithFormat:@"%C", 0xA1 ],		@"&iexcl;",					
				[NSString stringWithFormat:@"%C", 0xA2 ],		@"&cent;",
				[NSString stringWithFormat:@"%C", 0xA3 ],		@"&pound;",
				[NSString stringWithFormat:@"%C", 0xA4 ],		@"&curren;",					
				[NSString stringWithFormat:@"%C", 0xA5 ],		@"&yen;",
				[NSString stringWithFormat:@"%C", 0xA6 ],		@"&brvbar;",
				[NSString stringWithFormat:@"%C", 0xA7 ],		@"&sect;",					
				[NSString stringWithFormat:@"%C", 0xA8 ],		@"&uml;",					
				[NSString stringWithFormat:@"%C", 0xA9 ],		@"&copy;",
				[NSString stringWithFormat:@"%C", 0xAA ],		@"&ordf;",					
				[NSString stringWithFormat:@"%C", 0xAB ],		@"&laquo;",					
				[NSString stringWithFormat:@"%C", 0xAC ],		@"&not;",					
				[NSString stringWithFormat:@"%C", 0xAD ],		@"&shy;",					
				[NSString stringWithFormat:@"%C", 0xAE ],		@"&reg;",					
				[NSString stringWithFormat:@"%C", 0xAF ],		@"&macr;",					
				[NSString stringWithFormat:@"%C", 0xB0 ],		@"&deg;",					
				[NSString stringWithFormat:@"%C", 0xB1 ],		@"&plusmn;",					
				[NSString stringWithFormat:@"%C", 0xB2 ],		@"&sup2;",
				[NSString stringWithFormat:@"%C", 0xB3 ],		@"&sup3;",
				[NSString stringWithFormat:@"%C", 0xB4 ],		@"&acute;",					
				[NSString stringWithFormat:@"%C", 0xB5 ],		@"&micro;",
				[NSString stringWithFormat:@"%C", 0xB6 ],		@"&para;",					
				[NSString stringWithFormat:@"%C", 0xB7 ],		@"&middot;",					
				[NSString stringWithFormat:@"%C", 0xB8 ],		@"&cedil;",					
				[NSString stringWithFormat:@"%C", 0xB9 ],		@"&sup1;",					
				[NSString stringWithFormat:@"%C", 0xBA ],		@"&ordm;",					
				[NSString stringWithFormat:@"%C", 0xBB ],		@"&raquo;",					
				[NSString stringWithFormat:@"%C", 0xBC ],		@"&frac14;",					
				[NSString stringWithFormat:@"%C", 0xBD ],		@"&frac12;",					
				[NSString stringWithFormat:@"%C", 0xBE ],		@"&frac34;",					
				[NSString stringWithFormat:@"%C", 0xBF ],		@"&iquest;",					
				[NSString stringWithFormat:@"%C", 0xC0 ],		@"&Agrave;",					
				[NSString stringWithFormat:@"%C", 0xC1 ],		@"&Aacute;",					
				[NSString stringWithFormat:@"%C", 0xC2 ],		@"&Acirc;",					
				[NSString stringWithFormat:@"%C", 0xC3 ],		@"&Atilde;",					
				[NSString stringWithFormat:@"%C", 0xC4 ],		@"&Auml;",					
				[NSString stringWithFormat:@"%C", 0xC5 ],		@"&Aring;",					
				[NSString stringWithFormat:@"%C", 0xC6 ],		@"&AElig;",					
				[NSString stringWithFormat:@"%C", 0xC7 ],		@"&Ccedil;",					
				[NSString stringWithFormat:@"%C", 0xC8 ],		@"&Egrave;",					
				[NSString stringWithFormat:@"%C", 0xC9 ],		@"&Eacute;",					
				[NSString stringWithFormat:@"%C", 0xCA ],		@"&Ecirc;",					
				[NSString stringWithFormat:@"%C", 0xCB ],		@"&Euml;",					
				[NSString stringWithFormat:@"%C", 0xCC ],		@"&Igrave;",					
				[NSString stringWithFormat:@"%C", 0xCD ],		@"&Iacute;",					
				[NSString stringWithFormat:@"%C", 0xCE ],		@"&Icirc;",					
				[NSString stringWithFormat:@"%C", 0xCF ],		@"&Iuml;",					
				[NSString stringWithFormat:@"%C", 0xD0 ],		@"&ETH;",					
				[NSString stringWithFormat:@"%C", 0xD1 ],		@"&Ntilde;",					
				[NSString stringWithFormat:@"%C", 0xD2 ],		@"&Ograve;",					
				[NSString stringWithFormat:@"%C", 0xD3 ],		@"&Oacute;",					
				[NSString stringWithFormat:@"%C", 0xD4 ],		@"&Ocirc;",					
				[NSString stringWithFormat:@"%C", 0xD5 ],		@"&Otilde;",					
				[NSString stringWithFormat:@"%C", 0xD6 ],		@"&Ouml;",					
				[NSString stringWithFormat:@"%C", 0xD7 ],		@"&times;",					
				[NSString stringWithFormat:@"%C", 0xD8 ],		@"&Oslash;",					
				[NSString stringWithFormat:@"%C", 0xD9 ],		@"&Ugrave;",					
				[NSString stringWithFormat:@"%C", 0xDA ],		@"&Uacute;",					
				[NSString stringWithFormat:@"%C", 0xDB ],		@"&Ucirc;",					
				[NSString stringWithFormat:@"%C", 0xDC ],		@"&Uuml;",					
				[NSString stringWithFormat:@"%C", 0xDD ],		@"&Yacute;",					
				[NSString stringWithFormat:@"%C", 0xDE ],		@"&THORN;",					
				[NSString stringWithFormat:@"%C", 0xDF ],		@"&szlig;",					
				[NSString stringWithFormat:@"%C", 0xE0 ],		@"&agrave;",					
				[NSString stringWithFormat:@"%C", 0xE1 ],		@"&aacute;",					
				[NSString stringWithFormat:@"%C", 0xE2 ],		@"&acirc;",					
				[NSString stringWithFormat:@"%C", 0xE3 ],		@"&atilde;",					
				[NSString stringWithFormat:@"%C", 0xE4 ],		@"&auml;",					
				[NSString stringWithFormat:@"%C", 0xE5 ],		@"&aring;",					
				[NSString stringWithFormat:@"%C", 0xE6 ],		@"&aelig;",					
				[NSString stringWithFormat:@"%C", 0xE7 ],		@"&ccedil;",					
				[NSString stringWithFormat:@"%C", 0xE8 ],		@"&egrave;",					
				[NSString stringWithFormat:@"%C", 0xE9 ],		@"&eacute;",					
				[NSString stringWithFormat:@"%C", 0xEA ],		@"&ecirc;",					
				[NSString stringWithFormat:@"%C", 0xEB ],		@"&euml;",					
				[NSString stringWithFormat:@"%C", 0xEC ],		@"&igrave;",					
				[NSString stringWithFormat:@"%C", 0xED ],		@"&iacute;",					
				[NSString stringWithFormat:@"%C", 0xEE ],		@"&icirc;",					
				[NSString stringWithFormat:@"%C", 0xEF ],		@"&iuml;",					
				[NSString stringWithFormat:@"%C", 0xF0 ],		@"&eth;",					
				[NSString stringWithFormat:@"%C", 0xF1 ],		@"&ntilde;",					
				[NSString stringWithFormat:@"%C", 0xF2 ],		@"&ograve;",					
				[NSString stringWithFormat:@"%C", 0xF3 ],		@"&oacute;",					
				[NSString stringWithFormat:@"%C", 0xF4 ],		@"&ocirc;",					
				[NSString stringWithFormat:@"%C", 0xF5 ],		@"&otilde;",					
				[NSString stringWithFormat:@"%C", 0xF6 ],		@"&ouml;",					
				[NSString stringWithFormat:@"%C", 0xF7 ],		@"&divide;",					
				[NSString stringWithFormat:@"%C", 0xF8 ],		@"&oslash;",					
				[NSString stringWithFormat:@"%C", 0xF9 ],		@"&ugrave;",					
				[NSString stringWithFormat:@"%C", 0xFA ],		@"&uacute;",					
				[NSString stringWithFormat:@"%C", 0xFB ],		@"&ucirc;",					
				[NSString stringWithFormat:@"%C", 0xFC ],		@"&uuml;",					
				[NSString stringWithFormat:@"%C", 0xFD ],		@"&yacute;",					
				[NSString stringWithFormat:@"%C", 0xFE ],		@"&thorn;",					
				[NSString stringWithFormat:@"%C", 0xFF ],		@"&yuml;",					
				[NSString stringWithFormat:@"%C", 0x0152 ],		@"&OElig;", 				
				[NSString stringWithFormat:@"%C", 0x0153 ],		@"&oelig;", 				
				[NSString stringWithFormat:@"%C", 0x0160 ],		@"&Scaron;", 				
				[NSString stringWithFormat:@"%C", 0x0161 ],		@"&scaron;", 				
				[NSString stringWithFormat:@"%C", 0x0178 ],		@"&Yuml;", 				
				[NSString stringWithFormat:@"%C", 0x00 ],		@"&fnof;",   				
				[NSString stringWithFormat:@"%C", 0x02C6 ],		@"&circ;", 				
				[NSString stringWithFormat:@"%C", 0x02DC ],		@"&tilde;", 				
				[NSString stringWithFormat:@"%C", 0x391 ],		@"&Alpha;",				
				[NSString stringWithFormat:@"%C", 0x392 ],		@"&Beta;",				
				[NSString stringWithFormat:@"%C", 0x393 ],		@"&Gamma;",				
				[NSString stringWithFormat:@"%C", 0x394 ],		@"&Delta;",				
				[NSString stringWithFormat:@"%C", 0x395 ],		@"&Epsilon;",				
				[NSString stringWithFormat:@"%C", 0x396 ],		@"&Zeta;",				
				[NSString stringWithFormat:@"%C", 0x397 ],		@"&Eta;",				
				[NSString stringWithFormat:@"%C", 0x398 ],		@"&Theta;",				
				[NSString stringWithFormat:@"%C", 0x399 ],		@"&Iota;",				
				[NSString stringWithFormat:@"%C", 0x39A ],		@"&Kappa;",				
				[NSString stringWithFormat:@"%C", 0x39B ],		@"&Lambda;",				
				[NSString stringWithFormat:@"%C", 0x39C ],		@"&Mu;",				
				[NSString stringWithFormat:@"%C", 0x39D ],		@"&Nu;",				
				[NSString stringWithFormat:@"%C", 0x39E ],		@"&#xi;",			  	
				[NSString stringWithFormat:@"%C", 0x39F ],		@"&Omicron;",				
				[NSString stringWithFormat:@"%C", 0x3A0 ],		@"&Pi;",				
				[NSString stringWithFormat:@"%C", 0x3A1 ],		@"&Rho;",				
				[NSString stringWithFormat:@"%C", 0x3A3 ],		@"&Sigma;",				
				[NSString stringWithFormat:@"%C", 0x3A4 ],		@"&Tau;",				
				[NSString stringWithFormat:@"%C", 0x3A5 ],		@"&Upsilon;",				
				[NSString stringWithFormat:@"%C", 0x3A6 ],		@"&Phi;",				
				[NSString stringWithFormat:@"%C", 0x3A7 ],		@"&Chi;",				
				[NSString stringWithFormat:@"%C", 0x3A8 ],		@"&Psi;",				
				[NSString stringWithFormat:@"%C", 0x3A9 ],		@"&Omega;",				
				[NSString stringWithFormat:@"%C", 0x3B1 ],		@"&alpha;",				
				[NSString stringWithFormat:@"%C", 0x3B2 ],		@"&beta;",				
				[NSString stringWithFormat:@"%C", 0x3B3 ],		@"&gamma;",				
				[NSString stringWithFormat:@"%C", 0x3B4 ],		@"&delta;",				
				[NSString stringWithFormat:@"%C", 0x3B5 ],		@"&epsilon;",				
				[NSString stringWithFormat:@"%C", 0x3B6 ],		@"&zeta;",				
				[NSString stringWithFormat:@"%C", 0x3B7 ],		@"&eta;",				
				[NSString stringWithFormat:@"%C", 0x3B8 ],		@"&theta;",				
				[NSString stringWithFormat:@"%C", 0x3B9 ],		@"&iota;",				
				[NSString stringWithFormat:@"%C", 0x3BA ],		@"&kappa;",				
				[NSString stringWithFormat:@"%C", 0x3BB ],		@"&lambda;",				
				[NSString stringWithFormat:@"%C", 0x3BC ],		@"&mu;",				
				[NSString stringWithFormat:@"%C", 0x3BD ],		@"&nu;",				
				[NSString stringWithFormat:@"%C", 0x3BE ],		@"&#xi;",				
				[NSString stringWithFormat:@"%C", 0x3BF ],		@"&omicron;",				
				[NSString stringWithFormat:@"%C", 0x3C0 ],		@"&pi;",				
				[NSString stringWithFormat:@"%C", 0x3C1 ],		@"&rho;",				
				[NSString stringWithFormat:@"%C", 0x3C2 ],		@"&sigmaf;",				
				[NSString stringWithFormat:@"%C", 0x3C3 ],		@"&sigma;",				
				[NSString stringWithFormat:@"%C", 0x3C4 ],		@"&tau;",				
				[NSString stringWithFormat:@"%C", 0x3C5 ],		@"&upsilon;",				
				[NSString stringWithFormat:@"%C", 0x3C6 ],		@"&phi;",				
				[NSString stringWithFormat:@"%C", 0x3C7 ],		@"&chi;",				
				[NSString stringWithFormat:@"%C", 0x3C8 ],		@"&psi;",				
				[NSString stringWithFormat:@"%C", 0x3C9 ],		@"&omega;",				
				[NSString stringWithFormat:@"%C", 0x3D1 ],		@"&thetasym;",				
				[NSString stringWithFormat:@"%C", 0x3D2 ],		@"&upsih;",				
				[NSString stringWithFormat:@"%C", 0x3D3 ],		@"&piv;",				
				[NSString stringWithFormat:@"%C", 0x2022 ],		@"&bull;",			
				[NSString stringWithFormat:@"%C", 0x2026 ],		@"&hellip;",			
				[NSString stringWithFormat:@"%C", 0x2032 ],		@"&prime;",			
				[NSString stringWithFormat:@"%C", 0x2033 ],		@"&Prime;",			
				[NSString stringWithFormat:@"%C", 0x203E ],		@"&oline;",			
				[NSString stringWithFormat:@"%C", 0x2044 ],		@"&frasl;",   
				[NSString stringWithFormat:@"%C", 0x2118 ],		@"&weierp;",			
				[NSString stringWithFormat:@"%C", 0x2111 ],		@"&image;",			
				[NSString stringWithFormat:@"%C", 0x211C ],		@"&real;",			
				[NSString stringWithFormat:@"%C", 0x2122 ],		@"&trade;",				
				[NSString stringWithFormat:@"%C", 0x2135 ],		@"&alefsym;",		
				[NSString stringWithFormat:@"%C", 0x2190 ],		@"&larr;",			
				[NSString stringWithFormat:@"%C", 0x2191 ],		@"&uarr;",			
				[NSString stringWithFormat:@"%C", 0x2192 ],		@"&rarr;",			
				[NSString stringWithFormat:@"%C", 0x2193 ],		@"&darr;",			
				[NSString stringWithFormat:@"%C", 0x2194 ],		@"&harr;",			
				[NSString stringWithFormat:@"%C", 0x21B5 ],		@"&crarr;",			
				[NSString stringWithFormat:@"%C", 0x21D0 ],		@"&lArr;",			
				[NSString stringWithFormat:@"%C", 0x21D1 ],		@"&uArr;",			
				[NSString stringWithFormat:@"%C", 0x21D2 ],		@"&rArr;",			
				[NSString stringWithFormat:@"%C", 0x21D3 ],		@"&dArr;",			
				[NSString stringWithFormat:@"%C", 0x21D4 ],		@"&hArr;",			
				[NSString stringWithFormat:@"%C", 0x2200 ],		@"&forall;",			
				[NSString stringWithFormat:@"%C", 0x2202 ],		@"&part;",			
				[NSString stringWithFormat:@"%C", 0x2203 ],		@"&exist;",			
				[NSString stringWithFormat:@"%C", 0x2205 ],		@"&empty;",			
				[NSString stringWithFormat:@"%C", 0x2207 ],		@"&nabla;",			
				[NSString stringWithFormat:@"%C", 0x2208 ],		@"&isin;",			
				[NSString stringWithFormat:@"%C", 0x2209 ],		@"&notin;",			
				[NSString stringWithFormat:@"%C", 0x220B ],		@"&ni;",			
				[NSString stringWithFormat:@"%C", 0x220F ],		@"&prod;",			
				[NSString stringWithFormat:@"%C", 0x2211 ],		@"&sum;",			
				[NSString stringWithFormat:@"%C", 0x2212 ],		@"&minus;",			
				[NSString stringWithFormat:@"%C", 0x2217 ],		@"&lowast;",			
				[NSString stringWithFormat:@"%C", 0x221A ],		@"&radic;",			
				[NSString stringWithFormat:@"%C", 0x221D ],		@"&prop;",			
				[NSString stringWithFormat:@"%C", 0x221E ],		@"&infin;",			
				[NSString stringWithFormat:@"%C", 0x2220 ],		@"&ang;",			
				[NSString stringWithFormat:@"%C", 0x2227 ],		@"&and;",			
				[NSString stringWithFormat:@"%C", 0x2228 ],		@"&or;",			
				[NSString stringWithFormat:@"%C", 0x2229 ],		@"&cap;",			
				[NSString stringWithFormat:@"%C", 0x222A ],		@"&cup;",			
				[NSString stringWithFormat:@"%C", 0x222B ],		@"&int;",			
				[NSString stringWithFormat:@"%C", 0x2234 ],		@"&there4;",			
				[NSString stringWithFormat:@"%C", 0x223C ],		@"&sim;",			
				[NSString stringWithFormat:@"%C", 0x2245 ],		@"&cong;",			
				[NSString stringWithFormat:@"%C", 0x2248 ],		@"&asymp;",			
				[NSString stringWithFormat:@"%C", 0x2260 ],		@"&ne;",			
				[NSString stringWithFormat:@"%C", 0x2261 ],		@"&equiv;",			
				[NSString stringWithFormat:@"%C", 0x2264 ],		@"&le;",			
				[NSString stringWithFormat:@"%C", 0x2265 ],		@"&ge;",			
				[NSString stringWithFormat:@"%C", 0x2282 ],		@"&sub;",			
				[NSString stringWithFormat:@"%C", 0x2283 ],		@"&sup;",			
				[NSString stringWithFormat:@"%C", 0x2284 ],		@"&nsub;",			
				[NSString stringWithFormat:@"%C", 0x2286 ],		@"&sube;",			
				[NSString stringWithFormat:@"%C", 0x2287 ],		@"&supe;",			
				[NSString stringWithFormat:@"%C", 0x2295 ],		@"&oplus;",			
				[NSString stringWithFormat:@"%C", 0x2297 ],		@"&otimes;",			
				[NSString stringWithFormat:@"%C", 0x22A5 ],		@"&perp;",			
				[NSString stringWithFormat:@"%C", 0x22C5 ],		@"&sdot;",			
				[NSString stringWithFormat:@"%C", 0x2308 ],		@"&lceil;",			
				[NSString stringWithFormat:@"%C", 0x2309 ],		@"&rceil;",			
				[NSString stringWithFormat:@"%C", 0x230A ],		@"&lfloor;",			
				[NSString stringWithFormat:@"%C", 0x230B ],		@"&rfloor;",			
				[NSString stringWithFormat:@"%C", 0x2329 ],		@"&lang;",			
				[NSString stringWithFormat:@"%C", 0x232A ],		@"&rang;",			
				[NSString stringWithFormat:@"%C", 0x25CA ],		@"&loz;",			
				[NSString stringWithFormat:@"%C", 0x2660 ],		@"&spades;",
				[NSString stringWithFormat:@"%C", 0x2663 ],		@"&clubs;",
				[NSString stringWithFormat:@"%C", 0x2665 ],		@"&hearts;",
				[NSString stringWithFormat:@"%C", 0x2666 ],		@"&diams;",
				[NSString stringWithFormat:@"%C", 0x2002 ],		@"&ensp;", 		 
				[NSString stringWithFormat:@"%C", 0x2003 ],		@"&emsp;", 		 
				[NSString stringWithFormat:@"%C", 0x2009 ],		@"&thinsp;", 		 
				[NSString stringWithFormat:@"%C", 0x200C ],		@"&zwnj;", 		 
				[NSString stringWithFormat:@"%C", 0x200D ],		@"&zwj;", 		 
				[NSString stringWithFormat:@"%C", 0x200E ],		@"&lrm;", 		 
				[NSString stringWithFormat:@"%C", 0x200F ],		@"&rlm;", 		 
				[NSString stringWithFormat:@"%C", 0x2013 ],		@"&ndash;", 		 
				[NSString stringWithFormat:@"%C", 0x2014 ],		@"&mdash;", 		 
				[NSString stringWithFormat:@"%C", 0x2018 ],		@"&lsquo;", 		 
				[NSString stringWithFormat:@"%C", 0x2019 ],		@"&rsquo;", 		 
				[NSString stringWithFormat:@"%C", 0x201A ],		@"&sbquo;", 		 
				[NSString stringWithFormat:@"%C", 0x201C ],		@"&ldquo;", 		 
				[NSString stringWithFormat:@"%C", 0x201D ],		@"&rdquo;", 		 
				[NSString stringWithFormat:@"%C", 0x201E ],		@"&bdquo;", 		 
				[NSString stringWithFormat:@"%C", 0x2020 ],		@"&dagger;", 		 
				[NSString stringWithFormat:@"%C", 0x2021 ],		@"&Dagger;", 		 
				[NSString stringWithFormat:@"%C", 0x2030 ],		@"&permil;", 		 
				[NSString stringWithFormat:@"%C", 0x2039 ],		@"&lsaquo;", 		  
				nil
				] retain];	// forall quot lt forall
	specialTags_ = [[NSDictionary dictionaryWithObjectsAndKeys:
					@"\n",		@"<br>",
					nil
				] retain];
}
@end

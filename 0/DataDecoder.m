
#import "DataDecoder.h"

@implementation DataDecoder

// override

- (void) dealloc {
	DNSLog( @"DataDecoder - dealloc" );
#ifdef _DEBUG
	[codeNames_ release];
#endif
	free( codes_ );
	[super dealloc];
}

- (id) init {
	self = [super init];
	if (self != nil) {
		DNSLog( @"DataDecoder - init" );
		[self readyForDecoding];
#ifdef _DEBUG
		[self readyForDecodingTypeString];
#endif
	}
	return self;
}

// original method

- (NSString*)decodeNSData:(NSData*)data {
	NSString *decoded_strings = nil;
	int i;
	for( i = 0; i < JAPANESE_CHAR_CODE; i++ ) {
		decoded_strings = [[[NSString alloc] initWithData:data encoding:codes_[i]] autorelease];
		if( decoded_strings ) {
#ifdef _DEBUG
			DNSLog( @"Decoding with %@.", [codeNames_ objectAtIndex:i] );
#endif
			return decoded_strings;
		}
	}
	DNSLog( @"Decoding is failed." );
	return nil;
}

- (void) readyForDecoding {
	codes_ = (unsigned int *)malloc( sizeof(unsigned int) * JAPANESE_CHAR_CODE);
	unsigned int *p = codes_;
	*(p++) = CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingShiftJIS );
	*(p++) = NSShiftJISStringEncoding;
	*(p++) = CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingShiftJIS_X0213_00 );
	*(p++) = CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingShiftJIS_X0213_MenKuTen );
	*(p++) = CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingEUC_JP );
	*(p++) = NSJapaneseEUCStringEncoding;
	*(p++) = NSUTF8StringEncoding;
	*(p++) = CFStringConvertEncodingToNSStringEncoding( CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingMacJapanese ));
	*(p++) = NSMacOSRomanStringEncoding;
	*(p++) = CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingDOSJapanese );
	*(p++) = CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingASCII );
	*(p++) = NSASCIIStringEncoding;
	*(p++) = CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingJIS_X0201_76 );
	*(p++) = CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingJIS_X0208_83 );
	*(p++) = CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingJIS_X0208_90 );
	*(p++) = CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingJIS_X0212_90 );
	*(p++) = CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingJIS_C6226_78 );
	*(p++) = CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingISO_2022_JP );
	*(p++) = NSISO2022JPStringEncoding;
	*(p++) = CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingISO_2022_JP_2 );
	*(p++) = CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingISO_2022_JP_1 );
	*(p++) = CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingISO_2022_JP_3 );
	*(p++) = CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingISO_2022_CN );
	*(p++) = CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingISO_2022_CN_EXT );
	*(p++) = CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingISO_2022_KR );
	*(p++) = CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingNextStepJapanese );
	*(p++) = NSProprietaryStringEncoding;
}

#ifdef _DEBUG
- (void) readyForDecodingTypeString {
	codeNames_ = [[NSMutableArray array] retain];
	[codeNames_ addObject:@"kCFStringEncodingShiftJIS"];
	[codeNames_ addObject:@"NSShiftJISStringEncoding"];
	[codeNames_ addObject:@"kCFStringEncodingShiftJIS_X0213_00"];
	[codeNames_ addObject:@"kCFStringEncodingShiftJIS_X0213_MenKuTen"];
	[codeNames_ addObject:@"kCFStringEncodingEUC_JP"];
	[codeNames_ addObject:@"NSJapaneseEUCStringEncoding"];
	[codeNames_ addObject:@"NSUTF8StringEncoding"];
	[codeNames_ addObject:@"kCFStringEncodingMacJapanese"];
	[codeNames_ addObject:@"NSMacOSRomanStringEncoding"];
	[codeNames_ addObject:@"kCFStringEncodingDOSJapanese"];
	[codeNames_ addObject:@"kCFStringEncodingASCII"];
	[codeNames_ addObject:@"NSASCIIStringEncoding"];
	[codeNames_ addObject:@"kCFStringEncodingJIS_X0201_76"];
	[codeNames_ addObject:@"kCFStringEncodingJIS_X0208_83"];
	[codeNames_ addObject:@"kCFStringEncodingJIS_X0208_90"];
	[codeNames_ addObject:@"kCFStringEncodingJIS_X0212_90"];
	[codeNames_ addObject:@"kCFStringEncodingJIS_C6226_78"];
	[codeNames_ addObject:@"kCFStringEncodingISO_2022_JP"];
	[codeNames_ addObject:@"NSISO2022JPStringEncoding"];
	[codeNames_ addObject:@"kCFStringEncodingISO_2022_JP_2"];
	[codeNames_ addObject:@"kCFStringEncodingISO_2022_JP_1"];
	[codeNames_ addObject:@"kCFStringEncodingISO_2022_JP_3"];
	[codeNames_ addObject:@"kCFStringEncodingISO_2022_CN"];
	[codeNames_ addObject:@"kCFStringEncodingISO_2022_CN_EXT"];
	[codeNames_ addObject:@"kCFStringEncodingISO_2022_KR"];
	[codeNames_ addObject:@"kCFStringEncodingNextStepJapanese"];
	[codeNames_ addObject:@"NSProprietaryStringEncoding"];
}
#endif

@end

//
//  string_tool.m
//  ch2ParserTest
//
//  Created by sonson on 08/12/10.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "StringDecoder.h"

#define NUMBER_OF_CODE 5

unsigned int	*codes = NULL;
NSMutableArray	*codeNames = nil;

@implementation StringDecoder

+ (void)initialize {
	DNSLogMethod
	codes = (unsigned int*)malloc( sizeof( unsigned int ) * NUMBER_OF_CODE );
	codes[0] = CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingShiftJIS );
	codes[1] = NSShiftJISStringEncoding;
	codes[2] = NSISO2022JPStringEncoding;
	codes[3] = CFStringConvertEncodingToNSStringEncoding( CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingMacJapanese ));
	codes[4] = CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingShiftJIS_X0213_00 );
	
	codeNames = [[NSMutableArray alloc] init];
	[codeNames addObject:@"kCFStringEncodingShiftJIS"];
	[codeNames addObject:@"NSShiftJISStringEncoding"];
	[codeNames addObject:@"kCFStringEncodingISO_2022_JP"];
	[codeNames addObject:@"kCFStringEncodingMacJapanese"];
	[codeNames addObject:@"kCFStringEncodingShiftJIS_X0213_00"];
}

+ (NSString*)decodeBytesFrom:(char*)p length:(int)length {
	NSString *decoded_strings = nil;
	if( length == 0 )
		return @"";
	int i;
	for( i = 0; i < NUMBER_OF_CODE; i++ ) {
		decoded_strings = [[NSString alloc] initWithBytes:p length:length encoding:codes[i]];
		if( decoded_strings ) {
			if( [decoded_strings length] > 0 ) {
				// DNSLog( @"Decoding with %@", [codeNames objectAtIndex:i]);
				return decoded_strings;
			}
			[decoded_strings release];
		}
	}
	return nil;
};

+ (NSString*)decodeBytes:(char*)p from:(int)from to:(int)to {
	NSString *decoded_strings = nil;
	int i;
	for( i = 0; i < NUMBER_OF_CODE; i++ ) {
		decoded_strings = [[NSString alloc] initWithBytes:p+from length:to-from encoding:codes[i]];
		if( decoded_strings ) {
			if( [decoded_strings length] > 0 ) {
				// DNSLog( @"Decoding with %@", [codeNames objectAtIndex:i]);
				return decoded_strings;
			}
			[decoded_strings release];
		}
	}
	return nil;
};

@end

//
//  string_tool.m
//  ch2ParserTest
//
//  Created by sonson on 08/12/10.
//  Copyright 2008 sonson. All rights reserved.
//

#import "StringDecoder.h"

#define NUMBER_OF_CODE 5

unsigned int	*codes = NULL;
NSMutableArray	*codeNames = nil;

@implementation StringDecoder

+ (void)initialize {
	DNSLogMethod
	codes = (unsigned int*)malloc( sizeof( unsigned int ) * NUMBER_OF_CODE );
	unsigned int* p = codes;
	//	*(p++) = CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingShiftJIS );
	*(p++) = NSShiftJISStringEncoding;
	*(p++) = NSISO2022JPStringEncoding;
	*(p++) = CFStringConvertEncodingToNSStringEncoding( CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingMacJapanese ));
	*(p++) = CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingShiftJIS_X0213_00 );
	
	codeNames = [[NSMutableArray alloc] init];
	//	[codeNames addObject:@"kCFStringEncodingShiftJIS"];
	[codeNames addObject:@"NSShiftJISStringEncoding"];
	[codeNames addObject:@"kCFStringEncodingISO_2022_JP"];
	[codeNames addObject:@"kCFStringEncodingMacJapanese"];
	[codeNames addObject:@"kCFStringEncodingShiftJIS_X0213_00"];
}

+ (unsigned int)encodeingFromBytes:(char*)p length:(int)length {
	if( length < 1 )
		return 0;
	NSString *decoded_strings = nil;
	int i;
	for( i = 0; i < NUMBER_OF_CODE; i++ ) {
		decoded_strings = [[NSString alloc] initWithBytes:p length:length encoding:codes[i]];
		if( decoded_strings ) {
			if( [decoded_strings length] > 0 ) {
				[decoded_strings release];
				return codes[i];
			}
			[decoded_strings release];
		}
	}
	return 0;
}

+ (NSString*)decodeBytesFrom:(char*)p length:(int)length {
	//	DNSLog( @"decodeBytesFrom - %d", counter++ );
	if( length < 1 )
		return @"";
	NSString *decoded_strings = nil;
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

+ (NSString*)decodeBytesFrom:(char*)p length:(int)length encoding:(int*)encoding {
	if( length < 1 )
		return @"";
	NSString *decoded_strings = nil;
	int i;
	for( i = 0; i < NUMBER_OF_CODE; i++ ) {
		decoded_strings = [[NSString alloc] initWithBytes:p length:length encoding:codes[i]];
		if( decoded_strings ) {
			if( [decoded_strings length] > 0 ) {
				// DNSLog( @"Decoding with %@", [codeNames objectAtIndex:i]);
				//	DNSLog( @"%@", decoded_strings );
				*encoding = codes[i];
				return decoded_strings;
			}
			[decoded_strings release];
		}
	}
	return nil;
};

+ (NSString*)decodeBytes:(char*)p from:(int)from to:(int)to {
	if( to - from < 1 )
		return @"";
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

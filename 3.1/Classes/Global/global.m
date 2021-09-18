//
//  global.m
//  2tch
//
//  Created by sonson on 08/05/27.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "global.h"

#include <ctype.h>

NSDictionary* isURLOf2ch( NSString*url ) {
	NSArray*elements = [url componentsSeparatedByString:@"/"];
	if( [elements count] >= 7 ) {
		
		NSString* server = [elements objectAtIndex:2];
		NSString* boardPath = [elements objectAtIndex:5];
		NSString* dat = [elements objectAtIndex:6];
		
		NSArray* serverElements = [server componentsSeparatedByString:@"."];
		
		if( [serverElements count] == 3 ) {
			if( [[serverElements objectAtIndex:1] isEqualToString:@"2ch"] ) {
				NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
									  server,		@"server",
									  boardPath,	@"boardPath",
									  dat,		@"dat",
									  nil];
				return dict;
			}
		}
	}
	return nil;
}

static int isSingleByte( int c ) {
	if( isalnum( c ) )
		return YES;
	if( c == '.' || c == '-' || c == '_' )
		return YES;
	return NO;
}

static int decodeMultiByteOfOnePass( int input ) {
	int c = 0;
	if( isdigit( input ) ) {
		c += ( input - '0' );
	} else if ('a' <= input && input <= 'f') {
		c += (10 + ( input - 'a' ) );
	}	
	return c;
}

@implementation NSString (PercentEscape)
- (NSString*) URLdecode {
	NSData* data = [self dataUsingEncoding: NSASCIIStringEncoding];
	NSMutableString* result = [NSMutableString string];
	
	int i;
	const unsigned char* bytes = [data bytes];
	for (i = 0; i < [data length]; i++) {
		if (bytes[i] == '%') {
			int c = 0;
			
			i++;
			if (isdigit(bytes[i])) {
				c += (bytes[i] - '0');
			} else if ('a' <= bytes[i] && bytes[i] <= 'f') {
				c += (10 + (bytes[i] - 'a'));
			}
			
			c <<= 4;
			
			i++;
			if (isdigit(bytes[i])) {
				c += (bytes[i] - '0');
			} else if ('a' <= bytes[i] && bytes[i] <= 'f') {
				c += (10 + (bytes[i] - 'a'));
			}
			
			[result appendFormat: @"%c", c];
		} else if (bytes[i] == '+') {
			[result appendString: @" "];
		} else {
			[result appendFormat: @"%c", bytes[i]];
		}
	}
	
	return result;
}

- (NSString*) URLencode {
	NSData* data = [self dataUsingEncoding: NSShiftJISStringEncoding];
	NSMutableString* result = [NSMutableString string];
	
	int i;
	const unsigned char* bytes = [data bytes];
	for (i = 0; i < [data length]; i++) {
		if(isalnum(bytes[i]) || 
		   bytes[i] == '.' || bytes[i] == '-' || bytes[i] == '_') {
			[result appendFormat: @"%c", bytes[i]];
		} else if (bytes[i] == ' ') {
			[result appendString: @"+"];
		} else {
			[result appendFormat: @"%%%02x", bytes[i]];
		}
	}
	return result;
}

- (NSString*) URLdecodeNew {
	NSData* data = [self dataUsingEncoding: NSASCIIStringEncoding];
	NSMutableString* result = [NSMutableString string];
	
	int i;
	const unsigned char* bytes = [data bytes];
	for (i = 0; i < [data length]; i++) {
		if (bytes[i] == '%') {
			int c = 0;
			
			i++;
			if (isdigit(bytes[i])) {
				c += (bytes[i] - '0');
			} else if ('a' <= bytes[i] && bytes[i] <= 'f') {
				c += (10 + (bytes[i] - 'a'));
			}
			
			c <<= 4;
			
			i++;
			if (isdigit(bytes[i])) {
				c += (bytes[i] - '0');
			} else if ('a' <= bytes[i] && bytes[i] <= 'f') {
				c += (10 + (bytes[i] - 'a'));
			}
			
			[result appendFormat: @"%c", c];
		} else if (bytes[i] == '+') {
			[result appendString: @" "];
		} else {
			[result appendFormat: @"%c", bytes[i]];
		}
	}
	
	return result;
}

- (NSString*) URLencodeNew {
	NSData* data = [self dataUsingEncoding: NSShiftJISStringEncoding];
	NSMutableString* result = [NSMutableString string];
	
	int i;
	const unsigned char* bytes = [data bytes];
	for (i = 0; i < [data length]; i++) {
		if( isSingleByte( bytes[i] ) ) {
			[result appendFormat: @"%c", bytes[i]];
		} else if (bytes[i] == ' ') {
			[result appendString: @"+"];
		} else {
			[result appendFormat: @"%%%02x", bytes[i]];
		}
	}
	
	return result;
}
@end

/*
@implementation NSDate (RFC1123)
- (NSString*) descriptionInRFC1123 {
	return [self descriptionWithCalendarFormat: @"%a, %d %b %Y %H:%M:%S GMT"
									  timeZone: [NSTimeZone timeZoneWithName: @"GMT"]
										locale: nil];
}
@end
*/

#pragma mark For auto text decoding

#define			NUMBER_OF_JAPANESE_CHAR_CODES	26
NSArray*		codes = nil;
NSMutableArray*	codeNames = nil;

NSString* decodeNSData(NSData* data) {
	initDataCode();
	NSString *decoded_strings = nil;
	int i;
	for( i = 0; i < NUMBER_OF_JAPANESE_CHAR_CODES; i++ ) {
		decoded_strings = [[[NSString alloc] initWithData:data encoding:[[codes objectAtIndex:i] unsignedIntValue]] autorelease];
		if( decoded_strings ) {
			if( [decoded_strings length] > 0 ) {
				// DNSLog( @"Decoding with %@", [codeNames objectAtIndex:i]);
				return decoded_strings;
			}
		}
	}
	//	DNSLog( @"Decoding is failed." );
	return nil;
};

void readyForDecoding() {
	if( codes == nil ) {
		codes = [[NSArray arrayWithObjects:
				  [NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingShiftJIS )],
				  [NSNumber numberWithUnsignedInt:NSShiftJISStringEncoding],
				  [NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingShiftJIS_X0213_00 )],
				  [NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingShiftJIS_X0213_MenKuTen )],
				  [NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingEUC_JP )],
				  [NSNumber numberWithUnsignedInt:NSJapaneseEUCStringEncoding],
				  [NSNumber numberWithUnsignedInt:NSUTF8StringEncoding],
				  [NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding( CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingMacJapanese ))],
				  [NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingDOSJapanese )],	[NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingJIS_X0201_76 )],
				  [NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingJIS_X0208_83 )],
				  [NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingJIS_X0208_90 )],
				  [NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingJIS_X0212_90 )],
				  [NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingJIS_C6226_78 )],
				  [NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingISO_2022_JP )],
				  [NSNumber numberWithUnsignedInt:NSISO2022JPStringEncoding],
				  [NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingISO_2022_JP_2 )],
				  [NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingISO_2022_JP_1 )],
				  [NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingISO_2022_JP_3 )],
				  [NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingISO_2022_CN )],
				  [NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingISO_2022_CN_EXT )],
				  [NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingISO_2022_KR )],
				  [NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingNextStepJapanese )],
				  [NSNumber numberWithUnsignedInt:CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingASCII )],
				  [NSNumber numberWithUnsignedInt:NSASCIIStringEncoding],
				  [NSNumber numberWithUnsignedInt:NSMacOSRomanStringEncoding],
				  //  [NSNumber numberWithUnsignedInt:NSProprietaryStringEncoding],
				  nil] retain];
	}
}

void readyForDecodingTypeString() {
	if( codeNames == nil ) {
		codeNames = [[NSMutableArray alloc] init]; //[[NSMutableArray array] retain];
		[codeNames addObject:@"kCFStringEncodingShiftJIS"];
		[codeNames addObject:@"NSShiftJISStringEncoding"];
		[codeNames addObject:@"kCFStringEncodingShiftJIS_X0213_00"];
		[codeNames addObject:@"kCFStringEncodingShiftJIS_X0213_MenKuTen"];
		[codeNames addObject:@"kCFStringEncodingEUC_JP"];
		[codeNames addObject:@"NSJapaneseEUCStringEncoding"];
		[codeNames addObject:@"NSUTF8StringEncoding"];
		[codeNames addObject:@"kCFStringEncodingMacJapanese"];
		[codeNames addObject:@"kCFStringEncodingDOSJapanese"];
		[codeNames addObject:@"kCFStringEncodingJIS_X0201_76"];
		[codeNames addObject:@"kCFStringEncodingJIS_X0208_83"];
		[codeNames addObject:@"kCFStringEncodingJIS_X0208_90"];
		[codeNames addObject:@"kCFStringEncodingJIS_X0212_90"];
		[codeNames addObject:@"kCFStringEncodingJIS_C6226_78"];
		[codeNames addObject:@"kCFStringEncodingISO_2022_JP"];
		[codeNames addObject:@"NSISO2022JPStringEncoding"];
		[codeNames addObject:@"kCFStringEncodingISO_2022_JP_2"];
		[codeNames addObject:@"kCFStringEncodingISO_2022_JP_1"];
		[codeNames addObject:@"kCFStringEncodingISO_2022_JP_3"];
		[codeNames addObject:@"kCFStringEncodingISO_2022_CN"];
		[codeNames addObject:@"kCFStringEncodingISO_2022_CN_EXT"];
		[codeNames addObject:@"kCFStringEncodingISO_2022_KR"];
		[codeNames addObject:@"kCFStringEncodingNextStepJapanese"];
		[codeNames addObject:@"kCFStringEncodingASCII"];
		[codeNames addObject:@"NSASCIIStringEncoding"];
		[codeNames addObject:@"NSMacOSRomanStringEncoding"];
		[codeNames addObject:@"NSProprietaryStringEncoding"];
	}
}

void initDataCode() {
	readyForDecoding();
	readyForDecodingTypeString();
}

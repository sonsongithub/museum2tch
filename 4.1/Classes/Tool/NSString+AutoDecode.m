//
//  NSString+AutoDecode.m
//  2tch
//
//  Created by sonson on 09/02/14.
//  Copyright 2009 sonson. All rights reserved.
//

#import "NSString+AutoDecode.h"

unsigned int	*NSStringCandidateCodes = NULL;
NSMutableArray	*NSStringCandidateCodeNames = nil;

#define NUMBER_OF_CODE 4

@implementation NSString(AutoDecode)

+ (void)initialize {
	DNSLogMethod
	unsigned int *p = (unsigned int*)malloc( sizeof( unsigned int ) * NUMBER_OF_CODE );
	NSStringCandidateCodes = p;
	//	*(p++) = CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingShiftJIS );
	*(p++) = NSShiftJISStringEncoding;
	*(p++) = NSISO2022JPStringEncoding;
	*(p++) = CFStringConvertEncodingToNSStringEncoding( CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingMacJapanese ));
	*(p++) = CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingShiftJIS_X0213_00 );
	
	NSStringCandidateCodeNames = [[NSMutableArray alloc] init];
	//	[codeNames addObject:@"kCFStringEncodingShiftJIS"];
	[NSStringCandidateCodeNames addObject:@"NSShiftJISStringEncoding"];
	[NSStringCandidateCodeNames addObject:@"kCFStringEncodingISO_2022_JP"];
	[NSStringCandidateCodeNames addObject:@"kCFStringEncodingMacJapanese"];
	[NSStringCandidateCodeNames addObject:@"kCFStringEncodingShiftJIS_X0213_00"];
}

+ (NSString*)stringFromBytes:(char*)p length:(int)length encodingResult:(int*)encodingResult {
	if( length < 1 )
		return @"";
	NSString *decoded_strings = nil;
	int i;
	for( i = 0; i < NUMBER_OF_CODE; i++ ) {
		decoded_strings = [[NSString alloc] initWithBytes:p length:length encoding:NSStringCandidateCodes[i]];
		if( decoded_strings ) {
			if( [decoded_strings length] > 0 ) {
				// DNSLog( @"Decoding with %@", [NSStringCandidateCodeNames objectAtIndex:i]);
				// DNSLog( @"%@", decoded_strings );
				if( encodingResult )
					*encodingResult = NSStringCandidateCodes[i];
				return [decoded_strings autorelease];
			}
			[decoded_strings release];
		}
	}	
	return nil;
}

+ (NSString*)stringFromBytes:(char*)p length:(int)length {
	return [NSString stringFromBytes:p length:length encodingResult:nil];
}

+ (NSString*)stringFromBytes:(char*)p offset:(int)offset tail:(int)tail encodingResult:(int*)encodingResult {
	int length = tail - offset;
	if( length < 1 ) {
		return @"";
	}
	NSString *decoded_strings = nil;
	int i;
	for( i = 0; i < NUMBER_OF_CODE; i++ ) {
		decoded_strings = [[NSString alloc] initWithBytes:p+offset length:tail-offset encoding:NSStringCandidateCodes[i]];
		//decoded_strings = [[NSString alloc] initWithBytes:p length:length encoding:NSStringCandidateCodes[i]];
		if( decoded_strings ) {
			if( [decoded_strings length] > 0 ) {
				// DNSLog( @"Decoding with %@", [NSStringCandidateCodeNames objectAtIndex:i]);
				// DNSLog( @"%@", decoded_strings );
				if( encodingResult )
					*encodingResult = NSStringCandidateCodes[i];
				return [decoded_strings autorelease];
			}
			[decoded_strings release];
		}
	}
	DNSLog( @"failed" );
	return nil;
}

+ (NSString*)stringFromBytes:(char*)p offset:(int)offset tail:(int)tail {
	return [NSString stringFromBytes:p offset:offset tail:tail encodingResult:nil];
}

+ (NSString*)stringFromBytes:(char*)p range:(NSRange)range encodingResult:(int*)encodingResult {
	int offset = range.location;
	int tail = offset + range.length;
	int length = tail - offset;
	if( length < 1 ) {
		return @"";
	}
	NSString *decoded_strings = nil;
	int i;
	for( i = 0; i < NUMBER_OF_CODE; i++ ) {
		decoded_strings = [[NSString alloc] initWithBytes:p+offset length:tail-offset encoding:NSStringCandidateCodes[i]];
		//decoded_strings = [[NSString alloc] initWithBytes:p length:length encoding:NSStringCandidateCodes[i]];
		if( decoded_strings ) {
			if( [decoded_strings length] > 0 ) {
				// DNSLog( @"Decoding with %@", [NSStringCandidateCodeNames objectAtIndex:i]);
				// DNSLog( @"%@", decoded_strings );
				if( encodingResult )
					*encodingResult = NSStringCandidateCodes[i];
				return [decoded_strings autorelease];
			}
			[decoded_strings release];
		}
	}
	DNSLog( @"failed" );
	return nil;
}

+ (NSString*)stringFromBytes:(char*)p range:(NSRange)range {
	return [NSString stringFromBytes:p range:range encodingResult:nil];
}

+ (NSString*)stringFromBytesNoCopy:(char*)p range:(NSRange)range encodingResult:(int*)encodingResult {
	int offset = range.location;
	int tail = offset + range.length;
	int length = tail - offset;
	if( length < 1 ) {
		return @"";
	}
	NSString *decoded_strings = nil;
	int i;
	for( i = 0; i < NUMBER_OF_CODE; i++ ) {
		decoded_strings = [[NSString alloc] initWithBytesNoCopy:p+offset length:tail-offset encoding:NSStringCandidateCodes[i] freeWhenDone:NO];
		//decoded_strings = [[NSString alloc] initWithBytes:p length:length encoding:NSStringCandidateCodes[i]];
		if( decoded_strings ) {
			if( [decoded_strings length] > 0 ) {
				// DNSLog( @"Decoding with %@", [NSStringCandidateCodeNames objectAtIndex:i]);
				// DNSLog( @"%@", decoded_strings );
				if( encodingResult )
					*encodingResult = NSStringCandidateCodes[i];
				return [decoded_strings autorelease];
			}
			[decoded_strings release];
		}
	}
	DNSLog( @"failed" );
	return nil;
}

+ (NSString*)stringFromBytesNoCopy:(char*)p range:(NSRange)range {
	return [NSString stringFromBytesNoCopy:p range:range encodingResult:nil];
}

@end

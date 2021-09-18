//
//  SubjectTxtParser.m
//  parser
//
//  Created by sonson on 08/12/11.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DatParser.h"
#import "StringDecoder.h"

const char url_string[] = {
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	1, // !
	0,
	0,
	1, // $
	1, // %
	1, // &
	1, // '
	1, // (
	1, // )
	1, // *
	1, // +
	2, // ,
	2, // -
	1, // .
	1, // /
	2, // 0
	2, // 1
	2, // 2
	2, // 3
	2, // 4
	2, // 5
	2, // 6
	2, // 7
	2, // 8
	2, // 9
	1, // :
	1, // ;
	0,
	1, // =
	0,
	1, // ?
	1, // @
	1, // A
	1, // B
	1, // C
	1, // D
	1, // E
	1, // F
	1, // G
	1, // H
	1, // I
	1, // J
	1, // K
	1, // L
	1, // M
	1, // N
	1, // O
	1, // P
	1, // Q
	1, // R
	1, // S
	1, // T
	1, // U
	1, // V
	1, // W
	1, // X
	1, // Y
	1, // Z
	0,
	0,
	0,
	0,
	1, // _
	0,
	1, // a
	1, // b
	1, // c
	1, // d
	1, // e
	1, // f
	1, // g
	1, // h
	1, // i
	1, // j
	1, // k
	1, // l
	1, // m
	1, // n
	1, // o
	1, // p
	1, // q
	1, // r
	1, // s
	1, // t
	1, // u
	1, // v
	1, // w
	1, // x
	1, // y
	1, // z
	0,
	0,
	0,
	1, // ~
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0
};
	
typedef enum {
	kSearching,
	kFoundHTTP,
	kFoundTTP,
	kFoundAnchor
}kHTTPSearch;


NSMutableString* extractHTTP( char*p, int head, int tail ) {
	NSMutableString* string = [[NSMutableString alloc] init];
	int i;
	int http_start_pos = 0;
	int anchor_start_pos = 0;
	int terminate = head;
	int searchMode = kSearching;
	const char* http_template = "http:/";
	const char* ttp_template = "ttp://";
	const char* anchor = "&gt;";
	for( i = head; i < tail; i++ ) {
		if( !strncmp( p + i, "~", 1 ) ) {
			NSLog( @"found - %d", *(p+i) );
		}
		
		if( searchMode == kSearching ) {
			if( i < tail - 6 ) {
				if( !strncmp( p + i, http_template, 6 ) ) {
					//	NSLog( @"%d", i - head);
					http_start_pos = i;
					i += 6;
					searchMode = kFoundHTTP;
				}
				else if( !strncmp( p + i, ttp_template, 6 ) ) {
					//	NSLog( @"%d", i - head);
					http_start_pos = i;
					i += 6;
					searchMode = kFoundTTP;
				}
			}
			if( i < tail - 4 ) {
				if( !strncmp( p + i, anchor, 4 ) ) {
					searchMode = kFoundAnchor;
					anchor_start_pos = i;
					i += 4;
				}
			}
			if( i < tail - 25 ) {
				if( !strncmp( p + i, " target=\"_blank\">&gt;&gt;", 25 ) ) {
					NSString* to_target_blank = [StringDecoder decodeBytesFrom:p + terminate length:i - terminate];
					i+=16;
					terminate = i;
					[string appendString:to_target_blank];
					[to_target_blank release];
				}
			}
		}
		else if( searchMode == kFoundTTP || searchMode == kFoundHTTP ) {
			if( url_string[*(p+i)] > 0) {
			}
			else {
				NSString* url_prev = [StringDecoder decodeBytesFrom:p + terminate length:http_start_pos - terminate];
				NSString* url = [StringDecoder decodeBytesFrom:p + http_start_pos length:i - http_start_pos];
				
				//NSString* url_prev = decodeBytes( p + terminate, http_start_pos - terminate );
				//NSString* url = decodeBytes( p + http_start_pos, i - http_start_pos );
				//NSLog( @"%@", url_prev );
				//NSLog( @"%@", url );
				
				NSString* revisedURL = [url stringByReplacingOccurrencesOfString:@"‾" withString:@"~"];
				
				
				[string appendString:url_prev];
				if( searchMode == kFoundTTP )
					[string appendFormat:@"<a href=\"h%@\">%@</a>", revisedURL, revisedURL];
				else if( searchMode == kFoundHTTP )
					[string appendFormat:@"<a href=\"%@\">%@</a>", revisedURL, revisedURL];
				
				http_start_pos = 0;
				searchMode = kSearching;
				terminate = i;
				[url_prev release];
				[url release];
			}
		}
		else if( searchMode == kFoundAnchor ) {
			if( url_string[*(p+i)] > 2 && i > anchor_start_pos + 5 ) {
			}
			else if( url_string[*(p+i)] > 1 && i > anchor_start_pos + 6 ) {
			}
			else {
				if( i - anchor_start_pos - 5 > 0 ) {
					NSString* anchor_prev = [StringDecoder decodeBytesFrom:p + terminate length:anchor_start_pos - terminate];
					NSString* num = [StringDecoder decodeBytesFrom:p + anchor_start_pos + 4 length:i - anchor_start_pos - 4];
					
					
					
					//NSString* anchor_prev = decodeBytes( p + terminate, anchor_start_pos - terminate );
					//NSString* num = decodeBytes( p + anchor_start_pos + 4, i - anchor_start_pos - 4 );
					
					[string appendString:anchor_prev];
					[string appendFormat:@"<a href=\"../%@\">&gt;%@</a>", num, num];
					
					[anchor_prev release];
					[num release];
					terminate = i;
				}
				anchor_start_pos = 0;
				searchMode = kSearching;
			}
		}
	}
	NSString* a = [StringDecoder decodeBytesFrom:p + terminate length:tail-terminate];
	// NSString* a = decodeBytes( p + terminate, tail-terminate);
	if( a != nil )
		[string appendString:a];
	[a release];
	return string;
}

NSMutableString* elminateHTMLTag( char*p, int head, int tail ) {
	NSMutableString* string = [[NSMutableString alloc] init];
	
	int i;
	int ampersand = -1;
	int terminate = head;
	
	for( i = head; i < tail; i++ ) {
		if( *( p + i ) == '<' ) {
			ampersand = i;
		}
		if( *( p + i ) == '>' && ampersand != -1) {
			NSString* a = [StringDecoder decodeBytesFrom:p + terminate length:ampersand - terminate];
			//NSString* a = decodeBytes( p + terminate, ampersand - terminate);
			if( a != nil ) {
				[string appendString:a];
				[a release];
			}
			ampersand = -1;
			terminate = i+1;
		}
	}
	NSString* a = [StringDecoder decodeBytesFrom:p + terminate length:tail-terminate];
	// NSString* a = decodeBytes( p + terminate, tail-terminate);
	//NSLog( @"%@", a );
	if( a != nil )
		[string appendString:a];
	[a release];
	return string;
}

BOOL searchDatDivider( char*p, int head, int tail, int *position ) {
	int i;
	int counter = 0;
	const char* dat_template = "<>";
	if( tail - head < 2 )
		return NO;
	for( i = head; i < tail - 1; i++ ) {
		if( !strncmp( p + i, dat_template, 2 ) ) {
			*(position++) = i;
			counter++;
		}
	}
	if( counter == 4 )
		return YES;
	return NO;
}

@implementation DatParser

+ (NSArray*)getNumbers:(NSString*)url {
	NSArray *ary = [url componentsSeparatedByString:@"/"];
	NSString* res_num = [ary objectAtIndex:[ary count]-1];
	NSMutableArray* res = [NSMutableArray array];
	NSArray *numbers = [res_num componentsSeparatedByString:@"-"];
	int i;
	if( [numbers count] > 1 ) {
		for( i = [[numbers objectAtIndex:0] intValue]; i <= [[numbers objectAtIndex:1] intValue]; i++ ) {
			[res addObject:[NSNumber numberWithInt:i]];
		}
	}
	else {
		[res addObject:[NSNumber numberWithInt:[res_num intValue]]];
	}
	return res;
}

+ (void)parse:(NSData*)data toArray:(NSMutableArray*)array {
	DNSLogMethod
	int i,head = 0;
	char*p = (char*)[data bytes];
	int length = [data length];
	
	//int counter = 0;
	
	for( i = 0; i < length; i++ ) {
		unsigned char c = *( p + i );
		if( c == 0x0A ) {
			int position[5];
			BOOL re = searchDatDivider( p, head, i, position );
			if( re ) {
				NSString* name = elminateHTMLTag( p, head, position[0] );
				NSString* date_id = elminateHTMLTag( p, + position[1] + 2, position[2] );
				NSString* email = [StringDecoder decodeBytesFrom:p + position[0] + 2 length:position[1] - position[0] - 2];
				NSString* body = extractHTTP( p, position[2] + 2, position[3] );
				NSString* thread_title = [StringDecoder decodeBytesFrom:p + position[3] + 2 length:i - position[3]-1];
				
				NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
									  name,		@"name",
									  email,	@"email",
									  date_id,	@"date_id",
									  body,		@"body",
									  nil];
				[array addObject:dict];
				
				[name release];
				[email release];
				[date_id release];
				[body release];
				[thread_title release];
				//	if( counter++ > 20 )
				//	return;
			}
			head = i + 1;
		}
	}
}
@end

//
//  SubjectTxtParser.m
//  parser
//
//  Created by sonson on 08/12/11.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DatParser.h"
#import "StringDecoder.h"
#import "SubjectParser.h"
#import "ThreadLayoutComponent.h"
#import "ThreadResData.h"
#import "Dat.h"

unsigned char* pp = NULL;

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
3, // 0
3, // 1
3, // 2
3, // 3
3, // 4
3, // 5
3, // 6
3, // 7
3, // 8
3, // 9
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
	kFoundAmpersand,
	kFoundAnchorHref,
	kFoundAnchor
}kHTTPSearch;

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

NSMutableString* elminateHTMLTagAndSpecialChars( char*p, int head, int tail ) {
	NSMutableString* string = [[NSMutableString alloc] init];
	
//	int encoding = -1;		//NSShiftJISStringEncoding;
	int i;
	int ampersand = -1;
	int tag = -1;
	int terminate = head;
	
	for( i = head; i < tail; i++ ) {
		if( *( p + i ) == '<' ) {
			tag = i;
		}
		if( tail - i > 1 ) {
			if( *( p + i ) == '&' ) {
				ampersand = i;
			}
		}
		if( *( p + i ) == '>' && tag != -1) {
			NSString* a = [StringDecoder decodeBytesFrom:p + terminate length:tag - terminate];
			if( a != nil ) {
				[string appendString:a];
				[a release];
			}
			tag = -1;
			terminate = i+1;
		}
		if( *( p + i ) == ';' && ampersand != -1 ) {
			NSString *a = [StringDecoder decodeBytesFrom:p + terminate length:ampersand - terminate];
			if( a != nil ) {
				[string appendString:a];
				[a release];
			}
			int code = utf8codeOfHTMLSpecialCharacter( p + ampersand + 1, i - ampersand - 1 );
			NSString* special_char = [NSString stringWithFormat:@"%C", code];
			[string appendString:special_char];
			terminate = i + 1;
			ampersand = -1;
		}
		if( i - ampersand > 7 && ampersand != -1 ) {
			i = ampersand;
			ampersand = -1;
		}
	}
	NSString* a = [StringDecoder decodeBytesFrom:p + terminate length:tail-terminate];
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
/*
void layout(NSMutableArray* array ) {
	CGRect rect;
	float line = HeightThreadFont;
	for( ThreadResData* ro in array ) {
		float height = HeightThreadInfoFont * 2 + 4 + 5;
		for( ThreadLayoutComponent* sr in ro.body ) {
			if( sr.textInfo != kThreadLayoutNewLine ) {
				rect.origin.x = 5;
				rect.origin.y = height;
				rect.size.width = 300 - 15;
				rect.size = [sr.text sizeWithFont:threadFont constrainedToSize:CGSizeMake(rect.size.width, 1300) lineBreakMode:UILineBreakModeWordWrap];
				height += rect.size.height;
				sr.rect = rect;
			}
			else {
				height += line;
			}
		}
		ro.height = height;
	}
}
*/
void inputTextIntoDataArray( char* buff, int *buff_pointor, NSMutableArray *array ) {
	if( *buff_pointor == 1 && buff[0] == 0x20 ) {
	}
	else {
		ThreadLayoutComponent* p = [[ThreadLayoutComponent alloc] init];
		p.text = [StringDecoder decodeBytesFrom:buff length:*buff_pointor];
		p.textInfo = kThreadLayoutText;
		[array addObject:p];
		[p release];
		[p.text release];
	}
	
	*buff_pointor = 0;
}

float parseBody( char*p, int head, int tail, NSMutableArray* objs ) {
	int i;
	int terminate = head;
	int ampersand = -1;
	int searchMode = kSearching;
	
	const char* http_template = "http:/";
	const char* ttp_template = "ttp://";
	
	int href_anchor_pos = 0;
	int anchor_start_pos = 0;
	int buff_pointor = 0;
	int buff_size  = tail - head + 10;
	char* buff = (char*)pp;
	
	int http_start_pos =-1;
	int encoding = -1;		//NSShiftJISStringEncoding;
	for( i = head; i < tail; i++ ) {
		//		DNSLog( @"%d-%c (%d)", i, p[i], terminate );
		if( searchMode == kSearching ) {
			if( tail - i > 3 ) {
				if( !strncmp( p+i, "<br>", 4 ) || !strncmp( p+i, "<BR>", 4 ) ) {
					memcpy( buff + buff_pointor, p+terminate, i - terminate );
					buff_pointor += (i - terminate);
					memcpy( buff + buff_pointor, "\r", 1);
					buff_pointor += 1;
					i += 3;
					terminate = i+1;
				}
			}
			if( tail - i > 4 ) {
				if( !strncmp( p+i, " <br>", 5 ) || !strncmp( p+i, " <BR>", 5 ) ) {
					memcpy( buff + buff_pointor, p+terminate, i - terminate );
					buff_pointor += (i - terminate);
					memcpy( buff + buff_pointor, "\r", 1);
					buff_pointor += 1;
					i += 4;
					terminate = i+1;
				}
			}
			if( tail - i > 5 ) {
				if( !strncmp( p+i, " <br> ", 6 ) || !strncmp( p+i, " <BR> ", 6 ) ) {
					memcpy( buff + buff_pointor, p+terminate, i - terminate );
					buff_pointor += (i - terminate);
					memcpy( buff + buff_pointor, "\r", 1);
					buff_pointor += 1;
					i += 5;
					terminate = i+1;
				}
			}
			if( tail - i > 6 ) {
				if( !strncmp( p + i, http_template, 6 ) ) {
					http_start_pos = i;
					i += 6;
					searchMode = kFoundHTTP;
					
				}
				else if( !strncmp( p + i, ttp_template, 6 ) ) {
					http_start_pos = i;
					i += 6;
					searchMode = kFoundTTP;
				}
			}
			if( i < tail - 11 ) {
				if( !strncmp( p + i, "<a href=", 8 ) ) {
					searchMode = kFoundAnchorHref;
					href_anchor_pos = i;
					i+=12;
					continue;
				}
			}
			if( tail - i > 1 ) {
				if( *( p + i ) == '&' ) {
					ampersand = i;
					searchMode = kFoundAmpersand;
				}
			}
		}
		if( searchMode == kFoundAnchorHref ) {
			if( *(p+i) != '>' ) {
			}
			else {
				memcpy( buff + buff_pointor, p+terminate, href_anchor_pos - terminate  );
				buff_pointor += (href_anchor_pos - terminate );
				searchMode = kFoundAnchor;
				i++;
				i+=8;
				anchor_start_pos = i;
				terminate = i;
			}
		}
		else if( searchMode == kFoundAnchor ) {
			if( url_string[*(p+i)] > 2 && i > anchor_start_pos ) {
			}
			else if( url_string[*(p+i)] > 1 && i > anchor_start_pos ) {
			}
			else {
				inputTextIntoDataArray( buff, &buff_pointor, objs );
				
				NSString* num = [StringDecoder decodeBytesFrom:p + anchor_start_pos length:i - anchor_start_pos];
				ThreadLayoutComponent* p_anchor = [[ThreadLayoutComponent alloc] init];
				p_anchor.text = [NSString stringWithFormat:@">>%@", num];
				p_anchor.textInfo = kThreadLayoutAnchor;
				[objs addObject:p_anchor];
				[p_anchor release];
				
				[num release];
				terminate = i+4;
				i+=3;
				anchor_start_pos = 0;
				searchMode = kSearching;
				
				if( !strncmp( p+i+1, "  <br> ", 7 ) || !strncmp( p+i+1, "  <BR> ", 7 )  ) {
					i += 6;
					terminate = i+2;
				}
				else if( !strncmp( p+i+1, " <br> ", 6 ) || !strncmp( p+i+1, " <BR> ", 6 ) ) {
					i += 5;
					terminate = i+2;
				}
				else if( !strncmp( p+i+1, " <br>", 5 ) || !strncmp( p+i+1, " <BR>", 5 ) ) {
					i += 4;
					terminate = i+2;
				}
				else if( !strncmp( p+i+1, "<br>", 4 ) || !strncmp( p+i+1, "<BR>", 4 ) ) {
					i += 3;
					terminate = i+2;
				}
				else if( !strncmp( p+i, "<br>", 4 ) || !strncmp( p+i, "<BR>", 4 ) ) {
					i += 3;
					terminate = i+1;
				}
				else {
				}
			}
		}
		if( searchMode == kFoundAmpersand ) {
			if( *( p + i ) == ';' ) {
				int code = utf8codeOfHTMLSpecialCharacter( p + ampersand + 1, i - ampersand - 1 );
				
				if( code != 0 ) {
					memcpy( buff + buff_pointor, p+terminate, ampersand - terminate  );
					buff_pointor += (ampersand - terminate);
					
					if( encoding == -1 )
						encoding = [StringDecoder encodeingFromBytes:p length:buff_size];
					
					NSString* special_char = [NSString stringWithFormat:@"%C", code];
					NSData* special_char_byte = [special_char dataUsingEncoding:encoding];
					char* pp = (char*)[special_char_byte bytes];
					memcpy( buff + buff_pointor, pp, [special_char_byte length] );
					buff_pointor += [special_char_byte length];
					terminate = i + 1;
					searchMode = kSearching;
				}
				else {
					searchMode = kSearching;
				}
				/*	
				 memcpy( buff + buff_pointor, p+terminate, ampersand - terminate  );
				 buff_pointor += (ampersand - terminate);
				 
				 if( encoding == -1 )
				 encoding = [StringDecoder encodeingFromBytes:p length:buff_size];
				 
				 int code = utf8codeOfHTMLSpecialCharacter( p + ampersand + 1, i - ampersand - 1 );
				 NSString* special_char = [NSString stringWithFormat:@"%C", code];
				 NSData* special_char_byte = [special_char dataUsingEncoding:encoding];
				 char* pp = (char*)[special_char_byte bytes];
				 memcpy( buff + buff_pointor, pp, [special_char_byte length] );
				 buff_pointor += [special_char_byte length];
				 terminate = i + 1;
				 searchMode = kSearching;
				 */
			}
			if( i - ampersand > 7 ) {
				searchMode = kSearching;
				i = ampersand;
			}
		}
		else if( searchMode == kFoundTTP || searchMode == kFoundHTTP ) {
			if( *(p+i) != ' ' && *(p+i) != '<' ) {
			}
			//if( url_string[*(p+i)] > 0 ) {
			//}
			else {
				memcpy( buff + buff_pointor, p+terminate, http_start_pos - terminate );
				buff_pointor += (http_start_pos - terminate);
				if( buff_pointor >= 1 && !strncmp( buff + buff_pointor - 1, "\r", 1 ) ) {
					buff_pointor -= 1;
				}
				inputTextIntoDataArray( buff, &buff_pointor, objs );
				
				NSString* url = [StringDecoder decodeBytesFrom:p + http_start_pos length:i - http_start_pos];
				ThreadLayoutComponent* p2 = [[ThreadLayoutComponent alloc] init];
				p2.text = [url stringByReplacingOccurrencesOfString:@"‾" withString:@"~"];
				p2.textInfo = kThreadLayoutHTTPLink;
				[url release];
				[objs addObject:p2];
				[p2 release];
				
				terminate = i;
				searchMode = kSearching;
				
				if( !strncmp( p+i+1, "  <br> ", 7 ) || !strncmp( p+i+1, "  <BR> ", 7 )  ) {
					i += 6;
					terminate = i+2;
				}
				else if( !strncmp( p+i+1, " <br> ", 6 ) || !strncmp( p+i+1, " <BR> ", 6 ) ) {
					i += 5;
					terminate = i+2;
				}
				else if( !strncmp( p+i+1, " <br>", 5 ) || !strncmp( p+i+1, " <BR>", 5 ) ) {
					i += 4;
					terminate = i+2;
				}
				else if( !strncmp( p+i+1, "<br>", 4 ) || !strncmp( p+i+1, "<BR>", 4 ) ) {
					i += 3;
					terminate = i+2;
				}
				else if( !strncmp( p+i, "<br>", 4 ) || !strncmp( p+i, "<BR>", 4 ) ) {
					i += 3;
					terminate = i+1;
				}
				else {
				}
			}
		}
	}
	memcpy( buff + buff_pointor, p + terminate, i - terminate );
	buff_pointor += (i - terminate);
	inputTextIntoDataArray( buff, &buff_pointor, objs );
	
	return 0;
}

@implementation DatParser

+ (NSArray*)getNumbers:(NSString*)anchor_string {
	NSArray *ary = [anchor_string componentsSeparatedByString:@">>"];
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

+ (void) parse:(NSMutableData*)data appendTo:(Dat*)dat{
	DNSLogMethod
	int i,head = 0;
	char*p = (char*)[data bytes];
	int length = [data length];
/*	
	NSString* a = [StringDecoder decodeBytesFrom:[data bytes] length:[data length]];
	DNSLog( @"%@", a );
	[a release];
*/	
	if( pp == NULL )
		pp = (unsigned char*)malloc( sizeof( unsigned char)*length );
	
	for( i = 0; i < length; i++ ) {
		unsigned char c = *( p + i );
		if( c == 0x0A ) {
			int position[5];
			BOOL re = searchDatDivider( p, head, i, position );
			if( re ) {
				NSMutableArray *objs = [[NSMutableArray alloc] init];
				// NSString* name = elminateHTMLTag( p, head, position[0] );
				NSString* name = elminateHTMLTagAndSpecialChars( p, head, position[0] );
				NSString* date_id = elminateHTMLTag( p, + position[1] + 2, position[2] );
				NSString* email = [StringDecoder decodeBytesFrom:p + position[0] + 2 length:position[1] - position[0] - 2];
				float height = parseBody( p, position[2] + 2, position[3], objs );
				
				if( [dat.resList count] == 0 ) {
					NSString* thread_title = parseTitle( p,  position[3] + 2, position[3] + 2 + i - position[3]-1 );
					//NSString* thread_title = [StringDecoder decodeBytesFrom:p + position[3] + 2 length:i - position[3]-1];
					DNSLog( @"%@", thread_title );
					dat.title = thread_title;
					[thread_title release];
				}
				
				ThreadResData *p = [[ThreadResData alloc] init];
				p.name = name;
				p.date = date_id;
				p.email = email;
				p.body = objs;
				p.height = height;
				p.number = [dat.resList count]+1;
				p.numberString = [NSString stringWithFormat:@"%d", p.number];
				
				[name release];
				[email release];
				[date_id release];
				[objs release];
				[dat.resList addObject:p];
				[p release];
			}
			head = i + 1;
		}
	}
	layout( dat.resList, 300 );
	
	free( pp );
	pp = NULL;
}

@end

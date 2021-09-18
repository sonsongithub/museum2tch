//
//  DatParser.m
//  parser
//
//  Created by sonson on 08/12/11.
//  Copyright 2008 sonson. All rights reserved.
//

#import "SubjectParser.h"
#import "SubjectData.h"
#import "GTMNSString+HTML.h"
#import "NSString+AutoDecode.h"

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

@implementation SubjectParser

+ (void)parse:(NSData*)data appendTarget:(NSMutableArray*)array {
	DNSLogMethod
	int head = 0;
	int dat = 0;
	int res = 0;
	char traceBuff[SUBJECT_BUFFER_LENGTH];
	char *p = (char*)[data bytes];
	int length = [data length];
	for (int i = 0; i < length; i++) {
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
					NSString *title = [NSString stringFromBytes:p offset:tail_dat_number + 6 tail:tail_title];
					
					SubjectData* data = [[SubjectData alloc] init];
					data.title = [title gtm_stringByUnescapingFromHTML];
					data.dat = dat;
					data.res = res;
					data.number = [array count]+1;
					
					data.numberString = [NSString stringWithFormat:@"%03d", data.number];
					data.resString = [NSString stringWithFormat:@"%03d", res];
					
					[array addObject:data];
					[data release];
				}
			}
			head = i + 1;
		}
	}
}


@end

//
//  ThreadDataBase.m
//  2tch
//
//  Created by sonson on 08/07/19.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ThreadDataBase.h"
#import "global.h"

@implementation ThreadDataBase

@synthesize resList = resList_;

- (id) initWithBoardPath:(NSString*)boardPath dat:(NSString*)dat {
	boardPath_ = [[NSString stringWithString:boardPath] retain];
	dat_ = [[NSString stringWithString:dat] retain];
	
	// make cache directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:boardPath_];
	if( ![[NSFileManager defaultManager] fileExistsAtPath:path] ) {
		[[NSFileManager defaultManager] createDirectoryAtPath:path attributes:nil];
	}
	
	[self load];
	
	return self;
}

- (void) dealloc {
	[boardPath_ release];
	[dat_ release];
	[resList_ release];
	[super dealloc];
}

- (BOOL) load {
	// make cache directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path =[NSString stringWithFormat:@"%@/%@/%@.dat", documentsDirectory, boardPath_, dat_];
	
	if( ![[NSFileManager defaultManager] fileExistsAtPath:path] ) {
		DNSLog( @"does not exist cache file" );
		resList_ = [[NSMutableArray array] retain];
		return NO;
	}
	else {
		DNSLog( @"load cache file" );	
		// make dictionary data to write
		NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
		resList_ = [NSMutableArray arrayWithArray:[dict objectForKey:@"NSMutableArray"]];
		[resList_ retain];
		return YES;
	}
}

- (BOOL) write {
	// make cache directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path =[NSString stringWithFormat:@"%@/%@/%@.dat", documentsDirectory, boardPath_, dat_];
	
	// make dictionary data to write
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:resList_, @"NSMutableArray", nil];
	return [dict writeToFile:path atomically:NO];
}

- (NSString*) extractLink:(NSString*) input {
	if( [input length] < 5 )
		return input;
	int i,j;
#define _CHECK_SIZE 4
	unichar c[_CHECK_SIZE];
	long long http_hex = 0;
	long long ttp_hex = 0;
	
	NSMutableString* body = [NSMutableString stringWithString:input];
	NSString* httpPrefix = @"http";
	NSString* ttpPrefix = @"ttp:";
	
	for( j = 0; j < _CHECK_SIZE; j++ )
		c[j] = [httpPrefix characterAtIndex:j];
	memcpy( &http_hex, c, sizeof(unichar) * _CHECK_SIZE );
	
	for( j = 0; j < _CHECK_SIZE; j++ )
		c[j] = [ttpPrefix characterAtIndex:j];
	memcpy( &ttp_hex, c, sizeof(unichar) * _CHECK_SIZE );
	
	BOOL isLookingForPrefix = YES;
	BOOL isTTP = NO;
	int linkHead = 0;
	
	for( i = 0; i < [body length]; i++ ) {
		if( isLookingForPrefix ) {
			if( i == [body length] - 5 )
				break;
			long long check_hex = 0;
			for( j = 0; j < _CHECK_SIZE; j++ )
				c[j] = [body characterAtIndex:i+j];
			memcpy( &check_hex, c, sizeof(unichar) * _CHECK_SIZE );
			if( check_hex == http_hex ) {
				isLookingForPrefix = NO;
				isTTP = NO;
				linkHead = i;
			}
			else if( check_hex == ttp_hex ) {
				isLookingForPrefix = NO;
				isTTP = YES;
				linkHead = i;
			}
		}
		else {
			if( [body characterAtIndex:i] >> 8 || [body characterAtIndex:i] == ' ') {
				NSString *suffix = [NSString stringWithFormat:@"</a>"];
				[body insertString:suffix atIndex:i];
				NSString *prefix = nil;
				if( isTTP )
					prefix = [NSString stringWithFormat:@"<a href=\"h%@\">", [body substringWithRange:NSMakeRange(linkHead, i - linkHead)]];
				else
					prefix = [NSString stringWithFormat:@"<a href=\"%@\">", [body substringWithRange:NSMakeRange(linkHead, i - linkHead)]];
				[body insertString:prefix atIndex:linkHead];
				i += (i - linkHead);
				isLookingForPrefix = YES;
			}
		}
	}

#define _FOR_A_TAG_TARGET_ATTR_BUG
#ifdef _FOR_A_TAG_TARGET_ATTR_BUG
	while( 1 ) {
		NSRange target_attr = [body rangeOfString:@"target=\"_blank\""];
		if( target_attr.location != NSNotFound ) {
			[body deleteCharactersInRange:target_attr];
		}
		else
			break;
	}
#endif	
	return body;
}

- (BOOL) append:(NSData*) data {
	int i,head = 0;
	char*p = (char*)[data bytes];
	int length = [data length];	
	int	new_res = 0;
	
	for( i = 0; i < length; i++ ) {
		unsigned char c = *( p + i );
		if( c == 0x0A ) {
			NSData *sub = [data subdataWithRange:NSMakeRange( head, i-head )];
			NSString *decoded = decodeNSData( sub );
			NSArray*values = [decoded componentsSeparatedByString:@"<>"];
			// DNSLog( decoded );
			if( [values count] == 5 ) {
				NSString *name = [values objectAtIndex:0];
				NSString *email = [values objectAtIndex:1];
				NSString *date_id = [values objectAtIndex:2];
				NSString *body = [values objectAtIndex:3];
				
				NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
									eliminateHTMLTag(name),		@"name",
									email,						@"email",
									eliminateHTMLTag(date_id),	@"date_id",
									[self extractLink:body],	@"body",
									  nil];
				[resList_ addObject:dict];
				new_res++;
			}
			head = i + 1;
		}
	}
	[self write];

	if( new_res > 0 )
		return YES;
	else
		return NO;
}

@end

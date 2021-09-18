//
//  DatFile.m
//  2tch
//
//  Created by sonson on 08/02/11.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Downloader.h"
#import "DatFile.h"
#import "global.h"

@implementation DatFile

- (id) init {
	self = [super init];
	
	downloader_ = [[Downloader alloc] initWithDelegate:self];
	
	id center = [NSNotificationCenter defaultCenter];
	[center addObserver:self 
			selector:@selector(didSelectThread:)
			name:@"didSelectThread"
			object:nil];
	isGettingDiff_ = NO;
	
	resPerPage_ = _RES_PER_PAGE;
	
	return self;
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[downloader_ release];
	[datFilePath_ release];
	[super dealloc];
}

- (void) extractLines {
	// search endline
	NSData* data = [NSData dataWithContentsOfFile:datFilePath_];
	int hist[256];
	memset( hist, 0, sizeof( char)*256 );
	int length = [data length];
	char*p = (char*)[data bytes];
	int i;
	for( i = 0; i < length; i++ )
		hist[(int)*p++]++;
	
	resNum_ = hist[0x0A];
	nowTailRes_ = 0;
	resPerPage_ = _RES_PER_PAGE;
	page_ = 0;
}

- (NSString*) getForwardPage {
	page_++;
	if( page_ > resNum_ / resPerPage_ ) {
		page_ = resNum_ / resPerPage_;
		return nil;
	}
	return [self getCurrentPage];	
}

- (NSString*) getBackwardPage {
	page_--;
	if( page_ < 0 ) {
		page_ = 0;
		return nil;
	}
	return [self getCurrentPage];
}

- (NSMutableString*) extractLink:(NSString*) input {
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
	return body;
}

- (NSString*) getCurrentPage {
	int i, head = 0;
	NSData* data = [NSData dataWithContentsOfFile:datFilePath_];
	int length = [data length];
	
	[NSThread detachNewThreadSelector:(SEL)NSSelectorFromString(@"showProgressHUD") toTarget:UIApp withObject:nil];
	
	int headResNumber = page_ * resPerPage_;
	int tailResNumber = ( ( page_ + 1 ) * resPerPage_ > resNum_ ) ? resNum_ :  ( page_ + 1 ) * resPerPage_;
	int currentSearchRes = 0;
	char* p = (char*)[data bytes];
	
	NSMutableString *buff = [NSMutableString string];
	[buff appendString:@"<html><head><STYLE TYPE=\"text/css\"><!--div.entry{}div.info{float: left;width: 320px;background:#EFEFEF;padding-left:8px;border-top:solid 1px #000000;font-size: 80%;margin-left: -8px;margin-bottom:10px;margin-top:-9px;}div.body{float: left;width: 290px;margin-left: 10px;border-color:#EFEFEF;margin-bottom:30px;}--></STYLE></head><body>"];
	
	for( i = 0; i < length; i++ ) {
		id pool = [[NSAutoreleasePool alloc] init];
		char c = *( p + i );
		if( c == 10 /*0x0A*/ ) {
			if( currentSearchRes >= headResNumber ) {
				NSData *sub = [data subdataWithRange:NSMakeRange( head, i-head )];
				NSString *decoded = decodeNSData( sub );
				NSArray*elements = [decoded componentsSeparatedByString:@"<>"];
				if( [elements count] == 5 ) {
					NSString *res = [NSString stringWithFormat:@"%03d. ", currentSearchRes+1];
					[elements objectAtIndex:0];		// name
					[elements objectAtIndex:1];		// email
					[elements objectAtIndex:2];		// date&id
					[elements objectAtIndex:3];		// body
					
					NSMutableString *name = [NSMutableString stringWithString:[elements objectAtIndex:0]];
					eliminateHTMLTag( name );
					
					[buff appendString:@"<div class=\"info\">"];
					[buff appendString:res];
					[buff appendString:name];
					[buff appendString:@" "];
					[buff appendString:[elements objectAtIndex:2]];
					[buff appendString:@"</div><br><div class=\"body\">"];
					[buff appendString:[self extractLink:[elements objectAtIndex:3]]];
					[buff appendString:@"</div>"];		
					[buff appendString:@"<br>"];
					
					if( currentSearchRes == tailResNumber ) {
						[UIApp hideProgressHUD];
						[pool release];
						break;
					}
				}
			}
			currentSearchRes++;
			head = i + 1;
		}
		[pool release];
	}
	[buff appendString:@"</body></html>"];
	[UIApp hideProgressHUD];
	return buff;
}

- (void) didSelectThread:(NSNotification *)notification {
	[downloader_ cancel];
	
	[datInfo_ release];
	id dict = [notification object];
	datInfo_ = [[NSDictionary dictionaryWithDictionary:dict] retain];
	
	[[NSNotificationCenter defaultCenter] 
		postNotificationName:@"addHistory"
		object:dict];
	[self startDownload];
}

- (void) startDownload {
	id dict = datInfo_;
	// make cache directory
	NSString* cachePath = [NSString stringWithFormat:@"%@/%@/", [UIApp applicationDirectory], [dict objectForKey:@"boardID"]];
	if( ![[NSFileManager defaultManager] fileExistsAtPath:cachePath] ) {
		[[NSFileManager defaultManager] createDirectoryAtPath:cachePath attributes:nil];
	}
	[datInfoPath_ release];
	datInfoPath_ = [[NSString stringWithFormat:@"%@%@.info", cachePath, [dict objectForKey:@"datFile"]] retain];
	[datFilePath_ release];
	datFilePath_ = [[NSString stringWithFormat:@"%@%@", cachePath, [dict objectForKey:@"datFile"]] retain];

	NSString* url = [NSString stringWithFormat:@"http://%@/%@/dat/%@", [dict objectForKey:@"boardServer"], [dict objectForKey:@"boardID"], [dict objectForKey:@"datFile"]];

	if( ![[NSFileManager defaultManager] fileExistsAtPath:datInfoPath_] ) {
		isGettingDiff_ = NO;
		[downloader_ startWithURL:url];
	}
	else {
		NSDictionary *newThreadInfoDict = nil;
		NSData *data = [NSData dataWithContentsOfFile:datInfoPath_];
		NSString *dataStr = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
		if( [dataStr length] ) {
			isGettingDiff_ = YES;
			newThreadInfoDict = [dataStr propertyList];
			[downloader_ startWithURL:url andLastModifiedDataAndSize:newThreadInfoDict];
		}
		// maybe there is a trouble
		else {
			isGettingDiff_ = NO;
			[[NSFileManager defaultManager] removeFileAtPath:datInfoPath_ handler:nil];		// delete cache and info file
			[[NSFileManager defaultManager] removeFileAtPath:datFilePath_ handler:nil];
			[downloader_ startWithURL:url];
		}
	}
}

- (void) didFinishLoadging:(id)fp {
	id newData = nil;
	NSData *data = [fp data];
	NSURLResponse *response = [fp response];
	NSDictionary *requestDict = [(NSHTTPURLResponse *)response allHeaderFields];
	
	NSString* contentRange = [requestDict objectForKey:@"Content-Range"];
	NSString *Last_Modified = [requestDict objectForKey:@"Last-Modified"];
	NSString *size = nil;
	
	// when try to download diff of thread dat
	if( isGettingDiff_ ) {			
		if( contentRange ) {
			newData = [NSMutableData dataWithContentsOfFile:datFilePath_];
			size = [NSString stringWithFormat:@"%d", [data length] + [newData length]];
			[newData appendData:data];
		}
		else {
			[self extractLines];
			[[NSNotificationCenter defaultCenter] 
				postNotificationName:@"openThreadView"
				object:datFilePath_];
			return;
		}
	}
	else {
		newData = data;
		// write data file
		size = [NSString stringWithFormat:@"%d", [data length]];
	}
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
		Last_Modified,	@"Last-Modified",
		size,			@"size",
		nil];
	[[dict description] writeToFile:datInfoPath_ atomically:NO encoding:NSUTF8StringEncoding error:nil];
	[newData writeToFile:datFilePath_ atomically:NO];
	
	[self extractLines];
	
	[[NSNotificationCenter defaultCenter] 
		postNotificationName:@"openThreadView"
		object:datFilePath_];
}

- (id) datInfo {
	return datInfo_;
}

- (void) didFailLoadging:(NSString*)str {
	if( [[NSFileManager defaultManager] fileExistsAtPath:datFilePath_] ) {
		[self extractLines];
		[[NSNotificationCenter defaultCenter] 
			postNotificationName:@"openThreadView"
			object:datFilePath_];
	}
}

@end

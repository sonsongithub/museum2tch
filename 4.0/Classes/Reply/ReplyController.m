//
//  ReplyController.m
//  2tch
//
//  Created by sonson on 08/08/30.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ReplyController.h"
#import "ThreadViewController.h"
#import "ReplyViewController.h"
#import "MainNavigationController.h"

NSMutableString* eliminateHTMLTag(NSString* input) {
	int del = 0;
	int i = 0;
	
	NSMutableString* str = [NSMutableString stringWithString:input];
	
	for(i = 0; i< ([str length]); i++) {
		BOOL deleted = NO;
		if([str characterAtIndex: i] == '<')
			del ++;
		
		if(del > 0) {
			deleted = YES;
		}
		
		if([str characterAtIndex: i] == '>') {
			if(del > 0)
				del --;
		}
		
		if(deleted) {
			NSRange r = NSMakeRange(i, 1);
			[str deleteCharactersInRange: r];
			i--;
		}
	}
	return str;
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

@interface NSString (PercentEscape)
@end

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

@end

@implementation ReplyController

@synthesize server = server_;
@synthesize boardPath = boardPath_;
@synthesize dat = dat_;
@synthesize name = name_;
@synthesize email = email_;
@synthesize body = body_;
@synthesize delegate = delegate_;

#pragma mark Class method

+ (ReplyController*) defaultController {
	ReplyController* obj = [[ReplyController alloc] init];
	return obj;
}

#pragma mark Original method

- (void) send {
	Ch2ThreadPostResult result = [self postWithName:name_ mail:email_ body:body_];
	
	if ( result == Ch2ThreadPostCheckCookie ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalStr( @"ConfirmCookie" ) message:result_body_
													   delegate:self cancelButtonTitle:LocalStr( @"Cancel" ) otherButtonTitles:LocalStr( @"OK" ), nil];
		[alert show];
		[alert release];
		cookieConfirm_ = alert;
	}
	else if ( result == Ch2ThreadPostSuccess ){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalStr( @"CompletedWriting" ) message:result_body_
													   delegate:self cancelButtonTitle:nil otherButtonTitles:LocalStr( @"OK" ), nil];
		[alert show];
		[alert release];
		successConfirm_ = alert;
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalStr( @"FailedWriting" ) message:result_body_
													   delegate:self cancelButtonTitle:nil otherButtonTitles:LocalStr( @"OK" ), nil];
		[alert show];
		[alert release];
		failedConfirm_ = alert;
	}
	
}

- (id) URLOfBoard {
	NSString* str = [NSString stringWithFormat:@"http://%@/%@/", server_, boardPath_];
	return [NSURL URLWithString:str];
}

- (NSMutableString*) defaultCGIParameterStringWithName:(NSString*)name mail:(NSString*)mail body:(NSString*)body {
	NSMutableString* paramStr = [[NSMutableString alloc] init];
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	
	[dict setValue:boardPath_ forKey: @"bbs"];
	[dict setValue:dat_ forKey: @"key"];
	[dict setValue:[NSString stringWithFormat: @"%d", 1] forKey: @"time"];
	[dict setValue:@"%8F%91%82%AB%8D%9E%82%DE" forKey:@"submit"];				// 書き込む
	
	[dict setValue: [name URLencode] forKey: @"FROM"];
	[dict setValue: [mail URLencode] forKey: @"mail"];
	[dict setValue: [body URLencode] forKey: @"MESSAGE"];
	
	NSEnumerator* enumerator = [dict keyEnumerator];
	id key;
	while ((key = [enumerator nextObject])) {
		[paramStr appendString: key];
		[paramStr appendString: @"="];
		[paramStr appendString: [dict objectForKey: key]];
		[paramStr appendString: @"&"];
	}
	
	// delete, last '&'character
	[paramStr deleteCharactersInRange: NSMakeRange([paramStr length] - 1, 1)];
	
	[dict release];
	
	return paramStr;
}

- (NSMutableURLRequest*) defaultRequest {
	NSURL* url = [NSURL URLWithString: @"/test/bbs.cgi" relativeToURL: [self URLOfBoard]];
	NSMutableURLRequest* req = [[NSMutableURLRequest alloc] initWithURL:url];
	[req setHTTPShouldHandleCookies:YES];
	[req setHTTPMethod: @"POST"];
	[req setValue:LocalStr( @"User-Agent" ) forHTTPHeaderField: @"User-Agent"];
	[req setValue:[NSString stringWithFormat:@"http://%@/%@/index.html", server_, boardPath_] forHTTPHeaderField: @"Referer"];
	[req setValue:@"ja-jp" forHTTPHeaderField: @"Accept-Language"];
	[req setValue:@"shift_jis" forHTTPHeaderField: @"Accept-Charset"];
	[req setValue:@"text/html, text/plain, */*" forHTTPHeaderField: @"Accept"];
	return req;
}

- (NSMutableString*) cookieStringToSend {
	NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray * cookies = [storage cookies];
	NSMutableString *cookieString = [[NSMutableString alloc] init];
	for( id obj in cookies ) {
		NSHTTPCookie * cookie = (NSHTTPCookie*)obj;
		if( [[cookie domain] isEqualToString:server_] ) {
			NSLog( @"Name - %@ - %@", [cookie name], [cookie value] );
			[cookieString appendFormat:@"%@=%@;", [cookie name], [cookie value]];
		}
	}
	return cookieString;
}

- (int) postWithName:(NSString*)name mail:(NSString*)mail body:(NSString*)body {
	NSHTTPURLResponse* resp;
	NSError* error;
	NSMutableURLRequest* req = [self defaultRequest];
	NSMutableString* cgiStr = [self defaultCGIParameterStringWithName:name mail:mail body:body];
	NSMutableString* cookieStr = [self cookieStringToSend];
	
	if( [cookieStr length] == 0 )
		[cookieStr appendString:@"NAME=; Path=/"];
	else
		[cgiStr appendString:@"&suka=pontan"];
	
	NSData* dataToSend = [cgiStr dataUsingEncoding:NSASCIIStringEncoding];
	[req setValue:cookieStr forHTTPHeaderField:@"Cookie"];
	[req setValue:[NSString stringWithFormat:@"%d", [dataToSend length]] forHTTPHeaderField:@"Content-Length"];
	[req setHTTPBody:dataToSend];
	
	NSData *dataToReceived = [NSURLConnection sendSynchronousRequest:req returningResponse:&resp error:&error];
	if( error != nil ) {
		DNSLog( @"error - %@", [error localizedDescription] );
		return Ch2ThreadPostClientError;
	}
	
	NSString *responseString = [[NSString alloc] initWithData:dataToReceived encoding:NSShiftJISStringEncoding];
	Ch2ThreadPostResult resultCode = [self extractReply2ch_X_String:responseString];
	NSString *responseBody = [self extractReplyBodyString:responseString];
	
	if( responseBody != nil ) {
		[result_body_ release];
		result_body_ = eliminateHTMLTag( [NSString stringWithString:responseBody] );
		[result_body_ retain];
	}
	
	[responseString release];
	[cookieStr release];
	[cgiStr release];
	[req release];
	return resultCode;
}

- (Ch2ThreadPostResult) extractReply2ch_X_String:(NSString*) string {
	// find 2ch_X
	NSString* value_2ch_X = nil;
	NSRange range_2ch_X_start = [string rangeOfString:@"<!-- 2ch_X:"];
	NSRange range_2ch_X_end = [string rangeOfString:@" -->"];
	if( range_2ch_X_start.location != NSNotFound && range_2ch_X_end.location != NSNotFound ) { 
		value_2ch_X = [string substringWithRange:NSMakeRange(range_2ch_X_start.location+11,(range_2ch_X_end.location) - (range_2ch_X_start.location+11))];
	}
	DNSLog( @"value_2ch_X->%@", value_2ch_X );
	if ([value_2ch_X isEqualToString: @"true"]) {
		return Ch2ThreadPostSuccess;
	}
	else if (value_2ch_X == nil) {
		return Ch2ThreadPostSuccess;
	}
	else if ([value_2ch_X isEqualToString: @"false"]) {
		return Ch2ThreadPostWarning;
	}
	else if ([value_2ch_X isEqualToString: @"error"]) {
		return Ch2ThreadPostError;
	}
	else if ([value_2ch_X isEqualToString: @"check"]) {
		return Ch2ThreadPostCheck;
	}
	else if ([value_2ch_X isEqualToString: @"cookie"]) {
		return Ch2ThreadPostCheckCookie;
	}
	else {
		return Ch2ThreadPostClientError;
	}	
	return 0;
}

- (NSString*) extractReplyBodyString:(NSString*) string {
	// find body
	NSRange range_body_start = [string rangeOfString:@"<body"];
	NSRange range_body_end = [string rangeOfString:@"</body>"];
	if( range_body_start.location != NSNotFound && range_body_end.location != NSNotFound ) { 
		NSString* value_body = [string substringWithRange:NSMakeRange(range_body_start.location,range_body_end.location - range_body_start.location)];
		return value_body;
	}
	return nil;
}

- (void) afterCookieConfirmAlertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	DNSLog( @"[ReplyController] show alert view to confirm cookie use" );
	if( buttonIndex == 0 ) {
		// delete cookie because user rejected it.
		id storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
		id cookies = [storage cookies];
		int i;
		for( i = 0; i < [cookies count]; i++ ) {
			id cookie = [cookies objectAtIndex:i];
			if( [[cookie domain] isEqualToString:server_] ) {
				[storage deleteCookie:cookie];
			}
		}
	}
	else if( buttonIndex == 1 ) {
		Ch2ThreadPostResult result = [self postWithName:name_ mail:email_ body:body_];
		if( result == Ch2ThreadPostSuccess ) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalStr( @"CompletedWriting" ) message:result_body_
														   delegate:self cancelButtonTitle:nil otherButtonTitles:LocalStr( @"OK" ), nil];
			[alert show];
			[alert release];
			successConfirm_ = alert;
		}
		else {
			DNSLog( @"[ReplyController] Failed? - %d", result );
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalStr( @"FailedWriting" ) message:result_body_
														   delegate:self cancelButtonTitle:nil otherButtonTitles:LocalStr( @"OK" ), nil];
			[alert show];
			[alert release];
		}
	}
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if( alertView == cookieConfirm_ ) {
		[self afterCookieConfirmAlertView:alertView clickedButtonAtIndex:buttonIndex];
	}
	else if( alertView == failedConfirm_ ) {
	}	
	else if( alertView == successConfirm_ ) {
		// for reloading after finished writing successfully
		
		if( [UIAppDelegate.navigationController.topViewController isKindOfClass:[ThreadViewController class]] ) {
			ThreadViewController *con = (ThreadViewController*)UIAppDelegate.navigationController.topViewController;
			[con pushReloadButton:self];
		}
		[(ReplyViewController*)delegate_ dismiss:YES];
	}
}

#pragma mark Override

- (void) dealloc {
	DNSLog( @"[ReplyController] dealloc" );
	[result_body_ release];
	[server_ release];
	[boardPath_ release];
	[dat_ release];
	[name_ release];
	[email_ release];
	[body_ release];
	[super dealloc];
}


@end

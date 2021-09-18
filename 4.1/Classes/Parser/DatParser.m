//
//  DatParser.m
//  2tch
//
//  Created by sonson on 09/02/15.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DatParser.h"
#import "ThreadResData.h"
#import "Dat.h"
#import "NSString+AutoDecode.h"
#import "NSString+RemoveTag.h"
#import "GTMNSString+HTML.h"

NSCharacterSet* CharSetUsedAnchor = nil;

unichar br[] = { 'b', 'r' };
unichar BR[] = { 'B', 'R' };
unichar hr[] = { 'h', 'r' };
unichar HR[] = { 'H', 'R' };
unichar ttp[] = { 't', 't', 'p', ':' };
unichar http[] = { 'h', 't', 't', 'p' };
unichar anchorHead[] = { 'a', ' ', 'h', 'r', 'e', 'f', '=', '"', '.', '.', '/', 't', 'e', 's', 't', '/', 'r', 'e', 'a', 'd', '.', 'c', 'g', 'i' };

unichar anchorGtGt[] = { '&', 'g', 't', ';', '&', 'g', 't', ';' };
unichar anchorLinkClose[] = { '<', '/', 'a', '>' };

BOOL getRangeFromEntry( char* basePointer, int offset, int tail, NSRange *entryRanges ) {
	int i, counter = 0;
	int previous = offset;
	const char* dat_template = "<>";
	if (tail - offset < 2)
		return NO;
	for (i = offset; i < tail - 1; i++) {
		char *p = basePointer + i;
		if (!strncmp(p, dat_template, 2)) {
			*(entryRanges++) = NSMakeRange(previous, i - previous);
			previous = i + 2;
			counter++;
			if (counter == 4) {
				*(entryRanges++) = NSMakeRange(previous, tail - previous);
				return YES;
			}
		}
	}
	return NO;
}

@implementation DatParser

@synthesize dat = dat_;
@synthesize currentThreadRes = currentThreadRes_;
@synthesize container = container_;
@synthesize stringContainer = stringContainer_;

+ (void)initialize {
	if (CharSetUsedAnchor == nil) {
		CharSetUsedAnchor = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789,-"] retain];
	}
}

- (void)saveStringContainerType:(int)componentMode {
	if (stack_ > 0) {
	ThreadLayoutComponent* p_anchor = [[[ThreadLayoutComponent alloc] init] autorelease];
	unichar *p = stackData_;
	int length = stack_;
	if (stackData_[0] == '\r') {
		p++;
		length--;
	}

	p_anchor.text = [NSString stringWithCharacters:p length:length];
	if( componentMode == kThreadLayoutText )
		p_anchor.text = [p_anchor.text gtm_stringByUnescapingFromHTML];
	stack_ = 0;
	p_anchor.textInfo = componentMode;
	[self.stringContainer addObject:p_anchor];
	}
//	self.container = [NSMutableString string];
}

- (int)parseAnchor:(unichar*)basePointer tail:(int)tail pointer:(int*)pointer {
	while (*pointer < tail) {
		if (!memcmp(basePointer+*pointer, anchorGtGt, sizeof(anchorGtGt))) {
			// skip ">>" of anchor
			//[self.container appendString:@">>"];
			stackData_[stack_++] = '>';
			stackData_[stack_++] = '>';
			(*pointer) += 8;
		}
		else if (!memcmp(basePointer+*pointer, anchorLinkClose, sizeof(anchorLinkClose))) {
			// skip "</a>" of anchor
			(*pointer) += 4;
		}
		else if (![CharSetUsedAnchor characterIsMember:basePointer[*pointer]]) {
			[self saveStringContainerType:kThreadLayoutAnchor];
			/*
			ThreadLayoutComponent* p_anchor = [[[ThreadLayoutComponent alloc] init] autorelease];
			p_anchor.text = self.container;
			p_anchor.textInfo = kThreadLayoutAnchor;
			[self.stringContainer addObject:p_anchor];
			self.container = [NSMutableString string];
			*/
			return 0;
		}
		else {
			//[self.container appendFormat:@"%C", basePointer[*pointer]];
			stackData_[stack_++] = basePointer[*pointer];
			(*pointer)++;
		}	
	}
	return 0;
}

- (int)parseTag:(unichar*)basePointer tail:(int)tail pointer:(int*)pointer {
	int tagStart = *pointer+1;		// skip 1 byte of "<", delimiter
	while (*pointer < tail) {
		if (basePointer[*pointer] == '>') {
			if (*pointer - tagStart == 2) {
				if (!memcmp(basePointer+tagStart, br, sizeof(br))||!memcmp(basePointer+tagStart, BR, sizeof(BR))) {
					//[self.container appendString:@"\r"];
					stackData_[stack_++] = '\r';
				}
				else if (!memcmp(basePointer+tagStart, hr, sizeof(hr))||!memcmp(basePointer+tagStart, HR, sizeof(HR))) {
					//[self.container appendString:@"\r--\r"];
					stackData_[stack_++] = '\r';
					stackData_[stack_++] = '-';
					stackData_[stack_++] = '-';
					stackData_[stack_++] = '\r';
				}
				(*pointer)+=2;			// skip 1 byte of ">", delimiter
				return 0;
			}
			else if( *pointer - tagStart > 24 ) {
				if (!memcmp(basePointer+tagStart, anchorHead, sizeof(anchorHead))) {
					(*pointer)++;
					[self saveStringContainerType:kThreadLayoutText];
					[self parseAnchor:basePointer tail:tail pointer:pointer];
					return 0;
				}
			}
			else {
				// DNSLog( @"Not implemented tag" );
				(*pointer)+=2;			// skip 1 byte of ">", delimiter
				return 0;
			}
		}
		else {
			(*pointer)++;
		}
	}
	return 0;
}

- (int)parseHTTP:(unichar*)basePointer tail:(int)tail pointer:(int*)pointer {
	int urlStart = *pointer;
	*pointer += 4;					// skip 4 byte of "http" or "ttp:"
	while (*pointer < tail) {
		if (basePointer[*pointer] == ' ' || basePointer[*pointer] == '<') {
			ThreadLayoutComponent* p_anchor = [[[ThreadLayoutComponent alloc] init] autorelease];
			p_anchor.textInfo = kThreadLayoutHTTPLink;
			[self.stringContainer addObject:p_anchor];
			p_anchor.text = [NSString stringWithCharacters:basePointer+urlStart length:*pointer-urlStart];
			//self.container = [NSMutableString string];
			stack_ = 0;
			return 0;
		}
		else {
			(*pointer)++;
		}
	}
	return 0;
}

- (void)bodyParse:(unichar*)basePointer length:(int)length {
	int i = 0;
	while (i < length) {
		if (basePointer[i] == '<') {
			[self parseTag:basePointer tail:length pointer:&i];
		}
		else if (!memcmp(basePointer+i, ttp, sizeof(ttp))||!memcmp(basePointer+i, http, sizeof(http))) {
			[self saveStringContainerType:kThreadLayoutText];
			[self parseHTTP:basePointer tail:length pointer:&i];
		}
		else {
			/*
			if ([self.container length] != 0 || basePointer[i] != ' ') {
				[self.container appendFormat:@"%C", basePointer[i]];
			}
			*/
			if ( !(stack_ == 0 && (basePointer[i] == ' '))) {
				stackData_[stack_++] = basePointer[i];
			}
			i++;
		}
	}
	[self saveStringContainerType:kThreadLayoutText];
}

- (void)parseAnEntryFromBytes:(char*)p offset:(int)offset tail:(int)tail {
	NSRange entryRanges[5];
	if (getRangeFromEntry(p, offset, tail, entryRanges)) {
		NSString* name = [NSString stringFromBytes:p range:entryRanges[0]];
		NSString* mail = [NSString stringFromBytes:p range:entryRanges[1]];
		NSString* date = [NSString stringFromBytes:p range:entryRanges[2]];
		NSString* body = [NSString stringFromBytesNoCopy:p range:entryRanges[3]];
		
		if (entryRanges[4].length > 0) {
			dat_.title = [NSString stringFromBytes:p range:entryRanges[4]];
		}
			
		
		// get unichar buffer pointor
		int length = [body length];
		self.container = [NSMutableString string];
		self.stringContainer = [NSMutableArray array];
		const unichar *buffer = CFStringGetCharactersPtr((CFStringRef)body);
		if (!buffer) {
			NSMutableData *data = [NSMutableData dataWithLength:length * sizeof(UniChar)];
			if (!data) {
				// NSLog(@"couldn't alloc buffer");
				return;
			}
			[body getCharacters:[data mutableBytes]];
			buffer = [data bytes];
		}
		[self bodyParse:buffer length:length];
	/*	
		for( ThreadLayoutComponent *component in self.stringContainer ) {
			DNSLog( @"%@", component );
		}
	*/	
		ThreadResData *threadResData = [[[ThreadResData alloc] init] autorelease];
		[self.dat.resList addObject:threadResData];
		threadResData.body = self.stringContainer;
		threadResData.date = date;
		threadResData.email = mail;
		threadResData.name = name;
		threadResData.number = [self.dat.resList count];
		threadResData.numberString = [NSString stringWithFormat:@"%d", threadResData.number];
		
		self.stringContainer = nil;
		self.container = nil;
	}
}

#pragma mark -
#pragma mark Parse Start

- (void)parse:(NSMutableData*)data appendToDat:(Dat*)dat {
	DNSLogMethod
	self.dat = dat;
	int i = 0, currentHead = 0;
	char*p = (char*)[data bytes];
	int length = [data length];
	
	stack_ = 0;
	stackData_ = (unichar*)malloc(sizeof(unichar) * length/2);
	
	while (i < length) {
		if (*(p + i) == 0x0A) {
			[self parseAnEntryFromBytes:p offset:currentHead tail:i];
			currentHead = i + 1;
			i++;
		}
		else {
			i++;
		}
	}
	layout( self.dat.resList, 300 );
	free(stackData_);
}

- (id)init {
	self = [super init];
	return self;
}

#pragma mark -
#pragma mark Dealloc

- (void) dealloc {
	DNSLogMethod
	[container_ release];
	[dat_ release];
	[currentThreadRes_ release];
	[super dealloc];
}

@end

//
//  NSString+RemoveTag.m
//  testHTML
//
//  Created by sonson on 09/02/15.
//  Copyright 2009 sonson. All rights reserved.
//

#import "NSString+RemoveTag.h"

@implementation NSString(RemoveTag)

- (NSString*)removeTag {
	// check sting length
	NSUInteger length = [self length];
	if (!length) {
		return self;
	}
	// get unichar buffer pointor
	NSMutableString *finalString = [NSMutableString string];
	const unichar *buffer = CFStringGetCharactersPtr((CFStringRef)self);
	if (!buffer) {
		NSMutableData *data = [NSMutableData dataWithLength:length * sizeof(UniChar)];
		if (!data) {
			NSLog(@"couldn't alloc buffer");
			return nil;
		}
		[self getCharacters:[data mutableBytes]];
		buffer = [data bytes];
	}
	// remove tag
	for (NSUInteger i = 0; i < length; ++i) {
		if( buffer[i] == 0x3C ) {
			// '<' => 0x3C
			for (;i < length; i++ ) {
				// '>' => 0x3E
				if( buffer[i] == 0x3E ) {
					break;
				}
			}	
		}
		else {
			[finalString appendFormat:@"%C", buffer[i]];
		}
	}
	return finalString;
}

@end

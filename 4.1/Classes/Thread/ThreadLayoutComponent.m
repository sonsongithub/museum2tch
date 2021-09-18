//
//  StringRect.m
//  scroller
//
//  Created by sonson on 08/12/19.
//  Copyright 2008 sonson. All rights reserved.
//

#import "ThreadLayoutComponent.h"

@implementation ThreadLayoutComponent

@synthesize text = text_;
@synthesize rect = rect_;
@synthesize textInfo = textInfo_;

- (id)copyWithZone:(NSZone*)zone {
	ThreadLayoutComponent * copiedObject = nil;
	copiedObject = [[[self class] allocWithZone:zone] init];
	copiedObject.text = [NSString stringWithString:text_];
	copiedObject.rect = rect_;
	copiedObject.textInfo = textInfo_;
    return copiedObject;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	self.text = [coder decodeObjectForKey:@"text"];
	self.textInfo = [coder decodeIntForKey:@"textInfo"];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.text forKey:@"text"];
	[encoder encodeInt:self.textInfo forKey:@"textInfo"];
//	[encoder encodeCGRect:self.rect forKey:@"rect"];
}

- (NSString*)description {
	NSMutableString *output = [NSMutableString string];
	[output appendFormat:@"Text - %@\r", self.text];
	[output appendFormat:@"Rect - %f,%f,%f,%f\r", self.rect.origin.x, self.rect.origin.y, self.rect.size.width, self.rect.size.height];
	switch (self.textInfo) {
		case kThreadLayoutText:
			[output appendString:@"Info - kThreadLayoutText\r"]; 
			break;
		case kThreadLayoutHTTPLink:
			[output appendString:@"Info - kThreadLayoutHTTPLink\r"]; 
			break;
		case kThreadLayoutAnchor:
			[output appendString:@"Info - kThreadLayoutAnchor\r"]; 
			break;
		default:
			break;
	}
	return output;
}

- (void)dealloc {
	[text_ release];
	[super dealloc];
}

@end
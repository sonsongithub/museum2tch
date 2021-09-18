//
//  ResObject.m
//  scroller
//
//  Created by sonson on 08/12/19.
//  Copyright 2008 sonson. All rights reserved.
//

#import "ThreadResData.h"
#import "ThreadLayoutComponent.h"

@implementation ThreadResData
@synthesize number = number_;
@synthesize numberString = numberString_;
@synthesize name = name_;
@synthesize email = email_;
@synthesize date = date_;
@synthesize body = body_;
@synthesize height = height_;
@synthesize isSelected = isSelected_;
@synthesize isPopup = isPopup_;

- (id)copyWithZone:(NSZone*)zone {
	ThreadResData * copiedObject = nil;
	copiedObject = [[[self class] allocWithZone:zone] init];
	copiedObject.name = [NSString stringWithString:name_];
	copiedObject.numberString = [NSString stringWithString:numberString_];
	copiedObject.email = [NSString stringWithString:email_];
	copiedObject.date = [NSString stringWithString:date_];
	copiedObject.body = [NSMutableArray array];//:body_];
	
	for( ThreadLayoutComponent* component in body_ ) {
		ThreadLayoutComponent*p = [component copy];
		[copiedObject.body addObject:p];
		[p release];
	}
	copiedObject.number = number_;
    return copiedObject;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	//	self.number = [coder decodeIntForKey:@"number"];
	self.name = [coder decodeObjectForKey:@"name"];
	self.numberString = [coder decodeObjectForKey:@"numberString"];
	self.email = [coder decodeObjectForKey:@"email"];
	self.date = [coder decodeObjectForKey:@"date"];
	self.body = [coder decodeObjectForKey:@"body"];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	//	[encoder encodeInt:self.number forKey:@"number"];
	[encoder encodeObject:self.name forKey:@"name"];
	[encoder encodeObject:self.numberString forKey:@"numberString"];
	[encoder encodeObject:self.email forKey:@"email"];
	[encoder encodeObject:self.date forKey:@"date"];
	[encoder encodeObject:self.body forKey:@"body"];
}

- (void)dealloc {
	[name_ release];
	[numberString_ release];
	[email_ release];
	[date_ release];
	[body_ release];
	[super dealloc];
}

@end

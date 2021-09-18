//
//  SubjectData.m
//  2tch
//
//  Created by sonson on 08/12/20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SubjectData.h"


@implementation SubjectData

@synthesize title = title_;
@synthesize path = path_;
@synthesize resString = resString_;
@synthesize readString = readString_;
@synthesize numberString = numberString_;
@synthesize dat = dat_;
@synthesize res = res_;
@synthesize number = number_;
@synthesize number = number_;
@synthesize read = read_;

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	self.title = [coder decodeObjectForKey:@"title"];
	self.path = [coder decodeObjectForKey:@"path"];
	self.resString = [coder decodeObjectForKey:@"resString"];
	self.numberString = [coder decodeObjectForKey:@"numberString"];
	self.dat = [coder decodeIntForKey:@"dat"];
	self.res = [coder decodeIntForKey:@"res"];
	self.number = [coder decodeIntForKey:@"number"];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.title forKey:@"title"];
	[encoder encodeObject:self.path forKey:@"path"];
	[encoder encodeObject:self.resString forKey:@"resString"];
	[encoder encodeObject:self.numberString forKey:@"numberString"];
	[encoder encodeInt:self.dat forKey:@"dat"];
	[encoder encodeInt:self.res forKey:@"res"];
	[encoder encodeInt:self.number forKey:@"number"];
}

- (void)dealloc {
	[title_ release];
	[path_ release];
	[resString_ release];
	[readString_ release];
	[numberString_ release];
	[super dealloc];
}

@end
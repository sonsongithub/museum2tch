//
//  BookmarkCellInfo.m
//  2tch
//
//  Created by sonson on 08/12/27.
//  Copyright 2008 sonson. All rights reserved.
//

#import "BookmarkCellInfo.h"

@implementation BookmarkCellInfo

@synthesize number = number_;
@synthesize dat = dat_;
@synthesize title = title_;
@synthesize path = path_;
@synthesize boardTitle = boardTitle_;
@synthesize resString = resString_;
@synthesize numberString = numberString_;
@synthesize readString = readString_;
@synthesize isUnread = isUnread_;

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	self.title = [coder decodeObjectForKey:@"title"];
	self.boardTitle = [coder decodeObjectForKey:@"boardTitle"];
	self.path = [coder decodeObjectForKey:@"path"];
	self.dat = [coder decodeIntForKey:@"dat"];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.title forKey:@"title"];
	[encoder encodeObject:self.boardTitle forKey:@"boardTitle"];
	[encoder encodeObject:self.path forKey:@"path"];
	[encoder encodeInt:self.dat forKey:@"dat"];
}

- (void)dealloc {
	[title_ release];
	[path_ release];
	[boardTitle_ release];
	[resString_ release];
	[numberString_ release];
	[readString_ release];
	[super dealloc];
}

@end
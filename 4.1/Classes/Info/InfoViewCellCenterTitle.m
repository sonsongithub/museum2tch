//
//  InfoViewCellCenterTitle.m
//  2tch
//
//  Created by sonson on 09/02/14.
//  Copyright 2009 sonson. All rights reserved.
//

#import "InfoViewCellCenterTitle.h"

@implementation InfoViewCellCenterTitle

@synthesize titleLabel = titleLabel_;

#pragma mark Override

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		self.titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake( 8, 7, 173, 30)] autorelease];
		self.titleLabel.backgroundColor = [UIColor clearColor];
		
		UIFont *fontBold = [UIFont boldSystemFontOfSize:17.0f];
		self.titleLabel.font = fontBold;
		
		[self.contentView addSubview:self.titleLabel];
	}
    return self;
}

- (void) layoutSubviews {
	[super layoutSubviews];
	CGRect parentRect = self.contentView.frame;
	CGRect titleRect = [titleLabel_ textRectForBounds:CGRectMake( 0, 0, 200, 30) limitedToNumberOfLines:1];
	titleRect.origin.x = ( parentRect.size.width - titleRect.size.width ) / 2.0f;
	titleRect.origin.y = ( parentRect.size.height - titleRect.size.height ) / 2.0f;
	titleLabel_.frame = titleRect;
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	DNSLogMethod
	[titleLabel_ release];
    [super dealloc];
}

@end
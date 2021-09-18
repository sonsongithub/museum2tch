//
//  MiniBadgeView.m
//  2tch
//
//  Created by sonson on 08/12/28.
//  Copyright 2008 sonson. All rights reserved.
//

#import "SNMiniBadgeView.h"

UIImage* badgeImage = nil;

@implementation SNMiniBadgeView

@synthesize rightTop = rightTop_;

#pragma mark Class Method

+ (void)initialize {
	if( badgeImage == nil ) {
		UIImage *original = [UIImage imageNamed:@"miniBadge.png"];
		badgeImage = [[original stretchableImageWithLeftCapWidth:15 topCapHeight:0] retain];
	}
}

#pragma mark Original Method

- (void)set:(int)remained {
	DNSLogMethod
	if( remained == 0 ) {
		self.hidden = YES;
	}
	else {
		label_.text = [NSString stringWithFormat:@"%d", remained];
		CGRect rect = [label_ textRectForBounds:CGRectMake( 0, 0, 300, 300) limitedToNumberOfLines:1];
		DNSLog( @"%f,%f", rect.size.width, rect.size.height );
		
		CGRect newRect = self.frame;
		newRect.size.width = rect.size.width + 24;
		self.frame = newRect;
		label_.frame = rect;
		label_.center = CGPointMake( self.frame.size.width / 2.0, self.frame.size.height / 2.0 - 3.25 );
		CGRect newSelfViewFrame = self.frame;
		newSelfViewFrame.origin.x = rightTop_.x - newSelfViewFrame.size.width;
		newSelfViewFrame.origin.y = rightTop_.y;
		self.frame = newSelfViewFrame;
		self.hidden = NO;
	}
}

#pragma mark Override

- (id)init {
    if (self = [super initWithImage:badgeImage]) {
        // Initialization code
		CGRect frame2;
		
		// 29, 30
		frame2.size = badgeImage.size;
		self.frame = frame2;
		label_ = [[UILabel alloc] initWithFrame:CGRectZero];
		label_.font = [UIFont boldSystemFontOfSize:14];
		label_.textColor = [UIColor whiteColor];
		label_.backgroundColor = [UIColor clearColor];
		[self addSubview:label_];
		self.hidden = YES;
    }
    return self;
}

#pragma mark dealloc

- (void)dealloc {
	[label_ release];
    [super dealloc];
}


@end

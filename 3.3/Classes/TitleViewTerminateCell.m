//
//  TitleViewTerminateCell.m
//  2tch
//
//  Created by sonson on 08/11/29.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TitleViewTerminateCell.h"

@implementation TitleViewTerminateCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		firstLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
		secondLabel_ = [[UILabel alloc] initWithFrame:CGRectZero];
		activity_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[self.contentView addSubview:firstLabel_];
		[self.contentView addSubview:secondLabel_];
		[self.contentView addSubview:activity_];
		
		firstLabel_.textColor = [UIColor colorWithRed:24.0f/255.0f green:83.0f/255.0f blue:135.0f/255.0f alpha:1.0f];
		
		//
		CGRect parentRect = self.contentView.frame;
		CGRect activityRect = activity_.frame;
		activityRect.origin.x = 10;
		activityRect.origin.y = ( parentRect.size.height - activityRect.size.height ) / 2.0;
		activity_.frame = activityRect;
		activity_.hidden = YES;
    }
    return self;
}

- (void)setLoading {
	activity_.hidden = NO;
	[activity_ startAnimating];
	CGRect parentRect = self.contentView.frame;
	
	firstLabel_.text = NSLocalizedString( @"loading", nil );
	CGRect firstLabelRect = [firstLabel_ textRectForBounds:CGRectMake(0,0,100,30) limitedToNumberOfLines:1];
	firstLabelRect.origin.x = ( parentRect.size.width - firstLabelRect.size.width ) / 2.0;
	firstLabelRect.origin.y = ( parentRect.size.height - firstLabelRect.size.height ) / 2.0;
	firstLabel_.frame = firstLabelRect;
}

- (void)setFinished {
	activity_.hidden = YES;
	[activity_ stopAnimating];
	CGRect parentRect = self.contentView.frame;
	
	firstLabel_.text = NSLocalizedString( @"finished", nil );
	CGRect firstLabelRect = [firstLabel_ textRectForBounds:CGRectMake(0,0,100,30) limitedToNumberOfLines:1];
	firstLabelRect.origin.x = ( parentRect.size.width - firstLabelRect.size.width ) / 2.0;
	firstLabelRect.origin.y = ( parentRect.size.height - firstLabelRect.size.height ) / 2.0;
	firstLabel_.frame = firstLabelRect;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:animated];
}

- (void)dealloc {
	[firstLabel_ release];
	[secondLabel_ release];
	[activity_ release];
    [super dealloc];
}


@end

//
//  InfoViewCell.m
//  2tch
//
//  Created by sonson on 08/08/29.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "InfoViewCell.h"

@implementation CenterTitleViewCell

@synthesize titleLabel = titleLabel_;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		titleLabel_ = [[UILabel alloc] initWithFrame:CGRectMake( 8, 7, 173, 30)];
		titleLabel_.backgroundColor = [UIColor clearColor];
		
		UIFont *fontBold = [UIFont boldSystemFontOfSize:17.0f];
		titleLabel_.font = fontBold;
		
		[self.contentView addSubview:titleLabel_];
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}

- (void)dealloc {
	[titleLabel_ release];
    [super dealloc];
}
@end

@implementation InfoViewCell

@synthesize titleLabel = titleLabel_;
@synthesize attributeLabel = attributeLabel_;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		titleLabel_ = [[UILabel alloc] initWithFrame:CGRectMake( 8, 7, 173, 30)];
		titleLabel_.backgroundColor = [UIColor clearColor];
		attributeLabel_ = [[UILabel alloc] initWithFrame:CGRectMake( 92, 7, 199, 30)];
		attributeLabel_.backgroundColor = [UIColor clearColor];
		
		UIFont *font = [UIFont systemFontOfSize:17.0f];
		UIFont *fontBold = [UIFont boldSystemFontOfSize:17.0f];
		attributeLabel_.font = font;
		titleLabel_.font = fontBold;
		
		attributeLabel_.textAlignment = UITextAlignmentRight;
		attributeLabel_.textColor = [UIColor colorWithRed:50.0f/255.0f green:79.0f/255.0f blue:133.0f/255.0f alpha:1.0f];
		
		[self.contentView addSubview:titleLabel_];
		[self.contentView addSubview:attributeLabel_];
    }
    return self;
}

- (void) layoutSubviews {
	[super layoutSubviews];
	CGRect parentRect = self.contentView.frame;
	
	CGRect titleRect = [titleLabel_ textRectForBounds:CGRectMake( 0, 0, 200, 30) limitedToNumberOfLines:1];
	CGRect attriRect = [attributeLabel_ textRectForBounds:CGRectMake( 0, 0, 200, 30) limitedToNumberOfLines:1];

	float hori_margin = 8;
	
	titleRect.origin.x = hori_margin;
	titleRect.origin.y = ( parentRect.size.height - titleRect.size.height ) / 2.0f;
	
	attriRect.origin.x = parentRect.size.width - attriRect.size.width - hori_margin;
	attriRect.origin.y = ( parentRect.size.height - attriRect.size.height ) / 2.0f;
	
	titleLabel_.frame = titleRect;
	attributeLabel_.frame = attriRect;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	//[super setSelected:selected animated:NO];
    // Configure the view for the selected state
}

- (void)dealloc {
	[titleLabel_ release];
	[attributeLabel_ release];
    [super dealloc];
}


@end

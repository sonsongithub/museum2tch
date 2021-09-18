//
//  ReplyViewCellName.m
//  2tch
//
//  Created by sonson on 08/07/19.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ReplyViewCellName.h"


@implementation ReplyViewCellName

@synthesize name = nameField_;
@synthesize prompt = prompt_;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		// Initialization code
	}
	return self;
}

- (void) setupFont {
	UIFont *font = [UIFont boldSystemFontOfSize:11.0f];
	prompt_.font = font;
	
	CGRect rect = prompt_.frame;
	CGRect new_rect = [prompt_ textRectForBounds:CGRectMake(0,0,200,200) limitedToNumberOfLines:1];
	
	CGRect cell_rect = self.contentView.frame;
	
	rect.size = new_rect.size;
	rect.size.height = 40.0f;
	rect.origin.y = ( cell_rect.size.height - rect.size.height ) / 2.0;
	prompt_.frame = rect;
	CGRect new_field_rect = nameField_.frame;
	new_field_rect.origin.x = prompt_.frame.origin.x + prompt_.frame.size.width + 5.0f;
	new_field_rect.size.width = 310 - new_field_rect.origin.x;
	nameField_.frame = new_field_rect;
}

- (void)prepareForReuse {
	[super prepareForReuse];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

	//[super setSelected:selected animated:animated];

	// Configure the view for the selected state
}


- (void)dealloc {
	[super dealloc];
}


@end

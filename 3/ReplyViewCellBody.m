//
//  ReplyViewCellBody.m
//  2tch
//
//  Created by sonson on 08/07/19.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ReplyViewCellBody.h"


@implementation ReplyViewCellBody

@synthesize body = bodyView_;
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

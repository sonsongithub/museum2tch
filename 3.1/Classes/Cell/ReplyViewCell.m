//
//  ReplyViewCell.m
//  2tch
//
//  Created by sonson on 08/08/30.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ReplyViewCell.h"

@implementation BodyCell

@synthesize textView = textView_;

#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
	if( [textView.text length] > 0 )
		placeholder_.hidden = YES;
	else
		placeholder_.hidden = NO;
}

#pragma mark Override

- (void) layoutSubviews {
	[super layoutSubviews];
	
	CGRect parent_rect = self.contentView.frame;
	CGRect new_field_rect = textView_.frame;
	
	new_field_rect.size = CGSizeMake( parent_rect.size.width*0.95, parent_rect.size.height*0.90 );
	
	new_field_rect.origin.x = ( parent_rect.size.width - new_field_rect.size.width ) / 2.0f;
	new_field_rect.origin.y = ( parent_rect.size.height - new_field_rect.size.height ) / 2.0f;
	new_field_rect.size.width = parent_rect.size.width * 0.88;
	
	textView_.frame = new_field_rect;
	textView_.delegate = self;
	textView_.font = [UIFont systemFontOfSize:17.0f];
	
	CGRect placeholderRect = [placeholder_ textRectForBounds:CGRectMake(0,0,300,30) limitedToNumberOfLines:1];
	placeholder_.backgroundColor = [UIColor clearColor];
	placeholderRect.origin = new_field_rect.origin;
	placeholderRect.origin.x = placeholderRect.origin.x + 8;
	placeholderRect.origin.y = placeholderRect.origin.y + 8;
	
	placeholder_.frame = placeholderRect;
	
	if( [textView_.text length] > 0 ) {
		placeholder_.hidden = YES;
		textView_.selectedRange = NSMakeRange([textView_.text length], 0);
	}
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		textView_ = [[UITextView alloc] initWithFrame:CGRectZero];
		[self.contentView addSubview:textView_];
		
		placeholder_ = [[UILabel alloc] initWithFrame:CGRectZero];
		placeholder_.font = [UIFont systemFontOfSize:17.0f];
		placeholder_.textColor = [UIColor colorWithRed:79.0f/255.0f green:79.0f/255.0f blue:79/255.0f alpha:0.25f];
		placeholder_.text = NSLocalizedString( @"Body", nil );
		[self.contentView addSubview:placeholder_];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}

- (void)dealloc {
	[textView_ release];
    [super dealloc];
}

@end

@implementation ReplyViewCell

@synthesize field = field_;

#pragma mark Original

#pragma mark Override

- (void) layoutSubviews {
	[super layoutSubviews];

	CGRect parent_rect = self.contentView.frame;
	CGRect new_field_rect = field_.frame;
	
	new_field_rect.size = CGSizeMake( parent_rect.size.width*0.90, parent_rect.size.height*0.8 );
	
	new_field_rect.origin.x = ( parent_rect.size.width - new_field_rect.size.width ) / 2.0f;
	new_field_rect.origin.y = ( parent_rect.size.height - new_field_rect.size.height ) / 2.0f;
	field_.frame = new_field_rect;
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		field_ = [[UITextField alloc] initWithFrame:CGRectZero];
		field_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		[self.contentView addSubview:field_];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	// [super setSelected:selected animated:animated];
	// Configure the view for the selected state
}

- (void)dealloc {
	[field_ release];
    [super dealloc];
}


@end

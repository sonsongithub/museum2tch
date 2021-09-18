#import "InfoViewCell.h"

@implementation InfoViewCell

@synthesize title = titleLabel_;
@synthesize attr = attrLabel_;

- (void)setFont {
	UIFont *font = [UIFont systemFontOfSize:17.0f];
	UIFont *fontBold = [UIFont boldSystemFontOfSize:17.0f];
	attrLabel_.font = font;
	titleLabel_.font = fontBold;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	//[super setSelected:selected animated:animated];
	// Configure the view for the selected state
}

@end

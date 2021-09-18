#import "ThreadTitleViewCell.h"
#import "global.h"

@implementation ThreadTitleViewCell

#pragma mark Accessor

@dynamic threadTitle;
@dynamic res;
@dynamic number;
@dynamic hiddenCacheImage;

- (BOOL) hiddenCacheImage {
	return cacheImg_.hidden;
}

- (void) setHiddenCacheImage:(BOOL)newValue {
	cacheImg_.hidden = newValue;
}

- (NSString*) threadTitle {
	return labelTitle_.text;
}

- (void) setThreadTitle:(NSString*)newValue {
	labelTitle_.text = newValue;
	UIFont *font = [UIFont boldSystemFontOfSize:15.0f];	
	labelTitle_.font = font;
	
	labelTitle_.numberOfLines = 3;
	CGRect textRect = [labelTitle_ textRectForBounds:labelTitle_.bounds limitedToNumberOfLines:3];
	
	DNSLog( @"%f,%f,%f,%f", textRect.origin.x, textRect.origin.y, textRect.size.width, textRect.size.height );
	
	CGRect frame = labelTitle_.frame;
	frame.origin.y = self.frame.size.height - frame.size.height - 5;
	labelTitle_.frame = frame;
	
	cacheImg_.hidden = YES;
	
	DNSLog( @"label's height - %f", frame.size.height );
	
	float font_size = frame.size.height / (labelTitle_.numberOfLines+1) - 2.0f;
}

- (NSString*) res {
	return labelResNumber_.text;
}

- (void) setRes:(NSString*)newValue {
	labelResNumber_.text = newValue;
}


- (NSString*) number {
	return labelNumber_.text;
}

- (void) setNumber:(NSString*)newValue {
	labelNumber_.text = newValue;
}

#pragma mark Override

- (void) dealloc {
	DNSLog( @"[ThreadTitleViewCell] dealloc" );
	[super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	if( selected ) {
		labelTitle_.textColor = [UIColor whiteColor];
		labelResNumber_.textColor = [UIColor whiteColor];
		labelNumber_.textColor = [UIColor whiteColor];
	}
	else {
		labelTitle_.textColor = [UIColor blackColor];
		labelResNumber_.textColor = [UIColor colorWithRed:37.0/255.0 green:113.0/255.0 blue:216.0/255.0 alpha:1.0];
		labelNumber_.textColor = [UIColor colorWithRed:37.0/255.0 green:113.0/255.0 blue:216.0/255.0 alpha:1.0];
	}
	[super setSelected:selected animated:animated];
}

#pragma mark Original method

- (void) setResNumberFontSize {
	UIFont *font = [UIFont boldSystemFontOfSize:12.0f];
	labelResNumber_.font = font;
	labelNumber_.font = font;
}

@end

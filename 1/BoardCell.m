
#import "BoardCell.h"

@implementation BoardCell

- (float) height {
	return height_;
}

- (NSString*)title {
	return [title_label_ text];
}

- (void) setTitle:(NSString*)title withURL:(NSString*)url {

	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	float transparentomponents[4] = {1, 1, 1, 0};
	
	// make title label
	title_label_ = [[[UITextLabel alloc] initWithFrame:CGRectMake( 23, 11, 310, 13)] autorelease];
	
	GSFontRef infoFont = [UIImageAndTextTableCell defaultTitleFont];
	[title_label_ setFont:infoFont];
	[title_label_ setWrapsText:YES];
	[title_label_ setText:title];
	[title_label_ sizeToFit];
	[title_label_ setBackgroundColor: CGColorCreate( colorSpace, transparentomponents)];
	[self addSubview:title_label_];

	NSString *cacheDirectoryPath = [UIApp makeCacheDirectroy:url];
	NSString *cachePath = [NSString stringWithFormat:@"%@subject.txt", cacheDirectoryPath];
	if( [[NSFileManager defaultManager] fileExistsAtPath:cachePath] ) {
		UIImage *icon = [UIApp cacheIconUIImage];
		UIImageView *imgView = [[[UIImageView alloc] initWithFrame:CGRectMake( 6.0, 13.0, 12.0, 16.0)] autorelease];
		[imgView setImage:icon];
		[imgView setBackgroundColor: CGColorCreate( colorSpace, transparentomponents)];
		[self addSubview:imgView];
	}

	[self addSubview:title_label_];

	[self setDisclosureStyle:2];
	[self setShowDisclosure:YES];
	
	height_ = 0;
}

@end

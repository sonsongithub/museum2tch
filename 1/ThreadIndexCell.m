
#import "ThreadIndexCell.h"
//#import "HTMLEliminator.h"

@implementation ThreadIndexCell

// overide

- (void) dealloc {
	[escaped_title_ release];
	[super dealloc];
}

- (float) height {
	return height_;
}

- (NSString*) title {
	return escaped_title_;
}

- (void) setDataWithDictionary:(NSDictionary*)dict {
	float top_margin = 3.0f;
	float bottom_margin = 9.0f;
	float left_margin = 23.0f;
	float space_margin = 3.0f;

	id info_label = [self setupInfo:dict];
	id body_label = [self setupBody:dict];
	
	CGRect rect_info = [info_label bounds];	
	CGRect rect_body = [body_label bounds];	
	
	rect_info.origin.x = left_margin;
	rect_info.origin.y = top_margin;
	rect_body.origin.x = left_margin;
	rect_body.origin.y = rect_info.origin.y + rect_info.size.height + space_margin;
	
	[info_label setFrame:rect_info];
	[body_label setFrame:rect_body];
	height_ = rect_info.size.height + rect_body.size.height + bottom_margin;

	[self setHaveReadIcon:dict];
}

- (id) setupBody:(NSDictionary*)dict {
	float body_size = [UIApp threadIndexSize];
	
	// make body label
	UITextLabel*body_label = [[[UITextLabel alloc] initWithFrame:CGRectMake( 5, 27, 310, 60)] autorelease];
	GSFontRef bodyFont = GSFontCreateWithName( FIXEDPITCH_FONT_NAME, kGSFontTraitBold, body_size );
	[body_label setFont:bodyFont];
	[body_label setWrapsText:YES];
	CFRelease(bodyFont);
	
	float transparentomponents[4] = {1, 1, 1, 0};
	[body_label setBackgroundColor: CGColorCreate( CGColorSpaceCreateDeviceRGB(), transparentomponents)];
	
	// save thread title into cell
	id titleStr = [dict valueForKey:@"title"];
	escaped_title_ = [[NSString stringWithString:[dict valueForKey:@"rawTitle"]] retain];
	[body_label setText:divideStringWithWidthAndFontSize( titleStr, 260, [UIApp threadIndexSize])];
	[body_label sizeToFit];
	[self addSubview:body_label];
	
	return body_label;
}

- (id) setupInfo:(NSDictionary*)dict {
	float info_size = [UIApp threadIndexSize] - 2.0f; 
	// make information label
	UITextLabel* info_label = [[[UITextLabel alloc] initWithFrame:CGRectMake( 5, 5, 310, 13)] autorelease];
	GSFontRef infoFont = GSFontCreateWithName( FIXEDPITCH_FONT_NAME, kGSFontTraitBold, info_size );
	[info_label setFont:infoFont];
	[info_label setWrapsText:YES];
	CFRelease(infoFont);
	
	float transparentomponents[4] = {1, 1, 1, 0};
	float gray[4] = {0.6, 0.6, 0.6, 1};
	[info_label setBackgroundColor: CGColorCreate( CGColorSpaceCreateDeviceRGB(), transparentomponents)];
	[info_label setColor:CGColorCreate( CGColorSpaceCreateDeviceRGB(), gray)];
	
	id resnumStr = [dict valueForKey:@"resnum"];
	id numberStr = [dict valueForKey:@"number"];
	id resMessage = NSLocalizedString( @"resMessagePrefix", nil );
	NSString *info_string = [NSString stringWithFormat:@"%@ - %@%@", numberStr, resMessage, resnumStr];
	[info_label setText:info_string];
	[info_label sizeToFit];
	[self addSubview:info_label];
	return info_label;
}

- (void) setHaveReadIcon:(NSDictionary*)dict {
	float transparentomponents[4] = {1, 1, 1, 0};
	NSString *path = [UIApp makeCacheDataPath:[dict valueForKey:@"url"]];
	if( [[NSFileManager defaultManager] fileExistsAtPath:path] ) {
		UIImage *icon = [UIApp cacheIconUIImage];
		UIImageView *imgView = [[[UIImageView alloc] initWithFrame:CGRectMake( 6.0, (int)(height_-16.0)/2, 12.0, 16.0)] autorelease];
		[imgView setImage:icon];
		[imgView setBackgroundColor: CGColorCreate( CGColorSpaceCreateDeviceRGB(), transparentomponents)];
		[self addSubview:imgView];
	}
}

@end

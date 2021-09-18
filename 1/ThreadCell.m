
#import "ThreadCell.h"

@implementation ThreadCell

- (float) height {
	return height_;
}

- (void) setDataWithDictionary:(NSDictionary*)dict {
	float body_height = [self setupBody:dict];
	float info_height = [self setupInfo:dict];
	[self setShowDisclosure:NO];
	height_ = body_height + info_height + 30;
}

- (float) setupBody:(NSDictionary*)dict {
	float body_size = [UIApp threadSize];
	// make body label
	UITextLabel* body_label = [[[UITextLabel alloc] initWithFrame:CGRectMake( 5, 40, 310, 60)] autorelease];;
	[body_label setWrapsText:YES];
	
	GSFontRef bodyFont = GSFontCreateWithName( FIXEDPITCH_FONT_NAME, kGSFontTraitNormal, body_size );
	[body_label setFont:bodyFont];
	CFRelease(bodyFont);
	
	[body_label setText:divideStringWithWidthAndFontSize( [dict valueForKey:@"body"], 290, [UIApp threadSize])];
	[body_label sizeToFit];
	
	[self addSubview:body_label];
	CGRect rect_body = [body_label bounds];
	return rect_body.size.height;
}

- (float) setupInfo:(NSDictionary*)dict {
	float info_size = [UIApp threadSize] - 2.0f;	
	// make information label
	UITextLabel* info_label = [[[UITextLabel alloc] initWithFrame:CGRectMake( 5, 5, 310, 13)] autorelease];
	[info_label setWrapsText:YES];
	
	GSFontRef infoFont = GSFontCreateWithName( FIXEDPITCH_FONT_NAME, kGSFontTraitBold, info_size );
	[info_label setFont:infoFont];
	CFRelease(infoFont);
	
	// set string
	id numberStr = [dict valueForKey:@"number"];
	id nameStr = [dict valueForKey:@"name"];
	id date_idStr = [dict valueForKey:@"date_id"];
	id mailStr = [dict valueForKey:@"mail"];
	NSString *info_string = [NSString stringWithFormat:@"%@:%@ %@\n  %@", numberStr, nameStr, mailStr, date_idStr];
	[info_label setText:info_string];
	[info_label sizeToFit];
	
	[self addSubview:info_label];
	CGRect rect_info = [info_label bounds];
	return rect_info.size.height;
}

@end

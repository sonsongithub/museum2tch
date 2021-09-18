//
//  ThreadIndexCell.m
//  2tch
//
//  Created by sonson on 08/03/10.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ThreadIndexCell.h"
#import "global.h"

@implementation ThreadIndexCell

#define	NUMBER_OF_LINES_TITLE 2

+ (float) defaultHeight {
	return 80.0f;
}

- (id) initWithDelegate:(id)delegate {
	self = [super init];
	delegate_ = delegate;
	return self;
}

- (float) height {
	return height_;
}

- (void) setDataWithDictionary:(NSDictionary*)dict {
	float top_margin = 5.0f;
	float bottom_margin = 5.0f;
	float left_margin = 10.0f;
	float space_margin = 0.0f;

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
	
	[info_label setWrapsText:YES];
	[body_label setWrapsText:YES];
	
	height_ = 0;//rect_info.size.height + rect_body.size.height + bottom_margin;
}

- (id) setupBody:(NSDictionary*)dict {
	float body_size = DEFALUT_FONT_SIZE;
	
	// make body label
	UITextLabel*body_label = [[[UITextLabel alloc] initWithFrame:CGRectMake( 0, 0, 295, 60)] autorelease];
	GSFontRef bodyFont = GSFontCreateWithName( "arial",2, body_size );
	[body_label setFont:bodyFont];
	CFRelease(bodyFont);
	
	float transparentomponents[4] = {1, 1, 1, 0};
	[body_label setBackgroundColor: CGColorCreate( CGColorSpaceCreateDeviceRGB(), transparentomponents)];
	
	// save thread title into cell
	id titleStr = [dict objectForKey:@"threadTitle"];
	[body_label setText:titleStr];
//	[body_label sizeToFit];
	[self addSubview:body_label];
	
	return body_label;
}

- (id) setupInfo:(NSDictionary*)dict {
	float info_size = DEFALUT_FONT_SIZE - 4.0f; 
	// make information label
	UITextLabel* info_label = [[[UITextLabel alloc] initWithFrame:CGRectMake( 5, 5, 310, info_size)] autorelease];
	//GSFontRef infoFont = GSFontCreateWithName( FIXEDPITCH_FONT_NAME, kGSFontTraitBold, info_size );
	GSFontRef infoFont = GSFontCreateWithName( "arial",2, info_size );
	[info_label setFont:infoFont];
	CFRelease(infoFont);
	
	float transparentomponents[4] = {1, 1, 1, 0};
	float gray[4] = {0.6, 0.6, 0.6, 1};
	[info_label setBackgroundColor: CGColorCreate( CGColorSpaceCreateDeviceRGB(), transparentomponents)];
	[info_label setColor:CGColorCreate( CGColorSpaceCreateDeviceRGB(), gray)];
		
	id lengthStr = [dict objectForKey:@"threadLength"];
	id boardTitleStr = [dict objectForKey:@"boardTitle"];
	NSString *info_string = [NSString stringWithFormat:@"%@ - %@", lengthStr, boardTitleStr ];
	[info_label setText:info_string];
//	[info_label sizeToFit];
	[self addSubview:info_label];
	return info_label;
}

- (void) removeControlWillHideRemoveConfirmation:(id)fp8 {
	[ self _showDeleteOrInsertion:NO
		  withDisclosure:NO
		  animated:YES
		  isDelete:YES
		  andRemoveConfirmation:YES
	];
}

- (void) _willBeDeleted {
	[delegate_ delete:self];
}

@end

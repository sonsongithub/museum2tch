//
//  PopupLabel.m
//  2tch
//
//  Created by sonson on 08/12/30.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PopupLabel.h"

NSString* kPopupLabelPopup = @"kPopupLabelPopup";
NSString* kPopupLabelPopout = @"kPopupLabelPopout";

@implementation PopupLabel

#pragma mark Original

- (void)show:(BOOL)animated {
	DNSLogMethod
	if( animated ){
		[UIView beginAnimations:kPopupLabelPopup context:nil];
		[UIView setAnimationDuration:0.25];
	}
	
	popupTitle_.alpha = 1.0;
	
	if( animated )
		[UIView commitAnimations];
}

- (void)hide:(BOOL)animated {
	DNSLogMethod
	if( animated ) {
		[UIView beginAnimations:kPopupLabelPopout context:nil];
		[UIView setAnimationDuration:1.5];
	}
	popupTitle_.alpha = 0.0;
	
	if( animated )
		[UIView commitAnimations];
}

#pragma mark Override

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	popupTitle_ = [[PopupTitleView alloc] init];
	[UIAppDelegate.window addSubview:popupTitle_];
	popupTitle_.alpha = 0;
	return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	DNSLogMethod
    [super touchesBegan:touches withEvent:event];
	[popupTitle_ setText:self.text];
	[self show:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
	[self hide:YES];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
	[self hide:YES];
}

#pragma mark dealloc

- (void)dealloc {
	[popupTitle_ release];
	[super dealloc];
}

@end

@implementation PopupTitleView

UIImage* popupBackImage = nil;

#pragma mark Class Method

+ (void)initialize {
	DNSLogMethod
	if( popupBackImage == nil ) {
		UIImage *original = [UIImage imageNamed:@"titlePopupBack.png"];
		popupBackImage = [[original stretchableImageWithLeftCapWidth:7 topCapHeight:13] retain];
	}
}

#pragma mark Original

- (void)setText:(NSString*)text {
	label_.text = text;
	
	CGRect rect = [label_ textRectForBounds:CGRectMake( 0, 0, 280, 200) limitedToNumberOfLines:10];
	CGRect newRect = self.frame;
	newRect.size.width = rect.size.width + 20;
	newRect.size.height = rect.size.height + 20;
	self.frame = newRect;
	self.center = CGPointMake( 160, 480 * 0.75 );
	label_.frame = rect;
	label_.center = CGPointMake( self.frame.size.width/2, self.frame.size.height/2 );
}

#pragma mark Override

- (id)init {
	DNSLogMethod
    if (self = [super initWithImage:popupBackImage]) {
        // Initialization code
		label_ = [[UILabel alloc] initWithFrame:CGRectZero];
		label_.font = [UIFont boldSystemFontOfSize:16];
		label_.textColor = [UIColor whiteColor];
		label_.backgroundColor = [UIColor clearColor];
		label_.numberOfLines = 10;
		[self addSubview:label_];
    }
    return self;
}

#pragma mark dealloc

- (void)dealloc {
	DNSLogMethod
	[label_ release];
    [super dealloc];
}

@end
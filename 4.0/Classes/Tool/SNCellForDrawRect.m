//
//  SNTableViewCellDrawRect.m
//  2tch
//
//  Created by sonson on 08/10/24.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SNCellForDrawRect.h"

CGGradientRef gradient = NULL;

@implementation SNCellBackgroundForDrawRect

- (id)initWithDelegate:(NSObject<SNCellBackgroundForDrawRectDelegate>*)delegate {
	if( self = [super init] ) {
		delegate_ = delegate;
		[delegate_ retain];
	}
	return self;
}

- (void) dealloc {
	[delegate_ release];
	[super dealloc];
}

- (void)drawRect:(CGRect)rect {
	[delegate_ drawBackgroundRect:rect];
}

@end

@implementation SNCellForDrawRect

+ (void)initialize {
	DNSLogMethod
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	CGFloat colors[] = {
		70.0f / 255.0, 146.0f / 255.0, 240.0f / 255.0, 1.00,
		23.0f / 255.0, 84.0f / 255.0, 205.0f / 255.0, 1.00
		//		43.0f / 255.0, 104.0f / 255.0, 225.0f / 255.0, 1.00
	};
	gradient = CGGradientCreateWithColorComponents( rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4) );
	CGColorSpaceRelease(rgb);
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		SNCellBackgroundForDrawRect* view = [[SNCellBackgroundForDrawRect alloc] initWithDelegate:self];
		self.selectedBackgroundView = view;
		[view release];
	}
    return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetRGBStrokeColor( context, 204.0f/255.0f, 204.0f/255.0f, 204.0f/255.0f, 1.0);
	CGContextSetLineWidth( context, 1.0 );
	CGContextMoveToPoint( context, 0, rect.size.height );
	CGContextAddLineToPoint( context, rect.size.width, rect.size.height );
	CGContextStrokePath( context );
}

- (void)drawBackgroundRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetRGBStrokeColor( context, 204.0f/255.0f, 204.0f/255.0f, 204.0f/255.0f, 1.0);
	CGContextSetLineWidth( context, 1.0 );
	CGContextMoveToPoint( context, 0, rect.size.height );
	CGContextAddLineToPoint( context, rect.size.width, rect.size.height );
	CGContextStrokePath( context );
	
	CGContextSaveGState(context);
	CGContextClipToRect(context, rect);
	CGPoint start = CGPointMake( 0, 0 );
	CGPoint end = CGPointMake( 0, rect.size.height );
	CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	CGContextRestoreGState(context);
}


- (void) layoutSubviews {
	[super layoutSubviews];
	[self setNeedsDisplay];
}

- (void)dealloc {
    [super dealloc];
}

@end

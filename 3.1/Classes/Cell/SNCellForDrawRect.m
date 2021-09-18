//
//  SNTableViewCellDrawRect.m
//  2tch
//
//  Created by sonson on 08/10/24.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SNCellForDrawRect.h"


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

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		SNCellBackgroundForDrawRect* view = [[SNCellBackgroundForDrawRect alloc] initWithDelegate:self];
		//[self.contentView addSubview:view];
		// view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
		self.selectedBackgroundView = view;
		[view release];
	}
    return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetRGBFillColor(context, 224.0f/255.0f, 224.0f/255.0f, 224.0f/255.0f, 1.f);
	CGContextFillRect(context,CGRectMake(0, 0, rect.size.width,0.5));
	CGContextSetRGBFillColor(context, 224.0f/255.0f, 224.0f/255.0f, 224.0f/255.0f, 1.f);
	CGContextFillRect(context,CGRectMake(0, rect.size.height-0.5, rect.size.width,0.5));
}

- (void)drawBackgroundRect:(CGRect)rect {
	DNSLog( @"drawBackgroundRect:" );
	
	
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	CGFloat colors[] = {
		70.0f / 255.0, 146.0f / 255.0, 240.0f / 255.0, 1.00,
		23.0f / 255.0, 84.0f / 255.0, 205.0f / 255.0, 1.00
//		43.0f / 255.0, 104.0f / 255.0, 225.0f / 255.0, 1.00
	};
	CGGradientRef gradient = CGGradientCreateWithColorComponents( rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4) );
	CGColorSpaceRelease(rgb);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(context);
	CGContextClipToRect(context, rect);
	CGPoint start = CGPointMake( 0, 0 );
	CGPoint end = CGPointMake( 0, rect.size.height );
	CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	CGContextRestoreGState(context);
	
	CGContextSetRGBFillColor(context, 224.0f/255.0f, 224.0f/255.0f, 224.0f/255.0f, 1.f);
	CGContextFillRect(context,CGRectMake(0, 0, rect.size.width,0.5));
	CGContextSetRGBFillColor(context, 224.0f/255.0f, 224.0f/255.0f, 224.0f/255.0f, 1.f);
	CGContextFillRect(context,CGRectMake(0, rect.size.height-0.5, rect.size.width,0.5));
}


- (void) layoutSubviews {
	[super layoutSubviews];
	[self setNeedsDisplay];
}

- (void)dealloc {
    [super dealloc];
}

@end

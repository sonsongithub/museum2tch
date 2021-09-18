//
//  VarticalBarIndexView.m
//  2tch
//
//  Created by sonson on 08/08/04.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "VerticalBarIndexView.h"
#import "global.h"

#define INDEX_FONT_SIZE 11.0f

@implementation IndexElementLabel

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	DNSLog( @"touchBegan" );
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
   DNSLog( @"aa" );
}

@end

@implementation VerticalBarIndexView

- (id)initWithFrame:(CGRect)frame delegate:(id)delegate{
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		UIImage *img =  [UIImage imageNamed:@"vertical_bar.png"];
		UIImage *newImg = [img stretchableImageWithLeftCapWidth:18 topCapHeight:18];
		background_ = [[UIImageView alloc] initWithImage:newImg];
		CGRect backgroundRect = background_.frame;
		backgroundRect.size = frame.size;
		background_.frame = backgroundRect;
		background_.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		background_.hidden = YES;
		[self addSubview:background_];
		elements_ = [[NSMutableArray array] retain];
		self.userInteractionEnabled = YES;
		current_index_ = -1;
		delegate_ = delegate;
    }
    return self;
}

- (void)prepareForReuse:(int)elements_num {
	
	DNSLog( @"[VerticalBarIndexView] prepareForReuse:" );
	
	for( id obj in elements_ ) {
		[(IndexElementLabel*)obj removeFromSuperview];
	}
	
	[elements_ removeAllObjects];
	int i;
	UIFont *font = [UIFont boldSystemFontOfSize:INDEX_FONT_SIZE];
	
	float offset_y = 12;
	float an_interval = 320.0f / (elements_num - 1);
	
	for( i = 0; i < elements_num; i++ ) {
		IndexElementLabel* p = [[IndexElementLabel alloc] initWithFrame:CGRectZero];
		if( i%2 == 0 )
			p.text = [NSString stringWithFormat:@"%d", i * 50 + 1];
		else
			p.text = @"●";
		p.textAlignment = UITextAlignmentCenter;
		p.userInteractionEnabled = YES;
		p.font = font;
		p.textColor = [UIColor colorWithRed:106.0f/255.0f green:115.0f/255.0f blue:125.0f/255.0f alpha:1.0f];
		p.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
		[elements_ addObject:p];
		DNSLog( p.text );
		//CGRect rect = [p textrect
		CGRect rect = [p textRectForBounds:CGRectMake(0,0,self.frame.size.width,100) limitedToNumberOfLines:1];
		rect.origin.y = 12 + an_interval * i;
		p.frame = rect;
		[self addSubview:p];
		[p release];
	}
}

- (void)evaluateTouch:(CGPoint)p {
	
	float an_interval = 320.0f / ([elements_ count] - 1);
	int i;
	for( i = 0; i < [elements_ count]; i++ ) {
		float target = 12 + an_interval * i;
		if( p.y > target && p.y < target + INDEX_FONT_SIZE ) {
			IndexElementLabel*p = [elements_ objectAtIndex:i];
			if( current_index_ != i ) {
				DNSLog( @"clicked - %@", p.text );
				current_index_ = i;
				[delegate_ setIndex:current_index_];
			}
			break;
		}
	}
	
//	float height = ( p.y - 12.0.f ) / [elements_ count];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	background_.hidden = NO;
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
	[self evaluateTouch:touchPoint];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // We only support single touches, so anyObject retrieves just that touch from touches
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
	[self evaluateTouch:touchPoint];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	background_.hidden = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	background_.hidden = YES;
}

- (void)dealloc {
    [super dealloc];
}


@end

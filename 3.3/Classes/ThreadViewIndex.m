//
//  ThreadViewIndex.m
//  2tchfree
//
//  Created by sonson on 08/08/24.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ThreadViewIndex.h"
#import "ThreadViewController.h"

#define	INDEX_FONT_SIZE 11.0f
#define	INDEX_STEP		50

@implementation ThreadViewIndex

- (id)initWithDelegate:(id)delegate {
	CGRect frame = CGRectMake( 280, 6, 37, 356);
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
		
		labels_ = [[NSMutableArray array] retain];
		indices_ = [[NSMutableArray array] retain];
		clickViews_ = [[NSMutableArray array] retain];
		
		current_index_ = -1;
		delegate_ = delegate;
    }
    return self;
}

- (void)prepareForReuseFrom:(int)from to:(int)to {
	DNSLogMethod
	
	[indices_ removeAllObjects];
	for( id obj in labels_ ) {
		[(UILabel*)obj removeFromSuperview];
	}
	[labels_ removeAllObjects];
	for( id obj in clickViews_ ) {
		[(UILabel*)obj removeFromSuperview];
	}
	[clickViews_ removeAllObjects];
	
	int i;
	UIFont *font = [UIFont boldSystemFontOfSize:INDEX_FONT_SIZE];
	
	int counter = 0;
	int numberOfLabels = (to+INDEX_STEP - from ) /INDEX_STEP;
	
	int surplus = (to+INDEX_STEP - from ) % INDEX_STEP;
	DNSLog( @"surplus - %d", surplus );
	
	if( surplus > 0 )
		numberOfLabels++;

	float an_interval = 320.0f / ( numberOfLabels - 1 );
	
	for( i = from; i < to+INDEX_STEP; i+=INDEX_STEP ) {
		DNSLog( @"%d %d/%d", i, (counter)+1, numberOfLabels );
		
		UILabel* p = [[UILabel alloc] initWithFrame:CGRectZero];
		if( counter%2 == 0 ) {
			if( counter != numberOfLabels-1 )
				p.text = [NSString stringWithFormat:@"%d", i];
			else
				p.text = [NSString stringWithFormat:@"%d", to];
		}
		else {
			p.text = @"●";			
		}
		
		p.textAlignment = UITextAlignmentCenter;
		p.userInteractionEnabled = YES;
		p.font = font;
		p.textColor = [UIColor colorWithRed:106.0f/255.0f green:115.0f/255.0f blue:125.0f/255.0f alpha:1.0f];
		p.backgroundColor = [UIColor clearColor];
		
		CGRect rect = [p textRectForBounds:CGRectMake(0,0,self.frame.size.width,100) limitedToNumberOfLines:1];
		rect.origin.y = 12 + an_interval * counter;
		p.frame = rect;
		[labels_ addObject:p];
		[self addSubview:p];
		
		[indices_ addObject:[NSNumber numberWithInt:i]];
		
		rect.size.width = 37.0f;
		UIView* view = [[UIView alloc] initWithFrame:rect];
		view.backgroundColor = [UIColor clearColor];
		[self addSubview:view];
		[clickViews_ addObject:view];
		[view release];
		
		counter++;
	}
}

- (void)evaluateTouch:(CGPoint)p {
	UIView *view = [self hitTest:p withEvent:nil];		
	int i = [clickViews_ indexOfObject:view];
	
	if( current_index_ != i && i != NSNotFound) {		
//		DNSLog( @"clicked - %d", [[indices_ objectAtIndex:i] intValue] );
		current_index_ = i;
		[(ThreadViewController*)delegate_ scrollToDIV:[[indices_ objectAtIndex:i] intValue]];
	}
	else
		current_index_ = NSNotFound;
}

#pragma mark Override

- (void)dealloc {
	DNSLog( @"[ThreadViewIndex] dealloc" );
	[background_ release];
	[indices_ release];
	[labels_ release];
	[clickViews_ release];
    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	background_.hidden = NO;
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
	[self evaluateTouch:touchPoint];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
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

@end

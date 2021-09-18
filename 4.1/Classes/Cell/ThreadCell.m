//
//  CellForDrawRect.m
//  scroller
//
//  Created by sonson on 08/12/15.
//  Copyright 2008 sonson. All rights reserved.
//

#import "ThreadCell.h"
#import "DatParser.h"
#import "ThreadLayoutComponent.h"
#import "ThreadResData.h"
#import "ThreadViewController.h"
#import "ThreadDatParser.h"

#define THREAD_CELL_TOP_MARGIN 0
#define THREAD_CELL_BOTTOM_MARGIN 0

UIImage*	AsciiImage = nil;
UIImage*	CheckImage = nil;
BOOL		isShownButton = NO;
BOOL		isEnabledAscii = NO;

@implementation ThreadCell

@synthesize resObject = resObject_;
@synthesize height = height_;
@synthesize delegate = delegate_;

+ (void)initialize {
	if( AsciiImage == nil )
		AsciiImage = [[UIImage imageNamed:@"ascii.png"] retain];
	if( CheckImage == nil )
		CheckImage = [[UIImage imageNamed:@"check.png"] retain];
	isShownButton = NO; //[[NSUserDefaults standardUserDefaults] boolForKey:@"asciiButton"];
	isEnabledAscii = [[NSUserDefaults standardUserDefaults] boolForKey:@"asciiButton"];
}

+ (float)offsetHeight {
	return 0;
	if( isShownButton )
		return HeightThreadInfoFont * 2 + THREAD_CELL_TOP_MARGIN + THREAD_CELL_BOTTOM_MARGIN + AsciiImage.size.height;
	else
		return HeightThreadInfoFont * 2 + THREAD_CELL_TOP_MARGIN + THREAD_CELL_BOTTOM_MARGIN;
}

+ (float)offsetHeightOfPopup {
	return 0;
	if( isShownButton )
		return HeightThreadInfoFont * 2 + THREAD_CELL_TOP_MARGIN + THREAD_CELL_BOTTOM_MARGIN + AsciiImage.size.height;
	else
		return HeightThreadInfoFont * 2 + THREAD_CELL_TOP_MARGIN + THREAD_CELL_BOTTOM_MARGIN;
}

#pragma mark Original Method

- (BOOL)isIt2ch:(NSString*)input toDictionary:(NSDictionary**)dict {
	DNSLogMethod
	NSArray*elements = [input componentsSeparatedByString:@"/"];
	if( [elements count] >= 7 ) {
		
		NSString* server = [elements objectAtIndex:2];
		NSString* boardPath = [elements objectAtIndex:5];
		NSString* dat = [elements objectAtIndex:6];
		
		NSArray* serverElements = [server componentsSeparatedByString:@"."];
		
		if( [serverElements count] == 3 ) {
			if( [[serverElements objectAtIndex:1] isEqualToString:@"2ch"] ) {
				*dict = [NSDictionary dictionaryWithObjectsAndKeys:
						 server,		@"server",
						 boardPath,	@"path",
						 dat,			@"dat",
						 nil];
				return YES;
			}
		}
	}
	return NO;
}

#pragma mark Override

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	DNSLogMethod
	UITouch *touch = [touches anyObject];
    CGPoint startTouchPosition = [touch locationInView:self];
	NSDictionary* link2ch = nil;
	
	if( CGRectContainsPoint( infoRect_, startTouchPosition ) && !resObject_.isPopup ) {
		DNSLog( @"kThreadLayoutInfo - %d", resObject_.number );
		resObject_.isSelected = !resObject_.isSelected;
		[self setNeedsDisplay];
		return;
	}
/*	
	if( CGRectContainsPoint( buttonRect_, startTouchPosition ) ) {
		DNSLog( @"AsciiButton - kThreadLayoutInfo - %d", [resObject_.numberString intValue] );
		[delegate_ openAsciiView:[resObject_.numberString intValue]];
		return;
	}
 */	
	if( CGRectContainsPoint( self.bounds, startTouchPosition ) && touch.tapCount == 2 && isEnabledAscii ) {
		DNSLog( @"AsciiButton - kThreadLayoutInfo - %d", [resObject_.numberString intValue] );
		[delegate_ openAsciiView:[resObject_.numberString intValue]];
		return;
	}
	
	for( ThreadLayoutComponent* p in resObject_.body ) {
		if( CGRectContainsPoint( p.rect, startTouchPosition ) ) {
			if( p.textInfo == kThreadLayoutAnchor ) {
				DNSLog( @"kThreadLayoutAnchor - %@", p.text );
				NSArray *numbers = [ThreadDatParser getNumber:p.text];
				[delegate_ openAnchor:numbers];
				return;
			}
			else if( p.textInfo == kThreadLayoutHTTPLink ) {
				DNSLog( @"kThreadLayoutHTTPLink - %@", p.text );
				if( [self isIt2ch:p.text toDictionary:&link2ch] ) {
					DNSLog( @"2ch link" );
					[delegate_ open2chLinkwithPath:[link2ch objectForKey:@"path"] dat:[[link2ch objectForKey:@"dat"] intValue]];
					return;
				}
				else if( [p.text rangeOfString:@".apple.com/WebObjects/MZStore.woa"].location != NSNotFound ) {
					if( [p.text characterAtIndex:0] == 't' ) {
						[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"h" stringByAppendingString:p.text]]];
						return;
					}
					else {
						[[UIApplication sharedApplication] openURL:[NSURL URLWithString:p.text]];
						return;
					}
				}
				else {
					DNSLog( @"%@", delegate_ );
					if( [p.text characterAtIndex:0] == 't' ) {
						[delegate_ openWebBrowser:[@"h" stringByAppendingString:p.text]];
						return;
					}
					else {
						[delegate_ openWebBrowser:p.text];
						return;
					}
				}
			}
		}
	}
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		resObject_.isSelected = NO;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:animated];
}

- (void) layoutSubviews {
	[super layoutSubviews];
	[self setNeedsDisplay];
}

- (void)drawAsciiButtonRect:(CGRect)rect {
//	float x = rect.size.width - AsciiImage.size.height - 70;
//	float y = rect.size.height - AsciiImage.size.height - 10;
	float x = 10;
	float y = rect.size.height - AsciiImage.size.height - 10;
	[AsciiImage drawAtPoint:CGPointMake( x, y )];
	buttonRect_ = CGRectMake( x, y, AsciiImage.size.width, AsciiImage.size.height );
}

- (void)drawInfoRect:(CGRect)rect {
	CGSize r_size;
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetRGBFillColor( context, 200/255.0f, 200/255.0f, 200/255.0f, 1.f );
	
	CGRect info_rect = CGRectMake( 0, 0, rect.size.width, HeightThreadInfoFont * 2 + 4 );
	CGContextFillRect( context, info_rect );
	
	CGContextSetRGBFillColor( context, 0/255.0f, 0/255.0f, 0/255.0f, 1.f );
	
	r_size = [resObject_.numberString drawInRect:CGRectMake( 5, 2, 200, HeightThreadInfoFont) withFont:threadInfoFont];
	[resObject_.name drawInRect:CGRectMake( r_size.width + 15, 2, rect.size.width -  r_size.width - 15, HeightThreadInfoFont) withFont:threadInfoFont];
	
	r_size = [resObject_.email drawInRect:CGRectMake(  5, HeightThreadInfoFont, rect.size.width - 5, HeightThreadInfoFont) withFont:threadInfoFont];
	[resObject_.date drawInRect:CGRectMake(  r_size.width + 15, HeightThreadInfoFont, rect.size.width -  r_size.width - 15, HeightThreadInfoFont) withFont:threadInfoFont];
	
	if( resObject_.isSelected ) {
		[CheckImage drawAtPoint:CGPointMake( 264, 3 )];
	}
}

- (void)drawRect:(CGRect)rect {
	[self drawInfoRect:rect];
	
	infoRect_ = CGRectMake( 0, 0, rect.size.width, HeightThreadInfoFont * 2 + 4 );
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	for( ThreadLayoutComponent* p in resObject_.body ) {
		if( p.textInfo == kThreadLayoutHTTPLink || p.textInfo == kThreadLayoutAnchor ) {
			CGContextSetRGBFillColor( context, 240/255.0f, 240/255.0f, 240/255.0f, 1.f );
			// outline 
			CGFloat minx = CGRectGetMinX( p.rect ), midx = CGRectGetMidX( p.rect ), maxx = CGRectGetMaxX( p.rect );
			CGFloat miny = CGRectGetMinY( p.rect ), midy = CGRectGetMidY( p.rect ), maxy = CGRectGetMaxY( p.rect );
			
			miny+=1;
			maxy-=1;
			
			float radius =4;
			
			CGContextMoveToPoint(context, minx, midy);
			CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
			CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
			CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
			CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
			CGContextClosePath(context);
			CGContextFillPath ( context );
			
			CGRect frame = p.rect;
			frame.origin.x += ANCHOR_OFFSET_X;
			frame.origin.y += ANCHOR_OFFSET_Y;
			
			//CGContextFillRect( context, p.rect );
			CGContextSetRGBFillColor(context, 85/255.0f, 26/255.0f, 139/255.0f, 1.f);
			[p.text drawInRect:frame withFont:threadFont];
		}
		else {
			CGContextSetRGBFillColor(context, 0/255.0f, 0/255.0f, 0/255.0f, 1.f);
			[p.text drawInRect:p.rect withFont:threadFont];
		}
	}	
//	if( isShownButton && !resObject_.isPopup )
//		[self drawAsciiButtonRect:rect];
}

#pragma mark dealloc

- (void)dealloc {
    [super dealloc];
}

@end

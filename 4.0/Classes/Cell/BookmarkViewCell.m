//
//  BookmarkViewCell.m
//  2tch
//
//  Created by sonson on 08/12/26.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BookmarkViewCell.h"
#import "BookmarkCellInfo.h"

CGGradientRef redGradient = NULL;

NSString	*resPromptBK = nil;
NSString	*readPromptBK = nil;
NSString	*boardBK = nil;
UIColor		*infoColorBK = nil;
UIImage		*unreadIcon = nil;
float	bookmarkCellHeight;

@implementation BookmarkViewCell

@synthesize data = data_;

+ (void)initialize {
	DNSLogMethod
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	CGFloat colors[] = {
		255.0f / 255.0, 190 / 255.0,  190 / 255.0, 1.00,
		255.0f / 255.0, 100 / 255.0,  100 / 255.0, 1.00
	};
	redGradient = CGGradientCreateWithColorComponents( rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4) );
	CGColorSpaceRelease(rgb);
	
	if( !unreadIcon )
		unreadIcon = [[UIImage imageNamed:@"unread.png"] retain];
	
	if( !resPromptBK )
		resPromptBK = LocalStr( @"Res:" );
	if( !readPromptBK )
		readPromptBK = LocalStr( @"Read:" );
	if( !boardBK )
		boardBK = LocalStr( @"Board" );
	if( !infoColorBK )
		infoColorBK = [[UIColor colorWithRed:37.0/255.0 green:113.0/255.0 blue:216.0/255.0 alpha:1.0] retain];
	bookmarkCellHeight = HeightThreadTitleFont * 3 + 15 + HeightThreadTitleInfoFont;
}

+ (float)height {
	return bookmarkCellHeight;
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}

- (void)draw:(BOOL)selected rect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGSize size;
	float editing_offset = 5 + rect.origin.x;
	
	if( data_.isUnread )
		[unreadIcon drawAtPoint:CGPointMake( editing_offset + 5, rect.size.height /2 )];
	
	float resPrompt_offset, readPrompt_offset;
	if( !selected )
		CGContextSetRGBFillColor( context, 37.0/255.0, 113.0/255.0, 216.0/255, 1.f );
	else
		CGContextSetRGBFillColor( context, 255.0/255.0, 255/255.0, 255/255, 1.f );
	
	[data_.numberString drawInRect:CGRectMake( 5 + editing_offset,  5, 100, HeightThreadTitleInfoFont) withFont:threadTitleInfoFont lineBreakMode:UILineBreakModeMiddleTruncation];
	
	if( data_.boardTitle != nil ) {
		resPrompt_offset = 40 + editing_offset;
		size = [resPromptBK drawInRect:CGRectMake( resPrompt_offset, 5, 100, HeightThreadTitleInfoFont) withFont:threadTitleInfoFont lineBreakMode:UILineBreakModeMiddleTruncation];
		[data_.resString drawInRect:CGRectMake( resPrompt_offset+size.width, 5, 100, HeightThreadTitleInfoFont) withFont:threadTitleInfoFont lineBreakMode:UILineBreakModeMiddleTruncation];
	}
	else {
		resPrompt_offset = 40 + editing_offset;
		size = [boardBK drawInRect:CGRectMake( resPrompt_offset, 5, 100, HeightThreadTitleInfoFont) withFont:threadTitleInfoFont lineBreakMode:UILineBreakModeMiddleTruncation];
	}
	
	if( data_.readString && data_.boardTitle != nil ) {
		readPrompt_offset = 110 + editing_offset;
		size = [readPromptBK drawInRect:CGRectMake( readPrompt_offset, 5, 100, HeightThreadTitleInfoFont) withFont:threadTitleInfoFont lineBreakMode:UILineBreakModeMiddleTruncation];
		[data_.readString drawInRect:CGRectMake( readPrompt_offset+size.width, 5, 100, HeightThreadTitleInfoFont) withFont:threadTitleInfoFont lineBreakMode:UILineBreakModeMiddleTruncation];
	}
	
	if( data_.boardTitle != nil ) {
		readPrompt_offset = 160 + editing_offset;
		[data_.boardTitle drawInRect:CGRectMake( readPrompt_offset+size.width, 5, 100, HeightThreadTitleInfoFont) withFont:threadTitleInfoFont lineBreakMode:UILineBreakModeMiddleTruncation];
	}
	
	if( !selected )
		CGContextSetRGBFillColor( context, 0/255.0, 0/255.0, 0/255, 1.f );
	else
		CGContextSetRGBFillColor( context, 255.0/255.0, 255/255.0, 255/255, 1.f );
	[data_.title drawInRect:CGRectMake( 25 + editing_offset, HeightThreadTitleInfoFont+10, rect.size.width - 40, HeightThreadTitleFont*3) withFont:threadTitleFont lineBreakMode:UILineBreakModeMiddleTruncation];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	CGRect frame = self.contentView.frame;
	[super drawRect:rect];
	[self draw:NO rect:frame];
}

- (void)drawBackgroundRect:(CGRect)rect {
	CGRect frame = self.contentView.frame;
	[super drawBackgroundRect:rect];
	[self draw:YES rect:frame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
	[self setNeedsDisplay];
}

- (void)dealloc {
    [super dealloc];
}

@end

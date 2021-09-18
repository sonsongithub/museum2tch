//
//  TitleCell.m
//  2tch
//
//  Created by sonson on 08/12/20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TitleCell.h"
#import "SubjectData.h"

NSString	*resPrompt = nil;
NSString	*readPrompt = nil;
UIColor		*infoColor = nil;
float		cellHeight;

@implementation TitleCell

@synthesize data = data_;

+ (void)initialize {
	DNSLogMethod
	if( !resPrompt )
		resPrompt = LocalStr( @"Res:" );
	if( !readPrompt )
		readPrompt = LocalStr( @"Read:" );
	if( !infoColor )
		infoColor = [[UIColor colorWithRed:37.0/255.0 green:113.0/255.0 blue:216.0/255.0 alpha:1.0] retain];
	cellHeight = HeightThreadTitleFont * 3 + 15 + HeightThreadTitleInfoFont;
}

+ (float)height {
	return cellHeight;
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}

- (void)drawString:(BOOL)selected {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGSize size;
	float resPrompt_offset, readPrompt_offset;
	if( !selected )
		CGContextSetRGBFillColor( context, 37.0/255.0, 113.0/255.0, 216.0/255, 1.f );
	else
		CGContextSetRGBFillColor( context, 255.0/255.0, 255/255.0, 255/255, 1.f );
	[data_.numberString drawInRect:CGRectMake( 5,  5, 100, HeightThreadTitleInfoFont) withFont:threadTitleInfoFont lineBreakMode:UILineBreakModeMiddleTruncation];
	resPrompt_offset = 40;
	size = [resPrompt drawInRect:CGRectMake( resPrompt_offset, 5, 100, HeightThreadTitleInfoFont) withFont:threadTitleInfoFont lineBreakMode:UILineBreakModeMiddleTruncation];
	[data_.resString drawInRect:CGRectMake( resPrompt_offset+size.width, 5, 100, HeightThreadTitleInfoFont) withFont:threadTitleInfoFont lineBreakMode:UILineBreakModeMiddleTruncation];
	
	if( data_.readString ) {
		readPrompt_offset = 120;
		size = [readPrompt drawInRect:CGRectMake( readPrompt_offset, 5, 100, HeightThreadTitleInfoFont) withFont:threadTitleInfoFont lineBreakMode:UILineBreakModeMiddleTruncation];
		[data_.readString drawInRect:CGRectMake( readPrompt_offset+size.width, 5, 100, HeightThreadTitleInfoFont) withFont:threadTitleInfoFont lineBreakMode:UILineBreakModeMiddleTruncation];
	}
	
	if( !selected )
		CGContextSetRGBFillColor( context, 0/255.0, 0/255.0, 0/255, 1.f );
	else
		CGContextSetRGBFillColor( context, 255.0/255.0, 255/255.0, 255/255, 1.f );
	[data_.title drawInRect:CGRectMake( 5, HeightThreadTitleInfoFont+10, 280, HeightThreadTitleFont * 3) withFont:threadTitleFont lineBreakMode:UILineBreakModeMiddleTruncation];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	[self drawString:NO];
}

- (void)drawBackgroundRect:(CGRect)rect {
	[super drawBackgroundRect:rect];
	[self drawString:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)dealloc {
	[data_ release];
    [super dealloc];
}


@end

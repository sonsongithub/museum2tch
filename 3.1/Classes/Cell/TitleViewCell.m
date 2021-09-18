//
//  TitleViewCell.m
//  2tchfree
//
//  Created by sonson on 08/08/23.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TitleViewCell.h"
#import "global.h"

UIImage* checkSelectedImage = nil;
UIImage* checkUnselectedImage = nil;
UIImage* boardIconImage = nil;

float TitleViewCellHeight = 88.0f;

#ifdef _NEW

float heightOfText(NSString* str, UIFont* font, float width, float height ) {
    UILabel *label = [[UILabel alloc] initWithFrame: CGRectZero];
    label.font = font;
    label.numberOfLines = 3;
    label.text = str;
    CGRect bounds = CGRectMake(0, 0, width, height );
    CGRect result = [label textRectForBounds:bounds limitedToNumberOfLines:3];
	CGFloat h = result.size.height;
	[label release];
	return h;
}

@implementation TitleViewCell

@synthesize title = title_;
@synthesize boardTitle = boardTitle_;
@synthesize number = number_;
@synthesize res = res_;
@synthesize isShownCheck = isShownCheck_;

#pragma mark Class Method

+ (UIImage*) getSelectedCheckImage {
	if( checkSelectedImage == nil ) {
		checkSelectedImage = [UIImage imageNamed:@"checkSelected.png"];
		[checkSelectedImage retain];
	}
	return checkSelectedImage;
}

+ (UIImage*) getUnselectedCheckImage {
	if( checkUnselectedImage == nil ) {
		checkUnselectedImage = [UIImage imageNamed:@"checkUnselected.png"];
		[checkUnselectedImage retain];
	}
	return checkUnselectedImage;
}

+ (UIImage*) getBoardIconImage {
	if( boardIconImage == nil ) {
		boardIconImage = [UIImage imageNamed:@"board.png"];
		[boardIconImage retain];
	}
	return boardIconImage;
}

#pragma mark Original Method

- (void)prepareForReuse {
	[super prepareForReuse];
	[title_ release];
	title_ = nil;
	
	[res_ release];
	res_ = nil;
	
	[number_ release];
	number_ = nil;
	
	[boardTitle_ release];
	boardTitle_ = nil;
	
	[readDate_ release];
	readDate_ = nil;
}

- (void) setTitle:(NSString*)title res:(NSString*)res number:(int)number boardTitle:(NSString*)boardTitle {
	// title_ = [[NSString alloc] initWithString:title];
	title_ = [title retain];
	
	res_ = [[NSString alloc] initWithFormat:@"%@:%@", NSLocalizedString( @"Res", nil ),  res];
	number_ = [[NSString alloc] initWithFormat:@"%03d", number];
	if( boardTitle ) {
		boardTitle_ = [boardTitle_ retain];
		// boardTitle_ = [[NSString alloc] initWithString:boardTitle];
	}
	isThreadTitle_ = YES;
}

- (void) setTitle:(NSString*)title res:(NSString*)res number:(int)number boardTitle:(NSString*)boardTitle date:(NSDate*)date{
	// title_ = [[NSString alloc] initWithString:title];
	title_ = [title retain];
	
	res_ = [[NSString alloc] initWithFormat:@"%@:%@", NSLocalizedString( @"Res", nil ),  res];
	number_ = [[NSString alloc] initWithFormat:@"%03d", number];
	
	boardTitle_ = [boardTitle_ retain];
	// boardTitle_ = [[NSString alloc] initWithString:boardTitle];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	readDate_ = [[NSString alloc] initWithString:[dateFormatter stringFromDate:date]];
	[dateFormatter release];
	isThreadTitle_ = YES;
}

- (void) setTitle:(NSString*)title number:(int)number {
	// title_ = [[NSString alloc] initWithString:title];
	title_ = [title retain];
	
	number_ = [[NSString alloc] initWithFormat:@"%03d", number];
	isThreadTitle_ = NO;
}

- (void) confirmHasCacheWithBoardPath:(NSString*)boardPath dat:(NSString*)dat {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path =[NSString stringWithFormat:@"%@/%@/%@.dat", documentsDirectory, boardPath, dat];
	
	if( [[NSFileManager defaultManager] fileExistsAtPath:path] )
		isShownCheck_ = YES;
	else
		isShownCheck_ = NO;
}

#pragma mark Override

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
    }
    return self;
}

- (void) drawDate {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetTextDrawingMode(context, kCGTextFill);
	if (self.selected) {
		CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	} else {
		CGContextSetFillColorWithColor(context, [UIColor grayColor].CGColor);
	}
	/*float height = */heightOfText( readDate_, [UIFont boldSystemFontOfSize:12.0f], 90, 12 );
	
	CGRect number_rect = CGRectMake( 310 - 90, 5, 90, 12);
	
	[readDate_ drawInRect:number_rect withFont:[UIFont boldSystemFontOfSize:12.0f] lineBreakMode:UILineBreakModeMiddleTruncation];
}

- (void) drawRes {
	NSString* temp = nil;
	if( res_ == nil ) {
		temp = [[NSString alloc] initWithString:NSLocalizedString( @"Board", nil )];
	}
	else 
		temp = res_;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetTextDrawingMode(context, kCGTextFill);
	if (self.selected) {
		CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	} else {
		CGContextSetFillColorWithColor(context, [UIColor grayColor].CGColor);
	}
	/*float height = */heightOfText( temp, [UIFont boldSystemFontOfSize:12.0f], 75, 12 );
	
	CGRect number_rect = CGRectMake( 41, 5 , 75, 12);
	
	[temp drawInRect:number_rect withFont:[UIFont boldSystemFontOfSize:12.0f] lineBreakMode:UILineBreakModeMiddleTruncation];
	
	if( res_ == nil ) {
		[temp release];
	}
}

- (void) drawBoardTitle {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetTextDrawingMode(context, kCGTextFill);
	if (self.selected) {
		CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	} else {
		CGContextSetFillColorWithColor(context, [UIColor grayColor].CGColor);
	}
	/*float height = */heightOfText( boardTitle_, [UIFont boldSystemFontOfSize:12.0f], 100, 12 );
	
	CGRect number_rect = CGRectMake( 117, 5 , 100, 12);
	
	[boardTitle_ drawInRect:number_rect withFont:[UIFont boldSystemFontOfSize:12.0f] lineBreakMode:UILineBreakModeMiddleTruncation];
	
}

- (void) drawNumber {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetTextDrawingMode(context, kCGTextFill);
	if (self.selected) {
		CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	} else {
		CGContextSetFillColorWithColor(context, [UIColor grayColor].CGColor);
	}
	/*float height = */heightOfText( number_, [UIFont boldSystemFontOfSize:12.0f], 35, 12 );
	
	CGRect number_rect = CGRectMake( 10, 5 , 35, 12);
	
	[number_ drawInRect:number_rect withFont:[UIFont boldSystemFontOfSize:12.0f] lineBreakMode:UILineBreakModeMiddleTruncation];
}

- (void) drawTitle {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetTextDrawingMode(context, kCGTextFill);
	if (self.selected) {
		CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	} else {
		CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
	}
	CGRect title_rect;

	DNSLog( @"%f,%f", self.contentView.frame.size.width, self.contentView.frame.size.height );
	DNSLog( @"%f,%f", self.contentView.frame.origin.x, self.contentView.frame.origin.y );
	
	if( self.editing ) {
		if( self.contentView.frame.origin.x > 0 ) {
			float height = heightOfText( title_, [UIFont boldSystemFontOfSize:15.0f], 240, 61 );
			title_rect = CGRectMake( 45, TitleViewCellHeight - 61 - 3 + ( 61 - height )/2.0f , 240, height);
		}
		else {
			float height = heightOfText( title_, [UIFont boldSystemFontOfSize:15.0f], 240, 61 );
			title_rect = CGRectMake( 25, TitleViewCellHeight - 61 - 3 + ( 61 - height )/2.0f , 260, height);
		}
	}
	else {
		float height = heightOfText( title_, [UIFont boldSystemFontOfSize:15.0f], 270, 61 );
		title_rect = CGRectMake( 25, TitleViewCellHeight - 61 - 3 + ( 61 - height )/2.0f , 270, height);
	}
	[title_ drawInRect:title_rect withFont:[UIFont boldSystemFontOfSize:15.0f] lineBreakMode:UILineBreakModeMiddleTruncation];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];	
	[self drawTitle];
	[self drawNumber];
	[self drawRes];
	[self drawBoardTitle];
	[self drawDate];
}

- (void)drawBackgroundRect:(CGRect)rect {
	[super drawBackgroundRect:rect];
	[self drawTitle];
	[self drawNumber];
	[self drawRes];
	[self drawBoardTitle];
	[self drawDate];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (void)dealloc {
    [super dealloc];
}

@end

#else

@implementation TitleViewCell

@synthesize title = title_;
@synthesize boardTitle = boardTitle_;
@synthesize number = number_;
@synthesize res = res_;
@synthesize isShownCheck = isShownCheck_;

#pragma mark Class Method

+ (UIImage*) getSelectedCheckImage {
	if( checkSelectedImage == nil ) {
		checkSelectedImage = [UIImage imageNamed:@"checkSelected.png"];
		[checkSelectedImage retain];
	}
	return checkSelectedImage;
}

+ (UIImage*) getUnselectedCheckImage {
	if( checkUnselectedImage == nil ) {
		checkUnselectedImage = [UIImage imageNamed:@"checkUnselected.png"];
		[checkUnselectedImage retain];
	}
	return checkUnselectedImage;
}

+ (UIImage*) getBoardIconImage {
	if( boardIconImage == nil ) {
		boardIconImage = [UIImage imageNamed:@"board.png"];
		[boardIconImage retain];
	}
	return boardIconImage;
}

#pragma mark Original Method

- (void) setTitle:(NSString*)title res:(NSString*)res number:(int)number boardTitle:(NSString*)boardTitle {
	title_.text = title;
	res_.text = [NSString stringWithFormat:@"%@:%@", NSLocalizedString( @"Res", nil ),  res];
	number_.text = [NSString stringWithFormat:@"%03d", number];
	boardTitle_.text = boardTitle;
	isThreadTitle_ = YES;
}

- (void) setTitle:(NSString*)title res:(NSString*)res number:(int)number boardTitle:(NSString*)boardTitle date:(NSDate*)date{
	title_.text = title;
	res_.text = [NSString stringWithFormat:@"%@:%@", NSLocalizedString( @"Res", nil ),  res];
	number_.text = [NSString stringWithFormat:@"%03d", number];
	boardTitle_.text = boardTitle;
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	readDate_.text = [dateFormatter stringFromDate:date];
	[dateFormatter release];
	isThreadTitle_ = YES;
}

- (void) setTitle:(NSString*)title number:(int)number {
	title_.text = title;
	res_.text = NSLocalizedString( @"Board", nil );
	number_.text = [NSString stringWithFormat:@"%03d", number];
	boardTitle_.text = @"";
	isThreadTitle_ = NO;
}

- (void) confirmHasCacheWithBoardPath:(NSString*)boardPath dat:(NSString*)dat {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path =[NSString stringWithFormat:@"%@/%@/%@.dat", documentsDirectory, boardPath, dat];
	
	if( [[NSFileManager defaultManager] fileExistsAtPath:path] )
		isShownCheck_ = YES;
	else
		isShownCheck_ = NO;
}

#pragma mark Override

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		title_ = [[UILabel alloc] initWithFrame:CGRectMake( 20, 22, 275, 61 )];
		number_ = [[UILabel alloc] initWithFrame:CGRectMake( 10, 5, 35, 12 )];
		res_ = [[UILabel alloc] initWithFrame:CGRectMake( 41, 5, 75, 12 )];
		boardTitle_ = [[UILabel alloc] initWithFrame:CGRectMake( 117, 5, 100, 12 )];
		readDate_ = [[UILabel alloc] initWithFrame:CGRectMake( 310 - 90, 5, 90, 12 )];
		
		[self.contentView addSubview:readDate_];
		[self.contentView addSubview:title_];
		[self.contentView addSubview:number_];
		[self.contentView addSubview:res_];
		[self.contentView addSubview:boardTitle_];
		
		selected_ = [[UIImageView alloc] initWithImage:[TitleViewCell getSelectedCheckImage]];
		unselected_ = [[UIImageView alloc] initWithImage:[TitleViewCell getUnselectedCheckImage]];
		boardIcon_ = [[UIImageView alloc] initWithImage:[TitleViewCell getBoardIconImage]];
		[self.contentView addSubview:unselected_];
		[self.contentView addSubview:selected_];
		[self.contentView addSubview:boardIcon_];
		unselected_.hidden = YES;
		selected_.hidden = YES;
		boardIcon_.hidden = YES;
		isShownCheck_ = NO;
		
		title_.numberOfLines = 3;
		UIFont *font1 = [UIFont boldSystemFontOfSize:12.0f];
		UIFont *font2 = [UIFont boldSystemFontOfSize:15.0f];
		title_.font = font2;
		title_.lineBreakMode = UILineBreakModeMiddleTruncation;
		number_.font = font1;
		res_.font = font1;
		boardTitle_.font = font1;
		readDate_.font = font1;
		readDate_.textAlignment = UITextAlignmentRight;
		
		title_.textColor = [UIColor blackColor];
		number_.textColor = [UIColor colorWithRed:37.0/255.0 green:113.0/255.0 blue:216.0/255.0 alpha:1.0];
		res_.textColor = [UIColor colorWithRed:37.0/255.0 green:113.0/255.0 blue:216.0/255.0 alpha:1.0];
		boardTitle_.textColor = [UIColor colorWithRed:37.0/255.0 green:113.0/255.0 blue:216.0/255.0 alpha:1.0];
		readDate_.textColor = [UIColor colorWithRed:37.0/255.0 green:113.0/255.0 blue:216.0/255.0 alpha:1.0];
		
    }
    return self;
}

- (void) layoutSubviews {
	[super layoutSubviews];
	
	selected_.frame = CGRectMake( 5, 39, 10, 10 );
	unselected_.frame = CGRectMake( 5, 39, 10, 10 );
	boardIcon_.frame = CGRectMake( 3, 44, 14, 16 );
	
	if( isThreadTitle_ ) {
		boardIcon_.hidden = YES;
		if( self.editing ) {
			title_.frame = CGRectMake( 20, 22, 235, 61 );
		}
		else {
			title_.frame = CGRectMake( 20, 22, 275, 61 );
		}
	}
	else {
		unselected_.hidden = YES;
		selected_.hidden = YES;
		boardIcon_.hidden =NO;
		
		if( self.editing ) {
			title_.frame = CGRectMake( 20, 22, 235, 61 );
		}
		else {
			title_.frame = CGRectMake( 20, 22, 275, 61 );
		}
		
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

	unselected_.hidden = YES;
	selected_.hidden = YES;

	if( selected ) {
		if( isShownCheck_ )
			selected_.hidden = NO;
			
		title_.textColor = [UIColor whiteColor];
		number_.textColor = [UIColor whiteColor];
		res_.textColor = [UIColor whiteColor];
		boardTitle_.textColor = [UIColor whiteColor];
		readDate_.textColor = [UIColor whiteColor];
		
		
		title_.backgroundColor = [UIColor clearColor];
		number_.backgroundColor = [UIColor clearColor];
		res_.backgroundColor = [UIColor clearColor];
		boardTitle_.backgroundColor = [UIColor clearColor];
		readDate_.backgroundColor = [UIColor clearColor];
	}
	else {
		if( isShownCheck_ )
			unselected_.hidden = NO;
		
		title_.textColor = [UIColor blackColor];
		number_.textColor = [UIColor colorWithRed:37.0/255.0 green:113.0/255.0 blue:216.0/255.0 alpha:1.0];
		res_.textColor = [UIColor colorWithRed:37.0/255.0 green:113.0/255.0 blue:216.0/255.0 alpha:1.0];
		boardTitle_.textColor = [UIColor colorWithRed:37.0/255.0 green:113.0/255.0 blue:216.0/255.0 alpha:1.0];
		readDate_.textColor = [UIColor colorWithRed:37.0/255.0 green:113.0/255.0 blue:216.0/255.0 alpha:1.0];
		
		title_.backgroundColor = [UIColor whiteColor];
		number_.backgroundColor = [UIColor whiteColor];
		res_.backgroundColor = [UIColor whiteColor];
		boardTitle_.backgroundColor = [UIColor whiteColor];
		readDate_.backgroundColor = [UIColor whiteColor];

	}

	[super setSelected:selected animated:animated];
}

- (void)dealloc {
	[readDate_ release];
	[title_ release];
	[number_ release];
	[res_ release];
	[boardTitle_ release];
	[selected_ release];
	[unselected_ release];
	[boardIcon_ release];
    [super dealloc];
}

@end

#endif

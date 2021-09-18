//
//  SearchTerminateCell.m
//  2tch
//
//  Created by sonson on 09/02/08.
//  Copyright 2009 sonson. All rights reserved.
//

#import "SearchTerminateCell.h"
#import "BookmarkViewCell.h"

@implementation SearchTerminateCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		indicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		message_ = [[UILabel alloc] initWithFrame:CGRectZero];
		message_.font = [UIFont boldSystemFontOfSize:16];
		message_.textColor = [UIColor colorWithRed:37.0/255.0 green:113.0/255.0 blue:216.0/255.0 alpha:1.0];
		resultLength_ = [[UILabel alloc] initWithFrame:CGRectZero];
		resultLength_.font = [UIFont boldSystemFontOfSize:16];
		resultLength_.textColor = [UIColor colorWithRed:180/255.0f green:180/255.0f blue:180/255.0f alpha:1.0f];
		[self.contentView addSubview:indicator_];
		[self.contentView addSubview:message_];
		[self.contentView addSubview:resultLength_];
		[indicator_ release];
		[message_ release];
		[resultLength_ release];
    }
    return self;
}

- (void)setFinished:(BOOL)finished resultLength:(int)resultLength {
	if( finished ) {
		indicator_.hidden = YES;
		[indicator_ stopAnimating];
		message_.text = NSLocalizedString( @"SearchFiniehd", nil );
		CGRect rect = [message_ textRectForBounds:CGRectMake(0,0,200,100) limitedToNumberOfLines:1];
		rect.origin.x = indicator_.frame.size.width+ 20;
		rect.origin.y = [BookmarkViewCell height]/2 - rect.size.height;
		message_.frame = rect;
		NSString* result_text = [NSString stringWithFormat:@"%@%d%@", NSLocalizedString( @"Total", nil ), resultLength, NSLocalizedString( @"SearchResults", nil )];
		resultLength_.text = result_text;
		rect = [resultLength_ textRectForBounds:CGRectMake(0,0,200,100) limitedToNumberOfLines:1];
		rect.origin.x = indicator_.frame.size.width+ 20;
		rect.origin.y = [BookmarkViewCell height]/2;
		resultLength_.frame = rect;
	}
	else {
		indicator_.center = CGPointMake( indicator_.frame.size.width / 2 + 10, [BookmarkViewCell height]/2 );
		indicator_.hidden = NO;
		[indicator_ startAnimating];
		message_.text = NSLocalizedString( @"NowSearching...", nil );
		CGRect rect = [message_ textRectForBounds:CGRectMake(0,0,200,100) limitedToNumberOfLines:1];
		rect.origin.x = indicator_.frame.size.width+ 20;
		rect.origin.y = [BookmarkViewCell height]/2 - rect.size.height;
		message_.frame = rect;
		NSString* result_text = [NSString stringWithFormat:@"%@%d%@", NSLocalizedString( @"Total", nil ), resultLength, NSLocalizedString( @"SearchResults", nil )];
		resultLength_.text = result_text;
		rect = [resultLength_ textRectForBounds:CGRectMake(0,0,200,100) limitedToNumberOfLines:1];
		rect.origin.x = indicator_.frame.size.width+ 20;
		rect.origin.y = [BookmarkViewCell height]/2;
		resultLength_.frame = rect;
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	return;
    [super setSelected:selected animated:animated];
}

- (void)dealloc {
    [super dealloc];
}

@end

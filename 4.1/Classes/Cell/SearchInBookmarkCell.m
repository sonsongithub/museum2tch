//
//  SearchInBookmarkCell.m
//  2tch
//
//  Created by sonson on 09/02/10.
//  Copyright 2009 sonson. All rights reserved.
//

#import "SearchInBookmarkCell.h"

@implementation SearchInBookmarkCell

UIImage* SearchInBookmarkImage = nil;
UIImage* SearchInBookmarkSelectedImage = nil;

+ (void)initialize {
	if( SearchInBookmarkImage == nil )
		SearchInBookmarkImage = [[UIImage imageNamed:@"search.png"] retain];
	if( SearchInBookmarkSelectedImage == nil )
		SearchInBookmarkSelectedImage = [[UIImage imageNamed:@"search_selected.png"] retain];
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
    }
    return self;
}

- (void) layoutSubviews {
	[super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
	
	if( selected )
		self.image = SearchInBookmarkSelectedImage;
	else
		self.image = SearchInBookmarkImage;
}

- (void)dealloc {
	DNSLogMethod
    [super dealloc];
}

@end

//
//  HistoryFolderCell.m
//  2tch
//
//  Created by sonson on 08/10/20.
//  Copyright 2008 sonson. All rights reserved.
//

#import "HistoryFolderCell.h"

@implementation HistoryFolderCell

UIImage* HistoryFolderImage = nil;
UIImage* HistoryFolderSelectedImage = nil;

+ (void)initialize {
	if( HistoryFolderImage == nil )
		HistoryFolderImage = [[UIImage imageNamed:@"HistoryFolder.png"] retain];
	if( HistoryFolderSelectedImage == nil )
		HistoryFolderSelectedImage = [[UIImage imageNamed:@"historyFolder_selected.png"] retain];
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
		self.image = HistoryFolderSelectedImage;
	else
		self.image = HistoryFolderImage;
}

- (void)dealloc {
	DNSLogMethod
    [super dealloc];
}

@end

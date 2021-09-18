//
//  HistoryFolderCell.m
//  2tch
//
//  Created by sonson on 08/10/20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HistoryFolderCell.h"

@implementation HistoryFolderCell

UIImage* historyFolderImage = nil;
UIImage* historyFolderSelectedImage = nil;

+ (UIImage*) getHistoryFolderImage {
	if( historyFolderImage == nil ) {
		historyFolderImage = [UIImage imageNamed:@"HistoryFolder.png"];
		[historyFolderImage retain];
	}
	return historyFolderImage;
}

+ (UIImage*) getHistoryFolderSelectedImage {
	if( historyFolderSelectedImage == nil ) {
		historyFolderSelectedImage = [UIImage imageNamed:@"historyFolder_selected.png"];
		[historyFolderSelectedImage retain];
	}
	return historyFolderSelectedImage;
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}

- (void) layoutSubviews {
	[super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
	if( selected ) {
		self.image = [HistoryFolderCell getHistoryFolderSelectedImage];
	}
	else {
		self.image = [HistoryFolderCell getHistoryFolderImage];
	}
}

- (void)dealloc {
    [super dealloc];
}

@end

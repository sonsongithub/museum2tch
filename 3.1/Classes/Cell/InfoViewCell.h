//
//  InfoViewCell.h
//  2tch
//
//  Created by sonson on 08/08/29.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CenterTitleViewCell : UITableViewCell {
	UILabel	*titleLabel_;
}
@property (nonatomic, assign) UILabel *titleLabel;
@end

@interface InfoViewCell : UITableViewCell {
	UILabel*	titleLabel_;
	UILabel*	attributeLabel_;
}
@property (nonatomic, assign) UILabel *titleLabel;
@property (nonatomic, assign) UILabel *attributeLabel;
@end

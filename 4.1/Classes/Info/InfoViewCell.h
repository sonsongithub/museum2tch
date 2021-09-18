//
//  InfoViewCell.h
//  2tch
//
//  Created by sonson on 08/08/29.
//  Copyright 2008 sonson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewCell : UITableViewCell {
	UILabel*	titleLabel_;
	UILabel*	attributeLabel_;
}
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *attributeLabel;
@end

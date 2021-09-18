//
//  PopupLabel.h
//  2tch
//
//  Created by sonson on 08/12/30.
//  Copyright 2008 sonson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PopupTitleView : UIImageView {
	UILabel			*label_;
}
#pragma mark Original
- (void)setText:(NSString*)text;
@end

@interface PopupLabel : UILabel {
	PopupTitleView	*popupTitle_;
}
#pragma mark Original
- (void)show:(BOOL)animated;
- (void)hide:(BOOL)animated;
@end
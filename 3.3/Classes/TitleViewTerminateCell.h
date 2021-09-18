//
//  TitleViewTerminateCell.h
//  2tch
//
//  Created by sonson on 08/11/29.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TitleViewTerminateCell : UITableViewCell {
	UILabel						*firstLabel_;
	UILabel						*secondLabel_;
	UIActivityIndicatorView		*activity_;
}
- (void)setLoading;
- (void)setFinished;
@end

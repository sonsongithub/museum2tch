//
//  SearchTerminateCell.h
//  2tch
//
//  Created by sonson on 09/02/08.
//  Copyright 2009 sonson. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SearchTerminateCell : UITableViewCell {
	UIActivityIndicatorView		*indicator_;
	UILabel						*message_;
	UILabel						*resultLength_;
}
- (void)setFinished:(BOOL)finished resultLength:(int)resultLength;
@end

//
//  ReplyViewCell.h
//  2tch
//
//  Created by sonson on 08/08/30.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BodyCell : UITableViewCell <UITextViewDelegate>{
	UITextView		*textView_;
	UILabel			*placeholder_;
}
@property (nonatomic, assign) UITextView *textView;
@end

@interface ReplyViewCell : UITableViewCell {
	UITextField		*field_;
}
@property (nonatomic, assign) UITextField *field;
@end

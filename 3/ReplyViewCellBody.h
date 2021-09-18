//
//  ReplyViewCellBody.h
//  2tch
//
//  Created by sonson on 08/07/19.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ReplyViewCellBody : UITableViewCell {
    IBOutlet UITextView *bodyView_;
	IBOutlet UILabel	*prompt_;
}
@property (nonatomic, assign) UITextView *body;
@property (nonatomic, assign) UILabel *prompt;
@end

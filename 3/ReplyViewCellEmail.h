//
//  ReplyViewCellEmail.h
//  2tch
//
//  Created by sonson on 08/07/19.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ReplyViewCellEmail : UITableViewCell {
    IBOutlet UITextField *emailField_;
	IBOutlet UILabel	*prompt_;
}
@property (nonatomic, assign) UITextField *email;
@property (nonatomic, assign) UILabel *prompt;
@end

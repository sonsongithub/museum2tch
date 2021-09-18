//
//  TitleCell.h
//  2tch
//
//  Created by sonson on 08/12/20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNCellForDrawRect.h"

@class SubjectData;

@interface TitleCell : SNCellForDrawRect {
	SubjectData *data_;
}
@property (nonatomic, retain) SubjectData *data;
+ (float)height;
@end

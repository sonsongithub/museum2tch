//
//  BookmarkViewCell.h
//  2tch
//
//  Created by sonson on 08/12/26.
//  Copyright 2008 sonson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNCellForDrawRect.h"

@class BookmarkCellInfo;

@interface BookmarkViewCell : SNCellForDrawRect {
	BookmarkCellInfo	*data_;
}
@property (nonatomic, assign) BookmarkCellInfo *data;
+ (float)height;
@end

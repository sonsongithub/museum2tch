//
//  BookmarkCellInfo.h
//  2tch
//
//  Created by sonson on 08/12/27.
//  Copyright 2008 sonson. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BookmarkCellInfo : NSObject {
	int				number_;
	NSString		*title_;
	NSString		*path_;
	int				dat_;
	NSString		*boardTitle_;
	NSString		*resString_;
	NSString		*readString_;
	NSString		*numberString_;
	BOOL			isUnread_;
}
@property (nonatomic, assign) int number;
@property (nonatomic, assign) int dat;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSString *boardTitle;
@property (nonatomic, retain) NSString *resString;
@property (nonatomic, retain) NSString *readString;
@property (nonatomic, retain) NSString *numberString;
@property (nonatomic, assign) BOOL isUnread;
@end

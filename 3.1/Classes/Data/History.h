//
//  History.h
//  2tch
//
//  Created by sonson on 08/09/20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface History : NSObject {
	NSMutableArray		*list_;
}

@property (nonatomic, assign) NSMutableArray *list;

#pragma mark Class Method
+ (History*) defaultHistory;

#pragma mark Original Method
- (BOOL) addWithDictinary:(NSMutableDictionary*)dict;
- (void) clear;
- (BOOL) write;

@end

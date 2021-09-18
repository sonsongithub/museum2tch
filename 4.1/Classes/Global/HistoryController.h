//
//  HistoryController.h
//  2tch
//
//  Created by sonson on 08/12/02.
//  Copyright 2008 sonson. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HistoryController : NSObject {
	NSMutableArray		*forwardBuffer_;
	NSMutableArray		*backBuffer_;
	NSDictionary		*currentDict_;
}
@property(nonatomic, retain) NSDictionary* currentDict;
+ (NSString*)threadTitleWithDat:(int)dat path:(NSString*)path;
- (BOOL)deleteEntry:(NSString*)pathInput dat:(int)datInput;
- (BOOL)clearEntries;
- (void)dumpBuffer;
- (BOOL)canGoBack;
- (BOOL)canGoForward;
- (NSDictionary*) goBack;
- (NSDictionary*) goForward;
- (void)insertNewThreadInfoWithPath:(NSString*)path dat:(int)dat;
@end

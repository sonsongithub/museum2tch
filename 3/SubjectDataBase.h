//
//  SubjectDataBase.h
//  2tch
//
//  Created by sonson on 08/07/18.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNProgressSheetController.h"
#import "SNHUDActivityView.h"

@interface SubjectDataBase : NSObject {
	NSMutableArray				*subjectList_;
	NSString					*boardPath_;
	SNProgressSheetController	*sheetController_;
	SNHUDActivityView			*hud_;
	float						parse_progress_;
}
@property (nonatomic, assign) NSMutableArray *subjectList;
@property (nonatomic, retain) NSString *boardPath;
@property (nonatomic, assign) float parse_progress;
+ (BOOL) isExistingCache:(NSString*)boardPath;
- (id) initWithBoardPath:(NSString*)boardPath;
- (void) dealloc;
- (BOOL) loadCache:(NSMutableArray*)array;
- (BOOL) write:(NSMutableArray*)array;
- (void) parse:(NSData*)data array:array delegate:(id)delegate;
- (void) doInfoProcess:(id)obj;
@end

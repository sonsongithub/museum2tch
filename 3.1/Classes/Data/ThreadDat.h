//
//  Dat.h
//  2tchfree
//
//  Created by sonson on 08/08/24.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThreadDat : NSObject {
	NSString			*dat_;
	NSString			*boardPath_;
	NSMutableArray		*resList_;
	int					newResNumber_;
}
@property (nonatomic, assign) NSString *dat;
@property (nonatomic, assign) NSString *boardPath;
@property (nonatomic, assign) NSMutableArray *resList;
@property (nonatomic, assign) int newResNumber;

#pragma mark Class method
+ (void) removeEvacuation;
+ (ThreadDat*) ThreadDatWithBoardPath:boardPath dat:(NSString*)dat;
+ (ThreadDat*) ThreadDatFromEvacuation;

#pragma mark Original method
- (BOOL) evacuate;
- (NSString*) resDescription;
- (BOOL) write;
- (int) updateNewComming:(int)previous_res;
- (BOOL) updateBookmarkResNumber;
- (BOOL) updateSubjectTxtResNumber;
- (BOOL) append:(NSData*) data;
- (void) clearOldData;

@end

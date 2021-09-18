//
//  DataBase.h
//  2tch
//
//  Created by sonson on 08/07/18.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBSMenuDataBase.h"
#import "SubjectDataBase.h"
#import "DatInfoDataBase.h"
#import "ThreadDataBase.h"

@interface DataBase : NSObject {
	NSMutableArray		*categoryList_;
	NSMutableArray		*boardList_;
	
	NSString			*dat_;
//	NSString			*boardPath_;
	NSMutableArray		*subjectList_;
	NSMutableArray		*resList_;
}
@property (nonatomic, assign) NSMutableArray *categoryList;
@property (nonatomic, assign) NSMutableArray *boardList;


@property (nonatomic, assign) NSMutableArray *subjectList;
@property (nonatomic, assign) NSString *dat;
@property (nonatomic, assign) NSMutableArray *resList;

- (id) init;
- (void) dealloc;
#pragma mark BBSMenu - category and board
- (void) parseBBSMenu:(NSData*)data;
- (void) setCurrentCategory:(int)category_id;
#pragma mark access bbsmenu data
- (NSString*) serverOfBoardPath:(NSString*)boardPath;
#pragma mark subject.txt
- (BOOL) loadSubjectTxtCache:(NSString*)boardPath;
- (BOOL) parseSubjectTxt:(NSData*)data ofBoardPath:(NSString*)path delegate:(id)delegate;
#pragma mark dat
- (void) setContentLength:(NSString*)contentLength lastModified:(NSString*)lastModified ofDat:(NSString*)dat atBoardPath:(NSString*)boardPath;
- (NSMutableDictionary*) contentLengthAndLastModifiedDictOfDat:(NSString*)dat atBoardPath:(NSString*)boardPath;
- (BOOL) loadCurrentDat:(NSString*)boardPath dat:(NSString*)dat;
- (BOOL) readRes:(NSString*)boardPath dat:(NSString*)dat data:(NSData*)data;

@end

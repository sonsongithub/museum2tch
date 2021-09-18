//
//  DatParser.h
//  2tch
//
//  Created by sonson on 08/11/29.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DatParser_old : NSObject {

}
+ (void)getPreviousRes:(int*)prevRes res:(int*)res withDat:(int)dat path:(NSString*)path;
+ (NSString*)categoryTitleWithPath:(int)category_id;
+ (NSString*)boardTitleWithPath:(NSString*)path;
+ (NSString*)threadTitleFromReadCGIWithDat:(int)dat path:(NSString*)path;
+ (NSString*)threadTitleFromUntrasedData:(int)dat path:(NSString*)path;
+ (NSString*)threadTitleWithDat:(int)dat path:(NSString*)path;
+ (void)getBytes:(int*)bytes lastModified:(NSString**)lastModified resRead:(int*)resRead ofPath:(NSString*)path dat:(int)dat;
+ (void)insertSubjectWithBytes:(int)bytes lastModified:(NSString*)lastModified resRead:(int)resRead title:(NSString*)title ofPath:(NSString*)path dat:(int)dat;
+ (void)updateReadRes:(int)resRead path:(NSString*)path dat:(int)dat;
+ (void)updateSubjectWithBytes:(int)bytes lastModified:(NSString*)lastModified resRead:(int)resRead previousRes:(int)previousRes ofPath:(NSString*)path dat:(int)dat;
+ (void)makeDirectoryOfPath:(NSString*)path;
+ (void) append:(NSData*)data toArray:(NSMutableArray*)array;
+ (BOOL) write:(NSMutableArray*)array path:(NSString*)path dat:(int)dat;
+ (NSMutableArray*)resListOfPath:(NSString*)path dat:(int)dat;
+ (int)appendNewThreadData:(NSData*)data path:(NSString*)path dat:(int)dat;
@end

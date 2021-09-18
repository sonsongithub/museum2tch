//
//  Dat.h
//  2tch
//
//  Created by sonson on 08/12/21.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

void layout(NSMutableArray* array, int width );

@interface Dat : NSObject {
	NSString		*title_;
	NSMutableArray	*resList_;
	
	NSString		*path_;
	int				dat_;
	int				bytes_;
	NSString		*lastModified_;
	int				savedScroll_;
}
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSMutableArray *resList;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, assign) int dat;
@property (nonatomic, assign) int bytes;
@property (nonatomic, assign) int savedScroll;
@property (nonatomic, retain) NSString *lastModified;
#pragma mark Function for writing
+ (void)makeDirectoryOfPath:(NSString*)path;
#pragma mark Update res, res_read, title of threadInfo where path, dat
+ (BOOL)updateThreadInfoWithRes:(int)res resRead:(int)res_read title:(NSString*)title path:(NSString*)path dat:(int)dat;
+ (void)insertSubjectWithRes:(int)res resRead:(int)res_read title:(NSString*)title path:(NSString*)path dat:(int)dat;
+ (BOOL)updateSubjectWithRes:(int)res resRead:(int)res_read title:(NSString*)title path:(NSString*)path dat:(int)dat;
#pragma mark Update res, title, path, dat of threadInfo
+ (BOOL)updateThreadInfoWithoutResReadWithRes:(int)res title:(NSString*)title path:(NSString*)path dat:(int)dat;
+ (void)insertSubjectWithoutResReadWithRes:(int)res title:(NSString*)title path:(NSString*)path dat:(int)dat;
+ (BOOL)updateSubjectWithoutResReadWithRes:(int)res title:(NSString*)title path:(NSString*)path dat:(int)dat;
#pragma mark Update lastOffset, date, res_read Of threadInfo where path, dat
+ (BOOL)updateLastOffset:(float)offset path:(NSString*)path dat:(int)dat res_read:(int)res_read;
#pragma mark return lastOffset of path and dat
+ (float)lastOffsetWithPath:(NSString*)path dat:(int)dat;
#pragma mark Original method
- (BOOL)hasData;
- (id)initWithDat:(int)dat path:(NSString*)path;
- (void)loadWithFILE;
- (void)writeWithFILE;
- (void)write;
@end

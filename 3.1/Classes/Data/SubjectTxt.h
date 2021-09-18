//
//  SubjectTxt.h
//  2tchfree
//
//  Created by sonson on 08/08/23.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark Global method

NSString* getDat( NSString* dat );
NSString* getThreadTitle (NSString* input);
int getThreadResNumber (NSString* input);
BOOL updateSubjectDictionary( NSMutableDictionary* dict );

@interface SubjectTxt : NSObject {
	NSMutableArray				*subjectList_;
	NSDate						*updateDate_;
	NSString					*path_;
	NSString					*keyword_;
}
@property (nonatomic, assign) NSMutableArray *subjectList;
@property (nonatomic, assign) NSDate *updateDate;
@property (nonatomic, assign) NSString *path;
@property (nonatomic, assign) NSString *keyword;

#pragma mark Class Method
+ (void) removeEvacuation;
+ (BOOL) isExistingCache:(NSString*)path;
+ (SubjectTxt*) SubjectTxtWithData:(NSData*)data path:(NSString*)path;
+ (SubjectTxt*) SubjectTxtFromCacheWithBoardPath:(NSString*)path;
+ (SubjectTxt*) RestoreFromEvacuation;
#pragma mark Original
- (NSString*) updateDateString;
- (BOOL) write;
- (BOOL) evacuate:(NSString*)keyword;

@end

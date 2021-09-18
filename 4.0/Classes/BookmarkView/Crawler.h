//
//  Crawler.h
//  2tch
//
//  Created by sonson on 08/12/27.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Dat;

@interface CrawlData : NSObject {
	NSString*	title_;
	NSString*	path_;
	int			dat_;
}
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* path;
@property (nonatomic, assign) int dat;
@end

@interface Crawler : NSObject <UIActionSheetDelegate> {
	UIProgressView	*progress_;
	UILabel			*targetLabel_;
	UILabel			*actionLabel_;
	
	NSMutableArray	*commit_;
	Dat				*currentDat_;
	float			progressStep_;
	UIActionSheet	*cancelSheet_;
	BOOL			isCanceled_;
	id				delegate_;
}
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) Dat* currentDat;
#pragma mark Original Method
- (void)makeCommitArrayWithBookmark;
- (void)show:(id)view;
- (void)tryToStartDownloadThreadWithCandidateThreadInfo;
- (void)downloadNewDat;
- (void)downloadResumeWithByte:(int)bytes lastModified:(NSString*)lastModified;
@end

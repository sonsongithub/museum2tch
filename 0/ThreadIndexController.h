#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import "invariables.h"

@interface ThreadIndexController : NSObject {
	id						threads_;
	NSMutableArray*			title_;
	NSMutableArray*			filename_;
	NSMutableArray*			resnum_;
	NSMutableArray*			titleAndResnum_;
	unsigned int*			codes_;
	NSMutableArray*			codeNames_;
}
// override
- (id) init;
- (void) dealloc;
// original method
- (NSString*) pullBoardTitles:(NSString*)url;
- (int) hasAPhrase:(NSString*)string withTargetPhrase:(NSString*)target;
- (NSMutableDictionary*) extractFileName:(NSString*)line;
- (BOOL) doProcess:(NSString*)url;
- (void) extractDataHtmlAndTitle:(NSString*) str_data;
- (id) threads;
- (id) titles;
- (id) filenames;
- (id) resnums;
@end

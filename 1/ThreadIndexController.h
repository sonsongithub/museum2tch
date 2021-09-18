#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import "global.h"

@interface ThreadIndexController : NSObject {
	NSString*				url_;
	NSString*				cacheDirectoryPath_;
	NSString*				cachePath_;
	NSString*				cacheURL_;
}
- (id) initWithURLString:(NSString*)url;
- (BOOL) reloadSubjectTxt;
- (BOOL) getSubjectTxt;
- (BOOL) checkHTMLHeader:(NSString*)str;
- (NSData*) downloadSubjectTxt;
- (NSString*) readSubjectTxtFromLocalFile;
- (int) res;
- (NSDictionary*) extractResNumber:(NSString*)str;
- (NSMutableArray*) getDataFrom:(int)from To:(int)to;
@end

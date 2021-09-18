#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import "invariables.h"

@interface ThreadController : NSObject {
	NSMutableArray*			entries_;
}
// override
- (void) dealloc;
// original method
- (BOOL) convertTheDayFromJapaneseToEnglish:(NSMutableString*)str;
- (BOOL) extractEntries:(NSData*)data;
- (BOOL) download:(NSString*)url startBytes:(int)bytes;
- (BOOL) loadURL:(NSString*)url;
- (id) getEntries;
#ifdef _DEBUG
- (BOOL) checkHead:(NSString*)url;
#endif
@end

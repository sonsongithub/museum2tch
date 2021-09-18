#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import "global.h"

@interface ThreadController : NSObject {
	NSString*				url_;
	NSString*				cachePath_;
	NSString*				dataPath_;
	NSString*				bookmarkPath_;
}
- (id) initWithURLString:(NSString*)url;
- (BOOL) updateDatFile;
- (NSMutableURLRequest*) makeRequestForAddtionalDownload;
- (NSMutableURLRequest*) makeRequestForNewDownload;
- (NSDictionary*) readDatFileFromLocal;
- (BOOL) checkDownloadedData:(NSData*)data;
- (BOOL) checkHTMLHeader:(NSString*)str;
- (BOOL) reloadCacheFile;
- (BOOL) saveData:(NSData*)data andInformation:(NSURLResponse*)response;
- (BOOL) downloadNewCacheFile;
- (int) res;
- (NSMutableArray*) getDataFrom:(int)from To:(int)to;
- (NSString*) bookmarkPath;
@end

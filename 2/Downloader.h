
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import "global.h"

@interface Downloader : NSObject {
	NSURLConnection*	connection_;
	NSMutableData*		data_;
	id					delegate_;
	BOOL				isDownloading_;
	id					response_;
	id					url_;
}
- (BOOL) respondsToSelector:(SEL) selector;
- (void) dealloc;
/*
- (id) initWithURL:(NSString*)url withDelegate:(id)fp;
*/
- (id) initWithDelegate:(id)fp;
- (void) startWithURL:(NSString*)url;
- (void) startWithURL:(NSString*)url andLastModifiedDataAndSize:(id)dict;
- (void) cancel;
- (void)outputResponse:(NSURLResponse *)response;
- (int)getContentLength:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data lengthReceived:(int)length;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (id) data;
- (id) response;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

@end

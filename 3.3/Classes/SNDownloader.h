//
//  SNDownloader.h
//  2tch
//
//  Created by sonson on 08/11/22.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SNDownloaderDelegate
- (void) didFinishLoading:(id)data;
- (void) didFinishLoading:(id)data response:(NSHTTPURLResponse*)response;
- (void) didCancelLoadingResponse:(NSHTTPURLResponse*)response;
- (void) didFailLoadingWithError:(NSError *)error;
- (void) didCacheURLLoading;
- (void) didDifferenctURLLoading;
@end

@interface SNURLConnection : NSURLConnection {
	id delegate_;
}
@end

@interface SNDownloader : NSObject {
	id					delegate_;
	SNURLConnection		*connection_;
	NSMutableData		*data_;
	int					sizeToRecieve_;
	NSURLRequest		*request_;
	NSHTTPURLResponse	*httpURLResponse_;
	UIProgressView		*progressView_;
	UIView				*progressParentView_;
}
+ (NSMutableURLRequest*)defaultRequestWithURLString:(NSString*)urlString;
- (id)initWithDelegate:(id)delegate;
- (void)cancel;
- (void)startWithRequest:(NSURLRequest*)request;
- (void) startProgressAnimation;
- (void) stopProgressAnimation;
@end

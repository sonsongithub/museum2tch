//
//  UpdateSubjectTxtOperation.h
//  2tch
//
//  Created by sonson on 08/11/26.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TitleViewController;

@interface UpdateSubjectTxtOperation : NSOperation {
	NSMutableArray		*cellData_;
	TitleViewController	*delegate_;
	NSOperationQueue	*queue_;
}
- (id)initWithMutableArray:(NSMutableArray*)input delegate:(TitleViewController*)delegate queue:(NSOperationQueue*)qq;
@end

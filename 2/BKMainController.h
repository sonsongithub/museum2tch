//
//  BKMainController.h
//  2tch
//
//  Created by sonson on 08/03/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BKMainController : NSObject {
	id	view_;
	id	bkMainView_;
	UINavigationBar *bar_;
	UINavigationBar *underBar_;
	id	bkView_;
	id	historyView_;
	
	id historyController_;
	id bookmarkController_;

}

@end

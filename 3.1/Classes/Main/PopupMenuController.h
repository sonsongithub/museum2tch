//
//  PopupMenuController.h
//  paging
//
//  Created by sonson on 08/09/03.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopupMenuCell : UIView {
	id			delegate_;
	int			number_;
	UILabel		*label_;
	UIImageView *background_;
	UIImageView *backgroundSelected_;
}
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) int number;
@property (nonatomic, assign) UILabel *label;
@end

@interface PopupMenuController : UIViewController {
	int				res_;
	int				numberOfCell_;
	NSMutableArray	*cells_;
	UILabel			*label_;
	int				selected_;
	UIView			*mainView_;
	id				delegate_;
	UISegmentedControl* segmentControl_;
}
@property (nonatomic, assign) int numberOfRes;
@property (nonatomic, assign) int numberOfCell;
@property (nonatomic, assign) NSMutableArray* cells;
@property (nonatomic, assign) UILabel *label;
@property (nonatomic, assign) UIView *mainView;
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) UISegmentedControl *segmentControl;

+ (PopupMenuController*) defaultControllerOfRes:(int)res new200:(BOOL)new200;
- (void) setMainTitleWithCellNumber:(int) num;

@end

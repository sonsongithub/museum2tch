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
	int			from_;
	int			to_;
}
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) int number;
@property (nonatomic, assign) int from;
@property (nonatomic, assign) int to;
@property (nonatomic, assign) UILabel *label;
@end

@interface PopupMenuController : UIViewController {
	int					res_;
	int					numberOfCell_;
	NSMutableArray		*cells_;
	UILabel				*label_;
	int					selected_;
	UIView				*mainView_;
	id					delegate_;
	
	UISegmentedControl	*segmentControl_;
	UILabel				*mainLabel_;
}
@property (nonatomic, assign) int numberOfRes;
@property (nonatomic, assign) int numberOfCell;
@property (nonatomic, assign) NSMutableArray* cells;
@property (nonatomic, assign) UILabel *label;
@property (nonatomic, assign) UIView *mainView;
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) UISegmentedControl *segmentControl;

- (id)init;
- (void)rebuildPopupMenu:(int)res;
- (void)dealloc;
- (void)setMainTitleWithCellNumber:(int) num;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)didReceiveMemoryWarning;

@end


#ifndef _INVARIABLES

#import <GraphicsServices/GraphicsServices.h>
#import "MyApp.h"

//#define		_DEBUG

#define		UIApp						(MyApp*)UIApp					// 

#define		TRANSITION_VIEW_FORWARD		1
#define		TRANSITION_VIEW_BACK		2

#define		READ_FROM_MENU_HTML			NSShiftJISStringEncoding		// bbsmenu.html is encoded by shift-jis
#define		OUTPUT_ENCODE_TYPE			NSUTF8StringEncoding			// output encode type is utf-8?
#define		READ_FROM_XML				NSUTF8StringEncoding
#define		OUTPUT_INTO_GUI				NSUTF8StringEncoding

#define		TITLE_ARRAY_APPEND			0
#define		HREF_ARRAY_APPEND			1
#define		CATEGORY_ARRAY_APPEND		2

#define		USER_AGENT					@"Monazilla/1.00 (iphone/0.00)"

#ifdef		_DEBUG
#define		VERSION_STRING_2CH_VIEWER	@"2chViewer version alpha\nDebug Build"
#else
#define		VERSION_STRING_2CH_VIEWER	@"2chViewer version alpha02"
#endif

#define		BOARD_URL_MENU				@"http://menu.2ch.net/bbsmenu.html"
#define		BOARD_URL_TERMINATER		@"http://count.2ch.net/?bbsmenu"

#define		DAY_OF_THE_WEEK				7

#define		THREAD_INDEX_PAGE			100

#define		THREAD_PAGE					50

#ifdef		_DEBUG
	//#define	_OUTPUT_TO_LOG
	#ifdef	_OUTPUT_TO_LOG
		void NSLogToFile( NSString *str );
		#define	DNSLog(...);			NSLogToFile([NSString stringWithFormat:__VA_ARGS__]);
	#else
		#define	DNSLog(...);			NSLog(__VA_ARGS__);
	#endif
#else
	#define DNSLog(...);				// NSLog(__VA_ARGS__);
#endif

extern NSString *kUIButtonBarButtonAction;
extern NSString *kUIButtonBarButtonInfo;
extern NSString *kUIButtonBarButtonInfoOffset;
extern NSString *kUIButtonBarButtonSelectedInfo;
extern NSString *kUIButtonBarButtonStyle;
extern NSString *kUIButtonBarButtonTag;
extern NSString *kUIButtonBarButtonTarget;
extern NSString *kUIButtonBarButtonTitle;
extern NSString *kUIButtonBarButtonTitleVerticalHeight;
extern NSString *kUIButtonBarButtonTitleWidth;
extern NSString *kUIButtonBarButtonType;

#endif
#import <SpringBoard/SBMediaController.h>
#import <SpringBoard/SBControlCenterController.h>
#import <SpringBoard/SBControlCenterViewController.h>

@interface SBPagedScrollView : UIScrollView
@property (assign,nonatomic) unsigned long long currentPageIndex;
- (BOOL)scrollToPageAtIndex:(unsigned long long)arg1 animated:(BOOL)arg2;
@end

@interface SBUIChevronView : UIView
- (void)setState:(long long)state;
@end

@interface SBNotificationCenterViewController : UIViewController
@property (nonatomic,readonly) SBUIChevronView *grabberView;
@end

@interface SPUINavigationBar : UIView
@end

@interface SBSearchEtceteraNavigationController : UIViewController
@end

@interface SBSearchEtceteraTodayLayoutContentView : UIView
@property (nonatomic, assign, readwrite) CGFloat navigationBarTopInset;
@end

@protocol NCNotificationSectionList <NSObject>
@required
-(unsigned long long)sectionCount;
@end

@interface NCNotificationChronologicalList : NSObject <NCNotificationSectionList>
@property (nonatomic, retain) NSMutableArray *sections;
@end


#define prefPath [NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), @"se.nosskirneh.lace.plist"]

static NSDictionary *prefs;
static SBPagedScrollView *pagedScrollView;
static id<NCNotificationSectionList> notificationList;
static SPUINavigationBar *searchNavBar;
static UIView *layoutContainerView;


void updateSettings(CFNotificationCenterRef center,
                    void *observer,
                    CFStringRef name,
                    const void *object,
                    CFDictionaryRef userInfo) {
    prefs = [[NSDictionary alloc] initWithContentsOfFile:prefPath];
}


/* Notification Centre */
%hook SBUIChevronView

- (void)setState:(long long)state {
    if ((prefs[@"enabled"] && ![prefs[@"enabled"] boolValue]) ||
        ![prefs[@"CustomChevronIconEnabled"] boolValue]) {
        return %orig;
    }

    %orig([prefs[@"CustomChevronIcon"] integerValue]);
}

%end


%hook SBNotificationCenterViewController

// Prevents stuttering animation between page control and chevron
- (void)_updateGrabberAndPageControlForMode:(NSUInteger)arg {
    return;
}

- (BOOL)shouldPlayFeedbackForNewTouchLocation:(CGPoint)point velocity:(CGPoint)speed {
    if (prefs[@"enabled"] && ![prefs[@"enabled"] boolValue])
        return %orig;

    // Set custom chevron state
    if ([prefs[@"CustomChevronIconEnabled"] boolValue] &&
        prefs[@"CustomChevronIcon"])
        [self.grabberView setState:-2]; // Dummy value, will be overwritten in method

    // Scroll to page
    int page = pagedScrollView.currentPageIndex;
    BOOL animated = NO;

    if ([prefs[@"DefaultSectionEnabled"] boolValue]) {
        page = [prefs[@"DefaultSection"] integerValue];
    } else if ([prefs[@"Automode"] boolValue]) {
        page = notificationList.sectionCount > 0 ? 1 : 0;
    } else if (!prefs[@"ChangeWhileDragging"] ||
               [prefs[@"ChangeWhileDragging"] boolValue]) {
        animated = YES;
        CGFloat width = [UIScreen mainScreen].bounds.size.width;

        if (point.x < width / 2.0f) { // Left
            page = 0;
        } else { // Right
            page = 1;
        }
    }

    if (pagedScrollView.currentPageIndex != page) {
        [pagedScrollView scrollToPageAtIndex:page animated:animated];
        pagedScrollView.currentPageIndex = page;
    }

    return %orig;
}

- (void)viewWillAppear:(BOOL)arg {
    %orig;

    if (prefs[@"enabled"] && ![prefs[@"enabled"] boolValue] &&
        searchNavBar.hidden) {
        // Restore hidden if tweak is no longer enabled
        [searchNavBar setHidden:NO];
        return;
    }

    if ([prefs[@"HideSearch"] boolValue]) {
        [searchNavBar setHidden:YES];

        [layoutContainerView setFrame:(CGRectMake(layoutContainerView.frame.origin.x,
                                                  layoutContainerView.frame.origin.y + 20,
                                                  layoutContainerView.frame.size.width,
                                                  layoutContainerView.frame.size.height - 20))];
    } else {
        [searchNavBar setHidden:NO];
    }
}

- (void)viewWillDisappear:(BOOL)arg {
    %orig;

    // Unhide in order to be visible with Spotlight
    [searchNavBar setHidden:NO];
}

%end


%hook SBSearchEtceteraTodayLayoutContentView

- (void)setNavigationBarTopInset:(CGFloat)inset {
    if (self.navigationBarTopInset != 0 &&
        inset != self.navigationBarTopInset &&
        prefs[@"enabled"] && [prefs[@"enabled"] boolValue] &&
        [prefs[@"HideSearch"] boolValue]) {
        return;
    }

    %orig;
}

%end


%hook NCNotificationSectionListViewController

- (void)setSectionList:(id)arg1 {
    %orig;
    notificationList = arg1;
}

%end

%hook NCNotificationChronologicalList

- (id)init {
    return notificationList = %orig;
}

%end


%hook SBPagedScrollView

- (id)initWithFrame:(CGRect)frame {
    if (!pagedScrollView && CGRectIsEmpty(frame)) {
        return pagedScrollView = %orig;
    }
    return %orig;
}

%end


%hook SBSearchEtceteraNavigationController

- (void)viewDidLoad {
    %orig;

    layoutContainerView = self.view;
}

%end


%hook SPUINavigationBar

- (id)initWithFrame:(CGRect)frame {
    return searchNavBar = %orig;
}

%end


/* Control Centre */
@interface SBControlCenterController (Addition)
@property (nonatomic, assign) NSInteger currentPage;
@end

%hook SBControlCenterController

%property (nonatomic, assign) NSInteger currentPage;

- (void)setPresented:(BOOL)presented {
    %orig;
    self.currentPage = -2;
}

- (void)_updateTransitionWithTouchLocation:(CGPoint)point velocity:(CGPoint)velocity {
    if (prefs[@"enabledCC"] && ![prefs[@"enabledCC"] boolValue])
        return %orig;

    // Scroll to page
    int page = -1;
    BOOL animated = NO;

    if ([prefs[@"DefaultSectionEnabledCC"] boolValue]) {
        page = [prefs[@"DefaultSectionCC"] integerValue];
    } else if ([prefs[@"AutomodeCC"] boolValue]) {
        page = [[%c(SBMediaController) sharedInstance] nowPlayingApplication] ? 1 : 0;
    } else if (!prefs[@"ChangeWhileDraggingCC"] ||
               [prefs[@"ChangeWhileDraggingCC"] boolValue]) {
        animated = YES;
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        page = point.x / width * [self numberOfActivePages];
    }

    if (page != -1 && self.currentPage != page) {
        [self scrollToPage:page animated:animated withCompletion:nil];
        self.currentPage = page;
    }

    %orig;
}

%end


%ctor {
    // Init settings file
    prefs = [[NSDictionary alloc] initWithContentsOfFile:prefPath];
    if (!prefs) prefs = [[NSMutableDictionary alloc] init];

    // Add observer to update settings    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &updateSettings, CFStringRef(@"se.nosskirneh.lace/preferencesChanged"), NULL, 0);
}

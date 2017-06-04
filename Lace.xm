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

@interface NCNotificationChronologicalList : NSObject
@property (nonatomic, retain) NSMutableArray *sections;
@end

@interface SPUINavigationBar : UIView
@end

@interface SBSearchEtceteraNavigationController : UIViewController
@end


#define prefPath [NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), @"se.nosskirneh.lace.plist"]

static NSDictionary *preferences;
static SBPagedScrollView *pagedScrollView;
static NCNotificationChronologicalList *notificationList;
static SPUINavigationBar *searchNavBar;
static UIView *layoutContainerView;
static SBSearchEtceteraTodayLayoutContentView *todayContentView;


void updateSettings(CFNotificationCenterRef center,
                    void *observer,
                    CFStringRef name,
                    const void *object,
                    CFDictionaryRef userInfo) {
    preferences = [[NSDictionary alloc] initWithContentsOfFile:prefPath];
}

%hook SBUIChevronView

- (void)setState:(long long)state {
    if (![preferences[@"enabled"] boolValue] || ![preferences[@"CustomChevronIconEnabled"] boolValue] || !preferences[@"CustomChevronIcon"]) {
        return %orig;
    }

    %orig([preferences[@"CustomChevronIcon"] integerValue]);
}

%end


%hook SBNotificationCenterViewController

// Prevents stuttering animation between page control and chevron
- (void)_updateGrabberAndPageControlForMode:(NSUInteger)arg {
    return;
}

- (BOOL)shouldPlayFeedbackForNewTouchLocation:(CGPoint)point velocity:(CGPoint)speed {
    if (![preferences[@"enabled"] boolValue]) {
        return %orig;
    }

    // Set custom state
    if ([preferences[@"CustomChevronIconEnabled"] boolValue] && preferences[@"CustomChevronIcon"]) {
        [self.grabberView setState:-2]; // Dummy value, will be overwritten in method
    }

    // Scroll to page
    int page = pagedScrollView.currentPageIndex;
    BOOL animated = NO;

    if ([preferences[@"DefaultSectionEnabled"] boolValue]) {
        page = [preferences[@"DefaultSection"] integerValue];
    } else if ([preferences[@"Automode"] boolValue]) {
        page = notificationList.sections.count > 0 ? 1 : 0;
    } else if ([preferences[@"ChangeWhileDragging"] boolValue]) {
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

    if (![preferences[@"enabled"] boolValue]) {
        return;
    }

    if ([preferences[@"HideSearch"] boolValue]) {
        [searchNavBar setHidden:YES];

        [layoutContainerView setFrame:(CGRectMake(layoutContainerView.frame.origin.x,
                                                  layoutContainerView.frame.origin.y + 20,
                                                  layoutContainerView.frame.size.width,
                                                  layoutContainerView.frame.size.height - 20))];
    } else {
        [searchNavBar setHidden:NO];
    }
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


%ctor {
    // Init settings file
    preferences = [[NSDictionary alloc] initWithContentsOfFile:prefPath];
    if (!preferences) preferences = [[NSMutableDictionary alloc] init];

    // Add observer to update settings    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &updateSettings, CFStringRef(@"se.nosskirneh.lace/preferencesChanged"), NULL, 0);
}

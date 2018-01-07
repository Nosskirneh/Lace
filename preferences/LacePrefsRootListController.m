#import <Preferences/PSListController.h>
#import <Preferences/PSControlTableCell.h>
#import <Preferences/PSSpecifier.h>

#define prefPath [NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), @"se.nosskirneh.lace.plist"]
#define LaceColor [UIColor colorWithRed:0.73 green:0.06 blue:0.58 alpha:1.0]
#define BatteryUsageUIBundle [NSBundle bundleWithPath:@"/System/Library/PreferenceBundles/BatteryUsageUI.bundle/"]


@interface UIImage (Private)
+ (id)imageNamed:(id)arg1 inBundle:(id)arg2;
@end


@interface LacePrefsRootListController : PSListController {
    UIWindow *settingsView;
}
@end

@implementation LacePrefsRootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
    }

    // Set icons for groups
    PSSpecifier *spec = _specifiers[1];
    UIImage *img = [UIImage imageNamed:@"NotificationCenter.png" inBundle:BatteryUsageUIBundle];
    [spec setProperty:img forKey:@"iconImage"];

    spec = _specifiers[2];
    img = [UIImage imageNamed:@"ControlCenter.png" inBundle:BatteryUsageUIBundle];
    [spec setProperty:img forKey:@"iconImage"];

    return _specifiers;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Tint
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = LaceColor;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // Restore tint
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = nil;
}

- (void)donate {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/nosskirneh"]];
}

@end


// Header
@interface LaceHeaderCell : PSTableCell {
    UILabel *_label;
}
@end

@implementation LaceHeaderCell
- (id)initWithSpecifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"headerCell" specifier:specifier];
    if (self) {
        _label = [[UILabel alloc] initWithFrame:[self frame]];
        [_label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_label setAdjustsFontSizeToFitWidth:YES];
        [_label setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:48]];
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Lace"];
        
        [_label setAttributedText:attributedString];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [_label setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:_label];
        [self setBackgroundColor:[UIColor clearColor]];
        
        // Setup constraints
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        [self addConstraints:[NSArray arrayWithObjects:leftConstraint, rightConstraint, bottomConstraint, topConstraint, nil]];
    }
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
    // Return a custom cell height.
    return 140.f;
}
@end

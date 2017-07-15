#import <Preferences/PSListController.h>
#import <Preferences/PSControlTableCell.h>
#import <Preferences/PSSpecifier.h>

#define prefPath [NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), @"se.nosskirneh.lace.plist"]
#define LaceColor [UIColor colorWithRed:0.73 green:0.06 blue:0.58 alpha:1.0]

@interface LacePrefsRootListController : PSListController {
    UIWindow *settingsView;
}
@end

@implementation LacePrefsRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

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

- (void)setCellForRowAtIndexPath:(NSIndexPath *)indexPath enabled:(BOOL)enabled {
    UITableViewCell *cell = [self tableView:self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
    if (cell) {
        cell.userInteractionEnabled = enabled;
        cell.textLabel.enabled = enabled;
        cell.detailTextLabel.enabled = enabled;
        
        if ([cell isKindOfClass:[PSControlTableCell class]]) {
            PSControlTableCell *controlCell = (PSControlTableCell *)cell;
            if (controlCell.control) {
                controlCell.control.enabled = enabled;
            }
        }
    }
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:prefPath];

    NSString *key = [specifier propertyForKey:@"key"];
    if (!preferences[key]) {
        return specifier.properties[@"default"];
    }

    BOOL enableCell = [[preferences objectForKey:key] boolValue];
    if ([key isEqualToString:@"enabled"]) {
        // Hide Search Bar
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] enabled:enableCell];

        // Change While Dragging
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] enabled:enableCell];

        // Automode
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] enabled:enableCell];

        // Default Section
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:4] enabled:enableCell];

        // Only reenable DefaultSection cell if DefaultSectionEnabled is enabled
        if (![preferences[@"DefaultSectionEnabled"] boolValue]) {
            [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:4] enabled:NO];
        } else {
            [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:4] enabled:enableCell];
        }

        // Chevron
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:5] enabled:enableCell];

        // Only reenable Chevron cell if CustomChevronIconEnabled is enabled
        if (![preferences[@"CustomChevronIconEnabled"] boolValue]) {
            [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:5] enabled:NO];
        } else {
            [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:5] enabled:enableCell];
        }

    } else if ([preferences[@"enabled"] boolValue]) {
        if ([key isEqualToString:@"Automode"]) {
            if ([preferences[@"DefaultSectionEnabled"] boolValue]) {
                [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] enabled:NO];
            } else {
                [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] enabled:!enableCell];   
            }

        } else if ([key isEqualToString:@"DefaultSectionEnabled"]) {
            // Disable Change While Dragging
            [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] enabled:!enableCell];
            // Disable Automode
            [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] enabled:!enableCell];
            // Enable DefaultSection cell
            [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:4] enabled:enableCell];

        } else if ([key isEqualToString:@"CustomChevronIconEnabled"]) {
            // Enable Chevron icon cell
            [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:5] enabled:enableCell];
        }
    }

    return preferences[key];
}


- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSMutableDictionary *preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    if (!preferences) preferences = [[NSMutableDictionary alloc] init];
    NSString *key = [specifier propertyForKey:@"key"];

    [preferences setObject:value forKey:key];
    [preferences writeToFile:prefPath atomically:YES];

    if ([key isEqualToString:@"enabled"]) {
        // Hide Search Bar
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] enabled:[value boolValue]];

        // Change While Dragging
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] enabled:[value boolValue]];

        // Automode
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] enabled:[value boolValue]];

        // Default Section enable
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:4] enabled:[value boolValue]];

        // Only reenable Section cell if DefaultSectionEnabled is enabled
        if (![preferences[@"DefaultSectionEnabled"] boolValue]) {
            [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:4] enabled:NO];
        } else {
            [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:4] enabled:[value boolValue]];
        }

        // Chevron enable
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:5] enabled:[value boolValue]];

        // Only reenable Chevron cell if CustomChevronIconEnabled is enabled
        if (![preferences[@"CustomChevronIconEnabled"] boolValue]) {
            [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:5] enabled:NO];
        } else {
            [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:5] enabled:[value boolValue]];
        }
    } else if ([key isEqualToString:@"Automode"]) {
        // Disable Change While Dragging
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] enabled:![value boolValue]];

    } else if ([key isEqualToString:@"DefaultSectionEnabled"]) {
        // Disable Change While Dragging
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] enabled:![value boolValue]];
        // Disable Automode
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] enabled:![value boolValue]];
        // Enable DefaultSection cell
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:4] enabled:[value boolValue]];
        
    } else if ([key isEqualToString:@"CustomChevronIconEnabled"]) {
        // Enable Chevron icon cell
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:5] enabled:[value boolValue]];
    }

    [preferences writeToFile:prefPath atomically:YES];

    CFStringRef post = (CFStringRef)CFBridgingRetain(specifier.properties[@"PostNotification"]);
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), post, NULL, NULL, YES);
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

// Colorful UISwitches
@interface PSSwitchTableCell : PSControlTableCell
- (id)initWithStyle:(int)style reuseIdentifier:(id)identifier specifier:(id)specifier;
@end

@interface LaceSwitchTableCell : PSSwitchTableCell
@end

@implementation LaceSwitchTableCell

- (id)initWithStyle:(int)style reuseIdentifier:(id)identifier specifier:(id)specifier {
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];
    if (self) {
        [((UISwitch *)[self control]) setOnTintColor:LaceColor];
    }
    return self;
}

@end

//
//  ContactPickerTextView.h
//  ContactPicker
//
//  Created by Tristan Himmelman on 11/2/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THContactBubble.h"
#import "THContact.h"

@class THContactPickerView;

@protocol THContactPickerDelegate <NSObject>

- (void)contactPickerTextViewDidChange:(NSString *)textViewText;
- (void)contactPickerDidRemoveContact:(id)contact;
- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView;
- (void)contactPickerTextViewWasEnabled:(BOOL)enabled;
- (void)contactPickerAddContactButtonClicked;
- (void)keyboardReturnClicked;
- (void)contactPickerAddContact:(THContact *)contact;

@end

@interface THContactPickerView : UIView <UITextViewDelegate, THContactBubbleDelegate, UIScrollViewDelegate, UITextInputTraits>

@property (nonatomic, strong) THContactBubble *selectedContactBubble;
@property (nonatomic, assign) IBOutlet id <THContactPickerDelegate>delegate;
@property (nonatomic, assign) BOOL limitToOne;
@property (nonatomic, assign) CGFloat verticalPadding;
@property (nonatomic, strong) UIFont *font;

- (void)addContact:(id)contact withName:(NSString *)name;
- (void)removeContact:(id)contact;
- (void)removeAllContacts;
- (void)resignFirstResponder;

// View Customization
- (void)setBubbleStyle:(THBubbleStyle *)color selectedStyle:(THBubbleStyle *)selectedColor;
- (void)setPlaceholderLabelText:(NSString *)text;
- (void)setPlaceholderTextColor:(UIColor *)placeholderColor;
- (void)setSelectedTextColor:(UIColor *)selectedTextColor;
- (void)setPromptLabelText:(NSString *)text;
- (void)setFont:(UIFont *)font;
- (void)setUnselectedFontColor:(UIColor *)unselectedColor;
- (void)addContactButtonImage:(UIImage *)addContactImage;

// View control
-(void)close;
-(void)open;

//helpers
-(void)clearTextView;

@end

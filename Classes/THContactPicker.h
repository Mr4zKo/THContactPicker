//
//  THContactPicker.h
//  Pods
//
//  Created by Michal Mrazik on 14/08/14.
//
//

#import <Foundation/Foundation.h>
#import "THContactPickerView.h"
#import "THContact.h"

@protocol THContactPickerNotifDelegate
-(void)contactPickerUpdatedHeight;
-(void)contactPickerAddContactButtonClicked;
-(void)contactPickerAddedContact;

@end

@interface THContactPicker : NSObject <THContactPickerDelegate, UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, assign) id<THContactPickerNotifDelegate>delegate;

@property(nonatomic, assign) THContactPickerView *contactPickerView;
@property(nonatomic, assign) UITableView *contactsTableView;
@property(nonatomic, assign) UIView *view;

-(id)initWithContactPickerView:(THContactPickerView *)contactPickerView
            contactsScrollView:(UITableView *)tableView
                    parentView:(UIView *)parentView;

- (void)adjustTableFrame;

- (void)closeContactPicker;
- (void)openContactPicker;

- (void)addContact:(THContact *)contact;

- (void)clear;
- (NSUInteger)selectedContactsCount;
- (NSArray *)selectedContacts;

- (void)refreshContacts;

@end

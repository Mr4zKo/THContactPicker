//
//  THContactPicker.h
//  Pods
//
//  Created by Michal Mrazik on 14/08/14.
//
//

#import <Foundation/Foundation.h>
#import "THContactPickerView.h"

@interface THContactPicker : NSObject <THContactPickerDelegate, UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, assign) THContactPickerView *contactPickerView;
@property(nonatomic, assign) UITableView *contactsTableView;
@property(nonatomic, assign) UIView *view;

-(id)initWithContactPickerView:(THContactPickerView *)contactPickerView
            contactsScrollView:(UITableView *)tableView
                    parentView:(UIView *)parentView;

- (void)adjustTableFrame;

@end

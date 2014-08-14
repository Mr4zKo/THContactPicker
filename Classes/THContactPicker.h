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

@property(nonatomic, strong) THContactPickerView *contactPickerView;
@property(nonatomic,strong) UITableView *contactsTableView;
@property(nonatomic, strong) UIView *view;

-(id)initWithContactPickerView:(THContactPickerView *)contactPickerView
            contactsScrollView:(UITableView *)tableView
                    parentView:(UIView *)parentView;

@end

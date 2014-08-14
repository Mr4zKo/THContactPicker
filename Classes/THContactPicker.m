//
//  THContactPicker.m
//  Pods
//
//  Created by Michal Mrazik on 14/08/14.
//
//

#import "THContactPicker.h"
#import "THContact.h"
#import "THContactTableViewCell.h"
#import <AddressBook/AddressBook.h>

@interface THContactPicker()

@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSMutableArray *privateSelectedContacts;
@property (nonatomic, strong) NSArray *filteredContacts;

@end

@implementation THContactPicker

NSString *THContactPickerContactCellReuseID = @"THContactPickerContactCell";

-(id)initWithContactPickerView:(THContactPickerView *)contactPickerView
             contactsScrollView:(UITableView *)tableView
             parentView:(UIView *)parentView;{
    
    if(self = [super init]){
        self.privateSelectedContacts = [[NSMutableArray alloc] init];
        self.contactPickerView = contactPickerView;
        [self.contactPickerView setHidden:NO];
        
        self.contactsTableView = tableView;
        [self.contactsTableView setHidden:NO];
        
        self.view = parentView;
        
        [self setDelegatesFillWithData];
    }
    
    return self;
}

-(void)setDelegatesFillWithData{
    self.contacts = [self contactsFromAddressBook];
    [self.contactPickerView setDelegate:self];
    [self.contactsTableView setDelegate:self];
    [self.contactsTableView setDataSource:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - THContactPickerDelegate

- (void)contactPickerTextViewDidChange:(NSString *)textViewText{
    if ([textViewText isEqualToString:@""]){
        self.filteredContacts = self.contacts;
    } else {
        self.filteredContacts = [self filteredContactsByText:textViewText];
    }
    [self.contactsTableView reloadData];
}

-(NSArray *)filteredContactsByText:(NSString *)text{
    NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
    for(THContact *contact in self.contacts){
        if([contact matchesFilterString:text]){
            [filteredArray addObject:contact];
        }
    }
    
    return filteredArray;
}

- (void)contactPickerDidRemoveContact:(id)contact{
    [self.privateSelectedContacts removeObject:contact];
    
    NSInteger index = [self.contacts indexOfObject:contact];
    UITableViewCell *cell = [self.contactsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryNone;
    [self didChangeSelectedItems];
}

- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView{
    CGRect frame = self.contactsTableView.frame;
    frame.origin.y = contactPickerView.frame.size.height + contactPickerView.frame.origin.y;
    self.contactsTableView.frame = frame;
}

#pragma mark - UITableView Delegate and Datasource functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredContacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    THContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:THContactPickerContactCellReuseID];
    
    if (cell == nil){
        cell = [[THContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THContactPickerContactCellReuseID];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    if ([self.privateSelectedContacts containsObject:[self.filteredContacts objectAtIndex:indexPath.row]]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    id contact = [self.filteredContacts objectAtIndex:indexPath.row];
    NSString *contactTilte = [self titleForRowAtIndexPath:indexPath];
    
    if(![self.privateSelectedContacts containsObject:contact]){
        [self.privateSelectedContacts addObject:contact];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.contactPickerView addContact:contact withName:contactTilte];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.contactPickerView resignFirstResponder];
}

#pragma mark - Public properties

- (NSArray *)filteredContacts {
    if (!_filteredContacts) {
        _filteredContacts = _contacts;
    }
    return _filteredContacts;
}

- (void)adjustTableViewInsetTop:(CGFloat)topInset bottom:(CGFloat)bottomInset {
    self.contactsTableView.contentInset = UIEdgeInsetsMake(topInset,
                                                   self.contactsTableView.contentInset.left,
                                                   bottomInset,
                                                   self.contactsTableView.contentInset.right);
    self.contactsTableView.scrollIndicatorInsets = self.contactsTableView.contentInset;
}

- (NSInteger)selectedCount {
    return self.privateSelectedContacts.count;
}

- (void)adjustTableFrame {
    CGFloat yOffset = self.contactPickerView.frame.origin.y + self.contactPickerView.frame.size.height;
    
    CGRect tableFrame = CGRectMake(0, yOffset, self.view.frame.size.width, self.view.frame.size.height - yOffset);
    self.contactsTableView.frame = tableFrame;
}

#pragma mark - Private methods

- (void)adjustTableViewInsetTop:(CGFloat)topInset {
    [self adjustTableViewInsetTop:topInset bottom:self.contactsTableView.contentInset.bottom];
}

- (void)adjustTableViewInsetBottom:(CGFloat)bottomInset {
    [self adjustTableViewInsetTop:self.contactsTableView.contentInset.top bottom:bottomInset];
}

- (void)configureCell:(THContactTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [cell.nameLabel setText:[self titleForRowAtIndexPath:indexPath]];
    [cell.numberLabel setText:[self phoneNumberForRowAtIndexPath:indexPath]];
}

- (NSString *)titleForRowAtIndexPath:(NSIndexPath *)indexPath {
    THContact *contact = [self.filteredContacts objectAtIndex:indexPath.row];
    return [contact name];
}

- (NSString *)phoneNumberForRowAtIndexPath:(NSIndexPath *)indexPath {
    THContact *contact = [self.filteredContacts objectAtIndex:indexPath.row];
    return [[contact phoneNumbers] objectAtIndex:0];
}

- (void) didChangeSelectedItems {
    
}

#pragma  mark - AddressBook
-(NSArray *)contactsFromAddressBook{
    NSLog(@"v kontaktoch");
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if(granted){
                NSLog(@"access granted");
            }else{
                NSLog(@"access not granted");
            }
        });
    }
    
    CFArrayRef all = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex n = ABAddressBookGetPersonCount(addressBook);
    
    NSMutableArray *contactsArray = [[NSMutableArray alloc] init];
    
    for( int i = 0 ; i < n ; i++ ){
        ABRecordRef ref = CFArrayGetValueAtIndex(all, i);
        
        NSString* compositeName = (__bridge_transfer NSString *)ABRecordCopyCompositeName(ref);
        
        CFTypeRef phoneProperty = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        NSArray *phones = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(phoneProperty);
        CFRelease(phoneProperty);
        for (NSString *phone in phones){
            THContact *contact = [[THContact alloc] init];
            [contact setName:compositeName];
            [contact addPhoneNumber:phone];
            [contactsArray addObject:contact];
        }
    }
    
    CFRelease(addressBook);
    CFRelease(all);
    
    
    return contactsArray;
}

#pragma  mark - NSNotificationCenter
- (void)keyboardDidShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kbRect = [self.view convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
    [self adjustTableViewInsetBottom:self.contactsTableView.frame.origin.y + self.contactsTableView.frame.size.height - kbRect.origin.y];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kbRect = [self.view convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
    [self adjustTableViewInsetBottom:self.contactsTableView.frame.origin.y + self.contactsTableView.frame.size.height - kbRect.origin.y];
}

@end

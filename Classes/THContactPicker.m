//
//  THContactPicker.m
//  Pods
//
//  Created by Michal Mrazik on 14/08/14.
//
//

#import "THContactPicker.h"
#import "THContactTableViewCell.h"
#import <AddressBook/AddressBook.h>
@import AddressBookUI;

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
        [self.contactsTableView setHidden:YES];
        
        self.view = parentView;
        
        [self setDelegatesFillWithData];
    }
    
    return self;
}

-(void)setDelegatesFillWithData{
    
    [self refreshContacts];
    
    [self.contactPickerView setDelegate:self];
    [self.contactsTableView setDelegate:self];
    [self.contactsTableView setDataSource:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)refreshContacts{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, NULL);
    ABAuthorizationStatus authorizationStatus = ABAddressBookGetAuthorizationStatus();
    
    if (authorizationStatus == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if(granted){
                
                self.contacts = [self contactsFromAddressBook];
            }else{
                
            }
        });
    }else if(authorizationStatus == kABAuthorizationStatusAuthorized){
        self.contacts = [self contactsFromAddressBook];
    }else{
        self.contacts = [[NSArray alloc] init];
    }
    
    [self refreshSelectedContacts];
    [self.contactsTableView reloadData];
}

-(void)refreshSelectedContacts{
    for(THContact *cont in self.privateSelectedContacts){
        if([cont.name isEqualToString:cont.phoneNumber]){
            THContact *finalContact = [self contactConsiderJustNumber:cont];
            if(![finalContact isEqual:cont]){
                [cont setName:finalContact.name];
            }
        }
        
    }
    
    NSArray *contactsToAdd = [NSArray arrayWithArray:self.privateSelectedContacts];
    [self clear];
    for(THContact *contact in contactsToAdd){
        [self addContact:contact];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - THContactPickerDelegate

- (void)contactPickerTextViewDidChange:(NSString *)textViewText{
    if ([textViewText isEqualToString:@""]|| textViewText==nil){
        self.filteredContacts = self.contacts;
        [self.contactsTableView setHidden:YES];
    } else {
        self.filteredContacts = [self filteredContactsByText:textViewText];
        
        if(self.filteredContacts.count>0){
            [self.contactsTableView setHidden:NO];
        }else{
            [self.contactsTableView setHidden:YES];
            [self.contactPickerView allowAddUnknownContact];
        }
    }
    
    [self.contactsTableView setFrame:CGRectMake(self.contactsTableView.frame.origin.x,
                                                [self contactsTableVerticalPosition],
                                                self.contactsTableView.frame.size.width,
                                                [self contactsTableHeight])];
    
    [self.delegate contactPickerUpdatedHeight];
    [self.contactsTableView reloadData];
}

-(NSArray *)filteredContactsByText:(NSString *)text{
    NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
    NSString *textNoDiacritics = [THContact removeDiacritics:text];
    for(THContact *contact in self.contacts){
        if([contact matchesFilterString:textNoDiacritics]){
            [filteredArray addObject:contact];
        }
    }
    
    return filteredArray;
}

-(void)bubbleWasSelected{
    //#1532
    [self.contactsTableView setHidden:YES];
}

- (void)contactPickerDidRemoveContact:(id)contact{
    [self.privateSelectedContacts removeObject:contact];
    
    NSInteger index = [self.contacts indexOfObject:contact];
    UITableViewCell *cell = [self.contactsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView{
    CGRect frame = self.contactsTableView.frame;
    frame.origin.y = contactPickerView.frame.size.height + contactPickerView.frame.origin.y;
    frame.size.height = [self contactsTableHeight];
    self.contactsTableView.frame = frame;
    [self.delegate contactPickerUpdatedHeight];
}

- (void)contactPickerAddContactButtonClicked{
    [self.contactsTableView setHidden:YES];
    [self.delegate contactPickerAddContactButtonClicked];
}

- (void)keyboardReturnClicked{
    [self.contactPickerView clearTextView];
    [self closeContactPicker];
}

- (void)contactPickerAddContact:(THContact *)contact{
    [self addContact:contact];
}

- (void)showViewController:(id)contactKey{
    
    THContact *contact = contactKey;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, NULL);
    
    CFArrayRef all = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex n = ABAddressBookGetPersonCount(addressBook);
    
    for( int i = 0 ; i < n ; i++ ){
        ABRecordRef ref = CFArrayGetValueAtIndex(all, i);
        
        NSString* compositeName = (__bridge_transfer NSString *)ABRecordCopyCompositeName(ref);
        if(compositeName==nil) compositeName=@"";
        
        if(![compositeName isEqualToString:[contact name]]) continue;
        
        CFTypeRef phoneProperty = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        
        NSArray *phones = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(phoneProperty);
        
        int counter = -1;
        for (NSString *phone in phones){
            counter++;
            if(![phone isEqualToString:[contact phoneNumber]]) continue;
            
                        NSString *type;
                        CFStringRef refString = ABMultiValueCopyLabelAtIndex(phoneProperty, counter);
                        if(refString!=NULL){
                            type = (__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(refString);
                            CFRelease(refString);
                            if(![[contact type] isEqualToString:type]) continue;
            
                        }else{
                            type = @"Phone";
                        }
            
            ABPersonViewController *picker = [[ABPersonViewController alloc] init];
            picker.displayedPerson = ref;
            // Allow users to edit the person’s information
            picker.allowsEditing = NO;
            picker.editing = NO;
            [picker setHighlightedItemForProperty:kABPersonPhoneProperty withIdentifier:counter];
            
            [self.delegate contactPickerShowViewController:picker];
            
            CFRelease(phoneProperty);
            CFRelease(addressBook);
            CFRelease(all);
            return;
        }
        
        
        CFRelease(phoneProperty);
    }
    
    CFRelease(addressBook);
    CFRelease(all);
    
    // if it gets here compare just normalized phone numbers
    [self showViewControllerConsiderJustNormalizedPhoneNumbers:contactKey];
}

// ak not contact found regulary, try to find contact just by number
- (void)showViewControllerConsiderJustNormalizedPhoneNumbers:(id)contactKey{
    
    THContact *contact = contactKey;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, NULL);
    
    CFArrayRef all = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex n = ABAddressBookGetPersonCount(addressBook);
    
    for( int i = 0 ; i < n ; i++ ){
        ABRecordRef ref = CFArrayGetValueAtIndex(all, i);
        
        CFTypeRef phoneProperty = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        
        NSArray *phones = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(phoneProperty);
        
        int counter = -1;
        for (NSString *phone in phones){
            counter++;
            
            NSString *normalizedPhone = [THContactPicker normalizeTelephoneNumber:phone];
            NSString *normalizedContactPhone = [THContactPicker normalizeTelephoneNumber:[contact phoneNumber]];
            
            if(![normalizedPhone isEqualToString:normalizedContactPhone]) continue;
            
            ABPersonViewController *picker = [[ABPersonViewController alloc] init];
            picker.displayedPerson = ref;
            // Allow users to edit the person’s information
            picker.allowsEditing = NO;
            picker.editing = NO;
            [picker setHighlightedItemForProperty:kABPersonPhoneProperty withIdentifier:counter];
            
            [self.delegate contactPickerShowViewController:picker];
            
            CFRelease(phoneProperty);
            CFRelease(addressBook);
            CFRelease(all);
            return;
        }
        
        
        CFRelease(phoneProperty);
    }
    
    CFRelease(addressBook);
    CFRelease(all);
    
    [self.delegate contactPickerShowAddUnknownNumberIntoContacts:contact];
}

#pragma mark - UITableView Delegate and Datasource functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //to not show checked in list
    BOOL wasChanged = [self removeSelectedFromFilteredContacts];
    if(self.filteredContacts.count==0){
        [self.contactsTableView setHidden:YES];
    }
    
    return self.filteredContacts.count;
}

//#1538
-(BOOL)removeSelectedFromFilteredContacts{
    NSMutableArray *fcArray = [[NSMutableArray alloc] init];
    for(THContact *contact in self.filteredContacts){
        if(![self.privateSelectedContacts containsObject:contact]){
            [fcArray addObject:contact];
        }
    }
    
    BOOL changed = NO;
    if(self.filteredContacts.count!=fcArray.count) changed = YES;
    
    self.filteredContacts = fcArray;
    
    return changed;
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
    NSString *contactTilte = [(THContact *)contact name];
    if([contactTilte isEqualToString:@""]){
        if([((THContact *)contact).phoneNumbers count]>0){
            contactTilte = [((THContact *)contact).phoneNumbers objectAtIndex:0];
        }
    }
    
    if(![self.privateSelectedContacts containsObject:contact]){
        [self.privateSelectedContacts addObject:contact];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.contactPickerView addContact:contact withName:contactTilte];
        [self.delegate contactPickerAddedContact];
    }
    
    self.filteredContacts = self.contacts;
    [self.contactsTableView reloadData];
    [self.contactsTableView setHidden:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.contactPickerView resignFirstResponderShouldntAddContact];
}

#pragma mark - Public properties

- (NSArray *)filteredContacts {
    if (!_filteredContacts) {
        _filteredContacts = _contacts;
    }
    return _filteredContacts;
}

- (NSInteger)selectedCount {
    return self.privateSelectedContacts.count;
}

- (void)adjustTableFrame {
    CGFloat yOffset = [self contactsTableVerticalPosition];
    
    CGRect tableFrame = CGRectMake(0, yOffset, self.view.frame.size.width, [self contactsTableHeight]);
    self.contactsTableView.frame = tableFrame;
    [self.delegate contactPickerUpdatedHeight];
}

- (void)closeContactPicker{
    [self.contactPickerView close];
    [self.contactsTableView setHidden:YES];
}

- (void)openContactPicker{
    
}

#pragma mark - Private methods

- (void)configureCell:(THContactTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    [cell.nameLabel setAttributedText:[self titleForRowAtIndexPath:indexPath]];
    [cell.numberLabel setAttributedText:[self phoneNumberForRowAtIndexPath:indexPath]];
}

- (NSAttributedString *)titleForRowAtIndexPath:(NSIndexPath *)indexPath {
    THContact *contact = [self.filteredContacts objectAtIndex:indexPath.row];
    NSAttributedString *title = [contact attributedNameLabel];
    return title;
}

- (NSMutableAttributedString *)phoneNumberForRowAtIndexPath:(NSIndexPath *)indexPath {
    THContact *contact = [self.filteredContacts objectAtIndex:indexPath.row];
    return [contact attributedNumberLabel];
}

-(float)contactsTableHeight{
    int tabBarHeight = 49;
    return self.view.frame.size.height-self.contactPickerView.frame.size.height-self.contactPickerView.frame.origin.y-tabBarHeight;
}

-(float)contactsTableVerticalPosition{
    int delta = 2;
    return self.contactPickerView.frame.origin.y+self.contactPickerView.frame.size.height+delta;
}

#pragma  mark - AddressBook
-(NSArray *)contactsFromAddressBook{
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, NULL);
    
    CFArrayRef all = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex n = ABAddressBookGetPersonCount(addressBook);
    
    NSMutableArray *contactsArray = [[NSMutableArray alloc] init];
    
    for( int i = 0 ; i < n ; i++ ){
        ABRecordRef ref = CFArrayGetValueAtIndex(all, i);
        
        NSString* compositeName = (__bridge_transfer NSString *)ABRecordCopyCompositeName(ref);
        if(compositeName==nil) compositeName=@"";
        
        CFTypeRef phoneProperty = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        
        NSArray *phones = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(phoneProperty);

        int counter = 0;
        for (NSString *phone in phones){
            THContact *contact = [[THContact alloc] init];
            [contact setName:compositeName];
            
            NSString *type;
            CFStringRef refString = ABMultiValueCopyLabelAtIndex(phoneProperty, counter);
            if(refString!=NULL){
                type = (__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(refString);
                CFRelease(refString);
            }else{
                type = @"Phone";
            }
            
            [contact setType:type];
            [contact addPhoneNumber:phone];
            [contactsArray addObject:contact];
            
            counter++;
        }
        
        CFRelease(phoneProperty);
    }
    
    CFRelease(all);
    CFRelease(addressBook);
    
    [self replaceSelectedContactsWithNewOnes:contactsArray];
    
    return contactsArray;
}

-(void)replaceSelectedContactsWithNewOnes:(NSArray *)newContacts{
    
    NSMutableArray *newSelectedContacts = [[NSMutableArray alloc] init];
    
    for(THContact *contact in self.privateSelectedContacts){
        BOOL foundInContactList = NO;
        
        for(THContact *actoualContact in newContacts){
            if([contact.name isEqualToString:actoualContact.name] &&
               [[contact phoneNumber] isEqualToString:[actoualContact phoneNumber]] &&
                [contact.type isEqualToString:actoualContact.type]){
                [newSelectedContacts addObject:actoualContact];
                foundInContactList = YES;
                break;
            }
        }
        
        if(!foundInContactList){
            [newSelectedContacts addObject:contact];
        }
    }
    
    [self.contactPickerView removeAllContacts];
    for(THContact *contact in  newSelectedContacts){
        [self.contactPickerView addContact:contact withName:contact.name];
    }
    
    [self.privateSelectedContacts removeAllObjects];
    [self.privateSelectedContacts addObjectsFromArray:newSelectedContacts];
}

#pragma  mark - NSNotificationCenter
- (void)keyboardDidShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kbRect = [self.view convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kbRect = [self.view convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
}

- (void)addContact:(THContact *)contact{
    
    if(![self.privateSelectedContacts containsObject:contact] &&
       ![self existsSameInPrivateContacts:contact]){
        THContact *finalContact = [self contactFromContacts:contact];
        
        if([contact.name isEqualToString:contact.phoneNumber]){
            finalContact = [self contactConsiderJustNumber:contact];
        }
        
        [self.privateSelectedContacts addObject:finalContact];
        [self.contactPickerView addContact:finalContact withName:finalContact.name];
    }else{
        [self.contactPickerView clearTextView];
    }
    
    self.filteredContacts = self.contacts;
    [self.contactPickerView open];
    [self.contactsTableView reloadData];
}

- (BOOL)existsSameInPrivateContacts:(THContact *)contact{
    
    for(THContact *cont in self.privateSelectedContacts){
        if([contact.name isEqualToString:cont.name] &&
           [contact.phoneNumber isEqualToString:cont.phoneNumber] &&
           [contact.type isEqualToString:cont.type]){
            return YES;
        }
    }
        
    return NO;
}

-(THContact *)contactFromContacts:(THContact *)incomingContact{
    for(THContact *cont in self.contacts){
        if([incomingContact.name isEqualToString:cont.name] &&
           [incomingContact.phoneNumber isEqualToString:cont.phoneNumber] &&
           [incomingContact.type isEqualToString:cont.type]){
            return cont;
        }
    }
    
    return incomingContact;
}

-(THContact *)contactConsiderJustNumber:(THContact *)incomingContact{
    
    for(THContact *cont in self.contacts){
        NSString *contPhoneNorm = [THContactPicker normalizeTelephoneNumber:cont.phoneNumber];
        NSString *incomingPhoneNorm = [THContactPicker normalizeTelephoneNumber:incomingContact.phoneNumber];
        if([incomingPhoneNorm isEqualToString:contPhoneNorm]){
            return cont;
        }
    }
    
    return incomingContact;
}

//TODO: normalizacia je 2 krat lebo picker z podu si nemoze brat normalizovane cislo z waletu
+ (NSString*)normalizeTelephoneNumber:(NSString*)telephoneNumber
{
    if (!telephoneNumber) return nil;
    NSString* newTelephoneNumber = [THContactPicker cleanTelephoneNumber:telephoneNumber];
    
    /*
     // replace 09 by +4219
     if ([newTelephoneNumber length] >= 2)
     newTelephoneNumber = [newTelephoneNumber stringByReplacingOccurrencesOfString:@"09" withString:@"+4219" options:0 range:NSMakeRange(0, 2)];
     */
    
    // replace 421 with +421
    if ([newTelephoneNumber length] >= 3)
        newTelephoneNumber = [newTelephoneNumber stringByReplacingOccurrencesOfString:@"421" withString:@"+421" options:0 range:NSMakeRange(0, 3)];
    
    // replace 420 with +420
    if ([newTelephoneNumber length] >= 3)
        newTelephoneNumber = [newTelephoneNumber stringByReplacingOccurrencesOfString:@"420" withString:@"+420" options:0 range:NSMakeRange(0, 3)];
    
    // replace 00 with +
    if ([newTelephoneNumber length] >= 2)
        newTelephoneNumber = [newTelephoneNumber stringByReplacingOccurrencesOfString:@"00" withString:@"+" options:0 range:NSMakeRange(0, 2)];
    
    // replace 0 with +421
    if ([newTelephoneNumber length] >= 1)
        newTelephoneNumber = [newTelephoneNumber stringByReplacingOccurrencesOfString:@"0" withString:@"+421" options:0 range:NSMakeRange(0, 1)];
    
    return newTelephoneNumber;
}

+ (NSString*)cleanTelephoneNumber:(NSString*)telephoneNumber
{
    if (!telephoneNumber) return nil;
    NSString* newTelephoneNumber = [NSString stringWithString:telephoneNumber];
    
    // remove characters: '(' ')' '-' '.' ' '
    NSMutableCharacterSet* characters = [NSMutableCharacterSet characterSetWithCharactersInString:@"()-."];
    [characters formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    newTelephoneNumber = [[newTelephoneNumber componentsSeparatedByCharactersInSet:characters] componentsJoinedByString:@""];
    return newTelephoneNumber;
}

- (void)clear{
    [self.privateSelectedContacts removeAllObjects];
    [self.contactPickerView removeAllContacts];
    [self closeContactPicker];
}

- (NSUInteger)selectedContactsCount{
    return [self.privateSelectedContacts count];
}

- (NSArray *)selectedContacts{
    return [self privateSelectedContacts];
}

@end

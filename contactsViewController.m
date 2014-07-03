//
//  settingsDetailViewController.m
//  Help!
//
//  Created by Jad Yacoub on 2/24/14.
//  Copyright (c) 2014 Jad Yacoub. All rights reserved.
//

#import "contactsViewController.h"
#import "contactsDataController.h"
#import "contact.h"

@interface settingsDetailViewController ()
- (void)configureView;
- (void)storeContact:(ABRecordRef)person;
@end

@implementation settingsDetailViewController 

#pragma mark - Managing the detail item


- (void)configureView
{
    /* Always initialize the contacts List first */
    self.contactsList = [[contactsDataController alloc] init];
  
    /* Check if any users are already stored */
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    if([user objectForKey:@"contactList"] != nil){
        /* Unarchive data first if any are stored*/
        NSArray *encodedContactList = [user objectForKey:@"contactList"];
        for (NSData *encodedContact in encodedContactList){
            contact *currentContact = [NSKeyedUnarchiver unarchiveObjectWithData:encodedContact];
            [self.contactsList addToContactListWithContact:currentContact];
        }
    }
}

/* Stores the contacts list in User Defaults */
- (void)storeDataToUserDefaults{
    NSMutableArray *encodedList = [[NSMutableArray alloc] init];
    for (contact *existingContact in self.contactsList.contactList){
        NSData *encodedContact =[NSKeyedArchiver archivedDataWithRootObject:existingContact];
        [encodedList addObject:encodedContact];
    }

    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:encodedList forKey:@"contactList"];
    /* Synchronize to make sure data is written to flash */
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/* Enable table editing when edit button is pressed */
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
}

/************************* Delegate for Address Book *********************************/
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/* Called after a person has been selected from the address book by the user */
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person{
    
    /* Store the people selected in the data model */
    [self storeContact:person];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    return NO;
}

- (void) storeContact:(ABRecordRef)person{
    
    bool addContact = NO;
    
    NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person,
                                                                         kABPersonFirstNameProperty);
    NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(person,
                                                                        kABPersonLastNameProperty);

    NSString *phone = @"None";
    
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person,
                                                     kABPersonPhoneProperty);
    
    /* If using the SMS notifcation Method */
    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        /*
         *This loop is to look for the phone Numbers that are labeled as either Mobile or iPhone
         *since they are the only ones capable of recieving SMS
         */
        for(int j = 0; j < ABMultiValueGetCount(phoneNumbers); j++){
            NSString *phoneLabel = (__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phoneNumbers, j));
            NSLog(@"Phone label is %@", phoneLabel);
            if ([phoneLabel isEqualToString:@"mobile"] || [phoneLabel isEqualToString:@"iPhone"]){
                phone = (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(phoneNumbers, j);
                addContact = YES;
                break;
            }
        }
    }
    
    /* No phone numbers were found, or the ones found have no mobile/Iphone tag */
    if ( (ABMultiValueGetCount(phoneNumbers) == 0) || addContact == NO) {
        UIAlertView *message = [[UIAlertView alloc]
                                initWithTitle:@"No Mobile Phone Number Found For Selected Contact"
                                message:@"Please add a Mobile or iPhone number and then reselect again"
                                delegate:self
                                cancelButtonTitle:@"OK"
                                otherButtonTitles:nil, nil];
        [message show];
        
        //addContact = NO;
    }
    
    if(lastName == nil){
        lastName = [[NSString alloc] initWithFormat:@""];
    }
    if(firstName == nil){
        firstName = [[NSString alloc] initWithFormat:@""];
    }
    
    if(addContact == YES){
        contact *contactToAdd = [[contact alloc] initWithName:firstName lastName:lastName phoneNumber:phone];
    
        if(![self.contactsList.contactList containsObject:contactToAdd]){
            [self.contactsList addToContactListWithContact:contactToAdd];
    
            /* Update the contactList in persistent storage */
            [self storeDataToUserDefaults];
    
            [self.tableView reloadData];
            self.editButton.enabled = YES;
        }
    }
    
    CFRelease(phoneNumbers);
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    return NO;
}

/************************************************************************************/


/************************ Data Source  & Delegate for Table *************************/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    /* Make it +1 to allow space for insertion row */
    return 1 + [self.contactsList countOfContactList];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    if( [self.contactsList objectInContactListAtIndex:indexPath.row] == nil){
        static NSString *CellIdentifier = @"emptyList";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

        [[cell textLabel] setText:@"Click edit to add contacts"];
        
        if([self.tableView isEditing]){
             [[cell textLabel] setText:@"Add new contact"];
        }

        return cell;
    }
    else{
        static NSString *CellIdentifier = @"contactInfo";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        contact *contactAtIndex = [self.contactsList objectInContactListAtIndex:indexPath.row];
        
        NSMutableString *cellText = [[NSMutableString alloc] init];
        [cellText appendString:contactAtIndex.firstName];
        [cellText appendString:@" "];
        [cellText appendString:contactAtIndex.lastName];
        
        [[cell textLabel] setText:cellText];
        
        [[cell detailTextLabel] setText:contactAtIndex.phoneNumber];
        
        return cell;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    if( [self.contactsList objectInContactListAtIndex:indexPath.row] == nil){
        return UITableViewCellEditingStyleInsert;
    }else{
        return UITableViewCellEditingStyleDelete;
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete){
        [self.contactsList removeContactAtIndex:indexPath.row];

        /* Update the contactList in persistent storage */
        [self storeDataToUserDefaults];
        
        [self.tableView reloadData];
        
    }
    else if(editingStyle == UITableViewCellEditingStyleInsert){
        ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
        
        picker.peoplePickerDelegate = self;
        
        [self presentViewController:picker animated:YES completion:nil];
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath
                                                                  *)indexPath
{
    return YES;
}


/**************************************************************************************/

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButton{
    [self.tableView setEditing:NO animated:YES];
    [super setEditing:NO animated:NO];
    self.navigationItem.rightBarButtonItem = self.editButton;
    [self.tableView reloadData];
}


- (IBAction)editButtonPressed:(id)sender {
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(doneButton)];
    self.navigationItem.rightBarButtonItem = doneButton;
    [self.tableView setEditing:YES animated:YES];
    [super setEditing:YES animated:YES];
    [self.tableView reloadData];
}


@end

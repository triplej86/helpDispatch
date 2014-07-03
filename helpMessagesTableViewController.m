//
//  helpMessagesTableViewController.m
//  Help!
//
//  Created by Jad Yacoub on 3/24/14.
//  Copyright (c) 2014 Jad Yacoub. All rights reserved.
//

#import "helpMessagesTableViewController.h"

#define DEFAULT_MESSAGE_1 @"I am being chased by a stranger!"
#define DEFAULT_MESSAGE_2 @"My house is being broken into!"
#define DEFAULT_MESSAGE_3 @"I am in a medical emergency!"
#define DEFAULT_MESSAGE_4 @"I am in a car accident!"
#define DEFAULT_NEW_HELP_MESSAGE @"Click to customize help message"

@interface helpMessagesTableViewController ()

@property NSUInteger tempVar;

@end

@implementation helpMessagesTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        /* Custome Init -  Allocate and init the help messages array first */
        self.helpMessages = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];

    self.helpMessages = [[user objectForKey:@"helpMessages"] mutableCopy];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([self.helpMessages count] + 1);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    /* The most bottom cell */
    if(indexPath.row == [self.helpMessages count]){
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"template" forIndexPath:indexPath];

        if([self.tableView isEditing]){
            [[cell textLabel] setText:@"Add new help message"];
        }
        else{
            [[cell textLabel] setText:@"Click edit to modify help messages"];
        }

        return cell;
        
    }
    else{

        UITableViewCell *cell = [[UITableViewCell alloc] init];
    
        /* Configure the cell */
        NSString *currentHelpMessage = [self.helpMessages objectAtIndex:indexPath.row];
    
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 300, 30)];

        if( [currentHelpMessage isEqualToString:DEFAULT_NEW_HELP_MESSAGE]){
            self.textField.placeholder = @ "Type new help message here";
        }
        else if( [currentHelpMessage length] == 0){
            self.textField.placeholder = @"Type new help message here";
        }
        else{
            self.textField.text = currentHelpMessage;
        }
        self.textField.delegate = self;
        self.textField.tag = indexPath.row;
        self.textField.adjustsFontSizeToFitWidth = YES;
    
        [cell.contentView addSubview:self.textField];
        
        return cell;
    }
}

-(void) textFieldDidEndEditing: (UITextField * ) textField {
    // Decide which text field based on it's tag and save data to the model.
    if( self.tempVar == [self.helpMessages count]){
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [self.helpMessages replaceObjectAtIndex:textField.tag withObject:textField.text];
    
        [user setObject:self.helpMessages forKey:@"helpMessages"];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if([self.tableView isEditing]){
        self.tempVar = [self.helpMessages count];
        return YES;
    }
    else{
        return NO;
    }
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


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row < [self.helpMessages count]){
        return UITableViewCellEditingStyleDelete;
    }
    else{
        return UITableViewCellEditingStyleInsert;
    }
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.tableView.isEditing == TRUE){
        return YES;
    }
    else{
        return NO;
    }
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.helpMessages removeObjectAtIndex:indexPath.row];
        [user setObject:self.helpMessages forKey:@"helpMessages"];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        NSString *newHelpMessage = DEFAULT_NEW_HELP_MESSAGE;
        [self.helpMessages addObject:newHelpMessage];
        [user setObject:self.helpMessages forKey:@"helpMessages"];
        [self.tableView reloadData];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

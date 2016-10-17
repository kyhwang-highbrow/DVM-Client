// Copyright (C) 2014 by Tapjoy Inc.
//
// This file is part of the Tapjoy SDK.
//
// By using the Tapjoy SDK in your software, you agree to the terms of the Tapjoy SDK License Agreement.
//
// The Tapjoy SDK is bound by the Tapjoy SDK License Agreement and can be found here: https://www.tapjoy.com/sdk/license

#import "TJUserPropertiesViewController.h"
#import <Tapjoy/Tapjoy.h>

@interface TJUserPropertiesViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userIdField;
@property (weak, nonatomic) IBOutlet UITextField *levelField;
@property (weak, nonatomic) IBOutlet UITextField *friendField;
@property (weak, nonatomic) IBOutlet UITextField *cohort1Field;
@property (weak, nonatomic) IBOutlet UITextField *cohort2Field;
@property (weak, nonatomic) IBOutlet UITextField *cohort3Field;
@property (weak, nonatomic) IBOutlet UITextField *cohort4Field;
@property (weak, nonatomic) IBOutlet UITextField *cohort5Field;
@property (weak, nonatomic) IBOutlet UITextField *userTagsField;

@property (weak, nonatomic) IBOutlet UIButton *setButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;

@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;
@property (weak, nonatomic) IBOutlet UIButton *clearUserTagButton;

@end

@implementation TJUserPropertiesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)setProperties:(id)sender
{
	//TODO: smarter setting--only set if value changed, type check for ints, etc
	[Tapjoy setUserID:_userIdField.text];
	[Tapjoy setUserLevel:[_levelField.text intValue]];
	[Tapjoy setUserFriendCount:[_friendField.text intValue]];
	[Tapjoy setUserCohortVariable:1 value:_cohort1Field.text];
	[Tapjoy setUserCohortVariable:2 value:_cohort2Field.text];
	[Tapjoy setUserCohortVariable:3 value:_cohort3Field.text];
	[Tapjoy setUserCohortVariable:4 value:_cohort4Field.text];
	[Tapjoy setUserCohortVariable:5 value:_cohort5Field.text];
}

- (IBAction)clearProperties:(id)sender
{
	// TODO: Tapjoy setUserID cannot be nil
	// [Tapjoy setUserID:nil];
	
	[Tapjoy setUserLevel:-1];
	[Tapjoy setUserFriendCount:-1];
	[Tapjoy setUserCohortVariable:1 value:nil];
	[Tapjoy setUserCohortVariable:2 value:nil];
	[Tapjoy setUserCohortVariable:3 value:nil];
	[Tapjoy setUserCohortVariable:4 value:nil];
	[Tapjoy setUserCohortVariable:5 value:nil];
	
	_userIdField.text = nil;
	_levelField.text = nil;
	_friendField.text = nil;
	_cohort1Field.text = nil;
	_cohort2Field.text = nil;
	_cohort3Field.text = nil;
	_cohort4Field.text = nil;
	_cohort5Field.text = nil;
}

- (IBAction)addUserTag:(id)sender {
    [Tapjoy addUserTag:_userTagsField.text];
    _userTagsField.text = nil;
}

- (IBAction)removeUserTag:(id)sender {
    [Tapjoy removeUserTag:_userTagsField.text];
    _userTagsField.text = nil;
}

- (IBAction)clearUserTag:(id)sender {
    [Tapjoy setUserTags:nil];
    _userTagsField.text = nil;
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end

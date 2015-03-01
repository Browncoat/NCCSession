//
//  ViewController.m
//  Session
//
//  Created by Nathaniel Potter on 11/3/14.
//  Copyright (c) 2014 Nathaniel Potter. All rights reserved.
//

#import "ViewController.h"
#import "NCCSession.h"
#import "AppDelegate.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;

@end

@implementation ViewController
{
    User *_user;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _user = [(AppDelegate *)[[UIApplication sharedApplication] delegate] user];
    if (_user) {
        _usernameTextField.text = _user.username;
        _passwordTextField.text = _user.password;
        _firstNameTextField.text = _user.firstName;
        _lastNameTextField.text = _user.lastName;
    } else {
        _user = [User user];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showUserWithId:(NSString *)uid
{
    User *user = [User userWithId:uid];
    
    _usernameTextField.text = user.username;
    _passwordTextField.text = user.password;
    _firstNameTextField.text = user.firstName;
    _lastNameTextField.text = user.lastName;
}

#pragma mark - Actions

- (IBAction)didPressSaveButton:(id)sender
{
    if (_user) {
        _user.username = _usernameTextField.text;
        _user.password = _passwordTextField.text;
        _user.firstName = _firstNameTextField.text;
        _user.lastName = _lastNameTextField.text;
        
        [_user save];
    }
}

- (IBAction)didPressDeleteButton:(id)sender
{
    if (_user) {
        [_user delete];
    }
    
    _usernameTextField.text = @"";
    _passwordTextField.text = @"";
    _firstNameTextField.text = @"";
    _lastNameTextField.text = @"";
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [User allUsers].count;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    User *user = [User allUsers][row];
    return user.uid;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    User *user = [User allUsers][row];
    [self showUserWithId:user.uid];
}

@end

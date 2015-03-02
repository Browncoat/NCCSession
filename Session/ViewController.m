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
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

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
        [self updateTextFields];
    } else {
        _user = [User user];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateTextFields
{
    _usernameTextField.text = _user.username;
    _passwordTextField.text = _user.password;
    _firstNameTextField.text = _user.firstName;
    _lastNameTextField.text = _user.lastName;
}

- (void)showUserWithId:(NSString *)uid
{
    _user = [User userWithId:uid];
    
    [self updateTextFields];
}

#pragma mark - Actions

- (IBAction)didPressSaveButton:(id)sender
{
    [self.view endEditing:YES];
    
    if (_user) {
        _user.username = _usernameTextField.text;
        _user.password = _passwordTextField.text;
        _user.firstName = _firstNameTextField.text;
        _user.lastName = _lastNameTextField.text;
        
        [_user save];
        
        [_pickerView reloadAllComponents];
    }
}

- (IBAction)didPressDeleteButton:(id)sender
{
    [self.view endEditing:YES];
    
    if (_user) {
        [_user delete];
        _user = nil;
    }
    
    [self updateTextFields];
    
    [_pickerView reloadAllComponents];
}

- (IBAction)didPressNewUser:(id)sender
{
    [self.view endEditing:YES];
    
    _user = [User user];
    
    [self updateTextFields];
    
    [_pickerView reloadAllComponents];
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

#pragma MARK - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    
    return NO;
}

@end

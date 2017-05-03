//
//  ViewController.m
//  MotA
//
//  Created by Drew Colace on 5/1/17.
//  Copyright © 2017 Drew Colace. All rights reserved.
//

#import "ViewController.h"
#import "BCDataCollector.h"
#import "MBProgressHUD.h"

NSString * const BC_DATA_CELL = @"ACRONYM";

@interface ViewController (/*private*/) < UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate >

@property (nonatomic, weak) IBOutlet UITextField *acronymField;
@property (nonatomic, weak) IBOutlet UIPickerView *definitionPickerView;


@property (nonatomic, strong) NSString *lastSearchString;
@property (nonatomic, strong) BCDataCollector *dataCollector;
@property (nonatomic, strong) NSArray *retrievedDefinitions;

@property CGFloat red;
@property CGFloat blue;
@property BOOL colorAscending;
@property BOOL cycleRed;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.definitionPickerView.delegate = self;
    self.definitionPickerView.dataSource = self;
    
    self.acronymField.delegate = self;

    self.dataCollector = [BCDataCollector new];
    
    _red = _blue = 142.0;
    self.cycleRed = YES;
    self.colorAscending = NO;
    
    [NSTimer scheduledTimerWithTimeInterval:.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        [self adjustColors];
        
        self.view.backgroundColor = [UIColor colorWithRed:self.red/255.0 green:1.0 blue:self.blue/255.0 alpha:1.0];
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)adjustColors
{
    if(self.colorAscending)
    {
        BOOL    peaked;
        [self incrementColor:(self.cycleRed ? &_red : &_blue) peaking:&peaked];
        
        if(peaked)
        {
            self.cycleRed = !self.cycleRed;
        }
    }
    else
    {
        [self decrementColor:(self.cycleRed ? &_red : &_blue)];
    }
}

- (void)incrementColor:(CGFloat *)ioColor peaking:(BOOL *)peaking
{
    BOOL peaked = NO;
    
    if(ioColor)
    {
        (*ioColor)++;
        
        if(*ioColor > 141)
        {
            self.colorAscending = NO;
            peaked = YES;
        }
    }
    
    if(peaking)
    {
        *peaking = peaked;
    }
}

- (void)decrementColor:(CGFloat *)ioColor
{
    if(ioColor)
    {
        (*ioColor)--;
        
        if(*ioColor < 2)
        {
            self.colorAscending = YES;
        }
    }
}

#pragma mark UITextFieldDelegate Methods
#pragma mark -

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if([MBProgressHUD HUDForView:self.view] != nil)
    {
        [MBProgressHUD hideHUDForView:self.view animated:NO];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *updatedSearchString = textField.text;
    
    if(updatedSearchString)
    {
        if(![self.lastSearchString isEqualToString:updatedSearchString])
        {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            hud.minShowTime = 1.5;
            
            [self.dataCollector lookupAcronym:updatedSearchString suceeded:^(NSArray * definitions) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    
                    self.retrievedDefinitions = definitions;
                    self.lastSearchString = updatedSearchString;
                    
//                    NSLog(@"%@", [definitions description]);
                    [self.definitionPickerView reloadAllComponents];
                });

            } failed:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    
                    self.retrievedDefinitions = nil;
                    self.lastSearchString = nil;
                });
            }];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return NO;
}

#pragma mark UIPickerViewDelegate Methods
#pragma mark -

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.retrievedDefinitions objectAtIndex:row];
}

#pragma mark UIPickerViewDataSource Methods
#pragma mark -

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.retrievedDefinitions count];
}

@end

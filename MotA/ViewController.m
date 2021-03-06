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

#define BC_USE_TABLEVIEW   1

NSString * const BC_DATA_CELL = @"ACRONYM";

@interface ViewController (/*private*/) < UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate >

@property (nonatomic, weak) IBOutlet UITextField *acronymField;
@property (nonatomic, weak) IBOutlet UIPickerView *definitionPickerView;

@property (nonatomic, weak) UITableView *definitionsView;


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
    
#if BC_USE_TABLEVIEW
    CGRect      itemRect = CGRectZero;
    UITableView *tv;
    
    itemRect.origin.y = CGRectGetMaxY(self.acronymField.frame) + 20;
    itemRect.size.width = CGRectGetWidth(self.view.bounds);
    itemRect.size.height = CGRectGetHeight(self.view.bounds) - itemRect.origin.y;
    
    tv = [[UITableView alloc] initWithFrame:itemRect style:UITableViewStylePlain];
 
    [self.view addSubview:tv];
    
    tv.delegate = self;
    tv.dataSource = self;
    tv.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.definitionsView = tv;
    
    self.definitionPickerView.hidden = TRUE;
#else
    self.definitionPickerView.delegate = self;
    self.definitionPickerView.dataSource = self;
#endif
    
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
        if([self incrementColor:(self.cycleRed ? &_red : &_blue) maxValue:140])
        {
            self.colorAscending = NO;
            self.cycleRed = !self.cycleRed;
        }
    }
    else
    {
        if([self decrementColor:(self.cycleRed ? &_red : &_blue) minValue:2])
        {
            self.colorAscending = YES;
        }
    }
}

- (BOOL)incrementColor:(CGFloat *)ioColor maxValue:(CGFloat)maxValue
{
    BOOL thresholdReached = NO;
    
    if(ioColor)
    {
        (*ioColor)++;
        
        if(*ioColor > maxValue)
        {
            thresholdReached = YES;
        }
    }
    
    return thresholdReached;
}

- (BOOL)decrementColor:(CGFloat *)ioColor minValue:(CGFloat)minValue
{
    BOOL thresholdReached = NO;
    
    if(ioColor)
    {
        (*ioColor)--;
        
        if(*ioColor < minValue)
        {
            thresholdReached = YES;
        }
    }
    
    return thresholdReached;
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
                    
#if BC_USE_TABLEVIEW
                    [self.definitionsView reloadData];
#else
                    [self.definitionPickerView reloadAllComponents];
#endif
                });

            } failed:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    
                    self.retrievedDefinitions = nil;
                    self.lastSearchString = nil;
                    
#if BC_USE_TABLEVIEW
                    [self.definitionsView reloadData];
#else
                    [self.definitionPickerView reloadAllComponents];
#endif
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

#pragma mark UITableViewDelegate Methods
#pragma mark -

#pragma mark UITableViewDataSource Methods
#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.retrievedDefinitions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BC_DATA_CELL];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BC_DATA_CELL];
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    cell.textLabel.text = [self.retrievedDefinitions objectAtIndex:indexPath.row];
    
    return cell;
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

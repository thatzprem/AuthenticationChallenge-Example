//
//  ViewController.h
//  NSURLProtectionSpace Example
//
//  Created by Prem kumar on 23/08/13.
//  Copyright (c) 2013 freakApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *statusMessageLabel;

- (IBAction)authenticateButtonPressed:(id)sender;
@end

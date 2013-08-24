//
//  ViewController.m
//  NSURLProtectionSpace Example
//
//  Created by Prem kumar on 23/08/13.
//  Copyright (c) 2013 freakApps. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

NSMutableData *receivedData;
NSURLProtectionSpace *protectionSpaceForBasicAuthentication;

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.statusMessageLabel.text = @"Application launched...";
    
    //create a protectionSpace for basic authentication.
    protectionSpaceForBasicAuthentication = [self createProtectionSpaceForBasicAuthentication];
    self.statusMessageLabel.text = @"Created protection space for basic authentication...";
    
}

- (IBAction)authenticateButtonPressed:(id)sender {
    
    self.statusMessageLabel.text = @"Authenticate button pressed...";
    
    //create credential object.
    NSURLCredential *credential = [self createCredentialForUsername:self.userNameTextField.text Password:self.passwordTextField.text];
    
    self.statusMessageLabel.text = @"Created credentials...";
    
    //Add credential to the protection space.
    [[NSURLCredentialStorage sharedCredentialStorage] setCredential:credential forProtectionSpace:protectionSpaceForBasicAuthentication];
    
    self.statusMessageLabel.text = @"Initiated connection...";
    
    // Create the request.
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://test.webdav.org/auth-basic/"]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    // create the connection with the request
    // and start loading the data
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        receivedData = [NSMutableData data];
    } else {
        
        // Inform the user that the connection failed.
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Your connection request failed." delegate:nil
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
    self.statusMessageLabel.text = @"Connection: didReceiveResponse...";
    
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [receivedData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    self.statusMessageLabel.text = @"Connection: didReceiveData...";
    
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    self.statusMessageLabel.text = @"Connection: didFailWithError...";
    
    // release the connection, and the data object
    // receivedData is declared as a method instance elsewhere
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.statusMessageLabel.text = @"Connection: connectionDidFinishLoading...";
    
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Info"
                                                        message:@"Authentication successfull..." delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
}

-(void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    self.statusMessageLabel.text = @"Connection: didReceiveAuthenticationChallenge...";
    
    self.statusMessageLabel.text = [NSString stringWithFormat:@"PreviousFailureCount: %d",[challenge previousFailureCount]];
    
    //check if the previous failure attempt is less than 5 to re-inititate authentiation.
    if ([challenge previousFailureCount] <= 5) {
        
        //get credentails for protection space.
        NSDictionary *credentialsDictionary = [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:protectionSpaceForBasicAuthentication];
        
        NSLog(@"All the keys from the credentials dictionary: %@",[credentialsDictionary allKeys]);;
        NSLog(@"Total number of credential pairs  in the protection space: %d",[[credentialsDictionary allKeys] count]);
        
        //enumerate the dictionary & get credential pairs for all the stored usenames.
        NSEnumerator *userNameEnumerator = [credentialsDictionary keyEnumerator];
        id userName;
        
        // iterate over all usernames for this protectionspace, which are the keys for the actual NSURLCredentials
        while (userName = [userNameEnumerator nextObject]) {
            NSURLCredential *cred = [credentialsDictionary objectForKey:userName];
            NSLog(@"Credentials found in the storage: %@", cred);
            
            self.statusMessageLabel.text = [NSString stringWithFormat:@"Authenticating using credential pair: %@",userName];
            
            if ([userName isEqualToString:self.userNameTextField.text]) {
                //use credential for authentication challenge.
                [[challenge sender] useCredential:cred forAuthenticationChallenge:challenge];
            }
        }
    } else {
        
        self.statusMessageLabel.text = @"Cancelled AuthenticationChallenge...";
        
        //cancel the authentication challenge
        [[challenge sender] cancelAuthenticationChallenge:challenge];
        
        // inform the user that the user name and password
        // in the preferences are incorrect
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"5 attempts failed for authentication! Reason: incorrect username/password." delegate:nil
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

-(NSURLProtectionSpace *)createProtectionSpaceForBasicAuthentication{
    
    NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc]
                                             initWithHost:@"http://test.webdav.org/auth-basic/"
                                             port:443
                                             protocol:@"http"
                                             realm:nil
                                             authenticationMethod:NSURLAuthenticationMethodHTTPBasic];
    return protectionSpace;
}

-(NSURLCredential *)createCredentialForUsername:(NSString *)username Password:(NSString *)password{
    
    NSURLCredential *credentialObject;
    credentialObject = [NSURLCredential credentialWithUser:username
                                                  password:password
                                               persistence:NSURLCredentialPersistenceForSession];
    return credentialObject;
}

-(BOOL)removeAllStoredCredentials{
    
    NSDictionary *credentialsDict = [[NSURLCredentialStorage sharedCredentialStorage] allCredentials];
    NSLog(@"All the received Credentials: %@",credentialsDict);
    
    if ([credentialsDict count] > 0) {
        // the credentialsDict has NSURLProtectionSpace objs as keys and dicts of userName => NSURLCredential
        NSEnumerator *protectionSpaceEnumerator = [credentialsDict keyEnumerator];
        id urlProtectionSpace;
        
        // iterate over all NSURLProtectionSpaces
        while (urlProtectionSpace = [protectionSpaceEnumerator nextObject]) {
            NSEnumerator *userNameEnumerator = [[credentialsDict objectForKey:urlProtectionSpace] keyEnumerator];
            id userName;
            
            // iterate over all usernames for this protectionspace, which are the keys for the actual NSURLCredentials
            while (userName = [userNameEnumerator nextObject]) {
                NSURLCredential *cred = [[credentialsDict objectForKey:urlProtectionSpace] objectForKey:userName];
                NSLog(@"credentials to be removed: %@", cred);
                [[NSURLCredentialStorage sharedCredentialStorage] removeCredential:cred forProtectionSpace:urlProtectionSpace];
            }
        }
    }
    return YES;
    
}


-(NSCachedURLResponse *)connection:(NSURLConnection *)connection
                 willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    NSCachedURLResponse *newCachedResponse = cachedResponse;
    
    if ([[[[cachedResponse response] URL] scheme] isEqual:@"https"]) {
        newCachedResponse = nil;
    } else {
        NSDictionary *newUserInfo;
        newUserInfo = [NSDictionary dictionaryWithObject:[NSDate date]
                                                  forKey:@"Cached Date"];
        newCachedResponse = [[NSCachedURLResponse alloc]
                             initWithResponse:[cachedResponse response]
                             data:[cachedResponse data]
                             userInfo:newUserInfo
                             storagePolicy:[cachedResponse storagePolicy]]
        ;
    }
    return newCachedResponse;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

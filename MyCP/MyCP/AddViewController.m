//
//  AddViewController.m
//  MyCP
//
//  Created by Vlad Alexa on 8/15/12.
//  Copyright (c) 2012 Vlad Alexa. All rights reserved.
//

#import "AddViewController.h"

#import "CpanelViewController.h"

#import "PDKeychainBindings.h"

@interface AddViewController ()

@end

@implementation AddViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)typeChange:(id)sender
{
   
    if ([type selectedSegmentIndex] == 0) {
        [domainField setHidden:NO];
        [usernameField setHidden:NO];
        [passwordField setHidden:NO];
        [urlField setHidden:YES];
    }else{
        [urlField setHidden:NO];
        [serverField setHidden:YES];
        [domainField setHidden:YES];
        [usernameField setHidden:YES];
        [passwordField setHidden:YES];
    }
     
}

- (IBAction)add:(id)sender
{
    [type setEnabled:NO];
    [addButton setHidden:YES];
    [spinner startAnimating];
    
    if ([type selectedSegmentIndex] == 0) {
        [self addCpanel];
    }else{
        [self addPhp];
    }

    [spinner stopAnimating];
    [type setEnabled:YES];
    [addButton setHidden:NO];
}

- (IBAction)cancel:(id)sender
{
    [self.delegate addViewControllerDidFinish:self];    
}

-(void)addCpanel
{
    NSString *serv = domainField.text;
    if ([serverField.text length] > 1) serv = serverField.text;
    NSString *dom = domainField.text;
    NSString *user = usernameField.text;
    NSString *pass = passwordField.text;
    NSData *hash = [[NSString stringWithFormat:@"%@:%@",user,pass] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *b64 = [CpanelViewController base64EncodeData:hash];
    NSError *error = nil;
    NSData *data = [CpanelViewController execCpanelCommand:@"Stats&cpanel_xmlapi_func=listrawlogs" server:serv domain:dom user:user b64:b64 error:&error];
    if (data)
    {
        NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        if ([responseBody rangeOfString:@"<error>Access denied</error>"].location != NSNotFound)
        {
            [[[UIAlertView alloc] initWithTitle:@"Access denied" message:@"Check your login credentials" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil ,nil] show];
        }else{
            PDKeychainBindings *bindings = [PDKeychainBindings sharedKeychainBindings];
            [bindings setObject:b64 forKey:dom];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSMutableArray *accounts = [NSMutableArray arrayWithArray:[defaults objectForKey:@"accounts"]];
            [accounts addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"cpanel",@"type",user,@"username",serv,@"server",dom,@"domain",[NSDate date],@"date", nil]];
            [defaults setObject:accounts forKey:@"accounts"];
            [defaults synchronize];
            [self.delegate addViewControllerDidFinish:self];            
        }
    }else{
        
        if ([[error description] rangeOfString:@"The certificate for this server is invalid"].location != NSNotFound){
            [[[UIAlertView alloc] initWithTitle:@"Failed to connect securely" message:@"It looks like your domain does not have it's own SSL certificate, type the Cpanel server address in the additional field above" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil ,nil] show];
            [serverField setHidden:NO];
        }else{
            [[[UIAlertView alloc] initWithTitle:serv message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil ,nil] show];
        }

    }
}

-(void)addPhp
{
    NSError *err;
    NSString *xmlphp = [urlField.text stringByAppendingPathComponent:@"xml.php"];
    if ([xmlphp rangeOfString:@"http"].location != 0)  xmlphp = [NSString stringWithFormat:@"http://%@",xmlphp];
    NSString *xml = [NSString stringWithContentsOfURL:[NSURL URLWithString:xmlphp] encoding:NSUTF8StringEncoding error:&err];
    if (err)
    {
        NSLog(@"%@",err);
		[[[UIAlertView alloc] initWithTitle:@"Invalid url" message:@"Could not connect to the url given" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil ,nil] show];
    }else{
        if ([xml rangeOfString:@"tns:phpsysinfo"].location != NSNotFound)
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSMutableArray *accounts = [NSMutableArray arrayWithArray:[defaults objectForKey:@"accounts"]];
            [accounts addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"phpsysinfo",@"type",xmlphp,@"url",[self domainFromUrl:xmlphp],@"domain",[NSDate date],@"date", nil]];
            [defaults setObject:accounts forKey:@"accounts"];
            [defaults synchronize];
            [self.delegate addViewControllerDidFinish:self];
        }else{
            [[[UIAlertView alloc] initWithTitle:@"Invalid phpSysInfo installation" message:@"Make sure a up to date phpSysInfo installation exists" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil ,nil] show];
        }
    }
}
                             
-(NSString*)domainFromUrl:(NSString*)url
{
    NSArray *first = [url componentsSeparatedByString:@"/"];
    for (NSString *part in first) {
        if ([part rangeOfString:@"."].location != NSNotFound){
            return part;
        }
    }
    return nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    if ([theTextField isFirstResponder]) {
        //take focus away from the text field so that the keyboard is dismissed.
        [theTextField resignFirstResponder];
    }
    [self add:theTextField];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Dismiss the keyboard when the view outside the text field is touched.
    if ([urlField isFirstResponder]) [urlField resignFirstResponder];
    if ([serverField isFirstResponder]) [serverField resignFirstResponder];
    if ([domainField isFirstResponder]) [domainField resignFirstResponder];
    if ([usernameField isFirstResponder]) [usernameField resignFirstResponder];
    if ([passwordField isFirstResponder]) [passwordField resignFirstResponder];
    
}

@end

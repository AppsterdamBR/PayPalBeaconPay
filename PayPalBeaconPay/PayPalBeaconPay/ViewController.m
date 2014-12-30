//
//  ViewController.m
//  PayPalBeaconPay
//
//  Created by Tales Pinheiro De Andrade on 16/12/14.
//  Copyright (c) 2014 Tales Pinheiro De Andrade. All rights reserved.
//

#import "ViewController.h"
#import "PayPalPaymentViewController.h"
#import "PayPalMobile.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <PayPalPaymentDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong, readwrite) PayPalConfiguration *payPalConfiguration;
@property (strong, nonatomic) CLLocationManager *locationManager;



@end

@implementation ViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _payPalConfiguration = [[PayPalConfiguration alloc] init];
        [_payPalConfiguration setAcceptCreditCards:NO];
    }
    
    return self;
}

- (IBAction)pay:(id)sender {
    PayPalPayment *payPalPayment = [[PayPalPayment alloc] init];
    
    payPalPayment.amount = [[NSDecimalNumber alloc] initWithString:@"1.99"];
    payPalPayment.currencyCode = @"BRL";
    payPalPayment.shortDescription = @"Guarana Dolly";
    payPalPayment.intent = PayPalPaymentIntentSale;
    
    if (payPalPayment.processable) {
        PayPalPaymentViewController *payPalPaymentViewController = [[PayPalPaymentViewController alloc]initWithPayment:payPalPayment configuration:self.payPalConfiguration delegate:self];
        [self presentViewController:payPalPaymentViewController animated:YES completion:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentNoNetwork];
    

    
    self.locationManager = [[CLLocationManager alloc] init];
    
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined && [self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]){
        [self.locationManager requestAlwaysAuthorization];
    }
    
    [self.locationManager setDelegate:self];
    
    
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];

    CLBeaconRegion *region;

    region = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID  identifier:@"Estimote Region"];
    
    [self.locationManager startMonitoringForRegion:region];
    [self.locationManager startRangingBeaconsInRegion:region];
}



- (void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [self.locationManager startRangingBeaconsInRegion: (CLBeaconRegion *)region];
}


-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSLog(@"nummero de beacons %lu",(unsigned long)beacons.count );
    for (CLBeacon *beacon in beacons) {
        NSLog(@"%ld",beacon.proximity );
        if(beacon.proximity == CLProximityImmediate)
        {
            [self pay:nil];
            NSLog(@"Queimou");
        } else if(beacon.proximity == CLProximityNear){
            NSLog(@"Quente");
        } else {
            NSLog(@"Frio");

        }
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController
                 didCompletePayment:(PayPalPayment *)completedPayment {

    [self verifyPayment:completedPayment];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)verifyPayment:(PayPalPayment *)completedPayment
{
    NSDictionary *dic = [completedPayment.confirmation objectForKey: @"response"];
    NSString *str = [dic objectForKey:@"state"];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Pagamento" message:str delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
    
    [alert show];
}

@end

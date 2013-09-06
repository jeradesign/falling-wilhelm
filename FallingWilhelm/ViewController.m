//
//  ViewController.m
//  FallingWilhelm
//
//  Created by John Brewer on 9/5/13.
//  Copyright (c) 2013 Jera Design LLC. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
@property (retain, nonatomic) IBOutlet UILabel *fallingLabel;
@end

@implementation ViewController {
    CMMotionManager *_motionManager;
    NSOperationQueue *_operationQueue;
    BOOL _falling;
    AVAudioPlayer *_player;
}

static float euclidianDist(float x1, float y1, float z1,
                           float x2, float y2, float z2)
{
    float xdiff = x1 - x2;
    xdiff = xdiff * xdiff;

    float ydiff = y1 - y2;
    ydiff = ydiff * ydiff;

    float zdiff = z1 - z2;
    zdiff = zdiff * zdiff;

    return sqrt(xdiff + ydiff + zdiff);
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSURL *url = [[NSBundle mainBundle] URLForResource:@"WilhelmScream" withExtension:@"wav"];
    NSError *error;
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.accelerometerUpdateInterval = 0.01;
    _operationQueue = [[NSOperationQueue alloc] init];
    [_motionManager startAccelerometerUpdatesToQueue:_operationQueue
                                         withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                             CMAcceleration acc = accelerometerData.acceleration;
                                             float mag = euclidianDist(acc.x, acc.y, acc.z,
                                                                       0, 0, 0);
                                             if (mag < 0.5 && !_falling) {
                                                 _falling = YES;
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [self startFalling];
                                                 });
                                             } else if (mag > 0.5 && _falling) {
                                                 _falling = NO;
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [self stopFalling];
                                                 });
                                             }
                                         }];
}

- (void)startFalling
{
    _fallingLabel.text = @"Falling!";
    [_player play];
}

- (void)stopFalling
{
    _fallingLabel.text = @"Not Falling";
    [_player stop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_fallingLabel release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setFallingLabel:nil];
    [super viewDidUnload];
    [_motionManager stopAccelerometerUpdates];
}
@end

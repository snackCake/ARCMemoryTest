//
//  ViewController.m
//  ARCMemoryTest
//
//  Created by Joshua Klun on 4/7/13.
//  Copyright (c) 2013 Joshua Klun. All rights reserved.
//

#import "ViewController.h"

static const NSUInteger kSmallMemoryBlockSize =  1;
static const NSUInteger kMediumMemoryBlockSize = 1024;
static const NSUInteger kLargeMemoryBlockSize =  10 * 1024 * 1024;

static const NSUInteger kSmallBlockLoopSize =  50000;
static const NSUInteger kMediumBlockLoopSize = 5000;
static const NSUInteger kLargeBlockLoopSize =  500;

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UILabel *memWarningLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (strong) NSOperationQueue *testOperationQueue;
@property (strong) NSDate *startTime;
@property (strong) NSData *dataProp;
@property (strong) NSArray *arrayProp;
@property (strong) NSSet *setProp;
@property (strong) NSDictionary *dictionaryProp;

- (IBAction)smallFoundationTapped:(id)sender;
- (IBAction)mediumFoundationTapped:(id)sender;
- (IBAction)largeFoundationTapped:(id)sender;

- (IBAction)smallMonoComparisonTapped:(id)sender;
- (IBAction)mediumMonoComparisonTapped:(id)sender;
- (IBAction)largeMonoComparisonTapped:(id)sender;

- (void)performMemoryTest:(NSUInteger const)loopSize blockSize:(NSUInteger const)blockSize monoComparisonMode:(BOOL)monoComparisonMode;
- (void)allocateMemoryWithLoopSize:(NSUInteger const)loopSize blockSize:(NSUInteger const)blockSize monoComparisonMode:(BOOL)monoComparisonMode;
- (void)displayTimerResults;

@end

@implementation ViewController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.testOperationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.memWarningLabel.hidden = NO;
}

#pragma mark - Actions

- (IBAction)smallFoundationTapped:(id)sender
{
    [self performMemoryTest:kSmallBlockLoopSize blockSize:kSmallMemoryBlockSize monoComparisonMode:NO];
}

- (IBAction)mediumFoundationTapped:(id)sender
{
    [self performMemoryTest:kMediumBlockLoopSize blockSize:kMediumMemoryBlockSize monoComparisonMode:NO];
}

- (IBAction)largeFoundationTapped:(id)sender
{
    [self performMemoryTest:kLargeBlockLoopSize blockSize:kLargeMemoryBlockSize monoComparisonMode:NO];
}

- (IBAction)smallMonoComparisonTapped:(id)sender
{
    [self performMemoryTest:kSmallBlockLoopSize blockSize:kSmallMemoryBlockSize monoComparisonMode:YES];
}

- (IBAction)mediumMonoComparisonTapped:(id)sender
{
    [self performMemoryTest:kMediumBlockLoopSize blockSize:kMediumMemoryBlockSize monoComparisonMode:YES];
}

- (IBAction)largeMonoComparisonTapped:(id)sender
{
    [self performMemoryTest:kLargeBlockLoopSize blockSize:kLargeMemoryBlockSize monoComparisonMode:YES];
}

#pragma mark - Memory Tests

- (void)performMemoryTest:(NSUInteger const)loopSize blockSize:(NSUInteger const)blockSize monoComparisonMode:(BOOL)monoComparisonMode
{
    __strong __typeof(&*self)weakSelf = self;
    NSOperation *testOperation = [NSBlockOperation blockOperationWithBlock:^{
        weakSelf.startTime = [NSDate date];
        [weakSelf allocateMemoryWithLoopSize:loopSize blockSize:blockSize monoComparisonMode:monoComparisonMode];
        [weakSelf performSelectorOnMainThread:@selector(displayTimerResults) withObject:nil waitUntilDone:NO];
    }];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self.testOperationQueue addOperation:testOperation];
}

- (void)allocateMemoryWithLoopSize:(NSUInteger const)loopSize
                         blockSize:(NSUInteger const)blockSize
                monoComparisonMode:(BOOL)monoComparisonMode
{
    for (NSUInteger i = 0; i < loopSize; i++) {
        NSData *data = [[NSMutableData alloc] initWithCapacity:blockSize];
        NSArray *array = [[NSMutableArray alloc] initWithCapacity:blockSize];
        if (monoComparisonMode) {
            NSDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:blockSize];
            self.dictionaryProp = dictionary;
        } else {
            NSSet *set = [[NSMutableSet alloc] initWithCapacity:blockSize];
            self.setProp = set;
        }
        self.dataProp = data;
        self.arrayProp = array;
    }
}

#pragma mark - Display Results

- (void)displayTimerResults
{
    self.timeLabel.text = [NSString stringWithFormat:@"%.5f", -[self.startTime timeIntervalSinceNow]];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

@end

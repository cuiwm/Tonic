//
//  SynthChooserViewController.m
//  TonicDemo
//
//  Created by Nick Donaldson on 2/8/13.
//  Copyright (c) 2013 Morgan Packard. All rights reserved.
//

#import "SynthChooserViewController.h"
#import "SynthTestViewController.h"
#import "SineSumSynth.h"
#import "SineAMSynth.h"
#import "FMDroneSynth.h"
#import "FilterTest.h"

// Just going to hard-code everything for now based on enum

enum {
  SynthChooserSineSum = 0,
  SynthChooserSineAM,
  SynthChooserFMDrone,
  SynthChooserTestFilt,
  SynthChooserNumChoices
  
};

@interface SynthChooserViewController ()

@end

@implementation SynthChooserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Choose a synth";
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setSynthTableView:nil];
    [super viewDidUnload];
}

#pragma mark - TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 76;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  NSString *synthName = nil;
  NSString *description = nil;
  SynthTestPanAction action = nil;
  
  switch(indexPath.row){
    case SynthChooserSineSum:
      synthName = @"SineSumSynth";
      description = @"Swipe up and down to change \"spread\" of additive sines.";
      action = ^(Tonic::Synth* synth, CGPoint touchPointNorm){
        SineSumSynth *ss = (SineSumSynth*)synth;
        TonicFloat spread = powf(touchPointNorm.y, 2.0f);
        ss->setSpread(spread);
      };
      break;
      
    case SynthChooserSineAM:
      synthName = @"SineAMSynth";
      description = @"Swipe up and down to change modulator freq. Swipe L/R to change carrier freq.";
      action = ^(Tonic::Synth* synth, CGPoint touchPointNorm){
        
        // arbitrarily chosen midi note numbers (linear pitch)
        TonicFloat car = Tonic::mtof(Tonic::map(touchPointNorm.x, 0.0f, 1.0f, 47, 88));
        
        // exponenetial sweep in frequency, 0-1000 Hz
        TonicFloat mod = 1000.0f / powf(10.0f, Tonic::map(touchPointNorm.y, 0.0f, 1.0f, 3.0f, 0.0f));

        synth->sendMessage("carrierFreq", car);
        synth->sendMessage("modFreq", mod);
      };
      break;
      
    case SynthChooserFMDrone:
      synthName = @"FMDroneSynth";
      description = @"FM Synth";
      action = ^(Tonic::Synth* synth, CGPoint touchPointNorm){
        synth->sendMessage("carrierFreq", Tonic::map(touchPointNorm.x, 0.0f, 1.0f, 100, 500));
        synth->sendMessage("modIndex", Tonic::map(touchPointNorm.y*touchPointNorm.y, 0.0f, 1.0f, 0.0f, 2.0f));
      };
      break;
      
    case SynthChooserTestFilt:
      synthName = @"FilterTest";
      description = @"X Axis: cutoff\nY Axis: LFO";
      action = ^(Tonic::Synth* synth, CGPoint touchPointNorm){
        synth->sendMessage("cutoff", 120.0f * powf(10.0f, touchPointNorm.x * 2));
        synth->sendMessage("LFO", touchPointNorm.y * 200);
      };
      break;
      
    default:
      break;
      
  }
  
  if (synthName){
    SynthTestViewController *stVC = [[SynthTestViewController alloc] initWithSynthName:synthName description:description panAction:action];
    [self.navigationController pushViewController:stVC animated:YES];
  }
}

#pragma mark - Table View Data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return SynthChooserNumChoices;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SynthChoiceCell"];
  if (cell == nil){
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SynthChoiceCell"];
    
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:14];
    cell.detailTextLabel.numberOfLines = 0;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
  }

  // All hard-coded for now
  NSString *synthName = nil;
  NSString *synthDesc = nil;

  switch(indexPath.row){
    case SynthChooserSineSum:
      synthName = @"10-Sine Additive Spread";
      synthDesc = @"10 sinewave oscillators diverging from central frequency";
      break;
      
    case SynthChooserSineAM:
      synthName = @"Basic Sinusoidal AM";
      synthDesc = @"Basic AM synth with sinusoidal carrier and modulator";
      break;
      
    case SynthChooserFMDrone:
      synthName = @"FM Drone";
      synthDesc = @"Basic FM synth with sinusoidal carrier and modulator";
      break;
      
    case SynthChooserTestFilt:
      synthName = @"Filter Test";
      synthDesc = @"Test of filter implementations.";
      break;
      
    default:
      break;
      
  }

  cell.textLabel.text = synthName;
  cell.detailTextLabel.text = synthDesc;

  return  cell;
}

@end

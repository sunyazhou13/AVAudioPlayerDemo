//
//  ViewController.m
//  AVAudioPlayerDemo
//
//  Created by sunyazhou on 2017/3/16.
//  Copyright © 2017年 Baidu, Inc. All rights reserved.
//

#import "ViewController.h"
#import <Masonry/Masonry.h>

#import "THControlKnob.h"
#import "THPlayButton.h"
#import <AVFoundation/AVFoundation.h>


@interface ViewController ()

//三个控制推子
@property (weak, nonatomic) IBOutlet THOrangeControlKnob *panKnob;
@property (weak, nonatomic) IBOutlet THOrangeControlKnob *volumnKnob;
@property (weak, nonatomic) IBOutlet THGreenControlKnob *rateKnob;
@property (weak, nonatomic) IBOutlet THPlayButton *playButton;

//音乐播放器
@property (nonatomic, strong) AVAudioPlayer *musicPlayer;
@property (nonatomic, getter = isPlaying) BOOL playing; //播放状态

//无关代码
@property (weak, nonatomic) IBOutlet UILabel *LeftRightRoundDec;
@property (weak, nonatomic) IBOutlet UILabel *voiceDec;
@property (weak, nonatomic) IBOutlet UILabel *rateDec;
@property (weak, nonatomic) IBOutlet UILabel *trackDescrption;

@end

@implementation ViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if (self.musicPlayer == nil) {
            self.musicPlayer = [self createPlayForFile:@"384551_1438267683" withExtension:@"mp3"];
        }
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    if (self.musicPlayer == nil) {
        self.musicPlayer = [self createPlayForFile:@"384551_1438267683" withExtension:@"mp3"];
    }
}

- (void)dealloc {
    if (self.musicPlayer) { self.musicPlayer = nil; }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configSubviews]; //视图布局 不用care这行代码
    
    // Panning L = -1, C = 0, R = 1
    self.panKnob.minimumValue = -1.0f;
    self.panKnob.maximumValue = 1.0f;
    self.panKnob.value = 0.0;
    self.panKnob.defaultValue = 0.0;
    
    //  Volume Ranges from 0..1
    self.volumnKnob.minimumValue = 0.0f;
    self.volumnKnob.maximumValue = 1.0f;
    self.volumnKnob.value = 1.0;
    self.volumnKnob.defaultValue = 1.0;
    
}

#pragma mark -
#pragma mark - 创建AVAudioPlayer与播放状态控制
/**
 创建音乐播放器
 
 @param fileName 文件名
 @param fileExtension 文件扩展名
 @return 播放器实例
 */
- (AVAudioPlayer *)createPlayForFile:(NSString *)fileName
                       withExtension:(NSString *)fileExtension{
    NSURL *url = [[NSBundle mainBundle] URLForResource:fileName withExtension:fileExtension];
    NSError *error = nil;
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (audioPlayer) {
        audioPlayer.numberOfLoops = -1; //-1无限循环
        audioPlayer.enableRate = YES; //启动倍速控制
        [audioPlayer prepareToPlay];
    } else {
        NSLog(@"Error creating player: %@",[error localizedDescription]);
    }
    return audioPlayer;
}

- (void)play {
    if (self.musicPlayer == nil) { return; }
    
    if (!self.playing) {
        NSTimeInterval delayTime = [self.musicPlayer deviceCurrentTime] + 0.01;
        [self.musicPlayer playAtTime:delayTime];
        self.playing = YES;
    }
    self.trackDescrption.text = [self.musicPlayer.url absoluteString];
}
- (void)stop {
    if (self.musicPlayer == nil) { return; }
    if (self.playing) {
        [self.musicPlayer stop];
        self.musicPlayer.currentTime = 0.0f;
        self.playing = NO;
    }
}

- (void)pause {
    if (self.musicPlayer == nil) { return; }
    if (self.playing) {
        [self.musicPlayer pause];
        self.playing = NO;
    }
}


/**
 调整声音左右声道 实现声音左右环绕音效
 
 @param pan L = -1, C = 0, R = 1
 */
- (void)adjustPan:(float)pan {
    if (self.musicPlayer == nil) { return; }
    self.musicPlayer.pan = pan;
}


/**
 调整播放器音频音量 如果结合麦克风输入的peak值可实现
 声音的闪避效果

 @param volume 音量
 */
- (void)adjustVolume:(float)volume {
    if (self.musicPlayer == nil) { return; }
    self.musicPlayer.volume = volume;
}


/**
 调整声音倍速 比如 0.5x 1x  1.5x 2.0x (1x 正常倍速)

 @param rate 倍速速率
 */
- (void)adjustRate:(float)rate {
    if (self.musicPlayer == nil) { return; }
    self.musicPlayer.rate = rate;
}


#pragma mark - 
#pragma mark - 触发事件
- (IBAction)playAction:(THPlayButton *)sender {
    if (!self.isPlaying) {
        [self play];
    } else {
        [self stop];
    }
    self.playButton.selected = !self.playButton.selected;
}

- (IBAction)volumeAction:(THControlKnob *)sender {
    [self adjustVolume:sender.value];
}

- (IBAction)panAction:(THControlKnob *)sender {
    [self adjustPan:sender.value];
}

- (IBAction)rateAction:(THControlKnob *)sender {
    [self adjustRate:sender.value];
}



#pragma mark -
#pragma mark - 无关代码
- (void)configSubviews{
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).offset(100);
        make.width.height.equalTo(@120);
    }];
    
    [self.panKnob mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(20);
        make.width.height.equalTo(@80);
        make.top.equalTo(self.playButton.mas_bottom).offset(10);
    }];
    
    [self.LeftRightRoundDec mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.panKnob.mas_left);
        make.top.equalTo(self.panKnob.mas_bottom).offset(5);
        make.width.equalTo(@80);
        make.height.equalTo(@50);
    }];
    
    [self.volumnKnob mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.width.height.equalTo(self.panKnob);
        make.top.equalTo(self.panKnob.mas_top);
    }];
    
    [self.voiceDec mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.volumnKnob.mas_right);
        make.width.height.equalTo(self.LeftRightRoundDec);
        make.top.equalTo(self.volumnKnob.mas_bottom).offset(5);
    }];
    self.voiceDec.textAlignment = NSTextAlignmentRight;
    
    [self.rateKnob mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.playButton.mas_bottom).offset(80);
        make.width.height.equalTo(@100);
    }];
    
    [self.rateDec mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.rateKnob.mas_bottom).offset(10);
        make.width.equalTo(@120);
        make.height.equalTo(@20);
        make.centerX.equalTo(self.rateKnob.mas_centerX);
    }];
    
    [self.trackDescrption mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(10);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.bottom.equalTo(self.view.mas_bottom).offset(-10);
        make.height.equalTo(@25);
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

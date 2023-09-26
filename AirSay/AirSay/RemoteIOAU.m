//
//  RemoteIOAU.m
//  AirSay
//
//  Created by Vlad Alexa on 4/5/12.
//  Copyright (c) 2012 Next Design. All rights reserved.
//

#import "RemoteIOAU.h"

#define kOutputBus 0
#define kInputBus 1

void checkStatus (OSStatus status, char *msg)
{
    if (status == noErr) {
        //NSLog(@"Status ok");
    }else { 
        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        NSLog(@"%s Status error: %@",msg,[error localizedDescription]);        
    }
}

void SilenceData(AudioBufferList *inData)
{
	for (UInt32 i=0; i < inData->mNumberBuffers; i++){
		memset(inData->mBuffers[i].mData, 0, inData->mBuffers[i].mDataByteSize);
    }    
}


Float32 getMeterLevel(AudioComponentInstance audioUnit)
{   
    Float32 value = 0.0;
    OSStatus status = AudioUnitGetParameter(audioUnit, kMultiChannelMixerParam_PreAveragePower, kAudioUnitScope_Input, kInputBus, &value);
    checkStatus(status,"Could not get kMultiChannelMixerParam_PreAveragePower");
    return value;
}

float AudioBufferDecibels(UInt32 inNumberFrames,AudioBufferList *ioData)
{
    
#define DBOFFSET -74.0
    // DBOFFSET is An offset that will be used to normalize the decibels to a maximum of zero.
    // This is an estimate, you can do your own or construct an experiment to find the right value
#define LOWPASSFILTERTIMESLICE .001
    // LOWPASSFILTERTIMESLICE is part of the low pass filter and should be a small positive value
    
    SInt32* samples = (SInt32*)(ioData->mBuffers[0].mData); // Step 1: get an array of your samples that you can loop through. Each sample contains the amplitude.
    
    Float32 decibels = DBOFFSET; // When we have no signal we'll leave this on the lowest setting
    Float32 currentFilteredValueOfSampleAmplitude, previousFilteredValueOfSampleAmplitude = 1; // We'll need these in the low-pass filter
    Float32 peakValue = DBOFFSET; // We'll end up storing the peak value here
    
    for (int i=0; i < inNumberFrames; i++) { 
        
        Float32 absoluteValueOfSampleAmplitude = abs(samples[i]); //Step 2: for each sample, get its amplitude's absolute value.
        
        // Step 3: for each sample's absolute value, run it through a simple low-pass filter
        // Begin low-pass filter
        currentFilteredValueOfSampleAmplitude = LOWPASSFILTERTIMESLICE * absoluteValueOfSampleAmplitude + (1.0 - LOWPASSFILTERTIMESLICE) * previousFilteredValueOfSampleAmplitude;
        previousFilteredValueOfSampleAmplitude = currentFilteredValueOfSampleAmplitude;
        Float32 amplitudeToConvertToDB = currentFilteredValueOfSampleAmplitude;
        // End low-pass filter
        
        Float32 sampleDB = 20.0*log10(amplitudeToConvertToDB) + DBOFFSET;
        // Step 4: for each sample's filtered absolute value, convert it into decibels
        // Step 5: for each sample's filtered absolute value in decibels, add an offset value that normalizes the clipping point of the device to zero.
        
        if((sampleDB == sampleDB) && (sampleDB <= DBL_MAX && sampleDB >= -DBL_MAX)) { // if it's a rational number and isn't infinite
            
            if(sampleDB > peakValue) peakValue = sampleDB; // Step 6: keep the highest value you find.
            decibels = peakValue; // final value
        }
    }
    
    //NSLog(@"decibel level is %f", decibels);
    return decibels/50.0;
}

static OSStatus outputCallback(void *inRefCon, 
                                  AudioUnitRenderActionFlags *ioActionFlags, 
                                  const AudioTimeStamp *inTimeStamp, 
                                  UInt32 inBusNumber, 
                                  UInt32 inNumberFrames, 
                                  AudioBufferList *ioData) {    
    /*
    //make and malloc buffers
    AudioBuffer buffer;    
    size_t bytesPerSample = sizeof(float);    
    buffer.mNumberChannels = 1;
    buffer.mDataByteSize = inNumberFrames * bytesPerSample;
    buffer.mData = malloc(buffer.mDataByteSize);
    
    //put buffers in a AudioBufferList
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0] = buffer;
    */

    OSStatus status;
	RemoteIOAU *obj = (__bridge RemoteIOAU *) inRefCon;   
    AudioComponentInstance audioUnit = obj.audioUnit;
    status = AudioUnitRender(audioUnit, ioActionFlags, inTimeStamp, kInputBus, inNumberFrames, ioData);  
    checkStatus(status,"Could not route input to output");
    
    if (status == noErr) {
        float decibels = AudioBufferDecibels(inNumberFrames,ioData);      
        if (obj.micLevel == 0) {
            obj.micLevel = decibels;
        }else {
            float old = obj.micLevel;
            obj.micLevel = (old+decibels)/2.0;
        }           
        if (obj.micMuted == YES) {
            SilenceData(ioData);                    
        }        
    }  

    return noErr;    
}

static OSStatus inputCallback(void *inRefCon, 
                                 AudioUnitRenderActionFlags *ioActionFlags, 
                                 const AudioTimeStamp *inTimeStamp, 
                                 UInt32 inBusNumber, 
                                 UInt32 inNumberFrames, 
                                 AudioBufferList *ioData) {    
    // Notes: ioData contains buffers (may be more than one!)
    // Fill them up as much as you can. Remember to set the size value in each buffer to match how
    // much data is in the buffer.    
    
    return noErr;
}


@implementation RemoteIOAU

@synthesize audioUnit,micLevel,micMuted,micRouted;

- (id)init
{
    self = [super init];
    if (self) {
        
        [[AVAudioSession sharedInstance] setDelegate:self];
        
        NSError *setCategoryErr = nil;    
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:&setCategoryErr];
        if (setCategoryErr) NSLog(@"Error setting the general audio session category");
        
        NSError *activationErr  = nil;    
        [[AVAudioSession sharedInstance] setActive:YES error:&activationErr];    
        if (activationErr) NSLog(@"Error activating the customized audio session");          
        
        float freq = [[AVAudioSession sharedInstance] currentHardwareSampleRate];
        [self startListeningWithFrequency:freq];
    }
    return self;
}

- (void)beginInterruption
{
    //NSLog(@"intrerupted by another process");
    [self stopUnit];
}

- (void)dealloc
{
    AudioUnitUninitialize(audioUnit);
}

-(void)startListeningWithFrequency:(float)frequency
{
    OSStatus status;
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;    
    
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    status = AudioComponentInstanceNew( inputComponent, &audioUnit);
    checkStatus(status,"Could not create new remoteIO audio unit");
        
    //
    //format
    //
    
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate			= frequency;
    audioFormat.mFormatID			= kAudioFormatLinearPCM;
    audioFormat.mFormatFlags        = kAudioFormatFlagsCanonical | kAudioFormatFlagIsNonInterleaved | (kAudioUnitSampleFractionBits << kLinearPCMFormatFlagsSampleFractionShift);
    audioFormat.mFramesPerPacket	= 1;
    audioFormat.mChannelsPerFrame	= 2;
    audioFormat.mBitsPerChannel     = 8 * sizeof(AudioUnitSampleType);
	audioFormat.mBytesPerPacket     = sizeof(AudioUnitSampleType);
	audioFormat.mBytesPerFrame      = sizeof(AudioUnitSampleType);	    
    status = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, kInputBus, &audioFormat, sizeof(audioFormat));
    checkStatus(status,"Could not set the remote I/O unit's output client format");
    status = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, kOutputBus, &audioFormat, sizeof(audioFormat));
    checkStatus(status,"Could not set the remote I/O unit's input client format");
    
    //
    //callbacks
    //
    AURenderCallbackStruct callbackStruct;
    
    callbackStruct.inputProc = inputCallback;
    callbackStruct.inputProcRefCon = (__bridge void*)self;    
    status = AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Output, kInputBus, &callbackStruct, sizeof(callbackStruct));
    checkStatus(status,"Could not set input callback (not used)");
    
    callbackStruct.inputProc = outputCallback;
    callbackStruct.inputProcRefCon = (__bridge void*)self;
    status = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, kOutputBus, &callbackStruct, sizeof(callbackStruct)); 
    checkStatus(status,"Could not set output callback (remote i/o render callback)");    
    
    //
    //settings
    //
    
    UInt32 flag = 1;
    status = AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, kInputBus, &flag, sizeof(flag));
    checkStatus(status,"Could not enable IO for the recorder");
    
    //flag = 0;
    //status = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_ShouldAllocateBuffer, kAudioUnitScope_Input, kInputBus, &flag, sizeof(flag));
    //checkStatus(status,"Could not disable buffer allocation for the recorder (optional - do this if we want to pass in our own)");   
    
    //flag = 1;
    //status = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_MeteringMode, kAudioUnitScope_Global, kInputBus, &flag, sizeof(flag));
    //checkStatus(status,"Could not enable metering for the recorder");   
    
        
    status = AudioUnitInitialize(audioUnit);
    checkStatus(status,"Could not initialize audio uint");    
    
    status = AudioSessionSetActive(true);
    checkStatus(status,"Could not set audio session active");

    if (status == noErr) [self startUnit];
   
}

-(void)stopUnit
{
    OSStatus status = AudioOutputUnitStop(audioUnit);
    checkStatus(status,"Could not stop audio unit");
    if (status == noErr) {
        micRouted = NO;
        NSLog(@"Stopped routing %@",[self routeName]);
    }
}

-(void)startUnit
{
    OSStatus status = AudioOutputUnitStart(audioUnit);
    checkStatus(status,"Could not start audio unit"); 
    if (status == noErr) {
        micRouted = YES;
        NSLog(@"Started routing %@",[self routeName]);    
    }    
}

#pragma mark tools


-(void)setSpeakerDefault
{
    OSStatus error;    
    UInt32 doChangeDefaultRoute = 1;
    error = AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof (doChangeDefaultRoute), &doChangeDefaultRoute);
    if (error) NSLog(@"Couldn't make the speaker the default sound route for the session");   
}

-(void)setSpeaker
{
    OSStatus error;
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker; 
    error = AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof (audioRouteOverride), &audioRouteOverride);
    if (error) NSLog(@"Couldn't route audio to speaker");
}

-(BOOL)audioIsAlreadyPlaying
{
    UInt32 propertySize, audioIsAlreadyPlaying=0;	
    propertySize = sizeof(UInt32);
    AudioSessionGetProperty(kAudioSessionProperty_OtherAudioIsPlaying, &propertySize, &audioIsAlreadyPlaying);
    if (audioIsAlreadyPlaying == 0) {
        return NO;
    }else {
        return YES;
    }
}

-(NSString*)routeName
{
    //Headset, Receiver, Speaker, SpeakerAndMicrophone, HeadsetInOut
    CFStringRef newRoute = nil;
    UInt32 size = sizeof(CFStringRef);
    OSStatus error = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &newRoute);
    if (error) {
        NSLog(@"Error getting destinations"); 
    }else {
        return (__bridge_transfer NSString*)newRoute;
    }    
    return nil;
}

-(NSArray*)outputDestinations
{
    CFArrayRef destinations = nil;
    UInt32 size = sizeof(CFArrayRef);        
    OSStatus error = AudioSessionGetProperty(kAudioSessionProperty_OutputDestinations, &size, &destinations);
    if (error) { 
        NSLog(@"Error getting destinations");
    }else {
        return (__bridge_transfer NSArray*)destinations;
    }    
    return nil;
}


-(NSNumber*)outputDestination
{
    CFNumberRef currentDest = nil;
    UInt32 size = sizeof(CFNumberRef);    
    OSStatus error = AudioSessionGetProperty(kAudioSessionProperty_OutputDestination, &size, &currentDest);  
    if (error){
        NSLog(@"Error getting destination"); 
    }else {
        return (__bridge_transfer NSNumber*)currentDest;
    }    
    return nil;
}


@end

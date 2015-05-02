/*
 * AudioFilter:
 * 
 * Processing App to demonstrate the effects of different audio filters (lowpass/highcut, highpass/lowcut and bandpass)
 * to an audio file. The cutoff-frequency is taken from the mouse position, bandwith for bandpass filter is always 600Hz.
 * Use keys 'l', 'h', and 'b' to switch the different filters. Gain (for frequency visualization) can be modified with + and - keys.
 *
 *
 * Max Stricker, www.maxstricker.it
 * based on Dan Ellis Playback_BPF
 */

import ddf.minim.analysis.*;
import ddf.minim.*;
import ddf.minim.effects.*;

Minim minim;
AudioPlayer sound;

BandPass bpf;
LowPassSP lpf;
HighPassSP hpf;
IIRFilter currentFilter; // BandPass, LowPassSP and HighPassSP implement IIRFilter

FFT fft;
float centerFreq;
float bandwidth;
float gain = 20;
int spectrumScale = 2; // pixels per FFT bin

void setup(){
  size(512, 200);
  textFont(createFont("SanSerif", 12));
  
  minim = new Minim(this);
  minim.debugOn();
  // Lyonn -  Empty Bed
  // taken from https://www.jamendo.com/de/list/a145856/we-ll-light-the-sky
  sound = minim.loadFile("Lyonn_-_Empty_Bed.mp3");
  sound.loop();

  //default values:
  centerFreq = 440; //changes with mouse position
  bandwidth = 600; //always fixed

  lpf = new LowPassSP(centerFreq, sound.sampleRate());
  hpf = new HighPassSP(centerFreq, sound.sampleRate());
  bpf = new BandPass(centerFreq, bandwidth, sound.sampleRate());
  currentFilter = lpf;
  sound.addEffect(currentFilter);

  fft = new FFT(sound.bufferSize(), sound.sampleRate());
  fft.window(FFT.HAMMING);
}

void mouseMoved(){
  // map the mouse position to the range [100, 10000], an arbitrary range of passBand frequencies
  centerFreq = map(mouseX, 0, width, 0, sound.sampleRate()/(2*spectrumScale));
  currentFilter.setFreq(centerFreq);
}


void draw(){
  background(255);
  fft.forward(sound.mix);
  fill(64,192,255);
  noStroke();
  //visualize frequency
  for(int i = 0; i < fft.specSize(); i++){
    // draw the line for frequency band i using dB scale
    float val = 2*(20*((float)Math.log10(fft.getBand(i))) + gain);
    rect(i*spectrumScale, height, spectrumScale, -Math.round(val));
  }
  fill(255, 0, 0, 80);
  //visualize text for the corresponding filter
  if(currentFilter==bpf){
    rect(mouseX-bpf.getBandWidth()/20, 0, bpf.getBandWidth()/10, height);
    fill(0);
    text("BandPass Filter: Center frequency="+Math.round(centerFreq)+" Hz bw="+Math.round(bandwidth), 5, 20);
  }else{
    rect(mouseX-5, 0, 10, height);
    fill(0);
    String filterType = "HighPass Filter"; if(currentFilter==lpf) filterType = "LowPass Filter";
    text(filterType+": CutOff frequency="+Math.round(centerFreq)+" Hz",5,20);
  }
}

// +/- to adjust gain (just for visualization
// h for highpass, l for lowpass, b for bandpass filters
void keyReleased(){
  if(key=='+'){
    gain = gain+3.0;
  }else if(key=='-'){
    gain = gain-3.0;
  }else if(key=='h'){
    currentFilter=hpf;
    sound.noEffects();
    sound.addEffect(currentFilter);
  }else if(key=='l'){
    currentFilter=lpf;
    sound.noEffects();
    sound.addEffect(currentFilter);
  }else if(key=='b'){
    currentFilter=bpf;
    sound.noEffects();
    sound.addEffect(currentFilter);
  }
}

void stop()
{
  sound.close();
  minim.stop();
  super.stop();
}



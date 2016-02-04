/*
  Conditioning
  to regulate camera, CS (LED, tone, whisker puff, ...), US. 
  This progrlam allow trace conditioning and high framerate acquisition of camera data.
 */
 
// Pin 13 has an LED connected on most Arduino boards.
// give it a name:


int camera=8;
int led = 9;
int whisker = 10;
int oscillo=11;
int electrical = 12;
int puff = 13;
int tonech = DAC0;

int campretime=200;
int cs = 500;
int csch = 1;
int ISI = 200;
int us = 20;
// int residual;
int tonefreq5 = 1;
float tone_amp = 1;
int val_DAC=0;


/////////////////////////////////
int phase_trial=0;  //0, bofre trial. 1, in trial. 2, after trial
//int phase_camera=0;  // odd, ON. even, OFF.
//int phase_cs=0;
//int phase_puff=0;
unsigned long time_now=0;
unsigned long time_start=0;
unsigned long time_csonset=0;
unsigned long time_usonset=0;
unsigned long time_csonset_us=0;
int time_passed=0;
int time_from_csonset=0;
int trial_dur=2000;

int cam_fps=200;
int cam_dur=1000;
//int cam_pulse_wid=1;
int cam_pulse_int=5;
int cam_pulse_num=1;
int cam_dio=0;
int cam_dio_old=0;

int osc_dio=0;
int osc_dio_old=0;

int cs_dio=0;
int cs_dio_old=0;

int puff_dio=0;
int puff_dio_old=0;

int el_pulse_wid=1;
int el_pulse_int=5;
int el_pulse_num=67;
int el_dio=0;
int el_dio_old=0;
/////////////////////////////////


// the setup routine runs once when you press reset:
void setup() {                
  // initialize the digital pin as an output.
  pinMode(oscillo, OUTPUT); 
  pinMode(camera, OUTPUT); 
  pinMode(led, OUTPUT);     
  pinMode(whisker, OUTPUT);  
  pinMode(electrical, OUTPUT);  
  pinMode(puff, OUTPUT);  
  Serial.begin(9600);
  analogWriteResolution(12);
  InitTrial();
}

// the loop routine runs over and over again forever:
void loop() {
  // Consider using attachInterrupt() to allow better realtime control of starting and stopping, etc.
  
  if (phase_trial !=1)   checkVars();
  
  if (phase_trial ==0)  { // trigger
    if (Serial.available()>0) {
      if (Serial.peek()==1) {  // This is the header for triggering; difference from variable communication is that only one byte is sent telling to trigger
        Serial.read();  // Clear the value from the buffer
        
        time_start=millis();
        InitTrial();
        phase_trial=1;
      }
    }  
  } // end of trigger
  
  ///// trial ////
  if (phase_trial ==1) {
    time_now=millis();
    time_passed=time_now-time_start;
    
    /// for camera ///
    cam_dio=PulseController(time_start, time_now, cam_pulse_int, 1, cam_pulse_num);
    if (cam_dio-cam_dio_old==1) {  digitalWrite(camera, HIGH);
    } else if (cam_dio-cam_dio_old==-1) {  digitalWrite(camera, LOW);  }
    cam_dio_old=cam_dio;
    
    /// for oscilloscope ///
    osc_dio=PulseController(time_csonset, time_now, 2*cs, cs, 1);
    if (osc_dio-osc_dio_old==1) {  digitalWrite(oscillo, HIGH);
    } else if (osc_dio-osc_dio_old==-1) {   digitalWrite(oscillo, LOW);  }
    osc_dio_old=osc_dio;
    
    if (cs>0){
      cs_dio=PulseController(time_csonset, time_now, 2*cs, cs, 1);
      if (csch<5){
        if (cs_dio-cs_dio_old==1) {
          if (csch==1) { digitalWrite(led, HIGH);   // turn the LED on (HIGH is the voltage level)
          } else if (csch==2) { digitalWrite(whisker, HIGH); }
        } else if (cs_dio-cs_dio_old==-1) {
          if (csch==1) { digitalWrite(led, LOW);   // turn the LED off (LOW is the voltage level)
          } else if (csch==2) { digitalWrite(whisker, LOW); }
        }
      }
      
      if (csch>=5 & csch<=6){
        if (cs_dio-cs_dio_old==1) {
          time_csonset_us=micros();
        } else if (cs_dio==1){
          val_DAC = (int)(tone_amp * toneDAC(tonefreq5, micros()-time_csonset_us));   // turn the LED on (HIGH is the voltage level)
          if (val_DAC<0) {val_DAC=0;}
          if (val_DAC>4095) {val_DAC=4095;}
          //val_DAC = 4000;
          analogWrite(tonech, val_DAC);
        } else if (cs_dio-cs_dio_old==-1) {
          analogWrite(tonech, 0);
        }
      }
      
      cs_dio_old=cs_dio;
    }
    
    if (csch==7) { // for electrical CS
        el_dio=PulseController(time_csonset, time_now, el_pulse_int, el_pulse_wid, el_pulse_num);
        if (el_dio-el_dio_old==1) {  digitalWrite(electrical, HIGH);
        } else if (el_dio-el_dio_old==-1) {  digitalWrite(electrical, LOW);  }
        el_dio_old=el_dio;
    }
    
    
    if (us > 0){
      puff_dio=PulseController(time_usonset, time_now, 2*us, us, 1);
      if (puff_dio-puff_dio_old==1) {  digitalWrite(puff, HIGH);
      } else if (puff_dio-puff_dio_old==-1) {  digitalWrite(puff, LOW);  }
      puff_dio_old=puff_dio;
    }
    
    if (time_passed>=trial_dur)  { // trial end
      InitTrial();
    }
  
  }
  
  delayMicroseconds(5);
}

// For DIO, this function return TTL (0 or 1). 
int PulseController(unsigned long pulseonsettime, unsigned long time_now, int pulseinterval, int pulsewidth, int pulsenum) {
  int digital=0;
  int time_past=0;
  int num_current=0;
  int time_from_pulse_onset=0;
  
  time_past=time_now-pulseonsettime;
  num_current=time_past/pulseinterval;
  time_from_pulse_onset=time_past%pulseinterval;
  
  if (num_current>=0 && time_from_pulse_onset>=0 && time_from_pulse_onset<pulsewidth && num_current<pulsenum) {
    digital=1;
  } else {
    digital=0;
  }
  return digital;
}


void InitTrial() {
  phase_trial=0;
  digitalWrite(oscillo, LOW);
  digitalWrite(camera, LOW);
  digitalWrite(led, LOW); 
  digitalWrite(whisker, LOW);
  digitalWrite(puff, LOW); 
  digitalWrite(electrical, LOW);
  analogWrite(tonech, 0);
  cam_dio=0;
  cam_dio_old=0;
  osc_dio=0;
  osc_dio_old=0;
  cs_dio=0;
  cs_dio_old=0;
  puff_dio=0;
  puff_dio_old=0;
  el_dio=0;
  el_dio_old=0;
  
  time_csonset = time_start+(unsigned long)campretime;  // for oscilloscope & CS
  time_usonset = time_start+(unsigned long)(ISI+campretime);  // for US
  
  el_pulse_num=cs/el_pulse_int;
  cam_pulse_int=1000/cam_fps;
//  cam_pulse_num=cam_dur/cam_pulse_int; // necessary for high framerate
}


// Check to see if Matlab is trying to send updated variables
void checkVars() {
  int header;
  int value;
   // Matlab sends data in 3 byte packets: first byte is header telling which variable to update, 
   // next two bytes are the new variable data as 16 bit int
   // Header is coded numerically such that 1=trigger, 2=continuous, 3=CS channel, 4=CS dur, 
   // 0 is reserved for some future function, possibly as a bailout (i.e. stop reading from buffer).
   while (Serial.available() > 2) {
     header = Serial.read();
     value = Serial.read() | Serial.read()<<8;
     
     if (header==0) {
       break;
     }
     
     switch (header) {
      case 3:
        campretime=value;
        break;
      case 4:
        csch=value;
        break;
      case 5:
        cs=value;
        break;
      case 6:
        us=value;
        break; 
      case 7:
        ISI=value;
        break;
      case 8:
        tonefreq5=value; // kHz
        break;
      case 9:
        cam_fps = value;
        break;
      case 10:
        el_pulse_int = value;
        break;
     }
     
     delay(4); // Delay enough to allow next 3 bytes into buffer (24 bits/9600 bps = 2.5 ms, so double it for safety).
  }

}


float toneDAC(int freq, int time_from_csonset) {// freq = kHz, time = us
  const float pi = 3.14159265359;
  int deg=0;
  float pure_tone[] = {0,123,477,1020,1686,2394,3060,3602,3957,4080,3957,3602,3060,2394,1686,1020,477,123,0};
  
  if (freq<=39) { // for pure tone
    // return (int)(2040*(1-cos(pi*(float)(2*freq*time_from_csonset)/1000)));
    deg=(int)(360*freq*time_from_csonset/1000)%360;
    return pure_tone[(int)(deg/20)];
  } else {  // for white noise
    return random(4096);
  }
}


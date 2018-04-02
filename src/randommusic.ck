//Input variables - To be changed by user!
"F" => string key; //Select a key. Do not use double sharps or flats
"Major" => string mode; //Major or Minor
"Pop/Rock" => string style; //Choose a style: Classical, Pop/Rock, or Blues
160 => int tempo; //Select a tempo. Advised not to exceed 200.
4 => int timesig; //Choose a time signature. Enter as single number e.g. 4 for 4/4, 3 for 3/4, etc.

//Get global variables
GetTempo(tempo) => dur beatdur; //Determine the duration of a beat using the input tempo
GetStructure() @=> int structure[]; //Generate a song structure
GetChords(key, mode, 0) @=> int chordslo[][]; //Get chords for the selected key
GetChords(key, mode, 1) @=> int chordshi[][]; //Get the same chords shifted up an octave
GetProgression(style) @=> int prog[]; //Use style input to get a chord progression
GetScale(key, mode, style) @=> int scale[]; //Get a scale appropriate for the desired style in the selected key
GetMelody(prog, timesig, scale) @=> int melody[]; //Get a melody to be used in the chorus sections
GetDrums() @=> string set[]; //Load a set of drum sounds
GetRhythms(timesig, 3) @=> int drumbeats[][]; //Get three rhythms, one for each drum sound
prog.cap() => int measures; //Determine the number of measures in the chord progression
beatdur * timesig * measures => dur length; //Determine the length of time required to move through one progression
 
int newprog[]; //Initialize an array for a new progression, which will be used later
int newdrumbeats[][]; //Initialize a 2-D array for a new set of drumbeats, which will be used later

Math.random2(1,2) => int chorusfeel; //Chorus will randomly be either regular or half-time
Math.random2(1,2) => int versefeel; //Verses will be either full or half-time
Math.random2(0,2) => int bassinstr; //Randomly choose a bass instrument for the song
Math.random2(0,4) => int harminstr1; //Randomly choose a harmony instrument for the song
Math.random2(0,4) => int harminstr2; //Randomly choose another harmony instrument for the song
Math.random2(0,2) => int leadinstr; //Randomly choose a lead instrument for the song

Shred harm1; //Initialize shreds for two harmony parts, three drum sounds, bass, and lead voices
Shred harm2;
Shred drum0;
Shred drum1;
Shred drum2;
Shred bass;
Shred lead;


//MAIN LOOP - Will play and repeat each section according to the values in the structure array

//Always start with a chorus
PlayChorus(structure[0]);

for(1 => int i; i < structure.cap(); 2 +=> i) //Trade verses and choruses
{                                             //Number of repetitions is determined by structure array
    PlayVerse(structure[i]);
    PlayChorus(structure[i+1]);
}
//Always end with a cadence
PlayCadence();


//FUNCTIONS
//Index of functions:
//PlayCadence()??????..line 79
//PlayChorus()???????..line 99
//PlayVerse()?????????.line 132
//PlayDrum()?????????..line 167
//PlayBass()??????????.line 184
//PlayHarmony()???????.line 309
//PlayLead()??????????.line 684
//GetTempo()??????????.line 855
//GetStructure()???????line 861
//GetProgression()????.line 872
//GetChords()?????????.line 943
//GetScale()??????????.line 980
//GetDrums()??????????.line 1031
//GetRhythms()????????.line 1046
//GetMelody()?????????.line 1059

function void PlayCadence() //Function to play cadences
{
    "Cadence" => string section; //Tells certain functions to play cadence
    spork ~PlayDrum(set[0], drumbeats[0], beatdur/chorusfeel) @=> drum0; //Play same drums as chorus
    spork ~PlayDrum(set[1], drumbeats[1], beatdur/chorusfeel) @=> drum1;
    spork ~PlayDrum(set[2], drumbeats[2], beatdur/2) @=> drum2;
    spork ~PlayHarmony(harminstr1, chordslo, prog, beatdur/chorusfeel, timesig*chorusfeel, section) @=> harm1; //Play harmony 1
    spork ~PlayBass(bassinstr, chordslo, prog, beatdur, timesig, section) @=> bass; //Play bass
    if(style == "Classical") //If style is classical, play harmony 2
    {
        spork ~PlayHarmony(harminstr2, chordshi, prog, beatdur/chorusfeel, timesig*chorusfeel, section) @=> harm2;
    }
    
    if(style != "Classical") //If style is not classical, play lead part
    {
        spork ~PlayLead(leadinstr, scale, beatdur/chorusfeel, timesig*chorusfeel, melody, section) @=> lead;
    }
    beatdur * timesig => now; //Progress one measure
}

function void PlayChorus(int rep) //Function to play chorus. Takes in # of repetitions as input.
{                                 //Chorus will have the same melody, progression, and drumbeats every time it is run.
    "Chorus" => string section; //Identifies section as chorus to functions
    spork ~PlayDrum(set[0], drumbeats[0], beatdur/chorusfeel) @=> drum0; //Play drumbeats array rhythms for chorus
    spork ~PlayDrum(set[1], drumbeats[1], beatdur/chorusfeel) @=> drum1;
    spork ~PlayDrum(set[2], drumbeats[2], beatdur/2) @=> drum2;
    spork ~PlayBass(bassinstr, chordslo, prog, beatdur, timesig, section) @=> bass; //Play bass
    spork ~PlayHarmony(harminstr1, chordslo, prog, beatdur/chorusfeel, timesig*chorusfeel, section) @=> harm1; //Play harmony 1
    if(style == "Classical") //If style is classical, play harmony 2
    {
        spork ~PlayHarmony(harminstr2, chordshi, prog, beatdur/chorusfeel, timesig*chorusfeel, section) @=> harm2;
    }
    
    if(style != "Classical") //If style is not classical, play lead part
    {
        spork ~PlayLead(leadinstr, scale, beatdur/chorusfeel, timesig*chorusfeel, melody, section) @=> lead;
    }
    rep * length => now; //Progress through chord progression # of times specified by input
    Machine.remove(drum0.id()); //Remove all shreds, otherwise they will continue to play when PlayVerse() is called
    Machine.remove(drum1.id());
    Machine.remove(drum2.id());
    Machine.remove(bass.id());
    Machine.remove(harm1.id());
    if(style == "Classical")
    {
        Machine.remove(harm2.id());
    }
    if(style != "Classical")
    {
        Machine.remove(lead.id());
    }
}

function void PlayVerse(int rep) //Function to play verses. Takes in # of repetitions as input.
{                                //Unlike chorus, verse will be different every time it is run, except for instrumentation.
    "Verse" => string section; //Identifies section as verse to functions
    GetProgression(style) @=> newprog; //Get a new chord progression each time verse is run
    GetRhythms(timesig, 3) @=> newdrumbeats; //Get new drum rhythms each time verse is run
    spork ~PlayDrum(set[0], newdrumbeats[0], beatdur/versefeel) @=> drum0; //Play newdrumbeats
    spork ~PlayDrum(set[1], newdrumbeats[1], beatdur/versefeel) @=> drum1;
    spork ~PlayDrum(set[2], newdrumbeats[2], beatdur/2) @=> drum2;
    spork ~PlayBass(bassinstr, chordslo, newprog, beatdur, timesig, section) @=> bass; //Play bass
    spork ~PlayHarmony(harminstr1, chordslo, newprog, beatdur/versefeel, timesig*versefeel, section) @=> harm1; //Play harmony 1
    if(style == "Classical") //If style is classical, play another harmony part
    {
        spork ~PlayHarmony(harminstr2, chordshi, newprog, beatdur/versefeel, timesig*versefeel, section) @=> harm2;
    }
    
    if(style != "Classical") //If style is not classical, play lead part
    {
        spork ~PlayLead(leadinstr, scale, beatdur/versefeel, timesig*versefeel, melody, section) @=> lead;
    }
    rep * length => now; //Progress through chord progression # of times specified by input
    Machine.remove(drum0.id()); //Remove all shreds, otherwise they will continue to play when PlayChorus() is called
    Machine.remove(drum1.id());
    Machine.remove(drum2.id());
    Machine.remove(bass.id());
    Machine.remove(harm1.id());
    if(style == "Classical")
    {
        Machine.remove(harm2.id());
    }
    if(style != "Classical")
    {
        Machine.remove(lead.id());
    }
}

function void PlayDrum(string drum, int rhythm[], dur beat) //Play a drum sample input with a rhythm
{
    while(true)
    {
        SndBuf play => dac; //Connect sndbuf to the dac
        0.2 => play.gain;
        drum => play.read; //Load the input sample
        play.samples() => play.pos; //Move to end of sample so nothing is heard initially
        for(0 => int i; i < rhythm.cap(); i++)
        {
            if(rhythm[i] == 1) 0 => play.pos; //Play sample whenever there is a 1 in the rhythm array
            beat => now; //Move forward one beat
        }
    }
}

//Bass part player function
function void PlayBass(int instrument, int chords[][], int prog[], dur beat, int timesig, string section)
{ //The following code is repeated for each possible bass instrument
    if (instrument == 0)
    {
        SqrOsc bass => Envelope e => dac; //Connect instrument to envelope to dac
        if(section == "Cadence") //Play only on cadence
        {
            e.target(0.1);
            Std.mtof(chords[4][0]) => bass.freq; //Play root of dominant chord
            beat => now;
            e.target(0.0);
            beat => now;
            e.target(0.1);
            Std.mtof(chords[0][0]) => bass.freq; //End on tonic
            2 * beat => now;
        }
        else //For chorus and verse sections
        {
            GetRhythms(timesig, 1) @=> int rhythm[][]; //Get a rhythm array using GetRhythm function
            while(true)
            {
                for(0 => int i; i < prog.cap(); i++) //Go through chord progression
                {
                    for(0 => int j; j < timesig; j++) //Go through measure
                    {
                        if(rhythm[0][j] == 1) //Play only on 1s in rhythm
                        {
                            e.target(0.1);
                            Std.mtof(chords[prog[i]-1][Math.random2(0,2)]-12) => bass.freq; //Play random note in chord
                            beat/2 => now;                                                  //shifted down an octave
                            e.target(0.0);
                            beat/2 => now; //Progress one beat
                        }
                        else //If 0 in rhythm, play nothing
                        {
                            beat => now; //Progress one beat
                        }
                    }
                }
            }
        }
    } 
    if (instrument == 1) //The following code is identical, albeit with different instruments
    {
        SawOsc bass => Envelope e => dac;
        if(section == "Cadence")
        {
            e.target(0.1);
            Std.mtof(chords[4][0]) => bass.freq;
            beat => now;
            e.target(0.0);
            beat => now;
            e.target(0.1);
            Std.mtof(chords[0][0]) => bass.freq;
            2 * beat => now;
        }
        else
        {
            GetRhythms(timesig, 1) @=> int rhythm[][];
            while(true)
            {
                for(0 => int i; i < prog.cap(); i++)
                {
                    for(0 => int j; j < timesig; j++)
                    {
                        if(rhythm[0][j] == 1)
                        {
                            e.target(0.1);
                            Std.mtof(chords[prog[i]-1][Math.random2(0,2)]-12) => bass.freq;
                            beat/2 => now;
                            e.target(0.0);
                            beat/2 => now;
                        }
                        else
                        {
                            beat => now;
                        }
                    }
                }
            }
        }   
    }
    if (instrument == 2)
    {
        TriOsc bass => Envelope e => dac;
        if(section == "Cadence")
        {
            e.target(0.1);
            Std.mtof(chords[4][0]) => bass.freq;
            beat => now;
            e.target(0.0);
            beat => now;
            e.target(0.1);
            Std.mtof(chords[0][0]) => bass.freq;
            2 * beat => now;
        }
        else
        {
            GetRhythms(timesig, 1) @=> int rhythm[][];
            while(true)
            {
                for(0 => int i; i < prog.cap(); i++)
                {
                    for(0 => int j; j < timesig; j++)
                    {
                        if(rhythm[0][j] == 1)
                        {
                            e.target(0.1);
                            Std.mtof(chords[prog[i]-1][Math.random2(0,2)]-12) => bass.freq;
                            beat/2 => now;
                            e.target(0.0);
                            beat/2 => now;
                        }
                        else
                        {
                            beat => now;
                        }
                    }
                }
            }
        }     
    }
}

//Harmony part player funciton
function void PlayHarmony(int instrument, int chords[][], int prog[], dur beat, int timesig, string section)
{ //The following code is repeated for each possible harmony instrument. In other words, it's ugly and really long
    if(instrument == 0)
    {
        PercFlut harmony[3]; //Initialize array of 3 identical UGens
        harmony[0] => dac.left; //Spread 3 voices over stereo field
        harmony[1] => dac;
        harmony[2] => dac.right;
        0.2 => harmony[0].gain;
        0.2 => harmony[1].gain;
        0.2 => harmony[2].gain;
        GetRhythms(timesig, 1) @=> int rhythm[][]; //Use GetRhythm function to get a rhythm
        while(true)
        {
            if(section == "Cadence") //Play only at cadence
            {
                harmony[0].noteOn(1); //Turn notes on
                harmony[1].noteOn(1);
                harmony[2].noteOn(1);
                Std.mtof(chords[4][0]) => harmony[0].freq; //Always play dominant chord to begin cadence
                Std.mtof(chords[4][1]) => harmony[1].freq;
                Std.mtof(chords[4][2]) => harmony[2].freq;
                (beat * timesig)/2 => now; //Progress half a measure
                Std.mtof(chords[0][0]) => harmony[0].freq; //Always finish on tonic
                Std.mtof(chords[0][1]) => harmony[1].freq;
                Std.mtof(chords[0][2]) => harmony[2].freq;
                (beat * timesig)/2 => now; //Half a measure
            }
            if(Math.random2(0,1) == 1 && section == "Verse") //Harmony will randomly play arpeggiations
            {                                                //But only during "verse" sections
                for(0 => int i; i < prog.cap(); i++) //Progress through chord progression
                {
                    for(0 => int j; j < timesig; j++) //Progress through measure
                    {
                        Math.random2(0,2) => int voice; //Only one voice will sound
                        Std.mtof(chords[prog[i]-1][Math.random2(0,2)] +    //Choose a random note in the chord and
                        (12 * Math.random2(-1,1))) => harmony[voice].freq; //play up, down, or on same octave
                        harmony[voice].noteOn(1); //Sound note
                        (beat - 1::samp) => now; //Progress one beat
                        harmony[voice].noteOff(1); //Turn note off
                        1::samp => now; //Progress 1 sample so note gets turned off before loop ends. This is  
                    }                   //important because if the shred is unsporked, the note won't be stuck on
                }
            }
            else //For the chorus section, and when the "verse" section isn't arpeggiating, just play chords
            {
                for(0 => int i; i < prog.cap(); i++) //Progress through chord progression
                {
                    for(0 => int j; j < timesig; j++) //Progress through measure
                    {
                        if(rhythm[0][j] == 1) //Play on the 1s in the rhythm array previously generated
                        {   
                            Std.mtof(chords[prog[i]-1][0] - 12 * Math.random2(0,1)) => harmony[0].freq; //Play chord
                            Std.mtof(chords[prog[i]-1][1] - 12 * Math.random2(0,1)) => harmony[1].freq; //Shift some notes
                            Std.mtof(chords[prog[i]-1][2] - 12 * Math.random2(0,1)) => harmony[2].freq; //down an octave
                            harmony[0].noteOn(1); //Turn voices on
                            harmony[1].noteOn(1);
                            harmony[2].noteOn(1);
                            (beat - 1::samp) => now; //Progress one beat
                            harmony[0].noteOff(1); //Turn voices off
                            harmony[1].noteOff(1);
                            harmony[2].noteOff(1);
                            1::samp => now; //Progress 1 sample so note gets turned off before loop ends
                        }
                        else //If rhythm value is 0, play a rest
                        {
                            harmony[0].noteOff(1); 
                            harmony[1].noteOff(1);
                            harmony[2].noteOff(1);
                            beat => now;  
                        }
                    }
                }
            }
        }
    }
    if(instrument == 1 ) //The remaining code is identical to the code above, albeit with different instruments
    {                    //See above comments
        Rhodey harmony[3];
        harmony[0] => dac.left;
        harmony[1] => dac;
        harmony[2] => dac.right;
        0.2 => harmony[0].gain;
        0.2 => harmony[1].gain;
        0.2 => harmony[2].gain;
        GetRhythms(timesig, 1) @=> int rhythm[][];
        while(true)
        {
            if(section == "Cadence")
            {
                harmony[0].noteOn(1);
                harmony[1].noteOn(1);
                harmony[2].noteOn(1);
                Std.mtof(chords[4][0]) => harmony[0].freq;
                Std.mtof(chords[4][1]) => harmony[1].freq;
                Std.mtof(chords[4][2]) => harmony[2].freq;
                (beat * timesig)/2 => now;
                Std.mtof(chords[0][0]) => harmony[0].freq;
                Std.mtof(chords[0][1]) => harmony[1].freq;
                Std.mtof(chords[0][2]) => harmony[2].freq;
                (beat * timesig)/2 => now;
            }
            if(Math.random2(0,1) == 1 && section == "Verse")
            {
                for(0 => int i; i < prog.cap(); i++)
                {
                    for(0 => int j; j < timesig; j++)
                    {
                        Math.random2(0,2) => int voice;
                        Std.mtof(chords[prog[i]-1][Math.random2(0,2)] + 
                        (12 * Math.random2(-1,1))) => harmony[voice].freq;
                        harmony[voice].noteOn(1);
                        (beat - 1::samp) => now;
                        harmony[voice].noteOff(1);
                        1::samp => now;
                    }
                }
            }
            else
            {
                for(0 => int i; i < prog.cap(); i++)
                {
                    for(0 => int j; j < timesig; j++)
                    {
                        if(rhythm[0][j] == 1)
                        {   
                            Std.mtof(chords[prog[i]-1][0] - 12 * Math.random2(0,1)) => harmony[0].freq;
                            Std.mtof(chords[prog[i]-1][1] - 12 * Math.random2(0,1)) => harmony[1].freq;
                            Std.mtof(chords[prog[i]-1][2] - 12 * Math.random2(0,1)) => harmony[2].freq;
                            harmony[0].noteOn(1);
                            harmony[1].noteOn(1);
                            harmony[2].noteOn(1);
                            (beat - 1::samp) => now;
                            harmony[0].noteOff(1);
                            harmony[1].noteOff(1);
                            harmony[2].noteOff(1);
                            1::samp => now;
                        }
                        else 
                        {
                            harmony[0].noteOff(1);
                            harmony[1].noteOff(1);
                            harmony[2].noteOff(1);
                            beat => now;  
                        }
                    }
                }
            }
        }
    }
    if(instrument == 2)
    {
        BeeThree harmony[3];
        harmony[0] => dac.left;
        harmony[1] => dac;
        harmony[2] => dac.right;
        0.2 => harmony[0].gain;
        0.2 => harmony[1].gain;
        0.2 => harmony[2].gain;
        GetRhythms(timesig, 1) @=> int rhythm[][];
        while(true)
        {
            if(section == "Cadence")
            {
                harmony[0].noteOn(1);
                harmony[1].noteOn(1);
                harmony[2].noteOn(1);
                Std.mtof(chords[4][0]) => harmony[0].freq;
                Std.mtof(chords[4][1]) => harmony[1].freq;
                Std.mtof(chords[4][2]) => harmony[2].freq;
                (beat * timesig)/2 => now;
                Std.mtof(chords[0][0]) => harmony[0].freq;
                Std.mtof(chords[0][1]) => harmony[1].freq;
                Std.mtof(chords[0][2]) => harmony[2].freq;
                (beat * timesig)/2 => now;
            }
            if(Math.random2(0,1) == 1 && section == "Verse")
            {
                for(0 => int i; i < prog.cap(); i++)
                {
                    for(0 => int j; j < timesig; j++)
                    {
                        Math.random2(0,2) => int voice;
                        Std.mtof(chords[prog[i]-1][Math.random2(0,2)] + 
                        (12 * Math.random2(-1,1))) => harmony[voice].freq;
                        harmony[voice].noteOn(1);
                        (beat - 1::samp) => now;
                        harmony[voice].noteOff(1);
                        1::samp => now;
                    }
                }
            }
            else
            {
                for(0 => int i; i < prog.cap(); i++)
                {
                    for(0 => int j; j < timesig; j++)
                    {
                        if(rhythm[0][j] == 1)
                        {   
                            Std.mtof(chords[prog[i]-1][0] - 12 * Math.random2(0,1)) => harmony[0].freq;
                            Std.mtof(chords[prog[i]-1][1] - 12 * Math.random2(0,1)) => harmony[1].freq;
                            Std.mtof(chords[prog[i]-1][2] - 12 * Math.random2(0,1)) => harmony[2].freq;
                            harmony[0].noteOn(1);
                            harmony[1].noteOn(1);
                            harmony[2].noteOn(1);
                            (beat - 1::samp) => now;
                            harmony[0].noteOff(1);
                            harmony[1].noteOff(1);
                            harmony[2].noteOff(1);
                            1::samp => now;
                        }
                        else 
                        {
                            harmony[0].noteOff(1);
                            harmony[1].noteOff(1);
                            harmony[2].noteOff(1);
                            beat => now;  
                        }
                    }
                }
            }
        }
    }
    if(instrument == 3)
    {
        Wurley harmony[3];
        harmony[0] => dac.left;
        harmony[1] => dac;
        harmony[2] => dac.right;
        0.2 => harmony[0].gain;
        0.2 => harmony[1].gain;
        0.2 => harmony[2].gain;
        GetRhythms(timesig, 1) @=> int rhythm[][];
        while(true)
        {
            if(section == "Cadence")
            {
                harmony[0].noteOn(1);
                harmony[1].noteOn(1);
                harmony[2].noteOn(1);
                Std.mtof(chords[4][0]) => harmony[0].freq;
                Std.mtof(chords[4][1]) => harmony[1].freq;
                Std.mtof(chords[4][2]) => harmony[2].freq;
                (beat * timesig)/2 => now;
                Std.mtof(chords[0][0]) => harmony[0].freq;
                Std.mtof(chords[0][1]) => harmony[1].freq;
                Std.mtof(chords[0][2]) => harmony[2].freq;
                (beat * timesig)/2 => now;
            }
            if(Math.random2(0,1) == 1 && section == "Verse")
            {
                for(0 => int i; i < prog.cap(); i++)
                {
                    for(0 => int j; j < timesig; j++)
                    {
                        Math.random2(0,2) => int voice;
                        Std.mtof(chords[prog[i]-1][Math.random2(0,2)] + 
                        (12 * Math.random2(-1,1))) => harmony[voice].freq;
                        harmony[voice].noteOn(1);
                        (beat - 1::samp) => now;
                        harmony[voice].noteOff(1);
                        1::samp => now;
                    }
                }
            }
            else
            {
                for(0 => int i; i < prog.cap(); i++)
                {
                    for(0 => int j; j < timesig; j++)
                    {
                        if(rhythm[0][j] == 1)
                        {   
                            Std.mtof(chords[prog[i]-1][0] - 12 * Math.random2(0,1)) => harmony[0].freq;
                            Std.mtof(chords[prog[i]-1][1] - 12 * Math.random2(0,1)) => harmony[1].freq;
                            Std.mtof(chords[prog[i]-1][2] - 12 * Math.random2(0,1)) => harmony[2].freq;
                            harmony[0].noteOn(1);
                            harmony[1].noteOn(1);
                            harmony[2].noteOn(1);
                            (beat - 1::samp) => now;
                            harmony[0].noteOff(1);
                            harmony[1].noteOff(1);
                            harmony[2].noteOff(1);
                            1::samp => now;
                        }
                        else 
                        {
                            harmony[0].noteOff(1);
                            harmony[1].noteOff(1);
                            harmony[2].noteOff(1);
                            beat => now;  
                        }
                    }
                }
            }
        }
    }
    if(instrument == 4)
    {
        HevyMetl harmony[3];
        harmony[0] => dac.left;
        harmony[1] => dac;
        harmony[2] => dac.right;
        0.2 => harmony[0].gain;
        0.2 => harmony[1].gain;
        0.2 => harmony[2].gain;
        GetRhythms(timesig, 1) @=> int rhythm[][];
        while(true)
        {
            if(section == "Cadence")
            {
                harmony[0].noteOn(1);
                harmony[1].noteOn(1);
                harmony[2].noteOn(1);
                Std.mtof(chords[4][0]) => harmony[0].freq;
                Std.mtof(chords[4][1]) => harmony[1].freq;
                Std.mtof(chords[4][2]) => harmony[2].freq;
                (beat * timesig)/2 => now;
                Std.mtof(chords[0][0]) => harmony[0].freq;
                Std.mtof(chords[0][1]) => harmony[1].freq;
                Std.mtof(chords[0][2]) => harmony[2].freq;
                (beat * timesig)/2 => now;
            }
            if(Math.random2(0,1) == 1 && section == "Verse")
            {
                for(0 => int i; i < prog.cap(); i++)
                {
                    for(0 => int j; j < timesig; j++)
                    {
                        Math.random2(0,2) => int voice;
                        Std.mtof(chords[prog[i]-1][Math.random2(0,2)] + 
                        (12 * Math.random2(-1,1))) => harmony[voice].freq;
                        harmony[voice].noteOn(1);
                        (beat - 1::samp) => now;
                        harmony[voice].noteOff(1);
                        1::samp => now;                    
                    }
                }
            }
            else
            {
                for(0 => int i; i < prog.cap(); i++)
                {
                    for(0 => int j; j < timesig; j++)
                    {
                        if(rhythm[0][j] == 1)
                        {   
                            Std.mtof(chords[prog[i]-1][0] - 12 * Math.random2(0,1)) => harmony[0].freq;
                            Std.mtof(chords[prog[i]-1][1] - 12 * Math.random2(0,1)) => harmony[1].freq;
                            Std.mtof(chords[prog[i]-1][2] - 12 * Math.random2(0,1)) => harmony[2].freq;
                            harmony[0].noteOn(1);
                            harmony[1].noteOn(1);
                            harmony[2].noteOn(1);
                            (beat - 1::samp) => now;
                            harmony[0].noteOff(1);
                            harmony[1].noteOff(1);
                            harmony[2].noteOff(1);
                            1::samp => now;
                        }
                        else 
                        {
                            harmony[0].noteOff(1);
                            harmony[1].noteOff(1);
                            harmony[2].noteOff(1);
                            beat => now;  
                        }
                    }
                }
            }
        }
    }
}

//Lead voice player function
function void PlayLead(int instrument, int scale[], dur beatdur, int timesig, int melody[], string section)
{ //The following code is repeated for each possible lead instrument
    if(instrument == 0)
    {
        Flute lead => NRev rev => dac; //Connect instrument to reverb to dac
        .05 => rev.mix;
        0.2 => lead.gain;
        if(section == "Cadence") //Play only on cadence
        {
            lead.noteOn(1); //Turn note on
            Std.mtof(scale[Math.random2(0,scale.cap()-1)]+12) => lead.freq; //Play random note in scale
            (beatdur * timesig)/2 => now; //Progress half a measure
            Std.mtof(scale[0] + 12) => lead.freq; //End on tonic
            ((beatdur * timesig)/2 - 1::samp) => now; //Progress half a measure
            lead.noteOff(1); //Turn note off
            1::samp => now; //Progress one sample to make sure note is turned off before loop ends
        }
        if(section == "Verse") //Play only on "verse" sections
        {
            Math.random2(0,2) => int octave; //Randomly choose an octave
            while(true)
            {        
                if(Math.random2(0,2) > 0) //Play notes approx 2/3 of the time
                {
                    lead.noteOn(1); //Turn note on
                    Std.mtof(scale[Math.random2(0,scale.cap()-1)]+12*octave) => lead.freq; //Play random note in scale
                    (beatdur - 1::samp) => now; //Progress one beat                        //shifted by octave value
                    lead.noteOff(1); //Turn note off
                    1::samp => now; //Progress one smaple to make sure note is turned off before loop ends
                }
                else //Other 1/3 of time play a rest
                {
                    beatdur => now; //Progress one beat
                }
            }
        }
        if(section == "Chorus") //Play a melody during choruses
        {
            while(true)
            {        
                for(0 => int i; i < melody.cap(); i++) //Progress through melody array
                {
                    if(melody[i] != 0) //Play melody values other than 0
                    {
                        lead.noteOn(1); //Turn note on
                        Std.mtof(melody[i]) => lead.freq; //Play midi value contained in melody array
                        (beatdur - 1::samp) => now; //Progress one beat
                        lead.noteOff(1); //Turn note off
                        1::samp => now; //Progress one sample to make sure note is turned off before loop ends
                    }
                    else //If value in array is 0, play a rest
                    {
                        beatdur => now; //Progress one beat
                    }
                }
            }
        }
    }
    if(instrument == 1) //The following code is identical to the above code, albeit with different instruments
    {
        SinOsc lead => Envelope e => NRev rev => dac;
        .05 => rev.mix;
        if(section == "Cadence")
        {
            e.target(.2);
            Std.mtof(scale[Math.random2(0,scale.cap()-1)]+12) => lead.freq;
            (beatdur * timesig)/2 => now;
            Std.mtof(scale[0] + 12) => lead.freq;
            ((beatdur * timesig)/2 - 1::samp) => now;
            e.target(0);
            1::samp => now;
        }
        if (section == "Verse")
        {
            Math.random2(0,2) => int octave;
            while(true)
            {        
                if(Math.random2(0,2) > 0)
                {
                    e.target(.2);
                    Std.mtof(scale[Math.random2(0,scale.cap()-1)]+12*octave) => lead.freq;
                    (beatdur - 1::samp) => now;
                    e.target(0);
                    1::samp => now; 
                }
                else
                {
                    beatdur => now;
                }
            }
        }
        if(section == "Chorus")
        {
            while(true)
            {        
                for(0 => int i; i < melody.cap(); i++)
                {
                    if(melody[i] != 0)
                    {
                        e.target(.2);
                        Std.mtof(melody[i]) => lead.freq;
                        (beatdur - 1::samp) => now;
                        e.target(0);
                        1::samp => now;
                    }
                    else
                    {
                        beatdur => now;
                    }
                }
            }
        }
    }
    if(instrument == 2)
    {
        Clarinet lead => NRev rev => dac;
        .05 => rev.mix;
        0.2 => lead.gain;
        if(section == "Cadence")
        {
            lead.noteOn(1);
            Std.mtof(scale[Math.random2(0,scale.cap()-1)]+12) => lead.freq;
            (beatdur * timesig)/2 => now;
            Std.mtof(scale[0] + 12) => lead.freq;
            ((beatdur * timesig)/2 - 1::samp) => now;
            lead.noteOff(1);
            1::samp => now;
        }
        if (section == "Verse")
        {
            Math.random2(0,2) => int octave;
            while(true)
            {        
                if(Math.random2(0,2) > 0)
                {
                    lead.noteOn(1);
                    Std.mtof(scale[Math.random2(0,scale.cap()-1)]+12*octave) => lead.freq;
                    (beatdur - 1::samp) => now;
                    lead.noteOff(1);
                    1::samp => now; 
                }
                else
                {
                    beatdur => now;
                }
            }
        }
        if(section == "Chorus")
        {
            while(true)
            {        
                for(0 => int i; i < melody.cap(); i++)
                {
                    if(melody[i] != 0)
                    {
                        lead.noteOn(1);
                        Std.mtof(melody[i]) => lead.freq;
                        (beatdur - 1::samp) => now;
                        lead.noteOff(1);
                        1::samp => now;
                    }
                    else
                    {
                        beatdur => now;
                    }
                }
            }
        }
    }
}

function dur GetTempo(float tempo) //Get the duration of one beat using tempo
{
    (60/tempo)::second => dur beat; 
    return beat; //Return beat duration
}

function int[] GetStructure() //Get a song structure
{
    (2 * Math.random2(1,3) + 1) => int numSections; //3, 5, or 7 sections to song
    int Struct[numSections]; //Array to hold structure
    for(0 => int i; i< numSections; i++)
    {
        Math.random2(2,4) => Struct[i]; //In each section, 2-4 repetitions 
    }
    return Struct; //Return song structure array
}

function int[] GetProgression(string style) //This function generates a chord progression array based on a style input
{                                           //Chords represented as numbers (1-7) in array
    if (style == "Classical") //For classical, a progression of undetermined length is generated using the classical sequence
    {
        int hold[50]; //temp array to hold progressions being generated. Tiny chance of being exceeded
        1 => hold[0]; //First chord always tonic 
        1 => int count; //Keep count of array size, index
        Math.random2(2,7) => hold[1]; //Second chord random 2-7
        count++;
        while ((count < 4) || (hold[count-1] != 1)) //Progression must end on tonic, be at least 4 chords 
        {
            if(hold[count-1] == 1) //Move from tonic to random 2-7
            {
                Math.random2(2,7) => hold[count];
                count++;
            }
            if(hold[count-1] == 3) //Move from 3 to 4
            {
                4 => hold[count];
                count++;
            }
            if(hold[count-1] == 6)
            {
                2 * Math.random2(1,2) => hold[count]; //Move from 6 to 4 or 2
                count++;
            }
            if(hold[count-1] == 4)
            {
                [1, 2, 5, 7] @=> int next[];
                next[Math.random2(0,3)] => hold[count]; //Move from 4 to 1, 2, 5, or 7
                count++;
            }
            if(hold[count-1] == 2)
            {
                2 * Math.random2(1,2) + 3 => hold[count]; //Move from 2 to 5 or 7
                count++; 
            }
            if(hold[count-1] == 5)
            {
                5 * Math.random2(0,1) + 1 => hold[count]; //Move from 5 to 6 or 1
                count++;
            }
            if(hold[count-1] == 7) //Move from 7 to 1
            {
                1 => hold[count];
                count++;
            }
        }
        int prog[count]; //Create new array that is the size of the progression
        for(0 => int i; i < count; i++) 
        {                                 
            hold[i] => prog[i]; //Transfer progression to new array
        }
        return prog; //Return chord progression array
    }
    if(style == "Blues") //For blues, it will always be 12-bar blues
    {
        [1, 1, 1, 1, 4, 4, 1, 1, 5, 4, 1, 1] @=> int prog[];
        return prog; //Return chord progression array
    }
    if(style == "Pop/Rock") //For pop/rock, generate a typical 4-bar progression using 1, 4, 5, and 6 chords
    {
        [1, Math.random2(4,5), Math.random2(5,6), Math.random2(4,6)] @=> int prog[];
        return prog; //Return chord progression array
    }
    else
    {
        <<<"INVALID STYLE">>>;
    }
}

function int[][] GetChords(string root, string mode, int octshift) //Get chords for key, change octave as desired
{
    int chords[][]; //2-D array for holding chords
    if (mode == "Major")
    {
        [[45, 49, 52], [47, 50, 54], [49, 52, 56], [50, 54, 57], [52, 56, 59],
        [54, 57, 61], [56, 59, 62], [57, 61, 64]] @=> chords; //Most common chords in A major
    }
    if (mode == "Minor")
    {
        [[45, 48, 52], [47, 50, 53], [48, 52, 55], [50, 53, 57], [52, 56, 59], 
        [53, 57, 60], [55, 59, 62], [57, 60, 64]] @=> chords; //Most common chords in A minor
    }
    if((mode != "Major") && (mode != "Minor"))  
        {
            <<<"INVALID MODE">>>;
        }
    ["A", "A#", "B", "B#", "C#", "D", "D#", "E", "E#", "F#", "G", "G#"] @=> string sharpkeys[]; //Possible keys
    ["A", "Bb", "Cb", "C", "Db", "D", "Eb", "Fb", "F", "Gb", "G", "Ab"] @=> string flatkeys[];
    int check; //Will use this to check that proper key is input
    for (0 => int i; i < sharpkeys.cap(); i++)
    {
        if (root == sharpkeys[i] || root == flatkeys[i]) //Compare key to possible keys
        {
            1 => check;
            for (0 => int j; j < chords.cap(); j++)
            {
                for (0 => int k; k< chords[j].cap(); k++)
                {
                    i + chords[j][k] + octshift * 12 => chords[j][k]; //Transpose from A to key, shift octave
                }
            }
        }
    }
    return chords;
}

function int[] GetScale(string key, string mode, string style) //Get a scale based on key, mode, and style
{
    int scale[]; //Array for scale
    if (style == "Classical" && mode == "Major")
    {
        [57, 59, 61, 62, 64, 66, 68, 69] @=> scale; //A major scale
    }
    if (style == "Classical" && mode == "Minor")
    {
        [57, 59, 60, 62, 64, 65, Math.random2(67,68), 69] @=> scale; //Either A natural or A harmonic minor
    }
    if (style == "Blues" && mode == "Major") 
    {
        [57, 59, 60, 61, 64, 66, 69] @=> scale; //A Major blues scale
    }
    if (style == "Blues" && mode == "Minor")
    {
        [57, 60, 62, 63, 64, 67, 69] @=> scale; //A Minor blues scale
    }
    if (style == "Pop/Rock" && mode == "Major")
    {
        [57, 59, 61, 64, 66, 69] @=> scale; //A Major pentatonic scale
    }
    if (style == "Pop/Rock" && mode == "Minor") 
    {
        [57, 60, 62, 64, 67, 69] @=> scale; //A Minor pentatonic scale
    }
    ["A", "A#", "B", "B#", "C#", "D", "D#", "E", "E#", "F#", "G", "G#"] @=> string sharpkeys[]; //Possible keys
    ["A", "Bb", "Cb", "C", "Db", "D", "Eb", "Fb", "F", "Gb", "G", "Ab"] @=> string flatkeys[]; 
    int check;
    for (0 => int i; i < sharpkeys.cap(); i++)
    {
        if (key == sharpkeys[i] || key == flatkeys[i]) //Compare key to arrays of possible keys
        {
            1 => check;
            for (0 => int j; j < scale.cap(); j++)
            {
                i + scale[j] => scale[j]; //Transpose scale from A to key
            }
        }
    }
    if (check == 1) //If key was correctly input, return scale
    {
        return scale;    
    }
    else //If key was incorrectly input, return error message
    {
        <<<"INVALID KEY">>>;
    }
}

function string[] GetDrums() //Choose three random drum sounds from library
{
    while (true)
    {
        "/home/ubuntu/Downloads/TriSamples_-_100_Kick_Drums_Vol_1/TriSamples - 100 Kick Drums Vol 1/" => string KicksDir;
        "/home/ubuntu/Downloads/TriSamples_-_100_Kick_Drums_Vol_1/TriSamples - 100 Kick Drums Vol 1/" => string PercDir; 
        "/home/ubuntu/Downloads/TriSamples_-_100_Kick_Drums_Vol_1/TriSamples - 100 Kick Drums Vol 1/" => string SnaresDir;
        string drumset[3]; //Array to hold filepath names for drum sounds
        KicksDir + "kick" + Math.random2(1,8) + ".aif" => drumset[0]; //Random kick sample
        SnaresDir + "snare" + Math.random2(1,8) + ".aif" => drumset[1]; //Random snare sample
        PercDir + "perc" + Math.random2(1,10) + ".aif" => drumset[2]; //Random percussion sample
        return drumset; //Return array of sample filepath names
    }
}

function int[][] GetRhythms(int timesig, int numPatterns) //Generates a number of rhythm patterns
{                                                         //in desired time signature
    int rhythms[numPatterns][timesig]; //2-D array to hold rhythm patterns
    for (0 => int i; i < numPatterns; i++)
    {
        for(0 => int j; j < timesig; j++)
        {
            Math.random2(0,1) => rhythms[i][j]; //Rhythms represented by 1s and 0s
        }
    }
    return rhythms; //Return array of rhythms
}

function int[] GetMelody(int prog[], int timesig, int scale[]) //Generates a melody of the length of a chord
{                                                              //progression using desired scale
    int melody[prog.cap() * timesig]; //Array to hold a note for every beat in a chord progression
    for(0 => int i; i < timesig * prog.cap(); i++)
    {
        if(Math.random2(0,3) > 0) //About 3 in 4 beats will be notes, the rest will be rests
        {
            scale[Math.random2(0, scale.cap()-1)] + 12 => melody[i]; //randomly select notes from the scale,
        }                                                            //shift up an octave
    }
    return melody;
}

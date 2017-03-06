// bell
(
SynthDef("bell",
{
		arg out = 0, freq = 256, mod = 0.2, pan = 0, t_trig=0;
// Klank - bank of resonators excited by impulses
		var p, z, panned, env;
		var freqs = [ freq,
			freq*1.81*Rand(1,1.01),
			freq*2.73*Rand(1,1.01),
			freq*4.03*Rand(1,1.01),
			freq*5.69*Rand(1,1.01),
			freq*6.48*Rand(1,1.01) ];
		// see "http://scitation.aip.org/confst/ASA/data/1/4pMU4.pdf" for harmonic specs
		z = `[	// filter bank specification :
			freqs,	// frequencies
			Array.fill(6, { arg i; 1/(6+i) }), 			// amplitudes
			Array.geom(6, 1500/freq, 0.75)		// ring times
			];
		env = Env([0,1,0], [0.002,0.02]);
		panned = Pan2.ar(
			Klank.ar(z, BrownNoise.ar(mul: mod)*EnvGen.ar(env, t_trig, doneAction:0)), pan
		);
		//DetectSilence.ar(panned, doneAction:2);
		Out.ar(out, panned);
	}
).store
)

(
SynthDef("kick",
	{ arg out = 0, freq = 50, mod_freq = 2, mod_index = 5, sustain = 0.3, amp = 0.8, beater_noise_level = 0.05, t_trig=0;
	var pitch_contour, drum_osc, drum_lpf, drum_env;
	var beater_source, beater_hpf, beater_lpf, lpf_cutoff_contour, beater_env;
	var kick_mix;
	pitch_contour = Line.kr(freq*2, freq, 0.02);
	drum_osc = PMOsc.ar(	pitch_contour,
				mod_freq,
				mod_index/1.3,
				mul: 1,
				add: 0);
	drum_lpf = LPF.ar(in: drum_osc, freq: 1000, mul: 1, add: 0);
	drum_env = drum_lpf * EnvGen.ar(Env.perc(0.01, sustain), t_trig, doneAction: 0);
	beater_source = WhiteNoise.ar(beater_noise_level);
	beater_hpf = HPF.ar(in: beater_source, freq: 500, mul: 1, add: 0);
	lpf_cutoff_contour = Line.kr(6000, 500, 0.03);
	beater_lpf = LPF.ar(in: beater_hpf, freq: lpf_cutoff_contour, mul: 1, add: 0);
	beater_env = beater_lpf * EnvGen.ar(Env.perc, t_trig, doneAction: 0);
	kick_mix = Mix.new([drum_env, beater_env]) * 2 * amp;
	Out.ar(out, [kick_mix, kick_mix])
	}
	).add
)

(
SynthDef("snare",
	{arg out = 0, sustain = 0.1, drum_mode_level = 0.25,
	snare_level = 50, snare_tightness = 100,
	freq = 805, amp = 0.8, t_trig=0;
	var drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc, drum_mode_mix, drum_mode_env;
	var snare_noise, snare_brf_1, snare_brf_2, snare_brf_3, snare_brf_4, snare_reson;
	var snare_env;
	var snare_drum_mix;

	drum_mode_env = EnvGen.ar(Env.perc(0.005, sustain), t_trig, doneAction: 0);
	drum_mode_sin_1 = SinOsc.ar(freq*0.53, 0, drum_mode_env * 0.5);
	drum_mode_sin_2 = SinOsc.ar(freq, 0, drum_mode_env * 0.5);
	drum_mode_pmosc = PMOsc.ar(	Saw.ar(freq*0.85),
					184,
					0.5/1.3,
					mul: drum_mode_env*5,
					add: 0);
	drum_mode_mix = Mix.new([drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc]) * drum_mode_level;

// choose either noise source below
//	snare_noise = Crackle.ar(2.01, 1);
	snare_noise = LFNoise0.ar(20000, 0.1);
	snare_env = EnvGen.ar(Env.perc(0.005, sustain), t_trig, doneAction: 0);
	snare_brf_1 = BRF.ar(in: snare_noise, freq: 8000, mul: 0.5, rq: 0.1);
	snare_brf_2 = BRF.ar(in: snare_brf_1, freq: 5000, mul: 0.5, rq: 0.1);
	snare_brf_3 = BRF.ar(in: snare_brf_2, freq: 3600, mul: 0.5, rq: 0.1);
	snare_brf_4 = BRF.ar(in: snare_brf_3, freq: 2000, mul: snare_env, rq: 0.0001);
	snare_reson = Resonz.ar(snare_brf_4, snare_tightness, mul: snare_level) ;
	snare_drum_mix = Mix.new([drum_mode_mix, snare_reson]) * 5 * amp;
	Out.ar(out, [snare_drum_mix, snare_drum_mix])
	}
).add
)

(
SynthDef("piano1",
	{ arg out = 0, freq = 440, mod = 0.5, pan = 0, t_trig=0;
		var delayTime, detune, strike, hammerEnv, hammer;
		var threeStrings, panned, silenced;
//		strike = Impulse.ar(0, 0, mod);
		strike = EnvGen.ar(Env.perc(0.0001,0.001, mod*0.05), t_trig);
		hammerEnv = Decay2.ar(strike, 0.008, 0.04); // excitation envelope
		threeStrings = // array of 3 strings per note
			Mix.ar(Array.fill(3, { arg i;
				// detune strings, calculate delay time :
				detune = #[0.999, 1, 1.0005].at(i);
				delayTime = 1 / (freq*detune);
				// each string gets own exciter :
				hammer = LFNoise2.ar(3000, hammerEnv); // 3000 Hz was chosen by ear..
				CombL.ar(hammer,		// used as a string resonator
					delayTime, 		// max delay time
					delayTime,			// actual delay time
					4) 				// decay time of string
			}));
		panned = Pan2.ar(threeStrings,pan);
		Out.ar(out, panned)
	}
).add
)

a = Synth("bell")
b = Synth("kick")
c = Synth("snare")
d = Synth("piano1")



a.set("t_trig",1)
b.set("t_trig",1)
c.set("t_trig",1)
d.set("t_trig",1)

(
x = OSCFunc( { | msg, time, addr, port |
	a.set("t_trig", 1)
}, '/bong' )
)

(
y = OSCFunc( { | msg, time, addr, port |
	b.set("t_trig", 1)
}, '/kick' )
)

(
z = OSCFunc( { | msg, time, addr, port |
	c.set("t_trig", 1)
}, '/snare' )
)

(
w = OSCFunc( { | msg, time, addr, port |
	d.set("t_trig", 1)
}, '/piano' )
)
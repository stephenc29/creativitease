// bell
(
SynthDef("bell",
{
		arg out = 0, midi = 60, mod = 0.2, pan = 0, t_trig=0;
// Klank - bank of resonators excited by impulses
		var p, z, panned, env;
		var freq = midicps(midi);
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
	{ arg out = 0, midi = 60, mod = 0.5, pan = 0, t_trig=0;
		var delayTime, detune, strike, hammerEnv, hammer;
		var threeStrings, panned, silenced;
		var freq = midicps(midi);
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

// FROM github.com/brunoruviaro/SynthDefs-for-Patterns/

(
SynthDef("blips1", {arg out = 0, midi = 20, numharm = 10, att = 0.01, rel = 1, amp = 0.1, pan = 0.5, t_trig = 0;
	var snd, env;
	var freq = midicps(midi);
	env = EnvGen.ar(Env.perc(att, rel, amp), t_trig, doneAction: 0);
	snd = LeakDC.ar(Mix(Blip.ar([freq, freq*1.01], numharm, env)));
	Out.ar(out, Pan2.ar(snd, pan));
}).add;
)

(
SynthDef("marimba1", {arg midi = 80, amp = 0.8, t_trig =0 ;
	var snd, env, env2;
	var freq = midicps(midi);
	env = EnvGen.ar(Env.linen(0.015, 1, 0.5, amp), t_trig, doneAction: 0);
	env2 = EnvGen.ar(Env.perc(0.015, 1, level:4), t_trig);
	snd = BPF.ar(env2, freq, 0.02);
	snd = BLowShelf.ar(snd, 220, 0.81, 6);
	snd = snd * env;
	Out.ar(0, Splay.ar(snd));
}).add;
)

(
SynthDef("prophet5pwmstrings", {
	arg out = 0, pan = 0.0, freq = 440, amp = 1.0, gate = 0, att = 0.01, rel = 0, sus = 1, dec = 0.5, lforate = 10, lfowidth = 0.5, cutoff = 12000, rq = 0.5;

	var lfo, pulse, filter, env;
	lfo = LFTri.kr(lforate * [1, 1.01], Rand(0, 2.0) ! 2);
	pulse = Pulse.ar(freq * [1, 1.01], lfo * lfowidth + 0.5);
	filter = RLPF.ar(pulse, cutoff, rq);
	env = EnvGen.ar(
		envelope: Env.adsr(att, dec, sus, rel, amp),
		gate: gate,
		doneAction: 0);
	Out.ar(out, Pan2.ar(
		in: Mix(filter) * env * 0.5,
		pos: pan)
	);
}).add
)

(
SynthDef("moogbass", {
	arg out = 0, pan = 0, midi = 40, amp = 0.1, gate = 0, cutoff = 1000, gain = 2.0, lagamount = 0.01, att = 0.001, dec = 0.3, sus = 0.9, rel = 0.2, chorus = 0.7;

	var freq= midicps(midi);
	var osc, filter, env, filterenv, snd, chorusfx;

	osc = Mix(VarSaw.ar(
		freq: freq.lag(lagamount) * [1.0, 1.001, 2.0],
		iphase: Rand(0.0,1.0) ! 3,
		width: Rand(0.5,0.75) ! 3,
		mul: 0.5));

	filterenv = EnvGen.ar(
		envelope: Env.asr(0.2, 1, 0.2),
		gate: gate);

	filter =  MoogFF.ar(
		in: osc,
		freq: cutoff * (1.0 + (0.5 * filterenv)),
		gain: gain);

	env = EnvGen.ar(
		envelope: Env.adsr(0.001, 0.3, 0.9, 0.2, amp),
		gate: gate,
		doneAction: 0);

	snd = (0.7 * filter + (0.3 * filter.distort)) * env;

	chorusfx = Mix.fill(7, {

		var maxdelaytime = rrand(0.005, 0.02);
		DelayC.ar(
			in: snd,
			maxdelaytime: maxdelaytime,
			delaytime: LFNoise1.kr(
				freq: Rand(4.5, 10.5),
				mul: 0.25 * maxdelaytime,
				add: 0.75 * maxdelaytime)
		)
	});

	snd = snd + (chorusfx * chorus);

	Out.ar(out, Pan2.ar(snd, pan));

}).add;
)

a = Synth("bell")
b = Synth("kick")
c = Synth("snare")
d = Synth("piano1")
e = Synth("blips1")
f = Synth("marimba1");
g = Synth("prophet5pwmstrings")
h = Synth("moogbass")





a.set("t_trig",1)
a.set("midi", 40)

b.set("t_trig",1)
b.set("freq", 500)
c.set("t_trig",1)

d.set("midi", 80)
d.set("t_trig",1)

e.set("midi", 30)
e.set("t_trig",1)

f.set("midi", 60)
f.set("t_trig",1)

g.set("gate",0)

h.set("midi", 10)
h.set("t_trig",1)



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
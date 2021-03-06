
// bell
(
SynthDef("bell",
{
		|out = 0, midi = 40, amp = 0.5, pan = 0|
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
			Klank.ar(z, BrownNoise.ar(mul: amp*0.25)*EnvGen.ar(env, 1, doneAction:0)), pan
		);
		DetectSilence.ar(panned, doneAction:2);
		Out.ar(out, panned);
	}
).store
)



(
SynthDef("kick",{
	| out = 0, freq = 50, mod_freq = 2, mod_index = 5, sustain = 0.3, amp = 0.5, beater_noise_level = 0.05 |
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
	drum_env = drum_lpf * EnvGen.ar(Env.perc(0.01, sustain), doneAction: 2);
	beater_source = WhiteNoise.ar(beater_noise_level);
	beater_hpf = HPF.ar(in: beater_source, freq: 500, mul: 1, add: 0);
	lpf_cutoff_contour = Line.kr(6000, 500, 0.03);
	beater_lpf = LPF.ar(in: beater_hpf, freq: lpf_cutoff_contour, mul: 1, add: 0);
	beater_env = beater_lpf * EnvGen.ar(Env.perc, doneAction: 2);
	kick_mix = Mix.new([drum_env, beater_env]) * 8 * amp;
	DetectSilence.ar(kick_mix, doneAction:2);

	Out.ar(out, [kick_mix, kick_mix])
	}
).store
)



(
SynthDef("snare",
	{arg out = 0, sustain = 0.1, drum_mode_level = 0.25,
	snare_level = 50, snare_tightness = 100,
	freq = 805, amp = 0.5;
	var drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc, drum_mode_mix, drum_mode_env;
	var snare_noise, snare_brf_1, snare_brf_2, snare_brf_3, snare_brf_4, snare_reson;
	var snare_env;
	var snare_drum_mix;

	drum_mode_env = EnvGen.ar(Env.perc(0.005, sustain), doneAction: 2);
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
	snare_env = EnvGen.ar(Env.perc(0.005, sustain), doneAction: 2);
	snare_brf_1 = BRF.ar(in: snare_noise, freq: 8000, mul: 0.5, rq: 0.1);
	snare_brf_2 = BRF.ar(in: snare_brf_1, freq: 5000, mul: 0.5, rq: 0.1);
	snare_brf_3 = BRF.ar(in: snare_brf_2, freq: 3600, mul: 0.5, rq: 0.1);
	snare_brf_4 = BRF.ar(in: snare_brf_3, freq: 2000, mul: snare_env, rq: 0.0001);
	snare_reson = Resonz.ar(snare_brf_4, snare_tightness, mul: snare_level) ;
	snare_drum_mix = Mix.new([drum_mode_mix, snare_reson]) * 10 * amp;
	Out.ar(out, [snare_drum_mix, snare_drum_mix])
	}
).store
)




(
SynthDef("piano",
	{ |out = 0, midi = 60, amp = 0.5, pan = 0 |
		var delayTime, detune, strike, hammerEnv, hammer;
		var threeStrings, panned, silenced;
		var freq = midicps(midi);
		strike = Impulse.ar(0, 0, amp*0.9);

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
		DetectSilence.ar(panned, doneAction:2);

		Out.ar(out, panned)
	}
).store
)



// FROM github.com/brunoruviaro/SynthDefs-for-Patterns/

(
SynthDef("blip", {arg out = 0, midi = 20, numharm = 10, att = 0.01, rel = 1, amp = 0.5, pan = 0.5;
	var snd, env;
	var freq = midicps(midi);
	env = EnvGen.ar(Env.perc(att, rel, amp), doneAction: 2);
	snd = LeakDC.ar(Mix(Blip.ar([freq, freq*1.01], numharm, env)));
	Out.ar(out, Pan2.ar(snd, pan));
}).store;
)


(
SynthDef("marimba", {|midi = 80, amp = 0.5|
	var snd, env, env2;
	var freq = midicps(midi);
	env = EnvGen.ar(Env.linen(0.015, 1, 0.5, amp*300), doneAction:2);
	env2 = EnvGen.ar(Env.perc(0.015, 1, level:4), doneAction:2);
	snd = BPF.ar(env2, freq, 0.02);
	snd = BLowShelf.ar(snd, 220, 0.81, 6);
	snd = snd * env;
	Out.ar(0, Splay.ar(snd));
}).store;
)

(
SynthDef("prophet", {
	| out = 0, pan = 0.0, midi=60, amp = 0.5, gate = 0, att = 0.01, rel = 0, sus = 1, dec = 0.5, lforate = 10, lfowidth = 0.5, cutoff = 12000, rq = 0.5 |

	var lfo, pulse, filter, env;
	var freq = midicps(midi);
	lfo = LFTri.kr(lforate * [1, 1.01], Rand(0, 2.0) ! 2);
	pulse = Pulse.ar(freq * [1, 1.01], lfo * lfowidth + 0.5);
	filter = RLPF.ar(pulse, cutoff, rq);
	env = EnvGen.ar(
		envelope: Env.adsr(att, dec, sus, rel,1),
		gate: gate,
		doneAction: 0);
	Out.ar(out, Pan2.ar(
		in: Mix(filter) * env * 0.2 * amp,
		pos: pan)
	);
}).store
)




(
SynthDef("moog", {
	| out = 0, pan = 0, midi=60, amp = 0.5, gate = 0, cutoff = 1000, gain = 2.0, lagamount = 0.5, att = 0.001, dec = 0.3, sus = 0.9, rel = 0.2, chorus = 0.7 |
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
		envelope: Env.adsr(0.001, 0.3, 0.9, 0.2, 1),
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

	snd = (snd + (chorusfx * chorus)) * amp * 12.0;

	Out.ar(out, Pan2.ar(snd, pan));

}).store;
)

// Crotale adapted from SuperCollider book p24
(
//run this first
SynthDef("crotale", {
| midi = 60, tone = 3, art = 1, amp = 0.5, pan = 0|
var env, out, mod, freq;

freq = midi.midicps;
env = Env.perc(0, art);
mod = 5 + (1/IRand(2, 6));

out = PMOsc.ar(freq, mod*freq,
	pmindex: EnvGen.kr(env, timeScale: art, levelScale: tone, doneAction:2),
	mul: EnvGen.kr(env, timeScale: art, levelScale: 0.3, doneAction:2));

out = Pan2.ar(out, pan);

out = out * amp*1.5 * EnvGen.kr(env,  timeScale: 1.3*art,
	levelScale: Rand(0.1, 0.5), doneAction:2);
Out.ar(0, out); //Out.ar(bus, out);

}).store;
)

// resonance designed to be in range 0-100
(
SynthDef("ghost",
	{|amp = 0.5, out=0, midi=40, resonance=70, lag = 1.0, gate =0|

		var noise=WhiteNoise.ar(mul:amp);
		var freq = Lag.kr(midicps(midi), lag);
		var env = EnvGen.ar(
		envelope: Env.adsr(2, 0.3, 0.8, 1, 1.2),
		gate: gate,
		doneAction: 0);
		Out.ar(out, env *
			RLPF.ar(noise, freq, 2.pow(-1.0*resonance/10.0))!2);
}).store
)

(
SynthDef("recordSample", {
	| buffer, recLevel=1, preLevel=1 |
    var in;
	in = SoundIn.ar([0, 1]);
    RecordBuf.ar(in, buffer,
		recLevel: recLevel,
		preLevel: preLevel,
		loop:0);
}).store
)

(
SynthDef("playSample", {
	|buffer, out = 0, rate = 1, startPos = 0|
    Out.ar(out, PlayBuf.ar(2, buffer, rate, startPos: startPos) ! 2)
}).store;
)


// soundFX
(
SynthDef("reverb", { |outBus = 0, inBus|
	var input;
	input = In.ar(inBus, 2);


	Out.ar(outBus, FreeVerb.ar(input));
	}).store;
)

(
SynthDef("delay", {| out = 0, inBus, time = 0.5|
	var input, delayed;
	input = In.ar(inBus, 2);

	delayed = CombN.ar(input, time, time, time*10);
	Out.ar(out, input);
	Out.ar(out, delayed);

}).store;
)



s.dumpOSC(1);

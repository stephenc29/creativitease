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

a=Synth("bell")
a.set("t_trig",1)

(
x = OSCFunc( { | msg, time, addr, port |
	a.set("t_trig", 1)
}, '/bong' )
)

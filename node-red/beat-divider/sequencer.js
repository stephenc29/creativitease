// allow restart on tick
// enable/disable looping
// start array includes note
// send end note?
// check out null note in sequence [1,2,,3]
// replace sequencer?
// fancy parsing of notes e.g. [1,1^,+3]*8 and note names
// sequencing loudness
// validity check in property editing
// check that notes and rhythm are arrays of ints
// allow notes or rhytm to be singleton number instead of singleton list
// default and non-default scale
// configure octave (interact with synth e.g. for bass sounds?)

module.exports = function(RED) {
    "use strict";

    function SequencerNode(config) {
        RED.nodes.createNode(this,config);
        var node = this;
	node.input = config.input || "beat";

	try{
	    node.notes = JSON.parse(config.notes);
	}
	catch(e){
	    node.notes = null;
	}
	if(!Array.isArray(node.notes)){
	    node.warn("Invalid or undefined notes, using [1]");
	    node.notes = [1];
	}

	try{
	    node.rhythm = JSON.parse(config.rhythm);
	}
	catch(e){
	    node.rhythm = null;
	}
	if(!Array.isArray(node.rhythm)){
	    node.warn("Invalid or undefined note lengths for using [1]");
	    node.rhythm = [1];
	}

	node.octave = 0; // make this configurable as an offset from middle C
	node.root = 60; // make this configurable as a name or offset, middle C for now
	node.mode = "minor"; // make this configurable
	
	node.rhythmPos = -1; // the position in the list of lengths
	node.rhythmCount = 0; // count down the number of beats
	node.notePos = -1; // the position in the list of notes

        this.on('input', function(msg) {
	    switch(msg.payload){
	    case "tick":
		var start = msg.start || [];
		if(start.indexOf(node.input)>=0){
		    node.rhythmCount--;
		    if(node.rhythmCount<=0){
			node.rhythmPos++;
			if(node.rhythmPos>=node.rhythm.length){
			    node.rhythmPos = 0;
			}
			node.rhythmCount = node.rhythm[node.rhythmPos];
			msg.count["rhythm_pos"] = node.rhythmPos;

			node.notePos++;
			if(node.notePos >= node.notes.length){
			    node.notePos = 0;
			}
			msg.count["note_pos"] = node.notePos;
			msg.note_midi = note2midi(node.notes[node.notePos], node);
			// send previous note end?
			start.push("note");
			msg.start = start;
			node.send(msg);
		    }
		}
		break;

	    default:
		node.send(msg);
	    }
        });


    }

// use default scale for now    
    function note2midi(note, node){
	if(note === null){
	    return -1;
	}
	var intervals = {
	    "major": [0,2,4,5,7,9,11,12],
	    "minor": [0,2,3,5,7,8,10,12]
	}
	var midi = node.root;
	var offsets = intervals[node.mode];

	while(note-1 > offsets.length){
	    note -= offsets.length;
	    midi += offsets[offsets.length -1];
	}
	
	midi += node.octave*12;

	midi += offsets[note-1];

	return midi;
    }
    
    RED.nodes.registerType("sequencer",SequencerNode);
}


module.exports = function(RED) {
    "use strict";

    var _ = require("underscore");
    
    function SequencerNode(config) {
        RED.nodes.createNode(this,config);
        var node = this;

	reset();
	
        this.on('input', function(msg) {
	    switch(msg.payload){
	    case "tick":
		var start = msg.start || [];
		if(start.indexOf(node.input)>=0){
//		    only start/ restart when we get the right kind of tick
		    if(node.rhythmPos == -1 && start.indexOf(node.start)<0){
			return;
		    }
		    node.rhythmCount--;
		    if(node.rhythmCount<=0){
			if(node.rhythmrand && node.loop){
			    node.rhythmCount = _.sample(node.rhythm);
			    node.rhythmPos = 0; // needs to be > 0 so that it continues after start/restart
			}
			else{
			    node.rhythmPos++;
			    if(node.rhythmPos>=node.rhythm.length){
				node.rhythmPos = 0;
			    }
			    node.rhythmCount = node.rhythm[node.rhythmPos];
			    msg.rhythm_pos = node.rhythmPos;
			}

			var note;
			if(node.notesrand && node.loop){
			    note = _.sample(node.notes);
			}
			else{
			    node.notePos++;
			    if(node.notePos >= node.notes.length){
				if(node.loop){
				    node.notePos = 0;
				}
				else{
				    restart();
				    return;
				}
			    }
			    note = node.notes[node.notePos]
			}
			var playmsg = 
			    {payload: "play",
			     midi: note2midi(note)};
			node.send(playmsg);
		    }
		}
		break;

	    case "reset":
		reset();
		node.send(msg);
		break;
		
	    default:
		node.send(msg);
		break;
	    }
        });

	function restart(){
	    node.rhythmPos = -1; // the position in the list of lengths
	    node.rhythmCount = 0; // count down the number of beats
	    node.notePos = -1; // the position in the list of notes
	    if(node.rhythmrand & !node.loop){
		node.rhythm = _.shuffle(node.rhythm);
	    }
	    if(node.notesrand & !node.loop){
		node.notes = _.shuffle(node.notes);
	    }
	}
	
	function reset(){
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
	    
	    node.octave = config.octave || 0;
	    
	    node.start = config.start || "bar"; // sequence won't start until this
	    
	    node.loop = config.loop || false;
	    node.notesrand = config.notesrand || false;
	    node.rhythmrand = config.rhythmrand || false;
	    
	    node.root = 60; // make this configurable as a name or offset, middle C for now
	    node.mode = "minor"; // make this configurable

	    restart();
	}

	// use default scale for now    
	function note2midi(note){
	    if(note === null){
		return -1;
	    }
	    var intervals = {
		"major": [0,2,4,5,7,9,11,12],
		"minor": [0,2,3,5,7,8,10,12]
	    }
	    var midi = node.root;
	    var offsets = intervals[node.mode];
	    
	    while(note > offsets.length){
		note -= offsets.length-1;
		midi += offsets[offsets.length-1];
	    }
	    
	    midi += node.octave*12;
	    
	    midi += offsets[note-1];
	    
	    return midi;
	}

    }

    
    RED.nodes.registerType("sequencer",SequencerNode);
}


module.exports = function(RED) {
    "use strict";
    
    function BeatNode(config) {
	
        RED.nodes.createNode(this,config);
        var node = this;
	
	reset();
	
	
        this.on('input', function(msg) {
	    switch(msg.topic){
	    case "bpm":
		setBPM(msg.payload);
		break;

	    default:
		switch(msg.payload){
		case "start":
		    if(!node.started){
			beat();
			node.started = true;
		    }
		    node.send(msg);
		    break;

		case "stop":
		    clearTimeout(node.tick);
		    node.started = false;
		    node.send(msg);
		    break;

		case "reset":
		    reset();
		    node.send(msg);
		    break;

		default:
		    node.send(msg);
		}
	    }
        });

	this.on('close', function(){
	    clearTimeout(node.tick);
	});
		
	function reset(){
	    clearTimeout(node.tick);
	    node.output = config.output;
	    setBPM(config.bpm);
	    node.started = false;
	    node.beatNum = 0;
	}

	function setBPM(bpm){
	    if(!isNaN(bpm)){
		if(bpm>10 && bpm <1000){
		    node.interval = 60000.0/bpm;
		}
		else{
		    node.warn("BPM not in range 10-1000");
		}
	    }
	    else{
		node.warn("BPM is not a number: " + bpm);
	    }
	}
	
	function beat(){
	    node.beatNum = node.beatNum || 0;
	    node.beatNum++;
	    var count = new Object();
	    count[node.output] = node.beatNum;
	    var msg = {payload: "tick",
		       start: [node.output],
		       };
	    msg[node.output] = node.beatNum;
	    node.send(msg);
	    node.tick = setTimeout(beat, node.interval);
	}

    }
    
	
    RED.nodes.registerType("beat",BeatNode);
}


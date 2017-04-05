module.exports = function(RED) {
    "use strict";
    var tick ;
    var context;
    
    function BeatNode(config) {
	
        RED.nodes.createNode(this,config);
        var node = this;
	
	context = this.context();

	node.output = config.output;

	setBPM(config.bpm);

	var beatNum, started;
	reset(node);
	
	
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
		    break;

		case "stop":
		    clearTimeout(tick);
		    node.started = false;
		    break;

		case "reset":
		    clearTimeout(tick);
		    reset();
		    node.send(msg);
		    break;

		default:
		    node.send(msg);
		}
	    }
        });

	function reset(node){
	    node.started = false;
	    node.beatNum = 0;
	}

	function setBPM(bpm){
	    if(!isNaN(bpm)){
		if(bpm>10 && bpm <1000){
		    context.set("interval", 60000.0/bpm);
		}
		else{
		    node.warn("BPM not in range 10-1000");
		}
	    }
	    else{
		node.warn("BPM is not a number: " + bpm);
	    }
	}

	function getInterval(){
	    return context.get("interval");
	}
	
	function beat(){
	    beatNum = beatNum || 0;
	    beatNum++;
	    var count = new Object();
	    count[node.output] = beatNum;
	    var msg = {topic: "tick",
		       start: [node.output],
		       };
	    msg[node.output] = beatNum;
	    node.send(msg);
	    tick = setTimeout(beat, getInterval());
	}

    }
    
	
    RED.nodes.registerType("beat",BeatNode);
}


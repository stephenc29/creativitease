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

	var beatNum = 0;
	
        this.on('input', function(msg) {
	    switch(msg.topic){
	    case "bpm":
		setBPM(msg.payload);
		break;

	    default:
		switch(msg.payload){
		case "start":
		    beat();
		    break;

		case "stop":
		    clearTimeout(tick);
		    break;

		default:
		    node.send(msg);
		}
	    }
        });

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
		       payload:{
			   start: [node.output],
			   count: count
		       }};
		       
	    node.send(msg);
	    tick = setTimeout(beat, getInterval());
	}

    }
    
	
    RED.nodes.registerType("beat",BeatNode);
}


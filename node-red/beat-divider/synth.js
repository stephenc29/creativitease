module.exports = function(RED) {
    "use strict";
    
    function SynthNode(config) {
	
        RED.nodes.createNode(this,config);
        var node = this;

	reset();
	
        this.on('input', function(msg) {
	    switch(msg.topic){
	    case "play":
	    case "tick":
		var playmsg = {
		    "topic": "/" + node.name,
		}
		if(msg.midi){
		    playmsg.payload = msg.midi;
		}

		node.send(playmsg);
		break;

	    case "volume":
		var newVol = Number(msg.payload);
		if(!Number.isNaN(newVol)){
		    node.vol = newVol;
		}
		
		node.vol = Math.min(100, Math.max(0, node.vol));
		
		var volmsg = {
		    "topic": "/" + node.name + "/volume",
		    "payload": node.vol
		}
		node.send(volmsg);
		
		break;
		
	    default:
		switch(msg.payload){
		case "reset":
		    reset();
		    // just this once the reset message is not propagated
		    break;

		default:
		    // do nothing
		}
		
	    }
        });

	function reset(){
	    node.name = config.name || "piano";
	    node.vol = Number(config.start_vol) || 70;
	    var volmsg = {
		"topic": "/" + node.name + "/volume",
		"payload": node.vol
	    }
	    node.send(volmsg);
	}
    }
    
	
    RED.nodes.registerType("synth",SynthNode);
}


module.exports = function(RED) {
    "use strict";
    
    function SynthNode(config) {
	
        RED.nodes.createNode(this,config);
        var node = this;
	node.name = config.name || "piano";
	node.vol = config.start_vol || 70;
	
        this.on('input', function(msg) {
	    switch(msg.topic){
	    case "play":
		var playmsg = {
		    "topic": "/" + node.name,
		    "payload": msg.payload.midi
		}
		node.send(playmsg);
		break;

	    case "volume":
		if(msg.payload =="up"){
		    node.vol += 5;
		}
		else if(msg.payload =="down"){
		    node.vol -= 5;
		}
		else{
		    var newVol = Number(msg.payload);
		    if(!Number.isNaN(newVol)){
			node.vol = newVol;
		    }
		}
		
		node.vol = Math.min(100, Math.max(0, node.vol));
		
		var volmsg = {
		    "topic": "/" + node.name + "/volume",
		    "payload": node.vol
		}
		node.send(volmsg);
		
		break;
		
	    default:
		// do nothing
	    }
        });
    }
    
	
    RED.nodes.registerType("synth",SynthNode);
}


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
		if(msg.payload.startsWith("up")){
		    var upby = Number(msg.payload.substring(2));
		    if(Number.isNaN(upby)){
			upby = 1;
		    }
		    node.vol += upby;
		}
		else if(msg.payload.startsWith("down")){
		    var downby = Number(msg.payload.substring(4));
		    if(Number.isNaN(downby)){
			downby = 1;
		    }
		    node.vol -= downby;
		}
		else if(msg.payload.startWith("set")){
		    var newVol = Number(msg.payload.substring(3));
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


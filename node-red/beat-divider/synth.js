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
		var payload = [node.synth_id];
		if(msg.midi == -1){
		    payload.push("gate", 0);
		}
		else{
		    payload.push("gate", 1);
		    payload.push("t_trig", 1);
		    if(msg.midi){
			payload.push("midi", msg.midi);
		    }
		}
		
		var playmsg = {
		    topic: "/n_set",
		    payload: payload
		}

		node.send(playmsg);
		break;

	    case "volume":
		var newVol = Number(msg.payload);
		if(!Number.isNaN(newVol)){
		    node.vol = newVol;
		}
		
		node.vol = Math.min(100, Math.max(0, node.vol));

		setSynthVol();

		break;
		
	    default:
		switch(msg.payload){
		case "reset":
		    reset();
		    // just this once the reset message is not propagated
		    break;

		case "stop":
		    var stopMsg = {topic: "/n_set",
				   payload:
				   [node.synth_id, "gate" , 0]
				  }
		    node.send(stopMsg);
		    break;
		    
		case "start":
		    // restart the synth
		    freeSynth();
		    createSynth();
		    break;
		    
		default:
		    // do nothing
		}
		
	    }
        });

	this.on('close', function(){
	    freeSynth();
	});

	function setSynthVol(){
	    var amp = node.vol/100.0; // Use a logarithmic scale?
	    
	    var volmsg = {
		"topic": "/n_set",
		"payload": [node.synth_id, "amp", amp]
	    }
	    node.send(volmsg);
	}
	

	function createSynth(){
	    var global = node.context().global;
	    var id = Number(global.get("synth_next_sc_node"));
	    if(isNaN(id)){
		id = 100000; // high to avoid nodes from sclang
	    }
	    global.set("synth_next_sc_node", id + 1);
	    node.synth_id = id;
	    var createMsg = {
		topic: "/s_new",
		payload: [node.name, node.synth_id, 1, 1]
	    }
	    node.send(createMsg);
	    setSynthVol();
	}
	
	function freeSynth(){
	    if(node.synth_id){
		var freeMsg = {
		    topic: "/n_free",
		    payload: node.synth_id
		}
		node.send(freeMsg);
		node.synth_id = null;
	    }
	}
	
	function reset(){
	    node.name = config.name || "piano";
	    node.vol = Number(config.start_vol) || 70;

	    freeSynth();
	    createSynth();
	}
    }
    
	
    RED.nodes.registerType("synth",SynthNode);
}


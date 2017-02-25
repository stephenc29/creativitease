module.exports = function(RED) {
    "use strict";
//    var NanoTimer = require('nanotimer');
//    var timer = new NanoTimer();
    var tick ;
    var context;
    
    function BeatNode(config) {
	
        RED.nodes.createNode(this,config);
        var node = this;
	context = this.context();
	context.set("bpm", 100);
        this.on('input', function(msg) {
	    switch(msg.payload){
	    case "start":
		beat();
		break;

	    case "stop":
		clearTimeout(tick);
		break;

	    case "interval":
		var bpm = msg.bpm;
		if(!isNaN(bpm)){
		    if(bpm>10 && bpm <400){
			context.set("interval", 60000.0/bpm);
		    }
		}
		break;
	    }
        });

	function beat(){
	    var msg = {payload:"beat"};
            node.send(msg);
	    var interval = context.get("interval");
	    tick = setTimeout(beat, interval);
	}

    }
    
	
    RED.nodes.registerType("beat",BeatNode);
}


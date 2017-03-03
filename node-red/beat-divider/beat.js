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
	context.set("interval", 600);
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
	    var beatNum = context.get("beatNum") || 0;
	    beatNum++;
	    context.set("beatNum", beatNum);
	    
	    var msg = {payload: "tick",
		       start: ["beat"],
		       count:{"beat": beatNum}};
		       
	    node.send(msg);

	    var interval = context.get("interval");
	    tick = setTimeout(beat, interval);
	}

    }
    
	
    RED.nodes.registerType("beat",BeatNode);
}


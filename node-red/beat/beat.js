module.exports = function(RED) {
    "use strict";
//    var NanoTimer = require('nanotimer');
//    var timer = new NanoTimer();
    var tick ;
    
    function BeatNode(config) {
	
        RED.nodes.createNode(this,config);
        var node = this;
        this.on('input', function(msg) {
	    if(msg.payload=="start"){
		tick = setInterval(beat, 1000);
	    }
        });

	function beat(){
	    var msg = {payload:"beat"};
            node.send(msg);
	}

    }
    
	
    RED.nodes.registerType("beat",BeatNode);
}


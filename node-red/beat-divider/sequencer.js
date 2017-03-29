module.exports = function(RED) {
    "use strict";
    
    function SequencerNode(config) {
        RED.nodes.createNode(this,config);
        var node = this;
	node.input = config.input || "beat";
	node.sequence = JSON.parse(config.sequence) || [1,1,2];
	node.pos = 0; // the position in the list
	node.count = node.sequence[node.pos] || 1; // count down the number of beats

        this.on('input', function(msg) {
	    switch(msg.payload){
	    case "tick":
		var start = msg.start || [];
		if(start.indexOf(node.input)>=0){
		    node.count--;
		    if(node.count<=0){
			node.pos++;
			if(node.pos>=node.sequence.length){
			    node.pos = 0;
			}
			node.count = node.sequence[node.pos];
			msg.start = start;
			msg.count["seq_pos"] = node.pos;
			node.send(msg);
		    }
		}
		break;

	    default:
		node.send(msg);
	    }
        });


    }
    
	
    RED.nodes.registerType("sequencer",SequencerNode);
}


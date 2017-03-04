module.exports = function(RED) {
    "use strict";
    
    function DividerNode(config) {
	
        RED.nodes.createNode(this,config);
        var node = this;
	node.input = config.input || "beat";
	node.output = config.output || "bar";
	node.ratio = config.ratio || 4;
	node.inputCount = 0;
	node.outputCount = 0;
	
        this.on('input', function(msg) {
	    switch(msg.payload){
	    case "tick":
		var start = msg.start || [];
		if(start.indexOf(node.input)>=0){
		    node.inputCount++;
		    if(node.inputCount > node.ratio || node.outputCount === 0){
			node.inputCount = 1;
			node.outputCount ++;
			start.push(node.output);
		    }
		}
		msg.start = start;
		msg.count[node.input + "_of_" + node.output] = node.inputCount;
		msg.count[node.output] = node.outputCount;
		node.send(msg);
		break;

	    case "ratio":

		break;
		
	    default:
		node.send(msg);
	    }
        });


    }
    
	
    RED.nodes.registerType("divider",DividerNode);
}


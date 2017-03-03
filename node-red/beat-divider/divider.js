module.exports = function(RED) {
    "use strict";
    var context;
    
    function DividerNode(config) {
	
        RED.nodes.createNode(this,config);
        var node = this;
	context = this.context();
	context.set("input", "beat");
	context.set("output", "bar");
	context.set("inputCount", 0);
	context.set("outputCount", 0);
	context.set("ratio", 4);
        this.on('input', function(msg) {
	    switch(msg.payload){
	    case "tick":
		var start = msg.start;
		var input = context.get("input");
		var output = context.get("output");
		var index = start.indexOf(input);
		if(start.indexOf(input)>=0){
		    var inputCount = context.get("inputCount");
		    var outputCount = context.get("outputCount");
		    inputCount++;
		    var ratio = context.get("ratio");
		    if(inputCount > ratio || outputCount === 0){
			inputCount = 1;
			outputCount ++;
			context.set("outputCount", outputCount);
			start.push(output);
		    }
		    context.set("inputCount", inputCount);
		    msg.start = start;
		    msg.count[input + "_of_" + output] = inputCount;
		    msg.count[output] = outputCount;
		}
		node.send(msg);
		break;

	    default:
		node.send(msg);
	    }
        });


    }
    
	
    RED.nodes.registerType("divider",DividerNode);
}


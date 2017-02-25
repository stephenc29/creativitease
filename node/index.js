var events = require('events');
var NanoTimer = require('nanotimer');
var osc = require('osc');

e = new events.EventEmitter();
timer = new NanoTimer();
var udpPort = new osc.UDPPort({
    localAddress: "0.0.0.0",
    localPort: 57121
});
udpPort.open()

bpm = 500
interval = 60/bpm

timer.setInterval(beat, '', interval+'s');

beatNum=0;
function beat(){
    console.log ("Beating")
    e.emit('beat')
    beatNum++
}

barNum=0
beatsInBar=4
beat=-1
e.on('beat', beatToBar);
function beatToBar(){
    beat++
    if(beat>beatsInBar || beat==0){
	barNum++
	beat=1
	e.emit('bar')
    }
}

e.on('beat', () => {
    console.log("make noise");
    udpPort.send({address: "/bong"}, "127.0.0.1", 57120);    
		   })

e.on('bar', () => {
    udpPort.send({address: "/bleep"}, "127.0.0.1", 12000);

		  });

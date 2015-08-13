//INSTANCE SPECIFIC
var porttolisten 		= 9000;

var logger = require('winston');
var express = require('express')
, passport = require('passport')
, util = require('util')
, BearerStrategy = require('passport-http-bearer').Strategy;
var bodyParser = require("body-parser");
var numCPUs = require('os').cpus().length;
var http = require('http');
var kafka = require('kafka-node');
var Producer = kafka.Producer;
var client = new kafka.Client(process.env.ZOOKPRSVRS + process.env.ZKKAFKAROOT);
var producer = new Producer(client);

function getSystemInfo() {
	os = require('os');
	cpu = os.cpus();
	var info = {	
			cpus: cpu.length,
			model: cpu[0].model,
			speed: cpu[0].speed,
			hostname: os.hostname(),
			ramused: Math.round(os.freemem()/(1024*1000))+"MB",
			ramtotal: Math.round(os.totalmem()/(1024*1000*1000)) + "GB"
	};
	return info;
}


function findByToken(token, fn) {
	var usercontext = {}; 
	return fn(null,usercontext);	
}

passport.use(new BearerStrategy(
  function(token, done) {
    findByToken(token, function (err, user) {
      if (err) { return done(err); }
      if (!user) { return done(null, false); }
      return done(null, user, { scope: 'write' });
    });
  }
));
 
var app = express();

app.use(passport.initialize());
app.use(bodyParser.json());
app.use(function (req, res, next) {
	next()
})	

app.post('/sentence',  passport.authenticate('bearer', { session: false }), function(req, res) {

	logger.info("Starting request");
	var msg = req.body;
	
	var msgtext = JSON.stringify(msg);
			
    payloads = [
        { topic: 'sentences', messages: msgtext, partition: 0 }
    ];	
    
	producer.send(payloads, function (err, data) {
		if (err) {
			logger.error(err);
			res.status(500);
			res.send({"status" : "error","statuscode" : 1,"description" : "Problem inserting event"});								
		} else {
			res.status(200);
			res.send({"status" : "success", "data": data});							
		}			
	});
});

logger.info("Starting docker process",getSystemInfo());

producer.on('ready', function () {	
	var server = http.createServer(app).listen(porttolisten, function(){	
		logger.info("Express server listening on port " + porttolisten);
	});		
});

//producer.on('error', function (err) {
//})    


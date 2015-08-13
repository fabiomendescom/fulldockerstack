//INSTANCE SPECIFIC
var nodename			= process.env.NODE_NAME;
var zookeeperurls		= process.env.ZOOKEEPER_URLS; //separated by semi colons

var logger = require('winston');
var myipaddress;
var ip = require('local-ip');
interface = "eth0";
ip(interface, function(err, res) {
  if (err) {
    logger.error('I have no idea what my local ip is.');
  } else {
	logger.info('My local ip address on ' + interface + ' is ' + res);
	myipaddress = res;
  }
});
logger.info("Starting registration to zookeeper");
var zookeeper = require('node-zookeeper-client');
 
var myurl = myipaddress + ":6379";

var client = zookeeper.createClient(zookeeperurls);
var path = "/DRILLIXSERVICES/REDIS" + "/" + nodename;
 
client.once('connected', function () {
    logger.info('Connected to zookeeper service at ' + zookeeperurls);							
	client.exists(path,function(error, stat) {
		if(error) {
			logger.error(error.stack);
		} else {
			if(stat) {
				client.setData(path, new Buffer(myurl), function(error,data,stat) {
					if(error) {
						logger.error('Failed to set data on node:' + path + ' due to: ' + error);
					} else {
						logger.info("Registered data " + myurl + " on node: " + path);
						logger.info("Starting redis server");
						var spawn = require('child_process').spawn,
							redisprocess    = spawn('redis-server');
						logger.info("Spawning redis process and waiting for response");
						redisprocess.stdout.on('data', function (data) {
							logger.info("Successful Response received");
							logger.info('stdout: ' + data);
						});		
						redisprocess.stderr.on('data', function (data) {
							logger.error("Error response received");
							logger.error('stderr' + data);
						});								
					}		
				})	
			} else {
				logger.info("Path " + path + " does not exist. Will create");		
				client.mkdirp(path, new Buffer(myurl), function (error) {
					if (error) {
						logger.error('Failed to create node:' + path + ' due to: ' + error.stack);
					} else {
						logger.info("Created path " + path);		
						logger.info("Starting redis server");
						var spawn = require('child_process').spawn,
							redisprocess    = spawn('redis-server');
						logger.info("Spawning redis process and waiting for response");
						redisprocess.stdout.on('data', function (data) {
							logger.info("Successful Response received");
							logger.info('stdout: ' + data);
						});		
						redisprocess.stderr.on('data', function (data) {
							logger.error("Error response received");
							logger.error('stderr' + data);
						});																												
					}
				});			
			}
		}
	});
});
 
client.connect();

extends Node
enum Connection {
	LOCAL,				# Local only game, tutorial
	DEDICATED_SERVER,	# Server only, no local client
	CLIENT_SERVER,		# Server with a local player
	CLIENT				# Client only, remote server
}

var connection = Connection.LOCAL
var host: String = ''
var port: int = 0

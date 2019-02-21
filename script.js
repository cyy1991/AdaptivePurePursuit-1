console.log("Server is starting");

var express = require("express");
var request = require("request");

var app = express();
var server = app.listen(process.env.PORT || 3000, listening);

function listening()
{
	console.log("Listening");
}

app.use(express.static("public"));

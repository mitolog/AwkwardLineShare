# AwkwardLineShare

AwkwardLineShare is a simple drawing app that can share each lines with other sockets using socket.io

## Spec
- can draw a awkward-line with 1st-dimension perlin noise
- can share your drawing with the other sockets
- forground only
- it's just a sample to examine realtimeness of socket.io.

## How to use

### Serverside

1. Prepare your nodejs environment ([nodebrew](https://github.com/hokaccha/nodebrew) is fast).
2. Just Install [socket.io](https://github.com/Automattic/socket.io) by `npm install socket.io` command where you want to run node.
3. Place **awkwardLineShareServer.js** at the same dir as **node_module** folder. 
4. Just Run with `node awkwardLineShareServer` (or if you want to debug, you can use `DEBUG*= node awkwardLineShareServer`)

::attension:: 
Don't forget to open `3000` inbound port of your server.
For your reference, my environment is:
- Amazon Linux AMI release 2014.09
- node v0.12.0 
- socket.io v1.3.5

### Clientside

Change **kWebSocketHostName** in `ViewController.h` file with yours. Be ware HostName doesn't start with `http://` but start with `ws://`.

The project uses cocoapods. so you have to run `pod install`.

### License
MIT


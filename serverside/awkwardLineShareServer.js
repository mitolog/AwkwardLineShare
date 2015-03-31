var io = require('socket.io')(3000);

io.on('connection', function (socket) {

    console.log(socket['id'] + ' has connected!');

    socket.on('init', function(data){
        io.emit('join', socket.id);
    });

    socket.on('draw', function (data,socketId) {
        console.log(data);
        console.log(socketId);
        io.emit('update', [data, socketId]);
    });

    socket.on('disconnect', function (data) {
        console.log(socket.id + ' has disconnected!');
        io.emit('disappear',socket.id);
    }); 
});       


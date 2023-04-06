const express = require('express')
const mongoose = require("mongoose")
const Room = require("./models/Room.js")
const getWord = require("./api/getWord.js");
require("dotenv").config()

// INITIALIZATION
const app = express()
const port = process.env.PORT
const db = process.env.MONGO_URL
var server = app.listen(port, () => console.log(`Example app listening on port ${port}!`))
mongoose.connect(db).then(() => {
    console.log("Connection Succesful!")
}).catch((e) => {
    console.log(e);
})
var io = require("socket.io")(server);

// MIDDLEWARES
app.use(express.json());

io.on('connection', (socket) => {
    //  CREATE GAME CALLBACK
    socket.on('create-game', async ({ nickname, name, occupancy, maxRounds }) => {
        try {
            const existingRoom = await Room.findOne({ name });
            if (existingRoom) {
                socket.emit('notCorrectGame', "Room with that name already exists!");
                return;
            }
            let room = new Room();
            const word = getWord();
            room.word = word;
            room.name = name;
            room.occupancy = occupancy;
            room.maxRounds = maxRounds;

            let player = {
                socketID: socket.id,
                nickname,
                isPlayerLeader: true,
            }
            room.players.push(player);
            room = await room.save();
            socket.join(name);
            io.to(name).emit('updateRoom', room);
        } catch (e) {
            console.log(e);
        }
    });



    // JOIN GAME CALLBACK
    socket.on('join-game', async ({ nickname, name }) => {
        try {
            let room = await Room.findOne({ name });
            if (!room) {
                socket.emit('notCorrectGame', 'Please enter a valid room name');
                return;
            }

            if (room.isJoin) {
                let player = {
                    socketID: socket.id,
                    nickname,
                }
                room.players.push(player);
                socket.join(name);
                if (room.players.length === room.occupancy) {
                    room.isJoin = false;
                }
                room.turn = room.players[room.turnIndex];
                room = await room.save();
                console.log({ 'room': name });
                io.to(name).emit('updateRoom', room);
            } else {
                socket.emit('notCorrectGame', 'The game is in progress, pls try later!');
            }
        } catch (err) {
            console.log("on-join-game ", err)
        }
    });

    // messaging logic
    socket.on('msg', async (data) => {
        try {
            if (data.msg === data.word) {
                let room = await Room.find({ name: data.roomName });
                let userPlayer = room[0].players.filter(
                    (player) => player.nickname === data.username
                )
                if (data.timeTaken !== 0) {
                    userPlayer[0].points += Math.round((200 / data.timeTaken) * 10);
                }
                room = await room[0].save();
                io.to(data.roomName).emit('msg', {
                    username: data.username,
                    msg: 'Guessed it!',
                    guessedUserCtr: data.guessedUserCtr + 1,
                })
                socket.emit('closeInput', "");
            } else {
                io.to(data.roomName).emit('msg', {
                    username: data.username,
                    msg: data.msg,
                    guessedUserCtr: data.guessedUserCtr + 1,
                })
            }
        } catch (e) {
            console.log('msg socket ', e);
        }
    })

    socket.on('change-turn', async (name) => {
        try {
            let room = await Room.findOne({ name });
            let = room.turnIndex;
            if (idx + 1 === room.players.length) {
                room.currentRound += 1;
            }
            if (room.currentRound <= room.maxRounds) {
                const word = getWord();
                room.word = word;
                room.turnIndex = (idx + 1) % room.players.length
                room.turn = room.players[room.turnIndex]
                room = await room.save();
                io.to(name).emit("show-leaderboard", room.players);
            } else {
                io.to(name).emit('show-leaderboard', room.players);
            }
        } catch (e) {
            console.log('change-turn', e)
        }
    })

    socket.on('updateScore', async (name) => {
        try {
            const room = await Room.findOne({ name });
            io.to(name).emit('updateScore', room);
        } catch (e) {
            console.log('update-score-socket ', e)
        }
    })

    // white board sockets
    socket.on('paint', ({ details, roomName }) => {
        io.to(roomName).emit('points', { details });
    })

    // color socket
    socket.on('color-change', ({ color, roomName }) => {
        io.to(roomName).emit('color-change', color);
    })

    // stroke socket
    socket.on('stroke-width', ({ value, roomName }) => {
        io.to(roomName).emit('stroke-width', value);
    })

    // clear screen
    socket.on('clear-screen', (roomName) => {
        io.to(roomName).emit('clear-screen', '');
    })

    socket.on('disconnect', async () => {
        try {
            let room = await Room.findOne({ "players.socketID": socket.id })
            for (var i = 0; i < room.players.length; i++) {
                if (room.players[i].socketID === socket.id) {
                    room.players.splice(i, 1);
                    break;
                }
            }
            room = await room.save();
            if (room.players.length === 1) {
                socket.broadcast.to(room.name).emit('show-leaderboard', room.players);
            } else {
                socket.broadcast.to(room.name).emit('user-disconnected', room);
            }
        } catch (e) {
            console.log('disconnect-socket', e)
        }
    })
})

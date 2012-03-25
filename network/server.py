from gevent.server import StreamServer
import json
import uuid

BUFSIZE=1024
DATA = {}
sockets = []
CRLF = "\r\n"
def sock_readlines(socket):
    remainder =  ' '
    while True:
        data = socket.recv(BUFSIZE)
        if len(data) == 0:
            break
        if CRLF in data:
            lines = data.split(CRLF)
            yield remainder + lines[0]
            for line in lines[1:-1]:
                yield line
            if data.endswith(CRLF):
                yield lines[-1]
                remainder = ''
            else:
                remainder = lines[-1]

class GameServer(StreamServer):
    def __init__(self,listener):
        StreamServer.__init__(self,listener, self.on_connect)

    def on_connect(self,socket,address):
        sockets.append(socket)
        print "sole connected"
        for line in sock_readlines(socket):
            print line, "read"
            obj = line
            self.broadcast(obj)

    def broadcast(self,message):
        line = message
        
        for socket in sockets:
            socket.send(line)

server = GameServer(('localhost', 9876))
server.serve_forever()


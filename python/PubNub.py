from twisted.internet import reactor
from twisted.internet.protocol import Protocol, ClientFactory
from sys import stdout

def PubNubTCP(Protocol):
    def message_receive(self):
        self.transport.write("Yay, it's me!")

c = ClientCreator(reactor, MyProtocol)
c.connectTCP("localhost", 1234).addCallback(lambda p: p.hello_dude())

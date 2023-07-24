//
//  UdpListener.swift
//  Telemetry
//
//  Created by MacBook on 21/07/2023.
//

// Inspired from :
// https://medium.com/@michaelrobertellis/how-to-make-a-swift-ios-udp-listener-using-apples-network-framework-f7cef6f4e45f
// https://gist.github.com/michael94ellis/92828bba252ccabd071279be098e26e6

import Foundation
import Network
import Combine

class UdpListenerClass: ObservableObject {
    
    // Test
    @Published private(set) var count: Int = 0
    
    func countUp() {
        count += 1
    }
    
    // UDP Listener
    var Listener: NWListener?
    var Connection: NWConnection?
    var Queue = DispatchQueue.global(qos: .userInitiated)

    @Published private(set) public var isReady: Bool = false
    @Published public var Listening: Bool = true
    
    @Published public var UdpMsg: Data?
    @Published public var UdpMsgString: String = ""
        
    convenience init(on port: Int) {
        self.init(on: NWEndpoint.Port(integerLiteral: NWEndpoint.Port.IntegerLiteralType(port)))
    }
    
    init(on port: NWEndpoint.Port) {
        let Params = NWParameters.udp
        Params.allowFastOpen = true
        self.Listener = try? NWListener(using: Params, on: port)
        self.Listener?.stateUpdateHandler = { Update in
            switch Update {
            case .ready: // Connected
                self.isReady = true
                print("Listener connected to port \(port)")
            case .failed, .cancelled: // Disconnected
                self.isReady = false
                self.Listening = false
                print("Listener disconnected from port \(port)")
            default: // Connecting
                print("Listener connecting to port \(port)...")
            }
        }
        self.Listener?.newConnectionHandler = { Connection in
            self.createConnection(Connection: Connection)
        }
        self.Listener?.start(queue: self.Queue)
    }
    
    func createConnection(Connection: NWConnection) {
        self.Connection = Connection
        self.Connection?.stateUpdateHandler = { (NewState) in
            switch (NewState) {
            case .ready:
                self.receive()
                print("Listener ready to receive message") // - \(Connection)")
            case .failed, .cancelled:
                self.Listener?.cancel()
                self.Listening = false
                print("Listener failed to receive message") // - \(Connection)")
            default:
                print("Listener waiting to receive message") // - \(Connection)")
            }
        }
        self.Connection?.start(queue: .global())
    }
    
    func receive() {
        self.Connection?.receiveMessage { Data, Context, isComplete, Error in
            if let unwrappedError = Error {
                print("Error : NWError received in \(#function) - \(unwrappedError)")
                return
            }
            guard isComplete, let data = Data else {
                print("Error : Received nil Data with context - \(String(describing: Context))")
                return
            }
            self.UdpMsg = data
            self.UdpMsgString = String(decoding: self.UdpMsg!, as: UTF8.self)
            print("Received message : \(self.UdpMsgString)")
                        
            if self.Listening {
                self.receive()
            }
        }
    }
    
    func cancel() {
        self.Listening = false
        self.Connection?.cancel()
    }
}


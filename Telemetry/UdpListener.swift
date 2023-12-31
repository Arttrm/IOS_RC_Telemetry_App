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

import UserNotifications

class UdpListenerClass: ObservableObject {
   
    // UDP Listener
    var Listener: NWListener?
    var connection: NWConnection?
    var Queue = DispatchQueue.global(qos: .userInitiated)

    @Published private(set) public var isReady: Bool = false
    @Published public var Listening: Bool = true // false
	
	@Published private(set) public var UdpMsgCntr: Int = 0
    
    @Published private var UdpMsg: Data?
    @Published private var UdpMsgString: String = ""
	@Published private var UdpMsgList: [String] = ["","",""]
	
	// @Published private(set) public var VBattString:String = "0.00"
    // @Published private(set) public var VBecString:String = "0.00"
    // @Published private(set) public var Temp1String:String = "0.00"
    // @Published private(set) public var Temp2String:String = "0.00"
        
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
        self.Listener?.newConnectionHandler = { connection in
            self.createConnection(connection: connection)
        }
        self.Listener?.start(queue: self.Queue)
    }
    
    func createConnection(connection: NWConnection) {
        self.connection = connection
        self.connection?.stateUpdateHandler = { (NewState) in
            switch (NewState) {
            case .ready:
				print("Listener ready to receive message") // - \(connection)")
                // self.receive()
            case .failed, .cancelled:
				print("Listener failed to receive message") // - \(connection)")
                self.Listener?.cancel()
                self.Listening = false
            default:
                print("Listener waiting to receive message") // - \(connection)")
				// self.receive()
            }
        }
		self.receive()
        self.connection?.start(queue: .global())
    }
    
    func receive() {

        self.connection?.receiveMessage { Data, Context, isComplete, Error in

            if let unwrappedError = Error {
                print("Error : NWError received in \(#function) - \(unwrappedError)")
                return
            }
            guard isComplete, let data = Data else {
                print("Error : Received nil Data with context - \(String(describing: Context))")
                return
            }
			
            self.UdpMsgCntr = (self.UdpMsgCntr + 1) % 16
			print(self.UdpMsgCntr)
            
			self.UdpMsg = data
			self.UdpMsgString = String(decoding: self.UdpMsg!, as: UTF8.self)
			print("Message received in class : \(self.UdpMsgString)")
            
			self.decodeMessage()
            
            if self.Listening {
                self.receive()
			}
        }
    }
	
	func decodeMessage() {
        
        self.UdpMsgList = self.UdpMsgString.components(separatedBy: ";")
        
        if self.UdpMsgString.starts(with: "01;") {
            NotificationCenter.default.post(name: Notification.Name.VBattNotif, object: self.UdpMsgList[1])
        } else if self.UdpMsgString.starts(with: "02;") {
            NotificationCenter.default.post(name: Notification.Name.VBecNotif, object: self.UdpMsgList[1])
        } else if self.UdpMsgString.starts(with: "03;") {
            NotificationCenter.default.post(name: Notification.Name.Temp1Notif, object: self.UdpMsgList[1])
        } else if self.UdpMsgString.starts(with: "04;") {
            NotificationCenter.default.post(name: Notification.Name.Temp2Notif, object: self.UdpMsgList[1])
        }
    }
    
    func cancel() {
        self.Listening = false
        self.connection?.cancel()
    }
}


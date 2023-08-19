//
//  ContentView.swift
//  Telemetry
//
//  Created by MacBook on 18/07/2023.
//

import SwiftUI
import UIKit

import Network

import UserNotifications
extension Notification.Name {
    static let VBattNotif = Notification.Name("VBattNotif")
	static let VBecNotif = Notification.Name("VBecNotif")
	static let Temp1Notif = Notification.Name("Temp1Notif")
	static let Temp2Notif = Notification.Name("Temp2Notif")
}

struct ContentView: View {
    
    @StateObject public var UdpListener: UdpListenerClass = .init(on: 54537)
	
	@State private var VBattString:String = "0.00"
	@State private var VBecString:String = "0.00"
	@State private var Temp1String:String = "0.00"
	@State private var Temp2String:String = "0.00"
    
    var body: some View {
        
        // Image(systemName: "globe")
        //     .imageScale(.large)
        //     .foregroundColor(.accentColor)
        // Text("Hello, world!")
        
        Form {
            
			// Toggle button to start / stop the listener
			Toggle(isOn: $UdpListener.Listening, label: {
				HStack{
					if UdpListener.Listening {
						Image(systemName: "power").foregroundColor(.green)
						Text("Listening")
					} else {
						Image(systemName: "power").foregroundColor(.red)
						Text("Stopped")
					}
				}
			})
			.onChange(of: UdpListener.Listening) { _ in
				print("Listener state : \(UdpListener.Listening)")
				if UdpListener.Listening {
					// Restart listening
				} else {
					// Stop listening
					// UdpListener.cancel()
				}
			}
			
            HStack{Text("VBatt")
                Spacer()
                Text(VBattString+"V")
				.onReceive(NotificationCenter.default.publisher(for: Notification.Name.VBattNotif)) { notif in
					if let MsgString = notif.object as? String {
						print("Received VBattString: \(MsgString)")
						VBattString = MsgString
					}
				}
            }
            HStack{Text("VBec")
                Spacer()
                Text(VBecString+"V")
				.onReceive(NotificationCenter.default.publisher(for: Notification.Name.VBecNotif)) { notif in
					if let MsgString = notif.object as? String {
						print("Received VBecString: \(MsgString)")
						VBecString = MsgString
					}
				}
            }
            HStack{Text("Temp1")
                Spacer()
                Text(Temp1String+"°C")
				.onReceive(NotificationCenter.default.publisher(for: Notification.Name.Temp1Notif)) { notif in
					if let MsgString = notif.object as? String {
						print("Received Temp1String: \(MsgString)")
						Temp1String = MsgString
					}
				}
            }
            HStack{Text("Temp2")
                Spacer()
                Text(Temp2String+"°C")
				.onReceive(NotificationCenter.default.publisher(for: Notification.Name.Temp2Notif)) { notif in
					if let MsgString = notif.object as? String {
						print("Received Temp2String: \(MsgString)")
						Temp2String = MsgString
					}
				}
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




//
//  ContentView.swift
//  Telemetry
//
//  Created by MacBook on 18/07/2023.
//

import SwiftUI
import UIKit
import Network

struct ContentView: View {
    
    @State public var isConnected:Bool = false
    
    @State public var VBattString:String = "0.00"
    @State public var VBecString:String = "0.00"
    @State public var Temp1String:String = "0.00"
    @State public var Temp2String:String = "0.00"
    
    @ObservedObject var UdpListener: UdpListenerClass = .init(on: 54537)
    
    var body: some View {
        
        // Image(systemName: "globe")
        //     .imageScale(.large)
        //     .foregroundColor(.accentColor)
        // Text("Hello, world!")
        
        Form {
            HStack {
				if isConnected {
					Image(systemName: "power").foregroundColor(.green)
					Text("Connected")
				} else {
					Image(systemName: "power").foregroundColor(.red)
					Text("Connecting")
				}
				Button("Connect") {
					UdpListener.createConnection(connection: UdpListener.connection)
				}
            }            
            HStack{Text("VBatt")
                Spacer()
                Text(VBattString+"V")
            }
            HStack{Text("VBec")
                Spacer()
                Text(VBecString+"V")
            }
            HStack{Text("Temp1")
                Spacer()
                Text(Temp1String+"°C")
            }
            HStack{Text("Temp2")
                Spacer()
                Text(Temp2String+"°C")
            }
        }
        
        .onReceive(UdpListener.$UdpMsgString) { Str in
            print("Message received")
            isConnected = true
            decodeMessage(UdpMsgString: Str)
        }
    }
    
    func decodeMessage(UdpMsgString: String) {
        
        let UdpMsgList = UdpMsgString.components(separatedBy: ";")
        
        if UdpMsgString.starts(with: "01;") {
            VBattString = UdpMsgList[1]
        } else if UdpMsgString.starts(with: "02;") {
            VBecString = UdpMsgList[1]
        } else if UdpMsgString.starts(with: "03;") {
            Temp1String = UdpMsgList[1]
        } else if UdpMsgString.starts(with: "04;") {
            Temp2String = UdpMsgList[1]
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




//
//  NetworkSupport.swift
//  VisualCamera
//
//  Created by 徐嗣苗 on 2022/12/17.
//

import Foundation
import Network
import UniformTypeIdentifiers

struct CameraOptions {
    var host: NWEndpoint.Host
    var port: NWEndpoint.Port
    var duration: Int
    var imageEncodingFormat: UTType
    
    init() {
        self.host = "192.168.1.206"
        self.port = 8899
        self.duration = 10
        self.imageEncodingFormat = .jpeg
    }
    
    init(host: NWEndpoint.Host, port: NWEndpoint.Port) {
        self.host = host
        self.port = port
        self.duration = 10
        self.imageEncodingFormat = .jpeg
    }
}

let clientQueue = DispatchQueue(label: "TCPClient")

var host: NWEndpoint.Host = "192.168.1.206"
var port: NWEndpoint.Port = 8899

var connection = NWConnection(to: .hostPort(host: host, port: port), using: .tcp)

var wifiIP: String? {
    var address: String?
    var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
    
    guard getifaddrs(&ifaddr) == 0 else {
        return nil
    }
    guard let firstAddr = ifaddr else {
        return nil
    }
    
    for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
        let interface = ifptr.pointee
        // Check for IPV4 or IPV6 interface
        let addrFamily = interface.ifa_addr.pointee.sa_family
        if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
            // Check interface name
            let name = String(cString: interface.ifa_name)
            if name == "en0" {
                // Convert interface address to a human readable string
                var addr = interface.ifa_addr.pointee
                var hostName = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(&addr,socklen_t(interface.ifa_addr.pointee.sa_len), &hostName, socklen_t(hostName.count), nil, socklen_t(0), NI_NUMERICHOST)
                address = String(cString: hostName)
            }
        }
    }
    
    freeifaddrs(ifaddr)
    return address
}




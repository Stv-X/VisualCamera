//
//  NetworkSupport.swift
//  VisualCamera
//
//  Created by 徐嗣苗 on 2022/12/17.
//

import Foundation
import Network

struct CameraOptions {
    var host: NWEndpoint.Host
    var port: NWEndpoint.Port
    
    init() {
        self.host = "192.168.1.206"
        self.port = 8899
    }
    
    init(host: NWEndpoint.Host, port: NWEndpoint.Port) {
        self.host = host
        self.port = port
    }
}

let clientQueue = DispatchQueue(label: "TCPClient")

var host: NWEndpoint.Host = "192.168.1.206"
var port: NWEndpoint.Port = 8899

var connection = NWConnection(to: .hostPort(host: host, port: port), using: .tcp)





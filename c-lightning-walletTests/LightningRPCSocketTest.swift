//
//  LightningRPCSocketTest.swift
//  c-lightning-walletTests
//
//  Created by Ben Harold on 1/31/18.
//  Copyright © 2018 Harold Consulting. All rights reserved.
//

import XCTest
import Socket
@testable import c_lightning_wallet

class LightningRPCSocketTest: XCTestCase {
    
    // This must be a path to an active c-lightning node socket in order for
    // these tests to pass. The default is ~/.lightning/lightning-rpc
    var relative_path = "~/.lightning/lightning-rpc"
    
    let decoder = JSONDecoder.init()
    
    // The socket path must be an absolute path without `file://` in the front.
    // Here I was just figuring out the best way to support the `~` character.
    func testPaths() {
        let path_with_tilde = "~/.lightning/lightning-rpc"
        let full_path = FileManager.default.homeDirectoryForCurrentUser.path + "/.lightning/lightning-rpc"
        XCTAssertEqual(NSString(string: path_with_tilde).expandingTildeInPath, full_path)
        
        let path_without_tilde = "/dev/null"
        XCTAssertEqual(NSString(string: path_without_tilde).expandingTildeInPath, path_without_tilde)
    }
    
    func testConnectToRPCServer() {
        let absolute_path = NSString(string: relative_path).expandingTildeInPath
        let socket_family = Socket.ProtocolFamily.unix
        let socket_type = Socket.SocketType.stream
        let socket_protocol = Socket.SocketProtocol.unix
        var socket: Socket?
        
        do {
            try socket = Socket.create(family: socket_family, type: socket_type, proto: socket_protocol)
            guard let socket = socket else {
                print("Unable to unwrap socket")
                throw SocketError.unwrap_error
            }
            socket.readBufferSize = 4096
            try socket.connect(to: absolute_path)
        } catch {
            print("socket connection error: \(error)")
        }
        XCTAssert((socket?.isConnected)!)
    }
    
    func testSendGetInfoQuery() {
        let socket = LightningRPCSocket(path: relative_path)
        let query = LightningRPCQuery(
            id: 1,
            method: "getinfo",
            params: []
        )
        let result = socket.send(query: query)
        // I need to update this after I create the `getinfo` struct.
        print("testSendQuery", String(data: result, encoding: .utf8)!)
//        do {
//            result = try decoder.decode(GetInfo.self, from: response)
//            XCTAssert(result is GetInfo) // Ignore the warning https://bugs.swift.org/browse/SR-1703
//        } catch {
//            print("Error: \(error)")
//        }
    }
    
    func testListPaymentsIsDecodable() {
        let result: PaymentResult
        let socket = LightningRPCSocket(path: relative_path)
        let query = LightningRPCQuery(
            id: 1,
            method: "listpayments",
            params: []
        )
        let response: Data = socket.send(query: query)
        do {
            result = try decoder.decode(PaymentResult.self, from: response)
            XCTAssert(result is PaymentResult) // Ignore the warning https://bugs.swift.org/browse/SR-1703
        } catch {
            print("Error: \(error)")
        }
    }

}

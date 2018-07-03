//
//  AddressService.swift
//  Voltage
//
//  Created by Ben Harold on 2/2/18.
//  Copyright © 2018 Harold Consulting. All rights reserved.
//

import Cocoa

class AddressService: NSObject {
    
    class func generate() -> String? {
        let decoder: JSONDecoder = JSONDecoder.init()
        guard let service = LightningRPCSocket.create() else {
            return nil
        }
        let newaddr: LightningRPCQuery = LightningRPCQuery(id: Int(getpid()), method: "newaddr", params: [])
        let response: Data = service.send(query: newaddr)
        
        do {
            let result: Address = try decoder.decode(AddressResult.self, from: response).result
            return result.address
        } catch {
            do {
                NotificationCenter.default.post(name: Notification.Name.rpc_error, object: error)
                let rpc_error = try decoder.decode(ErrorResult.self, from: response).error
                print("AddressService RPC error: " + rpc_error.message)
            } catch {
                print("AddressService RPC error: \(error)")
            }
            print("AddressService JSON decoder error: \(error)")
        }
        
        return nil
    }
}

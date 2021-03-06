//
//  ChannelsViewController.swift
//  Voltage
//
//  Created by Ben Harold on 2/1/18.
//  Copyright © 2018 Harold Consulting. All rights reserved.
//

import Cocoa

class ChannelsViewController: VoltageTableViewController {

    var channel_list: [Channel] = [Channel]()
    
    let table_keys = [
        "short_channel_id",
        "base_fee_millisatoshi",
        "flags",
        "active",
        "public",
        "delay",
        "last_update",
    ]
    
    @IBOutlet weak var channels_table_view: NSTableView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.tab_index = 4
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        channels_table_view.delegate = self
        channels_table_view.dataSource = self
        set_sort_descriptors()
    }
    
    override func reload() {
        channel_list.removeAll()
        load_table()
    }
    
    override func load_table_data() {
        if let response: ChannelResult = query(LightningRPC.Method.listchannels) {
            channel_list = response.result.channels
        }
    }
    
    override func reload_table_view() {
        channels_table_view.reloadData()
    }
    
    func set_sort_descriptors() {
        for (index, _) in table_keys.enumerated() {
            channels_table_view.tableColumns[index].sortDescriptorPrototype = NSSortDescriptor(key: table_keys[index], ascending: true)
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return channel_list.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if channel_list.count == 0 {
            return nil
        }
        
        var key = ""
        key = tableColumn!.identifier.rawValue
        
        if key == "short_channel_id" {
            return channel_list[row].short_channel_id
        } else if key == "base_fee" {
            if channel_list[row].base_fee_millisatoshi != nil {
                return channel_list[row].base_fee_millisatoshi! / 1000
            }
            return 0
        } else if key == "flags" {
            return channel_list[row].flags
        } else if key == "active" {
            return channel_list[row].active.to_yes_no()
        } else if key == "last_update" {
            if channel_list[row].last_update != nil {
                return channel_list[row].last_update?.to_date_string()
            }
            return ""
        } else if key == "public" {
            return channel_list[row].`public`.to_yes_no()
        } else if key == "delay" {
            return channel_list[row].delay
        }
        
        return nil
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        guard let sortDescriptor = tableView.sortDescriptors.first else {
            return
        }
        
        let key = sortDescriptor.key!
        
        if sortDescriptor.ascending == true {
            switch key {
            case "base_fee_millisatoshi":
                channel_list.sort { Int($0.base_fee_millisatoshi ?? -1) < Int($1.base_fee_millisatoshi ?? -1) }
            case "flags":
                channel_list.sort { $0.flags < $1.flags }
            case "active":
                channel_list.sort { $0.active && !$1.active }
            case "public":
                channel_list.sort { $0.`public` && !$1.`public` }
            case "last_update":
                channel_list.sort { Int($0.last_update ?? -1) < Int($1.last_update ?? -1) }
            case "delay":
                channel_list.sort { Int($0.delay ?? -1) < Int($1.delay ?? -1) }
            default:
                channel_list.sort { $0.short_channel_id < $1.short_channel_id }
            }
        } else {
            switch key {
            case "base_fee_millisatoshi":
                channel_list.sort { Int($0.base_fee_millisatoshi ?? -1) > Int($1.base_fee_millisatoshi ?? -1) }
            case "flags":
                channel_list.sort { $0.flags > $1.flags }
            case "active":
                channel_list.sort { !$0.active && $1.active }
            case "public":
                channel_list.sort { !$0.`public` && $1.`public` }
            case "last_update":
                channel_list.sort { Int($0.last_update ?? -1) > Int($1.last_update ?? -1) }
            case "delay":
                channel_list.sort { Int($0.delay ?? -1) > Int($1.delay ?? -1) }
            default:
                channel_list.sort { $0.short_channel_id > $1.short_channel_id }
            }
        }
        
        tableView.reloadData()
    }
}

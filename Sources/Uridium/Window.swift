//
//  Window.swift
//  Uridium
//
//  Created by renan jegouzo on 12/10/2017.
//  Copyright © 2017 aestesis. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import xcb
import Vulkan
import Foundation

public class Window {
    var title:String {
		didSet {
	        xcb_change_property(connection,UInt8(XCB_PROP_MODE_REPLACE.rawValue),window,XCB_ATOM_WM_NAME.rawValue,XCB_ATOM_STRING.rawValue,8,UInt32(strlen(title)),title)
		}
	}
    var width:Int
    var height:Int
    let connection:OpaquePointer
    let window:UInt32
    let wmDeleteWin : xcb_atom_t
    public var running = false
    public init?(title:String,width:Int,height:Int) {
        self.title = title
        self.width = width
        self.height = height
        var screenp:Int32 = 0
        //let connection:xcb_connection_t
        connection = xcb_connect(nil, &screenp)
        let error = xcb_connection_has_error(connection)
        if error > 0 {
            NSLog("xcb connection error: \(error)")
            return nil
        }
        let setup = xcb_get_setup(connection)
        var iter = xcb_setup_roots_iterator(setup)
        for _ in 1...screenp {
            xcb_screen_next(&iter)
        }
        let screen = iter.data!
        NSLog("screen: \(screen.pointee.root) w:\(screen.pointee.width_in_pixels) h:\(screen.pointee.height_in_pixels)")
        window = xcb_generate_id(connection)
        let emask:UInt32 = XCB_CW_BACK_PIXEL.rawValue | XCB_CW_EVENT_MASK.rawValue
        let vl :[UInt32] = [screen.pointee.black_pixel, 0]
        let visual = screen.pointee.root_visual
        xcb_create_window(connection,UInt8(XCB_COPY_FROM_PARENT),window,screen.pointee.root,100,100,UInt16(width),UInt16(height),0,UInt16(XCB_WINDOW_CLASS_INPUT_OUTPUT.rawValue),visual,emask,vl)
        xcb_change_property(connection,UInt8(XCB_PROP_MODE_REPLACE.rawValue),window,XCB_ATOM_WM_NAME.rawValue,XCB_ATOM_STRING.rawValue,8,UInt32(strlen(title)),title)
        
        let wmDeleteCookie = xcb_intern_atom(connection, 0, UInt16(strlen("WM_DELETE_WINDOW")), "WM_DELETE_WINDOW")
        let wmProtocolsCookie = xcb_intern_atom(connection, 0, UInt16(strlen("WM_PROTOCOLS")), "WM_PROTOCOLS")
        let wmDeleteReply = xcb_intern_atom_reply(connection, wmDeleteCookie, nil)
        let wmProtocolsReply = xcb_intern_atom_reply(connection, wmProtocolsCookie, nil)
        wmDeleteWin = wmDeleteReply!.pointee.atom
        //let wmProtocols = wmProtocolsReply!.pointee.atom
        xcb_change_property(connection, UInt8(XCB_PROP_MODE_REPLACE.rawValue), window,wmProtocolsReply!.pointee.atom, 4, 32, 1, &wmDeleteReply!.pointee.atom)
        
        xcb_map_window(connection, window)
        xcb_flush(connection)
    }
    public func renderLoop() {
        running = true
        while running {
            if let event = xcb_wait_for_event(connection) {
                switch event.pointee.response_type & ~0x80 {
                case UInt8(XCB_CLIENT_MESSAGE):
					let cm = UnsafeRawPointer(event).bindMemory(to: xcb_client_message_event_t.self, capacity: 1)
                    if cm.pointee.data.data32.0 == wmDeleteWin {
                        running = false
                    }
                default:
                    break
                }
                free(event)
            }
        }
        xcb_destroy_window(connection, window)
    }
    
}
//
//  YSocket.swift
//  PasteShare
//
//  Created by Floris-Jan Willemsen on 25-09-16.
//  Copyright © 2016 Floris-Jan Willemsen. All rights reserved.
//

import Foundation
open class YSocket{
    var addr:String
    var port:Int
    var fd:Int32?
    init(){
        self.addr=""
        self.port=0
    }
    public init(addr a:String,port p:Int){
        self.addr=a
        self.port=p
    }
}

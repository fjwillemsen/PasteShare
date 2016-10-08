//
//  TCPClient.swift
//  PasteShare
//
//  Created by Floris-Jan Willemsen on 25-09-16.
//  Copyright © 2016 Floris-Jan Willemsen. All rights reserved.
//

import Foundation

//@_silgen_name("ytcpsocket_connect") func c_ytcpsocket_connect(_ host:UnsafePointer<Int8>,port:Int32,timeout:Int32) -> Int32
//@_silgen_name("ytcpsocket_close") func c_ytcpsocket_close(_ fd:Int32) -> Int32
//@_silgen_name("ytcpsocket_send") func c_ytcpsocket_send(_ fd:Int32,buff:UnsafePointer<UInt8>,len:Int32) -> Int32
//@_silgen_name("ytcpsocket_pull") func c_ytcpsocket_pull(_ fd:Int32,buff:UnsafePointer<UInt8>,len:Int32,timeout:Int32) -> Int32
//@_silgen_name("ytcpsocket_listen") func c_ytcpsocket_listen(_ addr:UnsafePointer<Int8>,port:Int32)->Int32
//@_silgen_name("ytcpsocket_accept") func c_ytcpsocket_accept(_ onsocketfd:Int32,ip:UnsafePointer<Int8>,port:UnsafePointer<Int32>) -> Int32

open class TCPClient:YSocket{
    /*
     * connect to server
     * return success or fail with message
     */
    open func connect(timeout t:Int)->(Bool,String){
        let rs:Int32=c_ytcpsocket_connect(self.addr, port: Int32(self.port), timeout: Int32(t))
        if rs>0{
            self.fd=rs
            return (true,"connect success")
        }else{
            switch rs{
            case -1:
                return (false,"qeury server fail")
            case -2:
                return (false,"connection closed")
            case -3:
                return (false,"connect timeout")
            default:
                return (false,"unknow err.")
            }
        }
    }
    /*
     * close socket
     * return success or fail with message
     */
    open func close()->(Bool,String){
        if let fd:Int32=self.fd{
            c_ytcpsocket_close(fd)
            self.fd=nil
            return (true,"close success")
        }else{
            return (false,"socket not open")
        }
    }
    /*
     * send data
     * return success or fail with message
     */
    open func send(data d:[UInt8])->(Bool,String){
        if let fd:Int32=self.fd{
            let sendsize:Int32=c_ytcpsocket_send(fd, buff: d, len: Int32(d.count))
            if Int(sendsize)==d.count{
                return (true,"send success")
            }else{
                return (false,"send error")
            }
        }else{
            return (false,"socket not open")
        }
    }
    /*
     * send string
     * return success or fail with message
     */
    open func send(str s:String)->(Bool,String){
        if let fd:Int32=self.fd{
            let sendsize:Int32=c_ytcpsocket_send(fd, buff: s, len: Int32(strlen(s)))
            if sendsize==Int32(strlen(s)){
                return (true,"send success")
            }else{
                return (false,"send error")
            }
        }else{
            return (false,"socket not open")
        }
    }
    /*
     *
     * send nsdata
     */
    open func send(data d:Data)->(Bool,String){
        if let fd:Int32=self.fd{
            var buff:[UInt8] = [UInt8](repeating: 0x0,count: d.count)
            (d as NSData).getBytes(&buff, length: d.count)
            let sendsize:Int32=c_ytcpsocket_send(fd, buff: buff, len: Int32(d.count))
            if sendsize==Int32(d.count){
                return (true,"send success")
            }else{
                return (false,"send error")
            }
        }else{
            return (false,"socket not open")
        }
    }
    /*
     * read data with expect length
     * return success or fail with message
     */
    open func read(_ expectlen:Int, timeout:Int = -1)->[UInt8]?{
        if let fd:Int32 = self.fd{
            var buff:[UInt8] = [UInt8](repeating: 0x0,count: expectlen)
            let readLen:Int32=c_ytcpsocket_pull(fd, buff: &buff, len: Int32(expectlen), timeout: Int32(timeout))
            if readLen<=0{
                return nil
            }
            let rs=buff[0...Int(readLen-1)]
            let data:[UInt8] = Array(rs)
            return data
        }
        return nil
    }
}

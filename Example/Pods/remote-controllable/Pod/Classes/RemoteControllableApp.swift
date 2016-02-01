//
//  RemoteControllableApp.swift
//  Transmit screenshot
//
//  Created by Thomas Gilbert on 12/11/15.
//  Copyright © 2015 Thomas Gilbert. All rights reserved.
//

import Foundation
import SocketIOClientSwift

public final class RemoteControllableApp {
    
    public static let sharedInstance = RemoteControllableApp()
    
    private var remoteOverlay: UIView?
    private var socket: SocketIOClient?
    private var vendorId: String = UIDevice().identifierForVendor!.UUIDString
    
    private init() {}
    
    public func startConnection(url: String = "localhost:8006", uuid: String = UIDevice().identifierForVendor!.UUIDString) {
        debugPrint("Remote Connection called at: \(url)")
        vendorId = uuid;
        socket = SocketIOClient(socketURL: NSURL(string: url)!, options: [.Log(false), .ForcePolling(false)])
        setupHandlers()
    }
    
    /**
     Checks the status of the socket connection.
     Returns true if there is an active connection, false if there is none.
     */
    public func isConnected() -> Bool {
        debugPrint("Remote Connection Status Asked")
        if let socket = socket {
            return socket.status == SocketIOClientStatus.Connected ? true : false
        } else {
            return false
        }
    }
    
    /**
     Closes the connection. Will stop transmitting screen and removes the ui overlay.
     Will turn off automatic reconnects.
     */
    public func stopConnection() {
        debugPrint("Remote Connection Closing")
        socket?.disconnect()
        socket = nil
    }
    
    private func setupHandlers() {
        socket?.on("draw dot") { [weak self] data, ack in
            debugPrint("Remote Connection Draw Dot \(data)")
            if let coords = data[0] as? NSDictionary, x = coords["x"] as? Double, y = coords["y"] as? Double  {
                self?.drawCircleOnOverlay(x, y: y)
            }
        }
        
        socket?.on("connect") {[weak self] data, ack in
            debugPrint("Remote Connection Connected")
            self?.requestSupport()
            self?.transmitScreen()
            self?.addRemotePresentationOverlay()
        }
        
        socket?.on("error") { ack in
            debugPrint("Remote Connection Error: \(ack)")
        }
        
        socket?.on("disconnect") {[weak self] data, ack in
            debugPrint("Remote Connection Disconnected")
            self?.removeRemotePresentationOverlay()
        }
        socket?.connect()
    }
    
    private func addRemotePresentationOverlay() {
        var window = UIApplication.sharedApplication().keyWindow
        if window == nil {
            window = UIApplication.sharedApplication().windows.first
        }
        
        if let overlay = remoteOverlay {
            overlay.removeFromSuperview()
            remoteOverlay = nil
        }
        
        if let window = window where remoteOverlay == nil {
            let overlay = UIView(frame: window.frame)
            overlay.layer.cornerRadius=2
            overlay.layer.borderWidth=5
            overlay.layer.borderColor = UIColor.redColor().CGColor
            overlay.opaque = true
            overlay.userInteractionEnabled = false
            overlay.layer.zPosition = CGFloat(FLT_MAX)
            remoteOverlay = overlay
        }
        
        if let overlay = remoteOverlay, window = window {
            window.addSubview(overlay)
        }
    }
    
    private func removeRemotePresentationOverlay() {
        if let overlay = remoteOverlay {
            overlay.removeFromSuperview()
            remoteOverlay = nil
        }
    }
    
    private func drawCircleOnOverlay(x: Double, y: Double) {
        if let overlay = remoteOverlay {
            let pointX = overlay.frame.size.width * CGFloat(x)
            let pointY = overlay.frame.size.height * CGFloat(y)
            
            let circle = Circle(frame: CGRectMake(pointX - 50, pointY - 50 ,50,50))
            circle.opaque = true
            circle.layer.cornerRadius = 25
            circle.clipsToBounds = true
            overlay.addSubview(circle)
            
            UIView.animateWithDuration(0.8, animations: { () -> Void in
                circle.alpha = 0
                circle.transform = CGAffineTransformMakeScale(1.5, 1.5)
                }, completion: { (ok) -> Void in
                    circle.removeFromSuperview()
            })
        }
    }
    
    private func captureScreen() -> UIImage? {
        let windows = UIApplication.sharedApplication().windows
        
        if let _ = windows.first {
            UIGraphicsBeginImageContextWithOptions(windows.first!.frame.size, windows.first!.opaque, 0.0)
            for window in windows {
                UIGraphicsGetCurrentContext()
                window.drawViewHierarchyInRect(CGRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height), afterScreenUpdates: false)
            }
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        } else {
            return nil
        }
    }
    
    private func requestSupport() {
        guard socket?.status == SocketIOClientStatus.Connected else {
            debugPrint("Remote Connection Not Connected - Will not transmit request support")
            return
        }
        
        let message = ["vendorid" : "\(vendorId)"]
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.socket?.emit("request support", message)
            
            // Dispatch after sending the last request
            // this will make sure that we dont accumilate too many
            // requests on a slow connection
            let q_background = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
            let delayInSeconds:Int64 = 5
            let popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * 1000000000)
            
            dispatch_after(popTime, q_background) { () -> Void in
                self.requestSupport()
            }
        }
    }
    
    private func transmitScreen() {
        guard socket?.status == SocketIOClientStatus.Connected else {
            debugPrint("Remote Connection Not Connected - Will not transmit screenshot")
            return
        }
        
        if let image = captureScreen() {
            let smallerImage = UIImageJPEGRepresentation(image, 0.0)
            let base64String = smallerImage?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
            
            if let base64String = base64String {
                let message = ["vendorid" : "\(vendorId)", "image" : base64String]
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    self.socket?.emit("upload image", message)
                    
                    // Dispatch after sending the image
                    // this will make sure that we dont accumilate too many
                    // images on a slow connection
                    let q_queue = dispatch_get_main_queue()
                    let delayInSeconds:Int64 = 1
                    let popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * 1000000000)
                    
                    dispatch_after(popTime, q_queue) { () -> Void in
                        self.transmitScreen()
                    }
                }
            }
        }
    }
}

private class Circle: UIView {
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(ovalInRect: rect)
        UIColor.blueColor().setFill()
        path.fill()
    }
}
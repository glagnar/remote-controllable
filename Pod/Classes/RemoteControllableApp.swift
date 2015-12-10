//
//  RemoteControllableApp.swift
//  Transmit screenshot
//
//  Created by Thomas Gilbert on 12/11/15.
//  Copyright © 2015 Thomas Gilbert. All rights reserved.
//

import Foundation
import Socket_IO_Client_Swift

public final class RemoteControllableApp {
    
    public static let sharedInstance = RemoteControllableApp()
    
    private var remoteOverlay: UIView?
    private var socket: SocketIOClient?
    
    private init() {}
    
    public func startConnection(url: String = "localhost:8006") {
        debugPrint("Remote Connection called at: \(url)")
        socket = SocketIOClient(socketURL: url, options: [.Log(false), .ForcePolling(true)])
        setupHandlers()
    }
    
    public func isConnected() -> Bool {
        debugPrint("Remote Connection Status Asked")
        if let socket = socket {
            return socket.status == SocketIOClientStatus.Connected ? true : false
        } else {
            return false
        }
    }
    
    public func stopConnection() {
        debugPrint("Remote Connection Closing")
        socket?.close()
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
        var window = UIApplication.sharedApplication().keyWindow
        if window == nil {
            window = UIApplication.sharedApplication().windows.first
        }
        
        if let window = window{
            UIGraphicsBeginImageContextWithOptions(window.frame.size, window.opaque, 0.0)
            window.layer.renderInContext(UIGraphicsGetCurrentContext()!)
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
        
        let message = ["vendorid" : "\(UIDevice().identifierForVendor!.UUIDString)"]
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.socket?.emit("request support", message)
        }
        
        let q_background = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        let delayInSeconds:Int64 = 5
        let popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * 1000000000)
        
        dispatch_after(popTime, q_background) { () -> Void in
            self.requestSupport()
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
		    let message = ["vendorid" : "\(UIDevice().identifierForVendor!.UUIDString)", "image" : base64String]
		    
		    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
			self.socket?.emit("upload image", message)
		    }
		}
        }
        let q_queue = dispatch_get_main_queue() 
        let delayInSeconds:Int64 = 1
        let popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * 1000000000)
        
        dispatch_after(popTime, q_queue) { () -> Void in
            self.transmitScreen()
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

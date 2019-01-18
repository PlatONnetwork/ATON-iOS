//
//  QRScannerViewController.swift
//  platonWallet
//
//  Created by matrixelement on 26/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import AVFoundation
import Localize_Swift

private let scanFrameSize: CGFloat = 257.0

class QRScannerViewController: BaseViewController,AVCaptureMetadataOutputObjectsDelegate {

    lazy var captureSession: AVCaptureSession! = {
        
        let session = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return nil}
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return nil
        }
        
        if (session.canAddInput(videoInput)) {
            session.addInput(videoInput)
        } else {
            failed()
            return nil
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (session.canAddOutput(metadataOutput)) {
            session.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return nil
        }
        
        return session
        
    }()
    
    lazy var previewLayer: AVCaptureVideoPreviewLayer! = {
        
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.frame = view.bounds
        layer.backgroundColor = UIColor(rgb: 0x1B2137, alpha: 0.5).cgColor
        layer.videoGravity = .resizeAspectFill
        return layer
        
    }()
    
    var scanCompletion: ((String)->Void)?
    
    lazy var scanLine: CALayer = {
        
        let layer = CALayer()
        layer.contents = UIImage(named: "qrcode_scan_line")?.cgImage
        layer.isHidden = true
        return layer
        
    }()
    
    convenience init(scanCompletion:@escaping (_ result: String) -> Void) {
        
        self.init()
        self.scanCompletion = scanCompletion
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        checkCamareAuthStatus()
        setupUI()
        
    }
     
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startScanLineAnimation()
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanLineAnimation()
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    public func rescan() {
        startScanLineAnimation()
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    func setupUI() {
        
        navigationItem.localizedText = "QRScanerVC_nav_title"

        addScanLayer()
    }
    
    func addScanLayer() {
        
        let layer = CALayer()
        layer.frame = view.bounds
        layer.backgroundColor = UIColor(rgb: 0x1B2137, alpha: 0.5).cgColor
        view.layer.addSublayer(layer)
        
        let path = UIBezierPath(rect:view.bounds)
        let x = (view.bounds.size.width - scanFrameSize) / 2
        let centerRect = CGRect(x: x, y: 137, width: scanFrameSize, height: scanFrameSize)
        
        path.append(UIBezierPath(rect: centerRect).reversing())
        let shape = CAShapeLayer()
        
        shape.path = path.cgPath
        layer.mask = shape
        
        let centerLayer = CALayer()
        centerLayer.frame = centerRect
        centerLayer.contents = UIImage(named: "qrCode_scan_frame")?.cgImage
        scanLine.frame = CGRect(x: 0, y: 0, width: centerLayer.frame.size.width, height: 3)
        centerLayer.addSublayer(scanLine)
        
        view.layer.addSublayer(centerLayer)
        
    }
    
    func checkCamareAuthStatus() {
        
        func showAlert() {
            
            let alert = PAlertController(title: Localized("alert_cameraUsageDeny_title"), message: Localized("alert_cameraUsageDeny_msg"))
            alert.addAction(title: Localized("alert_cancelBtn_title")) { 
                self.navigationController?.popViewController(animated: true)
            }
            
            alert.addAction(title: Localized("alert_cameraUsageDeny_gotoSettings_title")) { 
                
                UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                
            }
            
            alert.show(inViewController: self)
        }
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
            
        case .authorized:
            
            view.layer.insertSublayer(self.previewLayer, at: 0)
            
        case .denied:
            
            showAlert()
            
        case .notDetermined:
            
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                
                DispatchQueue.main.async {
                    if granted {
                        self.view.layer.insertSublayer(self.previewLayer, at: 0)
                    }else {
                        showAlert()
                    }
                }
                
            }
            
        default:
            break
        }
        
    }
    
    
    func startScanLineAnimation() {
        
        let animate = CABasicAnimation(keyPath: "position.y")
        animate.duration = 2
        animate.repeatCount = MAXFLOAT
        animate.toValue = scanFrameSize
        scanLine.add(animate, forKey: nil)
        scanLine.isHidden = false
    }
    
    func stopScanLineAnimation() {
        
        scanLine.removeAllAnimations()
        scanLine.isHidden = true
        
    }
    
//    func addLayer(){
//
//        let scannerViewWidth = view.bounds.width - 2 * 20
//        let topEndY = (view.bounds.height - scannerViewWidth) * 0.5 - 44
//        //top
//        let topLayer = addEdgeLayer(frame: CGRect(x: 0, y: 0, width: kUIScreenWidth, height: topEndY))
//        //left
//        let _ = addEdgeLayer(frame: CGRect(x: 0, y: topLayer.frame.maxY, width: 20, height: scannerViewWidth))
//        //right
//        let rightLayer = addEdgeLayer(frame: CGRect(x: 20 + scannerViewWidth, y: topLayer.frame.maxY, width: 20, height: scannerViewWidth))
//        //bottom
//        let _ = addEdgeLayer(frame: CGRect(x: 0, y: rightLayer.frame.maxY, width: kUIScreenWidth, height: kUIScreenHeight))
//        
//    }
//    
//    func addEdgeLayer(frame : CGRect) -> CALayer{
//        let layer = CALayer()
//        layer.frame = frame
//        layer.backgroundColor = UIColor(rgb: 0x1b27aa, alpha: 0.5).cgColor
//        view.layer.addSublayer(layer)
//
//        return layer
//    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { 
                
                if (captureSession?.isRunning == false) {
                    captureSession.startRunning()
                }
                return 
                
            }
            scanCompletion?(stringValue)
            //AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
//            found(code: stringValue)
            
        }
        
    }
    
//    func found(code: String) {
//        
//        DispatchQueue.main.async {
//            self.captureSession.stopRunning()
//        }
//    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    


}

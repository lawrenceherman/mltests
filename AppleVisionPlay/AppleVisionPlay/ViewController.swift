//
//  ViewController.swift
//  AppleVisionPlay
//
//  Created by Lawrence Herman on 1/22/18.
//  Copyright © 2018 Lawrence Herman. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

  let label: UILabel = {
    let label = UILabel()
    label.textColor = UIColor.white
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Label"
    label.font = label.font.withSize(30)
    return label
  }()
  
  
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
   
    setupCaptureSession()
  
    view.addSubview(label)
    setupLabel()
  }
  
  func setupLabel() {
    label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
  }
  
  func setupCaptureSession() {
    
    // create a new capture session
    let captureSession = AVCaptureSession()
    
    let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices
  
    // get capture device, add device input to the capture session
    do {
      if let captureDevice = availableDevices.first {
        captureSession.addInput(try AVCaptureDeviceInput(device: captureDevice))
      }
    } catch {
      print(error.localizedDescription)
    }
    
    // setup output, add output to our capture session
    let captureOutput = AVCaptureVideoDataOutput()
    captureSession.addOutput(captureOutput)
    
    let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer.frame = view.frame
    view.layer.addSublayer(previewLayer)
    
    
    // The startRunning() method is a blocking call which can take some time, therefore you should perform session setup on a serial queue so that the main queue isn't blocked (which keeps the UI responsive)
    captureSession.startRunning()
    
    captureOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
    
    }
  
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    
    guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
  
    let request = VNCoreMLRequest(model: model) { (finishedRequest, error) in
      guard let results = finishedRequest.results as? [VNClassificationObservation] else { return}
      guard let Observation = results.first else { return }
      
      DispatchQueue.main.async(execute: {
        self.label.text = "\(Observation.identifier)"
      })
    }
      guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
      
      // execute request
//      try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    
      try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])

  }
  
  

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }


}


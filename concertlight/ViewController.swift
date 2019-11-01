//
//  ViewController.swift
//  concertlight
//
//  Created by Rick Yip on 31/10/2019.
//  Copyright © 2019 gwong1si4. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate {
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    let movieOutput = AVCaptureMovieFileOutput()
    
    
    let capturedView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    let previewView: UIView = {
        let view = UIView()
        return view
    }()
    let popoButton: UIButton = {
        return buttonFactory(title: "Popo")
    }()
    
    let captureButton: UIButton = {
        return buttonFactory(title: "Capture")
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(previewView)
        previewView.frame = view.bounds
        previewView.addSubview(containerView)
        
        
        containerView.addSubview(popoButton)
        containerView.addSubview(captureButton)
        containerView.addSubview(captureButton)
        NSLayoutConstraint.activate([
            
            containerView.topAnchor.constraint(equalTo: previewView.bottomAnchor, constant: -100),
            containerView.heightAnchor.constraint(equalToConstant: 100),
            containerView.leadingAnchor.constraint(equalTo: previewView.leadingAnchor, constant: 0),
            containerView.trailingAnchor.constraint(equalTo: previewView.trailingAnchor, constant: 0),
            
            popoButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -100),
            popoButton.leadingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -80),
            popoButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            captureButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -100),
            captureButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            captureButton.trailingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 100)
        ])
        captureButton.addTarget(self, action: #selector(didTakePhoto), for: .touchUpInside)
        popoButton.addTarget(self, action: #selector(playPopo), for: .touchUpInside)
    }
    
    @objc func didTakePhoto(){
        print("didTakePhoto")
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @objc func playPopo(){
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
           DispatchQueue.global(qos: .background).async {
               if let device = AVCaptureDevice.default(for: AVMediaType.video){
                   if (device.hasTorch) {
                       do {
                           try device.lockForConfiguration()
                           if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                               device.torchMode = AVCaptureDevice.TorchMode.off
                           } else {
                               do {
                                   try device.setTorchModeOn(level: 1.0)
                               } catch {
                                   print(error)
                               }
                           }
                           device.unlockForConfiguration()
                       } catch {
                           print(error)
                       }
                   }
               }
           }
       }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("Unable to access back camera!")
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
            if false { // movie mode
                let microphone = AVCaptureDevice.default(for: AVMediaType.audio)!

                do {
                    let micInput = try AVCaptureDeviceInput(device: microphone)
                    if captureSession.canAddInput(micInput) {
                        captureSession.addInput(micInput)
                    }
                } catch {
                    print("Error setting device audio input: \(error)")
                    return
                }


                // Movie output
                if captureSession.canAddOutput(movieOutput) {
                    captureSession.addOutput(movieOutput)
                }
            
            }
        } catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
    }
    
    func setupLivePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspect
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        
        previewView.bringSubviewToFront(containerView)
        
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
            }
        }
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        
        let image = UIImage(data: imageData)
        capturedView.image = image
        
        UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
          if let error = error {
              // we got back an error!
              let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
              ac.addAction(UIAlertAction(title: "OK", style: .default))
              present(ac, animated: true)
          } else {
              let ac = UIAlertController(title: "Image Saved!", message: "Your image has been saved to your photos.", preferredStyle: .alert)
              ac.addAction(UIAlertAction(title: "OK", style: .default))
              present(ac, animated: true)
          }
      }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    class func buttonFactory(title: String) -> UIButton {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle(title, for: .normal)
        return btn
    }

    func tempURL() -> URL? {
         let directory = NSTemporaryDirectory() as NSString

         if directory != "" {
             let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
             return URL(fileURLWithPath: path)
         }

         return nil
     }

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

//         let vc = segue.destination as! VideoPlaybackViewController
//
//         vc.videoURL = sender as? URL

     }
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation

        switch UIDevice.current.orientation {
          case .portrait:
              orientation = AVCaptureVideoOrientation.portrait
          case .landscapeRight:
              orientation = AVCaptureVideoOrientation.landscapeLeft
          case .portraitUpsideDown:
              orientation = AVCaptureVideoOrientation.portraitUpsideDown
          default:
               orientation = AVCaptureVideoOrientation.landscapeRight
        }

        return orientation
    }
    
    func startRecording() {

        if movieOutput.isRecording == false {

        let connection = movieOutput.connection(with: AVMediaType.video)

        if (connection?.isVideoOrientationSupported)! {
            connection?.videoOrientation = currentVideoOrientation()
        }

        if (connection?.isVideoStabilizationSupported)! {
            connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
        }

    //             let device = activeInput.device
    //
    //             if (device.isSmoothAutoFocusSupported) {
    //
    //                 do {
    //                     try device.lockForConfiguration()
    //                     device.isSmoothAutoFocusEnabled = false
    //                     device.unlockForConfiguration()
    //                 } catch {
    //                    print("Error setting configuration: \(error)")
    //                 }
    //
    //             }
    //
    //             //EDIT2: And I forgot this
    //             outputURL = tempURL()
    //             movieOutput.startRecording(to: outputURL, recordingDelegate: self)
    //
    //             }
    //             else {
    //                 stopRecording()
    //             }
        }
    }

    func stopRecording() {

        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
         }
    }

    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {

    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {

         if (error != nil) {

             print("Error recording movie: \(error!.localizedDescription)")

         } else {

        //             let videoRecorded = outputURL! as URL
        //
        //             performSegue(withIdentifier: "showVideo", sender: videoRecorded)

         }

    }

}


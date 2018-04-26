//
//  sceneViewController.swift
//  DownloadTaskExample
//
//  Created by Michael Benton on 2/25/18.
//  Copyright © 2018 Example. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import ModelIO
import SceneKit.ModelIO

class sceneViewController: UIViewController, ARSCNViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    var downloadManagerObject:DownloadManager?
    
    let configuration = ARWorldTrackingConfiguration()
    var selectedItem: String?
    var node: SCNNode?
    var scene: SCNScene?
    var initializedView = false
    var data = Data()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configuration.planeDetection = .horizontal
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.session.run(configuration)
        self.sceneView.delegate = self
        
        node = SCNNode()
        scene = SCNScene()
        
        var hasImageForTexture = false
        let tempDocumentsURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?
        var itemObjUrl = tempDocumentsURL!.appendingPathComponent("\(urlStringForItemDownload)/\(urlStringForItemDownload)")
        var itemTextureUrl = tempDocumentsURL!.appendingPathComponent("mug/text")
        
        if(urlStringForItemDownload == "cup"){
            itemTextureUrl = tempDocumentsURL!.appendingPathComponent("cup/marbreblanc")
            itemTextureUrl.appendPathExtension("tiff")
            hasImageForTexture = true
        }
        
        if(urlStringForItemDownload == "mug"){
            itemTextureUrl = tempDocumentsURL!.appendingPathComponent("mug/text")
            itemTextureUrl.appendPathExtension("jpg")
            hasImageForTexture = true
        }
        
        if(hasImageForTexture){
            do{
                data = try Data(contentsOf: itemTextureUrl)
            }catch{
                print("Unable to parse image data")
            }
        }
        
        itemObjUrl.appendPathExtension("obj")
        
        let asset = MDLAsset(url: itemObjUrl)
        self.scene = SCNScene(mdlAsset: asset)
    }
    
    
    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        
        let sceneView = sender.view as! ARSCNView
        let tapLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        if !hitTest.isEmpty{
            if(!initializedView){
                initializedView = true
                print("in tapped part")
                self.sceneView.scene.rootNode.enumerateChildNodes({ (node, stop) in
                    node.removeFromParentNode()
                })
                self.addItem(hitTestResult: hitTest.first!)
            }
        }else{
            print("not in tapped")
        }
    }
    
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
     
        let results = sceneView.hitTest(sender.location(in: sender.view), types: ARHitTestResult.ResultType.featurePoint)
        guard let result: ARHitTestResult = results.first else{ return }
        
        let position = SCNVector3Make(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
        if(node != nil){
            node?.parent?.position = position
        }
    }
    
    @IBAction func twoFingerPanRotate(_ sender: UIPanGestureRecognizer) {
        
        let currentPivot = self.node?.pivot
        let changePivot = SCNMatrix4Invert((self.node?.transform)!)
        
        self.node?.pivot = SCNMatrix4Mult(changePivot, currentPivot!)
        
        self.node?.transform = SCNMatrix4Identity
        
        if(self.node != nil){
            let xPan = sender.velocity(in: sceneView).x/10000
            self.node?.runAction(SCNAction.rotateBy(x: 0, y: xPan, z: 0, duration: 0.1))
        }
    }
    
    @IBAction func pinchGesture(_ sender: UIPinchGestureRecognizer) {
        
        if(node != nil){
            
            if (sender.state == .changed) {
                let pinchScaleX = Float(sender.scale) * (node?.scale.x)!
                let pinchScaleY =  Float(sender.scale) * (node?.scale.y)!
                let pinchScaleZ =  Float(sender.scale) * (node?.scale.z)!
                node?.scale = SCNVector3(pinchScaleX, pinchScaleY, pinchScaleZ)
                sender.scale=1
            }
        }
    }
    
    
    func degToRad(deg: Float) -> Float {
        return deg / 180 * Float(Double.pi)
    }
    
    func addItem(hitTestResult: ARHitTestResult){
        print("in add item part")
        
        node = scene?.rootNode
        
        node?.geometry?.firstMaterial?.diffuse.contents = UIImage(data: data)
        node?.geometry?.firstMaterial?.specular.contents = UIImage(data: data)
        node?.geometry?.firstMaterial?.emission.contents = UIImage(data: data)
        node?.geometry?.firstMaterial?.normal.contents = UIImage(data: data)
        
        print(node?.childNodes)
        node = scene!.rootNode.childNode(withName: "_material_1", recursively: true)
        node?.geometry?.firstMaterial?.diffuse.contents = UIImage(data: data)
        node?.geometry?.firstMaterial?.specular.contents = UIImage(data: data)
        node?.geometry?.firstMaterial?.emission.contents = UIImage(data: data)
        node?.geometry?.firstMaterial?.normal.contents = UIImage(data: data)
        node?.scale = SCNVector3Make(0.1, 0.1, 0.1)
        let minimum = float3((node?.boundingBox.min)!)
        let maximum = float3((node?.boundingBox.max)!)
        let translation = (maximum - minimum) * 0.5
        node?.pivot = SCNMatrix4MakeTranslation(translation.x, translation.y, translation.z)
        sceneView.scene.rootNode.addChildNode(node!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        node?.removeFromParentNode()
        scene = nil
        node = nil
        sceneView = nil
        dismiss(animated: true, completion: nil)
    }
    
}

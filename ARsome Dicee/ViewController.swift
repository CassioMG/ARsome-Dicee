//
//  ViewController.swift
//  ARsome Dicee
//
//  Created by Cássio Marcos Goulart on 28/06/19.
//  Copyright © 2019 CMG Solutions. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    var casinoPlaneNode = SCNNode()
    
    var diceArray = [SCNNode]()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self

        sceneView.autoenablesDefaultLighting = true
        
        // Uncoment for debugging
        // sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard casinoPlaneNode.parent == nil else { return }
        
        if let planeAnchor = anchor as? ARPlaneAnchor {
            
            casinoPlaneNode = createPlane(withAnchor: planeAnchor)
            
            node.addChildNode(casinoPlaneNode)
        }
    }
    
    
    private func createPlane(withAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        let gridMaterial = SCNMaterial()
        gridMaterial.isDoubleSided = true
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/casino-texture.jpg")
        plane.materials = [gridMaterial]
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-.pi/2, 1, 0, 0)
        
        return planeNode
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touchInScene = touches.first?.location(in: sceneView) {
            
            if let hitLocation = sceneView.hitTest(touchInScene, types: .existingPlaneUsingExtent).first {
                
               addDice(atLocation: hitLocation)
            }
        }
    }
    
    
    private func addDice(atLocation location: ARHitTestResult) {
    
        let diceScene = SCNScene(named: "art.scnassets/Dice/dice.scn")!
        
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            
            diceArray.append(diceNode)
            
            diceNode.position = SCNVector3(
                location.worldTransform.columns.3.x,
                location.worldTransform.columns.3.y + diceNode.boundingBox.max.y * diceNode.scale.y,
                location.worldTransform.columns.3.z
            )
            
            sceneView.scene.rootNode.addChildNode(diceNode)
            
            roll(dice: diceNode)
        }
    }
    
    
    private func roll(dice: SCNNode) {
        
        let randomX = Float(Int.random(in: 1...4)) * (Float.pi/2)
        let randomZ = Float(Int.random(in: 1...4)) * (Float.pi/2)
        
        dice.runAction(
            SCNAction.rotateBy(
                x: CGFloat(randomX * 5),
                y: 0,
                z: CGFloat(randomZ * 5),
                duration: 0.5)
        )
    }
    
    
    private func rollAll() {
        for dice in diceArray {
            roll(dice: dice)
        }
    }
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    @IBAction func cleanUpScene(_ sender: UIBarButtonItem) {
        for dice in diceArray {
            dice.removeFromParentNode()
        }
        
        casinoPlaneNode.removeFromParentNode()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
}

//
//  GameScene.swift
//  Project 11
//
//  Created by macbook on 1/10/20.
//  Copyright © 2020 example. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    let colors = ["Blue", "Cyan", "Green", "Grey", "Purple", "Red", "Yellow"]
    var editLabel: SKLabelNode!
    var ballsCreated = 0 {
        didSet {
            ballsLabel.text = "Balls left: \(5 - ballsCreated)"
        }
    }
    var ballsLabel: SKLabelNode!
    var boxesCreated = 0
    
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -3
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        addChild(background)
        
        physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(fontNamed: "ChalkDuster")
        scoreLabel.position = CGPoint(x: 980, y: 700)
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "ChalkDuster")
        editLabel.position = CGPoint(x: 80, y: 700)
        editLabel.text = "Edit"
        editLabel.horizontalAlignmentMode = .left
        addChild(editLabel)
        
        ballsLabel = SKLabelNode(fontNamed: "ChalkDuster")
        ballsLabel.position = CGPoint(x: 512, y: 700)
        ballsLabel.horizontalAlignmentMode = .center
        ballsLabel.text = "Balls left: 5"
        addChild(ballsLabel)
        
        createSlot(point: CGPoint(x: 128, y: 0), isGood: true)
        createSlot(point: CGPoint(x: 384, y: 0), isGood: false)
        createSlot(point: CGPoint(x: 640, y: 0), isGood: true)
        createSlot(point: CGPoint(x: 896, y: 0), isGood: false)
        
        createBouncer(point: CGPoint(x: 0, y: 0))
        createBouncer(point: CGPoint(x: 256, y: 0))
        createBouncer(point: CGPoint(x: 512, y: 0))
        createBouncer(point: CGPoint(x: 768, y: 0))
        createBouncer(point: CGPoint(x: 1024, y: 0))
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        
        let objects = nodes(at: location)
        
        if objects.contains(editLabel) {
            editingMode.toggle()
        } else {
            if editingMode {
                if boxesCreated < 20 {
                    let size = CGSize(width: CGFloat.random(in: 16...200), height: CGFloat.random(in: 10...20))
                    let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                    box.physicsBody = SKPhysicsBody(rectangleOf: size)
                    box.physicsBody?.isDynamic = false
                    box.zRotation = CGFloat.random(in: 0...CGFloat.pi)
                    box.position = location
                    box.name = "box"
                    addChild(box)
                    boxesCreated += 1
                }
            } else {
                if boxesCreated == 20 {
                    if ballsCreated < 5 {
                        let ball = SKSpriteNode(imageNamed: "ball\(colors.randomElement()!)")
                        
                        ball.position = CGPoint(x: location.x, y: frame.height)
                        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
                        ball.physicsBody?.restitution = 0.4
                        ball.physicsBody?.contactTestBitMask = ball.physicsBody!.collisionBitMask
                        ball.name = "ball"
                        addChild(ball)
                        ballsCreated += 1
                    }
                }
            }
        }
    }
    
    func createBouncer(point: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false
        bouncer.position = point
        bouncer.zPosition = 1
        addChild(bouncer)
    }
    
    func createSlot(point: CGPoint, isGood: Bool) {
        let slot: SKSpriteNode
        let slotGlow: SKSpriteNode
        
        if isGood {
            slot = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slot.name = "good"
        } else {
            slot = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slot.name = "bad"
        }
        
        slot.position = point
        slot.physicsBody = SKPhysicsBody(rectangleOf: slot.size)
        slot.physicsBody?.isDynamic = false
        addChild(slot)
        
        slotGlow.position = point
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let foreverSpin = SKAction.repeatForever(spin)
        slotGlow.run(foreverSpin)
        addChild(slotGlow)
    }
    
    func collision(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            remove(ball)
            score += 1
            let emiter = SKEmitterNode(fileNamed: "ConfettiPaticles")!
            emiter.particleColor = UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1)
            emiter.position = ball.position
            addChild(emiter)
            ballsCreated -= 1
        } else if object.name == "bad" {
            remove(ball)
            score -= 1
            let emiter = SKEmitterNode(fileNamed: "FireParticles")!
            emiter.position = ball.position
            addChild(emiter)
        } else if object.name == "box" {
            remove(object)
        }
    }
    
    func remove(_ ball: SKNode) {
        ball.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else {return}
        guard let nodeB = contact.bodyB.node else {return}
        
        if nodeA.name == "ball" && nodeB.name == "bad"{
            collision(ball: nodeA, object: nodeB)
        } else if nodeB.name == "ball" && nodeA.name == "bad" {
            collision(ball: nodeB, object: nodeA)
        } else if nodeA.name == "ball" && nodeB.name == "good" {
            collision(ball: nodeA, object: nodeA)
        } else if nodeB.name == "ball" && nodeA.name == "good" {
            collision(ball: nodeB, object: nodeA)
        } else if nodeA.name == "ball" && nodeA.name == "box" {
            collision(ball: nodeA, object: nodeB)
        } else if nodeB.name == "ball" && nodeA.name == "box" {
            collision(ball: nodeB, object: nodeA)
        }
    }
}

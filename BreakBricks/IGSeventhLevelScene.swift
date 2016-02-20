//
//  IGSeventhLevelScene.swift
//  BreakBricks
//
//  Created by Rich Rosiak on 2/2/16.
//  Copyright © 2016 Rich Rosiak. All rights reserved.
//

import Foundation
import SpriteKit

//var SIDE_CANNON_BALL : UInt32 = 0b100000 //32 //00000000000000000000000000100000

/*public struct SeventhBitMasks {
    
    static let sideCannonBall : UInt32 = 0b100000 //32 //00000000000000000000000000100000
}*/

@objc class IGSeventhLevelScene : IGStartBrickScene {
    
    var playCannonSound : SKAction!
    var startingVelocity : CGVector!
    var sceneSetup : IGSceneSetup!
    
    override init(size: CGSize) {
        print("Initing 7th scene")
        
        super.init(size: size)
        
        self.sceneSetup = IGGameManager2.sharedInstance.sceneSetup2 //self.retrieveSceneSetup() as! IGSceneSetup //workaround for cyclic dependency with IGGameManager
        
        self.playCannonSound = SKAction.playSoundFileNamed("firecannon.wav", waitForCompletion: false)
        
        self.addBackgroundImage()
        
        let redBallImg : SKTexture = SKTexture(imageNamed: "art.scnassets/ball_red.png")
        self.ball.texture = redBallImg
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addBackgroundImage() {
        
        let backgroundNode = SKSpriteNode(imageNamed:self.sceneSetup.tankBackgroundImageName)  //"art.scnassets/tanks_backgrnd.jpg")
        backgroundNode.position = CGPointMake(self.size.width / 2, self.size.height / 2)
        
        backgroundNode.setScale(self.sceneSetup.tankBackScalingFactor) //(0.5)
        backgroundNode.zPosition = -1
        
        self.addChild(backgroundNode)
    }
        
    override func didBeginContact(contact: SKPhysicsContact) {
        
        super.didBeginContact(contact)
        
        //if self.shouldFireCannonBall() && self.notTheBall.physicsBody!.categoryBitMask == BRICK_CATEGORY {
        if self.notTheBall.physicsBody!.categoryBitMask == BRICK_CATEGORY {
            
            print("Fire cannon - the brick was hit!")
            //[self runAction:[SKAction performSelector:@selector(addCannonBallToScene) onTarget:self]];
            self.runAction(SKAction.performSelector("addCannonBallToScene", onTarget: self))
            self.runAction(self.playCannonSound)
        }
        
        if self.notTheBall.physicsBody?.categoryBitMask == SIDE_CANNON_BALL_CATEGORY {
            print("Contact began. Ball hit the cannon ball! Ball's velocity is dx: ", self.ball.physicsBody!.velocity.dx, " dy: ", self.ball.physicsBody!.velocity.dy)
        }
    }
    
    func shouldFireCannonBall() -> Bool {
        
        switch self.numberOfVisibleBricks % 2 { //only odd numb. of bricks
        case 1:
            return true
        default:
            return false
        }
    }
    
    override func didEndContact(contact: SKPhysicsContact) {
        
        print("Contact ended with category: ", self.notTheBall.physicsBody?.categoryBitMask)
        
        if self.notTheBall.physicsBody?.categoryBitMask == BRICK_CATEGORY ||
            self.notTheBall.physicsBody?.categoryBitMask == EDGE_CATEGORY ||
            self.notTheBall.physicsBody?.categoryBitMask == PADDLE_CATEGORY {
    
            print("Bounce - Setting new velocity abs vales for ball - dx: ", self.ball.physicsBody!.velocity.dx, " and dy: ", self.ball.physicsBody!.velocity.dy)
            
            self.startingVelocity = CGVectorMake(abs(self.ball.physicsBody!.velocity.dx), abs(self.ball.physicsBody!.velocity.dy))

            print("New starting vel dx ", self.startingVelocity.dx, " dy: ", self.startingVelocity.dy)
        }
        
        if self.notTheBall.physicsBody?.categoryBitMask == SIDE_CANNON_BALL_CATEGORY {
            print("Contact ended. Ball hit the cannon ball! Ball's velocity is dx: ", self.ball.physicsBody!.velocity.dx, " dy: ", self.ball.physicsBody!.velocity.dy, "Converting to prev velocity...")
            
            self.keepConstantVelocity()
        }
    }
    
    func keepConstantVelocity() {
        
        let dxMultiplyer : CGFloat = self.ball.physicsBody!.velocity.dx >= 0 ? 1 : -1
        let dyMultiplyer : CGFloat = self.ball.physicsBody!.velocity.dy >= 0 ? 1 : -1
        self.ball.physicsBody!.velocity = CGVectorMake(self.startingVelocity.dx * dxMultiplyer, self.startingVelocity.dy * dyMultiplyer)
    }
    
    func addCannonBallToScene() {
        
        print("Adding cannon ball to scene...")
        
        let cBall : SKSpriteNode = SKSpriteNode(imageNamed: "cannonball") //spriteNodeWithImageNamed("cannonball")
        
        cBall.position = CGPointMake(0.0, self.generateRandomHeightPosition());
        
        cBall.physicsBody = SKPhysicsBody(circleOfRadius: cBall.frame.size.height / 2)
        cBall.physicsBody!.friction = 0
        cBall.physicsBody!.linearDamping = 0
        cBall.physicsBody!.restitution = 1.0
        cBall.physicsBody!.categoryBitMask = SIDE_CANNON_BALL_CATEGORY
        cBall.physicsBody!.collisionBitMask = 0 //will not collide with anything! The ball's collisionBitMask specifies SIDE_CANNON_BALL_CATEGORY so the ball WILL collide with it
        
        self.addChild(cBall)
        
        cBall.physicsBody?.applyImpulse(CGVectorMake(15.0, 0))
    }
    
    func generateRandomHeightPosition() -> CGFloat {
        
        let floor : CGFloat! = PADDLE_Y_POSITION + 80
        let ceiling : CGFloat! = (self.view?.frame.size.height)! / 2 + 50
        
        let diff : CGFloat! = ceiling - floor
        return ((CGFloat(arc4random()) / CGFloat(UINT32_MAX)) * diff) + floor
    }
        
    override func update(currentTime: NSTimeInterval) {
        //print("In Update - Ball's veloc is dx: ", self.ball.physicsBody!.velocity.dx, " dy: ", self.ball.physicsBody!.velocity.dy)
    }
}
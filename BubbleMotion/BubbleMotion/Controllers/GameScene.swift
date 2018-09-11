import SpriteKit
import CoreMotion
import AudioToolbox

class GameScene: SKScene, SKPhysicsContactDelegate {
    var bubble = SKSpriteNode()
    var platform = SKSpriteNode()
    var background = SKSpriteNode()
    var motionManager = CMMotionManager()
    var destX:CGFloat  = 0.0
    var destY:CGFloat  = 0.0
    
    var lastUpdateTime: CFTimeInterval = 0.0
    var deltaTime: CFTimeInterval = 0.0
    var doSomethingTimer: CFTimeInterval = 0.0
    var isInContact: Bool = false
    var isBlinking: Bool = false
    
    var countdownTimer: Timer!
    var matchTime = 60
    var timeInContact = 0
    var timeOutContact = 0
    var gameState: GameState = GameState.Normal
    var acelerationIndex: Double = 100;
    
    override func didMove(to view: SKView) {
        self.scaleMode = .aspectFill
        let screenSize = UIScreen.main.bounds
        
        startTimer()
        platform = (self.childNode(withName: "platform") as? SKSpriteNode)!
        platform.name = "platform"
        
        bubble = (self.childNode(withName: "bubble") as? SKSpriteNode)!
        bubble.name = "bubble"
        bubble.position = CGPoint(x: screenSize.width/2, y: screenSize.height/2)
        
        self.physicsWorld.contactDelegate = self
        
        if motionManager.isAccelerometerAvailable == true {
            
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler:{
                data, error in
                
                let currentX = self.bubble.position.x
                let currentY = self.bubble.position.y
                
                if (self.gameState == GameState.Magnet) {
                    
                    if Double((data?.acceleration.x)!) != 0 {
                        let nextX = currentX - CGFloat((data?.acceleration.x)! * self.acelerationIndex)
                        if (nextX - self.bubble.size.height/2 > 0 && nextX < screenSize.width - self.bubble.size.height) {
                            self.destX = nextX
                        }
                    }
                    if Double((data?.acceleration.y)!) != 0 {
                        let nextY = currentY + CGFloat((data?.acceleration.y)! * self.acelerationIndex)
                        if (nextY - self.bubble.size.height > 0 && nextY < screenSize.height - self.bubble.size.height/2) {
                            self.destY = nextY
                        }
                    }
                    
                } else {
                    
                    if Double((data?.acceleration.y)!) != 0 {
                        let nextX = currentX - CGFloat((data?.acceleration.y)! * self.acelerationIndex)
                        if (nextX - self.bubble.size.height/2 > 0 && nextX < screenSize.width - self.bubble.size.height) {
                            self.destX = nextX
                        }
                    }
                    
                    if Double((data?.acceleration.x)!) != 0 {
                        let nextY = currentY + CGFloat((data?.acceleration.x)! * self.acelerationIndex)
                        if (nextY - self.bubble.size.height > 0 && nextY < screenSize.height - self.bubble.size.height/2) {
                            self.destY = nextY
                        }
                    }
                }
            })
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact){
        print("collided! didEnd")
        self.isInContact = false
        self.timeInContact = 0
        self.timeOutContact = 0
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        updateBubble()
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        print("collided! didBegin")
        self.isInContact = true
        self.timeInContact = 0
        self.timeOutContact = 0
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        updateBubble()
        applyNormalState ()
    }
    
    func updateBubble () {
        self.bubble.texture = SKTexture(imageNamed: getBubbleName())
    }
    
    
    func getBubbleName () -> String {
        var name = ""
        
        if self.isInContact {
            name = "bubble_happy"
        } else {
            name = "bubble_sad"
        }
        if self.isBlinking {
            name += "_blink"
        }
        if (self.gameState == GameState.Frozen){
            name += "_iced"
        }
        return name
    }
    
    func blink (_ currentTime: CFTimeInterval) {
        deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        doSomethingTimer += deltaTime
        
        if doSomethingTimer >= 5.0 {
            if (!isBlinking) {
                isBlinking = true
            }
            doSomethingTimer = 0.0
        } else if doSomethingTimer >= 0.2 && isBlinking {
            isBlinking = false
        }
        updateBubble()
    }
    
    
    override func update(_ currentTime: CFTimeInterval) {
        
        blink (currentTime)
        
        if (self.bubble.position.x != destX) {
            let action = SKAction.moveTo(x: destX, duration: 0.04)
            self.bubble.run(action)
        }
        
        if (self.bubble.position.y != destY) {
            let action2 = SKAction.moveTo(y: destY, duration: 0.04)
            self.bubble.run(action2)
        }
    }
    
    
    func startTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        
        if (self.isInContact) {
            self.timeInContact += 1
        } else {
            self.timeOutContact += 1
        }
        
        if (timeOutContact == 3 ) {
            applyMagnetEffect ()
        }
        
        if matchTime != 0 {
            matchTime -= 1
        } else {
            endTimer()
        }
    }
    
    func endTimer() {
        countdownTimer.invalidate()
    }
    
    func applyFrozenEffect () {
        self.gameState = GameState.Frozen
        acelerationIndex = 10;
    }
    
    func applyFocusEffect () {
        self.gameState = GameState.Focus
        self.platform.scale(to: CGSize(width: 100, height: 100))
    }
    
    func applyZeroGravityEffect () {
        self.gameState = GameState.GravityZero
        self.acelerationIndex = 300;
    }
    
    func applyMagnetEffect () {
        self.gameState = GameState.Magnet
    }
    
    func applyNormalState () {
        self.gameState = GameState.Normal
        acelerationIndex = 100;
        self.platform.scale(to: CGSize(width: 160, height: 160))
    }
    
}

enum GameState {
    case Normal
    case Frozen
    case GravityZero
    case Focus
    case Magnet
}

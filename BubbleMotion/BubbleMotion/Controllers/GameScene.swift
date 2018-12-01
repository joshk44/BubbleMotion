import SpriteKit
import CoreMotion
import AudioToolbox

protocol GameSceneDelegate {
    func sendBomb (bomb: GameState)
    func sendFinishMatch (points: Int)
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let BOMB_TIME = 10
    let NO_BOMB = -1
    
    var bubble = SKSpriteNode()
    var platform = SKSpriteNode()
    var background = SKSpriteNode()
    var remainingTime = SKLabelNode()
    var bombReceived = SKLabelNode()
    var points = SKLabelNode()
    var bombButton = SKSpriteNode()
    
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
    let matchLenght = 60
    var timeInContact = 0
    var timeOutContact = 0
    var timeInContactTotal = 0
    var bombtime = -1
    var gameState: GameState = GameState.Normal
    var acelerationIndex: Double = 100
    var currentAvailableBomb: GameState = GameState.Normal
    var myPoints = 0
    
    var delegateVC : GameSceneDelegate?


    
    override func didMove(to view: SKView) {
        let screenSize = view.frame.size
        
        startTimer()
        platform = (self.childNode(withName: "platform") as? SKSpriteNode)!
        platform.position = CGPoint(x: screenSize.width/2, y: screenSize.height/2)
        platform.name = "platform"
        
        bubble = (self.childNode(withName: "bubble") as? SKSpriteNode)!
        bubble.name = "bubble"
        destX = screenSize.width/2
        destY = screenSize.height/2
        
        remainingTime = (self.childNode(withName: "timeOut") as? SKLabelNode)!
        points = (self.childNode(withName: "points") as? SKLabelNode)!
        
        bombReceived = (self.childNode(withName: "bombReceived") as? SKLabelNode)!
        bombReceived.position = CGPoint(x: screenSize.width/2, y: 30)

        
        background = (self.childNode(withName: "background") as? SKSpriteNode)!
        background.scale(to: CGSize(width: view.frame.size.width, height: view.frame.size.height))
        background.position = CGPoint(x: screenSize.width/2, y: screenSize.height/2)
        
        bombButton  = (self.childNode(withName: "bombButton") as? SKSpriteNode)!
        bombButton.position = CGPoint(x: screenSize.width - bombButton.size.width/2, y: 0 + bombButton.size.height/2)
        
        self.physicsWorld.contactDelegate = self
        
        if motionManager.isAccelerometerAvailable == true {
            
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler:{
                data, error in
                
                let currentX = self.bubble.position.x
                let currentY = self.bubble.position.y
                
                if (self.gameState == GameState.Magnet) {
                    
                    if Double((data?.acceleration.x)!) != 0 {
                        let nextX = currentX - CGFloat((data?.acceleration.x)! * self.acelerationIndex)
                        if (nextX - self.bubble.size.height / 2 > 0 && nextX < screenSize.width - self.bubble.size.height) {
                            self.destX = nextX
                        }
                    }
                    if Double((data?.acceleration.y)!) != 0 {
                        let nextY = currentY + CGFloat((data?.acceleration.y)! * self.acelerationIndex)
                        if (nextY - self.bubble.size.height > 0 && nextY < screenSize.height - self.bubble.size.height / 2) {
                            self.destY = nextY
                        }
                    }
                    
                } else {
                    
                    if Double((data?.acceleration.y)!) != 0 {
                        let nextX = currentX - CGFloat((data?.acceleration.y)! * self.acelerationIndex)
                        if (nextX - self.bubble.size.height / 2 > 0 && nextX < screenSize.width - self.bubble.size.height / 2) {
                            self.destX = nextX
                        }
                    }
                    
                    if Double((data?.acceleration.x)!) != 0 {
                        let nextY = currentY + CGFloat((data?.acceleration.x)! * self.acelerationIndex)
                        if (nextY - self.bubble.size.height / 2 > 0 && nextY < screenSize.height - self.bubble.size.height / 2) {
                            self.destY = nextY
                        }
                    }
                }
            })
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let node : SKNode = self.atPoint(location)
            if node.name == "bombButton" {
                if (currentAvailableBomb != GameState.Normal){
                    delegateVC!.sendBomb(bomb: currentAvailableBomb)
                    currentAvailableBomb = GameState.Normal
                    self.bombButton.texture = SKTexture(imageNamed: "normal")
                    self.timeInContact = 0
                }
            }
        }
    }
    
    func setBomb (bomb: GameState){
        bombtime = BOMB_TIME;
        self.applyNormalState()
        switch bomb {
        case GameState.Frozen:
            self.applyFrozenEffect()
        case GameState.GravityZero:
            self.applyZeroGravityEffect()
        case GameState.Focus:
            self.applyFocusEffect()
        case GameState.Magnet:
            self.applyMagnetEffect()
        default:
            print ("switch error")
        }
        updateBombReceivedLabel ()
    }
    
    func didEnd(_ contact: SKPhysicsContact){
        //print("collided! didEnd")
        self.isInContact = false
        self.timeInContact = 0
        self.timeOutContact = 0
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        updateBubble()
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        //print("collided! didBegin")
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
        
        if Int(doSomethingTimer) >= Int.random(in: 1 ... 5) {
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
        multiplayerRules ()
    }
    
    func multiplayerRules () {
        self.remainingTime.text = "\(matchTime)"
        
        if (self.isInContact) {
            self.timeInContactTotal += 1
        }
        
        if (self.isInContact) {
            self.timeInContact += 1
        }
        
        if (self.bombtime > 0) {
            self.bombtime -= 1
            updateBombReceivedLabel ();
        } else if (self.bombtime == 0){
            self.applyNormalState()
            self.bombtime = NO_BOMB
        }
        
        if (self.timeInContact > 9){
            if (self.currentAvailableBomb == GameState.Normal){
                switch Int.random(in: 0 ... 3) {
                case 0:
                    self.currentAvailableBomb = GameState.Frozen
                    self.bombButton.texture = SKTexture(imageNamed: "frozen")
                case 1:
                    self.currentAvailableBomb = GameState.GravityZero
                    self.bombButton.texture = SKTexture(imageNamed: "gravity")
                case 2:
                    self.currentAvailableBomb = GameState.Focus
                    self.bombButton.texture = SKTexture(imageNamed: "focus")
                case 3:
                    self.currentAvailableBomb = GameState.Magnet
                    self.bombButton.texture = SKTexture(imageNamed: "magnet")
                default:
                    print ("switch error")
                }
                print (self.currentAvailableBomb.rawValue)
                
            }
        }
        
        myPoints = (self.timeInContactTotal * 10 ) - ((self.matchLenght - self.matchTime - self.timeInContactTotal)  * 2)
        
        self.points.text = "\(myPoints)"
        
        if matchTime > 0 {
            matchTime -= 1
            print ("matchTime non 0")
        } else if matchTime == 0 {
            endTimer()
            matchTime -= 1
            delegateVC!.sendFinishMatch (points: myPoints)
            print ("matchTime 0")
        }
        print (self.gameState.rawValue)
    }

    
    func endTimer() {
        countdownTimer.invalidate()
        countdownTimer = nil
        print ("endTimer")
    }
    
    func applyFrozenEffect () {
        print ("applyFrozenEffect")
        self.gameState = GameState.Frozen
        acelerationIndex = 10;
    }
    
    func applyFocusEffect () {
        print ("applyFocusEffect")
        self.gameState = GameState.Focus
        self.platform.scale(to: CGSize(width: 100, height: 100))
    }
    
    func applyZeroGravityEffect () {
        print ("applyZeroGravityEffect")
        self.gameState = GameState.GravityZero
        self.acelerationIndex = 300;
    }
    
    func applyMagnetEffect () {
        print ("applyMagnetEffect")
        self.gameState = GameState.Magnet
    }
    
    func applyNormalState () {
        print ("applyNormalState")
        self.gameState = GameState.Normal
        acelerationIndex = 100;
        self.platform.scale(to: CGSize(width: 160, height: 160))
    }
    
    func updateBombReceivedLabel () {
        if (bombtime>0) {
            self.bombReceived.text = "\(gameState.rawValue.capitalized) recibido termina en: \(bombtime)"
        } else {
            self.bombReceived.text = ""
        }
    }
}

enum GameState : String {
    case Normal = "Nomral"
    case Frozen = "Frozen"
    case GravityZero = "GravityZero"
    case Focus = "Focus"
    case Magnet = "Magnet"
}

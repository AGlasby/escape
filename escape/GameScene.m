//
//  GameScene.m
//  escape
//
//  Created by Alan Glasby on 09/10/2016.
//  Copyright © 2016 Alan Glasby. All rights reserved.
//

#import "GameScene.h"
#import "GameOverScene.h"

static const CGFloat kTrackPointsPerSecond = 1000;

static const uint32_t categoryFence = 0x1 << 3;
static const uint32_t categoryPaddle = 0x1 << 2;
static const uint32_t categoryBlock = 0x1 << 1;
static const uint32_t categoryBall = 0x1 << 0;

@interface GameScene () <SKPhysicsContactDelegate>

@property (nonatomic, strong, nullable) UITouch *motivatingTouch;

@end

@implementation GameScene {

}

- (void)didMoveToView:(SKView *)view {
    // Setup your scene here

    self.name = @"Fence";
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.categoryBitMask = categoryFence;
    self.physicsBody.collisionBitMask = 0x0;
    self.physicsWorld.contactDelegate = self;

    SKSpriteNode *background = (SKSpriteNode *) [self childNodeWithName:@"Background"];
    background.zPosition = 0; // make sure background is at bottom of stack
    background.lightingBitMask = 0x1;


    SKLightNode *light = [SKLightNode new];
    light.categoryBitMask = 0x1;
    light.falloff = 1;
    light.ambientColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    light.ambientColor = [UIColor colorWithRed:0.07 green:0.7 blue:1.0 alpha:1.0];
    light.shadowColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    light.zPosition = 1;

    SKSpriteNode *blueBall = [SKSpriteNode spriteNodeWithImageNamed:@"blue ball.png"];
    blueBall.name = @"Ball";
    blueBall.position = CGPointMake(60.0, 30.0);
    blueBall.zPosition = 1; // ball on layer above background
    blueBall.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:blueBall.size.width/2];
    blueBall.physicsBody.dynamic = YES;
    blueBall.physicsBody.friction = 0.0;
    blueBall.physicsBody.restitution = 1.0;
    blueBall.physicsBody.linearDamping = 0.0;
    blueBall.physicsBody.angularDamping = 0.0;
    blueBall.physicsBody.allowsRotation = NO;
    blueBall.physicsBody.mass = 1.0;
    blueBall.physicsBody.velocity = CGVectorMake(200.0, 200.0);
    blueBall.physicsBody.affectedByGravity = NO;
    blueBall.physicsBody.categoryBitMask = categoryBall;
    blueBall.physicsBody.collisionBitMask = categoryBall | categoryFence | categoryBlock | categoryPaddle;
    blueBall.physicsBody.contactTestBitMask = categoryFence | categoryPaddle;
    blueBall.physicsBody.usesPreciseCollisionDetection = YES;
//    [blueBall addChild:light];
    [self addChild:blueBall];

    SKSpriteNode *redBall = [SKSpriteNode spriteNodeWithImageNamed:@"red ball.png"];
    redBall.name = @"Ball";
    redBall.position = CGPointMake(60.0, 75.0);
    redBall.zPosition = 1; // ball on layer above background
    redBall.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:redBall.size.width/2];
    redBall.physicsBody.dynamic = YES;
    redBall.physicsBody.friction = 0.0;
    redBall.physicsBody.restitution = 1.0;
    redBall.physicsBody.linearDamping = 0.0;
    redBall.physicsBody.angularDamping = 0.0;
    redBall.physicsBody.allowsRotation = NO;
    redBall.physicsBody.mass = 1.0;
    redBall.physicsBody.velocity = CGVectorMake(200.0, 200.0);
    redBall.physicsBody.affectedByGravity = NO;
    redBall.physicsBody.categoryBitMask = categoryBall;
    redBall.physicsBody.collisionBitMask = categoryBall | categoryFence | categoryBlock | categoryPaddle;
    redBall.physicsBody.contactTestBitMask = categoryFence | categoryPaddle;
    redBall.physicsBody.usesPreciseCollisionDetection = YES;
    [self addChild:redBall];

    CGPoint blueBallAnchor = CGPointMake(blueBall.position.x, blueBall.position.y);
    CGPoint redBallAnchor = CGPointMake(redBall.position.x, redBall.position.y);
    SKPhysicsJointSpring *joint = [SKPhysicsJointSpring jointWithBodyA:blueBall.physicsBody bodyB:redBall.physicsBody anchorA:blueBallAnchor anchorB:redBallAnchor];
    joint.damping = 0.0;
    joint.frequency = 1.75;
    [self.scene.physicsWorld addJoint:joint];

    SKSpriteNode *paddle = [SKSpriteNode spriteNodeWithImageNamed:@"Paddle.png"];
    paddle.name = @"Paddle";
    paddle.position = CGPointMake(self.size.width/2, 100);
    paddle.zPosition = 1;
    paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(paddle.size.width, paddle.size.height)];
    paddle.physicsBody.dynamic = NO;
    paddle.physicsBody.friction = 0.0;
    paddle.physicsBody.restitution = 0.75;
    paddle.physicsBody.linearDamping = 0.0;
    paddle.physicsBody.angularDamping = 0.0;
    paddle.physicsBody.allowsRotation = NO;
    paddle.physicsBody.mass = 1.0;
    paddle.physicsBody.velocity = CGVectorMake(0.0, 0.0);
    paddle.physicsBody.affectedByGravity = NO;
    paddle.physicsBody.categoryBitMask = categoryPaddle;
    paddle.physicsBody.collisionBitMask = 0x0;
    paddle.physicsBody.contactTestBitMask = categoryBall;
    paddle.physicsBody.usesPreciseCollisionDetection = YES;
    paddle.lightingBitMask = 0x1;
    [self addChild:paddle];

    SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:@"block.png"];
    CGFloat kBlockWidth = node.size.width;
    CGFloat kBlockHeight = node.size.height;
    CGFloat kBlockHorozontalSpacing = 20.0;
    int kBlocksPerRow = (self.size.width) / (kBlockWidth + kBlockHorozontalSpacing);
    for (int i = 0; i < kBlocksPerRow; i++) {
        node = [SKSpriteNode spriteNodeWithImageNamed:@"block.png"];
        node.name = @"Block";
        node.position = CGPointMake(kBlockHorozontalSpacing/2 + kBlockWidth/2 + i*(kBlockWidth + kBlockHorozontalSpacing), self.size.height - 100);
        node.zPosition = 1;
        node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:node.size center:CGPointMake(0, 0)];
        node.physicsBody.dynamic = NO;
        node.physicsBody.friction = 0.0;
        node.physicsBody.restitution = 1.0;
        node.physicsBody.linearDamping = 0.0;
        node.physicsBody.angularDamping = 0.0;
        node.physicsBody.allowsRotation = NO;
        node.physicsBody.mass = 1.0;
        node.physicsBody.velocity = CGVectorMake(0.0, 0.0);
        node.physicsBody.affectedByGravity = NO;
        node.physicsBody.categoryBitMask = categoryBlock;
        node.physicsBody.collisionBitMask = 0x0;
        node.physicsBody.contactTestBitMask = categoryBall;
        node.physicsBody.usesPreciseCollisionDetection = NO;
        node.lightingBitMask = 0x1;
        [self addChild:node];
    }

    kBlocksPerRow = ((self.size.width) / (kBlockWidth + kBlockHorozontalSpacing)) - 1;
    for (int i = 0; i < kBlocksPerRow; i++) {
        node = [SKSpriteNode spriteNodeWithImageNamed:@"block.png"];
        node.name = @"Block";
        node.position = CGPointMake(kBlockHorozontalSpacing + kBlockWidth + i*(kBlockWidth + kBlockHorozontalSpacing), self.size.height - 100 - 1.5 * kBlockHeight);
        node.zPosition = 1;
        node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:node.size center:CGPointMake(0, 0)];
        node.physicsBody.dynamic = NO;
        node.physicsBody.friction = 0.0;
        node.physicsBody.restitution = 1.0;
        node.physicsBody.linearDamping = 0.0;
        node.physicsBody.angularDamping = 0.0;
        node.physicsBody.allowsRotation = NO;
        node.physicsBody.mass = 1.0;
        node.physicsBody.velocity = CGVectorMake(0.0, 0.0);
        node.physicsBody.affectedByGravity = NO;
        node.physicsBody.categoryBitMask = categoryBlock;
        node.physicsBody.collisionBitMask = 0x0;
        node.physicsBody.contactTestBitMask = categoryBall;
        node.physicsBody.usesPreciseCollisionDetection = NO;
        node.lightingBitMask = 0x1;
        [self addChild:node];
    }

    kBlocksPerRow = (self.size.width) / (kBlockWidth + kBlockHorozontalSpacing);
    for (int i = 0; i < kBlocksPerRow; i++) {
        node = [SKSpriteNode spriteNodeWithImageNamed:@"block.png"];
        node.name = @"Block";
        node.position = CGPointMake(kBlockHorozontalSpacing/2 + kBlockWidth/2 + i*(kBlockWidth + kBlockHorozontalSpacing), self.size.height - 100 - 3 * kBlockHeight);
        node.zPosition = 1;
        node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:node.size center:CGPointMake(0, 0)];
        node.physicsBody.dynamic = NO;
        node.physicsBody.friction = 0.0;
        node.physicsBody.restitution = 1.0;
        node.physicsBody.linearDamping = 0.0;
        node.physicsBody.angularDamping = 0.0;
        node.physicsBody.allowsRotation = NO;
        node.physicsBody.mass = 1.0;
        node.physicsBody.velocity = CGVectorMake(0.0, 0.0);
        node.physicsBody.affectedByGravity = NO;
        node.physicsBody.categoryBitMask = categoryBlock;
        node.physicsBody.collisionBitMask = 0x0;
        node.physicsBody.contactTestBitMask = categoryBall;
        node.physicsBody.usesPreciseCollisionDetection = NO;
        node.lightingBitMask = 0x1;
        [self addChild:node];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    const CGRect touchRegion = CGRectMake(0, 0, self.size.width, self.size.height / 3);
    for(UITouch *touch in touches) {
        CGPoint p = [touch locationInNode:self];
        if(CGRectContainsPoint(touchRegion, p)) {
            self.motivatingTouch = touch;
        }
    }
    [self trackPaddleToMotivatingTouches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self trackPaddleToMotivatingTouches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if([touches containsObject:self.motivatingTouch])
        self.motivatingTouch = nil;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if([touches containsObject:self.motivatingTouch])
        self.motivatingTouch = nil;
}

-(void) trackPaddleToMotivatingTouches {
    SKNode *node = [self childNodeWithName:@"Paddle"];
    UITouch *touch = self.motivatingTouch;
    if(!touch)
        return;
    CGFloat xPos = [touch locationInNode:self].x;
    NSTimeInterval duration = ABS(xPos - node.position.x) / kTrackPointsPerSecond;
    [node runAction:[SKAction moveToX:xPos duration:duration]];
}

- (void) didBeginContact:(SKPhysicsContact *)contact {
    NSString *nameA = contact.bodyA.node.name;
    NSString *nameB = contact.bodyB.node.name;
    if(([nameA containsString:@"Fence"] && [nameB containsString:@"Ball"]) || ([nameA containsString:@"Ball"] && [nameB containsString:@"Fence"])) {
        if(contact.contactPoint.y < 10) {
            SKView *skview = (SKView *) self.view;
            [self removeFromParent];
            GameOverScene *scene = [GameOverScene nodeWithFileNamed:@"GameOverScene"];
            scene.scaleMode = SKSceneScaleModeAspectFill;
            [skview presentScene:scene];
        }
    }

}

- (void)touchDownAtPoint:(CGPoint)pos {

}

- (void)touchMovedToPoint:(CGPoint)pos {

}

- (void)touchUpAtPoint:(CGPoint)pos {

}

-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered

    static const int kMaxSpeed = 1500;
    static const int kMinSpeed = 400;

    SKNode *ball1 = [self childNodeWithName:@"Ball1"];
    SKNode *ball2 = [self childNodeWithName:@"Ball2"];

    float dx = (ball1.physicsBody.velocity.dx + ball2.physicsBody.velocity.dx)/2;
    float dy = (ball1.physicsBody.velocity.dy + ball2.physicsBody.velocity.dy)/2;
    float speed = sqrtf(dx*dx + dy*dy);

    if (speed > kMaxSpeed) {
        ball1.physicsBody.linearDamping += 0.1f;
        ball2.physicsBody.linearDamping += 0.1f;
    } else if (speed < kMinSpeed){
        ball1.physicsBody.linearDamping -= 0.1f;
        ball2.physicsBody.linearDamping -= 0.1f;
    } else {
        ball1.physicsBody.linearDamping = 0.0f;
        ball2.physicsBody.linearDamping = 0.0f;
    }

}

@end

//
//  GameOverScene.m
//  escape
//
//  Created by Alan Glasby on 09/10/2016.
//  Copyright © 2016 Alan Glasby. All rights reserved.
//

#import "GameOverScene.h"
#import "GameScene.h"

@implementation GameOverScene

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (touches) {

        SKView *skView = (SKView *)self.view;

        // Load the SKScene from 'GameScene.sks'
        GameScene *scene = [GameScene nodeWithFileNamed:@"GameScene"];

        // Set the scale mode to scale to fit the window
        scene.scaleMode = SKSceneScaleModeAspectFill;

        // Present the scene
        [skView presentScene:scene];
    }
}

@end

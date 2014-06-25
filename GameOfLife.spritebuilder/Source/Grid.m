//
//  Grid.m
//  GameOfLife
//
//  Created by Brandon Richey on 6/25/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Grid.h"
#import "Creature.h"

static const int GRID_ROWS = 8;
static const int GRID_COLUMNS = 10;

@implementation Grid
{
    NSMutableArray *_gridArray;
    float _cellWidth;
    float _cellHeight;
}

-(void)onEnter
{
    [super onEnter];
    [self setupGrid];
    
    // Accept touches on the grid
    self.userInteractionEnabled = YES;
}

-(void)setupGrid
{
    _cellWidth = self.contentSize.width / GRID_COLUMNS;
    _cellHeight = self.contentSize.height / GRID_ROWS;
    
    float x = 0;
    float y = 0;
    
    _gridArray = [NSMutableArray array];
    // Initialize Creatures
    for (int i = 0; i < GRID_ROWS; i++) {
        _gridArray[i] = [NSMutableArray array];
        x = 0;
        
        for (int j = 0; j < GRID_COLUMNS; j++) {
            Creature *creature  = [[Creature alloc] initCreature];
            creature.anchorPoint = ccp(0, 0);
            creature.position    = ccp(x, y);
            [self addChild:creature];
            
            _gridArray[i][j] = creature;
            
            x += _cellWidth;
        }
        y += _cellHeight;
    }
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInNode:self];
    Creature *creature = [self creatureForTouchPosition:touchLocation];
    creature.isAlive = !creature.isAlive;
}

-(Creature *)creatureForTouchPosition:(CGPoint)touchLocation
{
    int y = touchLocation.y / _cellHeight;
    int x = touchLocation.x / _cellWidth;
    return _gridArray[y][x];
}

-(void)evolveStep
{
    [self countNeighbors];
    [self updateCreatures];
    _generation++;
}

-(void)countNeighbors
{
    for (int i = 0; i < [_gridArray count]; i++) {
        for (int j = 0; j < [_gridArray[i] count]; j++) {
            Creature *currentCreature = _gridArray[i][j];
            currentCreature.livingNeighbors = 0;
            
            for (int x = (i-1); x <= (i+1); x++) {
                for (int y = (j-1); y <= (j+1); y++) {
                    BOOL isIndexValid;
                    isIndexValid = [self isIndexValidForX:x andY:y];
                    
                    if (!((x == i) && (y == j)) && isIndexValid) {
                        Creature *neighbor = _gridArray[x][y];
                        if (neighbor.isAlive) {
                            currentCreature.livingNeighbors += 1;
                        }
                    }
                }
            }
        }
    }
}
                             
-(BOOL)isIndexValidForX:(int)x andY:(int)y
{
    BOOL isIndexValid = YES;
    if (x < 0 || y < 0 || x >= GRID_ROWS || y >= GRID_COLUMNS) {
        isIndexValid = NO;
    }
    return isIndexValid;
}

-(void)updateCreatures
{
    int numAlive = 0;
    for (int i = 0; i < GRID_ROWS; i++) {
        for (int j = 0; j < GRID_COLUMNS; j++) {
            Creature *creature = _gridArray[i][j];
            if (creature.livingNeighbors == 3) {
                creature.isAlive = YES;
                numAlive++;
            } else if (creature.livingNeighbors <= 1 || creature.livingNeighbors >= 4) {
                creature.isAlive = NO;
            }
        }
    }
    _totalAlive = numAlive;
}

@end

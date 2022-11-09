/*
 *  CGPointUtil.c
 *  Meon
 *
 *  Created by Jean-Christophe Amiel on 4/22/10.
 *  Copyright 2010 Manbolo. All rights reserved.
 *
 */

#include "CGPointUtil.h"
#include <math.h>

CGFloat distanceBetweenTwoPoints(CGPoint point1, CGPoint point2){
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    return (CGFloat)sqrt(dx*dx + dy*dy );
}

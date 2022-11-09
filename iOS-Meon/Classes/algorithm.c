/*
 *  algorithm.c
 *  Meon
 *
 *  Created by Jean-Christophe Amiel on 1/17/10.
 *  Copyright 2010 Manbolo. All rights reserved.
 *
 */
#include "CMType.h"
#include "algorithm.h"
#include "tile.h"
#include <stdbool.h>
#include <stdlib.h>

/**
 * Compute way of the light
 * @param[in] cell array of cell level
 * @param[in] index index of the source cell
 * @param[in] lights array of light state for each cells level
 * @param[in] sourceType type of the source one of kTileGreenMeonS kTileGreenMeonW kTileGreenMeonN kTileGreenMeonE
 * @param[in] color color of the light 1=white, 2=red, 3=yellow, 4=blue
 * @param[in/out] array of light in each cell
 * @param[in/out] number of meon reached
 */
void computeLightWay(uint32* cells, uint32 index, uint8 sourceType, uint8 color, uint8* lights, uint8* meonReached)
{
    int8 decay[4][2] = {{0, 1}, {-1, 0}, {0,-1},{1, 0}};
	uint32 cell = 0;
    uint8 light = 0, old_color;
	int32 dx, dy, col, row, tmp;
	bool foundWall = false, isLightHorizontal, foundMirror1, foundMirror2;
	sourceType -= kTileGreenMeonS;
	bool foundMeon;
    
	dx		= decay[sourceType][0];
	dy		= decay[sourceType][1];
	col		= index % 12;
	row		= index / 12;
	
	while(!foundWall){
		col			= col + dx;
		row			= row + dy;
		index		= col + 12 * row;
		cell		= cells[ index ];
		light		= lights[ index ];
        foundWall	=	((cell >= kTileGreenMeonS) && (cell <= kTileGreenMeonE)) ||
                            ((cell == kTilePlain));
		// a t'on un mur
		if (foundWall)
			break;
        
        //
		// Neon managment
		//
		foundMeon		= ((cell >= kTileWhiteMeon) && (cell <= kTileBlueMeon));
		if (foundMeon){
			uint32 type_t = cell - kTileWhiteMeon;
			*meonReached += (1 == (color-type_t));
            lights[ index ] = color + (sourceType << 3);
            break;
		}
        
       
        //
		// T managment
		//
		if ((cell >= kTileSplitterS) && (cell <= kTileSplitterE)){
			
			uint32 sourceTypeT = (cell - kTileSplitterS);
			
			if (2 == abs((int)sourceType - (int)sourceTypeT)){
				
				lights[ index ] = color;
				
				if ((0 != sourceTypeT) && (0 != sourceType))
                    computeLightWay(cells, index, kTileGreenMeonS, color, lights, meonReached);
				if ((1 != sourceTypeT) && (1 != sourceType))
					computeLightWay(cells, index, kTileGreenMeonW, color, lights, meonReached);
				if ((2 != sourceTypeT) && (2 != sourceType))
					computeLightWay(cells, index, kTileGreenMeonN, color, lights, meonReached);
				if ((3 != sourceTypeT) && (3 != sourceType))
					computeLightWay(cells, index, kTileGreenMeonE, color, lights, meonReached);
			}
			break;
		}
        
        //
		// prism management
		//
		if ((cell >= kTilePrismS) && (cell <= kTilePrismE)){
			
			uint32 sourceTypeP = cell - kTilePrismS;
            
			if (( 2 == abs((int)sourceTypeP-(int)sourceType)) && (1 == color)){
				lights[ index ] = 1;
				
                computeLightWay(cells, index, kTileGreenMeonS+ ((1+sourceTypeP) % 4), 4, lights, meonReached);
                computeLightWay(cells, index, kTileGreenMeonS+ ((2+sourceTypeP) % 4), 2, lights, meonReached);
                computeLightWay(cells, index, kTileGreenMeonS+ ((3+sourceTypeP) % 4), 3, lights, meonReached);

			}
			break;
		}
        
        //
		// brick color managment
		//
		if ((cell >= kTileBrickRed) && (cell <= kTileBrickBlue)){
            uint8 brickColor = (cell - kTileBrickRed + 2);
			if ((1 == color) || (color == brickColor))
				color = brickColor;
			else
				break;
		}
        
        //
		// mirror managment
		//
		foundMirror1 = (cell == kTileMirror1);
		foundMirror2 = (cell == kTileMirror2);
		if (foundMirror1){
			tmp	= dx;
			dx	= dy;
			dy	= tmp;
			isLightHorizontal = sourceType < 2;
			sourceType = 3 - sourceType;
		}
		else if (foundMirror2){
			tmp		= dx;
			dx		= -dy;
			dy		= -tmp;
			isLightHorizontal = (1==sourceType) || (2==sourceType);
			if (sourceType % 2)
				sourceType--;
			else
				sourceType++;
		}
		else {
			isLightHorizontal = (sourceType % 2) != 0;
		}
        
        
        if (isLightHorizontal)
			old_color = light % 5;
		else
			old_color = light / 5;
		
		if (color > old_color){
			if (isLightHorizontal)
				lights[ index ] += (color-old_color);
			else
				lights[ index ] += 5*(color-old_color);
		}
    }
}



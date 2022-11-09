/*
 *  algorithm.h
 *  Meon
 *
 *  Created by Jean-Christophe Amiel on 1/17/10.
 *  Copyright 2010 Manbolo. All rights reserved.
 *
 */

#include "CMType.h"

/**
 * Compute way of the light
 * @param[in] cell array of cell level
 * @param[in] index index of the source cell
 * @param[in] lights array of light state for each cells level
 * @param[in] sourceType type of the source one of kTileGreenMeonS kTileGreenMeonW kTileGreenMeonN kTileGreenMeonE
 * @param[in] color color of the light 1=white, 2=red, 3=yellow, 4=blue
 * @param[in/out] number of meon reached
 */
void computeLightWay(uint32* cells, uint32 index, uint8 sourceType, uint8 color, uint8* lights, uint8 *meonReached);

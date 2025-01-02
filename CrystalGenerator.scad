/*
 * Copyright 2021 Code and Make (codeandmake.com)
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/*
 * Crystal Generator by Code and Make (https://codeandmake.com/)
 *
 * https://codeandmake.com/post/crystal-generator
 *
 * Crystal Generator v1.2 (14 June 2021)
 */
 
 /*
 * Modified by TAKTAK to act as a library
 */

module crystalGenerator(
    Randomness = 0,
    Seed = 0,
    Number_of_Shards = 3,
    Shard_Sides = 6,
    Shard_Length = 100,
    Shard_Diameter = 25,
    Shard_Tilt = 20,
    Shard_Offset = 10,
    Shard_Length_Variance_Percentage = 50,
    Shard_Diameter_Variance_Percentage = 20,
    Shard_Tilt_Variance_Percentage = 20,
    Shard_Offset_Variance_Percentage = 20,
    Shard_Spacing_Variance_Percentage = 50,
    Hollow_Shards = 0,
    Hollow_Base = 1,
    Hollow_Shard_Wall_Thickness = 2,
    Base_Type = 2,
    Base_Thickness = 3
) {
    shardLengthMin = Shard_Length - (Shard_Length * Shard_Length_Variance_Percentage / 100 / 2);
    shardLengthMax = Shard_Length + (Shard_Length * Shard_Length_Variance_Percentage / 100 / 2);

    shardDiameterMin = Shard_Diameter - (Shard_Diameter * Shard_Diameter_Variance_Percentage / 100 / 2);
    shardDiameterMax = Shard_Diameter + (Shard_Diameter * Shard_Diameter_Variance_Percentage / 100 / 2);

    shardTiltMin = Shard_Tilt - (Shard_Tilt * Shard_Tilt_Variance_Percentage / 100 / 2);
    // clamp to max of 45 degrees for unsupported printing
    shardTiltMax = min(Shard_Tilt + (Shard_Tilt * Shard_Tilt_Variance_Percentage / 100 / 2), 45);

    shardOffsetMin = Shard_Offset - (Shard_Offset * Shard_Offset_Variance_Percentage / 100 / 2);
    shardOffsetMax = Shard_Offset + (Shard_Offset * Shard_Offset_Variance_Percentage / 100 / 2);

    shardSpacing = 360 / Number_of_Shards;
    shardSpacingAdjustMin = - (shardSpacing * Shard_Spacing_Variance_Percentage / 100 / 2);
    shardSpacingAdjustMax = + (shardSpacing * Shard_Spacing_Variance_Percentage / 100 / 2);

    // base radius without bevel
    baseRadius = shardOffsetMax + (shardDiameterMax * 0.75);

    seeds = (Randomness ? rands(0, 2147483646, Number_of_Shards + 5, Seed) : rands(0, 2147483646, Number_of_Shards + 5));

    shardTilts = rands(shardTiltMin, shardTiltMax, Number_of_Shards, seeds[0]);
    shardOffsets = rands(shardOffsetMin, shardOffsetMax, Number_of_Shards, seeds[1]);
    shardZRotations = rands(0, 360, Number_of_Shards, seeds[2]);
    shardSpacingAdjusts = rands(shardSpacingAdjustMin, shardSpacingAdjustMax, Number_of_Shards, seeds[3]);
    
    // cache random values
    shardDiameters = rands(shardDiameterMin, shardDiameterMax, Number_of_Shards, seeds[4]);
    
    // clamp to diameter so that we always have a crystal shape
    shardLengths =  [ for (i = [0:Number_of_Shards - 1]) max(rands(shardLengthMin, shardLengthMax, 1, seeds[5 + i])[0], shardDiameters[i]) ];

    module shard(i, inside) {
        shardRadius = (shardDiameters[i] / 2);
        shardLength = shardLengths[i];
        shardTilt = shardTilts[i];
        shardOffset = shardOffsets[i];
        shardZrotation = shardZRotations[i];
        insideAdjust = (inside ? Hollow_Shard_Wall_Thickness : 0);

        translate([0, -shardOffset, 0]) {
            intersection() {
                if (!inside) {
                    cylinder(r = (shardLength + shardRadius) * cos(shardTilt), h = (shardLength + shardRadius) * cos(shardTilt));
                }
                rotate([shardTilt, 0, 0]) {
                    rotate([0, 0, shardZrotation]) {
                        cylinder(r = shardRadius - insideAdjust, h = (shardLength - shardRadius) * 2, center = true, $fn = Shard_Sides);
                        translate([0, 0, shardLength - shardRadius]) {
                            cylinder(r1 = shardRadius - insideAdjust, r2 = 0, h = shardRadius - insideAdjust, $fn = Shard_Sides);
                        }
                    }
                }
            }
        }
    }

    module hollowShards() {
        for (i=[0:Number_of_Shards - 1]) {
            rotate([0, 0, (shardSpacing * i) + shardSpacingAdjusts[i]]) {
                shard(i, true);
            }
        }
    }

    module hollowBaseCutout() {
        translate([0, 0, -0.5]) {
            linear_extrude(height = Base_Thickness + 1, convexity = 10) {
                projection(cut = true) {
                    hollowShards();
                };
            }
        }
    }

    module base() {
        if (Base_Type == 1) {
            cylinder(r = baseRadius, h = Base_Thickness, $fn = 100);
        }
        if (Base_Type == 2) {
            hull() {
                rotate_extrude(convexity=10, $fn = 100) {
                    translate([baseRadius, 0, 0]) {
                        intersection() {
                            circle(r=Base_Thickness);
                            square(size=[Base_Thickness, Base_Thickness]);
                        }
                    }
                }
            }
        }
    }

    for (i=[0:Number_of_Shards - 1]) {
        difference() {
            rotate([0, 0, (shardSpacing * i) + shardSpacingAdjusts[i]]) {
                shard(i);
            }

            if (Hollow_Shards) {
                hollowShards();
            }
        }
    }

    if (Base_Type != 0) {
        translate([0, 0, -Base_Thickness]) {
            difference() {
                base();
                if (Hollow_Shards && Hollow_Base) {
                    hollowBaseCutout();
                }
            }
        }
    }
}

crystalGenerator(
    Randomness = 1,
    Seed = 156,
    Number_of_Shards = 5,
    Shard_Sides = 5,
    Shard_Length = 120,
    Shard_Tilt = 5,
    Shard_Offset = 5,
    Shard_Length_Variance_Percentage = 80,
    Shard_Diameter_Variance_Percentage = 70,
    Shard_Tilt_Variance_Percentage = 20,
    Hollow_Shards = 1,
    Base_Type = 0
);
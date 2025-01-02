# ReadMe

OpenSCAD library for generating paramaterised crystals

Available params are ->

- Randomness
  - Randomness = 0; // [0:Non-deterministic - Not using Seed, 1:Deterministic - Using Seed]
  - Seed = 0; // [0:1:2147483646]
- Shards
  - Number_of_Shards = 3; // [1:1:20]
  - Shard_Sides = 6; // [3:1:8]
  - Shard_Length = 100; // [50:1:200]
  - Shard_Diameter = 25; // [5:1:50]
  - Shard_Tilt = 20; // [5:1:45]
  - Shard_Offset = 10; // [5:1:100]
- Variation
  - Shard_Length_Variance_Percentage = 50; // [0:1:100]
  - Shard_Diameter_Variance_Percentage = 20; // [0:1:100]
  - Shard_Tilt_Variance_Percentage = 20; // [0:1:100]
  - Shard_Offset_Variance_Percentage = 20; // [0:1:100]
  - Shard_Spacing_Variance_Percentage = 50; // [0:1:100]
- Hollow
  - Hollow_Shards = 0; // [0:No, 1:Yes]
  - Hollow_Base = 1; // [0:No, 1:Yes]
  - Hollow_Shard_Wall_Thickness = 2; // [1:0.5:5]
-Base
  - Base_Type = 2; // [0:None, 1:Cylinder, 2:Bevelled]
  - Base_Thickness = 3; // [2:1:10]

## Attribution

This is a converted version of [Crystal Generator v1.2](https://codeandmake.com/post/crystal-generator) into a library for inclusion in other scripts.


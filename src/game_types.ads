--------------------------------------------------------------------------------
--  Game_Types: Core type definitions for Ada Adventure Game
--  SPDX-License-Identifier: GPL-2.0-only
--------------------------------------------------------------------------------
with Interfaces.C;
with SDL;
with SDL.Video.Palettes;

package Game_Types is
   pragma Preelaborate;

   package C renames Interfaces.C;

   --  Screen and tile layout
   Screen_Width   : constant := 800;
   Screen_Height  : constant := 600;
   Tile_Size      : constant := 40;
   
   Grid_Cols      : constant := 20; -- 20 * 40 = 800
   Grid_Rows      : constant := 13; -- 13 * 40 = 520 (leaving 40px top HUD, 40px bottom bar)
   
   HUD_Height     : constant := 40;
   View_Offset_Y  : constant := HUD_Height;
   Bottom_Bar_Y   : constant := View_Offset_Y + (Grid_Rows * Tile_Size); -- 560

   type Direction is (Dir_Up, Dir_Down, Dir_Left, Dir_Right);

   type Game_Mode is
     (Mode_Title,
      Mode_Playing,
      Mode_Dialogue,
      Mode_Game_Over,
      Mode_Victory);

   type Tile_Kind is
     (Tile_Grass,
      Tile_Path,
      Tile_Water,
      Tile_Tree,
      Tile_Stone_Wall,
      Tile_Wood_Wall,
      Tile_Dungeon_Floor,
      Tile_Door_Locked,
      Tile_Door_Open,
      Tile_Spikes_Down,
      Tile_Spikes_Up,
      Tile_Citadel_Floor,
      Tile_Altar);

   type Room_ID is
     (Room_Forest,
      Room_Village,
      Room_Cavern,
      Room_Dungeon,
      Room_Citadel);

   type Crystal_ID is (Crystal_Forest, Crystal_Cavern, Crystal_Dungeon);
   type Crystal_Array is array (Crystal_ID) of Boolean;

   type Entity_Kind is
     (Entity_None,
      Entity_Player,
      Entity_NPC_Elder,
      Entity_NPC_Guard,
      Entity_Slime,
      Entity_Skeleton,
      Entity_Chest,
      Entity_Key_Item,
      Entity_Heart_Item,
      Entity_Crystal_Item);

   type Map_Grid is array (1 .. Grid_Cols, 1 .. Grid_Rows) of Tile_Kind;

   --  Colors
   Black       : constant SDL.Video.Palettes.Colour := (0, 0, 0, 255);
   White       : constant SDL.Video.Palettes.Colour := (255, 255, 255, 255);
   Red         : constant SDL.Video.Palettes.Colour := (220, 40, 40, 255);
   Dark_Red    : constant SDL.Video.Palettes.Colour := (130, 20, 20, 255);
   Green       : constant SDL.Video.Palettes.Colour := (40, 180, 50, 255);
   Dark_Green  : constant SDL.Video.Palettes.Colour := (25, 110, 30, 255);
   Light_Green : constant SDL.Video.Palettes.Colour := (90, 220, 80, 255);
   Blue        : constant SDL.Video.Palettes.Colour := (45, 120, 225, 255);
   Dark_Blue   : constant SDL.Video.Palettes.Colour := (20, 60, 140, 255);
   Sky_Blue    : constant SDL.Video.Palettes.Colour := (90, 180, 250, 255);
   Yellow      : constant SDL.Video.Palettes.Colour := (245, 215, 45, 255);
   Gold        : constant SDL.Video.Palettes.Colour := (255, 195, 0, 255);
   Orange      : constant SDL.Video.Palettes.Colour := (235, 130, 30, 255);
   Brown       : constant SDL.Video.Palettes.Colour := (139, 69, 19, 255);
   Light_Brown : constant SDL.Video.Palettes.Colour := (195, 135, 75, 255);
   Dark_Brown  : constant SDL.Video.Palettes.Colour := (90, 45, 15, 255);
   Gray        : constant SDL.Video.Palettes.Colour := (128, 128, 128, 255);
   Light_Gray  : constant SDL.Video.Palettes.Colour := (190, 190, 190, 255);
   Dark_Gray   : constant SDL.Video.Palettes.Colour := (60, 60, 65, 255);
   Night_Blue  : constant SDL.Video.Palettes.Colour := (18, 22, 45, 255);
   Purple      : constant SDL.Video.Palettes.Colour := (160, 60, 210, 255);

end Game_Types;

--------------------------------------------------------------------------------
--  Game_Sprites: Procedural 2D pixel-art graphics rendering for Ada Adventure
--  SPDX-License-Identifier: GPL-2.0-only
--------------------------------------------------------------------------------
with Interfaces.C;
with SDL;
with SDL.Video.Palettes;
with SDL.Video.Renderers;
with Game_Types; use Game_Types;

package Game_Sprites is

   --  Draw a map tile at grid position (Col, Row)
   procedure Draw_Tile
     (Renderer : in out SDL.Video.Renderers.Renderer;
      Tile     : in Tile_Kind;
      Col      : in Positive;
      Row      : in Positive;
      Tick     : in Natural);

   --  Draw the Player Knight
   procedure Draw_Player
     (Renderer   : in out SDL.Video.Renderers.Renderer;
      X, Y       : in Interfaces.C.int;
      Dir        : in Direction;
      Anim_Frame : in Natural;
      Is_Attacking: in Boolean;
      Is_Invulnerable: in Boolean);

   --  Draw enemies
   procedure Draw_Slime
     (Renderer : in out SDL.Video.Renderers.Renderer;
      X, Y     : in Interfaces.C.int;
      Tick     : in Natural;
      Is_Hit   : in Boolean);

   procedure Draw_Skeleton
     (Renderer : in out SDL.Video.Renderers.Renderer;
      X, Y     : in Interfaces.C.int;
      Dir      : in Direction;
      Is_Hit   : in Boolean);

   --  Draw NPCs
   procedure Draw_NPC
     (Renderer : in out SDL.Video.Renderers.Renderer;
      Kind     : in Entity_Kind;
      X, Y     : in Interfaces.C.int;
      Tick     : in Natural);

   --  Draw Chest (Open or Closed)
   procedure Draw_Chest
     (Renderer : in out SDL.Video.Renderers.Renderer;
      X, Y     : in Interfaces.C.int;
      Is_Open  : in Boolean);

   --  Draw Collectible Items
   procedure Draw_Item
     (Renderer : in out SDL.Video.Renderers.Renderer;
      Kind     : in Entity_Kind;
      X, Y     : in Interfaces.C.int;
      Tick     : in Natural);

   --  HUD / UI Helpers
   procedure Draw_Heart
     (Renderer : in out SDL.Video.Renderers.Renderer;
      X, Y     : in Interfaces.C.int;
      Filled   : in Boolean);

   procedure Draw_Key_Icon
     (Renderer : in out SDL.Video.Renderers.Renderer;
      X, Y     : in Interfaces.C.int);

   procedure Draw_Gem_Icon
     (Renderer : in out SDL.Video.Renderers.Renderer;
      X, Y     : in Interfaces.C.int;
      ID       : in Crystal_ID;
      Collected: in Boolean);

   procedure Draw_Frame_Box
     (Renderer : in out SDL.Video.Renderers.Renderer;
      X, Y, W, H : in Interfaces.C.int;
      Border_Col : in SDL.Video.Palettes.Colour := Gold;
      Bg_Col     : in SDL.Video.Palettes.Colour := Night_Blue);

end Game_Sprites;

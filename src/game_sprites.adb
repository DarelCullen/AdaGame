--------------------------------------------------------------------------------
--  Game_Sprites: Implementation of pixel-art graphics rendering
--  SPDX-License-Identifier: GPL-2.0-only
--------------------------------------------------------------------------------
with SDL.Video.Rectangles;
with SDL.Video.Palettes; use SDL.Video.Palettes;

package body Game_Sprites is

   use Interfaces.C;
   use type Interfaces.C.int;

   procedure Fill_Rect
     (Renderer : in out SDL.Video.Renderers.Renderer;
      X, Y     : in Interfaces.C.int;
      W, H     : in Interfaces.C.int;
      Col      : in SDL.Video.Palettes.Colour)
   is
      R : constant SDL.Video.Rectangles.Rectangle :=
        (X      => SDL.Coordinate (X),
         Y      => SDL.Coordinate (Y),
         Width  => SDL.Natural_Dimension (W),
         Height => SDL.Natural_Dimension (H));
   begin
      Renderer.Set_Draw_Colour (Col);
      Renderer.Fill (R);
   end Fill_Rect;

   procedure Draw_Rect
     (Renderer : in out SDL.Video.Renderers.Renderer;
      X, Y     : in Interfaces.C.int;
      W, H     : in Interfaces.C.int;
      Col      : in SDL.Video.Palettes.Colour)
   is
      R : constant SDL.Video.Rectangles.Rectangle :=
        (X      => SDL.Coordinate (X),
         Y      => SDL.Coordinate (Y),
         Width  => SDL.Natural_Dimension (W),
         Height => SDL.Natural_Dimension (H));
   begin
      Renderer.Set_Draw_Colour (Col);
      Renderer.Draw (R);
   end Draw_Rect;

   -----------------------------------------------------------------------------
   --  Tiles
   -----------------------------------------------------------------------------
   procedure Draw_Tile
     (Renderer : in out SDL.Video.Renderers.Renderer;
      Tile     : in Tile_Kind;
      Col      : in Positive;
      Row      : in Positive;
      Tick     : in Natural)
   is
      X : constant Interfaces.C.int := Interfaces.C.int (Col - 1) * Tile_Size;
      Y : constant Interfaces.C.int := View_Offset_Y + Interfaces.C.int (Row - 1) * Tile_Size;
   begin
      case Tile is
         when Tile_Grass =>
            Fill_Rect (Renderer, X, Y, Tile_Size, Tile_Size, Dark_Green);
            --  Texture blades
            Fill_Rect (Renderer, X + 8, Y + 6, 2, 6, Light_Green);
            Fill_Rect (Renderer, X + 10, Y + 4, 2, 4, Light_Green);
            Fill_Rect (Renderer, X + 26, Y + 22, 2, 6, Light_Green);
            Fill_Rect (Renderer, X + 28, Y + 20, 2, 4, Light_Green);
            --  Wildflower
            if (Col * 7 + Row * 13) mod 5 = 0 then
               Fill_Rect (Renderer, X + 18, Y + 14, 4, 4, Yellow);
               Fill_Rect (Renderer, X + 19, Y + 15, 2, 2, White);
            elsif (Col * 3 + Row * 11) mod 7 = 0 then
               Fill_Rect (Renderer, X + 14, Y + 28, 4, 4, Sky_Blue);
            end if;

         when Tile_Path =>
            Fill_Rect (Renderer, X, Y, Tile_Size, Tile_Size, Light_Brown);
            --  Cobblestones / gravel speckles
            Fill_Rect (Renderer, X + 4, Y + 4, 8, 6, Brown);
            Fill_Rect (Renderer, X + 18, Y + 8, 12, 8, Dark_Brown);
            Fill_Rect (Renderer, X + 8, Y + 22, 10, 6, Brown);
            Fill_Rect (Renderer, X + 24, Y + 24, 10, 10, Dark_Brown);
            Draw_Rect (Renderer, X, Y, Tile_Size, Tile_Size, Brown);

         when Tile_Water =>
            declare
               Wave : constant Interfaces.C.int := Interfaces.C.int ((Tick / 15 + Col) mod 4);
            begin
               Fill_Rect (Renderer, X, Y, Tile_Size, Tile_Size, Blue);
               --  Shimmer ripples
               Fill_Rect (Renderer, X + 4 + Wave * 2, Y + 8, 12, 3, Sky_Blue);
               Fill_Rect (Renderer, X + 16 - Wave * 2, Y + 22, 14, 3, Sky_Blue);
               Fill_Rect (Renderer, X + 2, Y + 32, 8, 2, White);
            end;

         when Tile_Tree =>
            --  Grass under tree
            Fill_Rect (Renderer, X, Y, Tile_Size, Tile_Size, Dark_Green);
            --  Trunk
            Fill_Rect (Renderer, X + 14, Y + 20, 12, 18, Dark_Brown);
            --  Leaves canopy
            Fill_Rect (Renderer, X + 4, Y + 4, 32, 22, Green);
            Fill_Rect (Renderer, X + 8, Y + 2, 24, 4, Light_Green);
            Fill_Rect (Renderer, X + 8, Y + 6, 8, 6, Light_Green);
            Fill_Rect (Renderer, X + 22, Y + 10, 8, 6, Dark_Green);

         when Tile_Stone_Wall =>
            Fill_Rect (Renderer, X, Y, Tile_Size, Tile_Size, Dark_Gray);
            --  Mortar lines
            Fill_Rect (Renderer, X, Y + 12, Tile_Size, 2, Gray);
            Fill_Rect (Renderer, X, Y + 26, Tile_Size, 2, Gray);
            Fill_Rect (Renderer, X + 18, Y, 2, 12, Gray);
            Fill_Rect (Renderer, X + 8, Y + 12, 2, 14, Gray);
            Fill_Rect (Renderer, X + 28, Y + 12, 2, 14, Gray);
            Fill_Rect (Renderer, X + 20, Y + 26, 2, 14, Gray);
            --  Stone highlights
            Fill_Rect (Renderer, X + 2, Y + 2, 6, 4, Light_Gray);

         when Tile_Wood_Wall =>
            Fill_Rect (Renderer, X, Y, Tile_Size, Tile_Size, Brown);
            Fill_Rect (Renderer, X + 2, Y + 2, Tile_Size - 4, Tile_Size - 4, Light_Brown);
            --  Vertical beam lines
            Fill_Rect (Renderer, X + 10, Y, 2, Tile_Size, Dark_Brown);
            Fill_Rect (Renderer, X + 20, Y, 2, Tile_Size, Dark_Brown);
            Fill_Rect (Renderer, X + 30, Y, 2, Tile_Size, Dark_Brown);
            Draw_Rect (Renderer, X, Y, Tile_Size, Tile_Size, Dark_Brown);

         when Tile_Dungeon_Floor =>
            Fill_Rect (Renderer, X, Y, Tile_Size, Tile_Size, Dark_Gray);
            Draw_Rect (Renderer, X, Y, Tile_Size, Tile_Size, Gray);
            Fill_Rect (Renderer, X + 10, Y + 15, 6, 2, Gray);

         when Tile_Door_Locked =>
            Fill_Rect (Renderer, X, Y, Tile_Size, Tile_Size, Dark_Brown);
            Draw_Rect (Renderer, X, Y, Tile_Size, Tile_Size, Gold);
            --  Iron bars & Keyhole
            Fill_Rect (Renderer, X + 6, Y + 6, 28, 28, Gray);
            Fill_Rect (Renderer, X + 18, Y + 14, 4, 8, Yellow);
            Fill_Rect (Renderer, X + 17, Y + 22, 6, 4, Yellow);

         when Tile_Door_Open =>
            Fill_Rect (Renderer, X, Y, Tile_Size, Tile_Size, Dark_Gray);
            --  Open doorway opening
            Fill_Rect (Renderer, X + 4, Y + 2, Tile_Size - 8, Tile_Size - 2, Black);
            --  Door frame
            Draw_Rect (Renderer, X + 4, Y + 2, Tile_Size - 8, Tile_Size - 2, Gold);

         when Tile_Spikes_Down =>
            Fill_Rect (Renderer, X, Y, Tile_Size, Tile_Size, Dark_Gray);
            --  Holes in stone
            Fill_Rect (Renderer, X + 8, Y + 8, 4, 4, Black);
            Fill_Rect (Renderer, X + 28, Y + 8, 4, 4, Black);
            Fill_Rect (Renderer, X + 18, Y + 18, 4, 4, Black);
            Fill_Rect (Renderer, X + 8, Y + 28, 4, 4, Black);
            Fill_Rect (Renderer, X + 28, Y + 28, 4, 4, Black);

         when Tile_Spikes_Up =>
            Fill_Rect (Renderer, X, Y, Tile_Size, Tile_Size, Dark_Gray);
            --  Sharp metal points
            Fill_Rect (Renderer, X + 8, Y + 6, 4, 10, Light_Gray);
            Fill_Rect (Renderer, X + 9, Y + 4, 2, 4, White);
            Fill_Rect (Renderer, X + 8, Y + 22, 4, 10, Light_Gray);
            Fill_Rect (Renderer, X + 9, Y + 20, 2, 4, White);

            Fill_Rect (Renderer, X + 18, Y + 6, 4, 10, Light_Gray);
            Fill_Rect (Renderer, X + 19, Y + 4, 2, 4, White);
            Fill_Rect (Renderer, X + 18, Y + 22, 4, 10, Light_Gray);
            Fill_Rect (Renderer, X + 19, Y + 20, 2, 4, White);

            Fill_Rect (Renderer, X + 28, Y + 6, 4, 10, Light_Gray);
            Fill_Rect (Renderer, X + 29, Y + 4, 2, 4, White);
            Fill_Rect (Renderer, X + 28, Y + 22, 4, 10, Light_Gray);
            Fill_Rect (Renderer, X + 29, Y + 20, 2, 4, White);

         when Tile_Citadel_Floor =>
            Fill_Rect (Renderer, X, Y, Tile_Size, Tile_Size, Light_Gray);
            Draw_Rect (Renderer, X, Y, Tile_Size, Tile_Size, White);
            --  Royal blue/gold diamond inlay
            Fill_Rect (Renderer, X + 16, Y + 16, 8, 8, Blue);
            Fill_Rect (Renderer, X + 18, Y + 18, 4, 4, Gold);

         when Tile_Altar =>
            Fill_Rect (Renderer, X, Y, Tile_Size, Tile_Size, Dark_Gray);
            --  Golden altar pedestal
            Fill_Rect (Renderer, X + 4, Y + 6, 32, 28, Gold);
            Fill_Rect (Renderer, X + 8, Y + 10, 24, 20, Purple);
            --  Gleaming mystic light
            Fill_Rect (Renderer, X + 18, Y + 16, 4, 8, White);
            Fill_Rect (Renderer, X + 16, Y + 18, 8, 4, White);
      end case;
   end Draw_Tile;

   -----------------------------------------------------------------------------
   --  Player Knight
   -----------------------------------------------------------------------------
   procedure Draw_Player
     (Renderer   : in out SDL.Video.Renderers.Renderer;
      X, Y       : in Interfaces.C.int;
      Dir        : in Direction;
      Anim_Frame : in Natural;
      Is_Attacking: in Boolean;
      Is_Invulnerable: in Boolean)
   is
      Leg_Offset : Interfaces.C.int := 0;
   begin
      --  Invulnerability blink (skip rendering alternate frames)
      if Is_Invulnerable and then (Anim_Frame mod 4 >= 2) then
         return;
      end if;

      if Anim_Frame mod 2 = 1 then
         Leg_Offset := 2;
      end if;

      --  Shadow
      Fill_Rect (Renderer, X + 6, Y + 32, 24, 6, Black);

      --  Legs / Boots
      Fill_Rect (Renderer, X + 8 + Leg_Offset, Y + 26, 6, 8, Dark_Gray);
      Fill_Rect (Renderer, X + 20 - Leg_Offset, Y + 26, 6, 8, Dark_Gray);

      --  Tunic / Armor Body
      Fill_Rect (Renderer, X + 8, Y + 14, 18, 14, Blue);
      Fill_Rect (Renderer, X + 11, Y + 16, 12, 10, Light_Gray); -- Chestplate
      Fill_Rect (Renderer, X + 15, Y + 18, 4, 6, Gold);        -- Emblem

      --  Belt
      Fill_Rect (Renderer, X + 8, Y + 23, 18, 3, Dark_Brown);
      Fill_Rect (Renderer, X + 15, Y + 23, 4, 3, Gold);

      --  Head / Helmet
      Fill_Rect (Renderer, X + 10, Y + 2, 14, 13, Gray);
      Fill_Rect (Renderer, X + 12, Y, 10, 4, Dark_Red); -- Red plume on top!

      --  Visor depending on direction
      case Dir is
         when Dir_Down =>
            Fill_Rect (Renderer, X + 12, Y + 7, 10, 3, Dark_Gray);
            Fill_Rect (Renderer, X + 14, Y + 8, 2, 2, Sky_Blue); -- Eyes
            Fill_Rect (Renderer, X + 18, Y + 8, 2, 2, Sky_Blue);
            --  Shield on left side
            Fill_Rect (Renderer, X + 2, Y + 14, 6, 12, Red);
            Draw_Rect (Renderer, X + 2, Y + 14, 6, 12, Gold);

         when Dir_Up =>
            Fill_Rect (Renderer, X + 11, Y + 4, 12, 6, Dark_Gray);
            --  Cape visible on back
            Fill_Rect (Renderer, X + 10, Y + 14, 14, 14, Red);

         when Dir_Left =>
            Fill_Rect (Renderer, X + 8, Y + 7, 6, 3, Dark_Gray);
            Fill_Rect (Renderer, X + 9, Y + 8, 2, 2, Sky_Blue);
            --  Shield forward
            Fill_Rect (Renderer, X + 2, Y + 14, 6, 12, Red);
            Draw_Rect (Renderer, X + 2, Y + 14, 6, 12, Gold);

         when Dir_Right =>
            Fill_Rect (Renderer, X + 20, Y + 7, 6, 3, Dark_Gray);
            Fill_Rect (Renderer, X + 23, Y + 8, 2, 2, Sky_Blue);
            --  Shield forward
            Fill_Rect (Renderer, X + 26, Y + 14, 6, 12, Red);
            Draw_Rect (Renderer, X + 26, Y + 14, 6, 12, Gold);
      end case;

      --  Sword / Attack Arc
      if Is_Attacking then
         case Dir is
            when Dir_Right =>
               Fill_Rect (Renderer, X + 26, Y + 12, 16, 4, White);
               Fill_Rect (Renderer, X + 26, Y + 8, 12, 4, Sky_Blue);
               Fill_Rect (Renderer, X + 24, Y + 10, 3, 8, Gold); -- Guard
            when Dir_Left =>
               Fill_Rect (Renderer, X - 8, Y + 12, 16, 4, White);
               Fill_Rect (Renderer, X - 4, Y + 8, 12, 4, Sky_Blue);
               Fill_Rect (Renderer, X + 7, Y + 10, 3, 8, Gold);
            when Dir_Up =>
               Fill_Rect (Renderer, X + 16, Y - 10, 4, 16, White);
               Fill_Rect (Renderer, X + 12, Y - 6, 4, 12, Sky_Blue);
               Fill_Rect (Renderer, X + 12, Y + 5, 12, 3, Gold);
            when Dir_Down =>
               Fill_Rect (Renderer, X + 14, Y + 28, 4, 16, White);
               Fill_Rect (Renderer, X + 18, Y + 24, 4, 12, Sky_Blue);
               Fill_Rect (Renderer, X + 10, Y + 26, 12, 3, Gold);
         end case;
      else
         --  Sheathed sword
         case Dir is
            when Dir_Down | Dir_Right =>
               Fill_Rect (Renderer, X + 24, Y + 12, 3, 12, Light_Gray);
               Fill_Rect (Renderer, X + 23, Y + 10, 5, 3, Gold);
            when others =>
               null;
         end case;
      end if;
   end Draw_Player;

   -----------------------------------------------------------------------------
   --  Enemies
   -----------------------------------------------------------------------------
   procedure Draw_Slime
     (Renderer : in out SDL.Video.Renderers.Renderer;
      X, Y     : in Interfaces.C.int;
      Tick     : in Natural;
      Is_Hit   : in Boolean)
   is
      Bounce : constant Interfaces.C.int := Interfaces.C.int ((Tick / 8) mod 2);
      Body_Col : constant SDL.Video.Palettes.Colour := (if Is_Hit then White else Green);
      Shine_Col: constant SDL.Video.Palettes.Colour := (if Is_Hit then Red else Light_Green);
   begin
      --  Shadow
      Fill_Rect (Renderer, X + 4, Y + 28, 26, 6, Black);
      --  Slime body
      Fill_Rect (Renderer, X + 6, Y + 14 - Bounce * 2, 22, 16 + Bounce * 2, Body_Col);
      Fill_Rect (Renderer, X + 10, Y + 8 - Bounce * 2, 14, 6, Body_Col);
      --  Highlights
      Fill_Rect (Renderer, X + 8, Y + 12 - Bounce * 2, 6, 4, Shine_Col);
      --  Eyes
      Fill_Rect (Renderer, X + 11, Y + 15 - Bounce * 2, 4, 5, White);
      Fill_Rect (Renderer, X + 19, Y + 15 - Bounce * 2, 4, 5, White);
      Fill_Rect (Renderer, X + 13, Y + 17 - Bounce * 2, 2, 3, Black);
      Fill_Rect (Renderer, X + 21, Y + 17 - Bounce * 2, 2, 3, Black);
   end Draw_Slime;

   procedure Draw_Skeleton
     (Renderer : in out SDL.Video.Renderers.Renderer;
      X, Y     : in Interfaces.C.int;
      Dir      : in Direction;
      Is_Hit   : in Boolean)
   is
      Bone_Col : constant SDL.Video.Palettes.Colour := (if Is_Hit then Red else White);
      Dark_Col : constant SDL.Video.Palettes.Colour := (if Is_Hit then White else Dark_Gray);
   begin
      --  Shadow
      Fill_Rect (Renderer, X + 6, Y + 32, 22, 5, Black);
      --  Bony legs
      Fill_Rect (Renderer, X + 10, Y + 24, 3, 9, Bone_Col);
      Fill_Rect (Renderer, X + 18, Y + 24, 3, 9, Bone_Col);
      --  Ribcage
      Fill_Rect (Renderer, X + 9, Y + 14, 14, 10, Dark_Col);
      Fill_Rect (Renderer, X + 10, Y + 15, 12, 2, Bone_Col);
      Fill_Rect (Renderer, X + 10, Y + 18, 12, 2, Bone_Col);
      Fill_Rect (Renderer, X + 10, Y + 21, 12, 2, Bone_Col);
      --  Skull
      Fill_Rect (Renderer, X + 10, Y + 3, 12, 10, Bone_Col);
      Fill_Rect (Renderer, X + 12, Y + 11, 8, 3, Bone_Col); -- Jaw
      --  Glowing eyes
      Fill_Rect (Renderer, X + 12, Y + 7, 2, 3, Red);
      Fill_Rect (Renderer, X + 17, Y + 7, 2, 3, Red);
      --  Rusty blade
      case Dir is
         when Dir_Left =>
            Fill_Rect (Renderer, X + 2, Y + 14, 3, 14, Gray);
            Fill_Rect (Renderer, X, Y + 18, 7, 2, Dark_Brown);
         when others =>
            Fill_Rect (Renderer, X + 24, Y + 14, 3, 14, Gray);
            Fill_Rect (Renderer, X + 22, Y + 18, 7, 2, Dark_Brown);
      end case;
   end Draw_Skeleton;

   -----------------------------------------------------------------------------
   --  NPCs
   -----------------------------------------------------------------------------
   procedure Draw_NPC
     (Renderer : in out SDL.Video.Renderers.Renderer;
      Kind     : in Entity_Kind;
      X, Y     : in Interfaces.C.int;
      Tick     : in Natural)
   is
      pragma Unreferenced (Tick);
   begin
      --  Shadow
      Fill_Rect (Renderer, X + 6, Y + 32, 24, 6, Black);

      if Kind = Entity_NPC_Elder then
         --  Blue wizard/elder robe
         Fill_Rect (Renderer, X + 8, Y + 14, 18, 18, Blue);
         --  Golden trim
         Fill_Rect (Renderer, X + 16, Y + 14, 2, 18, Gold);
         --  Face & Long White Beard
         Fill_Rect (Renderer, X + 12, Y + 4, 10, 8, Light_Brown);
         Fill_Rect (Renderer, X + 10, Y + 10, 14, 12, White); -- Beard
         --  Eyes
         Fill_Rect (Renderer, X + 14, Y + 7, 2, 2, Black);
         Fill_Rect (Renderer, X + 18, Y + 7, 2, 2, Black);
         --  Pointy or hooded hat
         Fill_Rect (Renderer, X + 8, Y + 2, 18, 4, Dark_Blue);
         Fill_Rect (Renderer, X + 12, Y - 2, 10, 4, Dark_Blue);
         --  Staff
         Fill_Rect (Renderer, X + 26, Y + 2, 3, 30, Brown);
         Fill_Rect (Renderer, X + 25, Y, 5, 5, Sky_Blue); -- staff orb
      else
         --  Guard in Steel Armor
         Fill_Rect (Renderer, X + 8, Y + 14, 18, 16, Gray);
         Fill_Rect (Renderer, X + 10, Y + 4, 14, 10, Light_Gray);
         Fill_Rect (Renderer, X + 12, Y, 10, 4, Red); -- Plume
         Fill_Rect (Renderer, X + 13, Y + 8, 8, 2, Black); -- Visor slit
         --  Spear
         Fill_Rect (Renderer, X + 26, Y - 4, 3, 36, Dark_Brown);
         Fill_Rect (Renderer, X + 25, Y - 8, 5, 6, White);
      end if;
   end Draw_NPC;

   -----------------------------------------------------------------------------
   --  Chest & Items
   -----------------------------------------------------------------------------
   procedure Draw_Chest
     (Renderer : in out SDL.Video.Renderers.Renderer;
      X, Y     : in Interfaces.C.int;
      Is_Open  : in Boolean)
   is
   begin
      --  Shadow
      Fill_Rect (Renderer, X + 4, Y + 30, 26, 6, Black);

      if not Is_Open then
         --  Closed Chest
         Fill_Rect (Renderer, X + 5, Y + 12, 24, 18, Brown);
         Draw_Rect (Renderer, X + 5, Y + 12, 24, 18, Dark_Brown);
         --  Iron/Gold brackets
         Fill_Rect (Renderer, X + 5, Y + 12, 4, 18, Gold);
         Fill_Rect (Renderer, X + 25, Y + 12, 4, 18, Gold);
         Fill_Rect (Renderer, X + 5, Y + 18, 24, 3, Gold);
         --  Lock
         Fill_Rect (Renderer, X + 15, Y + 17, 4, 5, Yellow);
      else
         --  Open Chest
         Fill_Rect (Renderer, X + 5, Y + 16, 24, 14, Brown);
         Draw_Rect (Renderer, X + 5, Y + 16, 24, 14, Dark_Brown);
         --  Inner black void
         Fill_Rect (Renderer, X + 7, Y + 14, 20, 5, Black);
         --  Open lid tilting back
         Fill_Rect (Renderer, X + 5, Y + 6, 24, 7, Dark_Brown);
         Fill_Rect (Renderer, X + 6, Y + 7, 22, 5, Brown);
         --  Sparkles
         Fill_Rect (Renderer, X + 16, Y + 10, 3, 3, Yellow);
      end if;
   end Draw_Chest;

   procedure Draw_Item
     (Renderer : in out SDL.Video.Renderers.Renderer;
      Kind     : in Entity_Kind;
      X, Y     : in Interfaces.C.int;
      Tick     : in Natural)
   is
      Bob : constant Interfaces.C.int := Interfaces.C.int ((Tick / 10) mod 3);
   begin
      case Kind is
         when Entity_Key_Item =>
            --  Golden key
            Draw_Key_Icon (Renderer, X + 6, Y + 8 - Bob);

         when Entity_Heart_Item =>
            --  Floating heart
            Draw_Heart (Renderer, X + 6, Y + 8 - Bob, Filled => True);

         when Entity_Crystal_Item =>
            --  Mystic Crystal
            declare
               Gem_Col : constant SDL.Video.Palettes.Colour :=
                 (case (Tick / 30) mod 3 is
                     when 0 => Light_Green,
                     when 1 => Sky_Blue,
                     when others => Purple);
            begin
               Fill_Rect (Renderer, X + 14, Y + 6 - Bob, 8, 18, Gem_Col);
               Fill_Rect (Renderer, X + 10, Y + 10 - Bob, 16, 10, Gem_Col);
               Fill_Rect (Renderer, X + 16, Y + 8 - Bob, 4, 8, White); -- Shine
            end;

         when others =>
            null;
      end case;
   end Draw_Item;

   -----------------------------------------------------------------------------
   --  HUD Elements
   -----------------------------------------------------------------------------
   procedure Draw_Heart
     (Renderer : in out SDL.Video.Renderers.Renderer;
      X, Y     : in Interfaces.C.int;
      Filled   : in Boolean)
   is
      Col : constant SDL.Video.Palettes.Colour := (if Filled then Red else Dark_Gray);
   begin
      --  Heart shape
      Fill_Rect (Renderer, X + 2, Y, 6, 6, Col);
      Fill_Rect (Renderer, X + 10, Y, 6, 6, Col);
      Fill_Rect (Renderer, X, Y + 3, 18, 7, Col);
      Fill_Rect (Renderer, X + 2, Y + 10, 14, 4, Col);
      Fill_Rect (Renderer, X + 5, Y + 14, 8, 4, Col);
      Fill_Rect (Renderer, X + 7, Y + 18, 4, 2, Col);

      if Filled then
         --  White shine
         Fill_Rect (Renderer, X + 3, Y + 2, 3, 3, White);
      else
         --  Empty heart outline
         Draw_Rect (Renderer, X + 2, Y + 2, 14, 14, Gray);
      end if;
   end Draw_Heart;

   procedure Draw_Key_Icon
     (Renderer : in out SDL.Video.Renderers.Renderer;
      X, Y     : in Interfaces.C.int)
   is
   begin
      --  Ring
      Fill_Rect (Renderer, X, Y + 4, 10, 10, Gold);
      Fill_Rect (Renderer, X + 2, Y + 6, 6, 6, Black);
      --  Shaft
      Fill_Rect (Renderer, X + 9, Y + 7, 12, 4, Gold);
      --  Teeth
      Fill_Rect (Renderer, X + 16, Y + 11, 3, 4, Gold);
      Fill_Rect (Renderer, X + 19, Y + 11, 2, 3, Gold);
   end Draw_Key_Icon;

   procedure Draw_Gem_Icon
     (Renderer : in out SDL.Video.Renderers.Renderer;
      X, Y     : in Interfaces.C.int;
      ID       : in Crystal_ID;
      Collected: in Boolean)
   is
      Col : constant SDL.Video.Palettes.Colour :=
        (if not Collected then Dark_Gray
         else (case ID is
                  when Crystal_Forest  => Light_Green,
                  when Crystal_Cavern  => Sky_Blue,
                  when Crystal_Dungeon => Red));
   begin
      Fill_Rect (Renderer, X + 6, Y, 6, 16, Col);
      Fill_Rect (Renderer, X + 2, Y + 4, 14, 8, Col);
      if Collected then
         Fill_Rect (Renderer, X + 6, Y + 3, 3, 4, White);
      else
         Draw_Rect (Renderer, X + 2, Y + 2, 14, 12, Gray);
      end if;
   end Draw_Gem_Icon;

   procedure Draw_Frame_Box
     (Renderer : in out SDL.Video.Renderers.Renderer;
      X, Y, W, H : in Interfaces.C.int;
      Border_Col : in SDL.Video.Palettes.Colour := Gold;
      Bg_Col     : in SDL.Video.Palettes.Colour := Night_Blue)
   is
   begin
      --  Background
      Fill_Rect (Renderer, X, Y, W, H, Bg_Col);
      --  Outer border
      Draw_Rect (Renderer, X, Y, W, H, Border_Col);
      Draw_Rect (Renderer, X + 2, Y + 2, W - 4, H - 4, Border_Col);
      --  Corner accents
      Fill_Rect (Renderer, X, Y, 6, 6, Border_Col);
      Fill_Rect (Renderer, X + W - 6, Y, 6, 6, Border_Col);
      Fill_Rect (Renderer, X, Y + H - 6, 6, 6, Border_Col);
      Fill_Rect (Renderer, X + W - 6, Y + H - 6, 6, 6, Border_Col);
   end Draw_Frame_Box;

end Game_Sprites;

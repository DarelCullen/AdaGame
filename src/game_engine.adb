--------------------------------------------------------------------------------
--  Game_Engine: Implementation of game loop, input, state, and rendering
--  SPDX-License-Identifier: GPL-2.0-only
--------------------------------------------------------------------------------
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Real_Time; use Ada.Real_Time;
with SDL;
with SDL.Error;
with SDL.Events;
with SDL.Events.Events;
with SDL.Events.Keyboards;
with SDL.Video.Windows;
with SDL.Video.Windows.Makers;
with SDL.Video.Renderers;
with SDL.Video.Renderers.Makers;
with Game_Sprites; use Game_Sprites;
with Game_Font;    use Game_Font;

package body Game_Engine is

   use Interfaces.C;
   use type Interfaces.C.int;
   use type SDL.Init_Flags;
   use type SDL.Events.Event_Types;
   use type SDL.Events.Keyboards.Scan_Codes;

   -----------------------------------------------------------------------------
   --  Initialization
   -----------------------------------------------------------------------------
   procedure Init_Game (Engine : out Engine_State) is
   begin
      Engine.Mode               := Mode_Title;
      Engine.Player_X           := int (10 * Tile_Size);
      Engine.Player_Y           := int (View_Offset_Y + 10 * Tile_Size);
      Engine.Player_Dir         := Dir_Up;
      Engine.Player_HP          := 6;
      Engine.Player_Max_HP      := 6;
      Engine.Invulnerable_Timer := 0;
      Engine.Attack_Timer       := 0;
      Engine.Anim_Frame         := 0;
      Engine.Tick               := 0;
      Engine.Dialogue_Active    := False;
      Engine.Dialogue_Line1     := (others => ' ');
      Engine.Dialogue_Line2     := (others => ' ');
      Engine.Popup_Text         := (others => ' ');
      Engine.Popup_Timer        := 0;
      Engine.Should_Quit        := False;
      Engine.Key_Up_Pressed     := False;
      Engine.Key_Down_Pressed   := False;
      Engine.Key_Left_Pressed   := False;
      Engine.Key_Right_Pressed  := False;

      Init_World (Engine.World);
   end Init_Game;

   -----------------------------------------------------------------------------
   --  Input Handlers
   -----------------------------------------------------------------------------
   procedure Handle_Key_Down
     (Engine    : in out Engine_State;
      Scan_Code : in SDL.Events.Keyboards.Scan_Codes)
   is
   begin
      case Engine.Mode is
         when Mode_Title =>
            if Scan_Code = SDL.Events.Keyboards.Scan_Code_Return or else
               Scan_Code = SDL.Events.Keyboards.Scan_Code_Space
            then
               Engine.Mode := Mode_Playing;
               Engine.Popup_Text (1 .. 22) := "Quest Begins: Explore!";
               Engine.Popup_Timer := 120;
            elsif Scan_Code = SDL.Events.Keyboards.Scan_Code_Escape then
               Engine.Should_Quit := True;
            end if;

         when Mode_Playing =>
            --  Direction keys
            if Scan_Code = SDL.Events.Keyboards.Scan_Code_W or else
               Scan_Code = SDL.Events.Keyboards.Scan_Code_Up
            then
               Engine.Key_Up_Pressed := True;
               Engine.Player_Dir     := Dir_Up;
            elsif Scan_Code = SDL.Events.Keyboards.Scan_Code_S or else
                  Scan_Code = SDL.Events.Keyboards.Scan_Code_Down
            then
               Engine.Key_Down_Pressed := True;
               Engine.Player_Dir       := Dir_Down;
            elsif Scan_Code = SDL.Events.Keyboards.Scan_Code_A or else
                  Scan_Code = SDL.Events.Keyboards.Scan_Code_Left
            then
               Engine.Key_Left_Pressed := True;
               Engine.Player_Dir       := Dir_Left;
            elsif Scan_Code = SDL.Events.Keyboards.Scan_Code_D or else
                  Scan_Code = SDL.Events.Keyboards.Scan_Code_Right
            then
               Engine.Key_Right_Pressed := True;
               Engine.Player_Dir        := Dir_Right;

            --  Attack
            elsif Scan_Code = SDL.Events.Keyboards.Scan_Code_Space or else
                  Scan_Code = SDL.Events.Keyboards.Scan_Code_Z
            then
               if Engine.Attack_Timer = 0 then
                  Engine.Attack_Timer := 12;
                  declare
                     Hit : Boolean;
                  begin
                     Process_Player_Attack
                       (Engine.World,
                        Engine.Player_X, Engine.Player_Y,
                        Engine.Player_Dir,
                        Hit);
                     if Hit then
                        Engine.Popup_Text (1 .. 12) := "*SLASH!*    ";
                        Engine.Popup_Timer := 30;
                     end if;
                  end;
               end if;

            --  Interact / Talk / Open
            elsif Scan_Code = SDL.Events.Keyboards.Scan_Code_E or else
                  Scan_Code = SDL.Events.Keyboards.Scan_Code_Return
            then
               if Engine.Dialogue_Active then
                  Engine.Dialogue_Active := False;
               else
                  declare
                     Msg_Active : Boolean;
                     L1, L2     : String (1 .. 40) := (others => ' ');
                     Snd        : Natural;
                  begin
                     Try_Interact
                       (World            => Engine.World,
                        Player_X         => Engine.Player_X,
                        Player_Y         => Engine.Player_Y,
                        Player_Dir       => Engine.Player_Dir,
                        Player_HP        => Engine.Player_HP,
                        Player_Max_HP    => Engine.Player_Max_HP,
                        Message_Active   => Msg_Active,
                        Message_Line1    => L1,
                        Message_Line2    => L2,
                        Sound_Trigger    => Snd);

                     if Msg_Active then
                        Engine.Dialogue_Active := True;
                        Engine.Dialogue_Line1  := L1;
                        Engine.Dialogue_Line2  := L2;
                        if Snd = 3 then
                           --  Victory reached at Citadel Altar!
                           Engine.Mode := Mode_Victory;
                        end if;
                     end if;
                  end;
               end if;

            elsif Scan_Code = SDL.Events.Keyboards.Scan_Code_Escape then
               Engine.Mode := Mode_Title;
            end if;

         when Mode_Dialogue =>
            if Scan_Code = SDL.Events.Keyboards.Scan_Code_E or else
               Scan_Code = SDL.Events.Keyboards.Scan_Code_Return or else
               Scan_Code = SDL.Events.Keyboards.Scan_Code_Space
            then
               Engine.Dialogue_Active := False;
               Engine.Mode := Mode_Playing;
            end if;

         when Mode_Game_Over | Mode_Victory =>
            if Scan_Code = SDL.Events.Keyboards.Scan_Code_R then
               Init_Game (Engine);
               Engine.Mode := Mode_Playing;
            elsif Scan_Code = SDL.Events.Keyboards.Scan_Code_Escape then
               Engine.Should_Quit := True;
            end if;
      end case;
   end Handle_Key_Down;

   procedure Handle_Key_Up
     (Engine    : in out Engine_State;
      Scan_Code : in SDL.Events.Keyboards.Scan_Codes)
   is
   begin
      if Scan_Code = SDL.Events.Keyboards.Scan_Code_W or else
         Scan_Code = SDL.Events.Keyboards.Scan_Code_Up
      then
         Engine.Key_Up_Pressed := False;
      elsif Scan_Code = SDL.Events.Keyboards.Scan_Code_S or else
            Scan_Code = SDL.Events.Keyboards.Scan_Code_Down
      then
         Engine.Key_Down_Pressed := False;
      elsif Scan_Code = SDL.Events.Keyboards.Scan_Code_A or else
            Scan_Code = SDL.Events.Keyboards.Scan_Code_Left
      then
         Engine.Key_Left_Pressed := False;
      elsif Scan_Code = SDL.Events.Keyboards.Scan_Code_D or else
            Scan_Code = SDL.Events.Keyboards.Scan_Code_Right
      then
         Engine.Key_Right_Pressed := False;
      end if;
   end Handle_Key_Up;

   -----------------------------------------------------------------------------
   --  Game Update Tick
   -----------------------------------------------------------------------------
   procedure Update_Game (Engine : in out Engine_State) is
      Move_Speed : constant Interfaces.C.int := 3;
      Moving     : Boolean := False;
      Target_X   : Interfaces.C.int := Engine.Player_X;
      Target_Y   : Interfaces.C.int := Engine.Player_Y;
   begin
      Engine.Tick := Engine.Tick + 1;

      if Engine.Popup_Timer > 0 then
         Engine.Popup_Timer := Engine.Popup_Timer - 1;
      end if;

      if Engine.Attack_Timer > 0 then
         Engine.Attack_Timer := Engine.Attack_Timer - 1;
      end if;

      if Engine.Invulnerable_Timer > 0 then
         Engine.Invulnerable_Timer := Engine.Invulnerable_Timer - 1;
      end if;

      if Engine.Mode /= Mode_Playing then
         return;
      end if;

      --  Movement calculation with collision checking
      if Engine.Key_Up_Pressed then
         Target_Y := Target_Y - Move_Speed;
         Moving   := True;
      elsif Engine.Key_Down_Pressed then
         Target_Y := Target_Y + Move_Speed;
         Moving   := True;
      end if;

      if Engine.Key_Left_Pressed then
         Target_X := Target_X - Move_Speed;
         Moving   := True;
      elsif Engine.Key_Right_Pressed then
         Target_X := Target_X + Move_Speed;
         Moving   := True;
      end if;

      if Moving then
         Engine.Anim_Frame := Engine.Anim_Frame + 1;

         --  Test X movement
         if not Check_Tile_Collision (Engine.World, Target_X + 6, Engine.Player_Y + 16, 24, 18) then
            Engine.Player_X := Target_X;
         end if;

         --  Test Y movement
         if not Check_Tile_Collision (Engine.World, Engine.Player_X + 6, Target_Y + 16, 24, 18) then
            Engine.Player_Y := Target_Y;
         end if;

         --  Check room transitions
         declare
            Changed : Boolean;
         begin
            Check_Room_Transition
              (Engine.World,
               Engine.Player_X, Engine.Player_Y,
               Changed);
            if Changed then
               Engine.Popup_Text (1 .. 24) := Engine.World.Rooms (Engine.World.Current_Room).Name;
               Engine.Popup_Timer := 90;
            end if;
         end;
      end if;

      --  Update room entities (slimes, skeletons)
      Update_Entities
        (Engine.World,
         Engine.Player_X, Engine.Player_Y,
         Engine.Tick);

      --  Check enemy collision & damage
      if Engine.Invulnerable_Timer = 0 then
         declare
            Dmg : constant Natural := Check_Enemy_Damage (Engine.World, Engine.Player_X, Engine.Player_Y);
         begin
            if Dmg > 0 then
               if Engine.Player_HP > Dmg then
                  Engine.Player_HP := Engine.Player_HP - Dmg;
               else
                  Engine.Player_HP := 0;
                  Engine.Mode := Mode_Game_Over;
               end if;
               Engine.Invulnerable_Timer := 45; -- Invincibility blink
               Engine.Popup_Text (1 .. 14) := "OUCH! -HP!    ";
               Engine.Popup_Timer := 40;
            end if;
         end;
      end if;
   end Update_Game;

   -----------------------------------------------------------------------------
   --  Rendering
   -----------------------------------------------------------------------------
   procedure Render_Game
     (Engine   : in out Engine_State;
      Renderer : in out SDL.Video.Renderers.Renderer)
   is
      Cur_Room : constant Room_Record := Engine.World.Rooms (Engine.World.Current_Room);
   begin
      case Engine.Mode is
         when Mode_Title =>
            --  Dark fantasy background
            Renderer.Set_Draw_Colour (Night_Blue);
            Renderer.Clear;

            --  Ornate Border
            Draw_Frame_Box (Renderer, 40, 40, 720, 520, Gold, Night_Blue);

            --  Title Banner
            Draw_Text (Renderer, "THE QUEST OF THE", 260, 110, Sky_Blue, Scale => 3);
            Draw_Text (Renderer, "ADA KNIGHT", 280, 150, Gold, Scale => 4);

            --  Decorative sword & crystal motif
            Draw_Gem_Icon (Renderer, 320, 220, Crystal_Forest,  Collected => True);
            Draw_Gem_Icon (Renderer, 390, 220, Crystal_Cavern,  Collected => True);
            Draw_Gem_Icon (Renderer, 460, 220, Crystal_Dungeon, Collected => True);

            --  Story Synopsis
            Draw_Text (Renderer, "The ancient realm of Aethelgard is fading into void.", 110, 280, Light_Gray, Scale => 2);
            Draw_Text (Renderer, "Find the 3 Sacred Crystals and restore the Citadel Altar!", 90, 310, White, Scale => 2);

            --  Controls Box
            Draw_Frame_Box (Renderer, 160, 360, 480, 110, Gray, Dark_Gray);
            Draw_Text (Renderer, "CONTROLS:", 180, 375, Yellow, Scale => 2);
            Draw_Text (Renderer, "Move        : ARROWS or W / A / S / D", 200, 400, White, Scale => 2);
            Draw_Text (Renderer, "Attack      : SPACE or Z", 200, 422, White, Scale => 2);
            Draw_Text (Renderer, "Interact    : E or ENTER", 200, 444, White, Scale => 2);

            --  Pulsing Start Prompt
            if (Engine.Tick / 30) mod 2 = 0 then
               Draw_Text (Renderer, ">> PRESS ENTER OR SPACE TO BEGIN <<", 180, 500, Gold, Scale => 2);
            else
               Draw_Text (Renderer, ">> PRESS ENTER OR SPACE TO BEGIN <<", 180, 500, Yellow, Scale => 2);
            end if;

         when Mode_Playing | Mode_Dialogue =>
            --  1. Clear screen
            Renderer.Set_Draw_Colour (Black);
            Renderer.Clear;

            --  2. Draw Map Tiles
            for C in 1 .. Grid_Cols loop
               for R in 1 .. Grid_Rows loop
                  Draw_Tile (Renderer, Cur_Room.Grid (C, R), C, R, Engine.Tick);
               end loop;
            end loop;

            --  3. Draw Entities (Chests, Items, Enemies, NPCs)
            for I in 1 .. Cur_Room.Entity_Cnt loop
               declare
                  E : constant Entity_Record := Cur_Room.Entities (I);
               begin
                  if E.Active then
                     case E.Kind is
                        when Entity_Chest =>
                           Draw_Chest (Renderer, E.X, E.Y, E.Is_Open);
                        when Entity_Slime =>
                           Draw_Slime (Renderer, E.X, E.Y, Engine.Tick, E.Hit_Timer > 0);
                        when Entity_Skeleton =>
                           Draw_Skeleton (Renderer, E.X, E.Y, E.Dir, E.Hit_Timer > 0);
                        when Entity_NPC_Elder | Entity_NPC_Guard =>
                           Draw_NPC (Renderer, E.Kind, E.X, E.Y, Engine.Tick);
                        when Entity_Key_Item | Entity_Heart_Item | Entity_Crystal_Item =>
                           Draw_Item (Renderer, E.Kind, E.X, E.Y, Engine.Tick);
                        when others =>
                           null;
                     end case;
                  end if;
               end;
            end loop;

            --  4. Draw Player
            Draw_Player
              (Renderer        => Renderer,
               X               => Engine.Player_X,
               Y               => Engine.Player_Y,
               Dir             => Engine.Player_Dir,
               Anim_Frame      => Engine.Anim_Frame,
               Is_Attacking    => Engine.Attack_Timer > 0,
               Is_Invulnerable => Engine.Invulnerable_Timer > 0);

            --  5. Top HUD Bar
            Draw_Frame_Box (Renderer, 0, 0, Screen_Width, HUD_Height, Gold, Night_Blue);

            --  Draw Health (3 Hearts)
            for H_Idx in 1 .. 3 loop
               declare
                  Filled : constant Boolean := Engine.Player_HP >= H_Idx * 2;
               begin
                  Draw_Heart (Renderer, 20 + Interfaces.C.int (H_Idx - 1) * 24, 10, Filled);
               end;
            end loop;

            --  Draw Keys
            Draw_Key_Icon (Renderer, 120, 10);
            Draw_Text (Renderer, "x" & Natural'Image (Engine.World.Keys_Count), 148, 12, Gold, Scale => 2);

            --  Draw Sacred Crystals
            Draw_Gem_Icon (Renderer, 220, 10, Crystal_Forest,  Engine.World.Crystals (Crystal_Forest));
            Draw_Gem_Icon (Renderer, 245, 10, Crystal_Cavern,  Engine.World.Crystals (Crystal_Cavern));
            Draw_Gem_Icon (Renderer, 270, 10, Crystal_Dungeon, Engine.World.Crystals (Crystal_Dungeon));

            --  Current Location Name
            Draw_Text (Renderer, Cur_Room.Name, 420, 12, Sky_Blue, Scale => 2);

            --  6. Bottom Bar / Dialogue Window
            if Engine.Dialogue_Active then
               Draw_Frame_Box (Renderer, 10, Bottom_Bar_Y - 20, Screen_Width - 20, 56, Gold, Night_Blue);
               Draw_Text (Renderer, Engine.Dialogue_Line1, 30, Bottom_Bar_Y - 12, White, Scale => 2);
               Draw_Text (Renderer, Engine.Dialogue_Line2, 30, Bottom_Bar_Y + 10, Yellow, Scale => 2);
               Draw_Text (Renderer, "[E] Close", Screen_Width - 110, Bottom_Bar_Y + 10, Light_Gray, Scale => 2);
            else
               --  Hints Bar
               Draw_Frame_Box (Renderer, 0, Bottom_Bar_Y, Screen_Width, 40, Dark_Gray, Black);
               Draw_Text (Renderer, "[ARROWS] Move  [SPACE] Attack  [E] Interact  [ESC] Menu", 90, Bottom_Bar_Y + 12, Light_Gray, Scale => 2);
            end if;

            --  Floating Popup text
            if Engine.Popup_Timer > 0 then
               Draw_Frame_Box (Renderer, 260, 80, 280, 36, Gold, Night_Blue);
               Draw_Text (Renderer, Engine.Popup_Text, 280, 90, Yellow, Scale => 2);
            end if;

         when Mode_Game_Over =>
            Renderer.Set_Draw_Colour (Dark_Red);
            Renderer.Clear;

            Draw_Frame_Box (Renderer, 100, 140, 600, 320, Red, Black);
            Draw_Text (Renderer, "YOU HAVE FALLEN", 230, 200, Red, Scale => 4);
            Draw_Text (Renderer, "The shadows claim your soul...", 220, 270, Light_Gray, Scale => 2);
            Draw_Text (Renderer, "Press [R] to Rise Again and Fight", 200, 340, White, Scale => 2);
            Draw_Text (Renderer, "Press [ESC] to Exit", 310, 380, Gray, Scale => 2);

         when Mode_Victory =>
            Renderer.Set_Draw_Colour (Night_Blue);
            Renderer.Clear;

            Draw_Frame_Box (Renderer, 60, 80, 680, 440, Gold, Dark_Blue);
            Draw_Text (Renderer, "CITADEL PURIFIED!", 210, 130, Gold, Scale => 4);
            Draw_Text (Renderer, "VICTORY OF THE ADA KNIGHT", 180, 190, Sky_Blue, Scale => 3);

            Draw_Gem_Icon (Renderer, 330, 260, Crystal_Forest,  Collected => True);
            Draw_Gem_Icon (Renderer, 390, 260, Crystal_Cavern,  Collected => True);
            Draw_Gem_Icon (Renderer, 450, 260, Crystal_Dungeon, Collected => True);

            Draw_Text (Renderer, "The 3 Sacred Crystals blaze with eternal holy light.", 100, 320, White, Scale => 2);
            Draw_Text (Renderer, "The Void Portal is sealed, and peace returns to the realm!", 70, 350, Light_Green, Scale => 2);

            Draw_Text (Renderer, "Press [R] to Embark Anew", 260, 420, Yellow, Scale => 2);
            Draw_Text (Renderer, "Press [ESC] to Return", 300, 455, Light_Gray, Scale => 2);
      end case;

      Renderer.Present;
   end Render_Game;

   -----------------------------------------------------------------------------
   --  Main Game Loop Runner
   -----------------------------------------------------------------------------
   procedure Run is
      W                    : SDL.Video.Windows.Window;
      Renderer             : SDL.Video.Renderers.Renderer;
      Engine               : Engine_State;
      Event                : SDL.Events.Events.Events;
      Loop_Start_Time_Goal : Ada.Real_Time.Time;
      Frame_Duration       : constant Ada.Real_Time.Time_Span :=
        Ada.Real_Time.Microseconds (16_667); -- 60 FPS
   begin
      Ada.Text_IO.Put_Line ("Initializing The Quest of the Ada Knight...");
      if not SDL.Initialise (SDL.Enable_Screen or SDL.Enable_Events or SDL.Enable_Timer) then
         Ada.Text_IO.Put_Line ("SDL Initialise failed: " & SDL.Error.Get);
         return;
      end if;
      Ada.Text_IO.Put_Line ("SDL initialised. Creating game window...");

      SDL.Video.Windows.Makers.Create
        (Win      => W,
         Title    => "The Quest of the Ada Knight",
         Position => SDL.Natural_Coordinates'(X => 100, Y => 100),
         Size     => SDL.Positive_Sizes'(Width => Screen_Width, Height => Screen_Height),
         Flags    => SDL.Video.Windows.Resizable);

      SDL.Video.Renderers.Makers.Create (Renderer, W);
      Ada.Text_IO.Put_Line ("Window & Renderer created. Starting main loop...");

      Init_Game (Engine);
      Loop_Start_Time_Goal := Ada.Real_Time.Clock;

      Main_Loop : loop
         Loop_Start_Time_Goal := Loop_Start_Time_Goal + Frame_Duration;

         while SDL.Events.Events.Poll (Event) loop
            case Event.Common.Event_Type is
               when SDL.Events.Quit =>
                  exit Main_Loop;

               when SDL.Events.Keyboards.Key_Down =>
                  Handle_Key_Down (Engine, Event.Keyboard.Key_Sym.Scan_Code);

               when SDL.Events.Keyboards.Key_Up =>
                  Handle_Key_Up (Engine, Event.Keyboard.Key_Sym.Scan_Code);

               when others =>
                  null;
            end case;
         end loop;

         if Engine.Should_Quit then
            exit Main_Loop;
         end if;

         Update_Game (Engine);
         Render_Game (Engine, Renderer);

         delay until Loop_Start_Time_Goal;
      end loop Main_Loop;

      Ada.Text_IO.Put_Line ("Shutting down cleanly...");
      W.Finalize;
      SDL.Finalise;
   exception
      when E : others =>
         Ada.Text_IO.Put_Line ("Fatal Exception: " & Ada.Exceptions.Exception_Information (E));
   end Run;

end Game_Engine;

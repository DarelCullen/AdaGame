--------------------------------------------------------------------------------
--  Game_World: Implementation of maps, entities, collision and interactions
--------------------------------------------------------------------------------
package body Game_World is

   use Interfaces.C;
   use type Interfaces.C.int;

   function Is_Solid_Tile (Tile : in Tile_Kind) return Boolean is
   begin
      case Tile is
         when Tile_Tree | Tile_Stone_Wall | Tile_Wood_Wall | Tile_Water | Tile_Door_Locked =>
            return True;
         when others =>
            return False;
      end case;
   end Is_Solid_Tile;

   function Check_Tile_Collision
     (World  : in World_Record;
      X, Y   : in Interfaces.C.int;
      W, H   : in Interfaces.C.int) return Boolean
   is
      --  Convert bounding box corners to grid columns and rows
      Col1 : constant Interfaces.C.int := X / Tile_Size + 1;
      Col2 : constant Interfaces.C.int := (X + W - 1) / Tile_Size + 1;
      Row1 : constant Interfaces.C.int := (Y - View_Offset_Y) / Tile_Size + 1;
      Row2 : constant Interfaces.C.int := (Y + H - 1 - View_Offset_Y) / Tile_Size + 1;
      Cur_Room : constant Room_Record := World.Rooms (World.Current_Room);
   begin
      --  Bound checks within grid
      if Col1 < 1 or else Col2 > Grid_Cols or else Row1 < 1 or else Row2 > Grid_Rows then
         return False; -- Edge handling handled by Room_Transition
      end if;

      for C in Col1 .. Col2 loop
         for R in Row1 .. Row2 loop
            if Is_Solid_Tile (Cur_Room.Grid (Positive (C), Positive (R))) then
               return True;
            end if;
         end loop;
      end loop;

      return False;
   end Check_Tile_Collision;

   -----------------------------------------------------------------------------
   --  Map Layouts Initialization
   -----------------------------------------------------------------------------
   procedure Init_World (World : out World_Record) is
   begin
      World.Current_Room := Room_Forest;
      World.Keys_Count   := 0;
      World.Crystals     := (others => False);
      World.Chest_Opened := (others => False);

      --  Initialize default empty entities
      for Rm in Room_ID loop
         World.Rooms (Rm).Entity_Cnt := 0;
         for E in 1 .. Max_Entities_Per_Room loop
            World.Rooms (Rm).Entities (E) :=
              (Kind         => Entity_None,
               X            => 0,
               Y            => 0,
               Dir          => Dir_Down,
               Active       => False,
               HP           => 1,
               Max_HP       => 1,
               Hit_Timer    => 0,
               Is_Open      => False,
               Patrol_Start => 0,
               Patrol_End   => 0,
               Patrol_Axis  => 'X',
               Move_Speed   => 1,
               Dialogue_ID  => 0);
         end loop;
      end loop;

      --------------------------------------------------------------------------
      --  Room 1: Whispering Woods
      --------------------------------------------------------------------------
      World.Rooms (Room_Forest).Name := "Whispering Woods        ";
      for C in 1 .. Grid_Cols loop
         for R in 1 .. Grid_Rows loop
            World.Rooms (Room_Forest).Grid (C, R) := Tile_Grass;
         end loop;
      end loop;

      --  Surrounding border trees
      for C in 1 .. Grid_Cols loop
         World.Rooms (Room_Forest).Grid (C, 1) := Tile_Tree;
         World.Rooms (Room_Forest).Grid (C, Grid_Rows) := Tile_Tree;
      end loop;
      for R in 1 .. Grid_Rows loop
         World.Rooms (Room_Forest).Grid (1, R) := Tile_Tree;
         World.Rooms (Room_Forest).Grid (Grid_Cols, R) := Tile_Tree;
      end loop;

      --  Exits: North (opening for Village), East (opening for Cavern)
      World.Rooms (Room_Forest).Grid (10, 1) := Tile_Path;
      World.Rooms (Room_Forest).Grid (11, 1) := Tile_Path;
      World.Rooms (Room_Forest).Grid (Grid_Cols, 7) := Tile_Path;

      --  Central Pond
      for C in 5 .. 7 loop
         for R in 6 .. 8 loop
            World.Rooms (Room_Forest).Grid (C, R) := Tile_Water;
         end loop;
      end loop;

      --  Path from South to North and East
      for R in 2 .. 12 loop
         World.Rooms (Room_Forest).Grid (10, R) := Tile_Path;
      end loop;
      for C in 11 .. Grid_Cols - 1 loop
         World.Rooms (Room_Forest).Grid (C, 7) := Tile_Path;
      end loop;

      --  Scattered trees in woods
      World.Rooms (Room_Forest).Grid (4, 3) := Tile_Tree;
      World.Rooms (Room_Forest).Grid (16, 4) := Tile_Tree;
      World.Rooms (Room_Forest).Grid (17, 10) := Tile_Tree;

      --  Chest with Key in forest (Chest 1)
      World.Rooms (Room_Forest).Entity_Cnt := 3;
      World.Rooms (Room_Forest).Entities (1) :=
        (Kind         => Entity_Chest,
         X            => 4 * Tile_Size,
         Y            => View_Offset_Y + 9 * Tile_Size,
         Dir          => Dir_Down,
         Active       => True,
         HP           => 1,
         Max_HP       => 1,
         Hit_Timer    => 0,
         Is_Open      => False,
         Patrol_Start => 0,
         Patrol_End   => 0,
         Patrol_Axis  => 'X',
         Move_Speed   => 0,
         Dialogue_ID  => 1); -- Contains Bronze Key

      --  Friendly Forest Slime
      World.Rooms (Room_Forest).Entities (2) :=
        (Kind         => Entity_Slime,
         X            => 14 * Tile_Size,
         Y            => View_Offset_Y + 9 * Tile_Size,
         Dir          => Dir_Left,
         Active       => True,
         HP           => 2,
         Max_HP       => 2,
         Hit_Timer    => 0,
         Is_Open      => False,
         Patrol_Start => 13 * Tile_Size,
         Patrol_End   => 17 * Tile_Size,
         Patrol_Axis  => 'X',
         Move_Speed   => 1,
         Dialogue_ID  => 0);

      --  Signpost / Guard near North exit
      World.Rooms (Room_Forest).Entities (3) :=
        (Kind         => Entity_NPC_Guard,
         X            => 8 * Tile_Size,
         Y            => View_Offset_Y + 2 * Tile_Size,
         Dir          => Dir_Down,
         Active       => True,
         HP           => 1,
         Max_HP       => 1,
         Hit_Timer    => 0,
         Is_Open      => False,
         Patrol_Start => 0,
         Patrol_End   => 0,
         Patrol_Axis  => 'X',
         Move_Speed   => 0,
         Dialogue_ID  => 10); -- Forest Guard

      --------------------------------------------------------------------------
      --  Room 2: Oakhaven Village
      --------------------------------------------------------------------------
      World.Rooms (Room_Village).Name := "Oakhaven Village        ";
      for C in 1 .. Grid_Cols loop
         for R in 1 .. Grid_Rows loop
            World.Rooms (Room_Village).Grid (C, R) := Tile_Grass;
         end loop;
      end loop;

      --  Perimeter fences / trees
      for C in 1 .. Grid_Cols loop
         World.Rooms (Room_Village).Grid (C, 1) := Tile_Wood_Wall;
         World.Rooms (Room_Village).Grid (C, Grid_Rows) := Tile_Wood_Wall;
      end loop;
      for R in 1 .. Grid_Rows loop
         World.Rooms (Room_Village).Grid (1, R) := Tile_Wood_Wall;
         World.Rooms (Room_Village).Grid (Grid_Cols, R) := Tile_Wood_Wall;
      end loop;

      --  Exits: South (to Forest), North (to Citadel, locked initially!), East (to Dungeon)
      World.Rooms (Room_Village).Grid (10, Grid_Rows) := Tile_Path;
      World.Rooms (Room_Village).Grid (11, Grid_Rows) := Tile_Path;
      World.Rooms (Room_Village).Grid (10, 1) := Tile_Door_Locked; -- Citadel Gate
      World.Rooms (Room_Village).Grid (Grid_Cols, 7) := Tile_Path; -- To Dungeon

      --  Village Paved Square & Fountain
      for C in 8 .. 13 loop
         for R in 5 .. 9 loop
            World.Rooms (Room_Village).Grid (C, R) := Tile_Path;
         end loop;
      end loop;
      World.Rooms (Room_Village).Grid (10, 7) := Tile_Water; -- Village Fountain
      World.Rooms (Room_Village).Grid (11, 7) := Tile_Water;

      --  Houses (Wood walls)
      for C in 3 .. 6 loop
         for R in 3 .. 5 loop
            World.Rooms (Room_Village).Grid (C, R) := Tile_Wood_Wall;
         end loop;
      end loop;
      World.Rooms (Room_Village).Grid (5, 5) := Tile_Door_Open;

      for C in 15 .. 18 loop
         for R in 3 .. 5 loop
            World.Rooms (Room_Village).Grid (C, R) := Tile_Wood_Wall;
         end loop;
      end loop;
      World.Rooms (Room_Village).Grid (16, 5) := Tile_Door_Open;

      --  NPC Elder Eldrin
      World.Rooms (Room_Village).Entity_Cnt := 2;
      World.Rooms (Room_Village).Entities (1) :=
        (Kind         => Entity_NPC_Elder,
         X            => 9 * Tile_Size,
         Y            => View_Offset_Y + 6 * Tile_Size,
         Dir          => Dir_Down,
         Active       => True,
         HP           => 1,
         Max_HP       => 1,
         Hit_Timer    => 0,
         Is_Open      => False,
         Patrol_Start => 0,
         Patrol_End   => 0,
         Patrol_Axis  => 'X',
         Move_Speed   => 0,
         Dialogue_ID  => 20); -- Elder Eldrin

      --  Heart item / Potion near fountain
      World.Rooms (Room_Village).Entities (2) :=
        (Kind         => Entity_Heart_Item,
         X            => 4 * Tile_Size,
         Y            => View_Offset_Y + 10 * Tile_Size,
         Dir          => Dir_Down,
         Active       => True,
         HP           => 1,
         Max_HP       => 1,
         Hit_Timer    => 0,
         Is_Open      => False,
         Patrol_Start => 0,
         Patrol_End   => 0,
         Patrol_Axis  => 'X',
         Move_Speed   => 0,
         Dialogue_ID  => 0);

      --------------------------------------------------------------------------
      --  Room 3: Sunken Cavern (holds Emerald Crystal!)
      --------------------------------------------------------------------------
      World.Rooms (Room_Cavern).Name := "Sunken Emerald Cavern   ";
      for C in 1 .. Grid_Cols loop
         for R in 1 .. Grid_Rows loop
            World.Rooms (Room_Cavern).Grid (C, R) := Tile_Dungeon_Floor;
         end loop;
      end loop;

      --  Perimeter stone walls
      for C in 1 .. Grid_Cols loop
         World.Rooms (Room_Cavern).Grid (C, 1) := Tile_Stone_Wall;
         World.Rooms (Room_Cavern).Grid (C, Grid_Rows) := Tile_Stone_Wall;
      end loop;
      for R in 1 .. Grid_Rows loop
         World.Rooms (Room_Cavern).Grid (1, R) := Tile_Stone_Wall;
         World.Rooms (Room_Cavern).Grid (Grid_Cols, R) := Tile_Stone_Wall;
      end loop;

      --  West Exit (Back to Forest)
      World.Rooms (Room_Cavern).Grid (1, 7) := Tile_Path;

      --  Underground River dividing room
      for R in 2 .. Grid_Rows - 1 loop
         World.Rooms (Room_Cavern).Grid (10, R) := Tile_Water;
      end loop;
      --  Stone bridge across river
      World.Rooms (Room_Cavern).Grid (10, 7) := Tile_Dungeon_Floor;

      --  Spike hazards
      World.Rooms (Room_Cavern).Grid (14, 5) := Tile_Spikes_Up;
      World.Rooms (Room_Cavern).Grid (14, 9) := Tile_Spikes_Up;

      --  Cavern Slimes and Chest with Emerald Crystal
      World.Rooms (Room_Cavern).Entity_Cnt := 3;
      World.Rooms (Room_Cavern).Entities (1) :=
        (Kind         => Entity_Slime,
         X            => 5 * Tile_Size,
         Y            => View_Offset_Y + 4 * Tile_Size,
         Dir          => Dir_Down,
         Active       => True,
         HP           => 2,
         Max_HP       => 2,
         Hit_Timer    => 0,
         Is_Open      => False,
         Patrol_Start => View_Offset_Y + 3 * Tile_Size,
         Patrol_End   => View_Offset_Y + 9 * Tile_Size,
         Patrol_Axis  => 'Y',
         Move_Speed   => 1,
         Dialogue_ID  => 0);

      World.Rooms (Room_Cavern).Entities (2) :=
        (Kind         => Entity_Slime,
         X            => 15 * Tile_Size,
         Y            => View_Offset_Y + 7 * Tile_Size,
         Dir          => Dir_Left,
         Active       => True,
         HP           => 2,
         Max_HP       => 2,
         Hit_Timer    => 0,
         Is_Open      => False,
         Patrol_Start => 12 * Tile_Size,
         Patrol_End   => 18 * Tile_Size,
         Patrol_Axis  => 'X',
         Move_Speed   => 2,
         Dialogue_ID  => 0);

      --  Chest with Forest Emerald Crystal (Chest 2)
      World.Rooms (Room_Cavern).Entities (3) :=
        (Kind         => Entity_Chest,
         X            => 17 * Tile_Size,
         Y            => View_Offset_Y + 4 * Tile_Size,
         Dir          => Dir_Down,
         Active       => True,
         HP           => 1,
         Max_HP       => 1,
         Hit_Timer    => 0,
         Is_Open      => False,
         Patrol_Start => 0,
         Patrol_End   => 0,
         Patrol_Axis  => 'X',
         Move_Speed   => 0,
         Dialogue_ID  => 2); -- Contains Emerald Crystal!

      --------------------------------------------------------------------------
      --  Room 4: Lich Crypt & Dungeon (holds Sapphire & Ruby Crystals)
      --------------------------------------------------------------------------
      World.Rooms (Room_Dungeon).Name := "Lich Crypt & Dungeon    ";
      for C in 1 .. Grid_Cols loop
         for R in 1 .. Grid_Rows loop
            World.Rooms (Room_Dungeon).Grid (C, R) := Tile_Dungeon_Floor;
         end loop;
      end loop;

      for C in 1 .. Grid_Cols loop
         World.Rooms (Room_Dungeon).Grid (C, 1) := Tile_Stone_Wall;
         World.Rooms (Room_Dungeon).Grid (C, Grid_Rows) := Tile_Stone_Wall;
      end loop;
      for R in 1 .. Grid_Rows loop
         World.Rooms (Room_Dungeon).Grid (1, R) := Tile_Stone_Wall;
         World.Rooms (Room_Dungeon).Grid (Grid_Cols, R) := Tile_Stone_Wall;
      end loop;

      --  West Exit (Back to Village)
      World.Rooms (Room_Dungeon).Grid (1, 7) := Tile_Path;

      --  Inner dungeon chamber walls with locked door
      for R in 3 .. 11 loop
         World.Rooms (Room_Dungeon).Grid (12, R) := Tile_Stone_Wall;
      end loop;
      World.Rooms (Room_Dungeon).Grid (12, 7) := Tile_Door_Locked; -- Requires Key!

      --  Enemies: Patrolling Skeletons
      World.Rooms (Room_Dungeon).Entity_Cnt := 4;
      World.Rooms (Room_Dungeon).Entities (1) :=
        (Kind         => Entity_Skeleton,
         X            => 6 * Tile_Size,
         Y            => View_Offset_Y + 4 * Tile_Size,
         Dir          => Dir_Down,
         Active       => True,
         HP           => 3,
         Max_HP       => 3,
         Hit_Timer    => 0,
         Is_Open      => False,
         Patrol_Start => View_Offset_Y + 3 * Tile_Size,
         Patrol_End   => View_Offset_Y + 10 * Tile_Size,
         Patrol_Axis  => 'Y',
         Move_Speed   => 1,
         Dialogue_ID  => 0);

      World.Rooms (Room_Dungeon).Entities (2) :=
        (Kind         => Entity_Skeleton,
         X            => 8 * Tile_Size,
         Y            => View_Offset_Y + 9 * Tile_Size,
         Dir          => Dir_Right,
         Active       => True,
         HP           => 3,
         Max_HP       => 3,
         Hit_Timer    => 0,
         Is_Open      => False,
         Patrol_Start => 3 * Tile_Size,
         Patrol_End   => 10 * Tile_Size,
         Patrol_Axis  => 'X',
         Move_Speed   => 1,
         Dialogue_ID  => 0);

      --  Chest in outer dungeon with Sapphire Crystal (Chest 3)
      World.Rooms (Room_Dungeon).Entities (3) :=
        (Kind         => Entity_Chest,
         X            => 3 * Tile_Size,
         Y            => View_Offset_Y + 3 * Tile_Size,
         Dir          => Dir_Down,
         Active       => True,
         HP           => 1,
         Max_HP       => 1,
         Hit_Timer    => 0,
         Is_Open      => False,
         Patrol_Start => 0,
         Patrol_End   => 0,
         Patrol_Axis  => 'X',
         Move_Speed   => 0,
         Dialogue_ID  => 3); -- Sapphire Crystal

      --  Chest in inner vault with Dungeon Ruby Crystal (Chest 4)
      World.Rooms (Room_Dungeon).Entities (4) :=
        (Kind         => Entity_Chest,
         X            => 16 * Tile_Size,
         Y            => View_Offset_Y + 7 * Tile_Size,
         Dir          => Dir_Down,
         Active       => True,
         HP           => 1,
         Max_HP       => 1,
         Hit_Timer    => 0,
         Is_Open      => False,
         Patrol_Start => 0,
         Patrol_End   => 0,
         Patrol_Axis  => 'X',
         Move_Speed   => 0,
         Dialogue_ID  => 4); -- Ruby Crystal

      --------------------------------------------------------------------------
      --  Room 5: The Sacred Citadel (Grand Altar)
      --------------------------------------------------------------------------
      World.Rooms (Room_Citadel).Name := "The Sacred Citadel      ";
      for C in 1 .. Grid_Cols loop
         for R in 1 .. Grid_Rows loop
            World.Rooms (Room_Citadel).Grid (C, R) := Tile_Citadel_Floor;
         end loop;
      end loop;

      --  Pillars and Grand Walls
      for C in 1 .. Grid_Cols loop
         World.Rooms (Room_Citadel).Grid (C, 1) := Tile_Stone_Wall;
         World.Rooms (Room_Citadel).Grid (C, Grid_Rows) := Tile_Stone_Wall;
      end loop;
      for R in 1 .. Grid_Rows loop
         World.Rooms (Room_Citadel).Grid (1, R) := Tile_Stone_Wall;
         World.Rooms (Room_Citadel).Grid (Grid_Cols, R) := Tile_Stone_Wall;
      end loop;

      --  South Exit (Back to Village)
      World.Rooms (Room_Citadel).Grid (10, Grid_Rows) := Tile_Path;
      World.Rooms (Room_Citadel).Grid (11, Grid_Rows) := Tile_Path;

      --  Citadel Pillars
      World.Rooms (Room_Citadel).Grid (4, 4) := Tile_Stone_Wall;
      World.Rooms (Room_Citadel).Grid (4, 9) := Tile_Stone_Wall;
      World.Rooms (Room_Citadel).Grid (7, 4) := Tile_Stone_Wall;
      World.Rooms (Room_Citadel).Grid (7, 9) := Tile_Stone_Wall;
      World.Rooms (Room_Citadel).Grid (14, 4) := Tile_Stone_Wall;
      World.Rooms (Room_Citadel).Grid (14, 9) := Tile_Stone_Wall;
      World.Rooms (Room_Citadel).Grid (17, 4) := Tile_Stone_Wall;
      World.Rooms (Room_Citadel).Grid (17, 9) := Tile_Stone_Wall;

      --  Central Sacred Altar
      World.Rooms (Room_Citadel).Grid (10, 6) := Tile_Altar;
      World.Rooms (Room_Citadel).Grid (11, 6) := Tile_Altar;

      World.Rooms (Room_Citadel).Entity_Cnt := 1;
      World.Rooms (Room_Citadel).Entities (1) :=
        (Kind         => Entity_NPC_Guard,
         X            => 8 * Tile_Size,
         Y            => View_Offset_Y + 6 * Tile_Size,
         Dir          => Dir_Right,
         Active       => True,
         HP           => 1,
         Max_HP       => 1,
         Hit_Timer    => 0,
         Is_Open      => False,
         Patrol_Start => 0,
         Patrol_End   => 0,
         Patrol_Axis  => 'X',
         Move_Speed   => 0,
         Dialogue_ID  => 30); -- Citadel High Guard
   end Init_World;

   -----------------------------------------------------------------------------
   --  Entity AI & Movement Updates
   -----------------------------------------------------------------------------
   procedure Update_Entities
     (World    : in out World_Record;
      Player_X : in Interfaces.C.int;
      Player_Y : in Interfaces.C.int;
      Tick     : in Natural)
   is
      pragma Unreferenced (Player_X, Player_Y);
      Room : Room_Record renames World.Rooms (World.Current_Room);
   begin
      for I in 1 .. Room.Entity_Cnt loop
         declare
            E : Entity_Record renames Room.Entities (I);
         begin
            if E.Active then
               --  Decrement hit animation timer
               if E.Hit_Timer > 0 then
                  E.Hit_Timer := E.Hit_Timer - 1;
               end if;

               --  Patrolling enemies movement
               if (E.Kind = Entity_Slime or else E.Kind = Entity_Skeleton) and then E.Patrol_End > E.Patrol_Start then
                  if Tick mod 2 = 0 then
                     if E.Patrol_Axis = 'X' then
                        if E.Dir = Dir_Right then
                           E.X := E.X + E.Move_Speed;
                           if E.X >= E.Patrol_End then
                              E.Dir := Dir_Left;
                           end if;
                        else
                           E.X := E.X - E.Move_Speed;
                           if E.X <= E.Patrol_Start then
                              E.Dir := Dir_Right;
                           end if;
                        end if;
                     else
                        if E.Dir = Dir_Down then
                           E.Y := E.Y + E.Move_Speed;
                           if E.Y >= E.Patrol_End then
                              E.Dir := Dir_Up;
                           end if;
                        else
                           E.Y := E.Y - E.Move_Speed;
                           if E.Y <= E.Patrol_Start then
                              E.Dir := Dir_Down;
                           end if;
                        end if;
                     end if;
                  end if;
               end if;
            end if;
         end;
      end loop;
   end Update_Entities;

   -----------------------------------------------------------------------------
   --  Player Attack
   -----------------------------------------------------------------------------
   procedure Process_Player_Attack
     (World            : in out World_Record;
      Player_X, Player_Y : in Interfaces.C.int;
      Player_Dir       : in Direction;
      Hit_Enemy        : out Boolean)
   is
      Room : Room_Record renames World.Rooms (World.Current_Room);
      --  Attack hitbox in front of player
      Atk_X, Atk_Y : Interfaces.C.int := 0;
      Atk_W, Atk_H : constant Interfaces.C.int := 36;
   begin
      Hit_Enemy := False;

      case Player_Dir is
         when Dir_Up =>
            Atk_X := Player_X + 2;
            Atk_Y := Player_Y - 24;
         when Dir_Down =>
            Atk_X := Player_X + 2;
            Atk_Y := Player_Y + 28;
         when Dir_Left =>
            Atk_X := Player_X - 24;
            Atk_Y := Player_Y + 4;
         when Dir_Right =>
            Atk_X := Player_X + 28;
            Atk_Y := Player_Y + 4;
      end case;

      for I in 1 .. Room.Entity_Cnt loop
         declare
            E : Entity_Record renames Room.Entities (I);
         begin
            if E.Active and then (E.Kind = Entity_Slime or else E.Kind = Entity_Skeleton) then
               --  Check bounding box overlap
               if Atk_X < E.X + 32 and then Atk_X + Atk_W > E.X + 8 and then
                  Atk_Y < E.Y + 32 and then Atk_Y + Atk_H > E.Y + 8
               then
                  Hit_Enemy   := True;
                  E.Hit_Timer := 15;
                  if E.HP > 1 then
                     E.HP := E.HP - 1;
                     --  Knockback
                     case Player_Dir is
                        when Dir_Up    => E.Y := E.Y - 12;
                        when Dir_Down  => E.Y := E.Y + 12;
                        when Dir_Left  => E.X := E.X - 12;
                        when Dir_Right => E.X := E.X + 12;
                     end case;
                  else
                     --  Defeated!
                     E.Active := False;
                  end if;
               end if;
            end if;
         end;
      end loop;
   end Process_Player_Attack;

   -----------------------------------------------------------------------------
   --  Enemy Damage Check
   -----------------------------------------------------------------------------
   function Check_Enemy_Damage
     (World            : in World_Record;
      Player_X, Player_Y : in Interfaces.C.int) return Natural
   is
      Room : constant Room_Record := World.Rooms (World.Current_Room);
   begin
      for I in 1 .. Room.Entity_Cnt loop
         declare
            E : constant Entity_Record := Room.Entities (I);
         begin
            if E.Active and then (E.Kind = Entity_Slime or else E.Kind = Entity_Skeleton) then
               if Player_X + 8 < E.X + 30 and then Player_X + 28 > E.X + 10 and then
                  Player_Y + 8 < E.Y + 32 and then Player_Y + 30 > E.Y + 10
               then
                  if E.Kind = Entity_Skeleton then
                     return 2; -- Skeleton deals 2 HP damage
                  else
                     return 1; -- Slime deals 1 HP damage
                  end if;
               end if;
            end if;
         end;
      end loop;

      --  Check spike traps
      declare
         Col : constant Interfaces.C.int := (Player_X + 16) / Tile_Size + 1;
         Row : constant Interfaces.C.int := (Player_Y + 20 - View_Offset_Y) / Tile_Size + 1;
      begin
         if Col in 1 .. Grid_Cols and then Row in 1 .. Grid_Rows then
            if Room.Grid (Positive (Col), Positive (Row)) = Tile_Spikes_Up then
               return 1;
            end if;
         end if;
      end;

      return 0;
   end Check_Enemy_Damage;

   -----------------------------------------------------------------------------
   --  Interaction (Chests, NPCs, Doors, Items)
   -----------------------------------------------------------------------------
   procedure Try_Interact
     (World            : in out World_Record;
      Player_X, Player_Y : in Interfaces.C.int;
      Player_Dir       : in Direction;
      Player_HP        : in out Natural;
      Player_Max_HP    : in Natural;
      Message_Active   : out Boolean;
      Message_Line1    : out String;
      Message_Line2    : out String;
      Sound_Trigger    : out Natural)
   is
      Room : Room_Record renames World.Rooms (World.Current_Room);
      Int_X, Int_Y : Interfaces.C.int := 0;
   begin
      Message_Active := False;
      Message_Line1  := (others => ' ');
      Message_Line2  := (others => ' ');
      Sound_Trigger  := 0;

      case Player_Dir is
         when Dir_Up    => Int_X := Player_X + 16; Int_Y := Player_Y - 10;
         when Dir_Down  => Int_X := Player_X + 16; Int_Y := Player_Y + 40;
         when Dir_Left  => Int_X := Player_X - 10; Int_Y := Player_Y + 16;
         when Dir_Right => Int_X := Player_X + 40; Int_Y := Player_Y + 16;
      end case;

      --  1. Check Tile Interaction (Locked Doors, Altar)
      declare
         Col : constant Interfaces.C.int := Int_X / Tile_Size + 1;
         Row : constant Interfaces.C.int := (Int_Y - View_Offset_Y) / Tile_Size + 1;
      begin
         if Col in 1 .. Grid_Cols and then Row in 1 .. Grid_Rows then
            declare
               T : Tile_Kind renames Room.Grid (Positive (Col), Positive (Row));
            begin
               if T = Tile_Door_Locked then
                  if World.Keys_Count > 0 then
                     World.Keys_Count := World.Keys_Count - 1;
                     T := Tile_Door_Open;
                     Message_Active := True;
                     Message_Line1 (1 .. 27) := "Used 1 Key! Door unlocked. ";
                     Message_Line2 (1 .. 25) := "The passageway is clear! ";
                     Sound_Trigger := 1;
                     return;
                  else
                     Message_Active := True;
                     Message_Line1 (1 .. 33) := "This sturdy iron door is locked! ";
                     Message_Line2 (1 .. 29) := "You need a Key to open it.   ";
                     return;
                  end if;
               elsif T = Tile_Altar then
                  if World.Crystals (Crystal_Forest) and then
                     World.Crystals (Crystal_Cavern) and then
                     World.Crystals (Crystal_Dungeon)
                  then
                     Message_Active := True;
                     Message_Line1 (1 .. 34) := "The 3 Sacred Crystals resonate!   ";
                     Message_Line2 (1 .. 32) := "THE SACRED CITADEL IS PURIFIED! ";
                     Sound_Trigger := 3; -- Victory
                     return;
                  else
                     Message_Active := True;
                     Message_Line1 (1 .. 35) := "Altar of Light. Needs 3 Crystals:  ";
                     Message_Line2 (1 .. 33) := "Forest Emerald, Cavern, Dungeon! ";
                     return;
                  end if;
               end if;
            end;
         end if;
      end;

      --  2. Check Entity Interaction (Chests, NPCs, Items)
      for I in 1 .. Room.Entity_Cnt loop
         declare
            E : Entity_Record renames Room.Entities (I);
         begin
            if E.Active then
               --  Proximity check
               if (abs (Int_X - (E.X + 16)) < 26) and then (abs (Int_Y - (E.Y + 16)) < 26) then
                  case E.Kind is
                     when Entity_Chest =>
                        if not E.Is_Open then
                           E.Is_Open := True;
                           Message_Active := True;
                           Sound_Trigger := 2;
                           case E.Dialogue_ID is
                              when 1 =>
                                 World.Keys_Count := World.Keys_Count + 1;
                                 Message_Line1 (1 .. 27) := "Found an ancient Chest!    ";
                                 Message_Line2 (1 .. 25) := "Acquired 1 Bronze Key!   ";
                              when 2 =>
                                 World.Crystals (Crystal_Forest) := True;
                                 Message_Line1 (1 .. 29) := "Found the Sacred Chest!      ";
                                 Message_Line2 (1 .. 33) := "Obtained the FOREST EMERALD GEM! ";
                              when 3 =>
                                 World.Crystals (Crystal_Cavern) := True;
                                 World.Keys_Count := World.Keys_Count + 1;
                                 Message_Line1 (1 .. 29) := "Crypt Reliquary Opened!      ";
                                 Message_Line2 (1 .. 34) := "Obtained the CAVERN SAPPHIRE GEM! ";
                              when 4 =>
                                 World.Crystals (Crystal_Dungeon) := True;
                                 World.Keys_Count := World.Keys_Count + 1;
                                 Message_Line1 (1 .. 30) := "Lich Master Vault Opened!     ";
                                 Message_Line2 (1 .. 34) := "Obtained the DUNGEON RUBY CORE!   ";
                              when others =>
                                 World.Keys_Count := World.Keys_Count + 1;
                                 Message_Line1 (1 .. 24) := "Found a treasure chest! ";
                                 Message_Line2 (1 .. 20) := "Obtained a Key!     ";
                           end case;
                           return;
                        else
                           Message_Active := True;
                           Message_Line1 (1 .. 28) := "The chest is empty now.     ";
                           Message_Line2 (1 .. 28) := "You already looted its boon.";
                           return;
                        end if;

                     when Entity_Heart_Item =>
                        E.Active := False;
                        if Player_HP < Player_Max_HP then
                           Player_HP := Natural'Min (Player_Max_HP, Player_HP + 2);
                        end if;
                        Message_Active := True;
                        Message_Line1 (1 .. 29) := "Drank a Vitality Elixir!     ";
                        Message_Line2 (1 .. 26) := "Restored 2 Hearts of HP!  ";
                        Sound_Trigger := 2;
                        return;

                     when Entity_NPC_Elder =>
                        Message_Active := True;
                        if not (World.Crystals (Crystal_Forest) and then
                                World.Crystals (Crystal_Cavern) and then
                                World.Crystals (Crystal_Dungeon))
                        then
                           Message_Line1 (1 .. 35) := "Elder: Bring the 3 Sacred Crystals ";
                           Message_Line2 (1 .. 35) := "to the Citadel Altar to the North! ";
                        else
                           Message_Line1 (1 .. 35) := "Elder: You found all 3 Crystals!   ";
                           Message_Line2 (1 .. 35) := "Hurry, place them upon the Altar!  ";
                        end if;
                        return;

                     when Entity_NPC_Guard =>
                        Message_Active := True;
                        if E.Dialogue_ID = 10 then
                           Message_Line1 (1 .. 35) := "Guard: Beware the East Caverns!    ";
                           Message_Line2 (1 .. 35) := "Slimes and hidden treasures await. ";
                        else
                           Message_Line1 (1 .. 35) := "Guard: This is the Citadel Hall.   ";
                           Message_Line2 (1 .. 35) := "Only the Chosen may purge shadow.  ";
                        end if;
                        return;

                     when others =>
                        null;
                  end case;
               end if;
            end if;
         end;
      end loop;
   end Try_Interact;

   -----------------------------------------------------------------------------
   --  Room Transitions
   -----------------------------------------------------------------------------
   procedure Check_Room_Transition
     (World            : in out World_Record;
      Player_X, Player_Y : in out Interfaces.C.int;
      Room_Changed     : out Boolean)
   is
   begin
      Room_Changed := False;

      case World.Current_Room is
         when Room_Forest =>
            --  North edge -> Village
            if Player_Y < View_Offset_Y and then Player_X in 8 * Tile_Size .. 12 * Tile_Size then
               World.Current_Room := Room_Village;
               Player_Y := View_Offset_Y + (Grid_Rows - 2) * Tile_Size;
               Room_Changed := True;
            --  East edge -> Cavern
            elsif Player_X > (Grid_Cols - 1) * Tile_Size and then
                  Player_Y in View_Offset_Y + 5 * Tile_Size .. View_Offset_Y + 8 * Tile_Size
            then
               World.Current_Room := Room_Cavern;
               Player_X := Tile_Size + 4;
               Room_Changed := True;
            end if;

         when Room_Village =>
            --  South edge -> Forest
            if Player_Y > View_Offset_Y + (Grid_Rows - 1) * Tile_Size and then
               Player_X in 8 * Tile_Size .. 12 * Tile_Size
            then
               World.Current_Room := Room_Forest;
               Player_Y := View_Offset_Y + Tile_Size;
               Room_Changed := True;
            --  North edge (through Citadel Gate) -> Citadel
            elsif Player_Y < View_Offset_Y and then Player_X in 9 * Tile_Size .. 12 * Tile_Size then
               if World.Rooms (Room_Village).Grid (10, 1) = Tile_Door_Open then
                  World.Current_Room := Room_Citadel;
                  Player_Y := View_Offset_Y + (Grid_Rows - 2) * Tile_Size;
                  Room_Changed := True;
               end if;
            --  East edge -> Dungeon
            elsif Player_X > (Grid_Cols - 1) * Tile_Size and then
                  Player_Y in View_Offset_Y + 5 * Tile_Size .. View_Offset_Y + 8 * Tile_Size
            then
               World.Current_Room := Room_Dungeon;
               Player_X := Tile_Size + 4;
               Room_Changed := True;
            end if;

         when Room_Cavern =>
            --  West edge -> Forest
            if Player_X < 4 and then
               Player_Y in View_Offset_Y + 5 * Tile_Size .. View_Offset_Y + 8 * Tile_Size
            then
               World.Current_Room := Room_Forest;
               Player_X := (Grid_Cols - 2) * Tile_Size;
               Room_Changed := True;
            end if;

         when Room_Dungeon =>
            --  West edge -> Village
            if Player_X < 4 and then
               Player_Y in View_Offset_Y + 5 * Tile_Size .. View_Offset_Y + 8 * Tile_Size
            then
               World.Current_Room := Room_Village;
               Player_X := (Grid_Cols - 2) * Tile_Size;
               Room_Changed := True;
            end if;

         when Room_Citadel =>
            --  South edge -> Village
            if Player_Y > View_Offset_Y + (Grid_Rows - 1) * Tile_Size and then
               Player_X in 8 * Tile_Size .. 12 * Tile_Size
            then
               World.Current_Room := Room_Village;
               Player_Y := View_Offset_Y + Tile_Size;
               Room_Changed := True;
            end if;
      end case;
   end Check_Room_Transition;

end Game_World;

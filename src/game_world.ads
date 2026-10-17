--------------------------------------------------------------------------------
--  Game_World: Rooms, Maps, Tile definitions, and Entity placement
--  SPDX-License-Identifier: GPL-2.0-only
--------------------------------------------------------------------------------
with Interfaces.C;
with Game_Types; use Game_Types;

package Game_World is

   Max_Entities_Per_Room : constant := 10;

   type Entity_Record is record
      Kind         : Entity_Kind;
      X, Y         : Interfaces.C.int; -- Pixel coordinates
      Dir          : Direction;
      Active       : Boolean;
      HP           : Natural;
      Max_HP       : Natural;
      Hit_Timer    : Natural;
      Is_Open      : Boolean;          -- For chests
      Patrol_Start : Interfaces.C.int;
      Patrol_End   : Interfaces.C.int;
      Patrol_Axis  : Character;        -- 'X' or 'Y'
      Move_Speed   : Interfaces.C.int;
      Dialogue_ID  : Natural;          -- For NPCs
   end record;

   type Entity_List is array (1 .. Max_Entities_Per_Room) of Entity_Record;

   type Room_Record is record
      Name       : String (1 .. 24);
      Grid       : Map_Grid;
      Entities   : Entity_List;
      Entity_Cnt : Natural;
   end record;

   type Room_Array is array (Room_ID) of Room_Record;
   type Chest_Flag_Array is array (1 .. 10) of Boolean;

   type World_Record is record
      Current_Room : Room_ID;
      Rooms        : Room_Array;
      Keys_Count   : Natural;
      Crystals     : Crystal_Array;
      Chest_Opened : Chest_Flag_Array; -- Persistent chest states
   end record;

   --  Initialize world maps and entities
   procedure Init_World (World : out World_Record);

   --  Checks whether a tile is solid/impassable
   function Is_Solid_Tile (Tile : in Tile_Kind) return Boolean;

   --  Checks whether given bounding box collides with world tiles
   function Check_Tile_Collision
     (World  : in World_Record;
      X, Y   : in Interfaces.C.int;
      W, H   : in Interfaces.C.int) return Boolean;

   --  Interact with tile / entity in front of player
   procedure Try_Interact
     (World            : in out World_Record;
      Player_X, Player_Y : in Interfaces.C.int;
      Player_Dir       : in Direction;
      Player_HP        : in out Natural;
      Player_Max_HP    : in Natural;
      Message_Active   : out Boolean;
      Message_Line1    : out String;
      Message_Line2    : out String;
      Sound_Trigger    : out Natural);

   --  Update room entities (slime/skeleton patrol movement & AI)
   procedure Update_Entities
     (World    : in out World_Record;
      Player_X : in Interfaces.C.int;
      Player_Y : in Interfaces.C.int;
      Tick     : in Natural);

   --  Attack swing against enemies in front of player
   procedure Process_Player_Attack
     (World            : in out World_Record;
      Player_X, Player_Y : in Interfaces.C.int;
      Player_Dir       : in Direction;
      Hit_Enemy        : out Boolean);

   --  Check if enemy touches player (returns damage amount, 0 if none)
   function Check_Enemy_Damage
     (World            : in World_Record;
      Player_X, Player_Y : in Interfaces.C.int) return Natural;

   --  Check for room transitions at screen edges or doors
   procedure Check_Room_Transition
     (World            : in out World_Record;
      Player_X, Player_Y : in out Interfaces.C.int;
      Room_Changed     : out Boolean);

end Game_World;

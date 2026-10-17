--------------------------------------------------------------------------------
--  Game_Engine: Main game state, event processing, update loop and rendering
--------------------------------------------------------------------------------
with Interfaces.C;
with SDL.Video.Renderers;
with SDL.Events.Keyboards;
with Game_Types; use Game_Types;
with Game_World; use Game_World;

package Game_Engine is

   type Engine_State is record
      Mode               : Game_Mode;
      Player_X           : Interfaces.C.int;
      Player_Y           : Interfaces.C.int;
      Player_Dir         : Direction;
      Player_HP          : Natural;
      Player_Max_HP      : Natural;
      Invulnerable_Timer : Natural;
      Attack_Timer       : Natural;
      Anim_Frame         : Natural;
      Tick               : Natural;
      World              : World_Record;
      Dialogue_Active    : Boolean;
      Dialogue_Line1     : String (1 .. 40);
      Dialogue_Line2     : String (1 .. 40);
      Popup_Text         : String (1 .. 32);
      Popup_Timer        : Natural;
      Should_Quit        : Boolean;
      
      --  Input states
      Key_Up_Pressed     : Boolean;
      Key_Down_Pressed   : Boolean;
      Key_Left_Pressed   : Boolean;
      Key_Right_Pressed  : Boolean;
   end record;

   --  Initializes new game session
   procedure Init_Game (Engine : out Engine_State);

   --  Runs one game tick update (called at 60 Hz)
   procedure Update_Game (Engine : in out Engine_State);

   --  Renders current game frame
   procedure Render_Game
     (Engine   : in out Engine_State;
      Renderer : in out SDL.Video.Renderers.Renderer);

   --  Handles SDL keyboard input event
   procedure Handle_Key_Down
     (Engine    : in out Engine_State;
      Scan_Code : in SDL.Events.Keyboards.Scan_Codes);

   procedure Handle_Key_Up
     (Engine    : in out Engine_State;
      Scan_Code : in SDL.Events.Keyboards.Scan_Codes);

   --  Executes the complete game loop from initialization to shutdown
   procedure Run;

end Game_Engine;

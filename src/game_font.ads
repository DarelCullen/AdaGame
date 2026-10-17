--------------------------------------------------------------------------------
--  Game_Font: Crisp retro bitmap font renderer for SDL2
--------------------------------------------------------------------------------
with Interfaces.C;
with SDL;
with SDL.Video.Palettes;
with SDL.Video.Renderers;

package Game_Font is

   --  Draws a text string at pixel coordinates (X, Y) with specified scale & color.
   --  Base glyph size is 5x7 pixels plus 1px spacing (6x8 per character * Scale).
   procedure Draw_Text
     (Renderer : in out SDL.Video.Renderers.Renderer;
      Text     : in String;
      X        : in Interfaces.C.int;
      Y        : in Interfaces.C.int;
      Colour   : in SDL.Video.Palettes.Colour := (255, 255, 255, 255);
      Scale    : in Positive := 2;
      Shadow   : in Boolean := True);

   --  Returns pixel width of the given text when drawn with Scale
   function Text_Width (Text : in String; Scale : in Positive := 2) return Interfaces.C.int;

end Game_Font;

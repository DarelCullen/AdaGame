--------------------------------------------------------------------------------
--  Game_Font: Body implementing a 5x7 retro bitmap font
--------------------------------------------------------------------------------
with SDL.Video.Rectangles;

package body Game_Font is

   use Interfaces.C;
   use type Interfaces.C.int;

   type Glyph_Rows is array (1 .. 7) of Natural;

   --  Returns 5-bit row pattern for character C
   function Get_Glyph (C : in Character) return Glyph_Rows is
      UC : Character := C;
   begin
      --  Convert lowercase to uppercase for simple font
      if UC in 'a' .. 'z' then
         UC := Character'Val (Character'Pos (UC) - 32);
      end if;

      case UC is
         when 'A' => return (2#01110#, 2#10001#, 2#10001#, 2#11111#, 2#10001#, 2#10001#, 2#10001#);
         when 'B' => return (2#11110#, 2#10001#, 2#10001#, 2#11110#, 2#10001#, 2#10001#, 2#11110#);
         when 'C' => return (2#01111#, 2#10000#, 2#10000#, 2#10000#, 2#10000#, 2#10000#, 2#01111#);
         when 'D' => return (2#11110#, 2#10001#, 2#10001#, 2#10001#, 2#10001#, 2#10001#, 2#11110#);
         when 'E' => return (2#11111#, 2#10000#, 2#10000#, 2#11110#, 2#10000#, 2#10000#, 2#11111#);
         when 'F' => return (2#11111#, 2#10000#, 2#10000#, 2#11110#, 2#10000#, 2#10000#, 2#10000#);
         when 'G' => return (2#01111#, 2#10000#, 2#10000#, 2#10111#, 2#10001#, 2#10001#, 2#01110#);
         when 'H' => return (2#10001#, 2#10001#, 2#10001#, 2#11111#, 2#10001#, 2#10001#, 2#10001#);
         when 'I' => return (2#11111#, 2#00100#, 2#00100#, 2#00100#, 2#00100#, 2#00100#, 2#11111#);
         when 'J' => return (2#00001#, 2#00001#, 2#00001#, 2#00001#, 2#10001#, 2#10001#, 2#01110#);
         when 'K' => return (2#10001#, 2#10010#, 2#10100#, 2#11000#, 2#10100#, 2#10010#, 2#10001#);
         when 'L' => return (2#10000#, 2#10000#, 2#10000#, 2#10000#, 2#10000#, 2#10000#, 2#11111#);
         when 'M' => return (2#10001#, 2#11011#, 2#10101#, 2#10101#, 2#10001#, 2#10001#, 2#10001#);
         when 'N' => return (2#10001#, 2#11001#, 2#10101#, 2#10011#, 2#10001#, 2#10001#, 2#10001#);
         when 'O' => return (2#01110#, 2#10001#, 2#10001#, 2#10001#, 2#10001#, 2#10001#, 2#01110#);
         when 'P' => return (2#11110#, 2#10001#, 2#10001#, 2#11110#, 2#10000#, 2#10000#, 2#10000#);
         when 'Q' => return (2#01110#, 2#10001#, 2#10001#, 2#10001#, 2#10101#, 2#10011#, 2#01101#);
         when 'R' => return (2#11110#, 2#10001#, 2#10001#, 2#11110#, 2#10100#, 2#10010#, 2#10001#);
         when 'S' => return (2#01111#, 2#10000#, 2#10000#, 2#01110#, 2#00001#, 2#00001#, 2#11110#);
         when 'T' => return (2#11111#, 2#00100#, 2#00100#, 2#00100#, 2#00100#, 2#00100#, 2#00100#);
         when 'U' => return (2#10001#, 2#10001#, 2#10001#, 2#10001#, 2#10001#, 2#10001#, 2#01110#);
         when 'V' => return (2#10001#, 2#10001#, 2#10001#, 2#10001#, 2#10001#, 2#01010#, 2#00100#);
         when 'W' => return (2#10001#, 2#10001#, 2#10001#, 2#10101#, 2#10101#, 2#11011#, 2#10001#);
         when 'X' => return (2#10001#, 2#10001#, 2#01010#, 2#00100#, 2#01010#, 2#10001#, 2#10001#);
         when 'Y' => return (2#10001#, 2#10001#, 2#01010#, 2#00100#, 2#00100#, 2#00100#, 2#00100#);
         when 'Z' => return (2#11111#, 2#00001#, 2#00010#, 2#00100#, 2#01000#, 2#10000#, 2#11111#);

         when '0' => return (2#01110#, 2#10011#, 2#10101#, 2#10101#, 2#11001#, 2#10001#, 2#01110#);
         when '1' => return (2#00100#, 2#01100#, 2#00100#, 2#00100#, 2#00100#, 2#00100#, 2#01110#);
         when '2' => return (2#01110#, 2#10001#, 2#00001#, 2#00010#, 2#00100#, 2#01000#, 2#11111#);
         when '3' => return (2#11110#, 2#00001#, 2#00001#, 2#01110#, 2#00001#, 2#00001#, 2#11110#);
         when '4' => return (2#00010#, 2#00110#, 2#01010#, 2#10010#, 2#11111#, 2#00010#, 2#00010#);
         when '5' => return (2#11111#, 2#10000#, 2#11110#, 2#00001#, 2#00001#, 2#10001#, 2#01110#);
         when '6' => return (2#00110#, 2#01000#, 2#10000#, 2#11110#, 2#10001#, 2#10001#, 2#01110#);
         when '7' => return (2#11111#, 2#00001#, 2#00010#, 2#00100#, 2#01000#, 2#01000#, 2#01000#);
         when '8' => return (2#01110#, 2#10001#, 2#10001#, 2#01110#, 2#10001#, 2#10001#, 2#01110#);
         when '9' => return (2#01110#, 2#10001#, 2#10001#, 2#01111#, 2#00001#, 2#00010#, 2#01100#);

         when '.' => return (2#00000#, 2#00000#, 2#00000#, 2#00000#, 2#00000#, 2#01100#, 2#01100#);
         when ',' => return (2#00000#, 2#00000#, 2#00000#, 2#00000#, 2#00000#, 2#01100#, 2#00100#);
         when ':' => return (2#00000#, 2#01100#, 2#01100#, 2#00000#, 2#01100#, 2#01100#, 2#00000#);
         when '!' => return (2#00100#, 2#00100#, 2#00100#, 2#00100#, 2#00100#, 2#00000#, 2#00100#);
         when '?' => return (2#01110#, 2#10001#, 2#00010#, 2#00100#, 2#00100#, 2#00000#, 2#00100#);
         when '-' => return (2#00000#, 2#00000#, 2#00000#, 2#11111#, 2#00000#, 2#00000#, 2#00000#);
         when '+' => return (2#00000#, 2#00100#, 2#00100#, 2#11111#, 2#00100#, 2#00100#, 2#00000#);
         when '*' => return (2#00000#, 2#10101#, 2#01110#, 2#11111#, 2#01110#, 2#10101#, 2#00000#);
         when '/' => return (2#00001#, 2#00010#, 2#00100#, 2#01000#, 2#10000#, 2#00000#, 2#00000#);
         when '(' => return (2#00010#, 2#00100#, 2#01000#, 2#01000#, 2#01000#, 2#00100#, 2#00010#);
         when ')' => return (2#01000#, 2#00100#, 2#00010#, 2#00010#, 2#00010#, 2#00100#, 2#01000#);
         when '[' => return (2#01110#, 2#01000#, 2#01000#, 2#01000#, 2#01000#, 2#01000#, 2#01110#);
         when ']' => return (2#01110#, 2#00010#, 2#00010#, 2#00010#, 2#00010#, 2#00010#, 2#01110#);
         when '<' => return (2#00010#, 2#00100#, 2#01000#, 2#10000#, 2#01000#, 2#00100#, 2#00010#);
         when '>' => return (2#01000#, 2#00100#, 2#00010#, 2#00001#, 2#00010#, 2#00100#, 2#01000#);
         when '=' => return (2#00000#, 2#11111#, 2#00000#, 2#11111#, 2#00000#, 2#00000#, 2#00000#);
         when ''' => return (2#00100#, 2#00100#, 2#00010#, 2#00000#, 2#00000#, 2#00000#, 2#00000#);
         when '"' => return (2#01010#, 2#01010#, 2#00000#, 2#00000#, 2#00000#, 2#00000#, 2#00000#);
         when '#' => return (2#01010#, 2#11111#, 2#01010#, 2#01010#, 2#11111#, 2#01010#, 2#00000#);
         when '$' => return (2#00100#, 2#01111#, 2#10100#, 2#01110#, 2#00101#, 2#11110#, 2#00100#);
         when '%' => return (2#11001#, 2#11010#, 2#00100#, 2#01000#, 2#01011#, 2#10011#, 2#00000#);
         when others =>
            return (2#00000#, 2#00000#, 2#00000#, 2#00000#, 2#00000#, 2#00000#, 2#00000#);
      end case;
   end Get_Glyph;

   function Text_Width (Text : in String; Scale : in Positive := 2) return Interfaces.C.int is
   begin
      return Interfaces.C.int (Text'Length * (6 * Scale));
   end Text_Width;

   procedure Draw_Char
     (Renderer : in out SDL.Video.Renderers.Renderer;
      C        : in Character;
      X        : in Interfaces.C.int;
      Y        : in Interfaces.C.int;
      Colour   : in SDL.Video.Palettes.Colour;
      Scale    : in Positive)
   is
      Rows : constant Glyph_Rows := Get_Glyph (C);
      S    : constant Interfaces.C.int := Interfaces.C.int (Scale);
      Dim  : constant SDL.Natural_Dimension := SDL.Natural_Dimension (S);
   begin
      Renderer.Set_Draw_Colour (Colour);
      for Row_Idx in 1 .. 7 loop
         declare
            Row_Val : Natural := Rows (Row_Idx);
            Row_Y   : constant SDL.Coordinate := SDL.Coordinate (Y + Interfaces.C.int (Row_Idx - 1) * S);
         begin
            for Col_Idx in reverse 0 .. 4 loop
               if (Row_Val mod 2) = 1 then
                  declare
                     Col_X : constant SDL.Coordinate := SDL.Coordinate (X + Interfaces.C.int (Col_Idx) * S);
                     R     : constant SDL.Video.Rectangles.Rectangle :=
                       (X => Col_X, Y => Row_Y, Width => Dim, Height => Dim);
                  begin
                     Renderer.Fill (R);
                  end;
               end if;
               Row_Val := Row_Val / 2;
            end loop;
         end;
      end loop;
   end Draw_Char;

   procedure Draw_Text
     (Renderer : in out SDL.Video.Renderers.Renderer;
      Text     : in String;
      X        : in Interfaces.C.int;
      Y        : in Interfaces.C.int;
      Colour   : in SDL.Video.Palettes.Colour := (255, 255, 255, 255);
      Scale    : in Positive := 2;
      Shadow   : in Boolean := True)
   is
      Cur_X : Interfaces.C.int := X;
      Step  : constant Interfaces.C.int := Interfaces.C.int (6 * Scale);
      Black_Shadow : constant SDL.Video.Palettes.Colour := (0, 0, 0, 200);
   begin
      if Shadow then
         --  Draw drop shadow offset by 1*Scale or 2px
         declare
            Shadow_X : Interfaces.C.int := X + Interfaces.C.int (Scale);
            Shadow_Y : constant Interfaces.C.int := Y + Interfaces.C.int (Scale);
         begin
            for C of Text loop
               Draw_Char (Renderer, C, Shadow_X, Shadow_Y, Black_Shadow, Scale);
               Shadow_X := Shadow_X + Step;
            end loop;
         end;
      end if;

      for C of Text loop
         Draw_Char (Renderer, C, Cur_X, Y, Colour, Scale);
         Cur_X := Cur_X + Step;
      end loop;
   end Draw_Text;

end Game_Font;

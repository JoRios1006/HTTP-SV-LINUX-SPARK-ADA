-- http_handler.adb
-- AGPL-3.0

with Interfaces.C;        use Interfaces.C;
with Ada.Strings;
with Ada.Strings.Fixed;
with Http_Bindings;       use Http_Bindings;
with Posix_Constants;     use Posix_Constants;

package body Http_Handler is

   ---------------------------------------------------------------------------
   --  Static response built at elaboration time
   --
   --  The Content-Length header is computed from Payload'Length so it never
   --  goes stale when the HTML changes.
   ---------------------------------------------------------------------------

   Payload : constant String :=
     "<!DOCTYPE html>" &
     "<html lang='en'>" &
       "<head>" &
         "<meta charset='UTF-8'>" &
         "<meta name='viewport' content='width=device-width, initial-scale=1.0'>" &
         "<title>Pong Game</title>" &
       "</head>" &
       "<body><h1>Pong!</h1></body>" &
     "</html>";

   Response : constant String :=
     "HTTP/1.1 200 OK"                                              & ASCII.CR & ASCII.LF &
     "Content-Length: "                                             &
     Ada.Strings.Fixed.Trim (Integer'Image (Payload'Length),
                              Ada.Strings.Left)                     & ASCII.CR & ASCII.LF &
                                                                       ASCII.CR & ASCII.LF &
     Payload;

   ---------------------------------------------------------------------------
   --  Handle_Connection
   ---------------------------------------------------------------------------

   procedure Handle_Connection (Client_FD : int) is
      --  TODO:
      --    1. Parse the request line → extract method and path.
      --    2. Open the file at that path with C_Open.
      --    3. Stream the file to the client with C_Sendfile.
      --    4. Return proper 404 / 405 responses for unknown paths / methods.

      Buf           : char_array (0 .. 4095);
      N_Read        : size_t;
      Bytes_Written : ptrdiff_t;
      Ignored       : int;
   begin
      --  Drain the request so the client doesn't get a connection-reset error.
      --  The content is discarded for now (see TODO above).
      N_Read := C_Read (Client_FD, Buf'Address, Buf'Length);
      pragma Unreferenced (N_Read);

      --  Send the hardcoded response.
      Bytes_Written := C_Write (Fd    => Client_FD,
                                Buf   => Response'Address,
                                Count => Response'Length);
      pragma Unreferenced (Bytes_Written);

      Ignored := C_Close (Client_FD);
      pragma Unreferenced (Ignored);
   end Handle_Connection;

end Http_Handler;

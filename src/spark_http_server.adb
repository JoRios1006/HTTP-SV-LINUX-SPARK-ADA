-- spark_http_server.adb
-- AGPL-3.0
--
-- Entry point.  Brings up a TCP socket on Port and loops forever, handing
-- each accepted connection to Http_Handler.Handle_Connection.
--
-- Startup sequence (mirrors the standard POSIX server recipe):
--
--   socket  →  setsockopt(SO_REUSEADDR)  →  bind  →  listen  →  accept loop

with Interfaces.C;    use Interfaces.C;
with System;
with Http_Bindings;   use Http_Bindings;
with Http_Handler;    use Http_Handler;
with Posix_Constants; use Posix_Constants;

procedure Spark_Http_Server is

   Port    : constant := 8080;
   Backlog : constant := 128;  -- max pending connections before accept drains them

   Server_FD : int;
   Client_FD : int;
   Opt       : aliased int := 1;
   Addr      : aliased Sockaddr_In;
   Addr_Len  : aliased int := Sockaddr_In'Size / 8;
   Ret       : int;

begin
   --  1. Create a TCP socket.
   Server_FD := C_Socket (AF_INET, SOCK_STREAM, 0);
   pragma Assert (Server_FD >= 0);

   --  2. Allow immediate reuse of the port after a restart (avoids
   --     "Address already in use" during development).
   Ret := C_Setsockopt (Server_FD, SOL_SOCKET, SO_REUSEADDR,
                        Opt'Address, int (Opt'Size / 8));
   pragma Assert (Ret = 0);

   --  3. Bind to 0.0.0.0:Port (all interfaces).
   Addr := (Sin_Family => Interfaces.C.unsigned_short (AF_INET),
            Sin_Port   => Htons (Interfaces.C.unsigned_short (Port)),
            Sin_Addr   => INADDR_ANY,
            Sin_Zero   => (others => Interfaces.C.char'Val (0)));

   Ret := C_Bind (Server_FD, Addr'Address, Addr_Len);
   pragma Assert (Ret = 0);

   --  4. Start listening.
   Ret := C_Listen (Server_FD, Backlog);
   pragma Assert (Ret = 0);

   --  5. Accept loop — runs forever (single-threaded, one client at a time).
   loop
      Client_FD := C_Accept (Server_FD,
                              System.Null_Address,
                              System.Null_Address);
      if Client_FD >= 0 then
         Handle_Connection (Client_FD);
      end if;
   end loop;

end Spark_Http_Server;

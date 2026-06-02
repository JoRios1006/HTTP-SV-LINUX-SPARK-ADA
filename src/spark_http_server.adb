-- spark_http_server.adb
-- AGPL-3.0
with Interfaces.C;         use Interfaces.C;
with System;

procedure Spark_Http_Server is
   -- Constants
   Port    : constant := 8080;
   Backlog : constant := 128;
   --  Linux syscall bindings
   -- socket(2)
   function C_Socket
     (Domain   : int;
      Typ      : int;
      Protocol : int) return int
   with Import, Convention => C, External_Name => "socket";
   -- setsockopt(2)
   function C_Setsockopt
     (Sockfd  : int;
      Level   : int;
      Optname : int;
      Optval  : System.Address;
      Optlen  : int) return int
   with Import, Convention => C, External_Name => "setsockopt";
   -- bind(2)
   function C_Bind
     (Sockfd  : int;
      Addr    : System.Address;
      Addrlen : int) return int
   with Import, Convention => C, External_Name => "bind";
   -- listen(2)
   function C_Listen
     (Sockfd  : int;
      Backlog : int) return int
   with Import, Convention => C, External_Name => "listen";
   -- accept(2)
   function C_Accept
     (Sockfd  : int;
      Addr    : System.Address;
      Addrlen : System.Address) return int
   with Import, Convention => C, External_Name => "accept";
   -- read(2)
   function C_Read
     (Fd    : int;
      Buf   : System.Address;
      Count : size_t) return size_t
   with Import, Convention => C, External_Name => "read";
   -- open(2)
   function C_Open
     (Pathname : char_array;
      Flags    : int) return int
   with Import, Convention => C, External_Name => "open";
   -- sendfile(2)
   function C_Sendfile
     (Out_FD : int;
      In_FD  : int;
      Offset : System.Address;
      Count  : size_t) return size_t
   with Import, Convention => C, External_Name => "sendfile";
   -- close(2)
   function C_Close (Fd : int) return int
   with Import, Convention => C, External_Name => "close";
   -- sockaddr_in (IPv4)
   type Sockaddr_In is record
      Sin_Family : Interfaces.C.unsigned_short;
      Sin_Port   : Interfaces.C.unsigned_short;
      Sin_Addr   : Interfaces.C.unsigned;       -- in_addr (s_addr)
      Sin_Zero   : Interfaces.C.char_array (0 .. 7);
   end record
   with Convention => C;
   -- Helpers
   procedure Handle_Connection (Client_FD : int) is
      -- TODO:
      --   1. read(Client_FD, ...) → raw HTTP request bytes
      --   2. parse request line → method + path
      --   3. open(path) → file_fd
      --   4. sendfile(Client_FD, file_fd, ...) → send bytes
      --   5. close(file_fd)
      --   6. close(Client_FD)
      Buf     : char_array (0 .. 4095);
      N_Read  : size_t;
      Ignored : int;
   begin
      N_Read := C_Read (Client_FD, Buf'Address, Buf'Length);
      pragma Unreferenced (N_Read);
      -- TODO: parse + respond
      Ignored := C_Close (Client_FD);
      pragma Unreferenced (Ignored);
   end Handle_Connection;
   -- Main
   -- Constants (POSIX / Linux x86-64)
   AF_INET     : constant int := 2;
   SOCK_STREAM : constant int := 1;
   SOL_SOCKET  : constant int := 1;
   SO_REUSEADDR: constant int := 2;
   O_RDONLY    : constant int := 0;
   INADDR_ANY  : constant Interfaces.C.unsigned := 0;
   -- htons — needed for port + sin_family byte order
   function Htons (Host : Interfaces.C.unsigned_short)
     return Interfaces.C.unsigned_short
   with Import, Convention => C, External_Name => "htons";
   Server_FD  : int;
   Client_FD  : int;
   Opt        : aliased int := 1;
   Addr       : aliased Sockaddr_In;
   Addr_Len   : aliased int := Sockaddr_In'Size / 8;
   Ret        : int;
   
begin
   -- 1. socket
   Server_FD := C_Socket (AF_INET, SOCK_STREAM, 0);
   pragma Assert (Server_FD >= 0);
   -- 2. setsockopt SO_REUSEADDR
   Ret := C_Setsockopt (Server_FD, SOL_SOCKET, SO_REUSEADDR,
                        Opt'Address, int (Opt'Size / 8));
   pragma Assert (Ret = 0);
   -- 3. bind
   Addr := (Sin_Family => Interfaces.C.unsigned_short (AF_INET),  -- host byte order
            Sin_Port   => Htons (Interfaces.C.unsigned_short (Port)),
            Sin_Addr   => INADDR_ANY,
            Sin_Zero   => (others => Interfaces.C.char'Val (0)));

   Ret := C_Bind (Server_FD, Addr'Address, Addr_Len);
   pragma Assert (Ret = 0);
   -- 4. listen
   Ret := C_Listen (Server_FD, Backlog);
   pragma Assert (Ret = 0);
   -- 5. accept loop
   loop
      Client_FD := C_Accept (Server_FD,
                              System.Null_Address,
                              System.Null_Address);
      if Client_FD >= 0 then
         Handle_Connection (Client_FD);
      end if;
   end loop;
end Spark_Http_Server;

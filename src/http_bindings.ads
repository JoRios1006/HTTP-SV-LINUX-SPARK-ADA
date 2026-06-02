-- http_bindings.ads
-- AGPL-3.0
--
-- Thin Ada bindings to the Linux socket/IO syscalls used by the HTTP server.
-- Every subprogram here maps 1-to-1 to a C function via the Import aspect;
-- no Ada logic lives in this file.
--
-- Return-value conventions (same as the underlying C calls):
--   socket / bind / listen / accept / setsockopt / close
--     => 0 on success, -1 on error (errno set)
--   read  => bytes read, 0 on EOF, size_t(-1) on error
--   write => bytes written, ptrdiff_t(-1) on error
--   sendfile => bytes sent, size_t(-1) on error

with Interfaces.C; use Interfaces.C;
with System;

package Http_Bindings is

   ---------------------------------------------------------------------------
   --  Data types
   ---------------------------------------------------------------------------

   --  IPv4 socket address — mirrors struct sockaddr_in from <netinet/in.h>.
   --  The Convention => C aspect guarantees the same memory layout as C.
   type Sockaddr_In is record
      Sin_Family : Interfaces.C.unsigned_short;   -- AF_INET
      Sin_Port   : Interfaces.C.unsigned_short;   -- port in network byte order
      Sin_Addr   : Interfaces.C.unsigned;         -- IPv4 address (struct in_addr)
      Sin_Zero   : Interfaces.C.char_array (0 .. 7); -- padding, must be zero
   end record
   with Convention => C;

   ---------------------------------------------------------------------------
   --  Byte-order conversion
   ---------------------------------------------------------------------------

   --  htons(3) — host-to-network short (converts port number to big-endian)
   function Htons (Host : Interfaces.C.unsigned_short)
     return Interfaces.C.unsigned_short
   with Import, Convention => C, External_Name => "htons";

   ---------------------------------------------------------------------------
   --  Socket lifecycle  (socket → setsockopt → bind → listen → accept)
   ---------------------------------------------------------------------------

   --  socket(2) — creates an endpoint for communication; returns a file descriptor
   function C_Socket
     (Domain   : int;   -- e.g. AF_INET
      Typ      : int;   -- e.g. SOCK_STREAM
      Protocol : int)   -- 0 = kernel chooses
     return int
   with Import, Convention => C, External_Name => "socket";

   --  setsockopt(2) — sets options on a socket (here used for SO_REUSEADDR)
   function C_Setsockopt
     (Sockfd  : int;
      Level   : int;            -- SOL_SOCKET
      Optname : int;            -- option to set (e.g. SO_REUSEADDR)
      Optval  : System.Address; -- pointer to option value
      Optlen  : int)            -- size of Optval in bytes
     return int
   with Import, Convention => C, External_Name => "setsockopt";

   --  bind(2) — assigns a local address/port to a socket
   function C_Bind
     (Sockfd  : int;
      Addr    : System.Address; -- pointer to struct sockaddr_in
      Addrlen : int)
     return int
   with Import, Convention => C, External_Name => "bind";

   --  listen(2) — marks the socket as passive (ready to accept connections)
   function C_Listen
     (Sockfd  : int;
      Backlog : int)  -- max length of the pending-connection queue
     return int
   with Import, Convention => C, External_Name => "listen";

   --  accept(2) — blocks until a client connects; returns a new file descriptor
   --  Addr / Addrlen are Null_Address here because we don't need the client IP.
   function C_Accept
     (Sockfd  : int;
      Addr    : System.Address;
      Addrlen : System.Address)
     return int
   with Import, Convention => C, External_Name => "accept";

   ---------------------------------------------------------------------------
   --  I/O
   ---------------------------------------------------------------------------

   --  read(2) — reads up to Count bytes from Fd into Buf
   function C_Read
     (Fd    : int;
      Buf   : System.Address;
      Count : size_t)
     return size_t
   with Import, Convention => C, External_Name => "read";

   --  write(2) — writes Count bytes from Buf to Fd
   function C_Write
     (Fd    : int;
      Buf   : System.Address;
      Count : size_t)
     return ptrdiff_t
   with Import, Convention => C, External_Name => "write";

   --  open(2) — opens a file; returns a file descriptor
   function C_Open
     (Pathname : char_array;
      Flags    : int)
     return int
   with Import, Convention => C, External_Name => "open";

   --  sendfile(2) — zero-copy transfer from In_FD to Out_FD
   function C_Sendfile
     (Out_FD : int;
      In_FD  : int;
      Offset : System.Address; -- null = start from current position
      Count  : size_t)
     return size_t
   with Import, Convention => C, External_Name => "sendfile";

   --  close(2) — releases a file descriptor
   function C_Close (Fd : int) return int
   with Import, Convention => C, External_Name => "close";

end Http_Bindings;

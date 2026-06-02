-- posix_constants.ads
-- AGPL-3.0
--
-- Numeric constants from POSIX / Linux x86-64 ABI.
-- These values are platform-specific (Linux x86-64).
-- On other systems, verify against <sys/socket.h>, <fcntl.h>, etc.

with Interfaces.C; use Interfaces.C;

package Posix_Constants is

   --  Address families (<sys/socket.h>)
   AF_INET     : constant int := 2;

   --  Socket types (<sys/socket.h>)
   SOCK_STREAM : constant int := 1;

   --  Socket-level option names (<sys/socket.h>)
   SOL_SOCKET  : constant int := 1;
   SO_REUSEADDR: constant int := 2;

   --  open(2) flags (<fcntl.h>)
   O_RDONLY    : constant int := 0;

   --  Wildcard local address — binds to all interfaces
   INADDR_ANY  : constant Interfaces.C.unsigned := 0;

end Posix_Constants;

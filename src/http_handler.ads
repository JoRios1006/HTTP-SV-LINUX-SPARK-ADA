-- http_handler.ads
-- AGPL-3.0
--
-- Public interface for handling a single HTTP connection.

with Interfaces.C; use Interfaces.C;

package Http_Handler is

   --  Reads the incoming HTTP request from Client_FD, sends a fixed HTTP/1.1
   --  200 response with an HTML payload, then closes the connection.
   procedure Handle_Connection (Client_FD : int);

end Http_Handler;

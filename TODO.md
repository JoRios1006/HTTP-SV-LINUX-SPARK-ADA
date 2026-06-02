
## Current
- [ ] Create `Send_Response` procedure
- [ ] Send literal string `HTTP/1.1 200 OK\r\n\r\n`
- [ ] Build project
- [ ] Run server
- [ ] Test with curl
# Core HTTP
## Socket Lifecycle

- [x] Create socket
- [x] Set SO_REUSEADDR
- [x] Bind socket
- [x] Listen on socket
- [x] Accept connection
- [x] Read request bytes
- [ ] Write response bytes
- [ ] Close client socket after response


## Minimal Response

- [ ] Define response buffer
- [ ] Add status line
- [ ] Add CRLF terminator
- [ ] Call write syscall
- [ ] Verify curl no longer shows Empty Reply
- [ ] Verify browser receives response


## Request Parsing

- [ ] Create request buffer constant size
- [ ] Locate first space
- [ ] Extract method
- [ ] Store method string
- [ ] Locate second space
- [ ] Extract path
- [ ] Store path string
- [ ] Extract HTTP version
- [ ] Print parsed values for debugging


## GET Validation

- [ ] Compare method against GET
- [ ] Return 405 for non-GET
- [ ] Test POST request
- [ ] Test invalid method


## Path Handling

- [ ] Detect `/`
- [ ] Map `/` -> `/index.html`
- [ ] Remove duplicate slashes
- [ ] Reject empty path
- [ ] Reject malformed path


## Security

- [ ] Detect `../`
- [ ] Reject traversal attempt
- [ ] Return 403 response
- [ ] Test traversal via curl


## File Opening

- [ ] Build full filesystem path
- [ ] Call open syscall
- [ ] Check open success
- [ ] Check open failure
- [ ] Log opened filename


## File Metadata

- [ ] Call stat syscall
- [ ] Read file size
- [ ] Store content length
- [ ] Verify length value


## HTTP Headers

- [ ] Create 200 response template
- [ ] Add Content-Length header
- [ ] Add Connection header
- [ ] Add blank line separator
- [ ] Send headers


## File Transfer

- [ ] Call sendfile
- [ ] Verify bytes transferred
- [ ] Close file descriptor
- [ ] Test small file
- [ ] Test large file


# Error Responses
## 400 Bad Request

- [ ] Create response template
- [ ] Send status line
- [ ] Send body
- [ ] Test malformed request


## 403 Forbidden

- [ ] Create response template
- [ ] Send body
- [ ] Test traversal request


## 404 Not Found

- [ ] Detect open failure
- [ ] Generate 404 response
- [ ] Send response
- [ ] Test missing file


## 405 Method Not Allowed

- [ ] Generate 405 response
- [ ] Test POST
- [ ] Test PUT


## 500 Internal Server Error

- [ ] Create template
- [ ] Send response on syscall failure
- [ ] Test failure path


# SPARK Verification
## Preconditions

- [ ] Add contract for request parser
- [ ] Add contract for path parser
- [ ] Add contract for send routine


## Proofs
- [ ] Run GNATprove
- [ ] Fix overflow warnings
- [ ] Fix range warnings
- [ ] Fix aliasing warnings
- [ ] Achieve clean proof


## Runtime Safety

- [ ] Eliminate runtime checks
- [ ] Verify buffer bounds
- [ ] Verify array accesses
- [ ] Verify string slicing


# Testing
## Curl

- [ ] GET /
- [ ] GET /index.html
- [ ] GET missing file
- [ ] POST request
- [ ] Traversal request


## Browser

- [ ] Open homepage
- [ ] Refresh page
- [ ] Open missing file


## Stress

- [ ] 10 sequential requests
- [ ] 100 sequential requests
- [ ] Verify no fd leaks


# Milestone v0.1

- [ ] Curl returns HTML
- [ ] Browser loads page
- [ ] 404 works
- [ ] 405 works
- [ ] No Empty Reply from Server


## Done

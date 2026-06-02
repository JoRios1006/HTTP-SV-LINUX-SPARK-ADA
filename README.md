# HTTP-SV-LINUX-SPARK-ADA

Minimal HTTP/1.1 server. Ada/SPARK. Raw Linux syscalls. Work in progress.

---

## Syscall Pipeline

```
socket → setsockopt → bind → listen → accept → read → open → sendfile → close
```

| Syscall | Purpose |
|---------|---------|
| `socket` | Create TCP socket (`AF_INET`, `SOCK_STREAM`) |
| `setsockopt` | Set `SO_REUSEADDR` — skip TIME_WAIT on restart |
| `bind` | Attach socket to addr:port |
| `listen` | Mark passive, set backlog queue |
| `accept` | Block → return client fd on connection |
| `read` | Consume HTTP request bytes from client fd |
| `open` | Open requested file → get file fd |
| `sendfile` | Zero-copy kernel transfer: file fd → client fd |
| `close` | Release client fd + file fd |

---

## Requirements

- [Alire](https://alire.ada.dev/) (`alr`)
- GNAT (Ada 2012+)
- GNATprove / SPARK Pro (for formal verification)
- Linux x86-64

---

## Build

```bash
alr build
```

---

## Run WIP

```bash
./_build/spark_http_server <port> <www_root>
# e.g.
./_build/spark_http_server 8080 ./share/spark_http_server
```

---

## Structure

```
spark_http_server/
├── alire.toml
├── spark_http_server.gpr
├── src/
│   └── spark_http_server.adb   ← everything here
└── share/
    └── spark_http_server/      ← static files root
```

All logic lives in `src/spark_http_server.adb`.

---

## Status
Work in progress — does not serve requests yet.

---

## License

[AGPL-3.0](LICENSE)

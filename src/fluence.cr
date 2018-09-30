require "../config/application"

Kemal.config.host_binding = Fluence::OPTIONS.host
Kemal.config.port = Fluence::OPTIONS.port

Kemal.run

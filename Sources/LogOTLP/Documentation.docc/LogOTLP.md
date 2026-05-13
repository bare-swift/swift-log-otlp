# ``LogOTLP``

OpenTelemetry OTLP/logs encoder over HTTP+protobuf — Sendable, Foundation-free.

## Overview

`LogOTLP` is the third OTLP signal package in the bare-swift ecosystem. It
extends the `OTLP` namespace from swift-otlp-exporter (metrics) and
swift-tracing-otlp (traces) with the log types defined by
`opentelemetry/proto/logs/v1/logs.proto` — `LogRecord`, `SeverityNumber`,
`ScopeLogs`, `ResourceLogs`, and `ExportLogsServiceRequest`.

Common types (`Resource`, `InstrumentationScope`, `KeyValue`, `AnyValue`)
are re-used from `OTLPExporter` so the three signal packages share a
single vocabulary. The proto3 wire writer is duplicated internally per the
RFC-0007 anchor decision — the wire format is stable and inlining keeps
the dependency graph flat.

`OTLP.encodeLogs(_:)` is the entry point: pass an
`ExportLogsServiceRequest`, get back `Bytes` ready for
`HTTP POST /v1/logs` with `Content-Type: application/x-protobuf`.

```swift
import OTLPExporter
import LogOTLP
import Bytes

let request = OTLP.ExportLogsServiceRequest(
    resourceLogs: [
        OTLP.ResourceLogs(
            resource: OTLP.Resource(attributes: [
                .init(key: "service.name", value: .string("checkout"))
            ]),
            scopeLogs: [
                OTLP.ScopeLogs(
                    scope: OTLP.InstrumentationScope(name: "checkout-handler"),
                    logRecords: [
                        OTLP.LogRecord(
                            timeUnixNano: 1_700_000_000_000_000_000,
                            severityNumber: .info,
                            severityText: "INFO",
                            body: .string("payment received"),
                            attributes: [.init(key: "order.id", value: .string("o-1"))]
                        )
                    ]
                )
            ]
        )
    ]
)

let payload: Bytes = OTLP.encodeLogs(request)
// → POST /v1/logs with Content-Type: application/x-protobuf
```

The encoder entry point is `OTLP.encodeLogs(_:)`, defined as a static
method on the `OTLP` namespace re-exported from swift-otlp-exporter.

## Topics

### Cross-signal correlation

`OTLP.LogRecord` accepts an `OTLP.TraceContext` (from swift-tracing-otlp) to fill `traceID` / `spanID` / `flags` in one call. See the README for usage.

### Essentials

- ``LogOTLPError``

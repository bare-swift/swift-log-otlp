# swift-log-otlp

OpenTelemetry OTLP/logs encoder over HTTP+protobuf — Sendable, Foundation-free; outputs `Bytes` ready for HTTP POST.

Part of the [bare-swift](https://github.com/bare-swift) ecosystem.

## Install

Add to your `Package.swift`:

```swift
.package(url: "https://github.com/bare-swift/swift-log-otlp.git", from: "0.3.0")
```

Then depend on the `LogOTLP` product:

```swift
.product(name: "LogOTLP", package: "swift-log-otlp")
```

## Usage

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

## Cross-signal correlation

Since v0.3, `OTLP.LogRecord` accepts an `OTLP.TraceContext` (from [swift-tracing-otlp](https://github.com/bare-swift/swift-tracing-otlp)) to fill the W3C trace correlation fields in one shot:

```swift
import LogOTLP
import TracingOTLP
import OTLPExporter

let ctx = OTLP.TraceContext.parse(
    traceparent: "00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01"
)!

let record = OTLP.LogRecord(
    timeUnixNano: 1_700_000_000_000_000_000,
    severityNumber: .info,
    body: .string("user logged in"),
    traceContext: ctx
)
// record.traceID, .spanID populated; record.flags == 0x01
```

Per the OTLP spec, the low 8 bits of `LogRecord.flags` carry the W3C `traceFlags` byte; the convenience init sets that mapping for you.

## Scope

Third OTLP signal package in the bare-swift ecosystem; companion to:

- swift-otlp-exporter (metrics signal)
- swift-tracing-otlp (traces signal)

The `OTLP` namespace is shared. Common types (`Resource`, `KeyValue`, `AnyValue`, `InstrumentationScope`) live in swift-otlp-exporter and are re-used. This package adds:

- `OTLP.LogRecord`, `OTLP.SeverityNumber` (24-step), `OTLP.ScopeLogs`, `OTLP.ResourceLogs`, `OTLP.ExportLogsServiceRequest`.
- `OTLP.encodeLogs(_:) -> Bytes`.
- Trace correlation fields (`traceID`, `spanID`, `flags`) and the recent `eventName` field (logs.proto field 12).

Out of scope for v0.1:

- gRPC transport (HTTP+protobuf only — same constraint as the other signal packages).
- JSON OTLP. Defer to v0.2.
- A logging API. This package is the *encoder*; bridges from swift-log or other logging frontends are downstream.
- Date parsing / clock helpers. Time fields are `UInt64` Unix-nanos; producers supply them directly.

## Documentation

Full DocC documentation: <https://bare-swift.github.io/swift-log-otlp/>

## Source

No upstream Rust crate; this is a native bare-swift package implementing the OpenTelemetry OTLP wire format directly.

## License

Apache 2.0 with LLVM exception. See [LICENSE](./LICENSE) and [NOTICE](./NOTICE).

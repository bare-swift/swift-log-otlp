# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.2.0] - 2026-05-10

### Added
- `OTLP.LogRecord.init(time: Time.Instant, observedTime: Time.Instant?, ...)` — convenience initializer accepting `Time.Instant` for the timestamp fields.
- `OTLP.LogRecord.time` / `OTLP.LogRecord.observedTime` computed properties returning `Time.Instant`.
- 4 new tests covering wire-field translation, getter round-trip, both-field initialization, and negative-instant clamping.

### Dependencies
- New: `swift-time` 0.1.0 — for the `Time.Instant` type used by the helpers.

### Migration
- Additive only. The existing `timeUnixNano: UInt64` / `observedTimeUnixNano: UInt64` fields and the canonical `init(...)` continue to work unchanged. Negative `Time.Instant` values clamp to `0` on the wire (pre-1970 log records don't occur in real exporter data).

## [0.1.0] - 2026-05-09

### Added
- `OTLP.LogRecord`, `OTLP.SeverityNumber` (24-step enum from `unspecified` through `fatal4`), `OTLP.ScopeLogs`, `OTLP.ResourceLogs`, and `OTLP.ExportLogsServiceRequest` value types — Sendable, Equatable.
- `OTLP.encodeLogs(_:) -> Bytes` — protobuf wire-format encoder over HTTP+protobuf for `POST /v1/logs` with `Content-Type: application/x-protobuf`.
- Trace correlation fields on `LogRecord` (`traceID`, `spanID`, `flags`) plus the recent `eventName` field (logs.proto field 12).
- `LogOTLPError` typed-throws extension point (no cases in v0.1).

### Dependencies
- `swift-bytes` 0.1.0 — output buffer.
- `swift-varint` 0.1.0 — protobuf varint encoding.
- `swift-otlp-exporter` 0.1.0 — shared `OTLP` namespace (`Resource`, `KeyValue`, `AnyValue`, `InstrumentationScope`).

### Limitations (out of scope for v0.1)
- gRPC transport. HTTP+protobuf only — same constraint as swift-otlp-exporter and swift-tracing-otlp.
- JSON OTLP. Defer to v0.2.
- Logging-frontend bridges (swift-log, swift-distributed-tracing log adapter, etc.). This package is the encoder; bridge packages live downstream.

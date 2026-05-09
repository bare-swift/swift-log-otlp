# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

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

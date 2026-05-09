// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Copyright (c) 2026 The bare-swift Project Authors.

/// Sendable, Foundation-free OpenTelemetry OTLP encoder for logs over HTTP+protobuf.
///
/// Companion to swift-otlp-exporter (metrics signal) and swift-tracing-otlp
/// (traces signal). The `OTLP` namespace is defined by swift-otlp-exporter;
/// this package extends it with log-specific types (`OTLP.LogRecord`,
/// `OTLP.SeverityNumber`, `OTLP.ScopeLogs`, `OTLP.ResourceLogs`,
/// `OTLP.ExportLogsServiceRequest`) and re-uses the common types
/// `OTLP.Resource`, `OTLP.InstrumentationScope`, `OTLP.KeyValue`,
/// `OTLP.AnyValue`.
///
/// See `OTLP.encodeLogs(_:)` for the entry point.
public enum LogOTLP: Sendable {}

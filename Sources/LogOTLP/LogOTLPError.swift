// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Copyright (c) 2026 The bare-swift Project Authors.

/// Errors thrown by `OTLP.encodeLogs(_:)` and related encoders.
///
/// **v0.1: this enum has no cases.** Encoding is total — every well-formed
/// `ExportLogsServiceRequest` produces a valid protobuf payload. The type
/// exists as a forward-compatible extension point for v0.2 size-cap or
/// resource-limit checks. Mirrors `OTLPError` and `TracingOTLPError`.
public enum LogOTLPError: Error, Equatable, Sendable {}

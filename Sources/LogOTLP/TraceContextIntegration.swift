// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Copyright (c) 2026 The bare-swift Project Authors.

import Bytes
import OTLPExporter
import TracingOTLP

/// swift-tracing-otlp integration for OTLP log records.
///
/// `OTLP.TraceContext` (defined in swift-tracing-otlp) is the W3C Trace
/// Context propagation value used to thread trace IDs across HTTP
/// boundaries. OTLP cross-signal correlation requires the same trace ID,
/// span ID, and trace-flags byte to appear on each `LogRecord` emitted
/// in the scope of a span. This initializer fills those fields from a
/// single `TraceContext` value to avoid repetitive plumbing at call
/// sites.
///
/// Per OTLP convention, the low 8 bits of `LogRecord.flags` carry the
/// W3C `traceFlags` byte. The high 24 bits are reserved; this init
/// leaves them zero.
extension OTLP.LogRecord {
    /// Convenience initializer that fills `traceID`, `spanID`, and
    /// `flags` from an `OTLP.TraceContext`.
    public init(
        timeUnixNano: UInt64 = 0,
        observedTimeUnixNano: UInt64 = 0,
        severityNumber: OTLP.SeverityNumber = .unspecified,
        severityText: String = "",
        body: OTLP.AnyValue? = nil,
        attributes: [OTLP.KeyValue] = [],
        droppedAttributesCount: UInt32 = 0,
        traceContext: OTLP.TraceContext,
        eventName: String = ""
    ) {
        self.init(
            timeUnixNano: timeUnixNano,
            observedTimeUnixNano: observedTimeUnixNano,
            severityNumber: severityNumber,
            severityText: severityText,
            body: body,
            attributes: attributes,
            droppedAttributesCount: droppedAttributesCount,
            flags: UInt32(traceContext.traceFlags),
            traceID: traceContext.traceID,
            spanID: traceContext.spanID,
            eventName: eventName
        )
    }
}

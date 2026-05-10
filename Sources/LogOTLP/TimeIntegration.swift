// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Copyright (c) 2026 The bare-swift Project Authors.

import Bytes
import OTLPExporter
import Time

/// swift-time integration for OTLP log types. The wire-format fields
/// (`timeUnixNano`, `observedTimeUnixNano`) remain `UInt64` for proto3
/// compatibility; these helpers translate to/from `Time.Instant` at the
/// boundary.
///
/// `Time.Instant` is signed `Int64` (pre-1970 representable). OTLP's
/// `UInt64` cannot represent negative nanos, so the conversion clamps
/// negative inputs to 0 — pre-1970 log records don't appear in real
/// log-exporter data and would corrupt downstream collectors if
/// encoded naively as bit patterns.
extension OTLP.LogRecord {
    /// Convenience initializer accepting `Time.Instant` for `time` and
    /// (optionally) `observedTime`.
    public init(
        time instant: Time.Instant,
        observedTime: Time.Instant? = nil,
        severityNumber: OTLP.SeverityNumber = .unspecified,
        severityText: String = "",
        body: OTLP.AnyValue? = nil,
        attributes: [OTLP.KeyValue] = [],
        droppedAttributesCount: UInt32 = 0,
        flags: UInt32 = 0,
        traceID: Bytes = Bytes(),
        spanID: Bytes = Bytes(),
        eventName: String = ""
    ) {
        self.init(
            timeUnixNano: instantToWireNano(instant),
            observedTimeUnixNano: observedTime.map(instantToWireNano) ?? 0,
            severityNumber: severityNumber,
            severityText: severityText,
            body: body,
            attributes: attributes,
            droppedAttributesCount: droppedAttributesCount,
            flags: flags,
            traceID: traceID,
            spanID: spanID,
            eventName: eventName
        )
    }

    /// Wall-clock instant when the log record was emitted.
    public var time: Time.Instant {
        Time.Instant(nanosecondsSinceEpoch: Int64(bitPattern: timeUnixNano))
    }

    /// Wall-clock instant when the log record was observed by the
    /// collection pipeline (typically equal to or slightly later than
    /// ``time``).
    public var observedTime: Time.Instant {
        Time.Instant(nanosecondsSinceEpoch: Int64(bitPattern: observedTimeUnixNano))
    }
}

@inline(__always)
private func instantToWireNano(_ instant: Time.Instant) -> UInt64 {
    instant.nanosecondsSinceEpoch < 0 ? 0 : UInt64(instant.nanosecondsSinceEpoch)
}

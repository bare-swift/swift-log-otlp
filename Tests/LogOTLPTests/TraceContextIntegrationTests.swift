// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Copyright (c) 2026 The bare-swift Project Authors.

import Bytes
import OTLPExporter
import Testing
import TracingOTLP
@testable import LogOTLP

@Suite("OTLP.LogRecord traceContext convenience init")
struct TraceContextIntegrationTests {
    private static let canonicalTraceID = Bytes([
        0x4b, 0xf9, 0x2f, 0x35, 0x77, 0xb3, 0x4d, 0xa6,
        0xa3, 0xce, 0x92, 0x9d, 0x0e, 0x0e, 0x47, 0x36
    ])
    private static let canonicalSpanID = Bytes([
        0x00, 0xf0, 0x67, 0xaa, 0x0b, 0xa9, 0x02, 0xb7
    ])

    @Test("traceContext init fills traceID/spanID/flags from the context")
    func fillsCorrelationFields() {
        let ctx = OTLP.TraceContext(
            traceID: Self.canonicalTraceID,
            spanID: Self.canonicalSpanID,
            traceFlags: 0x01
        )
        let record = OTLP.LogRecord(
            timeUnixNano: 1_700_000_000_000_000_000,
            severityNumber: .info,
            body: .string("hello"),
            traceContext: ctx
        )
        #expect(record.traceID == Self.canonicalTraceID)
        #expect(record.spanID == Self.canonicalSpanID)
        #expect(record.flags == 0x01)
        #expect(record.timeUnixNano == 1_700_000_000_000_000_000)
        #expect(record.severityNumber == .info)
        #expect(record.body == .string("hello"))
    }
}

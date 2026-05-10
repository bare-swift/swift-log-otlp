// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import LogOTLP
import OTLPExporter
import Time

@Suite("Time integration on OTLP.LogRecord")
struct LogRecordTimeIntegrationTests {
    @Test("init(time:) translates to UInt64 wire field")
    func initWithInstant() {
        let i = Time.Instant(nanosecondsSinceEpoch: 1_700_000_000_000_000_000)
        let r = OTLP.LogRecord(time: i, severityNumber: .info)
        #expect(r.timeUnixNano == 1_700_000_000_000_000_000)
        #expect(r.observedTimeUnixNano == 0)
        #expect(r.severityNumber == .info)
    }

    @Test("init(time:observedTime:) sets both fields")
    func initWithBoth() {
        let t = Time.Instant(nanosecondsSinceEpoch: 1_700_000_000_000_000_000)
        let o = Time.Instant(nanosecondsSinceEpoch: 1_700_000_000_001_000_000)
        let r = OTLP.LogRecord(time: t, observedTime: o, severityNumber: .warn)
        #expect(r.timeUnixNano == 1_700_000_000_000_000_000)
        #expect(r.observedTimeUnixNano == 1_700_000_000_001_000_000)
    }

    @Test(".time / .observedTime getters round-trip")
    func gettersRoundTrip() {
        let r = OTLP.LogRecord(
            timeUnixNano: 42_000_000_000,
            observedTimeUnixNano: 43_000_000_000
        )
        #expect(r.time.nanosecondsSinceEpoch == 42_000_000_000)
        #expect(r.observedTime.nanosecondsSinceEpoch == 43_000_000_000)
    }

    @Test("negative Instants clamp to 0 (pre-1970 logs)")
    func negativeClamps() {
        let r = OTLP.LogRecord(time: Time.Instant(nanosecondsSinceEpoch: -1_000_000_000))
        #expect(r.timeUnixNano == 0)
    }
}

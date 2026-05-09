// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import LogOTLP
import OTLPExporter
import Bytes

@Suite("Public types")
struct PublicTypesTests {
    @Test("LogRecord defaults")
    func logRecordDefaults() {
        let r = OTLP.LogRecord()
        #expect(r.timeUnixNano == 0)
        #expect(r.observedTimeUnixNano == 0)
        #expect(r.severityNumber == .unspecified)
        #expect(r.severityText == "")
        #expect(r.body == nil)
        #expect(r.attributes.isEmpty)
        #expect(r.droppedAttributesCount == 0)
        #expect(r.flags == 0)
        #expect(r.traceID.isEmpty)
        #expect(r.spanID.isEmpty)
        #expect(r.eventName == "")
    }

    @Test("SeverityNumber raw values cover the OTLP enum range 0...24")
    func severityRawValues() {
        #expect(OTLP.SeverityNumber.unspecified.rawValue == 0)
        #expect(OTLP.SeverityNumber.trace.rawValue == 1)
        #expect(OTLP.SeverityNumber.debug.rawValue == 5)
        #expect(OTLP.SeverityNumber.info.rawValue == 9)
        #expect(OTLP.SeverityNumber.warn.rawValue == 13)
        #expect(OTLP.SeverityNumber.error.rawValue == 17)
        #expect(OTLP.SeverityNumber.fatal.rawValue == 21)
        #expect(OTLP.SeverityNumber.fatal4.rawValue == 24)
    }

    @Test("ExportLogsServiceRequest is Equatable")
    func equatable() {
        let a = OTLP.ExportLogsServiceRequest(resourceLogs: [])
        let b = OTLP.ExportLogsServiceRequest(resourceLogs: [])
        #expect(a == b)
    }
}

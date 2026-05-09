// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import LogOTLP
import OTLPExporter
import Bytes

@Suite("EncodeLogs")
struct EncodeLogsTests {
    @Test("empty LogRecord encodes to empty Bytes (all-default proto3)")
    func emptyLogRecord() {
        let bytes = EncodeLogs.encodeLogRecord(OTLP.LogRecord())
        #expect(bytes.isEmpty)
    }

    @Test("LogRecord with severity_number emits varint tag for field 2")
    func severityNumberField() {
        let r = OTLP.LogRecord(severityNumber: .info)
        let bytes = EncodeLogs.encodeLogRecord(r)
        // Field 2 / varint = (2 << 3) | 0 = 0x10
        #expect(bytes.storage.first == 0x10)
        // Followed by the varint value 9 (info).
        #expect(bytes.storage.count >= 2)
        #expect(bytes.storage[1] == 9)
    }

    @Test("LogRecord with timeUnixNano emits fixed64 tag for field 1")
    func timeField() {
        let r = OTLP.LogRecord(timeUnixNano: 0x0102030405060708)
        let bytes = EncodeLogs.encodeLogRecord(r)
        // Field 1 / i64 = (1 << 3) | 1 = 0x09
        #expect(bytes.storage.first == 0x09)
        // 8 little-endian bytes for the value follow the 1-byte tag.
        #expect(bytes.storage.count == 1 + 8)
        let valueBytes = Array(bytes.storage[1..<9])
        #expect(valueBytes == [0x08, 0x07, 0x06, 0x05, 0x04, 0x03, 0x02, 0x01])
    }

    @Test("LogRecord with body string encodes as field-5 message")
    func bodyString() {
        let r = OTLP.LogRecord(body: .string("hello"))
        let bytes = EncodeLogs.encodeLogRecord(r)
        // Field 5 / len = (5 << 3) | 2 = 0x2A
        #expect(bytes.storage.first == 0x2A)
    }

    @Test("LogRecord with traceID/spanID at fields 9 and 10")
    func traceCorrelation() {
        let r = OTLP.LogRecord(
            traceID: Bytes(repeating: 0xAA, count: 16),
            spanID:  Bytes(repeating: 0xBB, count: 8)
        )
        let bytes = EncodeLogs.encodeLogRecord(r)
        // Should contain both field-9 (0x4A) and field-10 (0x52) tags.
        #expect(bytes.storage.contains(0x4A))
        #expect(bytes.storage.contains(0x52))
    }

    @Test("LogRecord with observedTimeUnixNano at field 11 (out-of-order proto field)")
    func observedTime() {
        let r = OTLP.LogRecord(observedTimeUnixNano: 42)
        let bytes = EncodeLogs.encodeLogRecord(r)
        // Field 11 / i64 = (11 << 3) | 1 = 0x59
        #expect(bytes.storage.first == 0x59)
    }

    @Test("LogRecord with eventName at field 12")
    func eventName() {
        let r = OTLP.LogRecord(eventName: "click")
        let bytes = EncodeLogs.encodeLogRecord(r)
        // Field 12 / len = (12 << 3) | 2 = 0x62
        #expect(bytes.storage.first == 0x62)
    }

    @Test("LogRecord with attributes emits repeated field-6 messages")
    func attributesRepeated() {
        let r = OTLP.LogRecord(attributes: [
            .init(key: "a", value: .int(1)),
            .init(key: "b", value: .int(2)),
        ])
        let bytes = EncodeLogs.encodeLogRecord(r)
        // Field 6 / len = (6 << 3) | 2 = 0x32
        let count = bytes.storage.filter { $0 == 0x32 }.count
        #expect(count >= 2)
    }

    @Test("ScopeLogs wraps records under field 2 and scope under field 1")
    func scopeLogs() {
        let sl = OTLP.ScopeLogs(
            scope: OTLP.InstrumentationScope(name: "checkout"),
            logRecords: [OTLP.LogRecord(severityNumber: .info)]
        )
        let bytes = EncodeLogs.encodeScopeLogs(sl)
        #expect(bytes.storage.contains(0x0A)) // field 1 (scope) tag
        #expect(bytes.storage.contains(0x12)) // field 2 (log_records) tag
    }

    @Test("ResourceLogs wraps scope under field 2 and resource under field 1")
    func resourceLogs() {
        let rl = OTLP.ResourceLogs(
            resource: OTLP.Resource(attributes: [
                .init(key: "service.name", value: .string("svc"))
            ]),
            scopeLogs: [OTLP.ScopeLogs(
                scope: OTLP.InstrumentationScope(name: "x"),
                logRecords: [OTLP.LogRecord(severityNumber: .info)]
            )]
        )
        let bytes = EncodeLogs.encodeResourceLogs(rl)
        #expect(bytes.storage.contains(0x0A))
        #expect(bytes.storage.contains(0x12))
    }

    @Test("ExportLogsServiceRequest wraps ResourceLogs under field 1")
    func exportRequest() {
        let req = OTLP.ExportLogsServiceRequest(resourceLogs: [
            OTLP.ResourceLogs(
                scopeLogs: [OTLP.ScopeLogs(
                    logRecords: [OTLP.LogRecord(body: .string("ok"))]
                )]
            )
        ])
        let bytes = OTLP.encodeLogs(req)
        #expect(!bytes.isEmpty)
        #expect(bytes.storage.first == 0x0A)  // field 1 / len
    }

    @Test("Empty ExportLogsServiceRequest encodes to empty Bytes")
    func emptyRequest() {
        let bytes = OTLP.encodeLogs(OTLP.ExportLogsServiceRequest())
        #expect(bytes.isEmpty)
    }
}

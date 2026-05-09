// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import LogOTLP
import OTLPExporter
import Bytes

@Suite("End-to-end")
struct EndToEndTests {
    @Test("realistic ExportLogsServiceRequest encodes to non-empty Bytes")
    func realistic() {
        let req = OTLP.ExportLogsServiceRequest(
            resourceLogs: [
                OTLP.ResourceLogs(
                    resource: OTLP.Resource(attributes: [
                        .init(key: "service.name",    value: .string("checkout")),
                        .init(key: "service.version", value: .string("1.0.0")),
                    ]),
                    scopeLogs: [
                        OTLP.ScopeLogs(
                            scope: OTLP.InstrumentationScope(name: "checkout-handler", version: "2.3.0"),
                            logRecords: [
                                OTLP.LogRecord(
                                    timeUnixNano: 1_700_000_000_000_000_000,
                                    observedTimeUnixNano: 1_700_000_000_001_000_000,
                                    severityNumber: .info,
                                    severityText: "INFO",
                                    body: .string("payment received"),
                                    attributes: [
                                        .init(key: "order.id", value: .string("o-1")),
                                        .init(key: "amount",   value: .double(99.95)),
                                    ],
                                    traceID: Bytes(repeating: 0xAA, count: 16),
                                    spanID:  Bytes(repeating: 0xBB, count: 8)
                                ),
                                OTLP.LogRecord(
                                    timeUnixNano: 1_700_000_000_500_000_000,
                                    severityNumber: .warn,
                                    severityText: "WARN",
                                    body: .string("retrying"),
                                    attributes: [.init(key: "attempt", value: .int(2))]
                                ),
                            ]
                        )
                    ]
                )
            ]
        )

        let payload = OTLP.encodeLogs(req)
        #expect(!payload.isEmpty)
        // Top-level field 1 (resource_logs) tag is 0x0A.
        #expect(payload.storage.first == 0x0A)
        // Should be reasonably-sized for two log records with attributes.
        #expect(payload.count > 100)
    }

    @Test("multi-resource request: two ResourceLogs in one payload")
    func multiResource() {
        let r1 = OTLP.ResourceLogs(
            resource: OTLP.Resource(attributes: [.init(key: "service.name", value: .string("a"))]),
            scopeLogs: [.init(logRecords: [.init(severityNumber: .info)])]
        )
        let r2 = OTLP.ResourceLogs(
            resource: OTLP.Resource(attributes: [.init(key: "service.name", value: .string("b"))]),
            scopeLogs: [.init(logRecords: [.init(severityNumber: .error)])]
        )
        let payload = OTLP.encodeLogs(OTLP.ExportLogsServiceRequest(resourceLogs: [r1, r2]))
        // Two top-level field-1 tags expected.
        let topLevelTags = payload.storage.filter { $0 == 0x0A }.count
        #expect(topLevelTags >= 2)
    }
}

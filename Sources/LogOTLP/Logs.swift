// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Copyright (c) 2026 The bare-swift Project Authors.

import Bytes
import OTLPExporter

extension OTLP {
    /// `opentelemetry.proto.logs.v1.SeverityNumber`. The four-step
    /// granularity (TRACE, TRACE2, TRACE3, TRACE4) lets producers convey
    /// sub-level intensity within a band.
    public enum SeverityNumber: UInt32, Sendable, Equatable {
        case unspecified = 0
        case trace  = 1
        case trace2 = 2
        case trace3 = 3
        case trace4 = 4
        case debug  = 5
        case debug2 = 6
        case debug3 = 7
        case debug4 = 8
        case info   = 9
        case info2  = 10
        case info3  = 11
        case info4  = 12
        case warn   = 13
        case warn2  = 14
        case warn3  = 15
        case warn4  = 16
        case error  = 17
        case error2 = 18
        case error3 = 19
        case error4 = 20
        case fatal  = 21
        case fatal2 = 22
        case fatal3 = 23
        case fatal4 = 24
    }

    /// `opentelemetry.proto.logs.v1.LogRecord`.
    public struct LogRecord: Sendable, Equatable {
        public var timeUnixNano: UInt64
        public var observedTimeUnixNano: UInt64
        public var severityNumber: SeverityNumber
        public var severityText: String
        public var body: AnyValue?
        public var attributes: [KeyValue]
        public var droppedAttributesCount: UInt32
        public var flags: UInt32
        public var traceID: Bytes
        public var spanID: Bytes
        public var eventName: String

        public init(
            timeUnixNano: UInt64 = 0,
            observedTimeUnixNano: UInt64 = 0,
            severityNumber: SeverityNumber = .unspecified,
            severityText: String = "",
            body: AnyValue? = nil,
            attributes: [KeyValue] = [],
            droppedAttributesCount: UInt32 = 0,
            flags: UInt32 = 0,
            traceID: Bytes = Bytes(),
            spanID: Bytes = Bytes(),
            eventName: String = ""
        ) {
            self.timeUnixNano = timeUnixNano
            self.observedTimeUnixNano = observedTimeUnixNano
            self.severityNumber = severityNumber
            self.severityText = severityText
            self.body = body
            self.attributes = attributes
            self.droppedAttributesCount = droppedAttributesCount
            self.flags = flags
            self.traceID = traceID
            self.spanID = spanID
            self.eventName = eventName
        }
    }

    /// `opentelemetry.proto.logs.v1.ScopeLogs`.
    public struct ScopeLogs: Sendable, Equatable {
        public var scope: InstrumentationScope
        public var logRecords: [LogRecord]
        public var schemaURL: String

        public init(
            scope: InstrumentationScope = InstrumentationScope(),
            logRecords: [LogRecord] = [],
            schemaURL: String = ""
        ) {
            self.scope = scope
            self.logRecords = logRecords
            self.schemaURL = schemaURL
        }
    }

    /// `opentelemetry.proto.logs.v1.ResourceLogs`.
    public struct ResourceLogs: Sendable, Equatable {
        public var resource: Resource
        public var scopeLogs: [ScopeLogs]
        public var schemaURL: String

        public init(
            resource: Resource = Resource(),
            scopeLogs: [ScopeLogs] = [],
            schemaURL: String = ""
        ) {
            self.resource = resource
            self.scopeLogs = scopeLogs
            self.schemaURL = schemaURL
        }
    }

    /// `opentelemetry.proto.collector.logs.v1.ExportLogsServiceRequest`.
    public struct ExportLogsServiceRequest: Sendable, Equatable {
        public var resourceLogs: [ResourceLogs]
        public init(resourceLogs: [ResourceLogs] = []) {
            self.resourceLogs = resourceLogs
        }
    }
}

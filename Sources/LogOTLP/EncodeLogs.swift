// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Copyright (c) 2026 The bare-swift Project Authors.

import Bytes
import OTLPExporter

/// Internal per-message encoders for OTLP logs.v1. Each function produces the
/// inner protobuf payload for one OTLP message; callers wrap with tag+length
/// when embedding (via `ProtoWriter.writeMessage`).
///
/// Field numbers come from `opentelemetry/proto/logs/v1/logs.proto`. Field 4
/// in `LogRecord` was deprecated and is intentionally not encoded.
enum EncodeLogs {
    // MARK: - LogRecord
    static func encodeLogRecord(_ r: OTLP.LogRecord) -> Bytes {
        var w = ProtoWriter()
        // field 1 time_unix_nano (fixed64)
        w.writeFixed64(r.timeUnixNano, fieldNumber: 1)
        // field 2 severity_number (enum)
        w.writeEnum(r.severityNumber.rawValue, fieldNumber: 2)
        // field 3 severity_text (string)
        w.writeString(r.severityText, fieldNumber: 3)
        // field 4 deprecated — skipped.
        // field 5 body (AnyValue, message)
        if let body = r.body {
            let bodyBytes = EncodeCommon.encodeAnyValue(body)
            w.writeMessage(bodyBytes, fieldNumber: 5)
        }
        // field 6 attributes (repeated KeyValue)
        for kv in r.attributes {
            let kvb = EncodeCommon.encodeKeyValue(kv)
            w.writeMessage(kvb, fieldNumber: 6)
        }
        // field 7 dropped_attributes_count (uint32)
        w.writeUInt32(r.droppedAttributesCount, fieldNumber: 7)
        // field 8 flags (fixed32)
        w.writeFixed32(r.flags, fieldNumber: 8)
        // field 9 trace_id (bytes)
        w.writeBytes(r.traceID, fieldNumber: 9)
        // field 10 span_id (bytes)
        w.writeBytes(r.spanID, fieldNumber: 10)
        // field 11 observed_time_unix_nano (fixed64)
        w.writeFixed64(r.observedTimeUnixNano, fieldNumber: 11)
        // field 12 event_name (string)
        w.writeString(r.eventName, fieldNumber: 12)
        return w.finish()
    }

    // MARK: - ScopeLogs
    static func encodeScopeLogs(_ sl: OTLP.ScopeLogs) -> Bytes {
        var w = ProtoWriter()
        // field 1 scope (message); omit if empty
        let scopeBytes = EncodeCommon.encodeInstrumentationScope(sl.scope)
        if !scopeBytes.isEmpty {
            w.writeMessage(scopeBytes, fieldNumber: 1)
        }
        // field 2 log_records (repeated)
        for r in sl.logRecords {
            let rb = encodeLogRecord(r)
            w.writeMessage(rb, fieldNumber: 2)
        }
        // field 3 schema_url
        w.writeString(sl.schemaURL, fieldNumber: 3)
        return w.finish()
    }

    // MARK: - ResourceLogs
    static func encodeResourceLogs(_ rl: OTLP.ResourceLogs) -> Bytes {
        var w = ProtoWriter()
        // field 1 resource (message); omit if empty
        let resourceBytes = EncodeCommon.encodeResource(rl.resource)
        if !resourceBytes.isEmpty {
            w.writeMessage(resourceBytes, fieldNumber: 1)
        }
        // field 2 scope_logs (repeated)
        for sl in rl.scopeLogs {
            let slb = encodeScopeLogs(sl)
            w.writeMessage(slb, fieldNumber: 2)
        }
        // field 3 schema_url
        w.writeString(rl.schemaURL, fieldNumber: 3)
        return w.finish()
    }

    // MARK: - ExportLogsServiceRequest
    static func encodeExportLogsServiceRequest(
        _ req: OTLP.ExportLogsServiceRequest
    ) -> Bytes {
        var w = ProtoWriter()
        // field 1 resource_logs (repeated)
        for rl in req.resourceLogs {
            let rlb = encodeResourceLogs(rl)
            w.writeMessage(rlb, fieldNumber: 1)
        }
        return w.finish()
    }
}

// MARK: - Public entry point

extension OTLP {
    /// Encode an `ExportLogsServiceRequest` to its protobuf wire form.
    /// The returned `Bytes` is the body for `HTTP POST /v1/logs` with
    /// `Content-Type: application/x-protobuf`.
    public static func encodeLogs(_ request: ExportLogsServiceRequest) -> Bytes {
        EncodeLogs.encodeExportLogsServiceRequest(request)
    }
}

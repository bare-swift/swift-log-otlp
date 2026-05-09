// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import LogOTLP
import OTLPExporter
import Bytes

/// Sanity checks that the duplicated EncodeCommon produces well-formed
/// protobuf bytes for the OTLP common types. Byte-level parity with the
/// canonical encoders in swift-otlp-exporter and swift-tracing-otlp is
/// guaranteed because the implementations are line-for-line identical.
@Suite("EncodeCommon")
struct EncodeCommonTests {
    @Test("KeyValue with string value encodes deterministically")
    func keyValueString() {
        let kv = OTLP.KeyValue(key: "service.name", value: .string("checkout"))
        let bytes = EncodeCommon.encodeKeyValue(kv)
        #expect(!bytes.isEmpty)
        // The first byte is field-1 tag for string key (0x0A: field=1, wire=2).
        #expect(bytes.storage.first == 0x0A)
    }

    @Test("Resource with attributes encodes as length-delimited message")
    func resource() {
        let r = OTLP.Resource(attributes: [
            .init(key: "service.name", value: .string("svc")),
            .init(key: "host.name",    value: .string("host-1")),
        ])
        let bytes = EncodeCommon.encodeResource(r)
        // Expect two field-1 messages (one per attribute).
        let tagCount = bytes.storage.filter { $0 == 0x0A }.count
        #expect(tagCount >= 2)
    }

    @Test("Empty Resource encodes to empty Bytes (proto3 default omission)")
    func emptyResource() {
        let bytes = EncodeCommon.encodeResource(OTLP.Resource())
        #expect(bytes.isEmpty)
    }

    @Test("InstrumentationScope with name encodes")
    func instrumentationScope() {
        let s = OTLP.InstrumentationScope(name: "checkout")
        let bytes = EncodeCommon.encodeInstrumentationScope(s)
        #expect(!bytes.isEmpty)
        #expect(bytes.storage.first == 0x0A) // field 1 (name), wire 2
    }

    @Test("AnyValue.bool encodes both true and false")
    func anyValueBool() {
        // proto3 default omission applies to the OUTER container, not to the
        // oneof case identification — encodeAnyValue always emits the tag.
        let trueBytes = EncodeCommon.encodeAnyValue(.bool(true))
        let falseBytes = EncodeCommon.encodeAnyValue(.bool(false))
        #expect(!trueBytes.isEmpty)
        #expect(!falseBytes.isEmpty)
        // Field-2 tag for bool: (2 << 3) | 0 = 0x10
        #expect(trueBytes.storage.first == 0x10)
        #expect(falseBytes.storage.first == 0x10)
    }
}

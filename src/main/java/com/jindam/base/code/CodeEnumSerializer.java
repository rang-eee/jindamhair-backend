package com.jindam.base.code;

import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.databind.JsonSerializer;
import com.fasterxml.jackson.databind.SerializerProvider;

import java.io.IOException;

public class CodeEnumSerializer extends JsonSerializer<CodeEnum> {
    @Override
    public void serialize(CodeEnum value, JsonGenerator gen, SerializerProvider serializers) throws IOException {
        if (value == null) {
            gen.writeNull();
            return;
        }

        gen.writeStartObject();
        gen.writeStringField("code", value.getCode());
        gen.writeStringField("text", value.getText());
        gen.writeEndObject();
    }
}
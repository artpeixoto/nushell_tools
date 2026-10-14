const model = "glm-ocr:q8_0"

export def "infer text"  [] : path -> record {
    log info $"infering text in glm ocr"
    ollama run $model Text Recognition: $in
}

export def "infer image" [] {
    log info $"infering image in glm ocr"
    ollama run $model Figure Recognition: $in
}

# def "nu-complete pandoc-input-formats" [] {
#   try { ^pandoc --list-input-formats | lines | where ($it | str length) > 0 } catch { [] }
# }

# def "nu-complete pandoc-output-formats" [] {
#   try { ^pandoc --list-output-formats | lines | where ($it | str length) > 0 } catch { [] }
# }

# def "nu-complete pandoc-extensions" [] {
#   try {
#     ^pandoc --list-extensions | lines
#     | where ($it | str length) > 0
#     | parse "{format} {exts}"
#     | get format
#   } catch { [] }
# }

# def "nu-complete pandoc-highlight-languages" [] {
#   try { ^pandoc --list-highlight-languages | lines | where ($it | str length) > 0 } catch { [] }
# }

# def "nu-complete pandoc-highlight-styles" [] {
#   try { ^pandoc --list-highlight-styles | lines | where ($it | str length) > 0 } catch { [] }
# }

# def "nu-complete pandoc-wrap" [] { [auto none preserve] }

# def "nu-complete pandoc-eol" [] { [crlf lf native] }

# def "nu-complete pandoc-top-level-division" [] { [section chapter part] }

# def "nu-complete pandoc-track-changes" [] { [accept reject all] }

# def "nu-complete pandoc-reference-location" [] { [block section document] }

# def "nu-complete pandoc-caption-position" [] { [above below] }

# def "nu-complete pandoc-markdown-headings" [] { [setext atx] }

# def "nu-complete pandoc-email-obfuscation" [] { [none javascript references] }

# def "nu-complete pandoc-ipynb-output" [] { [all none best] }

# export extern "pandoc" [
#   ...files: path

#   -f: string@"nu-complete pandoc-input-formats"
#   --from: string@"nu-complete pandoc-input-formats"
#   -r: string@"nu-complete pandoc-input-formats"
#   --read: string@"nu-complete pandoc-input-formats"

#   -t: string@"nu-complete pandoc-output-formats"
#   --to: string@"nu-complete pandoc-output-formats"
#   -w: string@"nu-complete pandoc-output-formats"
#   --write: string@"nu-complete pandoc-output-formats"

#   -o: path
#   --output: path

#   --data-dir: path

#   -M: string
#   --metadata: string
#   --metadata-file: path

#   -d: path
#   --defaults: path

#   --file-scope
#   --sandbox

#   -s
#   --standalone
#   --template: path

#   -V: string
#   --variable: string
#   --variable-json: string

#   --wrap: string@"nu-complete pandoc-wrap"
#   --ascii

#   --toc
#   --table-of-contents
#   --toc-depth: int

#   --lof
#   --list-of-figures
#   --lot
#   --list-of-tables

#   -N
#   --number-sections
#   --number-offset: string
#   --top-level-division: string@"nu-complete pandoc-top-level-division"
#   --extract-media: path
#   --resource-path: string

#   -H: path
#   --include-in-header: path
#   -B: path
#   --include-before-body: path
#   -A: path
#   --include-after-body: path

#   --no-highlight
#   --highlight-style: string@"nu-complete pandoc-highlight-styles"
#   --syntax-definition: path
#   --syntax-highlighting: string
#   --dpi: int
#   --eol: string@"nu-complete pandoc-eol"
#   --columns: int

#   -p
#   --preserve-tabs
#   --tab-stop: int

#   --pdf-engine: string
#   --pdf-engine-opt: string
#   --reference-doc: path

#   --self-contained
#   --embed-resources
#   --link-images

#   --request-header: string
#   --no-check-certificate

#   --abbreviations: path
#   --indented-code-classes: string
#   --default-image-extension: string

#   -F: string
#   --filter: string
#   -L: path
#   --lua-filter: path

#   --shift-heading-level-by: int
#   --base-header-level: int
#   --track-changes: string@"nu-complete pandoc-track-changes"
#   --strip-comments
#   --reference-links
#   --reference-location: string@"nu-complete pandoc-reference-location"
#   --figure-caption-position: string@"nu-complete pandoc-caption-position"
#   --table-caption-position: string@"nu-complete pandoc-caption-position"
#   --markdown-headings: string@"nu-complete pandoc-markdown-headings"
#   --list-tables
#   --listings

#   -i
#   --incremental
#   --slide-level: int
#   --section-divs
#   --html-q-tags
#   --email-obfuscation: string@"nu-complete pandoc-email-obfuscation"
#   --id-prefix: string

#   -T: string
#   --title-prefix: string

#   -c: string
#   --css: string

#   --epub-subdirectory: string
#   --epub-cover-image: path
#   --epub-title-page
#   --epub-metadata: path
#   --epub-embed-font: path
#   --split-level: int
#   --chunk-template: path
#   --epub-chapter-level: int
#   --ipynb-output: string@"nu-complete pandoc-ipynb-output"

#   -C
#   --citeproc
#   --bibliography: path
#   --csl: path
#   --citation-abbreviations: path
#   --natbib
#   --biblatex

#   --mathml
#   --webtex: string
#   --mathjax: string
#   --katex: string
#   --gladtex

#   --trace
#   --dump-args
#   --ignore-args
#   --verbose
#   --quiet
#   --fail-if-warnings
#   --log: path

#   --bash-completion
#   --list-input-formats
#   --list-output-formats
#   --list-extensions: string@"nu-complete pandoc-input-formats"
#   --list-highlight-languages
#   --list-highlight-styles

#   -D: string@"nu-complete pandoc-output-formats"
#   --print-default-template: string@"nu-complete pandoc-output-formats"
#   --print-default-data-file: path
#   --print-highlight-style: string@"nu-complete pandoc-highlight-styles"

#   -v
#   --version
#   -h
#   --help
# ]

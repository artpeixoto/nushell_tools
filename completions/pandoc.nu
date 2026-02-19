def "nu-complete pandoc-wrap" [] { ["auto" "none" "preserve"] }

def "nu-complete pandoc-eol" [] { ["crlf" "lf" "native"] }

def "nu-complete pandoc-top-level-division" [] { ["section" "chapter" "part"] }

def "nu-complete pandoc-track-changes" [] { ["accept" "reject" "all"] }

def "nu-complete pandoc-reference-location" [] { ["block" "section" "document"] }

def "nu-complete pandoc-caption-position" [] { ["above" "below"] }

def "nu-complete pandoc-markdown-headings" [] { ["setext" "atx"] }

def "nu-complete pandoc-email-obfuscation" [] { ["none" "javascript" "references"] }

def "nu-complete pandoc-ipynb-output" [] { ["all" "none" "best"] }

def "nu-complete pandoc-bool" [] { ["true" "false"] }

def "nu-complete pandoc-input-formats" [] {
  try { ^pandoc --list-input-formats | lines | where {|s| ($s | str trim) != "" } } catch { [] }
}

def "nu-complete pandoc-output-formats" [] {
  try { ^pandoc --list-output-formats | lines | where {|s| ($s | str trim) != "" } } catch { [] }
}

def "nu-complete pandoc-extensions" [] {
  let fmt = (try { $in } catch { "" })
  if ($fmt | is-empty) { [] } else {
    try { ^pandoc --list-extensions $fmt | lines | where {|s| ($s | str trim) != "" } } catch { [] }
  }
}

def "nu-complete pandoc-highlight-languages" [] {
  try { ^pandoc --list-highlight-languages | lines | where {|s| ($s | str trim) != "" } } catch { [] }
}

def "nu-complete pandoc-highlight-styles" [] {
  try { ^pandoc --list-highlight-styles | lines | where {|s| ($s | str trim) != "" } } catch { [] }
}

export extern "pandoc" [
  ...files: path

  -f: string@"nu-complete pandoc-input-formats"
  -r: string@"nu-complete pandoc-input-formats"
  --from: string@"nu-complete pandoc-input-formats"
  --read: string@"nu-complete pandoc-input-formats"

  -t: string@"nu-complete pandoc-output-formats"
  -w: string@"nu-complete pandoc-output-formats"
  --to: string@"nu-complete pandoc-output-formats"
  --write: string@"nu-complete pandoc-output-formats"

  -o: path
  --output: path

  --data-dir: path

  -M: string
  --metadata: string
  --metadata-file: path

  -d: path
  --defaults: path

  --file-scope: string@"nu-complete pandoc-bool"
  --sandbox: string@"nu-complete pandoc-bool"

  -s: string@"nu-complete pandoc-bool"
  --standalone: string@"nu-complete pandoc-bool"

  --template: path

  -V: string
  --variable: string
  --variable-json: string

  --wrap: string@"nu-complete pandoc-wrap"
  --ascii: string@"nu-complete pandoc-bool"

  --toc: string@"nu-complete pandoc-bool"
  --table-of-contents: string@"nu-complete pandoc-bool"
  --toc-depth: int

  --lof: string@"nu-complete pandoc-bool"
  --list-of-figures: string@"nu-complete pandoc-bool"

  --lot: string@"nu-complete pandoc-bool"
  --list-of-tables: string@"nu-complete pandoc-bool"

  -N: string@"nu-complete pandoc-bool"
  --number-sections: string@"nu-complete pandoc-bool"
  --number-offset: string
  --top-level-division: string@"nu-complete pandoc-top-level-division"

  --extract-media: path
  --resource-path: string

  -H: path
  --include-in-header: path
  -B: path
  --include-before-body: path
  -A: path
  --include-after-body: path

  --no-highlight

  --highlight-style: string@"nu-complete pandoc-highlight-styles"
  --syntax-definition: path
  --syntax-highlighting: string

  --dpi: int
  --eol: string@"nu-complete pandoc-eol"
  --columns: int

  -p: string@"nu-complete pandoc-bool"
  --preserve-tabs: string@"nu-complete pandoc-bool"
  --tab-stop: int

  --pdf-engine: string
  --pdf-engine-opt: string
  --reference-doc: path

  --self-contained: string@"nu-complete pandoc-bool"
  --embed-resources: string@"nu-complete pandoc-bool"
  --link-images: string@"nu-complete pandoc-bool"

  --request-header: string
  --no-check-certificate: string@"nu-complete pandoc-bool"

  --abbreviations: path
  --indented-code-classes: string
  --default-image-extension: string

  -F: string
  --filter: string

  -L: path
  --lua-filter: path

  --shift-heading-level-by: int
  --base-header-level: int
  --track-changes: string@"nu-complete pandoc-track-changes"
  --strip-comments: string@"nu-complete pandoc-bool"
  --reference-links: string@"nu-complete pandoc-bool"
  --reference-location: string@"nu-complete pandoc-reference-location"
  --figure-caption-position: string@"nu-complete pandoc-caption-position"
  --table-caption-position: string@"nu-complete pandoc-caption-position"
  --markdown-headings: string@"nu-complete pandoc-markdown-headings"
  --list-tables: string@"nu-complete pandoc-bool"
  --listings: string@"nu-complete pandoc-bool"

  -i: string@"nu-complete pandoc-bool"
  --incremental: string@"nu-complete pandoc-bool"
  --slide-level: int
  --section-divs: string@"nu-complete pandoc-bool"
  --html-q-tags: string@"nu-complete pandoc-bool"
  --email-obfuscation: string@"nu-complete pandoc-email-obfuscation"
  --id-prefix: string

  -T: string
  --title-prefix: string

  -c: string
  --css: string

  --epub-subdirectory: string
  --epub-cover-image: path
  --epub-title-page: string@"nu-complete pandoc-bool"
  --epub-metadata: path
  --epub-embed-font: path
  --split-level: int
  --chunk-template: string
  --epub-chapter-level: int
  --ipynb-output: string@"nu-complete pandoc-ipynb-output"

  -C
  --citeproc
  --bibliography: path
  --csl: path
  --citation-abbreviations: path
  --natbib
  --biblatex

  --mathml
  --webtex: string
  --mathjax: string
  --katex: string
  --gladtex

  --trace: string@"nu-complete pandoc-bool"
  --dump-args: string@"nu-complete pandoc-bool"
  --ignore-args: string@"nu-complete pandoc-bool"
  --verbose
  --quiet
  --fail-if-warnings: string@"nu-complete pandoc-bool"
  --log: path

  --bash-completion

  --list-input-formats
  --list-output-formats
  --list-extensions: string@"nu-complete pandoc-input-formats"
  --list-highlight-languages
  --list-highlight-styles

  -D: string@"nu-complete pandoc-output-formats"
  --print-default-template: string@"nu-complete pandoc-output-formats"
  --print-default-data-file: path
  --print-highlight-style: string@"nu-complete pandoc-highlight-styles"

  -v
  --version
  -h
  --help
]
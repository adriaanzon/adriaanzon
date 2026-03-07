;; extends

; Use php_only for PHP code blocks, so they don't require a PHP opening tag
((fenced_code_block
  (info_string
    (language) @language)
  (code_fence_content) @injection.content)
  (#eq? @language "php")
  (#set! injection.language "php_only"))

"""
    convert_html(hs)

Convert a judoc html string into a html string.
"""
function convert_html(hs)
    # Tokenize
    tokens = find_tokens(hs, HTML_TOKENS, HTML_1C_TOKENS)
    # Find hblocks
    blocks, tokens = find_html_hblocks(hs, tokens)

end

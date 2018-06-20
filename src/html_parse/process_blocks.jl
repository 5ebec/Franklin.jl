"""
    process_math_blocks(html_string, asym_bm, sym_bm)

Take a string representing a html file, finds the placeholders left by
    - extract_asym_math_blocks
    - extract_sym_math_blocks
and plugs back in the KaTeX compatible corresponding content.
"""
function process_math_blocks(html_string, asym_bm, sym_bm)
    # first ASYM then SYM
    for (PH, blocks) ∈ zip([ASYM_MATH_PH, SYM_MATH_PH], [asym_bm, sym_bm])
        for (i, (mblock, inner)) ∈ enumerate(blocks)
            # mblock(inner) will return the content of the maths block
            # surrounded by the appropriate KaTeX tokens (see MDBlock)
            html_string = replace(html_string, PH * "$i", mblock(inner), 1)
        end
    end
    return html_string
end

const DIV_OPEN = r"@@([a-zA-Z]\S*)"
const DIV_CLOSE = r"@@(\s|\n|$)"

div_replace_open(hs) = replace(hs, DIV_OPEN, s"<div class=\"\1\">")
div_replace_close(hs) = replace(hs, DIV_CLOSE, "</div>")

"""
    process_div_blocks(html_string)

Find tokens of the form `@@name` and `@@`, delimiters of div blocks in the
Markdown notes and replace them by the html equivalent.
"""
process_div_blocks = div_replace_close ∘ div_replace_open


"""
    process_escaped_blocks(html_string, eb)

Plug blocks that were escaped back in the `html_string` given the placeholder.
"""
function process_escaped_blocks(html_string, eb)
    for (i, inner) ∈ enumerate(eb)
        html_string = replace(html_string, ESCAPED_PH * "$i", inner, 1)
    end
    return html_string
end

"""
    js_prerender_katex(hs::String)

Takes a html string that may contain inline katex blocks `\\(...\\)` or display katex blocks
`\\[ ... \\]` and use node and katex to pre-render them to HTML.
"""
function js_prerender_katex(hs::String)
    # look for \(, \) and \[, \] (we know they're paired because generated from markdown parsing)
    matches = collect(eachmatch(r"\\(\(|\[|\]|\))", hs))

    isempty(matches) && return hs

    # buffer to write the JS script
    jsbuffer = IOBuffer()
    write(jsbuffer, """
            const katex = require("$(joinpath(JD_PATHS[:libs], "katex", "katex.min.js"))");
            """)
    # string to separate the output of the different blocks
    splitter = "_>jdsplit<_"

    # go over each match and add the content to the jsbuffer
    for i ∈ 1:2:length(matches)-1
        # tokens are paired, no nesting
        mo, mc = matches[i:i+1]
        # check if it's a display style
        display = (mo.match == "\\[")
        # this is the content without the \( \) or \[ \]
        ms = subs(hs, mo.offset + 2, mc.offset - 1)
        # add to content of jsbuffer
        write(jsbuffer, """
            var html = katex.renderToString("$(escape_string(ms))", {displayMode: $display})
            console.log(html)
            """)
        # in between every block, write $splitter so that output can be split easily
        i == length(matches)-1 || write(jsbuffer, """\nconsole.log("$splitter")\n""")
    end
    return js2html(hs, jsbuffer, matches, splitter)
end


"""
    js_prerender_highlight(hs::String)

Takes a html string that may contain `<pre><code ... </code></pre>` blocks and use node and
highlight.js to pre-render them to HTML.
"""
function js_prerender_highlight(hs::String)
    # look for "<pre><code" and "</code></pre>" these will have been automatically generated
    # and therefore the regex can be fairly strict with spaces etc
    matches = collect(eachmatch(r"<pre><code class=\"?(?:language-)?(.*?)\"?\s*>|<\/code><\/pre>", hs))

    isempty(matches) && return hs

    # buffer to write the JS script
    jsbuffer = IOBuffer()
    write(jsbuffer, """const hljs = require('highlight.js');\n""")

#    @show run(`node -e "$(String(take!(jsbuffer)))"`)

    # string to separate the output of the different blocks
    splitter = "_>jdsplit<_"

    # go over each match and add the content to the jsbuffer
    for i ∈ 1:2:length(matches)-1
        # tokens are paired, no nesting
        co, cc = matches[i:i+1]
        # core code
        cs = escape_string(subs(hs, matchrange(co).stop+1, matchrange(cc).start-1))
        # add to content of jsbuffer
        write(jsbuffer, """console.log('<pre><code class=$(co.captures[1])>' +
                         hljs.highlight('$(co.captures[1])', '$(cs)').value +
                        '$(cc.match)')\n""")
        # in between every block, write $splitter so that output can be split easily
        i == length(matches)-1 || write(jsbuffer, """console.log('$splitter')\n""")
    end
    return js2html(hs, jsbuffer, matches, splitter)
end


"""
    js2html(hs, jsbuffer, matches, splitter)

Convenience function to run the content of `jsbuffer` with node, and lace the results with `hs`.
"""
function js2html(hs::String, jsbuffer::IOBuffer, matches::Vector{RegexMatch}, splitter::String)
    # run it redirecting the output to a buffer
    outbuffer = IOBuffer()
    run(pipeline(`node -e "$(String(take!(jsbuffer)))"`, stdout=outbuffer))

    # read the buffer and split it using $splitter
    out = String(take!(outbuffer))
    parts = split(out, splitter)

    # lace everything back together
    htmlbuffer = IOBuffer()
    head, c = 1, 1
    for i ∈ 1:2:length(matches)-1
        mo, mc = matches[i:i+1]
        write(htmlbuffer, subs(hs, head, mo.offset - 1))
        write(htmlbuffer, parts[c])
        head = mc.offset + 2
        c += 1
    end
    # add the rest of the document beyond the last mathblock
    head < lastindex(hs) && write(htmlbuffer, subs(hs, head, lastindex(hs)))

    return String(take!(htmlbuffer))
end

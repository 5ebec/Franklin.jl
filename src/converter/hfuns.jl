"""
    hfun_fill(params, allvars)

H-Function of the form `{{ fill vname }}` to plug in the content of a
jd-var `vname` (assuming it can be represented as a string).
"""
function hfun_fill(params::Vector{String}, allvars::Dict)
    length(params) == 1 || error("I found a {{fill ...}} with more than one parameter. Verify.")
    replacement = ""
    vname = params[1]
    if haskey(allvars, vname)
        # retrieve the value stored
        tmp_repl = allvars[vname].first

        (tmp_repl == nothing) || (replacement = string(tmp_repl))
    else
        warn("I found a '{{fill $vname}}' but I do not know the variable '$vname'. Ignoring.")
    end
    return replacement
end


"""
    hfun_insert(params)

H-Function of the form `{{ insert fpath }}` to plug in the content of a file at
`fpath`. Note that the base path is assumed to be `JD_PATHS[:in_html]` so paths
have to be expressed relative to that.
Note that (at the moment) the content is inserted "as is" without further
processing which means that any `{{...}}` block in the inserted content will
be displayed "as is".
"""
function hfun_insert(params::Vector{String})
    length(params) == 1 || error("I found an {{insert ...}} block with more than one parameter. Verify.")
    replacement = ""
    fpath = JD_PATHS[:in_html] * params[1]
    if isfile(fpath)
        replacement = readstring(fpath)
    else
        warn("I found an {{insert ...}} block and tried to insert '$fpath' but I couldn't find the file. Ignoring.")
    end
    return replacement
end

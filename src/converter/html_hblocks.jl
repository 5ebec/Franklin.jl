"""
    convert_hblock(β, allvars, fpath)

Helper function to process an individual block when the block is a `HCond` such as `{{ if
showauthor }} {{ fill author }} {{ end }}`.
"""
function convert_hblock(β::HCond, allvars::Dict, fpath::AbstractString="")
    # check that the bool vars exist
    allconds = [β.init_cond, β.sec_conds...]
    all(c -> haskey(allvars, c), allconds) || error("At least one of the booleans in a conditional html block could not be found. Verify.")

    # check if there's an "else" clause
    has_else = (length(β.actions) == 1 + length(β.sec_conds) + 1)
    # check the first clause that is verified
    k = findfirst(c -> allvars[c].first, allconds)
    # if none is verified, use the else clause if there is one or do nothing
    if isnothing(k)
        has_else || return ""
        partial = β.actions[end]
    # otherwise run the 1st one which is verified
    else
        partial = β.actions[k]
    end

    # NOTE the String(...) is necessary here as to avoid problematic indexing further on
    return convert_html(String(partial), allvars, fpath)
end

"""
    convert_hblock(β, allvars, fpath)

Helper function to process an individual block when the block is a `HIsDef` such as `{{ ifdef
author }} {{ fill author }} {{ end }}`. Which checks if a variable exists and if it does, applies
something.
"""
function convert_hblock(β::HCondDef, allvars::Dict, fpath::AbstractString="")
    hasvar = haskey(allvars, β.vname)
    # check if the corresponding bool is true and if so, act accordingly
    doaction = ifelse(β.checkisdef, hasvar, !hasvar)
    doaction && return convert_html(String(β.action), allvars, fpath::AbstractString)
    # default = do nothing
    return ""
end

function convert_hblock(β::HCondPage, allvars::Dict, fpath::AbstractString="")
    # get the relative paths so assuming fpath == joinpath(JD_PATHS[:in], rel_path)
    rpath = replace(fpath, JD_PATHS[:in] => "")
    rpath = replace(rpath, Regex("^$(PATH_SEP)pages$(PATH_SEP)")=>"$(PATH_SEP)pub$(PATH_SEP)")
    # rejoin and remove the extension
    rel_path = splitext(rpath)[1]
    # compare with β.pnames
    inpage = any(page -> splitext(page)[1] == rel_path, β.pages)
    # check if the corresponding bool is true and if so, act accordingly
    doaction = ifelse(β.checkispage, inpage, !inpage)
    doaction && return convert_html(String(β.action), allvars, fpath::AbstractString)
    # default = do nothing
    return ""
end

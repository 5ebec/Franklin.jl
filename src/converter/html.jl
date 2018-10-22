"""
    convert_html(hs, allvars)

Convert a judoc html string into a html string (i.e. replace {{ ... }} blocks).
"""
function convert_html(hs::String, allvars=Dict{String, Pair{Any, Tuple}}())

    # Tokenize
    tokens = find_tokens(hs, HTML_TOKENS, HTML_1C_TOKENS)
    tokens = deactivate_blocks(tokens, HTML_ESCAPE)

    # Find hblocks ({{ ... }})
    hblocks, tokens = find_html_hblocks(tokens)
    # Find qblocks (qualify the hblocks)
    qblocks = qualify_html_hblocks(hblocks)
    # Find overall conditional blocks (if ... elseif ... else ...  end)
    cblocks, qblocks = find_html_cblocks(qblocks)
    # Find conditional def blocks (ifdef / ifndef)
    cdblocks, qblocks = find_html_cdblocks(qblocks)
    # Get the list of blocks to process
    hblocks = merge_blocks(qblocks, cblocks, cdblocks)

    # construct the final html
    pieces = Vector{AbstractString}()
    head = 1
    for (i, hb) ∈ enumerate(hblocks)
        fromhb = from(hb)
        (head < fromhb) && push!(pieces, subs(hs, head, fromhb-1))
        push!(pieces, convert_hblock(hb, allvars))
        head = to(hb) + 1
    end
    strlen = lastindex(hs)
    (head < strlen) && push!(pieces, subs(hs, head, strlen))

    return prod(pieces)
end


"""
    JD_HBLOCKS

Dictionary for special html functions.
"""
const JD_HBLOCKS = Dict{String, Function}(
    "fill"   => ((π, ν) -> hfun_fill(π, ν)),
    "insert" => ((π, _) -> hfun_insert(π)),
    "href"   => ((π, _) -> hfun_href(π)),
)


"""
    convert_hblock(β, allvars)

Helper function to process an individual block when the block is a `HFun`
such as `{{ fill author }}`.
"""
function convert_hblock(β::HFun, allvars::Dict)

    fname = lowercase(β.fname)
    haskey(JD_HBLOCKS, fname) && return JD_HBLOCKS[fname](β.params, allvars)

    # unknown function
    @warn "I found a function block '{{$fname ...}}' but I don't recognise this function name. Ignoring."

    return β.ss
end


"""
    convert_hblock(β, allvars)

Helper function to process an individual block when the block is a `HCond`
such as `{{ if showauthor }} {{ fill author }} {{ end }}`.
"""
function convert_hblock(β::HCond, allvars::Dict)

    # check that the bool vars exist
    allconds = [β.init_cond, β.sec_conds...]
    has_else = (length(β.actions) == 1 + length(β.sec_conds) + 1)
    all(c -> haskey(allvars, c), allconds) || error("At least one of the booleans in a conditional html block could not be found. Verify.")
    k = findfirst(c -> allvars[c].first, allconds)
    if isnothing(k)
        has_else || return ""
        partial = β.actions[end]
    else
        partial = β.actions[k]
    end

    return convert_html(String(partial), allvars)
end


"""
    convert_hblock(β, allvars)

Helper function to process an individual block when the block is a `HIfDef`
such as `{{ ifdef author }} {{ fill author }} {{ end }}`. Which checks
if a variable exists and if it does, applies something.
"""
function convert_hblock(β::HCondDef, allvars::Dict)

    hasvar = haskey(allvars, β.vname)
    doaction = ifelse(β.checkisdef, hasvar, !hasvar)
    doaction && return convert_html(String(β.action), allvars)

    return ""
end

"""
    convert_html(hs, allvars)

Convert a judoc html string into a html string.
"""
function convert_html(hs::String, allvars::Dict)
    # Tokenize
    tokens = find_tokens(hs, HTML_TOKENS, HTML_1C_TOKENS)
    # Find hblocks ( {{ ... }})
    hblocks, tokens = find_html_hblocks(tokens)
    # Find qblocks (qualify the hblocks)
    qblocks = qualify_html_hblocks(hblocks, hs)
    # Find overall conditional blocks (if ... elseif ... else ...  end)
    cblocks, qblocks = find_html_cblocks(qblocks)
    # Get the list of blocks to process
    allblocks = get_html_allblocks(qblocks, cblocks, endof(hs))

    hs = prod(convert_html__procblock(β, hs, allvars) for β ∈ allblocks)
end


"""
    convert_html__procblock(β)

Helper function to process an individual block.
"""
function convert_html__procblock(β::Union{Block, <:HBlock, HCond}, hs::String,
                                 allvars::Dict)
    # if it's just a remain block, plug in "as is"
    ((typeof(β) == Block) && β.name == :REMAIN) && return hs[β.from:β.to]

    # if it's a conditional block, need to find the span corresponding
    # to the variable that is true (or the else block)
    if typeof(β) == HCond
        # check that the bool vars exist
        allconds = [β.vcond1, β.vconds...]
        haselse = (length(β.dofrom) == 1 + length(β.vconds) + 1)
        all(c -> haskey(allvars, c), allconds) || error("At least one of the booleans in the conditional block could not be found. Verify.")
        k = findfirst(c -> allvars[c].first, allconds)
        if (k == nothing)
            haselse || return ""
            partial = hs[β.dofrom[end]:β.doto[end]]
        else
            partial = hs[β.dofrom[k]:β.doto[k]]
        end
        return convert_html(partial, allvars)
    # function block
    elseif typeof(β) == HFun
        if lowercase(β.fname) == "fill"
            return hfun_fill(β.params, allvars)
        else
            # TODO TODO TODO TODO TODO
            return hs[β.from:β.to]
            # TODO TODO TODO TODO TODO
        end
    end
end


function hfun_fill(params::Vector{String}, allvars)
    length(params) == 1 || error("I found a {{fill ...}} with more than one parameter. Verify.")
    replacement = ""
    vname = params[1]
    if haskey(allvars, vname)
        tmp_repl = allvars[vname].first # retrieve the value stored
        (tmp_repl == nothing) || (replacement = string(tmp_repl))
    else
        warn("I found a '{{fill $vname}}' but I do not know the variable '$vname'. Ignoring.")
    end
    return replacement
end


# """
#     check_nparams(β, expect_args)
#
# Helper function to split a string `params` expected to contain references to
# parameters for `fun_name` in number `expect_args`. If that's not the case,
# with either too few or too many arguments, a warning is returned and the action
# will be ignored.
# """
# function split_params(params, fun_name, expect_args)
#     sparams = split(params)
#     len_sparams = length(sparams)
#     flag = (len_sparams == expect_args)
#     if !flag
#         warn("I found a '$fun_name' and expected $expect_args argument(s) but got $len_sparams instead. Ignoring.")
#     end
#     return (flag, ifelse(len_sparams == 1, sparams[1], sparams))
# end

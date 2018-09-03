@testset "Cblock+h-fill" begin
    allvars = Dict{String, Pair{Any, Tuple}}(
        "v1" => "INPUT1" => (String,),
        "b1" => false => (Bool,),
        "b2" => true  => (Bool,))

    hs = raw"""
        Some text then {{ fill v1 }} and
        {{ if b1 }}
        show stuff here {{ fill v2 }}
        {{ else if b2 }}
        other stuff
        {{ else }}
        show other stuff
        {{ end }}
        final text
        """

    tokens = JuDoc.find_tokens(hs, JuDoc.HTML_TOKENS, JuDoc.HTML_1C_TOKENS)
    hblocks, tokens = JuDoc.find_html_hblocks(tokens)
    qblocks = JuDoc.qualify_html_hblocks(hblocks)
    cblocks, qblocks = JuDoc.find_html_cblocks(qblocks)
    hblocks = JuDoc.merge_fblocks_cblocks(qblocks, cblocks)
    convhbs = [JuDoc.convert_hblock(hb, allvars) for hb ∈ hblocks]
    @test convhbs[1] == "INPUT1"
    @test convhbs[2] == "\nother stuff\n"
    @test JuDoc.convert_html(hs, allvars) == "Some text then INPUT1 and\n\nother stuff\n\nfinal text\n"
end


@testset "h-insert" begin
    # NOTE: the test/jd_paths.jl must have been run before
    global temp_rnd
    temp_rnd = joinpath(JuDoc.JD_PATHS[:in_html], "temp.rnd")
    write(temp_rnd, "some random text to insert")
    hs = raw"""
        Trying to insert: {{ insert temp.rnd }} and see.
        """
    allvars = Dict()
    @test JuDoc.convert_html(hs, allvars) == "Trying to insert: some random text to insert and see.\n"
end

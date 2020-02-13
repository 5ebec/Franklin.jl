@testset "Conv-lx" begin
    cd(td)
    # Exception instead of ArgumentError as may fail with system error
    @test_throws Exception F.check_input_rpath("aldjfk")
end

@testset "Conv-html" begin
    @test_throws F.HTMLFunctionError F.convert_html("{{fill bb cc}}")
    @test_throws F.HTMLFunctionError F.convert_html("{{insert bb cc}}")
    @test_throws F.HTMLFunctionError F.convert_html("{{href aa}}")
    @test (@test_logs (:warn, "Unknown dictionary name aa in {{href ...}}. Ignoring") F.convert_html("{{href aa bb}}")) == "<b>??</b>"
    @test_throws F.HTMLBlockError F.convert_html("{{if asdf}}{{end}}")
    @test_throws F.HTMLBlockError F.convert_html("{{if asdf}}")
    @test_throws F.HTMLBlockError F.convert_html("{{isdef asdf}}")
    @test_throws F.HTMLBlockError F.convert_html("{{ispage asdf}}")
end

@testset "Conv-md" begin
    s = """
        @def blah
        """
    @test (@test_logs (:warn, "Found delimiters for an @def environment but it didn't have the right @def var = ... format. Verify (ignoring for now).") (s |> fd2html_td)) == ""

    s = """
        Blah
        [^1]: hello
        """ |> fd2html_td
    @test isapproxstr(s, "<p>Blah </p>")
end

@testset "Franklin" begin
    cd(td); mkpath("foo"); cd("foo"); write("config.md","")
    @test_throws ArgumentError serve(single=true)
    cd(td)
end

@testset "RSS" begin
    F.set_var!(F.GLOBAL_VARS, "website_descr", "")
    F.RSS_DICT["hello"] = F.RSSItem("","","","","","","",Date(1))
    @test (@test_logs (:warn, """
              I found RSS items but the RSS feed is not properly described:
              at least one of the following variables has not been defined in
              your config.md: `website_title`, `website_descr`, `website_url`.
              The feed will not be (re)generated.""") F.rss_generator()) === nothing
end


@testset "parser-lx" begin
    s = raw"""
        \newcommand{hello}{hello}
        """
    @test_throws F.LxDefError (s |> fd2html)
    s = raw"""
        \foo
        """
    @test_throws F.LxComError (s |> fd2html)
    s = raw"""
        \newcommand{\foo}[2]{hello #1 #2}
        \foo{a} {}
        """
    @test_throws F.LxComError (s |> fd2html)
end

@testset "ocblocks" begin
    s = raw"""
        @@foo
        """
    @test_throws F.OCBlockError (s |> fd2html)
end

@testset "tofrom" begin
    s = "jμΛΙα"
    @test F.from(s) == 1
    @test F.to(s) == lastindex(s)
end

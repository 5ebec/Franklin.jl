@testset "Proc math bl" begin
	s = raw"""
	This is some *markdown* with $\sin(x)=1$ some maths
	$$ \int_0^1 x\mathrm{d}x = {1\over 2} $$
	and maybe some more here
	\begin{eqnarray}
		1+1 &=& 2\\
		2+2 &=& 4
	\end{eqnarray}
	or whatever it is they prove in _Principia Mathematica_.
	"""
	(s, abm) = JuDoc.asym_math_blocks(s);
	(s, sbm) = JuDoc.sym_math_blocks(s);
	h = JuDoc.html(JuDoc.Markdown.parse(s));
	@test h == "<p>This is some <em>markdown</em> with ##SYM_MATH_BLOCK##2 some maths ##SYM_MATH_BLOCK##1 and maybe some more here ##ASYM_MATH_BLOCK##1 or whatever it is they prove in _Principia Mathematica_.</p>\n"
	h = JuDoc.process_math_blocks(h, abm, sbm)
	@test h == "<p>This is some <em>markdown</em> with \\(\\sin(x)=1\\) some maths \$\$ \\int_0^1 x\\mathrm{d}x = {1\\over 2} \$\$ and maybe some more here \$\$\n\\begin{array}{c}\n\t1+1 &=& 2\\\\\n\t2+2 &=& 4\n\\end{array}\n\$\$ or whatever it is they prove in _Principia Mathematica_.</p>\n"
end


@testset "Proc div bl" begin
	t = JuDoc.dpat("blah", "content is here")
	@test t == "<div class=\"blah\">content is here</div>\n"
	s = raw"""
	This is some *markdown* followed by a div:
	@@some_div
	the content here
	@@ and then more markdown
	blah.
	"""
	s, b = JuDoc.div_blocks(s)
	@test s == "This is some *markdown* followed by a div:\n##DIV_BLOCK##1 and then more markdown\nblah.\n"
	@test b == [("some_div", "\nthe content here\n")]
	h = JuDoc.html(JuDoc.Markdown.parse(s));
	h = JuDoc.process_div_blocks(h, b)
	@test h == "<p>This is some <em>markdown</em> followed by a div: <div class=\"some_div\">\nthe content here\n</div>\n and then more markdown blah.</p>\n"
end


@testset "Proc {{.}} bl" begin
	# split param util
	params = "blah blih thing"
	@test_warn "I found a 'FNAME' and expected 2 argument(s) but got 3 instead. Ignoring." JuDoc.split_params(params, "FNAME", 2)
	(f, sp) = JuDoc.split_params(params, "FNAME", 3)
	@test f == true
	@test sp == ["blah", "blih", "thing"]

	# replacements :: braces_fill
	params1 = "blah"
	var1 = Dict("blah" => 25)
	r = JuDoc.braces_fill(params1, var1)
	@test r == "25"
	params1 = "blih"
	@test_warn "I found a '{{fill blih}}' but I do not know the variable 'blih'. Ignoring." JuDoc.braces_fill(params1, var1)
	params2 = "blih blah"
	@test_warn "I found a 'fill' and expected 1 argument(s) but got 2 instead. Ignoring." JuDoc.braces_fill(params2, var1)

	# replacements :: braces_insert_if
	temp_path = tempname()
	write(temp_path * ".html", "This is a test page.\n")
	params2 = "flag $temp_path"
	vars = Dict("flag" => true)
	r = JuDoc.braces_insert_if(params2, vars)
	@test r == "This is a test page.\n"
	params2 = "flag non-existing"
	@test_warn "I tried to insert 'non-existing.html' but I couldn't find the file. Ignoring." JuDoc.braces_insert_if(params2, vars)
	params2 = "flig non-existing"
	@test_warn "I found an '{{insert_if flig ...}}' but I do not know the variable 'flig'. Ignoring." JuDoc.braces_insert_if(params2, vars)

	# replacements :: general braces blocks
	h = """
	blah blah {{ fill blah }} and
	then some more stuff maybe {{ insert_if flag $temp_path }} etc
	blah
	"""
	vars = Dict("blah" => 0.123, "flag" => true)
	h = JuDoc.process_braces_blocks(h, vars)
	@test h == "blah blah 0.123 and\nthen some more stuff maybe This is a test page.\n etc\nblah\n"
	h = """
	{{ unknown f f2 }}
	"""
	@test_warn "I found a {{...}} block but did not recognise the function name 'unknown'. Ignoring." JuDoc.process_braces_blocks(h, vars)
end

@testset "Proc {{if}} bl" begin
	vars = Dict("flag" => true, "fflag" => false, "filler" => 245)
	h = """
	blah blah {{ if flag blah blah {{fill filler}} end }}
	and then {{ if fflag
	nothing should
	end }}
	be here
	"""
	h = JuDoc.process_if_braces_blocks(h, vars)
	@test h == "blah blah  blah blah {{fill filler}} \nand then \nbe here\n"
end

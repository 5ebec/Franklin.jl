"""
	`JD_PATHS`

Dictionary for the paths of the input folders and the output folders. The
simpler case only requires the main input folder to be defined i.e.
`JD_PATHS[:in]` and infers the others via the `set_paths!()` function.
"""
JD_PATHS = Dict{Symbol, String}(
	:in 	  => "",
  	:in_libs  => "",
	:in_css   => "",
  	:in_html  => "",
	:out 	  => "",
	:out_libs => "",
	:out_css  => "")


"""
	ifisdef(symb, def)

Short helper function to check if the symbol `symb` is defined in the `Main`
module (current environment). If it is, it returns the value of the symbol.
Otherwise it returns the `def` value (default value).
"""
ifisdef(symb, def) = isdefined(Main, symb) ? eval(:(Main.$symb)) : def


"""
	set_paths!()

Queries the `Main` module to see if the different path variables are defined.
`Main.PATH_INPUT` must be defined (and valid), the others have a default value.
"""
function set_paths!()
	global JD_PATHS

	@assert isdefined(Main, :PATH_INPUT) "PATH_INPUT undefined"
	JD_PATHS[:in] = Main.PATH_INPUT
	@assert isdir(JD_PATHS[:in]) "PATH_INPUT does not lead to valid input folder"

	JD_PATHS[:in_libs] = ifisdef(:PATH_INPUT_LIBS, JD_PATHS[:in] * "_libs/")
	JD_PATHS[:in_css]  = ifisdef(:PATH_INPUT_CSS,  JD_PATHS[:in] * "_css/")
	JD_PATHS[:in_html] = ifisdef(:PATH_INPUT_HTML, JD_PATHS[:in] * "_html_parts/")

	JD_PATHS[:out] 		= ifisdef(:PATH_OUTPUT, "web_output/")
	JD_PATHS[:out_libs] = ifisdef(:PATH_OUTPUT_LIBS, JD_PATHS[:out] * "_libs/")
	JD_PATHS[:out_css]  = ifisdef(:PATH_OUTPUT_CSS,  JD_PATHS[:out] * "_css/")

	return JD_PATHS
end

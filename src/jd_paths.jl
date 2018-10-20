"""
	FOLDER_PATH

Container to keep track of where JuDoc is being run.

DEVNOTE: a reference so that can be marked as const but assigned at runtime.
"""
const FOLDER_PATH = Ref{String}()


"""
	IGNORE_FILES

Collection of file names that will be ignored at compile time.
"""
const IGNORE_FILES = [".DS_Store"]


"""
	INFRA_EXT

Collection of file extensions considered as potential infrastructure files.
"""
const INFRA_EXT = [".html", ".css"]


"""
	JD_PATHS

Dictionary for the paths of the input folders and the output folders. The
simpler case only requires the main input folder to be defined i.e.
`JD_PATHS[:in]` and infers the others via the `set_paths!()` function.

DEVNOTE: marked as const for perf reasons but can be assigned later as Dict.
"""
const JD_PATHS = Dict{Symbol, String}()


"""
	set_paths!()

This assigns all the paths where files will be read and written with root the
FOLDER_PATH which is assigned at runtime.
"""
function set_paths!()
	@assert isassigned(FOLDER_PATH) "FOLDER_PATH undefined"
	@assert isdir(FOLDER_PATH[]) "FOLDER_PATH is not a valid path"

	#= NOTE I recommend against changing the names of those paths to simplify
	development. Pparticularly for the output dirs. If you do, check for
	example that the function JuDoc.publish points to the right dirs/files. =#
	JD_PATHS[:f] 		= normpath(FOLDER_PATH[] * "/")
	JD_PATHS[:in] 		= JD_PATHS[:f]  * "src/"
	JD_PATHS[:in_pages] = JD_PATHS[:in] * "pages/"
	JD_PATHS[:in_css]   = JD_PATHS[:in] * "_css/"
	JD_PATHS[:in_html]  = JD_PATHS[:in] * "_html_parts/"
	JD_PATHS[:out] 		= JD_PATHS[:f]  * "pub/"
	JD_PATHS[:out_css]  = JD_PATHS[:f]  * "css/"
	JD_PATHS[:libs] 	= JD_PATHS[:f]  * "libs/"

	return JD_PATHS
end

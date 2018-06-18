@testset "Asym Maths" begin
	# Just \[\]
	s = raw"""
		blahblah \[target\] blah
		\[target2\] blih
		"""
	(s, abm) = JuDoc.extract_asym_math_blocks(s)
	@test s == raw"""
		blahblah ##ASYM_MATH_BLOCK##1 blah
		##ASYM_MATH_BLOCK##2 blih
		"""
	@test abm[1][2] == "target"
	@test abm[2][2] == "target2"

	# Just ALIGN
	s = raw"""
		blahblah \begin{align}target\end{align} blah
		\begin{align}target2\end{align} blih
		"""
	(s, abm) = JuDoc.extract_asym_math_blocks(s)
	@test s == raw"""
		blahblah ##ASYM_MATH_BLOCK##1 blah
		##ASYM_MATH_BLOCK##2 blih
		"""
	@test abm[1][2] == "target"
	@test abm[2][2] == "target2"

	# Just EQNARRAY
	s = raw"""
		blahblah \begin{eqnarray}target\end{eqnarray} blah
		\begin{eqnarray}target2\end{eqnarray} blih
		"""
	(s, abm) = JuDoc.extract_asym_math_blocks(s)
	@test s == raw"""
		blahblah ##ASYM_MATH_BLOCK##1 blah
		##ASYM_MATH_BLOCK##2 blih
		"""
	@test abm[1][2] == "target"
	@test abm[2][2] == "target2"

	# Mixed asymetric
	s = raw"""
		blahblah \begin{eqnarray}target\end{eqnarray} blah
		\[target2\] and \begin{align}
		target3
		\end{align}
		"""
	(s, abm) = JuDoc.extract_asym_math_blocks(s)
	@test s == raw"""
		blahblah ##ASYM_MATH_BLOCK##3 blah
		##ASYM_MATH_BLOCK##1 and ##ASYM_MATH_BLOCK##2
		"""
	@test abm[1][2] == "target2"
	@test abm[2][2] == "\ntarget3\n"
	@test abm[3][2] == "target"
end


@testset "Sym Maths" begin
	# Just $ ... $
	s = raw"""
		blahblah $target$ blah
		$target2$ blih
		"""
	(s, sbm) = JuDoc.extract_sym_math_blocks(s)
	@test s == raw"""
		blahblah ##SYM_MATH_BLOCK##1 blah
		##SYM_MATH_BLOCK##2 blih
		"""
	@test sbm[1][2] == "target"
	@test sbm[2][2] == "target2"

	# Just $$ ... $$
	s = raw"""
		blahblah $$target$$ blah
		$$target2$$ blih
		"""
	(s, sbm) = JuDoc.extract_sym_math_blocks(s)
	@test s == raw"""
		blahblah ##SYM_MATH_BLOCK##1 blah
		##SYM_MATH_BLOCK##2 blih
		"""
	@test sbm[1][2] == "target"
	@test sbm[2][2] == "target2"

	# Mixed sym
	s = raw"""
		blahblah $target$ blah
		$$target2$$ blih
		"""
	(s, sbm) = JuDoc.extract_sym_math_blocks(s)
	@test s == raw"""
		blahblah ##SYM_MATH_BLOCK##2 blah
		##SYM_MATH_BLOCK##1 blih
		"""
	@test sbm[1][2] == "target2"
	@test sbm[2][2] == "target"
end

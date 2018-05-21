

some details:
1) index type must be GLuint, Int will orrcur error.
2) before you connect with shader uniform(glGetUniformLocation, glUniform3f), you must designate program, that is glUseProgram. Or opengl don't know which program to search.

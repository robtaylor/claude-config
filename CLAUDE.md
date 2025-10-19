# ChipFlow Servers Guidelines

# General behaviour
- **Do not always agree with me**: If I state something that you belive is incorrect, please say so and provide a demonstration of why it is incorrect.
- **Commit often**: Commit to git after each cohesive change and push often
- **Scripts**: in general don't make scripts executable, run them with the appropriate environment manager. PDM for Python, npm for js/ts, etc.
- Do not say "You're absolutely right". Rather than assume the user is always correct, you should sanity check requests from the user
- Do not be confident that you have solved an issue. Always test that you have.
- Always make any infrastructure configuration or setup scripts idempotent if possible.

## Build Commands
- **Build all servers**: `npm run build`
- **Watch all servers**: `npm run watch`
- **Build single server**: `cd src/server-name && npm run build`
- **Start a server**: `cd src/server-name && npm run start`

## Test Commands
- **TypeScript**: No global test configuration
- **Python tests**: `pytest`
- **Run single test**: `pytest tests/test_file.py::test_function_name`

## Code Style Guidelines
- **TypeScript**: ES2022, Node16 modules, strict mode
- **Python**: PEP-8 style, Python 3.10+, ruff for linting
- **Linting**: Python: `ruff check .`
- **Type checking**: Python: `pyright`, TypeScript: compiler in strict mode
- **Naming**: camelCase for JS/TS, snake_case for Python
- **Error handling**: Custom error types with descriptive messages
- **No trailing whitespace** in any files
- **No whitespace on blank lines** in any files

## Python Dependencies
- Most Python projects use `uv` for dependency management
- Some may use PDM - use `pdm install` to set up
- Run scripts with `pdm run script_name` or `uv run script_name`

## Project Organization
- Servers organized in `src/` directory
- Each server has its own package.json/pyproject.toml and Dockerfile

## Git
- *Always* rebase rather than merge

### Refactoring PR Commit History
When cleaning up a PR before final review, use this approach:

1. **Squash bug fixes into the feature they fix**
   - Thread-safety fixes, initialization bugs, etc. should be squashed into the main feature commit
   - Don't leave critical fixes as separate commits - they make the feature incomplete without them

2. **Keep maintainer feedback as followup commits**
   - Documentation fixes requested by maintainers can stay as separate commits
   - This shows responsiveness to feedback and keeps the main feature clean

3. **Preserve valuable test commits**
   - Keep test commits that add real testing value
   - Drop placeholder/documentation-only test commits

4. **Example rebase sequence**:
   ```
   pick <main-feature> Add feature X with unified error handling
   squash <bug-fix> Fix thread-safety in feature X
   pick <feedback> Fix documentation based on maintainer feedback
   pick <test1> Add test for feature X implementation
   pick <test2> Add integration test suite
   pick <test3> Add comparative testing
   drop <placeholder> Add placeholder test (documentation only)
   ```

5. **Process**:
   - Review commit history: `git log --oneline origin/main..HEAD`
   - Interactive rebase: `git rebase -i origin/main`
   - Edit the rebase file with above strategy
   - Force push: `git push --force-with-lease`

## GitHub
- Use `gh` tool to interact with GitHub
- Check PR status: `gh pr check`
- Wait for PR checks: `gh pr check --watch`
- Use `actionlint` to syntax check github action yml files (installed via homebrew)
- zshell command 'gh-look' can be used to watch for last github action run

## further Python guidelines
- Prefer pathlib over using os.path
- If there is a 'pdm lint' command, use this before finishing or committing
- When writing tests for a library, use public apis unless instructed otherwise. command line interfaces count as public api.

## PDM usage
- when starting work, check if there is a pyproject.toml. If it contains 'pdm' anywhere, assume you should use PDM for running scripts and interacting with the python environment.
- Run python directly by using 'pdm run python ...' to use the correct environment
- Run tests by running 'pdm test ..' of if that fails 'pdm run pytest .."

# C/C++ projects
## Debugging Build Issues

### CI Build Failures
- **Check CI status**: `gh pr checks` or `gh pr checks --watch`
- **View specific failure**: `gh run view <run-id> --log-failed`
- **View all logs**: `gh run view <run-id> --log`

### Common Build Problems and Solutions

#### Missing Header Files
- **Symptom**: `fatal error: 'header.h' file not found`
- **Solution**: Add missing include directories to `target_include_directories`
- **Example**: `target_include_directories(target PUBLIC $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/src/include>)`

#### Math Function Redeclaration
- **Symptom**: `warning: incompatible redeclaration of library function 'logb'`
- **Solution**: Use `check_symbol_exists` instead of `check_function_exists` with proper header inclusion
- **Example**: `set(CMAKE_REQUIRED_LIBRARIES m)` then `check_symbol_exists(logb "math.h" HAVE_LOGB)`

#### Bison Parser Issues
- **Symptom**: Generated parser headers not found or circular dependencies
- **Solution**: Ensure correct include paths and header generation order
- **Key**: Generated headers can be included in `.y` files - this goes into the generated `.c` file

#### Conditional Compilation Errors
- **Symptom**: Code accessing undefined struct members when features disabled
- **Solution**: Wrap feature-specific code in `#ifdef FEATURE_NAME` guards
- **Example**: `#ifdef OSDI` around OSDI-specific code

#### Static Library Linking Order
- **Symptom**: Massive undefined reference errors during linking (`trnoise_state_free`, `cx_*`, `klu_*`, etc.)
- **Root Cause**: Static libraries must be linked in reverse dependency order
- **Solution**: Order libraries from most dependent to least dependent, duplicate if needed for circular deps
- **Pattern**: `target_link_libraries(target PRIVATE ${DEVICE_LIBS} ${CORE_LIBS} ${DEVICE_LIBS})`
- **Reference**: https://eli.thegreenplace.net/2013/07/09/library-order-in-static-linking

### Build Process Tips
1. **Systematic approach**: Fix compilation errors before linking errors
2. **Check all targets**: Ensure fixes apply to executable, shared library, and TCL targets
3. **Cross-platform testing**: Verify fixes work on Linux, macOS, and Windows
4. **Use proper CMake patterns**: Prefer target-based configurations over global settings

<!-- CLAUDE-MEM QUICK REFERENCE -->
## 🧠 Memory System Quick Reference

### Search Your Memories (SIMPLE & POWERFUL)
- **Semantic search is king**: `mcp__claude-mem__chroma_query_documents(["search terms"])`
- **🔒 ALWAYS include project name in query**: `["claude-mem feature authentication"]` not just `["feature authentication"]`
- **Include dates for temporal search**: `["project-name 2025-09-09 bug fix"]` finds memories from that date
- **Get specific memory**: `mcp__claude-mem__chroma_get_documents(ids: ["document_id"])`

### Search Tips That Actually Work
- **Project isolation**: Always prefix queries with project name to avoid cross-contamination
- **Temporal search**: Include dates (YYYY-MM-DD) in query text to find memories from specific times
- **Intent-based**: "implementing oauth" > "oauth implementation code function"
- **Multiple queries**: Search with different phrasings for better coverage
- **Session-specific**: Include session ID in query when you know it

### What Doesn't Work (Don't Do This!)
- ❌ Complex where filters with $and/$or - they cause errors
- ❌ Timestamp comparisons ($gte/$lt) - Chroma stores timestamps as strings
- ❌ Mixing project filters in where clause - causes "Error finding id"

### Storage
- Collection: "claude_memories"
- Archives: ~/.claude-mem/archives/
<!-- /CLAUDE-MEM QUICK REFERENCE -->

# ChipFlow Servers Guidelines

# General behaviour
- **Do not always agree with me**: If I state something that you belive is incorrect, please say so and provide a demonstration of why it is incorrect.
- **Commit often**: Commit to git after each cohesive change and push often
- **Scripts**: in general don't make scripts executable, run them with the appropriate environment manager. PDM or UV for Python, npm for js/ts, etc, unless they are bash, require no environment setup or have a suitable shebang that executes them in the correct environment (e.g. #!/usr/bin/env -S uv run --script)
- Do not say "You're absolutely right". Rather than assume the user is always correct, you should sanity check requests from the user
- Do not be confident that you have solved an issue. Always test that you have.
- Always make any infrastructure configuration or setup scripts idempotent if possible.
- Don't be sure of your conclusions without confirming them

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
- **File size**: Keep source files under ~20,000 tokens (~70KB). If a file grows larger, split it into logical modules. Estimate tokens as `file_size_bytes / 3.5`
- **Always** attempt to add assertions for your assumptions

## Python Dependencies
- Use `uv` for dependency and python environment management. If a project has a pyproject.toml, you can determine which environment manager to use by looking for 'pdm', 'poetry' or 'uv' specific keys. if there are no manager specific keys, default to `uv`
- For projects that still use requirements.txt, use `uv` for installing an enviroment for that project.
- Some may use PDM - use `pdm install` to set up
- Run scripts with the package manager - e.g `uv run`, `pdm run`, `poetry run`

## Project Organization
- Servers organized in `src/` directory
- Each server has its own package.json/pyproject.toml and Dockerfile

## Git
- *Always* rebase rather than merge

### AI Agent Attribution in Commits - MANDATORY

**CRITICAL**: When creating commits as an AI assistant, you MUST identify yourself properly. This is NOT optional.

#### REQUIRED: Co-developed-by Tag

**YOU MUST include a "Co-developed-by" tag in EVERY commit message you create.**

**IF YOU ARE CLAUDE CODE (which you are), use this EXACT format:**
```
Co-developed-by: Claude Code v$version ($models_used)
```
Where:
- `$version` is the Claude Code version - **run `~/.claude/local/claude --version` to get it**
- `$models_used` is the model(s) used in the session (check with `/stats` if needed, or use the known model from this session)

Example for Claude Code:
```
Co-developed-by: Claude Code v2.0.76 (claude-sonnet-4-5-20250929)
```

**IMPORTANT**: Always run `~/.claude/local/claude --version` before creating commits to get the current version.

**For reference only** (other AI tools, NOT for Claude Code):
- GitHub Copilot: `Co-developed-by: GitHub-Copilot GPT-4 v1.0.0`
- Cursor: `Co-developed-by: Cursor gpt-4-turbo-2024-04-09`
- Generic Claude API usage: `Co-developed-by: Claude claude-sonnet-4-5-20250929`

**DO NOT include email addresses in the Co-developed-by tag.**

#### PROHIBITED: What You MUST NOT Do

1. **NEVER add a "Signed-off-by" tag for yourself**
   - The Signed-off-by tag represents a LEGAL CERTIFICATION by a human developer
   - Only the human user should add their Signed-off-by tag
   - AI assistants cannot make legal certifications

2. **NEVER include advertising or promotional text**
   - Do NOT add: "🤖 Generated with [Claude Code](https://claude.com/claude-code)"
   - Do NOT add: Similar promotional or marketing messages
   - Keep commit messages professional and focused on the technical changes

#### Why This Matters

Transparency about AI involvement in development:
- Helps maintainers and reviewers understand the development process
- Provides proper attribution for AI-assisted code
- Maintains trust and accountability in open source contributions
- Separates AI contribution from human legal certification

**Remember: The Co-developed-by tag is MANDATORY. The Signed-off-by tag is FORBIDDEN for AI assistants.**

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
- my custom zshell command 'gh-look' can be used to watch for last github action run
- you can use `gh run rerun` rather than empty commits to re run a workflow
- Alway use rebase when merging a PR

## further Python guidelines
- Prefer pathlib over using os.path
- If there is a 'lint', 'test' or similar command configured in pyproject.toml, use this before finishing or committing
- When writing tests for a library, use public apis unless instructed otherwise. command line interfaces count as public api.- Use python `logging` rather than prints for debug/trace messages

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

# Python Package Management with uv

Use uv exclusively for Python package management in this project.

## Package Management Commands

- All Python dependencies **must be installed, synchronized, and locked** using uv
- Never use pip, pip-tools, poetry, or conda directly for dependency management

Use these commands:

- Install dependencies: `uv add <package>`
- Remove dependencies: `uv remove <package>`
- Sync dependencies: `uv sync`

## Running Python Code

- Run a Python script with `uv run <script-name>.py`
- Run Python tools like Pytest with `uv run pytest` or `uv run ruff`
- Launch a Python repl with `uv run python`

## Managing Scripts with PEP 723 Inline Metadata

- Run a Python script with inline metadata (dependencies defined at the top of the file) with: `uv run script.py`
- You can add or remove dependencies manually from the `dependencies =` section at the top of the script, or
- Or using uv CLI:
    - `uv add package-name --script script.py`
    - `uv remove package-name --script script.py`

## uv with docker
- When building containers with docker for a uv based project, follow https://docs.astral.sh/uv/guides/integration/docker/
- If you need a specific python version, use uv to install, beung sure to mount the cache

# Docker & Container Patterns
When using Docker, it's essential to follow best practices for containerization and orchestration. Here are some key points to consider:

* Multi-stage Builds: Use multi-stage builds to optimize Docker images by reducing the size and complexity of the image layers. 
* Container Optimization: Optimize Docker images for performance and resource efficiency by removing unnecessary layers and dependencies. 
* Docker Compose Orchestration: Use Docker Compose to manage multiple containers and their dependencies easily. 
* Security Best Practices: Implement security measures such as non-root execution, read-only filesystems, and vulnerability scanning to protect your containerized environment. 
* Production-Ready Workflows: Ensure your containerized workflows are production-ready by testing and validating them thoroughly before deployment. 

By adhering to these best practices, you can create a secure and efficient containerized environment for using Claude Code, enhancing your development workflow and ensuring the safety of your projects.


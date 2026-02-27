# Global Learnings

Cross-project patterns and discoveries that apply across codebases.

## Build Systems

### Wave Synchronization Across GPU Architectures (2026-02-27)
**Insight**: RDNA (AMD) uses wave32 synchronization primitive, matching CUDA's warp32. This allows kernel code to be shared between HIP and CUDA with only `#ifdef __HIP_PLATFORM_AMD__` guards for includes (cooperative_groups header location differs).

**Context**: When porting GPU kernels to multiple vendors, wave/warp size compatibility is the primary blocker. If AMD changes to wave64 in future generations, synchronization barriers and shuffle operations would break despite shared memory layout.

### P&R Post-Fill Netlist Bloat (2026-02-27)
**Insight**: Place-and-route tools generate 4M+ filler/decap cells in post-fill netlists. These consume no area in functional simulation and can be dropped in favor of post-routing intermediate versions (~40x size reduction, 200MB → 5MB).

**Context**: When moving synthesis output through P&R and into simulation, check netlist sizes early. GitHub's 100MB hard limit on artifacts catches this late. Post-detailed-routing netlist is functionally identical for simulation purposes.

## APIs & Libraries

### Verilog Parser Escaped Identifier Handling (2026-02-27)
**Insight**: `sverilogparse` (Rust Verilog structural parser) cannot parse `!\escaped_name` (logical NOT immediately before backslash-escaped identifier). Using bitwise NOT (`~`) instead produces identical results for single-bit signals and is valid Verilog syntax that the parser accepts.

**Context**: When working with librelane P&R output or other synthesized netlists with unusual identifiers, prefer `~` over `!` for inversions. This appears in generated wrapper code and is not a user-facing issue, but matters when parsing generated Verilog.

### Build System Feature Flags for GPU Backends (2026-02-27)
**Insight**: Optional GPU backends (cuda, hip, metal) can be cleanly integrated via Cargo `#[cfg(feature = "...")]` without conditional compilation chaos. HIP support added with ~300 lines total (kernel wrapper, build.rs changes, dispatch logic) while leaving CUDA/Metal/CPU paths untouched.

**Context**: Multi-vendor GPU support benefits from explicit feature flags rather than auto-detection. This allows testing on platforms that don't have HIP/CUDA/Metal installed, and clear documentation of what you're enabling.

## Debugging Techniques

### Hypergraph Partitioning Resource Constraints (2026-02-27)
**Insight**: GPU block resource limits are hard constraints: max 8191 unique inputs/outputs, max 4095 intermediate pins per stage. Violations manifest as "single endpoint cannot map" errors with no recovery. Use `--level-split` to force pipeline stage boundaries before mapping, reducing partition complexity.

**Context**: When partition mapping fails on deep circuits, the error message doesn't indicate undersizing. Check logical depth and consider stage splits proactively. Partition time can exceed user patience; auto-splitting heuristics would improve usability.

## Tool Behaviors

### Yosys API Deprecation (2026-02-27)
**Insight**: Yosys 0.62+ renamed `read_ilang` to `read_rtlil`. Rebuild workflows must check Yosys version compatibility. This is not backward-compatible; old scripts break silently or fail with "no such command" errors.

**Context**: When automating synthesis workflows, pin Yosys version or add version detection. This affects CI/rebuild systems that may pull latest Yosys. No deprecation period observed; name just changed.


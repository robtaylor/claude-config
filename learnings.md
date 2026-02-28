# Global Learnings

Cross-project patterns and discoveries that apply across codebases.

## GPU Simulation & Timing

### GPU Double-Buffer Stage Synchronization in Kernel Pipelines (2026-02-28)
**Insight**: Multi-stage GPU kernels with double-buffering (input stage, compute stage, output stage) require careful synchronization when reading back computed values. If you read a value at the wrong stage, you get stale data from the previous iteration. This manifests as timing metadata lag or incorrect arrival times.

**Context**: When implementing GPU kernels with pipelined execution and double-buffering, ensure read operations happen at the correct stage. Metal kernels and CUDA threadblocks may have different synchronization semantics; test both code paths independently.

### SDF Timing Extraction: Post-PnR Always Trumps Pre-PnR (2026-02-28)
**Insight**: SDF timing files from post-place-and-route (post-PnR) are canonical and supersede pre-PnR timing. Pre-PnR timing is estimated, post-PnR reflects actual routed delays (parasitic RC extraction, interconnect). When both versions exist, discard pre-PnR to avoid timing confusion.

**Context**: Multi-stage physical design flows (synthesis → place-and-route → sign-off) produce multiple timing snapshots. Always prefer the latest, most-refined timing (post-PnR/post-sign-off) for accuracy. Implement explicit version preference in timing extraction pipelines.

### P&R Tool Robustness: Fallback Strategy for Sign-Off Crashes (2026-02-28)
**Insight**: Commercial P&R tools (e.g., librelane) can crash during sign-off checks (IR drop, antenna, DRC) despite successful routing. Instead of treating crash as fatal, fall back to the intermediate routed netlist which often contains most routing information with a subset of sign-off checks skipped.

**Context**: When integrating P&R into CI pipelines, implement graceful degradation: catch P&R crashes, check for intermediate outputs, and use best-available result. This enables progress even when final sign-off hangs. Document which optimizations/checks were skipped in the fallback path.

## Build Systems & Infrastructure

### ccache Integration in Makefiles (2026-02-28)
**Insight**: ABC's incremental build system can be significantly accelerated by enabling `ccache` in the Makefile. Adding conditional ccache wrapper (check for existence, fallback gracefully) speeds up rebuild cycles by 3-5x without breaking clean builds.

**Context**: Large C/C++ projects with Makefiles benefit from transparent ccache integration. Unlike CMake, Makefile-based builds need explicit ccache configuration via CC/CXX variables.

## Logic Synthesis & Optimization

### AIG Round-Trip Origin Loss via Aig_Man_t (2026-02-28)
**Insight**: Converting GIA (Gia_Man_t) → AIG (Aig_Man_t) → GIA loses per-object metadata because Aig_Man_t structure has no origin field. Cannot recover via direct reverse mapping; must anchor on invariant CO driver mappings and propagate backward through fanin cones.

**Context**: When implementing metadata (origins, attributes, source locations) across graph representations with different structure definitions, identify invariant anchor points (combinational outputs, primary inputs) that survive conversion losslessly. Then use those anchors to seed backward propagation for missing data.

### Structural Hashing Changes Object Identities (2026-02-28)
**Insight**: ABC's `&read` command (without `-s` flag) enables structural hashing by default, which renumbers all AIG objects to create a canonical representation. Cannot map objects via direct index correspondence; must use the vNodes vector mapping returned by the reader.

**Context**: When reading AIGs with potential structural optimization, always retrieve and use the identity mapping vector rather than assuming object IDs remain stable. This applies to any graph-based optimizer that implements deduplication.

### Per-AND Origin Tracking in Synthesis Maps (2026-02-28)
**Insight**: Synthesis tool map files (.sym) record \src attributes per AND object, NOT per primary input. Bottom-up origin propagation from inputs yields incomplete coverage; top-down propagation from combinational outputs through fanin cones achieves 100%.

**Context**: When backtracking from synthesis output to source code, trace backward from observable outputs rather than forward from inputs. Output-driven propagation captures all optimization artifacts (merged gates, partial logic), while input-driven propagation misses internal nodes.

### IF Mapper Origin Propagation via iCopy (2026-02-28)
**Insight**: ABC's IF mapper (Gia_ManIf) duplicates GIA structure during mapping; origins must be propagated via If_Obj_t::iCopy field which tracks the original object each mapped gate came from. Failure to propagate during If_ObjNew() calls loses origin ancestry.

**Context**: When implementing mappers that duplicate graph structure, ensure every new object carries a reference to its source, then use that reference to seed origin/attribute propagation in post-mapping fusion.

## APIs & Libraries

### XAIGER "y" Extension Variable-Length Encoding (2026-02-28)
**Insight**: The XAIGER "y" extension packs per-object origins into variable-length arrays (similar to ULEB128) achieving ~30% space savings vs. storing uint32 per object. Offset tracking during write/read must account for variable sizes—cannot index into the array with object IDs directly.

**Context**: When extending binary graph formats, variable-length encoding saves substantial space for sparse metadata but requires careful offset calculation during serialization. Pre-compute cumulative offsets or use an offset index to avoid O(n) lookups during deserialization.

## Debugging Techniques

### CO Driver Mapping for Round-Trip Recovery (2026-02-28)
**Insight**: After GIA round-trips (GIA→AIG→GIA), combinational outputs (COs) maintain 1:1 mapping between old and new GIA. Use CO drivers as anchor points to seed origin recovery, then propagate backward through fanin cones. This recovers ~90% of missing origins that were lost during AIG conversion.

**Context**: When metadata is lost during intermediate transformations with no direct reverse mapping available, identify structural invariants (outputs, dedicated pins) that survive conversion, and use them as anchors for backward propagation of derived metadata.

### Rehashing Invalidates Direct Object Pointers (2026-02-28)
**Insight**: Gia_ManRehash can reallocate the Gia_Obj_t array, invalidating any stored pointers to objects. After rehashing, must refresh vNodes mappings and re-index any per-object arrays. This is a common source of subtle memory corruption bugs.

**Context**: In graph-based data structures where structure array reallocation occurs during optimization, always use object IDs (handles) rather than stored pointers. If pointers are unavoidable, refresh them after any operation that might reallocate the array.

## GPU Sparse Solvers

### Metal Deferred GPU Synchronization for Operation Batching (2026-02-28)
**Insight**: Metal command queues guarantee sequential execution but have high per-submission overhead (~1-2ms per buffer on M-series). Instead of immediately submitting command buffers after each GPU operation (potrf, trsm, GEMM), defer submission until necessary (before readback or dependent CPU work). Batch sequential operations into single buffers: e.g., potrf→trsm into one buffer, GEMM→assemble into another. This reduces command queue pressure and saves ~25% latency on single factorization workflows.

**Context**: When optimizing GPU solvers on Metal (especially for small problems where kernel execution time is <5ms), profiling often shows command submission overhead dominates actual compute. Use `commitPending()`/`waitForGpu()` pattern: accumulate operations without committing, then flush when necessary. Key gotcha: must explicitly `flush()` or `waitForGpu()` before reading GPU data back via `get()`, otherwise you read stale values from before submission.


### Quick Validation
Run with Metal API + GPU validation to check for shader errors, buffer overruns, etc:
```bash
MTL_SHADER_VALIDATION=1 METAL_DEVICE_WRAPPER_TYPE=1 ./build_metal/baspacho/tests/MetalLUTest
```

### GPU Kernel Profiling (Recommended)
Log every Metal kernel dispatch with GPU execution time:
```bash
BASPACHO_METAL_PROFILE=1 ./build_metal/baspacho/tests/MetalLUTest \
  --gtest_filter="MetalLU.BlockSparse_float"
```
Output shows kernel name, thread count, and GPU time per dispatch, e.g.:
```
[GPU] lu_getrf_kernel_float                  threads=1   gpu=0.004ms
[GPU] lu_applyRowPerm_kernel_float           threads=1   gpu=0.003ms
[GPU] lu_trsmUpperRight_kernel_float         threads=1   gpu=0.004ms
```
This confirms all operations run on GPU (no CPU fallbacks).

### Programmatic GPU Capture (Recommended for CLI apps)
For CLI (non-GUI) apps, `xctrace` Metal System Trace often shows "No Graphs" for GPU.
Use **programmatic capture** via `MTLCaptureManager` instead — this produces a `.gputrace`
file that opens in Xcode with full GPU debugger (kernel names, buffers, timeline).

BaSpaCho has built-in capture support via `MetalContext::beginCapture()`/`endCapture()`.
The MetalLUTest `BlockSparse_float` test supports capture via env var:

```bash
# Capture a .gputrace of the LU test (opens in Xcode GPU debugger)
rm -rf /tmp/baspacho_lu.gputrace
METAL_CAPTURE_ENABLED=1 BASPACHO_GPU_CAPTURE=1 \
  ./build_metal/baspacho/tests/MetalLUTest --gtest_filter="MetalLU.BlockSparse_float"
open /tmp/baspacho_lu.gputrace   # Opens in Xcode
```

**Requirements**: `METAL_CAPTURE_ENABLED=1` env var must be set before process launch
(enables `MTLCaptureManager` for non-Xcode-launched apps).

### xctrace Metal System Trace (Alternative)
For driver-level timing (not individual kernel names), use `xctrace`:
```bash
# Use --gtest_repeat for enough GPU activity (short runs may show "No Graphs")
xctrace record --template "Metal System Trace" \
  --output /tmp/metal_trace.trace \
  --launch -- ./build_metal/baspacho/tests/MetalLUTest --gtest_repeat=20
open /tmp/metal_trace.trace

# CLI export: count GPU compute dispatches
xctrace export --input /tmp/metal_trace.trace \
  --xpath '/trace-toc/run[@number="1"]/data/table[@schema="metal-application-encoders-list"]' \
  2>&1 | grep -c '<row>'
```

**Note**: Must launch binary directly (not via shell script) or Instruments loses GPU tracking.

### What to Look For
- **Xcode GPU debugger** (`.gputrace`): Shows every compute dispatch with kernel function names, buffer bindings, thread group sizes, and execution timeline
- **xctrace encoder list**: Count of GPU dispatches confirms all operations on GPU
- **Driver Processing track** (purple bars in Instruments): Shows command buffer scheduling on GPU

## CUDA GPU Profiling (NVIDIA / Nsight Systems)

### nsys Profile (No Code Changes Needed)
`nsys` (Nsight Systems CLI) captures all CUDA API calls, kernel launches, cuBLAS/cuSolver calls,
and memory transfers automatically:
```bash
# Full profile with CUDA kernel trace
nsys profile --trace=cuda,nvtx,osrt \
  --output /tmp/cuda_lu_profile \
  ./build/baspacho/tests/CudaLUTest --gtest_filter="CudaLU.BlockSparse_double"

# View summary in terminal
nsys stats /tmp/cuda_lu_profile.nsys-rep

# Open in Nsight Systems GUI
nsys-ui /tmp/cuda_lu_profile.nsys-rep
```

### What to Check in nsys Output
- **CUDA API Summary**: All LU operations should appear as `cusolverDn[D/S]getrf`,
  `cublas[D/S]trsm`, `cublas[D/S]gemm`, and custom CUDA kernels
  (`transposeSquareInPlaceKernel`, `applyRowPermKernel`, `applyRowPermVec[Inv]Kernel`)
- **Memory Transfers**: Only small pivot arrays (n ints per lump) should show as
  `cudaMemcpy` H↔D. No large matrix data transfers.
- **GPU Timeline**: Continuous GPU activity with no CPU compute gaps
- **Kernel Duration**: Shows actual GPU execution time per kernel

### Quick Check (CI-friendly)
```bash
# Just list CUDA API calls to confirm no CPU fallbacks
nsys profile --trace=cuda --stats=true \
  ./build/baspacho/tests/CudaLUTest --gtest_filter="CudaLU.BlockSparse_double" 2>&1 \
  | grep -E "cublas|cusolver|Kernel|cudaMemcpy"
```



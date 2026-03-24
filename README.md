# Android Kernel Builder Action

A GitHub Actions workflow to automate the compilation and patching of an Android 13 (5.15) kernel. This workflow allows you to completely customize your kernel build natively in the cloud, injecting modern features like KernelSU, susfs4ksu, and performance optimizations.

## Features Supported
- **Auto-fetches Proton-Clang toolchain**
- **KernelSU & Kernel Patch Manager (KPM)** integration 
- **susfs4ksu** specifically targeted toward 5.15
- **sukisu-ultra** support
- **nomount** patches for namespace hiding
- **Performance Adjustments**: zRAM algorithms (LZ4/Zstd), TCP BBR Congestion Control, and VFS Cache Optimizations.
- **AnyKernel3 Package**: Spits out an `AnyKernel3-Kernel.zip` with `Image.lz4` for immediate flashing in TWRP or KernelSU.

## How to use
1. Fork or push this repository to your GitHub account.
2. Go to the **Actions** tab.
3. Select **Build Custom Android Kernel**.
4. Click **Run workflow** and provide your specific variables:
   - `KERNEL_SOURCE`: Link to the GitHub/GitLab repo of the kernel source tree.
   - `KERNEL_BRANCH`: The branch to checkout (e.g. `android13-5.15`).
   - `DEFCONFIG`: The configuration file name under `arch/arm64/configs/` (e.g. `vendor/my_device_defconfig`).
5. Select which patches you want to integrate.
6. Let it run! You'll find the output zip in the Artifacts section when it finishes.

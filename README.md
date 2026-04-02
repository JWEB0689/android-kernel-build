# 🔧 Universal Android Kernel Builder — rtwo

> Automated GitHub Actions pipeline for building hardened Android 13 (5.15 KMI) kernels for the Motorola Edge+ (rtwo).

## ✨ What This Builds

A fully featured, flashable AnyKernel3 ZIP that includes:

- **Kernel Image** — Compiled from your chosen source against android13-5.15 KMI
- **KernelSU** — Kernel-level root (SukiSU, Tiann, KernelSU-Next, ReSukiSU, WKSU)
- **SUSFS** — Root hiding via filesystem syscall hooks (two modes)
- **Zeromount** — VFS path redirection, zero mount-table pollution
- **SUSFS Module** — Userspace companion module auto-flashed at install time
- **KSU APK** — Manager APK copied to /sdcard/KSU/ for post-reboot install

## ⚙️ Features

### Root & Privacy
- 5 KernelSU fork options: SukiSU, Tiann, KernelSU-Next, ReSukiSU, WKSU
- SUSFS modes: SUSFS_only (ShirkNeko), NoMount_SUSFS (maxsteeel VFS patch), None

### Smart AnyKernel3 Installer
- Volume-key prompts during flash: VOL+ = Yes, VOL- = No
  - Install SUSFS module?
  - Install Zeromount module?
  - Copy KSU APK to /sdcard/KSU/?

### Performance
- BBR + ECN TCP congestion control
- Thin LTO optimization
- ccache (10 GB) for repeat builds
- 20 GB swap to prevent OOM during linking
- Choice of Clang: ZyC, Greenforce, WeebX, SuperRyzen, or System

### Advanced
- KPM (Kernel Patch Module) binary patching via patch_linux
- Private kernel source support via PRIVATE_REPO_TOKEN secret
- Patch reject artifact uploaded on failure

## 🚀 How to Use

### 1. Set up Secrets (Settings → Secrets → Actions)

| Secret | Required | Purpose |
|--------|----------|---------|
| PRIVATE_REPO_TOKEN | Only for private sources | GitHub PAT with repo scope |

### 2. Trigger a Build

1. Go to Actions → Universal Kernel Builder — rtwo
2. Click Run workflow
3. Fill in the inputs (kernel_repo and kernel_branch are required)

### 3. Flash via TWRP

1. Download the AnyKernel3 ZIP artifact
2. Boot into TWRP recovery
3. Flash the ZIP
4. Answer prompts with VOL+ (Yes) or VOL- (No)
5. After reboot, install KSU Manager from /sdcard/KSU/

## Build Pipeline

1. Free disk space + 20 GB swap
2. Install build tools + fetch Clang toolchain
3. Clone kernel source
4. Apply KernelSU (chosen fork)
5. Apply SUSFS patches (chosen mode)
6. Configure defconfig (KSU + SUSFS + BBR + KPM)
7. Build kernel with ccache + LLVM + LTO
8. Optional KPM patch_linux on Image
9. Download addon ZIPs + APK
10. Generate anykernel.sh with volume-key prompts
11. Upload AnyKernel3 ZIP artifact

## SUSFS Mode Comparison

| Mode | How it works | Mount entries |
|------|-------------|--------------|
| SUSFS_only | Syscall hooks hide KSU paths | Some |
| NoMount_SUSFS | VFS-layer patch — zero bind mounts | Zero |
| None | Raw KernelSU, no hiding | N/A |

## Troubleshooting

**Patch rejects:** Download the Rejects artifact, inspect .rej files. Try susfs_mode None to confirm base build works.

**KSU APK:** Install from /sdcard/KSU/ after first reboot — not installable from recovery.

**VOL key prompts missing:** Some recoveries lack getevent. Flash modules manually as separate ZIPs afterwards.

**Hanging on vmlinux:** LTO linking takes 10-15 minutes of silence — do not cancel.

## Component Sources

- SukiSU: SukiSU-Ultra/SukiSU-Ultra
- KernelSU: tiann/KernelSU
- KernelSU-Next: KernelSU-Next/KernelSU-Next
- SUSFS patches: ShirkNeko/susfs4ksu
- SUSFS module: sidex15/ksu_module_susfs
- NoMount patch: maxsteeel/nomount
- Zeromount: Enginex0/zeromount
- AnyKernel3: JWEB0689/AnyKernel3

## License

GPL-3.0 — Kernel source and bundled components retain their respective upstream licenses.

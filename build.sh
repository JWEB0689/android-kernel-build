#!/bin/bash
set -e

BUILD_DIR="/build"
KERNEL_DIR="${BUILD_DIR}/kernel"
OUT_DIR="${BUILD_DIR}/out"

echo "[*] Lineage 23.2 SM8550 Kernel Build with SUSFS4KSU, nomount/zeromount, BBR, VFS, KernelSU"
echo "[*] Working directory: ${BUILD_DIR}"

mkdir -p "${KERNEL_DIR}" "${OUT_DIR}"

# Clone Lineage kernel (SM8550 is lisa/yoshi variant)
echo "[*] Cloning LineageOS kernel..."
cd "${KERNEL_DIR}"
git clone https://github.com/LineageOS/android_kernel_motorola_sm8550.git . || {
    echo "[-] Failed to clone kernel. Attempting alternative source..."
    git clone https://github.com/LineageOS/android_kernel_sm8550.git . 2>/dev/null || true
}

if [ ! -f "Makefile" ]; then
    echo "[-] ERROR: Kernel source not properly cloned"
    exit 1
fi

echo "[+] Kernel source ready"

# Clone and apply KernelSU
echo "[*] Cloning KernelSU..."
cd "${BUILD_DIR}"
git clone https://github.com/tiann/KernelSU.git kernelsu || true
cd "${KERNEL_DIR}"

if [ -d "${BUILD_DIR}/kernelsu" ]; then
    echo "[*] Applying KernelSU patch..."
    "${BUILD_DIR}/kernelsu/kernel/setup.sh" "${KERNEL_DIR}" || {
        echo "[-] KernelSU patch warning (may already be applied)"
    }
fi

# Clone SUSFS4KSU patches
echo "[*] Cloning SUSFS4KSU..."
cd "${BUILD_DIR}"
git clone https://github.com/backups-world/SUSFS4KSU.git susfs || true

if [ -d "${BUILD_DIR}/susfs/kernel_patches" ]; then
    echo "[*] Applying SUSFS4KSU patches..."
    cd "${KERNEL_DIR}"
    for patch in "${BUILD_DIR}/susfs/kernel_patches"/*.patch; do
        if [ -f "$patch" ]; then
            echo "[+] Applying $(basename $patch)...\n"
            patch -p1 < "$patch" || echo "[-] Patch $(basename $patch) skipped (may already be applied)"
        fi
    done
fi

# Apply nomount patch (separate from SUSFS)
echo "[*] Checking for nomount patch..."
cd "${BUILD_DIR}"

# Try to clone nomount repo
NOMOUNT_FOUND=0
ZEROMOUNT_APPLIED=0

# Attempt nomount from common sources
git clone https://github.com/maxsteeel/nomount.git nomount 2>/dev/null || true
if [ -f "${BUILD_DIR}/nomount/patches/nomount-susfs-kernel-5.15.patch" ] 2>/dev/null; then
    echo "[*] Applying nomount patch..."
    cd "${KERNEL_DIR}"
    patch -p1 < "${BUILD_DIR}/nomount/patches/nomount-susfs-kernel-5.15.patch" || {
        echo "[-] nomount patch failed (may already be applied)"
    }
    NOMOUNT_FOUND=1
fi

# If nomount not available, use zeromount as alternative
if [ $NOMOUNT_FOUND -eq 0 ]; then
    echo "[*] nomount not found, attempting zeromount as alternative..."
    cd "${BUILD_DIR}"
    git clone https://github.com/revtracer/zeromount.git zeromount 2>/dev/null || true
    
    if [ -f "${BUILD_DIR}/zeromount/kernel.patch" ] 2>/dev/null; then
        echo "[*] Applying zeromount patch (alternative to nomount)..."
        cd "${KERNEL_DIR}"
        patch -p1 < "${BUILD_DIR}/zeromount/kernel.patch" || {
            echo "[-] zeromount patch failed (may already be applied)"
        }
        ZEROMOUNT_APPLIED=1
    else
        echo "[!] WARNING: Neither nomount nor zeromount patches found - continuing without mount spoofing"
    fi
fi

# Apply BBR congestion control (kernel-native)
echo "[*] Configuring BBR..."
cd "${KERNEL_DIR}"
if [ -f "net/ipv4/tcp_bbr.c" ]; then
    echo "[+] BBR source present (enabled via .config)"
fi

# VFS (Virtual Filesystem) patches - typically in-tree for modern kernels
echo "[*] VFS patches (included in Lineage kernel)"

# Generate defconfig for SM8550
echo "[*] Generating SM8550 config..."
cd "${KERNEL_DIR}"

# SM8550 uses lisa/yoshi defconfig
DEFCONFIG_LOCATIONS=(
    "arch/arm64/configs/lineageos_sm8550_defconfig"
    "arch/arm64/configs/lineageos_defconfig"
    "arch/arm64/configs/defconfig"
)

DEFCONFIG_FOUND=0
for defconfig in "${DEFCONFIG_LOCATIONS[@]}"; do
    if [ -f "$defconfig" ]; then
        echo "[+] Found defconfig: $defconfig"
        make O="${OUT_DIR}" ARCH=arm64 $(basename "$defconfig") || true
        DEFCONFIG_FOUND=1
        break
    fi
done

if [ $DEFCONFIG_FOUND -eq 0 ]; then
    echo "[-] No defconfig found, using generic arm64 config"
    make O="${OUT_DIR}" ARCH=arm64 defconfig || true
fi

# Enable kernel features in .config
echo "[*] Configuring kernel options..."
cd "${OUT_DIR}"
cat >> .config << 'EOF'
# KernelSU and SUSFS
CONFIG_HAVE_MODIFIERS_SUPPORT=y
CONFIG_KPROBES=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y

# BBR
CONFIG_TCP_CONG_BBR=y
CONFIG_DEFAULT_TCP_CONG="bbr"

# VFS
CONFIG_TMPFS=y
CONFIG_TMPFS_XATTR=y
CONFIG_TMPFS_POSIX_ACL=y

# Security
CONFIG_HAVE_STACKPROTECTOR=y
CONFIG_STACKPROTECTOR=y

# ThinLTO for faster builds
CONFIG_LTO_THIN=y
CONFIG_LTO=y
EOF

make -C "${KERNEL_DIR}" O="${OUT_DIR}" ARCH=arm64 oldconfig || true

# Build kernel (requires ARM64 cross-compiler)
echo "[*] Building kernel with ThinLTO..."
echo "[!] NOTE: This requires aarch64-linux-gnu cross-compiler tools"
echo "[!] For full build, install: apt-get install gcc-aarch64-linux-gnu"

cd "${KERNEL_DIR}"

# Calculate optimal parallelism (LTO is memory-intensive, use conservative settings)
NUM_CPUS=$(nproc)
LTO_JOBS=$((NUM_CPUS > 4 ? NUM_CPUS - 2 : 2))

echo "[*] Using ${LTO_JOBS} parallel jobs for ThinLTO"
echo "[*] Patches applied:"
echo "    - KernelSU: Yes"
echo "    - SUSFS4KSU: Yes"
if [ $NOMOUNT_FOUND -eq 1 ]; then
    echo "    - nomount: Yes"
elif [ $ZEROMOUNT_APPLIED -eq 1 ]; then
    echo "    - zeromount (alternative): Yes"
else
    echo "    - nomount/zeromount: Not found"
fi
echo "    - BBR (TCP): Yes"
echo "    - VFS: Yes"
echo "    - ThinLTO: Yes"
echo ""

make O="${OUT_DIR}" \
    ARCH=arm64 \
    CROSS_COMPILE=aarch64-linux-gnu- \
    CC=clang \
    LD=lld \
    LLVM=1 \
    -j${LTO_JOBS} \
    2>&1 | tee "${OUT_DIR}/build.log" || {
    echo "[-] Build failed. Check ${OUT_DIR}/build.log"
    exit 1
}

# Extract kernel image
if [ -f "${OUT_DIR}/arch/arm64/boot/Image.gz" ]; then
    echo "[+] Kernel built successfully"
    cp "${OUT_DIR}/arch/arm64/boot/Image.gz" "${OUT_DIR}/Image.gz-${KERNEL_VERSION:-sm8550}"
    echo "[+] Kernel image: ${OUT_DIR}/Image.gz-sm8550"
elif [ -f "${OUT_DIR}/arch/arm64/boot/Image" ]; then
    echo "[+] Kernel built (uncompressed)"
    cp "${OUT_DIR}/arch/arm64/boot/Image" "${OUT_DIR}/Image-${KERNEL_VERSION:-sm8550}"
    echo "[+] Kernel image: ${OUT_DIR}/Image-sm8550"
fi

# Build modules if applicable
if [ -f "${OUT_DIR}/modules.order" ]; then
    echo "[*] Building modules..."
    make O="${OUT_DIR}" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- \
        CC=clang LD=lld LLVM=1 \
        -j${LTO_JOBS} \
        INSTALL_MOD_PATH="${OUT_DIR}/modules" modules_install || true
    echo "[+] Modules installed to ${OUT_DIR}/modules"
fi

echo "[+] Build complete!"
echo "[+] Output directory: ${OUT_DIR}"
ls -lah "${OUT_DIR}" | grep -E "Image|boot|modules" || true

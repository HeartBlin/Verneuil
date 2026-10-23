{ lib, pkgs, ... }:

let
  targetLlvm = pkgs.llvmPackages_23;
  llvmStdenv = pkgs.overrideCC targetLlvm.stdenv (
    targetLlvm.stdenv.cc.override { bintools = targetLlvm.bintools; }
  );

  borePatch = {
    name = "bore-scheduler";
    patch = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/firelzrd/bore-scheduler/refs/heads/main/patches/stable/0001-linux7.3-rc2-bore-7.0.0.patch";
      hash = "sha256-DeD1bC49sUtLsnl6oDYqYj1LfjlkOt0dpl+Roc7c3P0=";
    };
  };
in
  pkgs.linux_latest.override (old: {
    stdenv = llvmStdenv;
    extraMakeFlags =
      (old.extraMakeFlags or [ ])
      ++ [
        "LLVM=1"
        "KCFLAGS=-march=znver2"
      ];

    kernelPatches = (old.kernelPatches or [ ]) ++ [ borePatch ];
    structuredExtraConfig = let
      inherit (lib.kernel) yes no freeform unset;
      forceNo = x: lib.genAttrs x (_: lib.mkForce no);
      forceUnset = x: lib.genAttrs x (_: lib.mkForce unset);
    in
      (old.structuredExtraConfig or { })
      // {
        SCHED_BORE = yes;
        HZ = freeform "1000";
        HZ_1000 = yes;
        PREEMPT = lib.mkForce yes;
        LTO_CLANG_THIN = lib.mkForce yes;
      }
      // forceNo [
        "DRM_AMDGPU_CIK"
        "DRM_AMDGPU_SI"
        "DRM_I915"
        "DRM_NOUVEAU"
        "DRM_XE"
        "LTO_CLANG_FULL"
        "LTO_NONE"
        "PREEMPT_LAZY"
        "SCHED_CLASS_EXT"
        "IIO"

        "ATM"
        "CAN"
        "COMEDI"

        "FPGA"
        "GREYBUS"
        "IIO"
        "INFINIBAND"
        "NFC"
        "PARPORT"
        "PCMCIA"
        "WWAN"
        "FIREWIRE"
        "FIREWIRE_NOSY"
      ]
      // forceUnset [
        # RIP Rust
        "RUST"

        # Remove Android
        "ANDROID"
        "ANDROID_BINDER_IPC"
        "ANDROID_BINDERFS"
        "ANDROID_BINDER_DEVICES"

        "STAGING"
        "STAGING_MEDIA"
        "W1"
        "ISDN"
        "INFINIBAND_IPOIB"
        "INFINIBAND_IPOIB_CM"
        "SCSI_LOWLEVEL_PCMCIA"

        # Fixing errors
        "DRM_AMD_DC_SI"
        "DRM_I915_GVT"
        "DRM_I915_GVT_KVMGT"
        "DRM_NOUVEAU_SVM"
        "DRM_NOVA"
        "DRM_PANIC_SCREEN_QR_CODE"
        "NOVA_CORE"

        # Cleanup warnings
        "CRC32_SELFTEST"
        "CRYPTO_TEST"
        "EXT3_FS_POSIX_ACL"
        "EXT3_FS_SECURITY"
        "GLOB_SELFTEST"
        "POWER_RESET_GPIO"
        "POWER_RESET_GPIO_RESTART"
        "XEN_SAVE_RESTORE"
      ];
  })

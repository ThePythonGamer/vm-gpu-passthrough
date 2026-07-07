# Research Notes: KVM/QEMU XML Configuration for Hypervisor Cracks

Based on the [Reddit discussion](https://www.reddit.com/r/PiratedGames/comments/1rft2u1/has_anyone_successfully_run_hypervisor_cracks_eg/), users successfully managed to run hypervisor-based cracks (e.g., MkDev, 0xZeOn, KIRIGIRI) inside a KVM/QEMU Windows VM with GPU passthrough by specifically tweaking their CPU and Hyper-V features in the VM's XML configuration.

## 1. Optimal Hyper-V XML Configuration

To prevent the hypervisor crack from freezing or crashing the VM while maintaining good performance, you must use a `custom` Hyper-V mode and toggle specific enlightenments. The most crucial part of this fix involves turning off `tlbflush` and `ipi`.

Merge the following into your VM's XML:

```xml
  <features>
    <acpi/>
    <apic/>
    <hyperv mode="custom">
      <relaxed state="on"/>
      <vapic state="on"/>
      <spinlocks state="on"/>
      <vpindex state="on"/>
      <runtime state="on"/>
      <synic state="on"/>
      <stimer state="on"/>
      <frequencies state="on"/>
      <tlbflush state="off"/> <!-- Crucial for crack compatibility -->
      <ipi state="off"/>      <!-- Crucial for crack compatibility -->
      <avic state="on"/>
    </hyperv>
  </features>
  
  <cpu mode="host-passthrough" check="none" migratable="on">
    <!-- Make sure to update topology cores/threads based on your actual CPU -->
    <topology sockets="1" dies="1" clusters="1" cores="12" threads="1"/>
    <cache mode="passthrough"/>
  </cpu>
  
  <clock offset="localtime">
    <timer name="hpet" present="yes"/>
    <timer name="hypervclock" present="yes"/>
  </clock>
```

## 2. Troubleshooting Crashes

If your VM still freezes or hangs upon running the crack with the above configuration, users recommend disabling additional Hyper-V features:

```xml
      <relaxed state="off"/>
      <spinlocks state="off"/>
      <vapic state="off"/>
```

## 3. Masking KVM / Additional Tweaks

One user (with an Intel CPU) successfully used additional toggles to disguise the VM more heavily. If the basic setup doesn't work, you might want to try these additions inside the `<features>` block:

```xml
      <!-- Inside <hyperv> -->
      <spinlocks state="on" retries="8191"/>
      <vendor_id state="on" value="GenuineIntel"/> <!-- Change to AuthenticAMD for AMD CPUs -->
      <evmcs state="on"/>
      
    <!-- Outside <hyperv>, still inside <features> -->
    <kvm>
      <hidden state="on"/>
    </kvm>
    <vmport state="off"/>
```

## 4. Fixing the "A hypervisor is already running" Error

If you launch the game and receive an error stating: `"A hypervisor is already running and AutoLoadHV is set to true!"`, follow these steps:

1. Navigate to the game folder's `\bin64` directory.
2. Open `denuvowo.ini` and set `AutoLoadHV=false`.
3. Locate the `/driver_intel/` or `/driver_amd/` folder (depending on your CPU). Find the path to the driver file (e.g., `hyperkd.sys` for Intel).
4. Open an **Administrator Command Prompt** (not PowerShell) and register the driver manually:
   ```cmd
   sc create denuvo type=kernel start=auto binPath="C:\Path\To\yourdriver.sys"
   sc start denuvo
   ```
5. Run the game's `.exe` file.

---

**Additional Resource:**
A full working VM configuration (XML) from the thread was also uploaded as a Gist: [NullCode1337 VM Configuration](https://gist.github.com/NullCode1337/1cf8e71d29296efa47e3f3d37d503713)

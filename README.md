# autonomous-asplos21-artifact
Autonomous NIC offloads ASPLOS'21 Artifact Evaluation
=====================================================

This repository contains scripts for ASPLOS'21 artifact evaluation
of the **Autonomous NIC offloads** paper by Boris Pismenny, Haggai Eran,
Aviad Yehezkel, Liran Liss, Adam Morrison, and Dan Tsafrir.

The scripts in this paper can be used to reproduce:
* Figure 9: NVMe-TCP/fio cycles per random read on the server
(drive resides on the generator); “%” shows copy+crc out of the total.
* Figure 10: Kernel-TLS/iperf per-record cycles when using AES-GCM
crypto operations (encryption, decryption, and authentication
using AES-NI).


Authors
-------

* Boris Pismenny (Technion and Mellanox)
* Haggai Eran (Technion and Mellanox)
* Aviad Yehezkel (Mellanox)
* Liran Liss (Mellanox)
* Adam Morrison (Tel-Aviv University)
* Dan Tsafrir (Technion and VMware)


Directory structure
-------------------

* `TestSuite/Tests` tests used for the paper. Each test is a unique experiment (see "Experiments" below for specific Figures)
* `TestSuite/Conf` configuration files. To run on your own machine pair create a new file here. See workflow in "Setup configuration" below
* `TestSuite/Process` scripts to process experimental results
* `TestSuite/DataCollector` scripts to collect results while running experiments
* `Results` Directory where test run results will be placed
* `linux` Linux kernel modifed to provide cycle breakdown, TLS offload, and NVMe-TCP offload emulation
* `nginx` Nginx modified to support TLS sendfile
* `iperf` IPerf2 modified to support TLS with OpenSSL
* `openssl` OpenSSL 3.0.0 (upstream). It already supports kernel TLS (and offload)
* `nvme-cli` nvme-cli (upstream) used to configure NVMe-TCP connection
* `fio` fio (upstrean) used for NVMe-TCP evaluation
* `scripts` Miscellaneous scripts for artifact evaluation


Hardware dependencies
---------------------

The experiments require two machines connected back-to-back.
The machines should support Intel AES-NI and ERMS. To
test whether on-CPU acceleration is enabled on a machine run:
```
./scripts/test_machine.sh
```

Additionally, for TLS offload experiments, we employ Mellanox ConnectX6-Dx
crypto enabled NICs. Specifically, we used part number MCX623106AC-CDA_Ax.

For NVMe-TCP experiments, we require that the remote (target) machine
has a disk. Specifically, we used an Intel Corporation Optane DC P4800X
Series SSD.


Software dependencies
---------------------

The code is tested on Ubuntu Ubuntu 16.04.2 LTS with our custom kernel patches applied over

We have modified the following libraries that need to be compiled:
* Linux kernel (TLS offload support, cycle breakdown for TLS and NVMe-TCP)
* OpenSSL (changes to support kernel TLS)
* IPerf support TLS using OpenSSL 
* Nginx use sendfile with kernel TLS
* Wrk with some scripts to benchmark nginx

Additionally, recent kernel versions requires packages that are not available by
default on Ubuntu, therefore we recommend using newer versions of:
* nvme-cli
* fio

Obtaining source code
---------------------

To obtain the source code for linux kernel and evaluated workloads perform:

```
git submodule init
git submodule update
```

To compile everything just type `make`

To compile the different binaries individually, type:

* linux kernel:  `make linux`
* linux kernel perf:  `make perf`
* openssl: `make openssl`
* iperf: `make iperf`
* nginx: `make nginx`
* nvme-cli: `make nvme-cli`
* fio: `make fio`
* wrk: `make wrk`

Note: openssl installation requires recent kernel headers to support kernel TLS.
To ensure that openssl is compiled correctly, go to the openssl directory and
run:
```
perl configdata.pm --dump
```
This will return the lists of enabled and disabled features.
Ensure that ktls is in the enabled features list.

Setup configuration
----------------------

To run the evaluations of the paper, you need a pair of machines
as prevoiusly described in "Hardware dependencies", and you need
to boot your machine with the provided linux kernel on both
sides.

The we need to configure both machines:
* Device under test machine (i.e., DUT)
* Load generator machine (i.e., loader)

### DUT configuration script
For an example see TestSuite/Conf/config\_dante732.sh

To create your own script that defines parameters about new machine
pairs add a new file under "TestSuite/Conf/". Impoartant parameters
to define are:
* TBASE: Path to TestSuite base
* loader1: Name of the load generator machine
* ip1: IP address of the first NIC of the DUT
* dip1: Destination IP address of the NIC connected to the DUT
* if1: Interface name of the NIC of the DUT
* dif1: Interface name on the loader1 machine connected to if1 NIC of the DUT
* mtu: Maximum Ethernet transmit unit
* SOCK\_SIZE: Default kernel socket buffer size

### Configuring the DUT and loader NICs
Using the setup configuration script we configure the NICs and interrupts
on both DUT and loader as follows (run it from the DUT):
```
source ./TestSuite/Conf/config\_dante732.sh;
./TestSuite/Conf/setup.sh;
```

### loader configuration script
For an example see TestSuite/Conf/config\_danger38.sh

The impoartant parameters here are:
* bigfile: This is the nvme device (/dev/nvme0n1) or the file that is
used instead. This file/block-device will be exposed over NVMe-TCP to the DUT.
* if1: the interface name that is connected to the DUT

### loader configuration
For NVMe-TCP tests, the loader machine must expose its local SSD. Alternatively,
you can load a memdisk on the loader machine using "TestSuite/Scripts/nvmet\_mem.sh"
script, or a null disk using "TestSuite/Scripts/nvmet\_null.sh"

For example, to run with /dev/nvme0n1 use:
```
source ./TestSuite/Conf/config\_danger38.sh;
./TestSuite/Scripts/nvmet_file.sh;
```

Additionally, nginx rely on a set of files that resides in ./nvme/mount".
These files are generated using the script at:
```
./TestSuite/Tests/nginx/generate_all_files.sh
```
These files can be either created locally in that directory or generated on the
loader disk, which is then mounted over NVMe-TCP in that directory.

Experiments
-----------

Before you start running the experiments, make sure you configured both
the DUT and the loader machine. For example by running this script for our
dante732 (DUT) and danger38 (loader):
```
./scripts/config_setup.sh
```

To run all experiments:

```
./scripts/run_all.sh
```

For running specific experiments:

* Figure 9 - NVMe-TCP/fio cycle breakdown - `./scripts/run_fio.sh`
* Figure 10 - Kernel-TLS/iperf per-record cycles  - `./scripts/run_iperf.sh`
* Figure 12 - Nginx with TLS offload  - `./scripts/run_nginx_tls.sh`

For plotting experimental results:

* Figure 9 - NVMe-TCP/fio cycle breakdown - `./scripts/plot_fio.sh <output>`
* Figure 10 - Kernel-TLS/iperf per-record cycles  - `./scripts/plot_iperf.sh`
* Figure 12 - Nginx with TLS offload  - `./scripts/plot_nginx_tls.sh`

Plotting our experimental results:

* Figure 9 - NVMe-TCP/fio cycle breakdown - `./scripts/plot_fio_test.sh`
* Figure 10 - Kernel-TLS/iperf per-record cycles - `./scripts/plot_iperf_test.sh`
* Figure 12 - Nginx with TLS offload  - `./scripts/plot_nginx_tls_test.sh`

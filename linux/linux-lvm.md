# LVM Cheet Sheet

```bash
export disks="/dev/nvme0n1 /dev/nvme2n1 /dev/nvme5n1 /dev/nvme6n1 /dev/nvme7n1"
for d in $disks; do wipefs $d; wipefs -a $d; done
pvcreate "$disks"
#disks="/dev/nvme0n1 /dev/nvme2n1 /dev/nvme5n1 /dev/nvme6n1 /dev/nvme7n1"; for d in $disks; do wipefs -a $d; done && pvcreate $disks
```

```bash
pvdisplay -s
```

```bash
vgcreate volgrp01 /dev/nvme0n1 /dev/nvme2n1 /dev/nvme5n1 /dev/nvme6n1 /dev/nvme7n1
vgextend volgrp01 /dev/nvme2n1 /dev/nvme5n1 /dev/nvme6n1 /dev/nvme7n1
vgs volgrp01 #vgdisplay
```

```bash
lvcreate -l 100%FREE -n lv01 volgrp01
lvdisplay /dev/volgrp01/lv01
```

```bash
mkfs.ext4 /dev/volgrp01/lv01
```

```bash
mount /dev/volgrp01/lv01 /disk2
```

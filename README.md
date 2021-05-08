# img-clone

Clone vm-bhyve cloudinit images

## Usage

`USAGE: img-clone <template> <target> <userdata> [<instance_config>]`

`img-clone` provides a utility to clone vm-bhyve cloud-init enabled images and
dynamically update the cloud-init user data (re-generating the seed.iso) 

The source `template` should be a cloud-init enabled vm-bhyve instance (the
utility will use the latest snapshot by default - to use a specific snapshot
this should be specified explicitly as template@snapshot)

A new vm-bhyve instance `target` will be created (using `vm clone`) and
`userdata` copied into the `.cloud-init` folder and the the `seed.iso` image
updated with the contents of the `.cloud-init` folder. 

`userdata` can either be specified as a file (or `-` for stdin) which will be
written as `user-data`, or can be a directory which will be copied recursively
into the `.cloud-init` folder (which allows additional files to be included in
the cloud-init configuration).

If `instance_config` is specified (either a file or `-` for stdin) it is
written to the `.cloud-init` folder as CONFIG (this is to allow a common
userdata config to be used for multiple instances and just specify separate
`instance_config`)

This approach is much faster than using `vm create` with a cloud image which 
uses `qemu dd` to copy the disk image rather than a zfs clone (which is pretty
much instant).

The source vm-bhyve instance should be configured to support cloud-init (`vm
create -C ....`) and the OS image also cloud-init enabled. For FreeBSD it is
possible to use the (very simple) `bhyve-cloudinit` rc.d script included in
thsi repository. This will mount the cdrom, set hostname from the `meta-data`
file and run the `user-data` script. There is *very* rudimentary support for
cloud-config files (add ssh keys, install packages, and runcmd) but this doesnt
parse the yaml file properly so will fail with anything unexpected. The utility
is mostly intended to just run a shell-script in `user-data`. 

When configuring the source template make sure that there are no artefacts left
in the instance (ssh host keys, config files, logs etc) and that the /firstboot
flag is set.

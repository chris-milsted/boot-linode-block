# Test to try and use Cloning and boot from Block 

Note this is not an officially supported solution and there will be some factors to investigate, e.g. we do not have a dedicated storage network at the moment, so the network for running the OS as well as the application network requirements will have to be looked at to see if this solution is sensible.... For now this is more of an "art of the possible" experiment.

## Steps

1. Create a linode.
2. Add a unique file to it

```bash
# touch "Uniquie-File"
root@localhost:~# ls
Uniquie-File
```
We now have a VM which is uniquely identified. 

3. Create a block volume, and attack it to the linode in the GUI, Note make the volume the same size as the disk in the VM. In my case I used an 80GB volume.

[block storage attached to linode](./Screenshot%20from%202026-01-16%2011-00-45.png)

4. Power off the linode and re-boot it into rescue mode

[click rescue](./Screenshot%20from%202026-01-16%2011-03-09.png)

5. Make sure you attach the external disk to the Linode as well as the internal drives

[Add the boot disk as /dev/sdc](./Screenshot%20from%202026-01-16%2011-04-07.png)

6. Open a Lish console, you should get a finnix prompt. Run a dd copy of the disk to copy the OS onto the external disk.

[glish with dd copy command](./Screenshot%20from%202026-01-16%2011-17-51.png)

NOTE actual dd command that worked and was used was:

```bash
dd if=/dev/SOURCE of=/dev/DEST bs=1M status=progress
sync
```

7. Just to make it more fun, I will also power off and then delete the original linode as part of the workflow. So all we have now is the boot-volume block storage volume... 

8. Now we are going to try and clone this volume and create a new linode with it and boot it....

First we need the block volume id:

```bash
$ linode-cli volumes list
┌──────────┬─────────────┬────────┬──────┬────────┬───────────┬────────────────────────────────┬────────────┐
│ id       │ label       │ status │ size │ region │ linode_id │ linode_label                   │ encryption │
├──────────┼─────────────┼────────┼──────┼────────┼───────────┼────────────────────────────────┼────────────┤
│ 13346686 │ boot-volume │ active │ 80   │ gb-lon │ 90095502  │ ubuntu-gb-lon-test-large-image │ disabled   │
└──────────┴─────────────┴────────┴──────┴────────┴───────────┴────────────────────────────────┴────────────┘
```

My volume id here is `13346686`

You will also need the linode firewall id.

You will also need to specify a region where the source and target volumes need to exist.

You will also need a linode-api token [Get Started with the Linode API](https://techdocs.akamai.com/linode-api/reference/get-started)

Also Note that cloning only works WITHIN a datacenter. So you would need a master image volume in each location you want to launch instances in. You can copy block volumes around as per:

[Transfer Block Storage data between data centers](https://techdocs.akamai.com/cloud-computing/docs/transfer-block-storage-data-between-data-centers)

Once you have updated the variables in the script, now run the [block clone deploy script](./block_clone_deploy.sh)


All done!

Start Time  : Fri Jan 16 11:57:22 AM GMT 2026
Finish Time : Fri Jan 16 11:57:46 AM GMT 2026

In the new booted from clone disk VM, verify the unique file is present:

```bash
root@localhost:~# ls -l
total 0
-rw-r--r-- 1 root root 0 Jan 16 11:47 Uniquie-File
```


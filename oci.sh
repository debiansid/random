#!/bin/bash
oci compute instance launch\
–availability-domain fjuo:AP-TOKYO-1-AD-1\
–shape VM.Standard.A1.Flex\
–fault-domain FAULT-DOMAIN-1\
–assign-private-dns-record true\
–compartment-id ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\
–image-id ocid1.image.oc1.ap-tokyo-1.aaaaaaaapzuoegadiixdi4liaoyrloxo6rdczquor5znxjehmsbvc4wfqlka\
–boot-volume-size-in-gbs 100\
–assign-public-ip true\
–subnet-id ocid1.subnet.oc1.ap-tokyo-1.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\
–shape-config ‘{"ocpus":2,"memoryInGBs":12}’\
–metadata ‘{"ssh_authorized_keys":"ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}’ 2>&1
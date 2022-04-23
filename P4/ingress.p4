/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
    

action forward(egressSpec_t port) {
    standard_metadata.egress_spec = port;
}

action drop() {
    mark_to_drop(standard_metadata);
}

action change_source( ip4Addr_t new_src ) {
    hdr.ipv4.srcAddr = new_src;
}

action change_destination( ip4Addr_t new_dest ) {
    hdr.ipv4.dstAddr = new_dest;
}

table translate_address {
    key = {
        hdr.ipv4.dstAddr: exact;
    }
    
    actions = {
        change_destination;
        change_source;
        drop;
    }
    size = 1024;
    default_action = drop();
}

table forwarding {
    key = {
        hdr.ipv4.dstAddr: exact;
    }
    actions = {
        forward;
        drop;
    }
    size = 1024;
    default_action = drop();
}

apply {
    if (hdr.ipv4.isValid()){
        translate_address.apply();
        forwarding.apply();
    }
}

}
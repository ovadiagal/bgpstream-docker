#!/usr/bin/env python

from collections import defaultdict
import pybgpstream

stream = pybgpstream.BGPStream(
    # Consider this time interval:
    from_time="2024-02-10 07:50:00", until_time="2024-02-10 08:10:00",
    collectors=["rrc01"],
    record_type="ribs",
)

# <prefix, origin-ASns-set > dictionary
prefix_origin = defaultdict(set)

for rec in stream.records():
    for elem in rec:
        # Get the prefix
        pfx = elem.fields["prefix"]
        # Get the list of ASes in the AS path
        ases = elem.fields["as-path"].split(" ")
        if len(ases) > 0:
            # Get the origin ASn (rightmost)
            origin = ases[-1]
            # Insert the origin ASn in the set of
            # origins for the prefix
            prefix_origin[pfx].add(origin)

# Print the list of MOAS prefix and their origin ASns
for pfx in prefix_origin:
    if len(prefix_origin[pfx]) > 1:
        print((pfx, ",".join(prefix_origin[pfx])))


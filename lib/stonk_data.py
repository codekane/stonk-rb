#!/usr/bin/env python
import sys
import json
from yahooquery import Ticker


if len(sys.argv) > 1:
    output = {}
    for index, arg in enumerate(sys.argv):
        if index == 0:
            pass
        else:
            output[arg] = Ticker(arg).summary_detail
    finished = json.dumps(output)
    print(finished)


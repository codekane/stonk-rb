import sys
import json
from yahooquery import Ticker

def sort_arguments():
    if len(sys.argv) > 2:
        method = ""
        args = []
        for index, arg in enumerate(sys.argv):
            if index == 0:
                pass
            if index == 1:
                method = arg
            if index > 1:
                args.append(arg)
        return {"method": method, "args": args}

args = sort_arguments()

# Delivery a JSON Hash with "response" keyed to an array of results to the query
if args['method'] == 'summary_detail':
    results = []
    for arg in args["args"]:
        data = Ticker(arg).summary_detail
        results.append(data)
    output = { "response": results }
    print(json.dumps(output))

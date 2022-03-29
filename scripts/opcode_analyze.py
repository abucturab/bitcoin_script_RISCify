import pandas as pd
import numpy as np
import os
import yaml

# df = pd.read_csv('../data/list_of_script_type.csv')
# df['type'].value_counts()

script_list = ['scriptHash', 'pubkeyhash', 'witness_v0_keyhash', 'witness_v0_scripthash', 'nonstandard', 'witness_v1_taproot', 'multisig', 'witness_unknown']
scrip_frq = [1035803135, 404923662, 379775214, 38885453, 260130, 207574, 671, 571, 24]
script_content = [['OP_HASH160', 'OP_EQUAL'], ['OP_DUP', 'OP_HASH160', 'OP_EQUALVERIFY', 'OP_CHECKSIG'], ['OP_0'], ['OP_HASH160', 'OP_0'], ['OP_RETURN'], [], ['OP_CHECKMULTISIG'], []]
print(script_content[0][0])



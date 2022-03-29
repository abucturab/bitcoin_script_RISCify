import re
from bs4 import BeautifulSoup
import pandas as pd
import yaml

with open('../data/script_opcodes.html', 'r') as file:
    bf_rd=BeautifulSoup(file.read(), 'html.parser')

opcode_table=bf_rd.find_all('table')
new_table = pd.DataFrame(columns=['Word', 'opcode', 'hex', 'input', 'output', 'description'])
dicto={}
opcode_table[0].tr.find_all('th')

for table in opcode_table:
    for row in table.find_all('tr'):
        columns=row.find_all('td')
        row_list=[]
        for column in columns:
            row_list.append(column.get_text().strip())
        if len(row_list)==6:
            new_table.loc[len(new_table)]=row_list

yaml_fd = open('../opcodes.yaml', 'w')
for i in new_table.index:
    dicto={new_table['Word'][i]: {'opcode': new_table['opcode'][i], 'hex': new_table['hex'][i], 'input': new_table['input'][i], 'output': new_table['output'][i]}}
    yaml.dump(dicto, yaml_fd)





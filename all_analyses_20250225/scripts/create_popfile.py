import argparse 
from datetime import datetime
import os

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('infile', help='Input file')
    
    args = parser.parse_args()

    outpath = os.path.dirname(args.infile)
    
    with open(args.infile, 'r') as in_file:
        with open(f"{outpath}/pop_file.txt", 'w') as out_file:
            for line in in_file.readlines():
                if '#' in line:
                    line = line.strip()
                    line = line.split('\t')
                    
                    if line[0] == '# Locus ID':
                        break
                    else:
                        pop_name = line[0].strip('# ')
                        samples = line[1].split(',')
                        print(pop_name)
                        print(samples)

                        for sample in samples:
                            out_file.write(f'{sample}\t{pop_name}\n')
                else:
                    break
        with open(f'{outpath}/pop_file.log', 'w') as out_file:
            out_file.write(f"Time Run: {datetime.now()}\n")
            out_file.write(f"Usage: create_popfile.py {args.infile}\n")

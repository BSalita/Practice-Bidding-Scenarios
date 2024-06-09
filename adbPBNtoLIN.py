# Reads all .pbn files from the folder /pbn-rotated-for-4-players
# generating a matching .lin file in the folder /lin-rotated-for-4-players 

import os
import endplay.parsers.pbn as pbn
import endplay.parsers.lin as lin

def process_file(files):
    print("entered process_file")
    n_files = 0
    for i_filename in files:
        if i_filename.lower().endswith('.pbn'):
            n_files = n_files + 1
            print(str(n_files) + " " + i_filename)
            o_filename = i_filename.replace('.pbn', '.lin')

            with open("./pbn-rotated-for-4-players-TEST/" + i_filename, 'r') as i_file:
                print("opened pbn file")
                # It fails on the next line
                
                boards = pbn.load(i_file)

            with open('./lin-rotated-for-4-players/' + o_filename, 'w') as o_file:
                lin.dump(boards, o_file)
                o_file.close()

def scan_for_pbn(directory_path):
    print("entered scan_for_pbn")
    # Use os.listdir() to get files in the current directory only
    current_directory_files = os.listdir(directory_path)
    process_file(current_directory_files)

    print(f"# Scan complete!")

def main():
    print("entered main")
    scan_for_pbn("./pbn-rotated-for-4-players-TEST")

if __name__ == "__main__":
    main()

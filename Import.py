import getopt
import os
import sys
import glob
import re

src_file = ""
tar_file = ""
src_dbname = ""
tar_dbname = ""

def print_usage():
	print('Usage: -s[source sql file] -t[target sql file] -d[srouce database name] -e[target database name]')
	
opts,args = getopt.getopt(sys.argv[1:], 's:t:d:e:', ['help'])
#print opts
for name, value in opts:
	if name in ['--help']:
		print_usage()
		exit()
	elif name in ['-s']:
		src_file = value
	elif name in ['-t']:
		tar_file = value
	elif name in ['-d']:
		src_dbname = value
	elif name in ['-e']:
		tar_dbname = value
		
if src_file == "" or tar_file == "" or src_dbname == "" or tar_dbname == "":
	print_usage()
	exit()
	
f_src = open(src_file, "rb")
f_tar = open(tar_file, "wb")
for line in f_src:
	new_line = line.decode()
	if "lobby_slg" in new_line:
		new_line = new_line.replace(src_dbname, tar_dbname)
	new_line = re.sub(r"DEFINER=.*? ", "", new_line)
	f_tar.write(new_line.encode())

f_src.close()
f_tar.close()
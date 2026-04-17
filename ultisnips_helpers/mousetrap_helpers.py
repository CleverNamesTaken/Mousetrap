import subprocess

def target():
    return (subprocess.run(["tmux", "display-message", "-t", "Mousetrap:","-p","-F","'#W'"],capture_output=True).stdout.decode('utf-8')[:-1][1:-1])

def lookup(key,value):
	import yaml
	try:
		with open("/tmp/lookup.yaml","r") as f:
			data = yaml.safe_load(f)
		return(data[key][value])
	except:
		return (f"{key}_{value}")

def box(machine):
	boxValue = lookup(machine,'IP')
	return boxValue

'''
with open("/tmp/lookup.yaml","r") as f:
	data = yaml.safe_load(f)
COMPUTER:
	IP: "127.0.0.1"
'''

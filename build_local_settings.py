try:
	with open(os.path.join(os.path.dirname(__file__), 'local_settings.py')) as f:
		exec(f.read(), globals())
except IOError:
	pass

LOGGING['handlers']['bridge']['filename'] = '/dev/null'
LOGGING['handlers']['all']['filename'] = '/dev/null'

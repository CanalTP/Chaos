import os
import sys
sys.path.append('/srv/chaos')
os.environ['CHAOS_CONFIG_FILE'] = '/srv/chaos/chaos/default_settings.py'
import chaos
application = chaos.app

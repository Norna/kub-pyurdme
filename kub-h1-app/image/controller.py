import os

script = os.environ['PROCESSINGSCRIPT']
if script == 'parameter-to-broker':
    os.system("python run_tasks.py")
elif script == 'broker-to-h1-app':
    os.system("/usr/local/bin/celery -A celery_conf worker -f /data/celery.log &")
else:
    print "unknown script %s" % script

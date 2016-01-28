import os
import sys

from celery import Celery
from celery.task import Task
from app_h1 import *
from io_parameter import *


# Get Kubernetes-provided address of the broker service
broker_service_host = os.environ.get('RABBITMQ_SERVICE_SERVICE_HOST')
if not broker_service_host:
    broker_service_host = "localhost"
    
app = Celery('tasks', broker='amqp://guest@%s//' % broker_service_host, backend='amqp')
app.conf.CELERYD_CONCURRENCY=1
app.conf.CELERY_ACCEPT_CONTENT= ['pickle']

class CallbackTask(Task):
    def on_success(self,retval,task_id,args,kwargs):
        print ("Done");
    def on_failure(self,exc,task_id,args,kwargs,einfo):
        print ("Failed");

@app.task(base=CallbackTask)
def run(name,data,id):
	
    model = Hes1(model_name="Hes1")

    # Parse parameters
    paramReader = ParameterReader(data)

    # Update parameters value
    for paramKey,paramValue in paramReader.Parameters.Items():
        model.listOfParameters[paramKey].value = paramValue
            
    # Run the model
    result = model.run(report_level=0)
 
    mRNA = result.get_species("mRNA")
    mRNAsum = numpy.sum(mRNA[:],axis=1)
    
    print (mRNAsum)
    print ("\n%s is done!\n" % id)

    return True

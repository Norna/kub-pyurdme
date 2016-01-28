import datetime
import os
import random
import syslog
import time
import sys

from celery_conf import run
from io_parameter import *

def Pause():
    while True:
        time.sleep(10)


def Generate(limit):

    para = ParameterSet()
    para.Set("k1",1.e7)
    para.Set("k2",0.5)
    para.Set("alpha_m",5.0)
    para.Set("alpha_m_gamma",0.2)
    para.Set("alpha_p",1.5)
    para.Set("mu_m",0.015)
    para.Set("mu_p",0.043)

    count = 0

    k2Value = 0.1
    while k2Value <= 0.9:
        para.Set("k2",k2Value)

        alpha_mValue = 1
        while alpha_mValue <= 10:
            para.Set("alpha_m",alpha_mValue)

            alpha_pValue = 1
            while alpha_pValue < 5:
                para.Set("alpha_p",alpha_pValue)
                
                # Parameter xml writer
                paramWriter = ParameterWriter("h1",para)

               	# Run the application
                res = run.apply_async(("H1", paramWriter.ToString(),count))

                count = count + 1
                if count > limit:
                    return
		
                alpha_pValue +=0.1
            alpha_mValue+= 0.01
        k2Value += 0.01

    #print ("Done!!!")

if __name__ == '__main__':
    Generate(int(sys.argv[1]))
    Pause()

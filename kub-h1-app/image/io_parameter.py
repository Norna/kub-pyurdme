import xml.etree.ElementTree as ET

class ParameterSet:
    def __init__(self):
        self.Parameters = dict()
    def Set(self,parameter,value):
        self.Parameters[parameter] = value
    def Items(self):
        return self.Parameters.items()
    def Keys(self):
        return self.Parameters.keys()
    def Values(self):
        return self.Parameters.values()
        

class ParameterSetIOBase:
    Version  = 1.0

class ParameterWriter(ParameterSetIOBase):
    
    def __init__(self,appName,parameterSet):
        #if type(parameterSet) != ParameterSet:
        #    raise TypeError
        
        self.AppName = appName
        self.ParameterSet = parameterSet

    def __build(self):
        root = ET.Element("Parameters")
        root.set("Version",str(ParameterSetIOBase.Version))
        root.set("App",self.AppName)

        for k,v in self.ParameterSet.Items():
            param = ET.SubElement(root,"Parameter")
            param.set("Name",k)
            param.set("Value",str(v))
        return root
    
    def ToString(self,encoding="utf-8"):
        return ET.tostring(self.__build(),encoding=encoding,method="xml")

class ParameterReader(ParameterSetIOBase):
    def __init__(self,xml):
        self.XML = xml
        self.Parameters = ParameterSet()

        if self.XML != "":
            paramRoot = ET.fromstring(self.XML)
            for ele in paramRoot:
                paramName = ele.get("Name")
                paramValue = float(ele.get("Value"))

                self.Parameters.Set(paramName,paramValue)
    
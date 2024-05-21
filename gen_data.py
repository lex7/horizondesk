from dataclasses import dataclass, asdict, is_dataclass, fields
from typing import List
import random
import json
import pprint
import os
class EnhancedJSONEncoder(json.JSONEncoder): # Класс необходимый для сериализации dataclass (не трогать)
    def default(self, o):
        if is_dataclass(o):
            return asdict(o)
        return super().default(o)
@dataclass
class MonthPerformance:
    name_of_month: str
    done: int
    executing: int
    declined: int

@dataclass
class Region:
    name_of_region: str
    months: List[MonthPerformance]
    total_done: int
    total_executing: int
    total_declined: int

@dataclass
class Fabric:
    regions: List[Region]
    specialization: str

@dataclass
class Specialization:
    tools: Fabric
    docs: Fabric
    sanpin: Fabric
    safety: Fabric

def regions()->List[Region]:
    region_list=[]
    for region in region_quantity:
        months_list = region_per_months()
        region_list.append(Region(region,
                                  months_list,
                                  sum([month.done for month in months_list]),       # total_done
                                  sum([month.executing for month in months_list]),  # total_executing
                                  sum([month.declined for month in months_list])    # total_declined
                                  ))  
    return region_list

def region_per_months()->List[MonthPerformance]:
    months_list = []
    for month in months:
        months_list.append(MonthPerformance(month,
                                            random.randint(8,12), # done        (Можно менять)
                                            random.randint(2,5), # executing   (Можно менять)
                                            random.randint(1,3), # declined    (Можно менять)
                                            ))
    return months_list


region_quantity = ["Участок №"+str(i) for i in range(1,4)]                              # Количество цехов
months = ["Январь", "Февраль", "Март", "Апрель", "Май"]                                                      # Месяца


data = {}
for spec in fields(Specialization):
    data[spec.name]=Fabric(regions(),spec.name)
    
pprint.pprint(data)

#print(os.getcwd())

with open("data_json_2.json", "w") as write_file:
      json.dump(data, write_file, cls=EnhancedJSONEncoder)
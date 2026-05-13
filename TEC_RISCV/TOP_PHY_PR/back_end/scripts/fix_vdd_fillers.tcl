# Ver 0.1, 15-11-2018 
#A. Chacon-Rodriguez  
#Conexion de los VDD, VDDO, VDDR de los rellenos
#Tomamos de ejemplo la conexion de los corner
#connect_supply_net VDD_1V8_PADS -ports {corner*/VDD}
#connect_supply_net VDD_3V3_PADS -ports {corner*/VDDO corner*/VDDR}
# Pero como ya se colocaron en un dominio de voltaje los rellenos, debemos apuntar ahi
connect_supply_net VDD_1V8_PADS -ports {pfiller*/VDD}
connect_supply_net VDD_3V3_PADS -ports {pfiller*/VDDO pfiller*/VDDR}
connect_supply_net VSS -ports {pfiller*/GNDO}
connect_supply_net VSS -ports {pfiller*/GNDR}



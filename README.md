graph TD
    subgraph Red Principal (LAN del Hospital)
        LAN_Switch(Switch LAN Principal)
    end

    subgraph Infraestructura del Clúster
        subgraph Switches Principales
            Switch1(Switch Gestionable 1)
            Switch2(Switch Gestionable 2)
        end

        subgraph Servidores Proxmox
            Srv1(Dell R650 #1)
            Srv2(Dell R650 #2)
            Srv3(Dell R750 #1)
        end

        subgraph Almacenamiento
            PV1(PowerVault #1)
            PV2(PowerVault #2)
        end
    end

    %% Conexiones de Almacenamiento 25Gb Fibra Óptica (Líneas Gruesas)
    Srv1 -- "25Gb FO (Storage)" ==> Switch1
    Srv1 -- "25Gb FO (Storage)" ==> Switch2
    Srv2 -- "25Gb FO (Storage)" ==> Switch1
    Srv2 -- "25Gb FO (Storage)" ==> Switch2
    PV1 -- "25Gb FO (Storage)" ==> Switch1
    PV1 -- "25Gb FO (Storage)" ==> Switch2
    PV2 -- "25Gb FO (Storage)" ==> Switch1
    PV2 -- "25Gb FO (Storage)" ==> Switch2

    %% Conexiones de Clúster / VMs 10Gb Cobre (Líneas Normales)
    Srv1 -- "10Gb Cu (Clúster/VMs)" --> Switch1
    Srv1 -- "10Gb Cu (Clúster/VMs)" --> Switch2
    Srv2 -- "10Gb Cu (Clúster/VMs)" --> Switch1
    Srv2 -- "10Gb Cu (Clúster/VMs)" --> Switch2
    Srv3 -- "10Gb Cu (Clúster/VMs)" --> Switch1
    Srv3 -- "10Gb Cu (Clúster/VMs)" --> Switch2

    %% Conexiones a la Red Principal
    Switch1 --> LAN_Switch
    Switch2 --> LAN_Switch

    %% Estilos para diferenciar
    linkStyle 0,1,2,3,4,5,6,7 stroke-width:4px,stroke:blue,color:blue
    linkStyle 8,9,10,11,12,13 stroke:green,color:green
    linkStyle 14,15 stroke:black,stroke-dasharray: 5 5
  

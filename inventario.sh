#!/bin/bash

NETWORK="192.168.56.0/24"
OUT_TXT="inventario-rede.txt"
OUT_XML="inventario-rede.xml"

sudo nmap -sS -T5 -p- -oN $OUT_TXT -oX $OUT_XML $NETWORK



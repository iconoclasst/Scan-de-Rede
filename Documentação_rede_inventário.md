Documenta¸c˜ao rede invent´ario

Davi Bezerra November 2025

1  Inic´ıo

Este laborat´orio ´e uma pr´atica simplificada de um ambiente de redes com virtual box.

Equipamentos iniciais:

1. RouterOS vers˜ao Cloud Hosted Router VDI Image
1. Ubuntu Server 22.04 Iso Image
1. Alpine Linux VM version

![](Aspose.Words.a0adb7f2-336b-4564-b8e2-9f9aec86326e.001.png)

Figure 1: Cen´ario simplificado

1. Configura¸c˜ao Virtual Box

No virtual box, criamos uma rede host-only e adicionamos `a VM do MikroTik uma interface adaptador NAT e uma interface adaptador host-only. A interface 2 (host-only) ter´a o endere¸co 192.168.56.1/24, enquanto a NAT recebe o IP 10.0.2.15/24 via DHCP VBox.

Essa configura¸c˜ao no MikroTik permite a conex˜ao entre a rede host-only e a rede externa.

OBS: O adaptador NAT permite requisi¸c˜oes para a internet publica´ de dentro para fora da rede, mas n˜ao o contr´ario.

2. Configura¸c˜ao de interfaces no MikroTik

Ao iniciar o RouterOS (MikroTik), verificamos se as interfaces foram recon- hecidas com o comando interface print. A ether1 ´e a NAT e a ether2 ´e a Host-Only.

![](Aspose.Words.a0adb7f2-336b-4564-b8e2-9f9aec86326e.002.png)

Figure 2: Interfaces MikroTik

Para adicionar um IP fixo na ether2, utilizamos o comando ip address add address=192.168.56.10/24 interface=ether2.

Podemos ver os endere¸cos definidos com o comando ip address print:

![](Aspose.Words.a0adb7f2-336b-4564-b8e2-9f9aec86326e.003.png)

Figure 3: Endere¸cos das interfaces

Com essas configura¸c˜oes, j´a conseguimos pingar da nossa m´aquina local para

- MikroTik, e o MikroTik consegue pingar com sucesso para a internet publica:´ Outra configura¸c˜ao importante ´e a cria¸c˜ao de uma regra de firewall para per-

miss˜ao de roteamento via MikroTik. O Ubuntu Server e o Alpine Linux ter˜ao

- MikroTik como roteador (via 192.168.56.10/24. Ent˜ao ´e necess´ario criar

uma regra de NAT. Podemos usar a interface gr´afica ou o comando de terminal /ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade comment="NAT para LAN". Esse comando cria no firewall uma regra de nat para

![](Aspose.Words.a0adb7f2-336b-4564-b8e2-9f9aec86326e.004.png)

Figure 4: Ping para internet publica´

permitir que os pacotes direcionados `a internet publica´ passem pela interface ether1 (NAT) e sejam mascarados.

3. Configura¸c˜ao inicial de Ubuntu Server

No virtual box, adicionamos ao Ubuntu Server a interface host-only da subnet 192.168.56.0/24. Durante a instala¸c˜ao, definimos na interface as informa¸c˜oes iniciais de rede. Para endere¸co IP, utilizamos o IP est´atico 192.168.56.5/24 e como gateway, inserimos o endere¸co do MikroTik 192.168.56.10. De in´ıcio, para termos servi¸cos funcionando, instalamos no servidor o OpenSSH e o Ng- nix. Opcionalmente, abrimos o arquivo etcsshsshd~~ config e mudamos a porta padr˜ao de 22 para 5347. Ap´os, reiniciamos e habilitamos o servi¸co SSH.

![](Aspose.Words.a0adb7f2-336b-4564-b8e2-9f9aec86326e.005.jpeg)

Figure 5: Servi¸co SSH

O servidor web Nginx servir´a apenas para ter um outro servi¸co com porta dispon´ıvel no servidor. Instalamos o mesmo com sudo apt update e sudo apt install nginx -y. Para confirmar que est´a tudo certo, podemos acessar o Ubuntu Server via SSH na nossa m´aquina local designando a porta modificada e dando um wget para verificar o funcionamento do servidor:

Por fim, instalamos e configuramos um servidor de arquivos Samba.

![](Aspose.Words.a0adb7f2-336b-4564-b8e2-9f9aec86326e.006.png)

Figure 6: Confirma¸c˜ao de SSH e Nginx

4. Configura¸c˜ao inicial de cliente Alpine Linux

Ao instalar o Alpine Linux, inserimos tamb´em a interface Host-only e damos os comandos ip link para ver as interfaces. Nossa interface de interesse ´e a eth0, ent˜ao inserimos ip addr add 192.168.56.6/24 dev eth0. Ap´os isso, inseri- mos a rota para o MikroTik com ip route add default via 192.168.56.10. Esse m´etodo adiciona o endere¸co na interface temporariamente. Para fixar o endere¸co, editamos o arquivo /etc/network/interfaces e adicionamos o seguinte conteudo:´

auto eth0

iface eth0 inet static

address 192.168.56.6 netmask 255.255.255.0 gateway 192.168.56.10

2  Realiza¸c˜ao de Invent´ario

A m´aquina usada para a realiza¸c˜ao do invent´ario ´e a minha m´aquina host que est´a executando o virtual box. Por padr˜ao, o Virtual Box cria uma interface virtual para conex˜ao com a rede host only:

5: vboxnet0: <BROADCAST,MULTICAST,UP,LOWER\_UP> mtu 1500 qdisc fq\_codel state UP group default qlen 1000 link/ether 0a:00:27:00:00:00 brd ff:ff:ff:ff:ff:ff

inet 192.168.56.1/24 brd 192.168.56.255 scope global vboxnet0

Para esse laborat´orio, ´e interessante utilizar-mos o endere¸co da interface virtual, que pode ser visto com ip route:

$ ip route

...

192\.168.56.0/24 dev vboxnet0 proto kernel scope link src 192.168.56.1

Esse comando mostrou o endere¸co da interface virtual (192.168.56.1) e a subrede (192.168.56.0/24).

Para fazer o invent´ario b´asico e simples, podemos criar um Script Shell que gera um arquivo TXT com as informa¸c˜oes obtidas e tamb´em um arquivo XML para visualiza¸c˜ao estruturada. Com um editor de texto (nano, vim, vi e etc) criamos o arquivo inventario.sh e inserimos esse conteudo:´

#!/bin/bash

NETWORK="192.168.56.0/24" OUT\_TXT="inventario-rede.txt" OUT\_XML="inventario-rede.xml"

sudo nmap -sS -T5 -p- -oN $OUT\_TXT -oX $OUT\_XML $NETWORK

Para executar temos que estar na mesma pasta e dar permiss˜ao de execu¸c˜ao com sudo chmod +x inventario.sh. E ent˜ao, usamos o comando ./inventario.sh. O script gerou os dois arquivos citados:

![](Aspose.Words.a0adb7f2-336b-4564-b8e2-9f9aec86326e.007.png)

Figure 7: Diret´orio com arquivos

Ao abrir o arquivo TXT, temos as informa¸c˜oes das m´aquinas da rede, com o 192.168.56.5 sendo o Ubuntu Server, o RouterOS MikroTik sendo o 192.168.56.10 e o Alpine Linux sendo o 192.168.56.6.

A seguir, abrimos o programa zenmap e inserimos a captura de rede do arquivo XML para obter as informa¸c˜oes estruturadas e o mapa em forma de topologia. Al´em dessas informa¸c˜oes, o zenmap mostra diversas outras, como portas, estados e outros detalhes, al´em de poder estruturar mais de acordo com

a captura feita no arquivo XML.

![](Aspose.Words.a0adb7f2-336b-4564-b8e2-9f9aec86326e.008.jpeg)

Figure 8: Captura em texto

![](Aspose.Words.a0adb7f2-336b-4564-b8e2-9f9aec86326e.009.jpeg)

Figure 9: Topologia desenhada

![](Aspose.Words.a0adb7f2-336b-4564-b8e2-9f9aec86326e.010.png)

Figure 10: M´aquinas registradas na captura

![](Aspose.Words.a0adb7f2-336b-4564-b8e2-9f9aec86326e.011.png)

Figure 11: Servi¸cos registrados na captura
7

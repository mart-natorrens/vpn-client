# VPN-client installation scripts

Scripts to install and manage some types of VPN-clients.
Scripts start/stop client service. **Configs are protected by master key as well.**

Usage:

(1.) Create master key if it has not been created before

```
./manage_master_key.sh
```
2. Start VPN client


```
./personal_openvpn.sh start
```

or

```
./personal_wireguard.sh start
```

Script will print your VPN covered IP address for success result 

(3.) Stop VPN client

```
./personal_openvpn.sh stop
```

or

```
./personal_wireguard.sh stop
```

Script will print your open/legal IP address for success result 








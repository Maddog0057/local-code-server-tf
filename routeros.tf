resource "wireguard_asymmetric_key" "wg_asc_key" {}

resource "random_integer" "wireguard_port" {
  min = 13232
  max = 13250
}

resource "random_integer" "ip_subnet" {
  min = 1
  max = 250
}

resource "random_integer" "ip_host" {
  min = 10
  max = 250
}

resource "routeros_interface_wireguard" "test_wg_interface" {
  name        = "${random_pet.pet_name.id}-WG"
  mtu         = 1500
  listen_port = random_integer.wireguard_port.result
}

resource "routeros_interface_wireguard_peer" "wg_peer" {
  interface            = routeros_interface_wireguard.test_wg_interface.name
  public_key           = wireguard_asymmetric_key.wg_asc_key.public_key
  persistent_keepalive = "25s"
  allowed_address = [
    "10.77.${random_integer.ip_subnet.result}.0/24"
  ]
}

data "wireguard_config_document" "peer" {
  private_key = wireguard_asymmetric_key.wg_asc_key.private_key
  listen_port = random_integer.wireguard_port.result
  dns = [
    "1.1.1.1"
  ]
  #PostUp = "DROUTE=$(ip route | grep default | awk '{print $3}'); HOMENET=10.77.${random_integer.ip_subnet}.0/24; ip route add $HOMENET via $DROUTE;iptables -I OUTPUT -d $HOMENET -j ACCEPT; iptables -A OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT"
  #PreDown = "HOMENET=10.77.${random_integer.ip_subnet}.0/24; ip route del $HOMENET via $DROUTE; iptables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT; iptables -D OUTPUT -d $HOMENET -j ACCEPT"

  peer {
    public_key = routeros_interface_wireguard.test_wg_interface.public_key
    allowed_ips = [
      "10.77.${random_integer.ip_subnet.result}.${random_integer.ip_subnet.result}/32",
    ]
    persistent_keepalive = 25
  }
}

output "wireguard_config" {
  value     = data.wireguard_config_document.peer.conf
  sensitive = true
}

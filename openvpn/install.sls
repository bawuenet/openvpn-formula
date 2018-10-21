{%- from "openvpn/map.jinja" import map with context %}

# Install openvpn packages
openvpn_pkgs:
  pkg.installed:
    - pkgs:
      {%- for pkg in map.pkgs %}
      - {{ pkg }}
      {%- endfor %}
{% if salt['grains.get']('os_family') == 'Windows' %}
    - require:
      - win_pki: openvpn_publisher_cert

openvpn_publisher_cert:
  win_pki.import_cert:
    - name: salt://openvpn/files/openvpn-1.cer
    - store: TrustedPublisher
{% endif %}

ufw:
  pkg.installed

/etc/ufw/user6.rules:
  file.managed:
    - source: salt://ufw/user6.rules

/etc/ufw/user.rules:
  file.managed:
    - source: salt://ufw/user.rules

/etc/ufw/ufw.conf:
  file.managed:
    - source: salt://ufw/ufw.conf

ufwservices:
  service.running:
  - name: ufw
  - watch:
    - file: /etc/ufw/user6.rules
    - file: /etc/ufw/user.rules
    - file: /etc/ufw/ufw.conf

flameshot:
  pkg.installed
~/.config/flameshot/flameshot.ini:
  file.managed:
    - source: salt://flameshot/flameshot.ini

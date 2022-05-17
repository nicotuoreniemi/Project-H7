nano:
  pkg.installed
/etc/nanorc:
  file.managed:
    - source: salt://nano/nanorc

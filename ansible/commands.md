- Create vault.yml

```bash
ansible-vault create vault.yml
```

- Edit vault.yml

```bash
ansible-vault edit vault.yml
```

- Run playbook

```bash
ansible-playbook -i inventory.yml --ask-become-pass --ask-vault-pass portenta_lynx_update.yml
```

- Run playbook for specific device

```bash
ansible-playbook -i inventory.yml --ask-become-pass --ask-vault-pass portenta_lynx_update.yml  -l device_name
```

- Run playbook for group of devices

```bash
ansible-playbook -i inventory.yml --ask-become-pass --ask-vault-pass portenta_lynx_update.yml  -l device_name1,device_name2
```
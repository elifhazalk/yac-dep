example usage: \
("become" needed for running bash with login and interactive flags ???) \

```bash
ansible-playbook -i inventory.yml --ask-vault-pass --ask-become-pass rigel.yml -l firefly_device_2
```

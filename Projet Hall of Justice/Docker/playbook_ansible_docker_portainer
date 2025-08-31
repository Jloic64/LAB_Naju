runuser -u ansible -- bash -lc '
mkdir -p ~/ansible && cd ~/ansible
cat > install_docker_portainer.yml << "YML"
---
- name: Installer Docker + Portainer (Debian 12)
  hosts: all
  become: true
  gather_facts: true

  vars:
    docker_repo: "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian {{ ansible_distribution_release }} stable"
    portainer_port: 9000

  tasks:
    - name: MAJ système (rapide)
      ansible.builtin.apt:
        update_cache: yes
        upgrade: yes

    - name: Paquets prérequis
      ansible.builtin.apt:
        name:
          - ca-certificates
          - curl
          - gnupg
          - lsb-release
          - software-properties-common
        state: present

    - name: Créer /etc/apt/keyrings
      ansible.builtin.file:
        path: /etc/apt/keyrings
        state: directory
        mode: "0755"

    - name: Installer clé GPG Docker (si absente)
      ansible.builtin.shell: |
        set -e
        curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        chmod a+r /etc/apt/keyrings/docker.gpg
      args:
        creates: /etc/apt/keyrings/docker.gpg

    - name: Dépôt Docker (signed-by)
      ansible.builtin.copy:
        dest: /etc/apt/sources.list.d/docker.list
        content: "{{ docker_repo }}\n"
        mode: "0644"

    - name: apt update après ajout dépôt
      ansible.builtin.apt:
        update_cache: yes

    - name: Installer Docker CE
      ansible.builtin.apt:
        name:
          - docker-ce
          - docker-ce-cli
          - containerd.io
          # - docker-compose-plugin   # décommente si tu veux aussi docker compose
        state: present

    - name: Activer + démarrer Docker
      ansible.builtin.service:
        name: docker
        state: started
        enabled: true

    - name: Créer volume Portainer (idempotent)
      ansible.builtin.shell: |
        docker volume inspect portainer_data >/dev/null 2>&1 || docker volume create portainer_data
      args:
        warn: false

    - name: Lancer Portainer CE (idempotent)
      ansible.builtin.shell: |
        if ! docker ps --format "{{'{{'}}.Names{{'}}'}}" | grep -qx portainer; then
          docker run -d \
            -p {{ portainer_port }}:9000 \
            --name portainer \
            --restart=always \
            -v /var/run/docker.sock:/var/run/docker.sock \
            -v portainer_data:/data \
            portainer/portainer-ce:latest
        fi
      args:
        warn: false

    - name: Message final
      ansible.builtin.debug:
        msg: "Portainer dispo sur http://{{ ansible_host }}:{{ portainer_port }}"
YML
'

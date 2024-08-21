# Ansible

一些关于 Ansible 的笔记。

## Playbook

Playbooks 是自动化蓝图，它们采用 yml 格式，Ansible 使用它们来部署和配置被管理的节点。

### Playbook

一个 playbook 是一个 plays 的列表，它们定义了 Ansible 执行操作的顺序（从上到下），以实现一个整体目标。

### Play

一个 play 是一个任务（tasks）的有序列表，这些任务映射到 inventory 中的被管理节点。

### Task

一个 task 是对单个模块的引用，它定义了 Ansible 将要执行的操作。

> 可以理解为脚本

### Module

模块是 Ansible 在被管理节点上运行的代码或二进制文件的单元。Ansible 模块被分组在 collections 中，每个模块都有一个完全限定的集合名称（FQCN）。

> Ansible 自带的 Modules: https://docs.ansible.com/ansible/latest/collections/index.html. 也可以自己实现。

可以使用 `ansible-doc` 查看某个模块。

#### 自定义 Module

https://docs.ansible.com/ansible/latest/reference_appendices/module_utils.html

**示例**：

```py
#!/usr/bin/python

from ansible.module_utils.basic import AnsibleModule

def run_module():
    module_args = dict(
        path=dict(type='str', required=True)
    )

    result = dict(
        changed=False,
        original_message='',
        message=''
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    path = module.params['path']

    try:
        with open(path, 'r') as file:
            content = file.read()
        result['message'] = content
    except Exception as e:
        module.fail_json(msg=str(e), **result)

    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()
```

使用模块：

在你的 playbook 中引用自定义模块：

```yml
- name: Test custom module
  hosts: localhost
  tasks:
    - name: Read content from file
      my_module:
        path: /path/to/your/file.txt
      register: result

    - name: Show result
      debug:
        var: result.message
```

运行 playbook：

确保 `my_module.py` 文件在 library 目录下，Ansible 会自动查找该目录中的模块。然后运行你的 playbook：

```sh
ansible-playbook your_playbook.yml
```

### 示例

为了更好地理解这些概念，以下是一个简单的 playbook 示例：

```yml
- name: Ensure web server is installed and running
  hosts: webservers
  become: yes

  tasks:
    - name: Install Apache
      ansible.builtin.yum:
        name: httpd
        state: present

    - name: Start Apache service
      ansible.builtin.service:
        name: httpd
        state: started
```

在这个示例中：

- **Playbook** 是整个 yml 文件。
- **Play** 是从 `- name: Ensure web server is installed and running` 开始的部分。
- **Task** 是 `Install Apache` 和 `Start Apache service` 这两个步骤。
- **Module** 是 `ansible.builtin.yum` 和 `ansible.builtin.service`，它们分别用于安装 Apache 和启动 Apache 服务。

## kubespray

kubespray 就是使用 ansible 进行生产环境的 k8s 部署，ansible 提供一个 playbook `cluster.yml`，类似：

```yml
- hosts: bastion:k8s_cluster:etcd_k8s
  gather_facts: True
  roles:
    - { role: kubernetes/pre-pkg/releases }
```

`hosts: bastion:k8s_cluster:etcd_k8s`: 这部分指定了要运行 playbook 的目标主机（或主机组）。bastion, k8s_cluster, etcd_k8s 可能是定义在你的 Ansible 清单文件中的主机或主机组。这意味着该任务将会在这些主机上执行。

`gather_facts: True`: 这个选项表示在执行任务之前，Ansible 会收集目标主机的事实（即主机的系统信息，如 IP 地址、操作系统类型等）。这些事实可以在后续任务中使用。

`roles`: 这部分定义了要在目标主机上执行的角色列表。每个角色包含了一系列任务、变量、模板和其他文件，可以自动应用到目标主机上。

`{ role: kubernetes/pre-pkg/releases }`: 这是一种简化的方式来定义角色。在这里，kubernetes/pre-pkg/releases 是角色的名称，表示这是一个与 Kubernetes 相关的角色，位于 pre-pkg/releases 目录中。这个角色可能包含了一些预定义的任务，用于设置或管理 Kubernetes 集群的特定组件或版本。

roles 是 Ansible 用来组织和复用代码的机制，通过指定一个或多个角色，可以在多个主机上执行复杂的自动化任务。

在 role 目录下有一系列 task 文件，比如：

1. defaults:

   作用：存储角色的默认变量值。defaults/main.yml 文件通常包含所有角色的默认设置。这些默认值可以在 playbook 或 vars 文件中被覆盖。

2. files:

   作用：存放角色可能需要分发到目标主机上的静态文件。Ansible 的 copy 或 template 模块可以从这个目录中复制文件到目标主机。

3. handlers:

   作用：存储在任务中触发的处理程序（handlers）。处理程序通常在某个条件满足时被调用，例如在配置文件改变后重新启动服务。

4. meta:

   作用：存储角色的元数据文件，通常是 main.yml 文件。元数据文件定义了角色的依赖关系、支持的 Ansible 版本、以及其他角色的依赖等信息。

5. tasks:

   作用：存放角色的主要任务文件。tasks/main.yml 是角色执行的主要任务入口文件，可能导入其他任务文件。

6. templates:

   作用：存放 Jinja2 模板文件。模板文件通常用于动态生成配置文件，并通过 template 模块分发到目标主机。

7. vars:

   作用：存储角色的变量文件。vars/main.yml 文件通常包含在角色中定义的变量，这些变量的优先级比 defaults 中定义的更高，但比 playbook 中定义的低。

# Ansible

一些关于 Ansible 的笔记。

## Playbook

Playbooks 是自动化蓝图，它们采用 YAML 格式，Ansible 使用它们来部署和配置被管理的节点。

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

```yaml
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

```yaml
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

- **Playbook** 是整个 YAML 文件。
- **Play** 是从 `- name: Ensure web server is installed and running` 开始的部分。
- **Task** 是 `Install Apache` 和 `Start Apache service` 这两个步骤。
- **Module** 是 `ansible.builtin.yum` 和 `ansible.builtin.service`，它们分别用于安装 Apache 和启动 Apache 服务。


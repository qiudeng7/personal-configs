# Agents.md

本文档的主要作用是介绍用户的使用习惯和工作方式。

## github

用户的 github 名称是 `qiudeng7`，本地安装了 gh-cli，没安装的话提醒一下用户。大部分项目都会放到 github，本地常用工作目录一般是 ~/workspace/，服务器上的部署目录一般是 ~/deploy 。如果和你提到什么你不知道的项目你可以在习惯目录和 github 里面搜一下。

## 记忆和密钥

用户给 codex 接入了 mem0，这是一个管理 Agent 记忆的工具，你可以在这里查询到跨会话记忆。

用户的密钥基本都放在infisical cloud，开发环境也基本都安装了infisical cli，如果需要用的时候发现未登录，提醒用户登录。

后续所有需要凭证的地方都可以先去mem0搜索一下凭证的位置，然后在用infisical核实一下是否有相关的密钥存在。

大部分项目里不会特别提到的凭证，一般放在infisical的 `personal` project。

## 阿里云

用户常用阿里云的镜像仓库，边缘加速（ESA）功能，也在阿里云有服务器，开发环境也基本都安装了aliyun cli，你可以通过aliyun cli管理这些云服务，登录凭证在infisical。

ESA方面，主要有两个域名，一个是chongqing-yusheng.cn 是公司的，一个是qiudeng.cc 属于个人。

镜像仓库统一使用个人仓库，地址是 `crpi-hvru9zd4pbpi8a42.cn-shanghai.personal.cr.aliyuncs.com`，但是分公开和私有两类namespace分别是`qiudeng-private`和`qiudeng-public`，容器仓库登录凭证在infisical。

## 开发workflow

如果你要处理的是相对正式的代码库，那基本上就是要开始进行正式的开发工作了，优先考虑这种工作方式：
1. 先和用户讨论和明确大致的任务目标和改动范围
2. 和用户开始进行多轮仔细设计，设计一般从这几个角度进行：用户交互，架构，流程，模块接口设计。
3. 开始实现

# OAuth2.0

以下内容参考自：[rfc6749](https://datatracker.ietf.org/doc/html/rfc6749)

OAuth 在客户端和资源提供商之间引入了一个授权层(authorization layer)将客户端的角色和资源的角色分开。

想象一个场景：

一个打印服务（客户端）需要访问我们存储在资源服务器（资源服务器）上的照片（可以是各种网盘等等），为了使这个打印服务可以访问我们的照片，通常我们会想到的就是直接使用帐号密码登录到我们的资源服务器上，但是这会引发以下问题：

- 第三方需要存储我们的凭证（帐号密码）以便在之后可以使用。

- 第三方服务被给予了太大的权限，资源所有者没有能力去限制第三方服务的权限。

- 资源所有者没有能力去撤销授予第三方的权限，只能通过改密码。

~~以上使用的方法在我校的打印店十分常见~~

但是 OAuth 出现了，它的出现使我们的认证流程发生了改变：

一个人（资源所有者）可以授予打印服务访问她存储在照片共享服务中的受保护的照片，而不需要与打印服务共享她的用户名和密码。她直接与照片共享服务信任的服务器（认证服务器）进行认证，该服务器向打印服务发放特定的授权凭证（访问令牌）。

## Roles & Terms

在上述 OAuth 流程中出现了以下四种角色：

### 资源所有者(resource owner)

资源所有者是指能够对受保护资源授予访问权的实体。当资源拥有者是一个人时，则其表示要打印照片的我们(end-user)。

在本文中，我有时会用用户代替资源所有者。

### 资源服务器(resource server)

托管受保护资源的服务器，拥有接手并且响应一个带有访问令牌(access tokens)请求受保护资源的能力。

### 客户端(client)

一个被资源所有者授权的发出请求受保护资源的程序。也就是第三方服务，一个发出请求受保护资源的服务。

### 授权服务器(authorization server)

资源所有者在成功认证客户端之后由认证服务器来给予客户端访问令牌(access tokens)。客户端使用这个访问令牌去访问资源服务器。

记住这四个角色，后面的流程都与它们相关。

除了了解 OAuth 中的角色之外，还有几个专有名词需要了解。

- User Agent: 用户代理，一般指浏览器。

- HTTP service: HTTP 服务提供商。

## Protocol Flow

工作流程如下：

```
     +--------+                               +---------------+
     |        |--(A)- Authorization Request ->|   Resource    |
     |        |                               |     Owner     |
     |        |<-(B)-- Authorization Grant ---|               |
     |        |                               +---------------+
     |        |
     |        |                               +---------------+
     |        |--(C)-- Authorization Grant -->| Authorization |
     | Client |                               |     Server    |
     |        |<-(D)----- Access Token -------|               |
     |        |                               +---------------+
     |        |
     |        |                               +---------------+
     |        |--(E)----- Access Token ------>|    Resource   |
     |        |                               |     Server    |
     |        |<-(F)--- Protected Resource ---|               |
     +--------+                               +---------------+
```

A. 用户打开客户端，要求用户授予权限。（此处的用户即资源所有者）

B. 用户同意授予权限。

C. 客户端使用上一步获得的授权，向认证服务器申请令牌。

D. 认证服务器对客户端进行认证之后，认证成功则发放令牌。

E. 客户端使用令牌，访问资源服务器上的资源。

F. 资源服务器确认令牌正确，向客户端开放资源。

客户端从用户获得授权的首选方法是使用认证服务器作为中介。

## Authorization Grant

authorization grant 是指来自资源所有者的**授权**，在 OAuth 中分为四种方式：

- 授权码模式（authorization code）

- 简化模式（implicit）

- 密码模式（resource owner password credentials）

- 客户端模式（client credentials）

### Authorization Code

授权码模式是**首选方法**，它使用认证服务器在客户端和资源所有者之间作为中介。

客户端不是直接向资源所有者请求授权，而是将资源所有者重定向到认证服务器，认证服务器再将资源所有者和授权代码一起重定向回客户端。

资源所有者的凭据只有认证服务器知道，第三方服务器是无法知道认证凭据的。

工作流程：

```
     +----------+
     | Resource |
     |   Owner  |
     |          |
     +----------+
          ^
          |
         (B)
     +----|-----+          Client Identifier      +---------------+
     |         -+----(A)-- & Redirection URI ---->|               |
     |  User-   |                                 | Authorization |
     |  Agent  -+----(B)-- User authenticates --->|     Server    |
     |          |                                 |               |
     |         -+----(C)-- Authorization Code ---<|               |
     +-|----|---+                                 +---------------+
       |    |                                         ^      v
      (A)  (C)                                        |      |
       |    |                                         |      |
       ^    v                                         |      |
     +---------+                                      |      |
     |         |>---(D)-- Authorization Code ---------'      |
     |  Client |          & Redirection URI                  |
     |         |                                             |
     |         |<---(E)----- Access Token -------------------'
     +---------+       (w/ Optional Refresh Token)

   Note: The lines illustrating steps (A), (B), and (C) are broken into
   two parts as they pass through the user-agent.
```

下面步骤中的用户都是在 user-agent 中操作的，也就是在浏览器上进行操作。

A. 用户访问客户端，客户端将用户（或者准确的说是 user-agent）重定向到认证服务器。客户端发送请求会包含 client identifier，requested scope, local state, redirection URI；依次为客户端标识符，申请的权限范围，客户端的当前状态，重定向 URI。

B. 认证服务器对用户进行身份验证（通过 user-agent）并确定用户是否授予或拒绝客户端的访问请求。

C. 假设用户给予授权，则认证服务器将用户重定向回客户端，同时附带上一个授权码（Authorization Code）,其中这个重定向 URI 来自客户端在 A 步骤发送得来。

D. 客户端收到授权码，附上去获取授权码的重定向 URI，向认证服务器申请令牌。

E. 认证服务器核对了授权码和重定向 URI，确认无误后，向客户端发送访问令牌（access token） 或者更新令牌（refresh token）。

其他三种模式，请参考阮一峰老师的文章[^1]

[^1]:[理解OAuth2.0](https://www.ruanyifeng.com/blog/2014/05/oauth_2_0.html)

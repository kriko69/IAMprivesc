# IAMprivesc

## DESCRIPCION

> **Enumeracion de usuario potenciales para escalacion de privilegios en base a permisos de IAM peligrosos.**

Actualmente esta herramienta esta en mejora y fase de desarrollo, pero puede validar los siguientes permisos peligros de IAM:

- iam:CreateAccessKey
- iam:CreateLoginProfile
- iam:UpdateLoginProfile
- iam:AddUserToGroup
- iam:CreatePolicyVersion
- iam:SetDefaultPolicyVersion
- iam:AttachUserPolicy
- iam:AttachGroupPolicy
- iam:AttachRolePolicy
- iam:PutUserPolicy
- iam:PutGroupPolicy
- iam:PutRolePolicy

El que tenga este permiso no quiere decir que el usuario ya puede elevar privilegios, es necesario ver la parte de **Resource** de la politica para ver sobre que recurso se puede usar el permiso.

## REQUISITOS

- aws CLI

[https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

- jq

```bash
apt install jq
```

> **Nota: se debe configurar credenciales privilegiadas en el perfil por defecto de aws CLI**

## USO DE LA HERRAMIENTA

```bash
git clone repository
cd IAMprivesc
chmod +x IAMprivesc.sh
./IAMprivesc <user_AWS>
```

![privesc](/images/privesc.png)

## FEEDBACK

Pueden hacer un fork para mejorar la herramienta. 

        
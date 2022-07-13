#!/bin/bash

RED='\033[0;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

usage(){
    printf "${CYAN}[!] Usage:${NC}\n\n"
    printf "${GREEN}$0 <usuario_aws>${NC}\n\n"
    printf "${CYAN}[!] <usuario_aws>: Usuario de AWS que queremos validar si tiene permisos para elevar privilegios.${NC}\n\n"
    printf "${GREEN}Ejemplo: $0 user1${NC}\n\n"
    printf "${CYAN}[!] Nota: Se debe configurar credenciales de AWS con una cuenta que tenga permisos para listar grupos y politicas.${NC} \n\n"
    printf "${GREEN}aws --configure${NC}\n"
    exit 1;
}

validar_input()
{
    if [ -z $1 ]
    then
        echo -e "${CYAN}\n[!] No hay argumentos${NC}\n"
        usage
    else
        main
    fi
}



obtener_usuarios() 
{
    : 'aws iam list-users | jq -r '.Users[].UserName' > users.txt

    for user in $(cat users.txt); do
        echo "\nUsuario: $user\n"
        politicas_attached_por_usuario $user
        grupos_por_usuario $user
        versiones_politicas
    done'
    
    user=$1
    aws iam list-users | jq -r '.Users[].UserName' | grep "$user" &>/dev/null && existe=1
    if [[ $existe -eq 1 ]]
    then
        echo -e "\n${GREEN}[+] El usuario${NC} ${YELLOW}$user${NC} ${GREEN}existe ${NC}\n"
        politicas_attached_por_usuario $user
        grupos_por_usuario $user
        versiones_politicas
    else
        echo -e "\n${RED}[-] El usuario $user no existe${NC}\n"
        echo -e "\n${RED}[-] Saliendo...${NC}\n"
    fi
    

}

politicas_attached_por_usuario()
{
    aws iam list-attached-user-policies --user-name $1 | jq -r '.AttachedPolicies[].PolicyArn' >> politicas.txt
}
grupos_por_usuario()
{
    aws iam list-groups-for-user --user-name $1 | jq -r '.Groups[].GroupName' > groups.txt
    for group in $(cat groups.txt); do
        politicas_attached_por_grupo $group
        politicas_por_grupo $group
    done
}

politicas_attached_por_grupo()
{
    aws iam list-attached-group-policies --group-name $1 | jq -r '.AttachedPolicies[].PolicyArn' >> politicas.txt
}

politicas_por_grupo()
{
    aws iam list-group-policies --group-name $1 | jq -r '.PolicyNames[].PolicyArn' >> politicas.txt
}

versiones_politicas()
{
    for policy in $(cat politicas.txt); do
        version=$(aws iam get-policy --policy-arn $policy | jq -r '.Policy.DefaultVersionId')
        aws iam get-policy-version --policy-arn $policy --version-id $version | jq -r '.PolicyVersion.Document.Statement[].Action' >> permisos.txt
        vulnerable=0
        for i in $(cat permisos.txt | tr "[]\"," " " | sed -e 's/^[[:space:]]*//' | sed -r '/^\s*$/d'); do
            
            case $i in

                "iam:CreateAccessKey")
                    echo -e "\n${GREEN}[+] Posible usuario vulnerable a ${YELLOW}iam:CreateAccessKey${NC}${NC}\n"
                    vulnerable=1
                    ;;

                "iam:CreateLoginProfile")
                    echo -e "\n${GREEN}[+] Posible usuario vulnerable a ${YELLOW}iam:CreateLoginProfile${NC}${NC}\n"
                    vulnerable=1
                    ;;
                    
                "iam:UpdateLoginProfile")
                    echo -e "\n${GREEN}[+] Posible usuario vulnerable a ${YELLOW}iam:UpdateLoginProfile${NC}${NC}\n"
                    vulnerable=1
                    ;; 

                "iam:AddUserToGroup")
                    echo -e "\n${GREEN}[+] Posible usuario vulnerable a ${YELLOW}iam:AddUserToGroup${NC}${NC}\n"
                    vulnerable=1
                    ;;

                "iam:CreatePolicyVersion")
                    echo -e "\n${GREEN}[+] Posible usuario vulnerable a ${YELLOW}iam:CreatePolicyVersion${NC}${NC}\n"
                    vulnerable=1
                    ;;
                    
                "iam:SetDefaultPolicyVersion")
                    echo -e "\n${GREEN}[+] Posible usuario vulnerable a ${YELLOW}iam:SetDefaultPolicyVersion${NC}${NC}\n"
                    vulnerable=1
                    ;;

                "iam:AttachUserPolicy")
                    echo -e "\n${GREEN}[+] Posible usuario vulnerable a ${YELLOW}iam:AttachUserPolicy${NC}${NC}\n"
                    vulnerable=1
                    ;;

                "iam:AttachGroupPolicy")
                    echo -e "\n${GREEN}[+] Posible usuario vulnerable a ${YELLOW}iam:AttachGroupPolicy${NC}${NC}\n"
                    vulnerable=1
                    ;;
                    
                "iam:AttachRolePolicy")
                    echo -e "\n${GREEN}[+] Posible usuario vulnerable a ${YELLOW}iam:AttachRolePolicy${NC}${NC}\n"
                    vulnerable=1
                    ;;   

                "iam:PutUserPolicy")
                    echo -e "\n${GREEN}[+] Posible usuario vulnerable a ${YELLOW}iam:PutUserPolicy${NC}${NC}\n"
                    vulnerable=1
                    ;;

                "iam:PutGroupPolicy")
                    echo -e "\n${GREEN}[+] Posible usuario vulnerable a ${YELLOW}iam:PutGroupPolicy${NC}${NC}\n"
                    vulnerable=1
                    ;;
                    
                "iam:PutRolePolicy")
                    echo -e "\n${GREEN}[+] Posible usuario vulnerable a ${YELLOW}iam:PutRolePolicy${NC}${NC}\n"
                    vulnerable=1
                    ;;  
         
            esac

            if [[ $vulnerable -eq 1 ]]
            then
                echo -e "${GREEN}[+] Politica:${NC}\n"
                aws iam get-policy-version --policy-arn $policy --version-id $version
                echo -e "\n"
                vulnerable2=0
            fi
            

        done
        rm -rf permisos.txt
    done

    if [[ $vulnerable2 -ne 0 ]]
    then
        echo -e "\n${RED}[-] El usuario no parece vulnerable${NC}"
    fi
}


borrar_archivos()
{
    rm -rf users.txt
    rm -rf groups.txt
    rm -rf politicas.txt
}

obtener_usuarios $1
borrar_archivos
#!/bin/bash

declare -A EnvArray=(
    [ENV.awsregion]="AWS Region e.g. eu-west-2"
    [ENV.awsaccesskey]="AWS Access Key"
    [ENV.awssecretkey]="AWS Secret Key" 
    [ENV.IPs_AllowedAccess_SSH]="IPs allowed to connect to SSH in format of X.X.X.X/32,Y.Y.Y.Y/32,Z.Z.Z.Z/32"
    [ENV.labsshpubkey]="SSH Public key"
    [ENV.labsshprivatekey]="SSH Private key"
    )

echo "***********************************************************************"
echo "Terraform lab examples under other folders use Vault secret values."
echo ""
echo "This script creates & populates ENV.xxx files, then can use"
echo "terraform to populate Vault values using ENV.xxx file contents"
echo "***********************************************************************"

if ! command -v dialog 2>&1 >/dev/null
then
    echo "ERROR: Dialog command could not be found, please install it to continue (e.g. sudo dnf install dialog)."
    exit
fi

AnyFileUpdated=false
DIALOG_WIDTH=50
DIALOG_HEIGHT=20

for ENV_File in "${!EnvArray[@]}"; do

  if [ -f $ENV_File ];
  then

    DECISION=$(dialog \
        --stdout \
        --title "${ENV_File} already exists" \
        --clear \
        --cancel-label "Exit" \
        --menu "Do you want to update it?" \
            $DIALOG_HEIGHT $DIALOG_WIDTH 1 \
            "No" "Leave existing file" \
            "Yes" "Update file" \
            "Exit" "Exit script" \
        )

    case $DECISION in
      No)
        # dialog --msgbox "No change to ${ENV_File}." 0 0
        echo "No change."
        ;;
      Yes)
        NEWCONTENT=$(dialog \
            --stdout \
            --title "Update content $ENV_File" \
            --backtitle "Please update content for $ENV_File = ${EnvArray[$ENV_File]}" \
            --editbox $ENV_File \
            $DIALOG_HEIGHT $DIALOG_WIDTH
            )

        # Only write contents if NEW contents specified   
        if [[ -n $NEWCONTENT ]];
        then
          echo $NEWCONTENT | xargs > $ENV_File
          dialog --msgbox "Updated $ENV_File" 0 0
        else
          dialog --msgbox "No change to $ENV_File" 0 0
        fi
        ;;
      *)
        # Exit / Cancel 
        exit 0
        ;;
    esac

  else

    touch $ENV_File

    NEWCONTENT=$(dialog \
        --stdout \
        --title "Enter file content to create $ENV_File" \
        --backtitle "Please enter content for $ENV_File = ${EnvArray[$ENV_File]}" \
        --editbox $ENV_File \
        $DIALOG_HEIGHT $DIALOG_WIDTH
        )

    rm $ENV_File

    if [[ -n $NEWCONTENT ]];
    then
      echo $NEWCONTENT | xargs > $ENV_File
      dialog --msgbox "Created $ENV_File" 0 0
    else
      dialog --msgbox "Did not create $ENV_File" 0 0
    fi

  fi

  #read -n 1 -s -p "Press any key to continue..."
done
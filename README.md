# terraform-azure-k3s-lab

## TL;DR:

1. Do not use it in production environments. It's a quick lab.

2. Be authenticated to Azure using AZCLI (.. or change authenticate method in ```azurerm``` provider).

3. Check these variables before applying it:

  - ```rg_name```: Shouldn't exist in your subscription.
  - ```vm_prefix_name```: Shouldn't overlap with current VM's in your subscription.
  - ```vm_username```: Should match your keys.

4. Have fun with the ```terraform apply```.

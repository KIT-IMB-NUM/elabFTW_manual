
# eLabFTW Manual

> A step‑by‑step illustrated guide for installing, configuring, and using eLabFTW and related tools on bwCloud.

<p align="center">
  <img src="./docs/images/cover.png" alt="eLabFTW Manual cover" width="500" />
</p>

---

## Table of Contents

* [Introduction](#introduction)
* [Installing PuTTY and PuTTYgen](#installing-putty-and-puttygen)
* [Creating SSH Keys](#creating-ssh-keys)
* [Starting an Instance on bwCloud](#starting-an-instance-on-bwcloud)
* [Connecting to the Instance via PuTTY](#connecting-to-the-instance-via-putty)
* [Transferring Files (Optional)](#transferring-files-optional)
* [Installing eLabFTW](#installing-elabftw)
* [Configuring Docker and elabctl](#configuring-docker-and-elabctl)
* [Accessing eLabFTW in Browser](#accessing-elabftw-in-browser)
* [Data Storage and Backups](#data-storage-and-backups)
* [Troubleshooting](#troubleshooting)
* [Appendix](#appendix)

---

## Introduction

This manual provides illustrated, step‑by‑step instructions to help you deploy and manage **eLabFTW** on **bwCloud**, from creating SSH keys and instances to installing and configuring the platform.

Each section will include clear explanations, screenshots, and tips for troubleshooting common issues.

> **Note:** All screenshots and command examples will be added as the guide develops. Place them under `./docs/images/` and use relative paths to display them.

---

## Installing PuTTY and PuTTYgen

Install putty and puttygen based on the OS you have.

---

## Creating SSH Keys

The first step is to create a pair of SSH keys that will later be used to connect to the server. These keys will also be required during the instance setup, so we’ll generate them now and reuse them in the next steps.

Open PuTTYgen on your computer.

Select RSA as the key type and set 2048 bits as the key size.

Click Generate, then move your mouse pointer continuously in the blank area until the key generation completes.

<p align="center"> <img src="./docs/images/puttygen.png" alt="PuTTYgen key generation" width="600" /> </p>

Once the key is generated, remove the default key comment and replace it with your email address.
Make sure your email address is also added at the end of the public key text shown in the box.

<p align="center"> <img src="./docs/images/puttygen02.png" alt="PuTTYgen with email added" width="600" /> </p>

Do not close PuTTYgen yet.
Save the private key (.ppk file) with a clear name in a safe location — this file is essential for accessing your instance later.
⚠️ Important: You cannot regenerate or replace this key later; losing it means losing access to your instance.

Keep PuTTYgen open for the next step.

---

## Starting an Instance on bwCloud

To begin, open the bwCloud portal link. Click on **Dashboard** in the upper right corner, as shown below:

<p align="center"><img src="./docs/images/bwCloud_login.png" alt="bwCloud_login" width="650" /></p>

Sign in and select your institute (**KIT**):

<p align="center"><img src="./docs/images/bwcloud_login02.png" alt="bwcloud_login02" width="520" /></p>

Enter your KIT account credentials to log in to the portal:

<p align="center"><img src="./docs/images/bw_portal01.png" alt="bw_portal01" width="520" /></p>

Next, import the SSH key you generated with PuTTYgen. Under **Compute**, click **Key Pairs**, then select **Import Key** at the top right.

Fill in the required fields as shown below, then click **Import Key**. Your key will appear in the list.

<p align="center"><img src="./docs/images/bw_portal02.png" alt="bw_portal02" width="520" /></p>

Now, create a new instance. Under **Compute**, click **Instances**, then select **Launch Instance**.

<p align="center"><img src="./docs/images/instance01.png" alt="instance01" width="650" /></p>

Assign a name to your instance and click **Next**. Choose an operating system (e.g., **Ubuntu 24.04**), then click **Next**.

In the **Flavor** section, select one of the available hardware configurations.

<p align="center"><img src="./docs/images/instance02.png" alt="instance02" width="520" /></p>

Continue with the default settings until you reach the **Key Pair** section. Here, select the SSH key you imported earlier, then click **Launch Instance**.

<p align="center"><img src="./docs/images/instance03.png" alt="instance03" width="520" /></p>

After a short wait, your instance will be created. You should see it listed as shown below. Copy the instance's IP address—you will need it to connect via PuTTY in the next step.

<p align="center"><img src="./docs/images/instance04.png" alt="instance04" width="520" /></p>

---

## Connecting to the Instance via PuTTY

Open the **PuTTY** application. In the left sidebar, navigate to **Connection > SSH > Auth**. Here, you will specify your credentials as shown below:

<p align="center"><img src="./docs/images/putty01.png" alt="PuTTY SSH Auth settings" width="600" /></p>

Click **Browse** and select the `.ppk` private key file you saved earlier with PuTTYgen.

Next, return to the **Session** section. Enter your instance's IP address in the **Host Name (or IP address)** field. Optionally, assign a name to your session and click **Save**. Double-click your saved session to connect, as illustrated below:

<p align="center"><img src="./docs/images/putty02.png" alt="PuTTY session setup" width="600" /></p>

If PuTTY displays a security alert, click **accept** it.

When prompted for a login name, enter `ubuntu`. You should now see the terminal window, confirming a successful connection:

<p align="center"><img src="./docs/images/putty03.png" alt="PuTTY terminal login" width="600" /></p>
<p align="center"><img src="./docs/images/putty04.png" alt="Connected terminal" width="600" /></p>

---



## Installing dependencies of elabftw

To prepare your system for **eLabFTW**, you'll need to install several dependencies using **elabctl**. For detailed instructions and further documentation, refer to [the official eLabFTW documentation](https://doc.elabftw.net/).

Begin by installing `curl`, which is required for downloading files:

```bash
sudo apt update && sudo apt install -y curl
```

Verify the installation by checking the version:

```bash
curl --version
```

Next, download and install Docker Compose:

```bash
sudo curl -SL https://github.com/docker/compose/releases/download/v2.39.4/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
```

Make Docker Compose executable:

```bash
sudo chmod +x /usr/local/bin/docker-compose
```

Create a symbolic link for easier access:

```bash
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```

Confirm Docker Compose is installed correctly:

```bash
docker-compose --version
```

Install Docker itself:

```bash
sudo apt install -y docker.io
```

Additionally, install `dialog` and `borgbackup` for interactive dialogs and backup management:

```bash
sudo apt install -y dialog borgbackup
```

Check their installations:

```bash
dialog --version
borgbackup --version
```

## Installing eLabFTW


To install **eLabFTW** using the official installer script, run the following commands in your terminal. These commands will download the `elabctl` installer, make it executable, move it to a system-wide location, and start the installation process:

```bash
curl -sL https://get.elabftw.net -o elabctl
chmod +x elabctl
sudo mv elabctl /usr/local/bin/
elabctl install
```

The installer will guide you through the setup steps. Follow the prompts to complete the installation.

Follow the on-screen instructions to configure your eLabFTW instance.
<p align="center"><img src="./docs/images/elabctl01.png" alt="elabctl installation step 1" width="600" /></p >

<p align="center"><img src="./docs/images/elabctl02.png" alt="elabctl installation step 2" width="600" /></p >

Now it is time to choose if you have a domain name or if you want to use the IP address of your instance to access eLabFTW. For using the IP address, you have to choose local computer instead of a server with a domain name.

<p align="center"><img src="./docs/images/elabctl03.png" alt="elabctl installation step 3" width="600" /></p >

## Configuring the .yml file

After the installation, it is time to configure the elabftw.yml file. for running it on your local computer keep the default settings. However it you are installing it on a server like bwCloud, you need to change the url to your IP address like shown below.

<p align="center"><img src="./docs/images/yml.png" alt="elabctl yml configuration" width="600" /></p >
then save the file and exit the editor.

Now it is time to start and initialize eLabFTW with the following command:

```bash
sudo elabctl start
sudo elabctl initialize
```
and wait until the process is finished as shown below.
<p align="center"><img src="./docs/images/elabctl04.png" alt="elabctl initialization" width="600" /></p >

keep in mind that the initialization process might take a while. Even if it shows done and healthy, it might still be in progress.
*(Content to be added later)*

---

## Accessing eLabFTW in Browser

If you set everything up correctly, you should be able to access eLabFTW in your web browser by navigating to 

`https://<your-instance-ip>` for installing on bwCloud
or 
`https://localhost` for installing on your local computer.

<p align="center"><img src="./docs/images/elabFTWbrowser.png" alt="eLabFTW login page" width="600" /></p >

---

## Data Storage and Backups

*(Content to be added later)*

---

## Troubleshooting

*(Content to be added later)*

---

## Appendix

Additional resources, references, and external documentation links will be added here.

---

> **Next step:** You can now start adding the written content and screenshots section by section. I’ll help format and illustrate them as you provide each part.

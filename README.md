# elabFTW_manual

# eLabFTW Manual

> A step‑by‑step illustrated guide for installing, configuring, and using eLabFTW and related tools on bwCloud.

<p align="center">
  <img src="./docs/images/hero.png" alt="eLabFTW Manual cover" width="800" />
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

you open the link
 and click on dashbord on the right corner up and then continue the same as screenshot.

<p align="center"><img src="./docs/images/bwCloud_login.png" alt="bwCloud_login" width="800" /></p>

Then sign in and choose the institute KIT

<p align="center"><img src="./docs/images/bwcloud_login02.png" alt="bwcloud_login02" width="800" /></p>

Then enter the KIT account credentials and log in to the portal (below screenshot)

<p align="center"><img src="./docs/images/bw_portal01.png" alt="bw_portal01" width="800" /></p>

Now you need to load the key that you have already generated using puttygen

under compute click on the key pairs and then click on the import key on the top right of the page

fill in the blanks as the screen shot below and then import the key. Then it will be listed there.

<p align="center"><img src="./docs/images/bw_portal02.png" alt="bw_portal02" width="800" /></p>

Now it is time to create an instance. Under compute click on instances and then click on lunch instance. then such window will open fo you

<p align="center"><img src="./docs/images/instance01.png" alt="instance01" width="800" /></p>

assign a name and click on next. then choose an operating system. we choose ubuntu 24.04 here and then click on next.

Then in flavor choose one of the available hardware configurations

<p align="center"><img src="./docs/images/instance02.png" alt="instance02" width="800" /></p>

After that you can continue the default values until the key pair section. There choose the saved key of prevoius step and click on lunch instance. the below screenshot

<p align="center"><img src="./docs/images/instance03.png" alt="instance03" width="800" /></p>

then the instance will be ceated after a few moments like the below screenshot. copy the ip address because you will need it to connect to instance using putty

<p align="center"><img src="./docs/images/instance04.png" alt="instance04" width="800" /></p>

---

## Connecting to the Instance via PuTTY

*(Content to be added later)*

---

## Transferring Files (Optional)

*(Content to be added later)*

---

## Installing eLabFTW

*(Content to be added later)*

---

## Configuring Docker and elabctl

*(Content to be added later)*

---

## Accessing eLabFTW in Browser

*(Content to be added later)*

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

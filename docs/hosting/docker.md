# Self Hosting Maybe with Docker

This guide will help you setup, update, and maintain your self-hosted Maybe application with Docker Compose. Docker Compose is the most popular and recommended way to self-host the Maybe app.

## Setup Guide

Follow the guide below to get your app running.

### Step 1: Install Docker

Complete the following steps:

1. Install Docker Engine by following [the official guide](https://docs.docker.com/engine/install/)
2. Start the Docker service on your machine
3. Verify that Docker is installed correctly and is running by opening up a terminal and running the following command:

```bash
# If Docker is setup correctly, this command will succeed
docker run hello-world
```

### Step 2: Configure your Docker Compose file and environment

#### Create a directory for your app to run

Open your terminal and create a directory where your app will run. Below is an example command with a recommended directory:

```bash
# Create a directory on your computer for Docker files (name whatever you'd like)
mkdir -p ~/docker-apps/maybe

# Once created, navigate your current working directory to the new folder
cd ~/docker-apps/maybe
```

#### Copy our sample Docker Compose file

Make sure you are in the directory you just created and run the following command:

```bash
# Download the sample compose.yml file from the Maybe Github repository
curl -o compose.yml https://raw.githubusercontent.com/maybe-finance/maybe/main/compose.example.yml
```

This command will do the following:

1. Fetch the sample docker compose file from our public Github repository
2. Creates a file in your current directory called `compose.yml` with the contents of the example file

At this point, the only file in your current working directory should be `compose.yml`.

### Step 3 (optional): Configure your environment

By default, our `compose.example.yml` file runs without any configuration.  That said, if you would like extra security (important if you're running outside of a local network), you can follow the steps below to set things up.

If you're running the app locally and don't care much about security, you can skip this step.

#### Create your environment file

In order to configure the app, you will need to create a file called `.env`, which is where Docker will read environment variables from.

To do this, run the following command:

```bash
touch .env
```

#### Generate the app secret key

The app requires an environment variable called `SECRET_KEY_BASE` to run.

We will first need to generate this in the terminal. If you have `openssl` installed on your computer, you can generate it with the following command:

```bash
openssl rand -hex 64
```

_Alternatively_, you can generate a key without openssl or any external dependencies by pasting the following bash command in your terminal and running it:

```bash
head -c 64 /dev/urandom | od -An -tx1 | tr -d ' \n' && echo
```

Once you have generated a key, save it and move on to the next step.

#### Fill in your environment file

Open the file named `.env` that we created in a prior step using your favorite text editor.

Fill in this file with the following variables:

```txt
SECRET_KEY_BASE="replacemewiththegeneratedstringfromthepriorstep"
POSTGRES_PASSWORD="replacemewithyourdesireddatabasepassword"
```

**IMPORTANT FOR AUTO-SYNCING ACCOUNTS WITH PLAID**

The original authors of Maybe tried to sell a version that they hosted and supported on their(?) servers. The usage of Plaid was intended to be exclusively for this platform, but this has since shut down. 

I have found a method to restore this functionality. In the future, I plan to tweak the code to avoid the need for this workaround, but at any rate, it still works.

In your `.env` file, make sure to include the following:

```txt
PLAID_ENV=production
PLAID_CLIENT_ID=<YOUR_ID_HERE>
PLAID_SECRET=<YOUR_SECRET_HERE>
```

The included `.env.example` file includes this already.

*For linked accounts/Plaid integration to work, you will need to have a Plaid developer account WITH PRODUCTION ACCESS ENABLED!! Log into the [Plaid dashboard](https://dashboard.plaid.com/onboarding) and send a request to the Plaid support team. Once your account is granted production access, you will have a client ID and a secret key that you can access from your account*

Bear in mind that this API is not free -- it is billed on a "pay-as-you-go" basis. See Plaid's cost schedule and billing information for more info.

As a security measure, Plaid only allows your web client to be redirected to certain URIs after connection of a financial institution is complete.

By default, your account will have no allowed redirect URIs. You will need to log in to the Plaid developer dashboard, and navigate to: "Platform > Developers > API > Allowed redirect URIs". Click "Configure" and add the URL that Maybe is hosted on.

For me personally, I use [Nginx Proxy Manager](https://nginxproxymanager.com/) to give Maybe a friendly DNS name and SSL tunneling. If you're unaware what that means: "http://192.168.x.y:3000" is accessible from "https://maybe.example.com" thanks to the reverse proxy.

So, the allowed redirect URIS that you should configure here are:

```txt
https://localhost:3000
https://maybe.example.com
```

After you have added the production-level Plaid env vars to your `.env` file, and added valid "Allowed redirect URIs", there is one final step to enable the "Link account" feature.

In your Docker Compose file (`compose.yml`), set `SELF_HOSTED` to `false`. Then, launch the app with `docker-compose up`. This works without blowing away existing data.

Log in to Maybe once it is launched and it will say something about a free trial. Accept the free trial and go to `https://yourhostformaybe.com/accounts`. Click "Add account" in the top right corner, and click any account where Plaid is supported (Depository/Cash, Credit Card, Loan, Investment, or Crypto).

When you click on the account type, a new window should pop with two options: "manual" or "link". At this point, you can move on, and do not need to add any accounts.

Tear down the app (`docker-compose down`) and set the `SELF_HOSTED` variable back to `true`. When you restart Maybe, you should now be able to add linked accounts! This feature is, for some reason, disabled by default for self-hosted instances, but works nonetheless if you perform this workaround.

For clarity: There is no 14-day trial that will be enforced and the "link account" button should be enabled in perpetuity after resetting the value of `SELF_HOSTED` to true.

You can now add accounts via the UI as normal, and they will auto-sync balances and transactions *WITHOUT NEEDING TO IMPORT CSV FILES MANUALLY!!*

One last major hurdle to get this to work: Plaid webhooks. Plaid informs its data clients (Maybe) of new data available via webhooks. That is, a Plaid server reaches out to: `https://yourhostformaybe.com/webhooks/plaid`. For this to work, you will need a registered public DNS name (which unfortunately does cost money) and the ability to port-forward ports 80 (HTTP) and 443 (HTTPS) on your router. If you aren't comfortable hosting from home, you can also use a rented server or cloud instance to host Maybe. Nonetheless, you will still need a DNS name that you can control.

I used Cloudflare for this purpose, but just about any capable DNS registrar should work.

If you're going this route, and are not hosting this on a cloud platform separate from your home network, I **STRONGLY RECOMMEND** mandating SSL, and using a proxy manager on your local network to restrict access control to only Maybe on your network. An SELinux host would also be a good idea. You will need to make your Maybe instance and public domain accessible from WAN by directing your DNS host to your home network's public IP. A detailed guide on how to do this can be generated upon request; either create an issue against this project or [email me](mailto:scott.carrion@gmail.com).

Enjoy!

### Step 4: Run the app

You are now ready to run the app. Start with the following command to make sure everything is working:

```bash
docker compose up
```

This will pull our official Docker image and start the app. You will see logs in your terminal.

Open your browser, and navigate to `http://localhost:3000`.

If everything is working, you will see the Maybe login screen.

### Step 5: Create your account

The first time you run the app, you will need to register a new account by hitting "create your account" on the login page.

1. Enter your email
2. Enter a password

### Step 6: Run the app in the background

Most self-hosting users will want the Maybe app to run in the background on their computer so they can access it at all times. To do this, hit `Ctrl+C` to stop the running process, and then run the following command:

```bash
docker compose up -d
```

The `-d` flag will run Docker Compose in "detached" mode. To verify it is running, you can run the following command:

```
docker compose ls
```

### Step 7: Enjoy!

Your app is now set up. You can visit it at `http://localhost:3000` in your browser.

If you find bugs or have a feature request, be sure to read through our [contributing guide here](https://github.com/maybe-finance/maybe/wiki/How-to-Contribute-Effectively-to-this-Project).

## How to update your app (no longer applies)

The mechanism that updates your self-hosted Maybe app is the GHCR (Github Container Registry) Docker image that you see in the `compose.yml` file:

```yml
image: ghcr.io/maybe-finance/maybe:latest
```

We recommend using one of the following images, but you can pin your app to whatever version you'd like (see [packages](https://github.com/maybe-finance/maybe/pkgs/container/maybe)):

- `ghcr.io/maybe-finance/maybe:latest` (latest commit)
- `ghcr.io/maybe-finance/maybe:stable` (latest release)

By default, your app _will
NOT_ automatically update. To update your self-hosted app, run the following commands in your terminal:

```bash
cd ~/docker-apps/maybe # Navigate to whatever directory you configured the app in
docker compose pull # This pulls the "latest" published image from GHCR
docker compose build # This rebuilds the app with updates
docker compose up --no-deps -d web worker # This restarts the app using the newest version
```

## How to change which updates your app receives

If you'd like to pin the app to a specific version or tag, all you need to do is edit the `compose.yml` file:

```yml
image: ghcr.io/maybe-finance/maybe:stable
```

After doing this, make sure and restart the app:

```bash
docker compose pull # This pulls the "latest" published image from GHCR
docker compose build # This rebuilds the app with updates
docker compose up --no-deps -d app # This restarts the app using the newest version
```

## Troubleshooting

### ActiveRecord::DatabaseConnectionError

If you are trying to get Maybe started for the **first time** and run into database connection issues, it is likely because Docker has already initialized the Postgres database with a _different_ default role (usually from a previous attempt to start the app).

If you run into this issue, you can optionally **reset the database**.

**PLEASE NOTE: this will delete any existing data that you have in your Maybe database, so proceed with caution.**  For first-time users of the app just trying to get started, you're generally safe to run the commands below.

By running the commands below, you will delete your existing Maybe database and "reset" it.

```
docker compose down
docker volume rm maybe_postgres-data # this is the name of the volume the DB is mounted to
docker compose up
docker exec -it maybe-postgres-1 psql -U maybe -d maybe_production -c "SELECT 1;" # This will verify that the issue is fixed
```
